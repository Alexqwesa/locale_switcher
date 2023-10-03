import 'package:flutter/material.dart';

import '../../locale_switcher.dart';
import '../locale_store.dart';

/// IconButton to show and select a language.
///
/// In popup window will be displayed [LocaleSwitcher.grid].
class SelectLocaleButton extends StatelessWidget {
  final bool updateIconOnChange;

  final String toolTipPrefix;

  final double radius;

  final Widget? useStaticIcon;

  final String popUpWindowTitle;

  final int useNLettersInsteadOfIcon;

  final ShapeBorder? shape;

  const SelectLocaleButton({
    super.key,
    this.updateIconOnChange = true,
    this.toolTipPrefix = 'Current language: ',
    this.radius = 32,
    this.useStaticIcon,
    this.popUpWindowTitle = "",
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocaleStore.languageCode,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: useStaticIcon ??
              LangIconWithToolTip(
                toolTipPrefix: toolTipPrefix,
                langCode: LocaleStore.languageCode.value,
                radius: radius,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
          // tooltip: LocaleStore.languageToCountry[showOtherLocales]?[1] ??
          //     "Other locales",
          onPressed: () =>
              showSelectLocaleDialog(context, title: popUpWindowTitle),
        );
      },
    );
  }
}
