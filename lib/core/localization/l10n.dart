import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('es'),
    const Locale('fr'),
  ];

  static final delegates = [
    // AppLocalizations.delegate, // Will be generated
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static String getLanguage(String code) {
    switch (code) {
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'en':
      default:
        return 'English';
    }
  }
}


