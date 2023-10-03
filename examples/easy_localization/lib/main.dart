import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'generated/locale_keys.g.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('de', 'DE'),
          Locale('vi', 'VN')
        ],
        useOnlyLangCode: true,
        path:
            'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('en', 'US'),
        child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ============= THIS 4 LINES ARE REQUIRED =============
    return LocaleManager(
      child: MaterialApp(
        locale: LocaleManager.locale.value, //context.locale,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          // =============== THIS LINE ===============
          LocaleSwitcher.iconButton(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              // =============== THIS LINE ===============
              child: LocaleSwitcher.menu(title: LocaleKeys.chooseLanguage.tr()),
            ),
            const Divider(),
            SizedBox(
              width: 400,
              // =============== THIS LINE ===============
              child: LocaleSwitcher.custom(
                builder: animatedToggleSwitchBuilder,
                numberOfShown: 2,
              ),
            ),
            const Divider(),
            SizedBox(
              width: 450,
              // =============== THIS LINE ===============
              child: LocaleSwitcher.segmentedButton(
                numberOfShown: 2,
                title: LocaleKeys.chooseLanguage.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget animatedToggleSwitchBuilder(
    List<String> langCodes, BuildContext context) {
  if (langCodes.length <= 1) {
    // AnimatedToggleSwitch crash with one value
    langCodes.add(showOtherLocales);
  }

  return AnimatedToggleSwitch<String>.rolling(
    values: langCodes,
    current: LocaleManager.languageCode.value,
    onChanged: (langCode) {
      if (langCode == showOtherLocales) {
        showSelectLocaleDialog(context);
      } else {
        LocaleManager.languageCode.value = langCode;
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
