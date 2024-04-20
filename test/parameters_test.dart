// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main_with_dynamic_options.dart';

class MyAppCupertinoTest extends StatelessWidget {
  const MyAppCupertinoTest({super.key});

  @override
  Widget build(BuildContext context) {
    final supported = AppLocalizations.supportedLocales
        .where((element) => ['en', 'de', 'vi'].contains(element.languageCode));
    // ============= THIS 5 LINES REQUIRED =============
    return LocaleManager(
      child: MaterialApp(
        locale: LocaleSwitcher.localeBestMatch,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supported,
        // ...
        title: LocaleSwitcher.current.locale!.tr.example,
        home: MyHomePage(title: LocaleSwitcher.current.locale!.tr.example),
      ),
    );
  }
}

void main() {
  group('Parameters tests', () {
    testWidgets('it show letters', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      expect(find.byType(SvgPicture), findsNWidgets(7)); // 2 + 3 + 2
      expect(find.text("VI"), findsNothing);
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(4));

      final listFinder = find.byType(Scrollable).at(1);
      final itemFinder = find.byType(CounterWidget);
      // Scroll until the item to be found appears.
      await tester.scrollUntilVisible(
        itemFinder,
        500.0,
        scrollable: listFinder,
      );

      await tester.tap(find.byTooltip(languageToCountry['vi']![1]).at(3),
          warnIfMissed: false);
      await tester.tap(find.byTooltip(languageToCountry['system']![1]).at(3),
          warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsNWidgets(7));

      await tester.ensureVisible(find.byType(Switch).at(0));
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture), findsNWidgets(7));

      await tester.ensureVisible(find.byType(Switch).at(1));
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture),
          findsNWidgets(3)); // DropDownMenu still have?

      // await tester.ensureVisible(find.byType(Switch).at(0));
      // await tester.tap(switches.at(0));
      // await tester.pumpAndSettle();
      // expect(find.byType(SvgPicture), findsNWidgets(6));

      // await safeTapByKey(tester, 'letterSwitch');
      // await safeTapByKey(tester, 'letterSwitch');
      // await tester.pumpAndSettle();
      // await tester.pump(const Duration(seconds: 3));
      // expect(find.byType(SvgPicture), findsNothing);
      // expect(find.text("VI"), findsNWidgets(4));

      // Verify that vi locale is loaded
      final viFlag = find.byTooltip(languageToCountry['vi']![1]);
      // Scroll until the item to be found appears.
      await tester.scrollUntilVisible(
        viFlag.at(1),
        -500.0,
        scrollable: listFinder,
      );
      expect(viFlag, findsNWidgets(4));
      await tester.tap(viFlag.at(1));
      expect(LocaleSwitcher.current.locale?.languageCode, "vi");
      expect(LocaleSwitcher.current.name, "vi");
      await tester.pumpAndSettle();
      expect(
          find.text(const Locale('vi').tr.counterDescription), findsOneWidget);
      expect(find.text(const Locale('en').tr.counterDescription), findsNothing);

      // Verify that en locale is loaded
      final sysFlag =
          find.byTooltip(languageToCountry['system']![1], skipOffstage: false);
      await tester.safeTap(sysFlag.at(1));
      // final enFlag =
      //     find.byTooltip(languageToCountry['en']![1], skipOffstage: false);
      //
      // await tester.safeTap(enFlag.at(1));

      // await tester.pumpAndSettle();
      expect(LocaleSwitcher.current.locale?.languageCode, "en");
      expect(LocaleSwitcher.current.name, "system");

      // await tester.tap(sysFlag.at(1)); // restore ?
      // await tester.pumpAndSettle();
      // expect(viFlag, findsNWidgets(2)); // why 3
    });
  });
}

Future safeTapByKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key), skipOffstage: false));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
}

extension Safe on WidgetTester {
  Future safeTap(Finder finder) async {
    await scrollUntilVisible(
      finder,
      -500.0,
      scrollable: find.byType(Scrollable).at(0),
    );
    await ensureVisible(finder);
    await pumpAndSettle();
    await tap(finder);
    await pumpAndSettle();
  }
}
