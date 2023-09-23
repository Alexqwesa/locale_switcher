import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class ToggleLanguageSwitch extends StatelessWidget {
  const ToggleLanguageSwitch({
    super.key,
    required this.padding,
    required this.crossAxisAlignment,
    required this.titlePositionTop,
    required this.titlePadding,
    required this.title,
    required this.locales,
  });

  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final bool titlePositionTop;
  final EdgeInsets titlePadding;
  final String? title;
  final List<String> locales;

  @override
  Widget build(BuildContext context) {
    if (locales.length < 2) {
      locales
          .add(showOtherLocales); // AnimatedToggleSwitch crash with one value
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (titlePositionTop)
            Padding(
              padding: titlePadding,
              child: Center(child: Text(title ?? '')),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!titlePositionTop)
                Padding(
                  padding: titlePadding,
                  child: Center(child: Text(title ?? '')),
                ),
              Expanded(
                child: AnimatedToggleSwitch<String>.rolling(
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
                  style: const ToggleStyle(backgroundColor: Colors.black12),
                  iconBuilder: getIconForLanguage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
