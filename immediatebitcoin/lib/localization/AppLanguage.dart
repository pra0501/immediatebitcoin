// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale;
  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('en');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("ar")) {
      _appLocale = Locale("ar");
      await prefs.setString('language_code', 'ar');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("de")) {
      _appLocale = Locale("de");
      await prefs.setString('language_code', 'de');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("es")) {
      _appLocale = Locale("es");
      await prefs.setString('language_code', 'es');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("fi")) {
      _appLocale = Locale("fi");
      await prefs.setString('language_code', 'fi');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("fr")) {
      _appLocale = Locale("fr");
      await prefs.setString('language_code', 'fr');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("it")) {
      _appLocale = Locale("it");
      await prefs.setString('language_code', 'it');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("nl")) {
      _appLocale = Locale("nl");
      await prefs.setString('language_code', 'nl');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("nb")) {
      _appLocale = Locale("nb");
      await prefs.setString('language_code', 'nb');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("it")) {
      _appLocale = Locale("it");
      await prefs.setString('language_code', 'it');
      await prefs.setString('countryCode', 'IT');
    } else if (type == Locale("pt")) {
      _appLocale = Locale("pt");
      await prefs.setString('language_code', 'pt');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("ru")) {
      _appLocale = Locale("ru");
      await prefs.setString('language_code', 'ru');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("sv")) {
      _appLocale = Locale("sv");
      await prefs.setString('language_code', 'sv');
      await prefs.setString('countryCode', '');
    } else {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', '');
    }
    notifyListeners();
  }
}
