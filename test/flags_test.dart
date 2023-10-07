import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';

import '../example/lib/main_with_counter.dart';

void main() {
  testWidgets('it detect flags correctly', (WidgetTester tester) async {
    final names = ['en', 'vi', 'de'];
    final namesSystem = ['system', 'en', 'vi', 'de'];
    await tester.pumpWidget(LocaleManager(
      supportedLocales: names.map((e) => Locale(e)).toList(),
      child: const MyApp(),
    ));
    expect(LocaleSwitcher.localeNameFlags.names, namesSystem);
    expect(LocaleSwitcher.localeNameFlags[1].flag?.key,
        Flags.instance['us']?.svg.key);
    expect(LocaleSwitcher.localeNameFlags[2].flag?.key,
        Flags.instance['vn']?.svg.key);
    expect(LocaleSwitcher.localeNameFlags[3].flag?.key,
        Flags.instance['de']?.svg.key);
    // for (final locName in LocaleSwitcher.localeNameFlags.skip(1)) {
    //   expect(locName.flag?.key, Flags.instance[locName.name]?.svg.key);
    // }
  });
}
