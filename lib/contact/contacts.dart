import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:highfive/error/error.dart';
import 'package:highfive/loading/loading_widget.dart';
import 'package:highfive/contact/contacts_holder.dart';
import 'package:highfive/highfive/high_five_model.dart';
import 'package:highfive/contact/contacts_list.dart';
import 'package:provider/provider.dart';
import 'contacts.i18n.dart';

class ContactsRoute extends MaterialPageRoute {
  ContactsRoute(HighFiveModel highFive)
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
      new ContactsHolder().invalidate();
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
              title: new Text('Кому послать?'.i18n),
              actions: [
                new IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => refresh(),
                ),
              ],
            ),
            body: ContactsListBody(snapshot.data),
          );
        } else if (snapshot.hasError) {
          return CustomErrorWidget(snapshot.error as Error);
        } else {
          return LoadingWidget();
        }
      },
    );
  }

  Future<List<String>> _getStoredPhones() async {
    return FirebaseFirestore.instance
        .collection('users')
        //  .where(FieldPath.documentId, whereIn: phones)  не работает why? TODO пофиксать!!!
        .get()
        .then((query) => query.docs)
        .then((documents) {
      return documents.map((doc) => doc.id).toList();
    }).then((storedUsers) {
      if (storedUsers.length == 0) {
        reportErrorMessage("Found no stored users");
      }
      return storedUsers;
    });
  }

  Future<List<Contact>> _refreshContacts() async {
    return new ContactsHolder().getContacts().then((contacts) async {

      var storedPhones = await _getStoredPhones();
      var contactsToSend = contacts
          .where((contact) =>
              contact.phones.map((phone) => normalizePhone(phone.value)).toList(growable: true).any((element) => storedPhones.contains(element)))
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
    super.initState();
  }
}
