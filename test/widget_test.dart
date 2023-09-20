// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

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
    expect(LocaleStore.realLocaleNotifier.value, "system");

    // Verify that vi locale is loaded
    final viFlag = find.byTooltip(LocaleStore.languageToCountry['vi']![1]);
    expect(viFlag, findsNWidgets(2));
    await tester.tap(viFlag.at(1));
    expect(LocaleManager.locale.value.languageCode, "vi");
    expect(LocaleStore.realLocaleNotifier.value, "vi");
    await tester.pumpAndSettle();
    // expect(find.text(deLoc.counterDescription), findsOneWidget);
    // expect(find.text(enLoc.counterDescription), findsNothing);

    // Verify that en locale is loaded

    final enFlag = find.byTooltip(LocaleStore.languageToCountry['en']![1]);
    await tester.tap(enFlag.at(1));
    await tester.pumpAndSettle();
    expect(LocaleManager.locale.value.languageCode, "en");
    expect(LocaleStore.realLocaleNotifier.value, "en");
    // expect(find.text(enLoc.counterDescription), findsOneWidget);
    // expect(find.text(deLoc.counterDescription), findsNothing);

    final sysFlag = find.byTooltip(LocaleStore.languageToCountry['system']![1]);
    await tester.tap(enFlag.at(1));
    await tester.pumpAndSettle();
    expect(LocaleManager.locale.value.languageCode, "en");
    expect(LocaleStore.realLocaleNotifier.value, "en");

    await tester.tap(sysFlag); // restore ?
  });

  testWidgets('it load locale and change via menu',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        {LocaleStore.innerSharedPreferenceName: "vi"});
    // Build our app and trigger a frame.
    // await LocaleStore.init();
    await SharedPreferences.getInstance();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final viLoc = const Locale('vi').tr;

    // test start with english locale
    expect(find.text(viLoc.counterDescription), findsOneWidget);
    expect(LocaleStore.realLocaleNotifier.value, "vi");

    expect(find.text(LocaleStore.languageToCountry['de']![1]), findsOneWidget);

    // tap menu
    final dropMenu = find.byType(DropdownMenu<String>);
    final openMenu =
        find.descendant(of: dropMenu, matching: find.byType(InkWell)
            // find.widgetWithIcon(Icon, Icons.arrow_drop_down),
            );
    // await tester.tap(dropMenu); // ???
    await tester.tap(openMenu.at(0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(LocaleManager.locale.value.languageCode, "vi");
    expect(LocaleManager.realLocaleNotifier.value, "vi");

    // tap item
    final option = find.descendant(
      of: dropMenu,
      matching: find.text(LocaleStore.languageToCountry['de']![1]),
    ); // Replace with the text of the option you want to select
    final deOption = find.ancestor(
      of: option,
      matching: find.byType(InkWell),
    ); // Replace with the text of the option you want to select
    expect(deOption, findsOneWidget);
    await tester.ensureVisible(deOption);
    await tester.pumpAndSettle();
    await tester.tap(deOption);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    // selected todo:
    // expect(
    // find.text(LocaleStore.languageToCountry['de']![1]), findsNWidgets(2));
    // expect(LocaleManager.realLocaleNotifier.value, "de");
    // expect(LocaleManager.locale.value.languageCode, "de");

    // final deLoc = const Locale('de').tr;
    // expect(find.text(deLoc.counterDescription), findsOneWidget);
  });
}
