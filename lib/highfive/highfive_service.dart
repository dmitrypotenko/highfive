import 'package:highfive/locator/locator.dart';
import 'package:highfive/contact/contacts_holder.dart';
import 'package:highfive/highfive/high_five_data.dart';
import 'package:highfive/highfive/high_fives_holder.dart';
import 'package:highfive/highfive/highfive_repository.dart';
import 'package:highfive/route/navigation.dart';

class HighfiveService {
  HighFiveRepository _highFiveRepository;

  HighfiveService(this._highFiveRepository);

  Future<void> handleHighFiveData(HighFiveData highFiveData) async {
    if (highFiveData.acknowledged == false) {
      _highFiveRepository.acknowledge(highFiveData.documentId);
      highFiveData.acknowledged = true;
    }
    var contactsHolder = new ContactsHolder();
    String contact = await contactsHolder.getContacts().then((contacts) => contactsHolder.findContact(contacts, highFiveData.sender).displayName);
    var highFive = await new HighFivesHolder().getById(highFiveData.highfiveId);

    locator.get<NavigationService>().pushNamed("highfive",
        arguments: {"documentId": highFiveData.documentId, "contact": contact, "highfiveModel": highFive, "comment": highFiveData.comment});
  }

  Future<List<HighFiveData>> readHighFives() {
    return _highFiveRepository.readHighFives();
  }

  Future<void> deleteHighfive(String documentId) {
    return _highFiveRepository.deleteRow(documentId);
  }

  Future<void> insertReceivedHighFive(HighFiveData highFiveData) {
    return _highFiveRepository.insertReceivedHighFive(highFiveData);
  }
}
