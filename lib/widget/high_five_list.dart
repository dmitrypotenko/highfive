import 'dart:async';

import 'package:flutter/material.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/model/high_five.dart';

import 'file:///C:/Users/Dzmitry_Potenko/AndroidStudioProjects/highfive/lib/route/contacts.dart';

class HighFiveList extends MaterialPageRoute {
  HighFiveList()
      : super(builder: (BuildContext context) {
          return new FutureBuilder(
              future: getHighFives(),
              builder: (BuildContext context, AsyncSnapshot<List<HighFive>> snapshot) {
                if (snapshot.hasData) {
                  return new Scaffold(
                    body: SafeArea(
                      child: new Container(
                        child: new Column(
                          children: snapshot.data
                              .map(
                                (highfive) => new InkWell(
                                  onTap: () => Navigator.of(context).push(new ContactsRoute(highfive)),
                                  child: new Container(
                                    child: new Column(
                                      children: [new Image(image: new AssetImage(highfive.imageUrl)), new Text(highfive.name)],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  );
                } else {
                  return new LoadingWidget();
                }
              });
        });
}

Future<List<HighFive>> getHighFives() {
  return new Future<List<HighFive>>(() => [new HighFive("обычная пацанская пятюня", "assets/highfive.jpg", 1, "обычную пацанскую пятюню")]);
}
