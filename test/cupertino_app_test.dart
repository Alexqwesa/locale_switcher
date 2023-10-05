// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/locale_switch_sub_widgets/grid_of_languages.dart';
import 'package:locale_switcher/src/locale_switch_sub_widgets/select_locale_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main_with_counter.dart';

class MyAppCupertinoTest extends StatelessWidget {
  const MyAppCupertinoTest({super.key});

  @override
  Widget build(BuildContext context) {
    // ============= THIS 5 LINES REQUIRED =============
    return LocaleManager(
      child: CupertinoApp(
        locale: CurrentLocale.current.locale!,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // ...
        title: CurrentLocale.current.locale!.tr.example,
        home: MyHomePage(title: CurrentLocale.current.locale!.tr.example),
      ),
    );
  }
}

void main() {
  group('Cupertino tests', () {
    testWidgets('it change locale via toggle switcher',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyAppCupertinoTest());

      // final deLoc = const Locale('de').tr;
      final enLoc = const Locale('en').tr;
      final flags = find.byType(SvgPicture);
      expect(flags, findsNWidgets(5)); // 2 + 3

      // test start with english locale
      expect(find.text(enLoc.counterDescription), findsOneWidget);
      expect(CurrentLocale.current.name, "system");

      // Verify that vi locale is loaded
      final viFlag = find.byTooltip(LocaleStore.languageToCountry['vi']![1]);
      expect(viFlag, findsNWidgets(2));
      await tester.tap(viFlag.at(1));
      expect(CurrentLocale.current.locale?.languageCode, "vi");
      expect(CurrentLocale.current.name, "vi");
      await tester.pumpAndSettle();
      // expect(find.text(deLoc.counterDescription), findsOneWidget);
      // expect(find.text(enLoc.counterDescription), findsNothing);

      // Verify that en locale is loaded

      final enFlag = find.byTooltip(LocaleStore.languageToCountry['en']![1]);
      await tester.tap(enFlag.at(1));
      await tester.pumpAndSettle();
      expect(CurrentLocale.current.locale?.languageCode, "en");
      expect(CurrentLocale.current.name, "en");
      // expect(find.text(enLoc.counterDescription), findsOneWidget);
      // expect(find.text(deLoc.counterDescription), findsNothing);

      final sysFlag =
          find.byTooltip(LocaleStore.languageToCountry['system']![1]);
      await tester.tap(enFlag.at(1));
      await tester.pumpAndSettle();
      expect(CurrentLocale.current.locale?.languageCode, "en");
      expect(CurrentLocale.current.name, "en");

      await tester.tap(sysFlag); // restore ?
    });

    testWidgets('it load locale and change via menu',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(
          {LocaleStore.innerSharedPreferenceName: "vi"});
      // Build our app and trigger a frame.
      await SharedPreferences.getInstance();
      await LocaleStore.init(); // why MaterialApp works without this ??
      await tester.pumpWidget(const MyAppCupertinoTest());
      await tester.pumpAndSettle();

      final viLoc = const Locale('vi').tr;

      // test start with english locale
      expect(find.text(viLoc.counterDescription), findsOneWidget);
      expect(CurrentLocale.current.name, "vi");

      expect(
          find.text(LocaleStore.languageToCountry['de']![1]), findsOneWidget);

      // tap menu
      final dropMenu = find.byType(DropdownMenu<LocaleNameFlag>);
      await tester.tap(dropMenu);
      await tester.pumpAndSettle();

      expect(CurrentLocale.current.locale?.languageCode, "vi");
      expect(CurrentLocale.current.name, "vi");

      // tap item
      final deOption = find.descendant(
        of: dropMenu,
        matching: find.byType(LangIconWithToolTip),
        // matching: find.text(LocaleStore.languageToCountry['de']![1]),
      );
      expect(deOption, findsNWidgets(5)); // 4 + current
      // await tester.tap(find.text(LocaleStore.languageToCountry['de']![1]).at(0));
      // await tester.ensureVisible(deOption.at(4));
      // await tester.pumpAndSettle();
      // await tester.tap(deOption.at(4));
      await tester.tap(find.byKey(const ValueKey("item-de")).at(1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // selected todo:
      expect(
          find.text(LocaleStore.languageToCountry['de']![1]), findsNWidgets(2));
      expect(CurrentLocale.current.name, "de");
      expect(CurrentLocale.current.locale?.languageCode, "de");

      final deLoc = const Locale('de').tr;
      expect(find.text(deLoc.counterDescription), findsOneWidget);

      // ??
      final sysFlag =
          find.byTooltip(LocaleStore.languageToCountry['system']![1]);
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
      await tester.pumpWidget(const MyAppCupertinoTest());

      // final deLoc = const Locale('de').tr;
      final enLoc = const Locale('en').tr;

      // test start with english locale
      expect(CurrentLocale.current.name, "system");
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
      expect(CurrentLocale.current.locale?.languageCode, "de");
      expect(CurrentLocale.current.name, "de");

      expect(
          find.text(const Locale('de').tr.counterDescription), findsOneWidget);
      expect(find.text(enLoc.counterDescription), findsNothing);

      // final sysFlag = find.byTooltip(LocaleStore.languageToCountry['system']![1]);
      // await tester.tap(sysFlag); // restore ?
    });
  });
}
