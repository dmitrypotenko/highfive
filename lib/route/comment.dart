import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/firebase/functions.dart';
import 'package:highfive/model/high_five.dart';

class CommentRoute extends MaterialPageRoute {
  List<Contact> _contactsToSend;

  CommentRoute(this._contactsToSend, HighFive highFive)
      : super(builder: (BuildContext context) {
          final _formKey = GlobalKey<FormState>();
          var controller = new TextEditingController();
          return new Scaffold(
            body: SafeArea(
              child: new Container(
                alignment: Alignment.center,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Комментарий? (Опционально)',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await sendPush(_contactsToSend, context, controller.value.text, highFive.id.toString());
                          },
                          child: Text('Отправить пятюню'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }) {}
}
