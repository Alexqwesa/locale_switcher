// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/locale_switcher.dart';

void main() {
  testWidgets('it fail other widgets', (WidgetTester tester) async {
    await tester.pumpWidget(LocaleManager(child: Container()));
    final e = TestWidgetsFlutterBinding.instance.takeException();
    expect(e, isA<UnimplementedError>());
  });
}
