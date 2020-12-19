import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:highfive/error/error.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:highfive/repository/repository.dart';
import 'package:highfive/route/high_five_route.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vibration/vibration.dart';

import 'login/login.dart';
import 'model/change_notifier_highfive.dart';
import 'widget/high_five_history.dart';
import 'widget/high_five_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    new OverlaySupport(
      child: MaterialApp(
        home: new App(),
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        title: 'Пятюня app',
      ),
    ),
  );
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

  Database db;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
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
      readHighFives().then((value) {
        _changeNotifierHighFive.highFives = value;
        _changeNotifierHighFive.notifyListeners();
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
      return CustomErrorWidget();
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
          handleHighFiveData(context, highFiveData);
        }
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        var highFiveData = parseHighFiveData(message.data);
        handleHighFiveData(context, highFiveData);
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
                  handleHighFiveData(context, highFiveData);
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
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
      FirebaseMessaging.instance.getToken().then(saveTokenToDatabase);
      FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
      listening = true;
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        print('User state changed AppWidget');
        if (user == null) {
          setState(() {
            this._user = null;
          });
        } else {
          setState(() {
            this._user = user;
          });
        }
      });
    }
    if (_user == null) {
      return SetPhoneNumberWidget();
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

Future<void> handleHighFiveData(BuildContext context, HighFiveData highFiveData) async {
  if (highFiveData.acknowledged == false) {
    acknowledge(highFiveData.documentId);
    highFiveData.acknowledged = true;
  }
  List<HighFive> highfives = await getHighFives();
  String contact = await getContacts().then((contacts) => findContact(contacts, highFiveData.sender).displayName);
  Navigator.of(context).push(_createRoute(
      highfives.firstWhere((highfive) => highfive.id == highFiveData.highfiveId), highFiveData.comment, contact, highFiveData.documentId));
}

Contact findContact(Iterable<Contact> contacts, String senderPhone) {
  return contacts.firstWhere((contact) => contact.phones.map((e) => e.value).contains(senderPhone),
      orElse: () => new Contact(displayName: senderPhone));
}

Future<Iterable<Contact>> contacts;

Future<Iterable<Contact>> getContacts() async {
  if (contacts == null) {
    contacts = ContactsService.getContacts(withThumbnails: false);
  }

  return contacts;
}

Route _createRoute(HighFive highFive, String comment, String contact, String docId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => new HighFiveWidget(highFive, comment, contact, docId),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    transitionDuration: new Duration(milliseconds: 500),
  );
}
