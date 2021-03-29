import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": 'What to send?', "ru": 'Что послать?'};

  String get i18n => localize(this, _t);
}