// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:locale_switcher/src/generated/asset_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/locale_switch_sub_widgets/grid_of_languages.dart';
import 'package:locale_switcher/src/locale_switch_sub_widgets/select_locale_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main.dart';

void main() {
  group('Material tests', () {
    testWidgets('it change locale via toggle switcher',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // final deLoc = const Locale('de').tr;
      final enLoc = const Locale('en').tr;
      final flags = find.byType(CircleFlag);
      expect(flags, findsNWidgets(5)); // 2 + 3

      // test start with english locale
      expect(find.text(enLoc.counterDescription), findsOneWidget);
      expect(LocaleStore.languageCode.value, "system");

      // Verify that vi locale is loaded
      final viFlag = find.byTooltip(LocaleStore.languageToCountry['vi']![1]);
      expect(viFlag, findsNWidgets(2));
      await tester.tap(viFlag.at(1));
      expect(LocaleManager.locale.value.languageCode, "vi");
      expect(LocaleStore.languageCode.value, "vi");
      await tester.pumpAndSettle();
      // expect(find.text(deLoc.counterDescription), findsOneWidget);
      // expect(find.text(enLoc.counterDescription), findsNothing);

      // Verify that en locale is loaded

      final enFlag = find.byTooltip(LocaleStore.languageToCountry['en']![1]);
      await tester.tap(enFlag.at(1));
      await tester.pumpAndSettle();
      expect(LocaleManager.locale.value.languageCode, "en");
      expect(LocaleStore.languageCode.value, "en");
      // expect(find.text(enLoc.counterDescription), findsOneWidget);
      // expect(find.text(deLoc.counterDescription), findsNothing);

      final sysFlag =
          find.byTooltip(LocaleStore.languageToCountry['system']![1]);
      await tester.tap(enFlag.at(1));
      await tester.pumpAndSettle();
      expect(LocaleManager.locale.value.languageCode, "en");
      expect(LocaleStore.languageCode.value, "en");

      await tester.tap(sysFlag); // restore ?
    });

    testWidgets('it change locale via popUp dialog',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(
          {LocaleStore.innerSharedPreferenceName: "system"});
      // Build our app and trigger a frame.
      await SharedPreferences.getInstance();
      // verify(SharedPreferences.getInstance()).called(1);
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // final deLoc = const Locale('de').tr;
      final enLoc = const Locale('en').tr;

      // test start with english locale
      expect(LocaleStore.languageCode.value, "system");
      expect(find.text(enLoc.counterDescription), findsOneWidget);

      // Verify that vi locale is loaded
      final selectLocaleButton = find.byType(SelectLocaleButton);
      expect(selectLocaleButton, findsNWidgets(2));
      await tester.tap(selectLocaleButton.at(0));
      await tester.pumpAndSettle();

      final grid = find.byType(GridOfLanguages);
      expect(grid, findsOneWidget);

      // tap item
      final deOption = find.descendant(
        of: grid,
        matching: find.text(LocaleStore.languageToCountry['de']![1]),
      );
      expect(deOption, findsOneWidget);
      await tester.tap(deOption);
      await tester.pumpAndSettle();

      // Verify that en locale is loaded
      expect(LocaleManager.locale.value.languageCode, "de");
      expect(LocaleStore.languageCode.value, "de");

      expect(
          find.text(const Locale('de').tr.counterDescription), findsOneWidget);
      expect(find.text(enLoc.counterDescription), findsNothing);

      // final sysFlag = find.byTooltip(LocaleStore.languageToCountry['system']![1]);
      // await tester.tap(sysFlag); // restore ?
    });
  });
}
