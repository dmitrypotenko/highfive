import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/route/navigation.dart';

class DeleteConsentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var navigationService = locator.get<NavigationService>();
    return new SimpleDialog(
      title: Text("Удалить?"),
      children: [
        SimpleDialogOption(
          onPressed: () {
            navigationService.pop(true);
          },
          child: const Text('Да'),
        ),
        SimpleDialogOption(
          onPressed: () {
            navigationService.pop(false);
          },
          child: const Text('Нет'),
        )
      ],
    );
  }
}
