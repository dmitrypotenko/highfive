import 'package:firebase_auth/firebase_auth.dart';
import 'package:highfive/highfive/high_five_data.dart';

class HomeEvent {}

class HomeInitEvent extends HomeEvent {}

class HomeErrorEvent extends HomeEvent {
  HomeError _error;

  HomeErrorEvent(this._error);
}

class SmsSentEvent extends HomeEvent {
  String verificationId;

  SmsSentEvent(this.verificationId);
}

class SmsHasNotReceived extends HomeEvent {
}

class ShowHighfive extends HomeEvent {
  HighFiveData highFiveData;

  ShowHighfive(this.highFiveData);
}

class ShowNewHighfiveOverlay extends HomeEvent {
  HighFiveData highFiveData;

  ShowNewHighfiveOverlay(this.highFiveData);
}

class DeleteHighfive extends HomeEvent {
  HighFiveData highFiveData;

  DeleteHighfive(this.highFiveData);
}

class AppResumed extends HomeEvent {

}

class UserChanged extends HomeEvent {
  User user;

  UserChanged(this.user);
}

class HomeError extends Error {
  Object _cause;
  StackTrace _stackTrace;

  HomeError(this._cause, this._stackTrace);
}

class RequestPermissions extends HomeEvent {}
