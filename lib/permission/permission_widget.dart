import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highfive/home/home_bloc.dart';
import 'package:highfive/home/home_event.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    var homeBloc = context.read<HomeBloc>();
    var state = homeBloc.state;
    if (state.permissionStatus == PermissionStatus.undetermined) {
      homeBloc.add(new RequestPermissions());
      return Material(
        child: Container(
          alignment: AlignmentDirectional.center,
          child: Text("Запрашиваем разрешения..."),
        ),
      );
    }
    if (state.permissionStatus == PermissionStatus.denied) {
      return Material(
        child: Container(
          alignment: AlignmentDirectional.center,
          child: Column(
            children: [
              Text("Нам нужны некоторые разрешения для работы"),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: () => homeBloc.add(new RequestPermissions()), child: Text("Запросить"))
            ],
          ),
        ),
      );
    }
  }
}
