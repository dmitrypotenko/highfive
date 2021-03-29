import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": 'Who to send to?', "ru": 'Кому послать?'} +
      {'en': 'Add information', 'ru': 'Добавить инфы'};

  String get i18n => localize(this, _t);
}