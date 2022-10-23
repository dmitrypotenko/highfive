import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": "We need some permissions for correct operation", "ru": 'Нам нужны некоторые разрешения для работы.'} +
      {'en': 'Request permissions...', 'ru': 'Запрашиваем разрешения...'} +
      {'en': 'Request', 'ru': 'Запросить'};

  String get i18n => localize(this, _t);
}
