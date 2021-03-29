import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:highfive/error/error.dart';
import 'package:highfive/loading/loading_widget.dart';
import 'package:highfive/highfive/list/highfive_list_widget.dart';
import 'package:highfive/home/home_bloc.dart';
import 'package:highfive/home/home_event.dart';
import 'package:highfive/home/home_state.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/permission/permission_widget.dart';
import 'package:highfive/highfive/highfive_route_builder.dart';
import 'package:highfive/highfive/history/highfive_delete_consent_widget.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart' as Sentry;
import 'home_widget.i18n.dart';

import '../highfive/history/highfive_history_widget.dart';
import '../login/login_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sentry.SentryFlutter.init(
    (options) => options.dsn = 'https://a5ad20b8cd2d4d289ab851898389133e@o497715.ingest.sentry.io/5574163',
    appRunner: () => runZonedApp(),
  );
}

runZonedApp() {
  GlobalKey<NavigatorState> key = GlobalKey();
  setupLocator(key);
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode, report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  runZonedGuarded<Future<void>>(() async {
    runApp(
      new OverlaySupport(
        child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale("ru", ''),
            const Locale("en", '')
          ],
          navigatorKey: key,
          home: I18n(child: new App(), initialLocale: Locale("ru"),),
          theme: ThemeData(
            primaryColor: Colors.white,
          ),
          routes: {"delete-highfive": (context) => DeleteConsentWidget(), "highfive-list": (context) => HighfiveListWidget()},
          title: 'Пятюня app'.i18n,
          onGenerateRoute: (settings) {
            if (settings.name == "highfive") {
              return HighFiveRoute.createInstance(settings);
            }
            return null;
          },
        ),
      ),
    );
  }, (Object error, StackTrace stackTrace) {
    // Whenever an error occurs, call the `_reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    reportError(error, stackTrace);
  });
}

class App extends StatelessWidget {
  HomeBloc _homeBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        _homeBloc = new HomeBloc(locator.get(), locator.get());
        return _homeBloc;
      },
      child: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
        if (state.error != null) {
          return CustomErrorWidget(state.error);
        }
        if (!state.initialized) {
          HomeBloc homeBloc = context.read();
          homeBloc.add(new HomeInitEvent());
          return LoadingWidget();
        }
        if (state.permissionStatus != PermissionStatus.granted) {
          return PermissionWidget();
        }
        if (state.user == null && state.verificationId == null) {
          return SetPhoneNumberWidget();
        } else if (state.user == null && state.verificationId != null) {
          return SetSmsWidget(state.verificationId);
        }
        return BlocListener<HomeBloc, HomeState>(
          listenWhen: (oldState, newState) => oldState.newHighfive != newState.newHighfive,
          listener: (context, state) {
            showSimpleNotification(
              GestureDetector(
                key: new UniqueKey(),
                child: new Container(
                  child: new Text(
                    "Вам прислали пятюню!".i18n,
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  height: 50,
                ),
                onTap: () async {
                  HomeBloc homeBloc = context.read();
                  homeBloc.add(new ShowHighfive(state.newHighfive));
                  return LoadingWidget();
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity < 0) {
                    OverlaySupportEntry.of(context).dismiss();
                  }
                },
              ),
              duration: new Duration(seconds: 5),
              key: new UniqueKey(),
            );
          },
          child: new HighfiveHistoryWidget(),
        );
      },),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _homeBloc != null) {
      _homeBloc.add(AppResumed());
    }
  }
}
