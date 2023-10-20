// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main_with_counter.dart';

void main() {
  group('Material tests loads', () {
    testWidgets('it load locale and change via menu',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({LocaleStore.prefName: "vi"});
      // Build our app and trigger a frame.
      // await LocaleStore.init();
      await SharedPreferences.getInstance();
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final viLoc = const Locale('vi').tr;

      // test start with english locale
      expect(find.text(viLoc.counterDescription), findsOneWidget);
      expect(LocaleSwitcher.current.name, "vi");

      expect(find.text(languageToCountry['de']![1]), findsOneWidget);

      // tap menu
      final dropMenu = find.byType(DropdownMenu<LocaleName>);
      await tester.tap(dropMenu);
      await tester.pumpAndSettle();

      expect(LocaleSwitcher.current.locale?.languageCode, "vi");
      expect(LocaleSwitcher.current.name, "vi");

      // tap item
      final options = find.descendant(
        of: dropMenu,
        matching: find.byType(LangIconWithToolTip),
        // matching: find.text(languageToCountry['de']![1]),
      );
      expect(options, findsNWidgets(6)); // 4 + current + 1??? todo: bugreport
      // await tester.tap(find.text(languageToCountry['de']![1]).at(0));
      // await tester.ensureVisible(deOption.at(4));
      // await tester.pumpAndSettle();
      // await tester.tap(deOption.at(4));
      await tester.tap(find.byKey(const ValueKey("item-de")).at(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // selected todo:
      expect(find.text(languageToCountry['de']![1]), findsNWidgets(2));
      expect(LocaleSwitcher.current.name, "de");
      expect(LocaleSwitcher.current.locale?.languageCode, "de");

      final deLoc = const Locale('de').tr;
      expect(find.text(deLoc.counterDescription), findsOneWidget);

      // ??
      final sysFlag = find.byTooltip(languageToCountry['system']![1]);
      await tester.tap(sysFlag.at(0)); // restore ?
    });
  });
}
