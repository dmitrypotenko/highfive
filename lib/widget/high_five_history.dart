import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/main.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:highfive/route/contacts.dart';
import 'package:highfive/widget/high_five_list.dart';

class HighFiveHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var phoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;
    return StreamBuilder<List<HighFiveData>>(
      stream:
          FirebaseFirestore.instance.collection('highfives').where('to', arrayContains: phoneNumber).snapshots().map((receivedHighFives) {
        var resultHighFives = receivedHighFives.docs.map((doc) {
          var data = doc.data();
          return parseHighFiveData(data, doc.id);
        }).toList(growable: true);
        resultHighFives.sort((HighFiveData first, HighFiveData second) => -first.timestamp.compareTo(second.timestamp));
        return resultHighFives;
      }),
      builder: (BuildContext context, AsyncSnapshot<List<HighFiveData>> snapshot) {
        if (snapshot.hasData) {
          Widget child = new Text('У вас нет непросмотренных пятюнь');
          if (snapshot.data.length > 0) {
            child = new ListView(
              children: snapshot.data
                  .map(
                    (highfive) => new ListTile(
                      leading: Icon(
                        Icons.arrow_back,
                        color: Colors.green,
                      ),
                      title: new FutureBuilder<String>(
                        future: getContacts().then((contacts) => findContact(contacts, highfive.sender).displayName),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            return new Text(snapshot.data);
                          }
                          return new Text(highfive.sender);
                        },
                      ),
                      onTap: () async => handleHighFiveData(context, highfive),
                    ),
                  )
                  .toList(),
            );
          }
          return new Scaffold(
            body: new SafeArea(
              child: new Container(child: child),
            ),
            bottomNavigationBar: new BottomAppBar(
              child: new ElevatedButton(
                child: new Text('Хочу послать пятюню'),
                onPressed: () => Navigator.of(context).push(new HighFiveList()),
              ),
            ),
          );
        } else {
          return LoadingWidget();
        }
      },
    );
  }
}

HighFiveData parseHighFiveData(Map<String, dynamic> data, String docId) {
  var highFiveData = new HighFiveData(data['sender'], data['highfiveId'], data['comment'], int.parse(data['timestamp']));
  highFiveData.documentId = docId;
  return highFiveData;
}
