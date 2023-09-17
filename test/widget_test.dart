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
  testWidgets('Localization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    final deLoc = const Locale('de').tr;
    final enLoc = const Locale('en').tr;
    final flags = find.byType(CircleFlag);
    expect(flags, findsNWidgets(3));

    // test start with english locale
    expect(find.text(enLoc.counterDescription), findsOneWidget);
    expect(LocaleStore.realLocaleNotifier.value, "system");

    // Verify that de locale is loaded
    await tester.tap(flags.at(2));
    expect(LocaleManager.locale.value.languageCode, "de");
    expect(LocaleStore.realLocaleNotifier.value, "de");
    await tester.pumpAndSettle();
    // expect(find.text(deLoc.counterDescription), findsOneWidget);
    // expect(find.text(enLoc.counterDescription), findsNothing);

    // Verify that en locale is loaded
    await tester.tap(flags.at(0));
    await tester.pumpAndSettle();
    expect(LocaleManager.locale.value.languageCode, "en");
    expect(LocaleStore.realLocaleNotifier.value, "en");
    // expect(find.text(enLoc.counterDescription), findsOneWidget);
    // expect(find.text(deLoc.counterDescription), findsNothing);

  });
}
