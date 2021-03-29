import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations("ru") + {"en": "High five app", "ru": "Пятюня app"} +
      {'ru': 'Вам прислали пятюню!', "en": "You've received a new high five!"};

  String get i18n => localize(this, _t);
}
