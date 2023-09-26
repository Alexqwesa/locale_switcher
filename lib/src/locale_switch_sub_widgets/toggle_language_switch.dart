import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class ToggleLanguageSwitch extends StatelessWidget {
  final int useNLettersInsteadOfIcon;
  final List<String> locales;

  final ShapeBorder? shape;

  const ToggleLanguageSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
  });

  @override
  Widget build(BuildContext context) {
    if (locales.length < 2) {
      locales
          .add(showOtherLocales); // AnimatedToggleSwitch crash with one value
    }

    return AnimatedToggleSwitch<String>.rolling(
      allowUnlistedValues: true,
      current: LocaleManager.languageCode.value,
      values: locales,
      loading: false,
      onChanged: (langCode) async {
        if (langCode == showOtherLocales) {
          showSelectLocaleDialog(context);
        } else {
          LocaleManager.languageCode.value = langCode;
        }
      },
      style: ToggleStyle(
        backgroundColor: Colors.black12,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      iconBuilder: (lang, foreground) => getIconForLanguage(
        lang,
        false,
        null,
        useNLettersInsteadOfIcon,
        null,
        shape,
      ),
    );
  }
}
