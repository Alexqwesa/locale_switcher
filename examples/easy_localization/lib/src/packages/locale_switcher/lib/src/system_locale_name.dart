import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_system_locale.dart';

/// A special [LocaleName] for [systemLocale].
// todo: singleton?
class SystemLocaleName extends LocaleName {
  @override
  Locale get locale => CurrentSystemLocale.currentSystemLocale.value;

  ValueNotifier<Locale> get notifier => CurrentSystemLocale.currentSystemLocale;

  SystemLocaleName({
    super.flag,
    // super.language,
  }) : super(name: systemLocale);
}
