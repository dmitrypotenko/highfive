import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:highfive/firebase/firebase_message_service.dart';
import 'package:highfive/highfive/highfive_service.dart';
import 'package:highfive/home/home_event.dart';
import 'package:highfive/home/home_state.dart';
import 'package:highfive/permission/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> with WidgetsBindingObserver {
  PermissionService _permissionService;
  HighfiveService _highfiveService;
  FirebaseMessageService _firebaseMessageService;

  HomeBloc(this._permissionService, this._highfiveService)
      : super(new HomeState(initialized: false, permissionStatus: PermissionStatus.denied));

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    switch (event.runtimeType) {
      case HomeInitEvent:
        await Firebase.initializeApp();
        FirebaseAuth.instance.authStateChanges().listen((User user) {
          print('User state changed AppWidget');
          if (user != null) {
            _firebaseMessageService.refreshToken();
          }
          add(UserChanged(user));
        });
        _firebaseMessageService = new FirebaseMessageService(_highfiveService);
        _firebaseMessageService.newHighfive.listen((event) => add(ShowNewHighfiveOverlay(event)));
        var highfives = await _highfiveService.readHighFives();
        yield state.copyWith(initialized: true, highfives: highfives);
        break;
      case RequestPermissions:
        PermissionStatus permissionStatus = await _permissionService.askForPermission();
        yield state.copyWith(permissionStatus: permissionStatus);
        break;
      case SmsSentEvent:
        var smsSentEvent = event as SmsSentEvent;
        yield state.copyWith(verificationId: smsSentEvent.verificationId);
        break;
      case SmsHasNotReceived:
        yield state.copyWith(verificationId: null);
        break;
      case UserChanged:
        var userChangedEvent = event as UserChanged;
        yield state.copyWith(user: userChangedEvent.user);
        break;
      case ShowHighfive:
        var showHighfive = event as ShowHighfive;
        _highfiveService.handleHighFiveData(showHighfive.highFiveData);
        yield state.copyWith();
        break;
      case ShowNewHighfiveOverlay:
        var showNewHighfiveOverlay = event as ShowNewHighfiveOverlay;
        yield state.copyWith(highfives: state.highfives..add(showNewHighfiveOverlay.highFiveData), newHighfive: showNewHighfiveOverlay.highFiveData);
        break;
      case AppResumed:
        var highfives = await _highfiveService.readHighFives();
        yield state.copyWith(highfives: highfives);
        break;
      case DeleteHighfive:
        var deleteHighfiveEvent = event as DeleteHighfive;
        await _highfiveService.deleteHighfive(deleteHighfiveEvent.highFiveData.documentId);
        yield state.copyWith(highfives: state.highfives..remove(deleteHighfiveEvent.highFiveData));
        break;
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    add(new HomeErrorEvent(new HomeError(error, stackTrace)));
  }
}
