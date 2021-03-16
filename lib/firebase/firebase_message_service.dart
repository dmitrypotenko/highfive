import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:highfive/highfive/highfive_service.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:vibration/vibration.dart';

class FirebaseMessageService {
  HighfiveService _highfiveService;
  final _controller = StreamController<HighFiveData>();

  Stream<HighFiveData> get newHighfive async* {
    yield* _controller.stream;
  }

  FirebaseMessageService(this._highfiveService) {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        var highFiveData = parseHighFiveData(message.data);
        _highfiveService.handleHighFiveData(highFiveData);
      }
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      var highFiveData = parseHighFiveData(message.data);
      _highfiveService.handleHighFiveData(highFiveData);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var highFiveData = parseHighFiveData(message.data);
      _highfiveService.insertReceivedHighFive(highFiveData);
      _controller.add(highFiveData);
      Vibration.vibrate(duration: 300);
    });
  }

  Future<void> _saveTokenToDatabase(String token) async {
    print('Saving new token to database');
    // Assume user is logged in for this example
    String phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (phoneNumber != null) {
      await FirebaseFirestore.instance.collection('users').doc(phoneNumber).set({
        'tokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  Future<void> refreshToken() async {
    FirebaseMessaging.instance.getToken().then(_saveTokenToDatabase);
  }
}

HighFiveData parseHighFiveData(Map<String, dynamic> data) {
  var highFiveData = new HighFiveData(data['sender'], int.parse(data['highfiveId']), data['comment'], int.parse(data['timestamp']), data['id']);
  highFiveData.acknowledged = false;
  return highFiveData;
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  HighfiveService highfiveService = locator.get();
  var highFiveData = parseHighFiveData(message.data);
  return highfiveService.insertReceivedHighFive(highFiveData);
}
