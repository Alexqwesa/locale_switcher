import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher_dev/src/locale_switcher/lib/src/locale_observable.dart';
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
    SharedPreferences.setMockInitialValues(
        {LocaleStore.innerSharedPreferenceName: "de"});
    await LocaleStore.init();

    const deLoc = Locale('de');
    // final enLoc = const Locale('de').tr;

    // test start with english locale
    expect(CurrentLocale.current.name, "de");
    expect(CurrentLocale.current.locale, deLoc);
  });

  test('it monitor system locale changes', () async {
    final platform = TestPlatformDispatcher(
        platformDispatcher: WidgetsBinding.instance.platformDispatcher);
    TestablePlatformDispatcher.overridePlatformDispatcher = platform;
    platform.localeTestValue = const Locale('vi');
    SharedPreferences.setMockInitialValues(
        {LocaleStore.innerSharedPreferenceName: "de"});
    // await LocaleStore.init(); // can't init twice

    // test start with english locale
    const deLoc = Locale('de');
    expect(CurrentLocale.current.name, "de");
    expect(CurrentLocale.current.locale, deLoc);

    CurrentLocale.current = CurrentLocale.byName(LocaleStore.systemLocale)!;
    expect(CurrentLocale.current.name, "system");
    expect(CurrentLocale.current.locale!.languageCode, 'vi');

    platform.localeTestValue = const Locale('es');
    expect(CurrentLocale.current.name, "system");
    expect(CurrentLocale.current.locale!.languageCode, 'es');
  });
}
