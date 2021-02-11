import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:highfive/route/navigation.dart';

GetIt locator = GetIt.instance;

void setupLocator(GlobalKey<NavigatorState> key) {
  locator.registerSingleton(
      new NavigationService(key));
}
