import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:highfive/error/error.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:highfive/route/high_five_route.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
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

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  User _user = null;
  bool listening = false;

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

    super.initState();
  }

  Future<void> initDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    var databasePath = await getDatabasesPath();
    db = await openDatabase(join(databasePath, 'highfive.db'), onCreate: (db, version) {
      return db
          .execute(
            'CREATE TABLE highfive(id TEXT PRIMARY KEY, highfive_id INTEGER, comment TEXT, timestamp INTEGER, sender_id INTEGER)',
          )
          .then((value) => db.execute('CREATE TABLE phone(id INTEGER PRIMARY KEY autoincrement, phone_number TEXT)'))
      .then((value) => db.execute('CREATE TABLE send_to(id INTEGER PRIMARY KEY autoincrement, highfive_id TEXT, phone_id INTEGER)'));
    }, version: 1);
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
          handleHighFiveMessage(context, message);
        }
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleHighFiveMessage(context, message);
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Vibration.vibrate(duration: 300);
        if (message.notification != null) {
          showSimpleNotification(
            GestureDetector(
              child: new Text("Вам прислали пятюню!"),
              onTap: () async {
                handleHighFiveMessage(context, message);
              },
            ),
            duration: new Duration(seconds: 10),
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
      return new HighFiveHistory();
    }
  }
}

ChangeNotifierHighFive _changeNotifierHighFive = new ChangeNotifierHighFive();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

Future<void> handleHighFiveMessage(BuildContext context, RemoteMessage message) async {
  return handleHighFiveData(context, parseHighFiveData(message.data, message.data['id']));
}

Future<void> handleHighFiveData(BuildContext context, HighFiveData highFiveData) async {
  List<HighFive> highfives = await getHighFives();
  String contact = await getContacts().then((contacts) => findContact(contacts, highFiveData.sender).displayName);
  Navigator.of(context).push(new HighFiveRoute(
      highfives.firstWhere((highfive) => highfive.id.toString() == highFiveData.highfiveId), highFiveData.comment, contact));
  FirebaseFirestore.instance.collection('highfives').doc(highFiveData.documentId).update({
    'to': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser.phoneNumber]),
  });
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
