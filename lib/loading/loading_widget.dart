import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'loading_widget.i18n.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new Column(
          children: [
            new Image.asset("assets/highfive.gif"),
            new Text(
              "Подгрузочка...".i18n,
              style: new TextStyle(fontSize: 26),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
