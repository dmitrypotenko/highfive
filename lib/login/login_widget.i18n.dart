import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": "Enter your phone number", "ru": 'Введите мобильник'} +
      {'en': 'Check mobile phone', 'ru': 'Проверить мобилку'} +
      {'en': 'Something went wrong with your sms', 'ru': 'Шота пошло не так с вашей смс'} +
      {'en': 'Sms is lost somewhere... Try again)', 'ru': 'Смска потерялась. Давай еще.'} +
      {'en': 'Sms code', 'ru': 'Смс код'} +
      {'en': 'Check sms', 'ru': 'Проверить смску'};

  String get i18n => localize(this, _t);
}
