// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/main_with_dynamic_options.dart';
import '../lib/locale_switcher.dart';
import '../lib/src/generated/asset_strings.dart';
import '../lib/src/locale_store.dart';

void main() {
  group('Parameters tests', () {
    testWidgets('it show letters', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircleFlag), findsNWidgets(7)); // 2 + 3 + 2
      expect(find.text("VI"), findsNothing);
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      await tester.tap(switches.at(0));
      await tester
          .tap(find.byTooltip(LocaleStore.languageToCountry['vi']![1]).at(3));
      await tester.tap(
          find.byTooltip(LocaleStore.languageToCountry['system']![1]).at(3));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(CircleFlag), findsNWidgets(9)); // 1+1+3+2+2

      // await safeTapByKey(tester, 'letterSwitch');
      await safeTapByKey(tester, 'letterSwitch');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(CircleFlag), findsNWidgets(3)); // ???? dialog?
      expect(find.text("VI"), findsNWidgets(4));

      // Verify that vi locale is loaded
      final viFlag = find.byTooltip(LocaleStore.languageToCountry['vi']![1]);
      expect(viFlag, findsNWidgets(5));
      await tester.tap(viFlag.at(1));
      expect(LocaleManager.locale.value.languageCode, "vi");
      expect(LocaleStore.languageCode.value, "vi");
      await tester.pumpAndSettle();
      expect(
          find.text(const Locale('vi').tr.counterDescription), findsOneWidget);
      expect(find.text(const Locale('en').tr.counterDescription), findsNothing);

      // Verify that en locale is loaded
      final enFlag = find.byTooltip(LocaleStore.languageToCountry['en']![1]);

      final sysFlag =
          find.byTooltip(LocaleStore.languageToCountry['system']![1]);
      await tester.tap(enFlag.at(1));
      await tester.pumpAndSettle();
      expect(LocaleManager.locale.value.languageCode, "en");
      expect(LocaleStore.languageCode.value, "en");

      await tester.tap(sysFlag.at(1)); // restore ?
    });
  });
}

Future safeTapByKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
}
