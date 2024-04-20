import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

import 'generated/locale_keys.g.dart';

// =============== THESE LINES ===============
// not needed for `locale_switcher_dev`
void activateSelectedLocale(BuildContext context) {
  context.setLocale(LocaleSwitcher.localeBestMatch);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('de', 'DE'),
          Locale('vi', 'VN')
        ],
        useOnlyLangCode: true,
        path: 'assets/translations',
        // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ============= THIS 4 LINES ARE REQUIRED =============
    return LocaleManager(
      child: MaterialApp(
        locale: LocaleSwitcher.localeBestMatch,
        //context.locale,
        supportedLocales: context.supportedLocales,
        // ...
        localizationsDelegates: context.localizationDelegates,
        title: LocaleKeys.example.tr(),
        home: MyHomePage(title: LocaleKeys.example.tr()),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue[900]!),
          useMaterial3: true,
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // Localizations.of(context)?.locale;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: const [
          // =============== THIS LINE ===============
          LocaleSwitcher.iconButton(
            setLocaleCallBack: activateSelectedLocale,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              // =============== THIS LINE ===============
              child: LocaleSwitcher.menu(
                title: LocaleKeys.chooseLanguage.tr(),
                setLocaleCallBack: activateSelectedLocale,
              ),
            ),
            const Divider(),
            TitleForLocaleSwitch(
              title: LocaleKeys.chooseLanguage.tr(),
              child: LocaleSwitcher.custom(
                builder: animatedToggleSwitchBuilder,
                numberOfShown: 2,
              ),
            ),
            const Divider(),
            TitleForLocaleSwitch(
              title: LocaleKeys.chooseLanguage.tr(),
              // =============== THIS LINE ===============
              child: const LocaleSwitcher.segmentedButton(
                numberOfShown: 2,
                setLocaleCallBack: activateSelectedLocale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget animatedToggleSwitchBuilder(
    SupportedLocaleNames langCodes, BuildContext context) {
  if (langCodes.length <= 1) {
    // AnimatedToggleSwitch crash with one value
    langCodes.addShowOtherLocales();
  }

  return AnimatedToggleSwitch<LocaleName>.rolling(
    values: langCodes,
    current: LocaleSwitcher.current,
    onChanged: (langCode) {
      if (langCode.name == showOtherLocales) {
        showSelectLocaleDialog(
          context,
          setLocaleCallBack: activateSelectedLocale,
        );
      } else {
        LocaleSwitcher.current = langCode;
        activateSelectedLocale(context);
      }
    },
    iconBuilder: LangIconWithToolTip.forIconBuilder,
    allowUnlistedValues: true,
    loading: false,
    style: ToggleStyle(
      backgroundColor: Colors.black12,
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
    ),
  );
}
