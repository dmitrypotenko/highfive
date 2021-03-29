import 'package:flutter/cupertino.dart';
import 'package:highfive/highfive/high_five_model.dart';
import 'package:highfive/highfive/highfive_widget.dart';

class HighFiveRoute extends PageRouteBuilder {
  HighFiveRoute(HighFiveModel highFive, String comment, String contact, String documentId)
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => HighfiveWidget(highFive, comment, contact, documentId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          transitionDuration: new Duration(milliseconds: 500),
        );

  static HighFiveRoute createInstance(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return new HighFiveRoute(arguments['highfiveModel'], arguments['comment'], arguments['contact'], arguments['documentId']);
  }
}
