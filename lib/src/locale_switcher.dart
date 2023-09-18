import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_store.dart';

const showOtherLocales = 'show_other_locales';

/// A Widget to switch locale of App.
class LocaleSwitcher extends StatelessWidget {
  /// A text describing switcher
  ///
  /// default: 'Choose the language:'
  /// pass null if not needed.
  final String? title;

  /// Title position,
  ///
  /// default `true` - on Top
  /// use `false` to show at Left side
  final bool titlePositionTop;

  /// Number of shown flags
  final int numberOfShown;

  /// A Widget to switch locale of App.
  const LocaleSwitcher({
    super.key,
    this.title = 'Choose the language:',
    this.numberOfShown = 4,
    this.titlePositionTop = true,
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
              if (titlePositionTop)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Center(child: Text(title ?? '')),
                ),
              Row(
                children: [
                  if (!titlePositionTop)
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
                        if (LocaleStore.languageToCountry[value] != null) {
                          final lang = LocaleStore.languageToCountry[value]!;
                          if (value == showOtherLocales) {
                            return IconButton(
                              icon: ClipOval(child: lang[2]),
                              onPressed: () {},
                            );
                          }

                          if (lang.length > 2) {
                            return ClipOval(child: lang[2]);
                          } else {
                            return CircleFlag(
                                (lang[0] as String).toLowerCase());
                          }
                        }
                        return CircleFlag(value);
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
