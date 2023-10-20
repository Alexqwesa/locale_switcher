// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main_with_dynamic_options.dart';

void main() {
  group('Parameters tests', () {
    testWidgets('it show letters', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      expect(find.byType(SvgPicture), findsNWidgets(7)); // 2 + 3 + 2
      expect(find.text("VI"), findsNothing);
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      await tester.tap(switches.at(0));
      await tester.tap(find.byTooltip(languageToCountry['vi']![1]).at(3));
      await tester.tap(find.byTooltip(languageToCountry['system']![1]).at(3));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SvgPicture), findsNWidgets(6)); // 1+1+2+2

      // await safeTapByKey(tester, 'letterSwitch');
      await safeTapByKey(tester, 'letterSwitch');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.text("VI"), findsNWidgets(4));

      // Verify that vi locale is loaded
      final viFlag = find.byTooltip(languageToCountry['vi']![1]);
      expect(viFlag, findsNWidgets(4));
      await tester.tap(viFlag.at(1));
      expect(LocaleSwitcher.current.locale?.languageCode, "vi");
      expect(LocaleSwitcher.current.name, "vi");
      await tester.pumpAndSettle();
      expect(
          find.text(const Locale('vi').tr.counterDescription), findsOneWidget);
      expect(find.text(const Locale('en').tr.counterDescription), findsNothing);

      // Verify that en locale is loaded
      final enFlag = find.byTooltip(languageToCountry['en']![1]);

      final sysFlag = find.byTooltip(languageToCountry['system']![1]);
      await tester.tap(enFlag.at(1));

      await tester.pumpAndSettle();
      expect(LocaleSwitcher.current.locale?.languageCode, "en");
      expect(LocaleSwitcher.current.name, "en");

      await tester.tap(sysFlag.at(1)); // restore ?
      await tester.pumpAndSettle();
      // expect(viFlag, findsNWidgets(2)); // why 3
    });
  });
}

Future safeTapByKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
}
