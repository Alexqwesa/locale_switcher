import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// Useful extension, in case you need to use localization outside of MaterialApp.
extension LocaleWithDelegate on Locale {
  /// Get class with translation strings for this locale.
  AppLocalizations get tr => lookupAppLocalizations(this);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ============= THIS 4 LINES ARE REQUIRED =============
    return LocaleManager(
      child: MaterialApp(
        locale: LocaleSwitcher.locale.value,
        supportedLocales: AppLocalizations.supportedLocales,
        // ...
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        title: LocaleSwitcher.locale.value.tr.example,
        home: MyHomePage(title: LocaleSwitcher.locale.value.tr.example),
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
    final loc = AppLocalizations.of(context); // localization shortcut
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
              child: LocaleSwitcher.menu(title: loc.chooseLanguage),
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
                title: loc.chooseLanguage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget animatedToggleSwitchBuilder(
    LocaleNameFlagList langCodes, BuildContext context) {
  if (langCodes.length <= 1) {
    // AnimatedToggleSwitch crash with one value
    langCodes.addShowOtherLocales();
  }

  return AnimatedToggleSwitch<LocaleNameFlag>.rolling(
    values: langCodes,
    current: CurrentLocale.current,
    onChanged: (langCode) {
      if (langCode.name == showOtherLocales) {
        showSelectLocaleDialog(context);
      } else {
        CurrentLocale.current = langCode;
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
