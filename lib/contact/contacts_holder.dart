import 'package:contacts_service/contacts_service.dart';
import 'package:highfive/error/error.dart';

class ContactsHolder {
  Future<Iterable<Contact>> _contacts;
  Future<Map<String, Contact>> _phoneToContactMap;

  Future<Iterable<Contact>> getContacts() async {
    if (_contacts == null) {
      _contacts = ContactsService.getContacts(withThumbnails: false).then((contacts) {
        if (contacts.length == 0) {
          reportErrorMessage("Local contacts are empty");
        }
        return contacts;
      });
      _phoneToContactMap = _contacts.then((contacts) => contacts
              .map((contact) =>
                  Map.fromIterable(contact.phones, key: (phone) => normalizePhone(phone.value as String), value: (phone) => contact))
              .reduce((value, element) {
            value.addAll(element);
            return value;
          }));
    }

    return _contacts;
  }

  Contact findContact(Iterable<Contact> contacts, String senderPhone) {
    return contacts.firstWhere(
            (contact) => contact.phones
            .map((phone) => normalizePhone(phone.value))
            .contains(senderPhone),
        orElse: () => new Contact(displayName: senderPhone));
  }

  Future<Map<String, Contact>> get phoneToContactMap => _phoneToContactMap;

  ContactsHolder._privateConstructor() {
    getContacts();
  }

  static final ContactsHolder _instance = ContactsHolder._privateConstructor();

  invalidate() {
    _contacts = null;
  }

  factory ContactsHolder() {
    return _instance;
  }
}

List<String> getPhonesFromContacts(Iterable<Contact> contacts) {
  return contacts
      .map((contact) => contact.phones.map((phone) => phone.value).map((phone) => normalizePhone(phone)).toList(growable: true))
      .reduce((value, phones) {
    value.addAll(phones);
    return value;
  });
}

String normalizePhone(String phone) {
  return phone.replaceAll(new RegExp('[-() ]+'), '');
}
