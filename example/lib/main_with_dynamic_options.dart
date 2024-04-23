import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:url_launcher/url_launcher.dart';

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
        locale: LocaleSwitcher.localeBestMatch,
        supportedLocales: AppLocalizations.supportedLocales,
        // ...
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        title: LocaleSwitcher.locale.value.tr.example,
        home: MyHomePage(title: LocaleSwitcher.locale.value.tr.example),
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

  bool useEmoji = false;

  double size = 1;

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
            useEmoji: useEmoji,
            shape: circleOrSquare ? const CircleBorder(eccentricity: 0) : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
          child: LayoutBuilder(
            builder: (context, constrains) {
              final children = [
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        LocaleSwitcher.menu(
                          width: 310,
                          iconRadius: 38 * size,
                          title: loc.chooseLanguage,
                          useNLettersInsteadOfIcon: showNletters,
                          useEmoji: useEmoji,
                          showLeading: showLeading,
                          shape: circleOrSquare
                              ? const CircleBorder(eccentricity: 0)
                              : null,
                        ),
                        Divider(
                          color: Theme.of(context).canvasColor,
                          height: 20,
                        ),
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
                                values: langCodes,
                                height: 48 * size,
                                indicatorSize: Size(48 * size, 48 * size),
                                fittingMode: FittingMode.none,
                                current: LocaleSwitcher.current,
                                onChanged: (langCode) {
                                  if (langCode.name == showOtherLocales) {
                                    showSelectLocaleDialog(context);
                                  } else {
                                    LocaleSwitcher.current = langCode;
                                  }
                                },
                                iconBuilder: (lang, foreground) =>
                                    LangIconWithToolTip(
                                  localeNameFlag: lang,
                                  radius: 48 * size,
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
                        TitleForLocaleSwitch(
                          title: loc.chooseLanguage,
                          childSize: Size(400, 48 * size),
                          child: LocaleSwitcher.segmentedButton(
                            iconRadius: 32 * size,
                            // width: 400,
                            useNLettersInsteadOfIcon: showNletters,
                            useEmoji: useEmoji,
                            numberOfShown: 2,
                            shape: circleOrSquare
                                ? const CircleBorder(eccentricity: 0)
                                : null,
                          ),
                        ),
                        const CounterWidget(),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Source code of this page: ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: 'here',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.https(
                                          'github.com',
                                          '/Alexqwesa/locale_switcher/blob/main/example/lib/main_with_dynamic_options.dart',
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      width: 220,
                    ),
                    Text(loc.showIcons),
                    Switch(
                      value: showLeading,
                      onChanged: (val) {
                        setState(() {
                          showLeading = val;
                        });
                      },
                    ),
                    Text(loc.showLetters),
                    Switch(
                      key: const ValueKey('letterSwitch'),
                      value: (showNletters != 0),
                      onChanged: (val) {
                        setState(() {
                          if (!val) {
                            showNletters = 0;
                          } else {
                            showNletters = 2;
                            useEmoji = false;
                          }
                        });
                      },
                    ),
                    Text(loc.circleOrSquare),
                    Switch(
                      value: !circleOrSquare,
                      onChanged: (val) {
                        setState(() {
                          circleOrSquare = !val;
                          showNletters = 0;
                          useEmoji = false;
                        });
                      },
                    ),
                    Text(loc.showEmoji),
                    Switch(
                      value: useEmoji,
                      onChanged: (val) {
                        setState(() {
                          useEmoji = val;
                          showNletters = 0;
                        });
                      },
                    ),
                    Slider(
                        min: 0.2,
                        max: 2,
                        value: size,
                        onChanged: (val) {
                          setState(() {
                            size = val;
                          });
                        }),
                  ],
                )
              ];
              final rc = (constrains.maxWidth < 800);
              return rc
                  ? SizedBox(height: 800, child: Column(children: children))
                  : Row(children: children);
            },
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
