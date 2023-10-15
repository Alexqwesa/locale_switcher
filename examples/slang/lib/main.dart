import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:slang_example/i18n/strings.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale(); // initialize with the right locale
  runApp(TranslationProvider(
    // wrap with TranslationProvider
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: MyHomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue[900]!),
        useMaterial3: true,
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 22)),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    LocaleSettings.getLocaleStream().listen((event) {
      print('locale changed: $event');
    });
  }

  @override
  Widget build(BuildContext context) {
    // get t variable, will trigger rebuild on locale change
    // otherwise just call t directly (if locale is not changeable)
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.mainScreen.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(t.mainScreen.counter(n: _counter)),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,

                // lets loop over all supported locales
                children: [
                  SwitchWidget(),
                ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _counter++);
        },
        tooltip: context.t.mainScreen.tapMe, // using extension method
        child: Icon(Icons.add),
      ),
    );
  }
}

class SwitchWidget extends StatelessWidget {
  const SwitchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            // =============== THIS LINE ===============
            child: LocaleSwitcher.menu(
              title: context.t.chooseLanguage,
              setLocaleCallBack: (context) => LocaleSettings.setLocale(
                  AppLocale.values.firstWhere((element) =>
                      element.languageCode ==
                      LocaleSwitcher.localeBestMatch.languageCode)),
            ),
          ),
          const Divider(),
          TitleForLocaleSwitch(
            title: context.t.chooseLanguage,
            child: LocaleSwitcher.custom(
              builder: animatedToggleSwitchBuilder,
              numberOfShown: 2,
              // setLocaleCallBack: (context) =>
              //     LocaleSettings.setLocale(LocaleSwitcher.localeBestMatch),
            ),
          ),
          const Divider(),
          TitleForLocaleSwitch(
            title: context.t.chooseLanguage,
            // =============== THIS LINE ===============
            child: LocaleSwitcher.segmentedButton(
              numberOfShown: 2,
              setLocaleCallBack: (context) => LocaleSettings.setLocale(
                LocaleSettings.setLocale(AppLocale.values.firstWhere(
                    (element) =>
                        element.languageCode ==
                        LocaleSwitcher.localeBestMatch.languageCode)),
              ),
            ),
          ),
        ],
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
        showSelectLocaleDialog(context,
            setLocaleCallBack: (context) => LocaleSettings.setLocale(
                  LocaleSettings.setLocale(AppLocale.values.firstWhere(
                      (element) =>
                          element.languageCode ==
                          LocaleSwitcher.localeBestMatch.languageCode)),
                ));
      } else {
        LocaleSwitcher.current = langCode;
        LocaleSettings.setLocale(
          LocaleSettings.setLocale(AppLocale.values.firstWhere((element) =>
              element.languageCode ==
              LocaleSwitcher.localeBestMatch.languageCode)),
        );
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
