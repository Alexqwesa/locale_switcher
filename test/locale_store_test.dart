import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  //   expect(LocaleStore.languageTag.value, "system");
  //   expect(LocaleStore.locale.value, enLoc);
  // });

  test('it load preference: de', () async {
    SharedPreferences.setMockInitialValues(
        {LocaleStore.innerSharedPreferenceName: "de"});
    await LocaleStore.init();

    const deLoc = Locale('de');
    // final enLoc = const Locale('de').tr;

    // test start with english locale
    expect(LocaleStore.languageTag.value, "de");
    expect(LocaleStore.locale.value, deLoc);
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
    expect(LocaleStore.languageTag.value, "de");
    expect(LocaleStore.locale.value, deLoc);

    LocaleStore.languageTag.value = LocaleStore.systemLocale;
    expect(LocaleStore.languageTag.value, "system");
    expect(LocaleStore.locale.value.toLanguageTag(), 'vi');

    platform.localeTestValue = const Locale('es');
    expect(LocaleStore.languageTag.value, "system");
    expect(LocaleStore.locale.value.toLanguageTag(), 'es');
  });
}
