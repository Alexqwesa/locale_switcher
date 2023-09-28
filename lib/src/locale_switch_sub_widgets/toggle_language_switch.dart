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
      values: locales,
      current: LocaleManager.languageCode.value,
      onChanged: (langCode) async {
        if (langCode == showOtherLocales) {
          showSelectLocaleDialog(context);
        } else {
          LocaleManager.languageCode.value = langCode;
        }
      },
      iconBuilder: (lang, foreground) => LangIconWithToolTip(
        langCode: lang,
        useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
        shape: shape,
      ),
      allowUnlistedValues: true,
      loading: false,
      style: ToggleStyle(
        backgroundColor: Colors.black12,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}
