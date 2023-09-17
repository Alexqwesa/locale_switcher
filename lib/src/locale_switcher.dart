import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_store.dart';

const showOtherLocales = 'show_other_locales';

/// A Widget to switch locale of App.
class LocaleSwitcher extends StatelessWidget {
  final String? title;

  final int numberOfShown;

  final bool inRow;

  /// A Widget to switch locale of App.
  const LocaleSwitcher({
    super.key,
    this.title = 'Choose the language:',
    this.numberOfShown = 4,
    this.inRow = false,
  });

  @override
  Widget build(BuildContext context) {
    final locales = [
      LocaleStore.systemLocale,
      ...(LocaleStore.supportedLocales ?? [])
          .take(numberOfShown) // chose most used
          .map((e) => e.languageCode),
      if ((LocaleStore.supportedLocales?.length ?? 0) > numberOfShown)
        showOtherLocales
    ];
    return ValueListenableBuilder(
      valueListenable: LocaleStore.realLocaleNotifier,
      builder: (BuildContext context, value, Widget? child) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!inRow)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Center(child: Text(title ?? '')),
                ),
              Row(
                children: [
                  if (inRow)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Center(child: Text(title ?? '')),
                    ),
                  Expanded(
                    child: AnimatedToggleSwitch<String>.rolling(
                      current: LocaleStore.realLocale,
                      values: locales,
                      loading: false,
                      onChanged: (langCode) async {
                        LocaleStore.setLocale(langCode);
                      },
                      style: const ToggleStyle(
                          // indicatorColor: Colors.white38,
                          backgroundColor: Colors.black12),
                      iconBuilder: (value, foreground) {
                        if (value == LocaleStore.systemLocale) {
                          return const ClipOval(child: Icon(Icons.language));
                        }
                        if (value == showOtherLocales) {
                          return const ClipOval(child: Icon(Icons.menu));
                        }
                        if (value == 'en') {
                          return CircleFlag(
                            'us',
                          );
                        }
                        return CircleFlag(
                          value,
                        );
                      },

                      // for deactivating loading animation
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
