import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_locale.dart';

/// IconButton to show and select a language.
///
/// In popup window will be displayed [LocaleSwitcher.grid].
class SelectLocaleButton extends StatelessWidget {
  final bool updateIconOnChange;
  final LocaleSwitcher widget;

  const SelectLocaleButton({
    super.key,
    this.updateIconOnChange = true,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrentLocale.allNotifiers,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: widget.useStaticIcon ??
              LangIconWithToolTip(
                useEmoji: widget.useEmoji,
                toolTipPrefix: widget.toolTipPrefix ?? '',
                localeNameFlag: LocaleSwitcher.current,
                radius: widget.iconRadius,
                useNLettersInsteadOfIcon: widget.useNLettersInsteadOfIcon,
                shape: widget.shape,
                multiLangCountries: widget.multiLangCountries,
                multiLangForceAll: widget.multiLangForceAll,
                multiLangWidget: widget.multiLangWidget,
              ),
          onPressed: () => showSelectLocaleDialog(
            context,
            title: widget.title ?? '',
            setLocaleCallBack: widget.setLocaleCallBack,
            useEmoji: widget.useEmoji,
          ),
        );
      },
    );
  }
}
