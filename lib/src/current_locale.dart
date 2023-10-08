import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_system_locale.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/preference_repository.dart';

/// An indexes and notifiers to work with [LocaleSwitcher.supportedLocaleNames].
///
/// [current] and [index] - are pointed at current active entry in
/// [LocaleSwitcher.supportedLocaleNames], have setters, correspond notifier - [notifier].
abstract class CurrentLocale extends CurrentSystemLocale {
  static late final ValueNotifier<int> _allNotifiers;
  static final _index = ValueNotifier(0);
  static late final ValueNotifier<Locale> _locale;

  /// Listen on both system locale and currently selected [LocaleName].
  ///
  /// In case [systemLocale] is selected: it didn't try to guess
  /// which [LocaleName] is best match, and just return OS locale.
  /// (Your localization system should select best match).
  static ValueNotifier<Locale> get locale {
    try {
      return _locale;
    } catch (e) {
      _locale = ValueNotifier<Locale>(const Locale('en'));
      _locale.value = current.locale!;
      allNotifiers.addListener(() => _locale.value = current.locale!);
      CurrentSystemLocale.currentSystemLocale
          .addListener(() => _allNotifiers.value++);
      return _locale;
    }
  }

  /// Listen on system locale.
  static ValueNotifier<int> get allNotifiers {
    try {
      return _allNotifiers;
    } catch (e) {
      _allNotifiers = ValueNotifier<int>(0);
      notifier.addListener(() => _allNotifiers.value++);
      CurrentSystemLocale.currentSystemLocale
          .addListener(() => _allNotifiers.value++);
      return _allNotifiers;
    }
  }

  /// ValueNotifier of [index] of selected [LocaleSwitcher.supportedLocaleNames].
  static ValueNotifier<int> get notifier => _index;

  /// Index of selected [LocaleSwitcher.supportedLocaleNames].
  ///
  /// Can be set here.
  static int get index => _index.value;

  static set index(int value) {
    if (value < LocaleStore.supportedLocaleNames.length && value >= 0) {
      if (LocaleStore.supportedLocaleNames[value].name != showOtherLocales) {
        // just double check
        _index.value = value;

        PreferenceRepository.write(LocaleStore.prefName, current.name);
      }
    }
  }

  /// Currently selected entry in [LocaleName].
  ///
  /// You can update this value directly, or
  /// if you are not sure that your locale exist in list of supportedLocales:
  /// use [CurrentLocale.trySetLocale].
  static LocaleName get current => LocaleStore.supportedLocaleNames[index];

  static set current(LocaleName value) {
    var idx = LocaleStore.supportedLocaleNames.indexOf(value);
    if (idx >= 0 && idx < LocaleStore.supportedLocaleNames.length) {
      index = idx;
    } else {
      idx = LocaleStore.supportedLocaleNames
          .indexOf(LocaleMatcher.byName(value.name));
      if (idx >= 0 && idx < LocaleStore.supportedLocaleNames.length) {
        index = idx;
      }
    }
  }
}
