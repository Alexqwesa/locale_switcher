import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:locale_switcher/locale_switcher.dart';

// ignore: avoid_relative_lib_imports
import 'main_with_counter.dart';

void main() => runApp(const MyAppCupertinoTest());

class MyAppCupertinoTest extends StatelessWidget {
  const MyAppCupertinoTest({super.key});

  @override
  Widget build(BuildContext context) {
    // ============= THIS 5 LINES REQUIRED =============
    return LocaleManager(
      child: CupertinoApp(
        locale: LocaleSwitcher.localeBestMatch,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // ...
        title: LocaleSwitcher.current.locale!.tr.example,
        home: MyHomePage(title: LocaleSwitcher.current.locale!.tr.example),
      ),
    );
  }
}
