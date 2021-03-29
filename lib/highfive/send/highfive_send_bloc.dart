import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart';

import '../../firebase/firebase_functions_service.dart';

class FirebaseFunctionBloc extends Bloc<SendHighFiveEvent, SendHighFiveState> {
  final FirebaseFunctionsService _firebaseFunctionsService;

  FirebaseFunctionBloc(this._firebaseFunctionsService) : super(SendHighFiveState(SendHighFiveStatus.unknown));

  @override
  Stream<SendHighFiveState> mapEventToState(SendHighFiveEvent event) async* {
    SendHighFiveStatus status = await _firebaseFunctionsService.sendPush(event.contactsToSend, event.comment, event.highfiveId, event.from);

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
