import 'dart:async';

import 'package:flutter/material.dart';
import 'package:highfive/loading/loading_widget.dart';
import 'package:highfive/highfive/high_five_model.dart';
import 'package:highfive/highfive/high_fives_holder.dart';
import 'package:highfive/contact/contacts.dart';
import 'highfive_list_widget.i18n.dart';

class HighfiveListWidget extends StatefulWidget {
  @override
  State createState() => HighfiveListWidgetState();
}

class HighfiveListWidgetState extends State {
  void refresh() {
    setState(() {
      new HighFivesHolder().invalidate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: getHighFives(),
        builder: (BuildContext context, AsyncSnapshot<List<HighFiveModel>> snapshot) {
          if (snapshot.hasData) {
            return new Scaffold(
              appBar: new AppBar(
                title: new Text('Что послать?'.i18n),
                actions: [
                  new IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => refresh(),
                  ),
                ],
              ),
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
                                color: new Color(snapshot.data[index].color),
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: new Color(snapshot.data[index].color).withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: new Column(
                              children: [
                                snapshot.data[index].getNetworkCachedImage(),
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
  }
}

Future<List<HighFiveModel>> getHighFives() {
  return new HighFivesHolder().highFives;
}
