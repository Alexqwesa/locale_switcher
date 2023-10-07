import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

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

  final Function(BuildContext)? setLocaleCallBack;

  const SelectLocaleButton({
    super.key,
    this.updateIconOnChange = true,
    this.toolTipPrefix = 'Current language: ',
    this.radius = 32,
    this.useStaticIcon,
    this.popUpWindowTitle = "",
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.setLocaleCallBack,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrentLocale.allNotifiers,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: useStaticIcon ??
              LangIconWithToolTip(
                toolTipPrefix: toolTipPrefix,
                localeNameFlag: CurrentLocale.current,
                radius: radius,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
          // tooltip: LocaleStore.languageToCountry[showOtherLocales]?[1] ??
          //     "Other locales",
          onPressed: () => showSelectLocaleDialog(
            context,
            title: popUpWindowTitle,
            setLocaleCallBack: setLocaleCallBack,
          ),
        );
      },
    );
  }
}
