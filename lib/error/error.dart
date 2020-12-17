import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: new Text("Что пошло не так! Чекните подключение к интернету."),
      ),
    );
  }
}
