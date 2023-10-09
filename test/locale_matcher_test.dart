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
}
