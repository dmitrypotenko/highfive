import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/firebase/firebase_functions_bloc.dart';
import 'package:highfive/firebase/firebase_functions_service.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/route/navigation.dart';
import 'package:highfive/widget/highfive_send.dart';

class CommentRoute extends MaterialPageRoute {
  CommentRoute(_contactsToSend, HighFive highFive)
      : super(builder: (BuildContext context) {
          final _formKey = GlobalKey<FormState>();
          var commentController = new TextEditingController();
          var senderNameController = new TextEditingController();
          return new Scaffold(
            body: SafeArea(
              child: new Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                decoration: new BoxDecoration(boxShadow: [new BoxShadow(color: Colors.grey)], color: Colors.white),
                alignment: Alignment.center,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        style: new TextStyle(color: Colors.blueAccent),
                        controller: senderNameController,
                        maxLength: 20,
                        decoration: new InputDecoration(
                            hintText: 'От кого? (твоя мобила по дефолту)',
                            border: new OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: new BorderSide())),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        maxLength: 30,
                        style: new TextStyle(color: Colors.greenAccent),
                        controller: commentController,
                        decoration: new InputDecoration(
                          hintText: 'Комментарий? (Опционально)',
                          border: new OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: new BorderSide()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: new HighFiveSend(locator.get<FirebaseFunctionsService>(),
                            locator.get<NavigationService>(),
                            new SendHighFiveEvent(_contactsToSend,
                                commentController.value.text,
                                highFive.id.toString(), senderNameController.value.text)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
}
/*sendPush(_contactsToSend, context, commentController.value.text, highFive.id.toString(),
                                senderNameController.value.text);*/