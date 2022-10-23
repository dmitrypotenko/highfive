import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": 'You don\'t have received high fives', "ru": 'У вас нет полученных пятюнь'} +
      {'ru': 'Хочу послать пятюню', "en": "Send high five"} +
      {'ru': 'Удалить?', "en": "Delete"}+
      {'ru': 'Да', "en": "Yes"}+
      {'ru': 'Нет', "en": "No"};

  String get i18n => localize(this, _t);
}
