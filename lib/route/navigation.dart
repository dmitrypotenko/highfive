import 'package:flutter/cupertino.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigationKey;

  NavigationService(this.navigationKey);

  Future<T> pushNamed<T>(String route, {Object arguments}) {
    return navigationKey.currentState.pushNamed(route, arguments: arguments);
  }

  void pop([Object arguments]) {
    navigationKey.currentState.pop(arguments);
  }
}