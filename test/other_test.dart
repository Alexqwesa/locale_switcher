// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';

void main() {
  testWidgets('it fail other widgets', (WidgetTester tester) async {
    await tester.pumpWidget(LocaleManager(child: Container()));
    final e = TestWidgetsFlutterBinding.instance.takeException();
    expect(e, isA<UnimplementedError>());
  });
}
