import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/select_locale_dialog.dart';

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
    final staticLocales = [
      LocaleStore.systemLocale,
      ...(LocaleStore.supportedLocales ?? [])
          .take(numberOfShown) // chose most used
          .map((e) => e.languageCode),
    ];

    return ValueListenableBuilder(
      valueListenable: LocaleStore.realLocaleNotifier,
      builder: (BuildContext context, value, Widget? child) {
        var locales = [...staticLocales];
        if (!locales.contains(LocaleStore.realLocaleNotifier.value)) {
          locales.last = LocaleStore.realLocaleNotifier.value;
        }
        if ((LocaleStore.supportedLocales?.length ?? 0) > numberOfShown) {
          locales.add(showOtherLocales);
        }

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
                      allowUnlistedValues: true,
                      current: LocaleStore.realLocaleNotifier.value,
                      values: locales,
                      loading: false,
                      onChanged: (langCode) async {
                        if (langCode == showOtherLocales) {
                          showSelectLocaleDialog(context);
                        } else {
                          LocaleStore.setLocale(langCode);
                        }
                      },
                      style: const ToggleStyle(
                          // indicatorColor: Colors.white38,
                          backgroundColor: Colors.black12),
                      iconBuilder: (value, foreground) {
                        if (LocaleStore.languageToCountry[value] != null) {
                          final lang = LocaleStore.languageToCountry[value]!;
                          if (value == showOtherLocales) {
                            return const SelectLocaleButton();
                          }
                          return Tooltip(
                            message: lang[1],
                            child: lang.length <= 2
                                ? CircleFlag((lang[0] as String).toLowerCase())
                                : ClipOval(child: lang[2]),
                          );
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
