// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';

void main() {
  group('Languages', () {
    // Build our app and trigger a frame.
    test('it check showOtherLocales', () async {
      const count = 150;
      const severalLang = 37;
      final lc = languageToCountry;
      expect(lc.keys.toSet().length, count);
      expect(lc.values.toSet().length, count);
      final multi = lc.keys.where((e) => e.contains('_')).toSet().length;
      expect(multi, 9);
      expect(lc.values.map((e) => (e[0], e[1])).toSet().length, count);
      expect(lc.values.map((e) => e[1]).toSet().length, count);
      expect(lc.values.map((e) => e[0]).toSet().length, count - severalLang);

      // see who has several language:
      // final noDup = lc.values.map((e) => e[0]).toSet();
      // final llc = lc.values.toList();
      // noDup.forEach((key) {
      //   final el = llc.firstWhere((element) => element[0] == key);
      //   llc.remove(el);
      //
      // });
    });
  });
}
