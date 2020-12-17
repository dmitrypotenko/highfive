import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

sendPush(List<Contact> contactsToSend, BuildContext context, String comment, String highfiveId) async {
  var data = new Map();
  data['to'] = contactsToSend.map((contact) => contact.phones.map((e) => e.value).toList(growable: true)).reduce((value, contact) {
    value.addAll(contact);
    return value;
  }).toSet().toList();
  data['from'] = FirebaseAuth.instance.currentUser.phoneNumber;
  data['comment'] = comment;
  data['highfiveId'] = highfiveId;

  await post("https://us-central1-highfive-311f2.cloudfunctions.net/sendPushNotification",
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"to": data['to'], "from": data['from'], "comment": data['comment'], "highfiveId": data['highfiveId']}));
  await showDialog<void>(
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Пятюня полетела!'),
          actions: <Widget>[
            TextButton(
              child: Text('Ясно, понятно'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
      context: context);
}
