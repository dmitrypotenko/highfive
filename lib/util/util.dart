import 'dart:math';

import 'package:flutter/material.dart';

const _myListOfRandomColors = [
  Colors.teal,
  Colors.pink,
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.amber,
  Colors.deepOrange,
  Colors.green,
  Colors.indigo,
  Colors.lime,
  Colors.orange,
];
final _random = Random();

MaterialColor getColor(int index) {
  return _myListOfRandomColors[index];
}

List<MaterialColor> getRandomColors(int amount) {
  return List<MaterialColor>.generate(amount, (index) {
    return _myListOfRandomColors[_random.nextInt(_myListOfRandomColors.length)];
  });
}
