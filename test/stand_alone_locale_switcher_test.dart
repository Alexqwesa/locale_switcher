import 'package:locale_switcher/src/generated/asset_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main_without_locale_manager.dart';

void main() {
  {
    testWidgets('it change locale without LocaleManager',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      final deLoc = const Locale('de').tr;
      final enLoc = const Locale('en').tr;
      final flags = find.byType(CircleFlag);
      expect(flags, findsNWidgets(5)); // 2 + 3

      // test start with english locale
      expect(find.text(enLoc.counterDescription), findsOneWidget);
      expect(LocaleStore.languageTag.value, "system");

      // Verify that vi locale is loaded
      final viFlag = find.byTooltip(LocaleStore.languageToCountry['vi']![1]);
      expect(viFlag, findsNWidgets(2));
      await tester.tap(viFlag.at(1));
      expect(LocaleManager.locale.value.toLanguageTag(), "vi");
      expect(LocaleStore.languageTag.value, "vi");
      await tester.pumpAndSettle();
      expect(
          find.text(const Locale('vi').tr.counterDescription), findsOneWidget);
      expect(find.text(enLoc.counterDescription), findsNothing);

      // Verify that en locale is loaded

      final enFlag = find.byTooltip(LocaleStore.languageToCountry['en']![1]);
      await tester.tap(enFlag.at(1));
      await tester.pumpAndSettle();
      expect(LocaleManager.locale.value.toLanguageTag(), "en");
      expect(LocaleStore.languageTag.value, "en");
      expect(find.text(enLoc.counterDescription), findsOneWidget);
      expect(find.text(deLoc.counterDescription), findsNothing);

      final sysFlag =
          find.byTooltip(LocaleStore.languageToCountry['system']![1]);
      await tester.tap(enFlag.at(1));
      await tester.pumpAndSettle();
      expect(LocaleManager.locale.value.toLanguageTag(), "en");
      expect(LocaleStore.languageTag.value, "en");

      await tester.tap(sysFlag); // restore ?
    });
  }
}
