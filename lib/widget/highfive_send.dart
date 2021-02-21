import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highfive/firebase/firebase_functions_bloc.dart';
import 'package:highfive/firebase/firebase_functions_repository.dart';
import 'package:highfive/route/navigation.dart';

class HighFiveSend extends StatelessWidget {
  final FirebaseFunctionsRepository _firebaseFunctionsRepository;
  final NavigationService _navigationService;
  final SendHighFiveEvent _event;

  HighFiveSend(this._firebaseFunctionsRepository, this._navigationService, this._event);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FirebaseFunctionBloc>(
      create: (context) => new FirebaseFunctionBloc(_firebaseFunctionsRepository),
      child: BlocListener<FirebaseFunctionBloc, SendHighFiveState>(
        listener: (context, state) {
          if (state.status == SendHighFiveStatus.success) {
            showDialog<void>(
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Пятюня полетела!'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Ясно, понятно'),
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
                    title: Text('Что-то не то. Попробуй еще раз.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Да блин'),
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
                  child: const Text('Отправить пятюню'),
                  onPressed: () async => context.read<FirebaseFunctionBloc>().add(_event),
                )),
      ),
    );
  }
}
