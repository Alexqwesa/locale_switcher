import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main_without_locale_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supported = AppLocalizations.supportedLocales
        .where((element) => ['en', 'de', 'vi'].contains(element.languageCode))
        .where((element) => !element.toString().contains('_'));
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
  {
    testWidgets('it change locale without LocaleManager',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      final deLoc = const Locale('de').tr;
      final enLoc = const Locale('en').tr;
      final flags = find.byType(SvgPicture);
      expect(flags, findsNWidgets(6)); // 2 + 3 + 1

      // test start with english locale
      expect(find.text(enLoc.counterDescription), findsOneWidget);
      expect(LocaleSwitcher.current.name, "system");

      // Verify that vi locale is loaded
      final viFlag = find.byTooltip(languageToCountry['vi']![1]);
      expect(viFlag, findsNWidgets(2));
      await tester.tap(viFlag.at(1));
      expect(LocaleSwitcher.current.locale?.languageCode, "vi");
      expect(LocaleSwitcher.current.name, "vi");
      await tester.pumpAndSettle();
      expect(
          find.text(const Locale('vi').tr.counterDescription), findsOneWidget);
      expect(find.text(enLoc.counterDescription), findsNothing);

      // Verify that en locale is loaded

      final enFlag = find.descendant(
        of: find.byType(AnimatedToggleSwitch<LocaleName>),
        matching: find.byTooltip(languageToCountry['en']![1]),
      );
      await tester.tap(enFlag);
      await tester.pumpAndSettle();
      expect(LocaleSwitcher.current.locale?.languageCode, "en");
      expect(LocaleSwitcher.current.name, "en");
      expect(find.text(enLoc.counterDescription), findsOneWidget);
      expect(find.text(deLoc.counterDescription), findsNothing);

      final vi2 = find.descendant(
        of: find.byType(AnimatedToggleSwitch<LocaleName>),
        matching: find.byTooltip(languageToCountry['vi']![1]),
      );
      await tester.tap(vi2);
      await tester.pumpAndSettle();
      expect(LocaleSwitcher.current.locale?.languageCode, "vi");
      expect(LocaleSwitcher.current.name, "vi");
      expect(
          find.text(const Locale('vi').tr.counterDescription), findsOneWidget);
      expect(find.text(enLoc.counterDescription), findsNothing);
      expect(find.text(deLoc.counterDescription), findsNothing);

      final sysFlag = find.byTooltip(languageToCountry['system']![1]);
      await tester.tap(enFlag);
      await tester.pumpAndSettle();
      expect(LocaleSwitcher.current.locale?.languageCode, "en");
      expect(LocaleSwitcher.current.name, "en");

      await tester.tap(sysFlag.at(1)); // restore ?
    });
  }
}
