import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';

// ignore: avoid_relative_lib_import
void main() {
  // setUpAll(() async {});
  // setUp(() async {});
  // tearDown(() async {});

  test('it works with SupportedLocaleNames', () async {
    // LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final names = <String>['en_gb', 'vi_vn', 'de_de'];
    final namesSystem = ['system', 'en_gb', 'vi_vn', 'de_de'];
    final lnf =
        SupportedLocaleNames(names.map((String e) => e.toLocale()).toList());
    expect(lnf.length, namesSystem.length);
    expect(lnf.names, namesSystem);

    lnf.addName(showOtherLocales);
    expect(lnf.names, namesSystem + [showOtherLocales]);

    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());
    final lnf2 = SupportedLocaleNames.fromEntries(lnf.skip(1).take(2));
    expect(lnf2.names, ['en_gb', 'vi_vn']);
    expect(lnf2.addName('de'), false);
    expect(lnf2.addName('de_DE'), true);

    expect(lnf2.names, ['en_gb', 'vi_vn', 'de_de']);
  });

  test('it works with LocaleMatcher', () async {
    // LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final names = <String>['en_gb', 'vi_vn', 'de_de'];

    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());
    final lnf = LocaleSwitcher.supportedLocaleNames;
    final namesSystem = ['system', 'en_gb', 'vi_vn', 'de_de'];
    expect(lnf.length, namesSystem.length);
    expect(lnf.names, namesSystem);

    expect(LocaleMatcher.tryFindLocale('vi')?.locale?.countryCode, 'vn');
    expect(LocaleMatcher.byLanguage('vi')?.locale?.countryCode, 'vn');
  });

  test('tryFindLocale returns a valid LocaleName when found by name', () {
    final names = <String>['en_gb', 'vi_vn', 'de_de'];
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());
    final result = LocaleMatcher.tryFindLocale('en_US');
    expect(result, isNotNull);
    expect(result!.name, 'en_gb');

    final result2 = LocaleMatcher.tryFindLocale('en_gb');
    expect(result2, isNotNull);
    expect(result2!.name, 'en_gb');
  });

  test('tryFindLocale returns a valid LocaleName when found by language', () {
    final names = <String>['en_gb', 'vi_vn', 'de_de'];
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());
    final result = LocaleMatcher.tryFindLocale('en');
    expect(result, isNotNull);
    expect(result!.name, 'en_gb'); // Assuming 'en' maps to 'en_US' in your code
  });

  test(
      'tryFindLocale returns null when not found and IfLocaleNotFound is doNothing',
      () {
    final result = LocaleMatcher.tryFindLocale('non_existent_locale');
    expect(result, isNull);
  });

  test(
      'tryFindLocale returns a valid LocaleName when IfLocaleNotFound is useSystem ',
      () {
    final names = <String>['vi_vn', 'de_de', 'en_gb'];
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final result = LocaleMatcher.tryFindLocale('non_existent_locale',
        ifLocaleNotFound: IfLocaleNotFound.useSystem);
    expect(result, isNotNull);
    expect(result!.name, 'system');
    expect(result.bestMatch.toString(), 'en_gb');
    expect(result.locale.toString(), 'en_US');
  });

  test(
      'tryFindLocale returns system when IfLocaleNotFound is useSystem and system locale is not found',
      () {
    final names = <String>['en_gb', 'vi_vn', 'de_de'];
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final result = LocaleMatcher.tryFindLocale('non_existent_locale',
        ifLocaleNotFound: IfLocaleNotFound.useSystem);
    expect(result!.name, 'system');
  });

  test(
      'tryFindLocale returns a valid LocaleName when IfLocaleNotFound is useFirst and a valid locale is not found',
      () {
    final names = <String>['de_de', 'en_gb', 'vi_vn'];
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final result = LocaleMatcher.tryFindLocale('non_existent_locale',
        ifLocaleNotFound: IfLocaleNotFound.useFirst);
    expect(result, isNotNull);
    expect(result!.name, 'de_de');
  });

  test('byLocale returns a valid LocaleName ', () {
    final names = <String>['de_de', 'en_gb', 'vi_vn'];
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final result =
        LocaleMatcher.byLocale(LocaleSwitcher.supportedLocaleNames[3].locale!);
    expect(result, isNotNull);
    expect(result!.name, 'vi_vn');

    // exact match
    final result2 = LocaleMatcher.byLocale(const Locale('vi'));
    expect(result2, isNull);
  });

  test('LocaleName toString() ', () {
    final names = <String>['de_de', 'en_gb', 'vi_vn'];
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    expect(LocaleSwitcher.supportedLocaleNames.firstOrNull, isNotNull);
    expect(LocaleSwitcher.supportedLocaleNames.firstOrNull!.toString(),
        "system|en");
  });

  test('LocaleName showOtherLocales failsafe ', () {
    final names = <String>['de_de', 'en_gb', 'vi_vn'];
    final lnf =
        SupportedLocaleNames(names.map((String e) => e.toLocale()).toList());
    lnf.addShowOtherLocales();

    expect(lnf[4], isNotNull);
    expect(lnf[4].bestMatch.toString(), "de_de");
  });

  test('LocaleName showOtherLocales failsafe ', () {
    final names = <String>['de_de', 'en_gb', 'vi_vn'];
    final lnf = SupportedLocaleNames(
        names.map((String e) => e.toLocale()).toList(),
        showOsLocale: true);
    lnf.replaceLast(str: 'de');
    expect(lnf[0].toString(), "system|en");
    expect(lnf.last.toString(), "vi_vn|vi");
  });
}
