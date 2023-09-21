import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// Return Icon widget for [langCode].
Widget getIconForLanguage(String langCode, [bool? foreground, double? radius]) {
  if (langCode == showOtherLocales) {
    return const SelectLocaleButton(
      updateIconOnChange: false,
    );
  }
  if (LocaleStore.languageToCountry[langCode] != null) {
    return LangIconWithToolTip(
      langCode: langCode,
      radius: radius,
    );
  } else {
    return CircleFlag(
      langCode,
      size: radius ?? 48,
    );
  }
}
