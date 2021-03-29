import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": 'Something went wrong. I am on my way to fix it!', "ru": 'Что пошло не так! Я уже потею, чтобы решить вашу проблемку'};

  String get i18n => localize(this, _t);
}