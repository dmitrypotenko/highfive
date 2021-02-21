import 'package:chopper/chopper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:highfive/firebase/firebase_functions_client.dart';
import 'package:highfive/firebase/firebase_functions_repository.dart';
import 'package:highfive/route/navigation.dart';

GetIt locator = GetIt.instance;

void setupLocator(GlobalKey<NavigatorState> key) {
  locator.registerSingleton(new NavigationService(key));
  var chopperClient = new ChopperClient(
      converter: JsonConverter(),
      errorConverter: JsonConverter()
  );

  var client = FirebaseFunctionClient.create(chopperClient);
  locator.registerSingleton(client);
  locator.registerSingleton(new FirebaseFunctionsRepository(client));
}
