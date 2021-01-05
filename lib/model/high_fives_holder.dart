import 'package:flutter/material.dart';

import 'high_five.dart';

class HighFivesHolder {
  Future<List<HighFive>> highFives;
  Future<Map<int, HighFive>> highFivesImageMap;
  HighFiveContentfulRepository _repository;

  HighFivesHolder._privateConstructor() {
    _repository = new HighFiveContentfulRepository();
    highFives = _repository.getHighFives();

    highFivesImageMap = highFives.then((highFives) => Map.fromIterable(highFives,
        key: (highFive) => highFive.id, value: (highFive) => highFive));
  }

  static final HighFivesHolder _instance = HighFivesHolder._privateConstructor();

  factory HighFivesHolder() {
    return _instance;
  }
}
