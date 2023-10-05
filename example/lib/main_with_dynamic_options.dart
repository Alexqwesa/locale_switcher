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
        locale: LocaleManager.locale.value,
        supportedLocales: AppLocalizations.supportedLocales,
        // ...
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        title: LocaleManager.locale.value.tr.example,
        home: MyHomePage(title: LocaleManager.locale.value.tr.example),
        debugShowCheckedModeBanner: false,
        // themeMode: ThemeMode.dark,
        theme: ThemeData
            // .dark().copyWith
            (
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue[400]!),
          useMaterial3: true,
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int showNletters = 0;

  bool showLeading = true;

  bool circleOrSquare = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context); // localization shortcut

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
        actions: [
          // =============== THIS LINE ===============
          LocaleSwitcher.iconButton(
            useNLettersInsteadOfIcon: showNletters,
            shape: circleOrSquare ? const CircleBorder(eccentricity: 0) : null,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Table(
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(400),
                        1: FixedColumnWidth(450),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            TableCell(
                              // =============== THIS LINE ===============
                              child: Center(
                                child: LocaleSwitcher.menu(
                                  title: loc.chooseLanguage,
                                  useNLettersInsteadOfIcon: showNletters,
                                  showLeading: showLeading,
                                  shape: circleOrSquare
                                      ? const CircleBorder(eccentricity: 0)
                                      : null,
                                ),
                              ),
                            ),
                            TableCell(
                                child: SizedBox(
                              height: 130,
                              child: Row(
                                children: [
                                  Text(loc.showIcons),
                                  Switch(
                                    value: showLeading,
                                    onChanged: (val) {
                                      setState(() {
                                        showLeading = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            TableCell(
                              child: SizedBox(
                                width: 400,
                                // =============== THIS LINE ===============
                                child: LocaleSwitcher.custom(
                                  numberOfShown: 2,
                                  builder: (langCodes, context) {
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
                                          LocaleManager.languageCode.value =
                                              langCode;
                                        }
                                      },
                                      iconBuilder: (lang, foreground) =>
                                          LangIconWithToolTip(
                                        localeCode: lang,
                                        useNLettersInsteadOfIcon: showNletters,
                                      ),
                                      allowUnlistedValues: true,
                                      loading: false,
                                      style: ToggleStyle(
                                        backgroundColor: Colors.black12,
                                        indicatorColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                    );
                                  },
                                  // shape: circleOrSquare? const CircleBorder(eccentricity: 0) : null,
                                ),
                              ),
                            ),
                            TableCell(
                              child: SizedBox(
                                height: 130,
                                child: Row(
                                  children: [
                                    Text(loc.showIcons),
                                    Switch(
                                      key: const ValueKey('letterSwitch'),
                                      value: (showNletters == 0),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val) {
                                            showNletters = 0;
                                          } else {
                                            showNletters = 2;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            TableCell(
                              child: SizedBox(
                                width: 400,
                                height: 130,
                                // =============== THIS LINE ===============
                                child: LocaleSwitcher.segmentedButton(
                                  useNLettersInsteadOfIcon: showNletters,
                                  numberOfShown: 2,
                                  shape: circleOrSquare
                                      ? const CircleBorder(eccentricity: 0)
                                      : null,
                                ),
                              ),
                            ),
                            TableCell(
                              child: SizedBox(
                                height: 130,
                                child: Row(
                                  children: [
                                    Text(loc.circleOrSquare),
                                    Switch(
                                      value: !circleOrSquare,
                                      onChanged: (val) {
                                        setState(() {
                                          circleOrSquare = !val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const CounterWidget(),
              ],
            ),
          ),
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
