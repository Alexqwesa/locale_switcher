import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_locale.dart';

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

  final bool useEmoji;

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
    this.useEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrentLocale.allNotifiers,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: useStaticIcon ??
              LangIconWithToolTip(
                useEmoji: useEmoji,
                toolTipPrefix: toolTipPrefix,
                localeNameFlag: LocaleSwitcher.current,
                radius: radius,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
          onPressed: () => showSelectLocaleDialog(
            context,
            title: popUpWindowTitle,
            setLocaleCallBack: setLocaleCallBack,
            useEmoji: useEmoji,
          ),
        );
      },
    );
  }
}
