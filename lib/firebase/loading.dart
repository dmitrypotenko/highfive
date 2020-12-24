import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new Column(
          children: [
            new Image.asset("assets/highfive.gif"),
            new Text(
              "Подгрузочка...",
              style: new TextStyle(fontSize: 26),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

Future<void> saveTokenToDatabase(String token) async {
  print('Saving new token to database');
  // Assume user is logged in for this example
  String phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
  if (phoneNumber != null) {
    await FirebaseFirestore.instance.collection('users').doc(phoneNumber).set({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }
}
