import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/model/high_five.dart';

class HighFiveRoute extends MaterialPageRoute {
  HighFiveRoute(HighFive highFive, String comment, String contact)
      : super(builder: (BuildContext context) {
          return new Scaffold(
            body: SafeArea(
              child: new Container(
                child: Column(
                  children: [
                    Image.asset(highFive.imageUrl),
                    new RichText(
                      text: new TextSpan(
                        children: [
                          new TextSpan(text: contact, style: TextStyle(fontWeight: FontWeight.bold)),
                          new TextSpan(text: ' отправил вам ' + highFive.nameFrom),
                          if (comment != null && comment.isNotEmpty)
                            new TextSpan(
                                text: ' со словами - ',
                                children: [new TextSpan(text: '\'' + comment + '\'', style: TextStyle(fontWeight: FontWeight.bold))])
                        ],
                        style: new TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
}
