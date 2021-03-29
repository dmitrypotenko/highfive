import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:highfive/highfive/high_five_data.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeState extends Equatable {
  bool initialized;
  User user;
  String verificationId;
  Object error;
  PermissionStatus permissionStatus;
  List<HighFiveData> highfives;
  HighFiveData newHighfive;

  HomeState({@required this.initialized, this.user, this.verificationId, this.error,@required  this.permissionStatus, this.highfives, this.newHighfive});

  @override
  List<Object> get props => [initialized, user, verificationId, error, permissionStatus, highfives, newHighfive];

  HomeState copyWith(
      {bool initialized,
      User user,
      String verificationId,
      Object error,
      PermissionStatus permissionStatus,
      List<HighFiveData> highfives,
      HighFiveData newHighfive}) {
    return new HomeState(
        initialized: initialized ?? this.initialized,
        user: user ?? this.user,
        verificationId: verificationId ?? this.verificationId,
        error: error,
        permissionStatus: permissionStatus ?? this.permissionStatus,
        highfives: highfives ?? this.highfives,
        newHighfive: newHighfive);
  }
}
