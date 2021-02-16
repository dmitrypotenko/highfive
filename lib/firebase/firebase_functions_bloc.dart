import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart';

import 'firebase_functions_repository.dart';

class FirebaseFunctionBloc extends Bloc<SendHighFiveEvent, SendHighFiveState> {
  final FirebaseFunctionsRepository _firebaseFunctionsRepository;

  FirebaseFunctionBloc(this._firebaseFunctionsRepository) : super(SendHighFiveState(SendHighFiveStatus.unknown));

  @override
  Stream<SendHighFiveState> mapEventToState(SendHighFiveEvent event) async* {
    SendHighFiveStatus status = await _firebaseFunctionsRepository.sendPush(event.contactsToSend, event.comment, event.highfiveId, event.from);

    yield new SendHighFiveState(status);
  }
}

class SendHighFiveState {
  SendHighFiveStatus status;

  SendHighFiveState(this.status);
}

class SendHighFiveEvent {
  List<Contact> contactsToSend;
  String comment;
  String highfiveId;
  String from;

  SendHighFiveEvent(this.contactsToSend, this.comment, this.highfiveId, this.from);
}
