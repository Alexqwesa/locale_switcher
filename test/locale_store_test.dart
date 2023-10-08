import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_observable.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // setUpAll(() async {});
  // setUp(() async {});
  // tearDown(() async {});

  // test('it load preference: system', () async {
  //   SharedPreferences.setMockInitialValues(
  //       {LocaleStore.innerSharedPreferenceName: "system"});
  //   await SharedPreferences.getInstance();
  //   await LocaleStore.init();
  //
  //   // final deLoc = const Locale('de').tr;
  //   const enLoc = Locale('en');
  //
  //   // test start with english locale
  //   expect(LocaleStore.languageCode.value, "system");
  //   expect(LocaleStore.locale.value, enLoc);
  // });

  test('it load preference: de', () async {
    SharedPreferences.setMockInitialValues({LocaleStore.prefName: "de"});
    await LocaleStore.init(
        supportedLocales: const [Locale('de'), Locale('en')]);

    const deLoc = Locale('de');
    // final enLoc = const Locale('de').tr;

    // test start with english locale
    expect(LocaleSwitcher.current.name, "de");
    expect(LocaleSwitcher.current.locale, deLoc);
  });

  test('it monitor system locale changes', () async {
    WidgetsFlutterBinding.ensureInitialized();
    final platform = TestPlatformDispatcher(
        platformDispatcher: WidgetsBinding.instance.platformDispatcher);
    TestablePlatformDispatcher.overridePlatformDispatcher = platform;
    platform.localeTestValue = const Locale('vi');
    SharedPreferences.setMockInitialValues({LocaleStore.prefName: "de"});
    await LocaleStore.init(
        supportedLocales: const [Locale('de'), Locale('en'), Locale('vi')]);

    // test start with english locale
    const deLoc = Locale('de');
    expect(LocaleSwitcher.current.name, "de");
    expect(LocaleSwitcher.current.locale, deLoc);

    LocaleSwitcher.current = LocaleMatcher.byName(systemLocale)!;
    expect(LocaleSwitcher.current.name, "system");
    expect(LocaleSwitcher.current.locale!.languageCode, 'vi');

    platform.localeTestValue = const Locale('es');
    expect(LocaleSwitcher.current.name, "system");
    expect(LocaleSwitcher.current.locale!.languageCode, 'es');
  });

  // test('it convert string to locale', () async {
  //   final names = ['en', 'vi', 'de'];
  //   await tester.pumpWidget(LocaleManager(
  //     supportedLocales: names.map((e) => Locale(e)).toList(),
  //     child: const MyApp(),
  //   ));
  //
  //   final namesSystem = ['system', 'en', 'vi', 'de'];
  //   final lnf = LocaleSwitcher.localeNameFlags;
  //   expect(lnf.names, namesSystem);
  //   expect(lnf[1].flag?.key, Flags.instance['us']?.svg.key);
  //   expect(lnf[2].flag?.key, Flags.instance['vn']?.svg.key);
  //   expect(lnf[3].flag?.key, Flags.instance['de']?.svg.key);
  //   // for (final locName in lnf.skip(1)) {
  //   //   expect(locName.flag?.key, Flags.instance[locName.name]?.svg.key);
  //   // }
  // });
}
