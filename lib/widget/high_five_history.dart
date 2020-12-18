import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/main.dart';
import 'package:highfive/model/change_notifier_highfive.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:highfive/route/contacts.dart';
import 'package:highfive/widget/high_five_list.dart';
import 'package:provider/provider.dart';

class HighFiveHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var highFivesModel = context.watch<ChangeNotifierHighFive>();
    Widget child = new Text('У вас нет непросмотренных пятюнь');
    if (highFivesModel.highFives.length > 0) {
      child = new ListView(
        children: highFivesModel.highFives
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
  }
}

HighFiveData parseHighFiveData(Map<String, dynamic> data) {
  var highFiveData = new HighFiveData(data['sender'], int.parse(data['highfiveId']), data['comment'], int.parse(data['timestamp']), data['id']);
  return highFiveData;
}
