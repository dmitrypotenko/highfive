import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/route/navigation.dart';

import 'highfive_history_widget.i18n.dart';

class DeleteConsentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var navigationService = locator.get<NavigationService>();
    return new SimpleDialog(
      title: Text("Удалить?".i18n),
      children: [
        SimpleDialogOption(
          onPressed: () {
            navigationService.pop(true);
          },
          child: Text('Да'.i18n),
        ),
        SimpleDialogOption(
          onPressed: () {
            navigationService.pop(false);
          },
          child: Text('Нет'.i18n),
        )
      ],
    );
  }
}
