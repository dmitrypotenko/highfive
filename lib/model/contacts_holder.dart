import 'package:contacts_service/contacts_service.dart';

class ContactsHolder {
  Future<Iterable<Contact>> _contacts;
  Future<Map<String, Contact>> _phoneToContactMap;

  Future<Iterable<Contact>> getContacts() async {
    if (_contacts == null) {
      _contacts = ContactsService.getContacts(withThumbnails: false);
      _phoneToContactMap = _contacts.then((value) =>
          value.map((e) => Map.fromIterable(e.phones, key: (element) => element.value as String, value: (element) => e)).reduce((value,
              element) {
            value.addAll(element);
            return value;
          }));
    }

    return _contacts;
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
