import 'package:flutter/widgets.dart';
import 'package:highfive/model/high_five_data.dart';

class ChangeNotifierHighFive extends ChangeNotifier {
  List<HighFiveData> _newHighFives;

  List<HighFiveData> get newHighFives => _newHighFives;

  set newHighFives(List<HighFiveData> value) {
    _newHighFives = value;
  }

  void add(HighFiveData newHighFive) {
    _newHighFives.add(newHighFive);
    notifyListeners();
  }

  void addSilently(HighFiveData newHighFive) {
    _newHighFives.add(newHighFive);
  }
}
