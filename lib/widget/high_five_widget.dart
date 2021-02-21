import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/model/high_five.dart';

class HighFiveWidget extends StatelessWidget {
  final HighFive _highFive;
  final String _comment;
  final String _contact;
  final String _documentId;

  HighFiveWidget(this._highFive, this._comment, this._contact, this._documentId);

  @override
  Widget build(BuildContext context) {
    return buildScreen(_highFive, _comment, _contact, _documentId);
  }

  Widget buildScreen(HighFive highFive, String comment, String contact, String docId) {
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
