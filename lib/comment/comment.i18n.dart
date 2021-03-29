import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") +
      {"en": 'From who? (your mobile by default)', "ru": 'От кого? (твоя мобила по дефолту)'} +
      {'ru': 'Comments? (Optional)', "en": "Комментарий? (Опционально)"};

  String get i18n => localize(this, _t);
}
