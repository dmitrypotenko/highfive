import 'package:flutter/widgets.dart';
import 'package:highfive/model/high_five_data.dart';

class ChangeNotifierHighFive extends ChangeNotifier {
  List<HighFiveData> _highFives = new List();

  List<HighFiveData> get highFives => _highFives;

  set highFives(List<HighFiveData> value) {
    _highFives = value;
    notifyListeners();
  }

  void add(HighFiveData newHighFive) {
    _highFives.add(newHighFive);
    notifyListeners();
  }

  void remove(HighFiveData highFiveData) {
    _highFives.remove(highFiveData);
    notifyListeners();
  }

  void addSilently(HighFiveData newHighFive) {
    _highFives.add(newHighFive);
  }

  ChangeNotifierHighFive._privateConstructor();

  static final ChangeNotifierHighFive _instance = ChangeNotifierHighFive._privateConstructor();

  factory ChangeNotifierHighFive() {
    return _instance;
  }
}
