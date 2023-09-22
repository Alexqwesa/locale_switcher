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
  //   expect(LocaleStore.realLocaleNotifier.value, "system");
  //   expect(LocaleStore.locale.value, enLoc);
  // });

  test('it load preference: de', () async {
    SharedPreferences.setMockInitialValues(
        {LocaleStore.innerSharedPreferenceName: "de"});
    await LocaleStore.init();

    const deLoc = Locale('de');
    // final enLoc = const Locale('de').tr;

    // test start with english locale
    expect(LocaleStore.realLocaleNotifier.value, "de");
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
    expect(LocaleStore.realLocaleNotifier.value, "de");
    expect(LocaleStore.locale.value, deLoc);

    LocaleStore.realLocaleNotifier.value = LocaleStore.systemLocale;
    expect(LocaleStore.realLocaleNotifier.value, "system");
    expect(LocaleStore.locale.value.languageCode, 'vi');

    platform.localeTestValue = const Locale('es');
    expect(LocaleStore.realLocaleNotifier.value, "system");
    expect(LocaleStore.locale.value.languageCode, 'es');
  });
}
