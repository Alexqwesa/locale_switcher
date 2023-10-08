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
    // ============= THIS 6 LINES ARE REQUIRED =============
    return ValueListenableBuilder(
      valueListenable: LocaleSwitcher.locale,
      builder: (BuildContext context, locale, Widget? child) {
        return MaterialApp(
          locale: LocaleSwitcher.localeBestMatch,
          supportedLocales: AppLocalizations.supportedLocales,
          // ...
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          title: LocaleSwitcher.locale.value.tr.example,
          home: MyHomePage(title: LocaleSwitcher.locale.value.tr.example),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.lightBlue[900]!),
            useMaterial3: true,
            textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 22)),
          ),
        );
      },
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
                numberOfShown: 2,
                builder: (langCodes, context) {
                  if (langCodes.length <= 1) {
                    // AnimatedToggleSwitch crash with one value
                    langCodes.addShowOtherLocales();
                  }

                  return AnimatedToggleSwitch<LocaleName>.rolling(
                    values: LocaleSwitcher.supportedLocaleNames,
                    current: LocaleSwitcher.current,
                    onChanged: (langCode) {
                      if (langCode.name == showOtherLocales) {
                        showSelectLocaleDialog(context);
                      } else {
                        LocaleSwitcher.current = langCode;
                      }
                    },
                    iconBuilder: LangIconWithToolTip.forIconBuilder,
                    allowUnlistedValues: true,
                    loading: false,
                    style: ToggleStyle(
                      backgroundColor: Colors.black12,
                      indicatorColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            // OR LocaleSwitcher.custom(...)
            const CounterWidget(),
          ],
        ),
      ),
    );
  }
}

///
/// BELOW IS JUST SOME RANDOM CODE - YOU DON'T NEED IT!!!!!!
///
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            loc.counterDescription,
            textAlign: TextAlign.center,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: loc.increment,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
