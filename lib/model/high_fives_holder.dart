import 'package:flutter/material.dart';

import 'high_five.dart';

class HighFivesHolder {
  Future<List<HighFive>> _highFives;
  Future<Map<int, HighFive>> _highFivesImageMap;
  HighFiveContentfulRepository _repository;

  HighFivesHolder._privateConstructor() {
    _repository = new HighFiveContentfulRepository();
  }

  Future<List<HighFive>> get highFives {
    if (_highFives == null) {
      _highFives = _repository.getHighFives();
    }
    return _highFives;
  }

  void invalidate() {
    _highFives = null;
    _highFivesImageMap = null;
  }

  static final HighFivesHolder _instance = HighFivesHolder._privateConstructor();

  factory HighFivesHolder() {
    return _instance;
  }

  Future<Map<int, HighFive>> get highFivesImageMap {
    if (_highFivesImageMap == null) {
      _highFivesImageMap =
          highFives.then((highFives) => Map.fromIterable(highFives, key: (highFive) => highFive.id, value: (highFive) => highFive));
    }
    return _highFivesImageMap;
  }

  Future<HighFive> getById(int id, {bool terminate = false}) async {
    var highFiveMap = await highFivesImageMap;
    var highFive = highFiveMap[id];
    if (highFive == null && !terminate) {
      invalidate();
      highFive = await getById(id, terminate: true);
    }
    if (highFive == null) {
      highFive = new HighFive(
          '',
          'https://images.ctfassets.net/4vb93gzyehi7/5L2BAKqRP6Q4ZNpnsfrEb4/63acf404dbdee6d61871b8076a0597f1/clipart2938578.png',
          0,
          'нечто нами неведомое',
          Colors.blue.value);
    }
    return highFive;
  }
}
