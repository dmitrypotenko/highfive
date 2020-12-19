import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:highfive/firebase/loading.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/widget/contacts_list.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ContactsRoute extends MaterialPageRoute {
  ContactsRoute(HighFive highFive)
      : super(builder: (BuildContext context) {
          return Provider(create: (context) => highFive, child: ContactsWidget());
        }) {}
}

class ContactsWidget extends StatefulWidget {
  @override
  State createState() => new ContactsWidgetState();
}

class ContactsWidgetState extends State<ContactsWidget> {
  Future<List<Contact>> refreshContactsFuture;

  void refresh() {
    setState(() {
      contacts = null;
      refreshContactsFuture = _refreshContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building ContactsWidgetState');
    return new FutureBuilder(
      future: refreshContactsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Кому пятюня?'),
              actions: [
                new IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => refresh(),
                ),
              ],
            ),
            body: ContactsListBody(snapshot.data),
          );
        } else {
          return LoadingWidget();
        }
      },
    );
  }

  Future<List<String>> _getStoredPhones(List<String> phones) async {
    return FirebaseFirestore.instance
        .collection('users')
        //  .where(FieldPath.documentId, whereIn: phones)  не работает why?
        .get()
        .then((query) => query.docs)
        .then((documents) {
      return documents.map((doc) => doc.id).toList();
    });
  }

  Future<List<Contact>> _refreshContacts() async {
    return getContacts().then((contacts) async {
      var localPhones =
          contacts.map((contact) => contact.phones.map((phone) => phone.value).toList(growable: true)).reduce((value, element) {
        value.addAll(element);
        return value;
      });

      var storedPhones = await _getStoredPhones(localPhones);
      var contactsToSend = contacts
          .where((contact) =>
              contact.phones.map((phone) => phone.value).toList(growable: true).any((element) => storedPhones.contains(element)))
          .toList();

      if (contactsToSend == null) {
        return [];
      }
      await Future.wait(contactsToSend.map((contact) async {
        contact.avatar = await ContactsService.getAvatar(contact);
      }));
      return contactsToSend.toList();
    });
  }

  @override
  void initState() {
    refreshContactsFuture = _refreshContacts();
  }
}
