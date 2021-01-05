import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/model/high_five.dart';

class HighFiveWidget extends StatelessWidget {
  HighFive highFive;
  String comment;
  String contact;
  String docId;

  HighFiveWidget(this.highFive, this.comment, this.contact, this.docId);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SafeArea(
        child: new Container(
          child: Column(
            children: [
              new Hero(child: highFive.getNetworkCachedImage(), tag: docId + 'highfivepic'),
              new Container(
                child: new RichText(
                  text: new TextSpan(
                    children: [
                      new TextSpan(text: contact, style: TextStyle(fontWeight: FontWeight.bold)),
                      new TextSpan(text: ' отправил вам ' + highFive.nameFrom),
                      if (comment != null && comment.isNotEmpty)
                        new TextSpan(
                            text: ' со словами - ',
                            children: [new TextSpan(text: '\'' + comment + '\'', style: TextStyle(fontWeight: FontWeight.bold))])
                    ],
                    style: new TextStyle(color: Colors.black, fontSize: 20),
                  ),

                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
