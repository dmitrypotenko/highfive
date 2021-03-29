import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": 'High five has flown away!', "ru": 'Пятюня полетела!'} +
      {"en": 'Got it!', "ru": 'Ясно, понятно'} +
      {'en': 'Something went wrong. Try again.', 'ru': 'Что-то не то. Попробуй еще раз.'} +
      {'en': 'Send high five', 'ru': 'Отправить пятюню'} +
      {'en': 'Oh sh*t', 'ru': 'Да блин'};

  String get i18n => localize(this, _t);
}
