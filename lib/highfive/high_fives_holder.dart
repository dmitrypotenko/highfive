import 'package:flutter/material.dart';

import 'high_five_model.dart';
import 'highfive_widget.i18n.dart';

class HighFivesHolder {
  Future<List<HighFiveModel>> _highFives;
  Future<Map<int, HighFiveModel>> _highFivesImageMap;
  HighFiveContentfulRepository _repository;

  HighFivesHolder._privateConstructor() {
    _repository = new HighFiveContentfulRepository();
  }

  Future<List<HighFiveModel>> get highFives {
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

  Future<Map<int, HighFiveModel>> get highFivesImageMap {
    if (_highFivesImageMap == null) {
      _highFivesImageMap =
          highFives.then((highFives) => Map.fromIterable(highFives, key: (highFive) => highFive.id, value: (highFive) => highFive));
    }
    return _highFivesImageMap;
  }

  Future<HighFiveModel> getById(int id, {bool terminate = false}) async {
    var highFiveMap = await highFivesImageMap;
    var highFive = highFiveMap[id];
    if (highFive == null && !terminate) {
      invalidate();
      highFive = await getById(id, terminate: true);
    }
    if (highFive == null) {
      highFive = new HighFiveModel(
          '',
          'https://images.ctfassets.net/4vb93gzyehi7/5L2BAKqRP6Q4ZNpnsfrEb4/63acf404dbdee6d61871b8076a0597f1/clipart2938578.png',
          0,
          'нечто нам неведомое'.i18n,
          Colors.blue.value);
    }
    return highFive;
  }
}
