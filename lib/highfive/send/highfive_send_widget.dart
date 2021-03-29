import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highfive/highfive/send/highfive_send_bloc.dart';
import 'package:highfive/firebase/firebase_functions_service.dart';
import 'package:highfive/route/navigation.dart';
import 'highfive_send_widget.i18n.dart';

class HighFiveSend extends StatelessWidget {
  final FirebaseFunctionsService _firebaseFunctionsService;
  final NavigationService _navigationService;
  final SendHighFiveEvent _event;

  HighFiveSend(this._firebaseFunctionsService, this._navigationService, this._event);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FirebaseFunctionBloc>(
      create: (context) => new FirebaseFunctionBloc(_firebaseFunctionsService),
      child: BlocListener<FirebaseFunctionBloc, SendHighFiveState>(
        listener: (context, state) {
          if (state.status == SendHighFiveStatus.success) {
            showDialog<void>(
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Пятюня полетела!'.i18n),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Ясно, понятно'.i18n),
                        onPressed: () {
                          _navigationService.popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  );
                },
                context: context);
          } else {
            showDialog<void>(
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Что-то не то. Попробуй еще раз.'.i18n),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Да блин'.i18n),
                        onPressed: () {
                          _navigationService.pop();
                        },
                      ),
                    ],
                  );
                },
                context: context);
          }
        },
        child: new Builder(
            builder: (context) => ElevatedButton(
                  child: Text('Отправить пятюню'.i18n),
                  onPressed: () async => context.read<FirebaseFunctionBloc>().add(_event),
                )),
      ),
    );
  }
}
