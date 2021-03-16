import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/firebase/firebase_functions_bloc.dart';
import 'package:highfive/firebase/firebase_functions_service.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/route/comment.dart';
import 'package:highfive/route/navigation.dart';
import 'package:provider/provider.dart';

import 'highfive_send.dart';

class ContactsListBody extends StatefulWidget {
  List<Contact> _contacts;

  ContactsListBody(this._contacts);

  @override
  State createState() {
    return new ContactsListBodyState(_contacts, []);
  }
}

class ContactsListBodyState extends State<ContactsListBody> {
  List<Contact> _contacts = [];

  List<Contact> _contactsToSend = [];

  PersistentBottomSheetController _controller;

  ContactsListBodyState(this._contacts, this._contactsToSend);

  @override
  Widget build(BuildContext context) {
    print('Building ContactsListBodyState');

    return new ListView(
      children: _contacts
          .map((contact) => new ListTile(
                leading: contact.avatar != null
                    ? Image.memory(contact.avatar)
                    : Icon(
                        Icons.face,
                        color: Colors.green,
                        size: 40,
                      ),
                title: new Text(contact.displayName),
                selected: _contactsToSend.contains(contact),
                selectedTileColor: Colors.blue,
                tileColor: Theme.of(context).cardColor,
                onTap: () => setState(() {
                  if (_contactsToSend.contains(contact)) {
                    _contactsToSend.remove(contact);
                    if (_contactsToSend.length == 0 && _controller != null) {
                      _controller.close();
                    }
                  } else {
                    _contactsToSend.add(contact);
                    if (_contactsToSend.length == 1) {
                      _controller = Scaffold.of(context).showBottomSheet((context) => Container(
                            height: 100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new HighFiveSend(locator.get<FirebaseFunctionsService>(), locator.get<NavigationService>(),
                                      new SendHighFiveEvent(_contactsToSend, "", Provider.of<HighFive>(context, listen: false).id.toString(), "")),
                                  ElevatedButton(
                                    child: const Text('Добавить инфы'),
                                    onPressed: () =>
                                        Navigator.of(context).push(new CommentRoute(_contactsToSend, Provider.of<HighFive>(context, listen: false))),
                                  )
                                ],
                              ),
                            ),
                          ));
                    }
                  }
                  ;
                }),
              ))
          .toList(),
    );
  }
}
