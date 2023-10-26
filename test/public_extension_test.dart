import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';

void main() {
  testWidgets('Test Locale.emoji', (WidgetTester tester) async {
    final locale1 = 'en_US'.toLocale();
    final locale2 = 'fr_FR'.toLocale();
    final locale3 = 'es'.toLocale();
    final locale4 = 'xyz_XYZ'.toLocale();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Column(
                children: [
                  Text('Flag for English: ${locale1.emoji}'),
                  Text('Flag for French: ${locale2.emoji}'),
                  Text('Flag for Spanish: ${locale3.emoji}'),
                  Text('Flag for UNKNOWN: ${locale4.emoji}'),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(
      find.textContaining(String.fromCharCodes(
          'us'.toUpperCase().codeUnits.map((e) => e + emojiOffset))),
      findsOneWidget,
    );

    expect(
      find.textContaining(String.fromCharCodes(
          'fr'.toUpperCase().codeUnits.map((e) => e + emojiOffset))),
      findsOneWidget,
    );

    expect(
      find.textContaining(String.fromCharCodes(
          'es'.toUpperCase().codeUnits.map((e) => e + emojiOffset))),
      findsOneWidget,
    );

    expect(
      find.textContaining('XYZ'),
      findsOneWidget,
    );
  });

  testWidgets('Test Locale.flag FlagNotFoundFallBack options',
      (WidgetTester tester) async {
    final locale = Locale('xyz_XYZ');

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Column(
                children: [
                  locale.flag(fallBack: FlagNotFoundFallBack.full) ??
                      const Text(''),
                  locale.flag(
                          fallBack: FlagNotFoundFallBack.countryCodeThenFull) ??
                      const Text(''),
                  locale.flag(
                          fallBack: FlagNotFoundFallBack
                              .emojiThenCountryCodeThenFull) ??
                      const Text(''),
                  locale.flag(fallBack: FlagNotFoundFallBack.emojiThenFull) ??
                      const Text(''),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Verify that the flags are displayed with fallback options
    expect(
      find.text('XYZ'),
      findsNWidgets(2),
    );
    expect(
      find.text('xyz_XYZ'),
      findsNWidgets(2),
    );
  });
}
