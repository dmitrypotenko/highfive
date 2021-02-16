import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:highfive/error/error.dart';
import 'package:highfive/firebase/firebase_functions_client.dart';

class FirebaseFunctionsRepository {
  FirebaseFunctionClient _firebaseFunctionClient;

  FirebaseFunctionsRepository(this._firebaseFunctionClient);

  Future<SendHighFiveStatus> sendPush(List<Contact> contactsToSend, String comment, String highfiveId, String from) async {
    var contactsToSendPhones = contactsToSend
        .map((contact) => contact.phones.map((phone) => phone.value).toList(growable: true))
        .reduce((value, contact) {
          value.addAll(contact);
          return value;
        })
        .toSet()
        .toList();

    var sendHighFiveRequest =
        new SendHighFiveRequest(contactsToSendPhones, from.isNotEmpty ? from : FirebaseAuth.instance.currentUser.phoneNumber, comment, highfiveId);

    try {
      await _firebaseFunctionClient.sendPush(sendHighFiveRequest);
      return SendHighFiveStatus.success;
    } catch (response) {
      reportErrorMessage("Fail to send highfive. " + response);
      return SendHighFiveStatus.fail;
    }
  }
}

enum SendHighFiveStatus { success, fail, unknown }
