import 'package:chopper/chopper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:highfive/firebase/firebase_functions_client.dart';
import 'package:highfive/firebase/firebase_functions_service.dart';
import 'package:highfive/highfive/highfive_service.dart';
import 'package:highfive/permission/permission_service.dart';
import 'package:highfive/highfive/highfive_repository.dart';
import 'package:highfive/route/navigation.dart';

GetIt locator = GetIt.instance;

void setupLocator(GlobalKey<NavigatorState> key) {
  locator.registerSingleton(new NavigationService(key));
  var chopperClient = new ChopperClient(converter: JsonConverter(), errorConverter: JsonConverter());

  var client = FirebaseFunctionClient.create(chopperClient);
  locator.registerSingleton(client);
  locator.registerSingleton(new FirebaseFunctionsService(client));
  locator.registerSingleton(new PermissionService());
  locator.registerSingleton(new HighFiveRepository());
  locator.registerSingleton(new HighfiveService(locator.get()));
}
