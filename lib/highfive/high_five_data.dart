import 'package:flutter/cupertino.dart';

class HighFiveData {
  String sender;
  int highfiveId;
  String comment;
  int timestamp;
  String documentId;
  bool _acknowledged;

  HighFiveData(this.sender, this.highfiveId, this.comment, this.timestamp, this.documentId);

  ValueNotifier<bool> acknowledgedNotifier;

  set acknowledged(bool newVal) {
    _acknowledged = newVal;
    if (acknowledgedNotifier!=null) {
      acknowledgedNotifier.value = newVal;
    }
  }

  get acknowledged {
    return _acknowledged;
  }
}
