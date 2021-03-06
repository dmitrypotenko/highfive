import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:highfive/error/error.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:highfive/repository/repository.dart';
import 'package:highfive/route/highfive_route.dart';
import 'package:highfive/route/navigation.dart';
import 'package:highfive/widget/delete_consent.dart';
import 'package:highfive/widget/high_five_widget.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart' as Sentry;
import 'package:sqflite/sqflite.dart';
import 'package:vibration/vibration.dart';

import 'login/login.dart';
import 'model/change_notifier_highfive.dart';
import 'model/contacts_holder.dart';
import 'model/high_fives_holder.dart';
import 'widget/high_five_history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sentry.SentryFlutter.init(
    (options) => options.dsn = 'https://a5ad20b8cd2d4d289ab851898389133e@o497715.ingest.sentry.io/5574163',
    appRunner: () => runZonedApp(),
  );
}

runZonedApp() {
  GlobalKey<NavigatorState> key = GlobalKey();
  setupLocator(key);
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode, report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  runZonedGuarded<Future<void>>(() async {
    runApp(
      new OverlaySupport(
        child: MaterialApp(
          navigatorKey: key,
          home: new App(),
          theme: ThemeData(
            primaryColor: Colors.white,
          ),
          routes: {
            "delete-highfive": (context) => DeleteConsentWidget(),
          },
          title: 'Пятюня app',
          onGenerateRoute: (settings) {
            if (settings.name == "highfive") {
              return HighFiveRoute.createInstance(settings);
            }
            return null;
          },
        ),
      ),
    );
  }, (Object error, StackTrace stackTrace) {
    // Whenever an error occurs, call the `_reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    reportError(error, stackTrace);
  });
}

class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  User _user = null;
  bool listening = false;
  Future<List<HighFiveData>> _highfives;
  FutureBuilder<List<HighFiveData>> highFiveHistoryList;
  String _verificationId;

  Database db;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();

      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
      FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    askForPermissions();
    _highfives = readHighFives();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      readHighFives().then((readHighFives) {
        _changeNotifierHighFive.highFives = readHighFives;
      });
    }
  }

  Future<PermissionStatus> askForPermissions() async {
    var status = await Permission.contacts.status;
    if (status.isUndetermined || status.isDenied) {
      return Permission.contacts.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return CustomErrorWidget(Error());
    }
    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return LoadingWidget();
    }
    if (_user == null && FirebaseAuth.instance.currentUser != null) {
      _user = FirebaseAuth.instance.currentUser;
    }
    if (!listening) {
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          var highFiveData = parseHighFiveData(message.data);
          handleHighFiveData(highFiveData);
        }
      });
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        var highFiveData = parseHighFiveData(message.data);
        handleHighFiveData(highFiveData);
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var highFiveData = parseHighFiveData(message.data);
        _changeNotifierHighFive.add(highFiveData);
        insertReceivedHighFive(highFiveData);
        Vibration.vibrate(duration: 300);
        if (message.notification != null) {
          showSimpleNotification(
            Builder(builder: (context) {
              return GestureDetector(
                key: new UniqueKey(),
                child: new Container(
                  child: new Text(
                    "Вам прислали пятюню!",
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  height: 50,
                ),
                onTap: () async {
                  handleHighFiveData(highFiveData);
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity < 0) {
                    OverlaySupportEntry.of(context).dismiss();
                  }
                },
              );
            }),
            duration: new Duration(seconds: 5),
            key: new UniqueKey(),
          );
        }
      });
      listening = true;
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        print('User state changed AppWidget');
        if (user == null) {
          setState(() {
            this._user = null;
          });
        } else {
          FirebaseMessaging.instance.getToken().then(saveTokenToDatabase);
          setState(() {
            this._user = user;
          });
        }
      });
    }
    if (_user == null && _verificationId == null) {
      return SetPhoneNumberWidget((smsSent) => setState(() {
            this._verificationId = smsSent;
          }));
    } else if (_verificationId != null && _user == null) {
      return SmsRoute(_verificationId);
    } else {
      highFiveHistoryList = new FutureBuilder<List<HighFiveData>>(
        future: _highfives,
        builder: (BuildContext context, AsyncSnapshot<List<HighFiveData>> snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            _changeNotifierHighFive.highFives = snapshot.data;
            return new ChangeNotifierProvider(
              create: (context) => _changeNotifierHighFive,
              child: new HighFiveHistory(),
            );
          } else {
            return LoadingWidget();
          }
        },
      );
      return highFiveHistoryList;
    }
  }
}

ChangeNotifierHighFive _changeNotifierHighFive = new ChangeNotifierHighFive();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  var highFiveData = parseHighFiveData(message.data);
  return insertReceivedHighFive(highFiveData);
}

Future<void> handleHighFiveData(HighFiveData highFiveData) async {
  if (highFiveData.acknowledged == false) {
    acknowledge(highFiveData.documentId);
    highFiveData.acknowledged = true;
  }
  var contactsHolder = new ContactsHolder();
  String contact = await contactsHolder.getContacts().then((contacts) => contactsHolder.findContact(contacts, highFiveData.sender).displayName);
  var highFive = await new HighFivesHolder().getById(highFiveData.highfiveId);

  locator.get<NavigationService>().pushNamed("highfive",
      arguments: {"documentId": highFiveData.documentId, "contact": contact, "highfiveModel": highFive, "comment": highFiveData.comment});
}
