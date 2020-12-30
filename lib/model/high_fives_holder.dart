import 'package:flutter/material.dart';

import 'high_five.dart';

class HighFivesHolder {
  Future<List<HighFive>> highFives;
  Future<Map<int, Image>> highFivesImageMap;

  HighFivesHolder._privateConstructor() {
    highFives = new Future<List<HighFive>>(() => [
          new HighFive("Стандартная пятюня", "assets/highfive.png", 1, "стандартную пятюню"),
          new HighFive("Подлая пятюня по попе", "assets/slap-ass.png", 2, "подлую пятюню по попе")
        ]);

    highFivesImageMap = highFives.then((highFives) => Map.fromIterable(highFives,
        key: (highFive) => highFive.id, value: (highFive) => Image.asset(highFive.imageUrl, width: 30, height: 30)));
  }

  static final HighFivesHolder _instance = HighFivesHolder._privateConstructor();

  factory HighFivesHolder() {
    return _instance;
  }
}
