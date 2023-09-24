import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// Return Icon widget for [langCode].
Widget getIconForLanguage(String langCode,
    [bool? foreground,
    double? radius,
    int useNLettersInsteadOfIcon = 0,
    TextStyle? textStyle]) {
  if (langCode == showOtherLocales) {
    return LocaleSwitcher.iconButton(
      useStaticIcon:
          ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
              ? LocaleStore.languageToCountry[showOtherLocales]![2]
              : const Icon(Icons.expand_more),
    );
  }
  if (langCode == LocaleStore.systemLocale) {
    useNLettersInsteadOfIcon = 0; // don't show letter code for system locale
  }
  if (LocaleStore.languageToCountry[langCode] != null) {
    return LangIconWithToolTip(
      langCode: langCode,
      radius: radius,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
      textStyle: textStyle,
    );
  } else {
    return (useNLettersInsteadOfIcon > 0)
        ? ClipOval(
            child: SizedBox(
                width: radius ?? 48,
                height: radius ?? 48,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: FittedBox(
                      child: Text(
                    langCode.toUpperCase(),
                    style: textStyle,
                  )),
                )),
          )
        : CircleFlag(
            langCode,
            size: radius ?? 48,
          );
  }
}
