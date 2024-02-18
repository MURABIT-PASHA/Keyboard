import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;

class KeyboardLayoutHelper {
  static const Map<String, String> _layoutFiles = {
    'tr': 'assets/layouts/turkish.json',
    'ar': 'assets/layouts/arabic.json',
    'de': 'assets/layouts/german.json',
    'ru': 'assets/layouts/russian.json',
    'kk': 'assets/layouts/kazakh.json',
    'en': 'assets/layouts/english.json',
  };

  Future<Map<String, dynamic>> getKeyboardLayout(Locale locale) async {
    String filePath = _layoutFiles[locale.languageCode] ?? _layoutFiles['en']!;

    String jsonString = await rootBundle.loadString(filePath);

    final Map<String, dynamic> json = jsonDecode(jsonString);

    return json;
  }

}
