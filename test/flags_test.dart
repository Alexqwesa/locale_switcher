import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';
import 'package:locale_switcher/src/locale_observable.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main_with_counter.dart';

void main() {
  testWidgets('it detect flags correctly', (WidgetTester tester) async {
    final names = <String>['en', 'vi', 'de'];
    await tester.pumpWidget(LocaleManager(
      supportedLocales: names.map((String e) => e.toLocale()).toList(),
      child: const MyApp(),
    ));

    final namesSystem = ['system', 'en', 'vi', 'de'];
    final lnf = LocaleSwitcher.supportedLocaleNames;
    expect(lnf.names, namesSystem);
    expect(lnf[1].flag?.key, Flags.instance['us']?.svg.key);
    expect(lnf[2].flag?.key, Flags.instance['vn']?.svg.key);
    expect(lnf[3].flag?.key, Flags.instance['de']?.svg.key);
    // for (final locName in lnf.skip(1)) {
    //   expect(locName.flag?.key, Flags.instance[locName.name]?.svg.key);
    // }
  });

  testWidgets('it detect flags for locale with country',
      (WidgetTester tester) async {
    final names = <String>['en_GB', 'vi_VN', 'de_lu'];
    await tester.pumpWidget(LocaleManager(
      supportedLocales: names.map((String e) => e.toLocale()).toList(),
      child: const MyApp(),
    ));
    var lnf1 = LocaleSwitcher.supportedLocaleNames;
    // it init supportedLocales only once (previous test)
    expect(lnf1.names, ['system', 'en', 'vi', 'de']);
    // it update supportedLocales
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());
    final lnf = LocaleSwitcher.supportedLocaleNames;
    final namesSystem = ['system', 'en_GB', 'vi_VN', 'de_lu'];
    expect(lnf.names, namesSystem);

    // it show flags
    expect(lnf[1].flag?.key, Flags.instance['gb']?.svg.key);
    expect(lnf[2].flag?.key, Flags.instance['vn']?.svg.key);
    expect(lnf[3].flag?.key, Flags.instance['lu']?.svg.key);

    // it update SupportedLocaleNames indexes works
    final namesSystem1 = ['system', 'de', 'vi_VN', 'de_lu'];
    lnf[1] = lnf1[3];
    expect(lnf.names, namesSystem1);
  });

  testWidgets('it can find localeBestMatch', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    final platform = TestPlatformDispatcher(
        platformDispatcher: WidgetsBinding.instance.platformDispatcher);
    TestablePlatformDispatcher.overridePlatformDispatcher = platform;
    platform.localeTestValue = const Locale('de');
    // SharedPreferences.setMockInitialValues(
    //     {LocaleStore.innerSharedPreferenceName: "de"});

    final names = <String>['en_GB', 'vi_VN', 'de_De'];
    await tester.pumpWidget(LocaleManager(
      supportedLocales: names.map((String e) => e.toLocale()).toList(),
      child: const MyApp(),
    ));
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final namesSystem = ['system', 'en_GB', 'vi_VN', 'de_De'];
    final lnf = LocaleSwitcher.supportedLocaleNames;
    expect(lnf.names, namesSystem);

    expect(LocaleSwitcher.current, lnf[0]);
    expect(LocaleSwitcher.localeBestMatch, lnf[3].locale);

    LocaleSwitcher.current = LocaleSwitcher.supportedLocaleNames[1];
    expect(LocaleSwitcher.current, lnf[1]);
    expect(LocaleSwitcher.localeBestMatch, lnf[1].locale);
  });

  testWidgets('it can find localeBestMatch 2', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    final platform = TestPlatformDispatcher(
        platformDispatcher: WidgetsBinding.instance.platformDispatcher);
    TestablePlatformDispatcher.overridePlatformDispatcher = platform;
    platform.localeTestValue = const Locale('vi');
    // SharedPreferences.setMockInitialValues(
    //     {LocaleStore.innerSharedPreferenceName: "de"});

    final names = <String>['en_GB', 'vi_VN', 'de_De'];
    await tester.pumpWidget(LocaleManager(
      supportedLocales: names.map((String e) => e.toLocale()).toList(),
      child: const MyApp(),
    ));
    LocaleSwitcher.readLocales(names.map((String e) => e.toLocale()).toList());

    final namesSystem = ['system', 'en_GB', 'vi_VN', 'de_De'];
    final lnf = LocaleSwitcher.supportedLocaleNames;
    expect(lnf.names, namesSystem);

    LocaleSwitcher.current = LocaleSwitcher.supportedLocaleNames[0];
    platform.localeTestValue = const Locale('vi');
    expect(LocaleSwitcher.current, lnf[0]);
    expect(LocaleSwitcher.localeBestMatch, lnf[2].locale);
  });
}
