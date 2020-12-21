import 'dart:async';

import 'package:flutter/material.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/model/high_fives_holder.dart';
import 'package:highfive/route/contacts.dart';
import 'package:highfive/util/util.dart';

class HighFiveList extends MaterialPageRoute {
  HighFiveList()
      : super(builder: (BuildContext context) {
          return new FutureBuilder(
              future: getHighFives(),
              builder: (BuildContext context, AsyncSnapshot<List<HighFive>> snapshot) {
                if (snapshot.hasData) {
                  return new Scaffold(
                    body: SafeArea(
                      child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 22),
                          physics: new BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index >= snapshot.data.length) {
                              return null;
                            } else {
                              return new InkWell(
                                onTap: () => Navigator.of(context).push(new ContactsRoute(snapshot.data[index])),
                                child: new Container(
                                  decoration: BoxDecoration(
                                      color: getColor(index),
                                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: getColor(index).withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3), // changes position of shadow
                                        ),
                                      ]),
                                  child: new Column(
                                    children: [
                                      new Image(image: new AssetImage(snapshot.data[index].imageUrl)),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        child: new Text(
                                          snapshot.data[index].name,
                                          style: new TextStyle(color: Colors.white, fontSize: 20),
                                        ),
                                      )
                                    ],
                                  ),
                                  margin: EdgeInsets.all(20),
                                ),
                              );
                            }
                          }),
                    ),
                  );
                } else {
                  return new LoadingWidget();
                }
              });
        });
}

Future<List<HighFive>> getHighFives() {
  return new HighFivesHolder().highFives;
}
