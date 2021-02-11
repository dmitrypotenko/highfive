import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomErrorWidget extends StatelessWidget {

  CustomErrorWidget(Error error) {
    reportError(error, error.stackTrace);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: new Text("Что пошло не так! Я уже потею, что решить вашу проблемку"),
      ),
    );
  }
}

bool get isInDebugMode {
  // Assume you're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

Future<void> reportError(dynamic error, dynamic stackTrace) async {
  // Print the exception to the console.
  print('Caught error: $error');
  if (isInDebugMode) {
    // Print the full stacktrace in debug mode.
    print(stackTrace);
  } else {
    // Send the Exception and Stacktrace to Sentry in Production mode.
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  }
}

Future<void> reportErrorMessage(String message) async {
  if (isInDebugMode) {
    // Print the full stacktrace in debug mode.
    print(message);
  } else {
    // Send the Exception and Stacktrace to Sentry in Production mode.
    Sentry.captureMessage(message);
  }
}
