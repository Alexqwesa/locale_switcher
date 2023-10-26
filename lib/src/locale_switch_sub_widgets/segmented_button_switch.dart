import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final SupportedLocaleNames locales;
  final int useNLettersInsteadOfIcon;

  final double? radius;

  final ShapeBorder? shape;

  final Function(BuildContext)? setLocaleCallBack;

  final bool useEmoji;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.radius = 32,
    this.shape,
    this.setLocaleCallBack,
    this.useEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<LocaleName>(
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: locales.map<ButtonSegment<LocaleName>>(
        (e) {
          final curRadius = radius;
          return ButtonSegment<LocaleName>(
            value: e,
            tooltip: e.language,
            label: Padding(
              padding:
                  // e.name == systemLocale
                  //     ? const EdgeInsets.all(0.0)
                  //     :
                  const EdgeInsets.all(8.0),
              child: LangIconWithToolTip(
                useEmoji: useEmoji,
                localeNameFlag: e,
                radius: curRadius,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
            ),
          );
        },
      ).toList(),
      selected: {LocaleSwitcher.current},
      multiSelectionEnabled: false,
      onSelectionChanged: (Set<LocaleName> newSelection) {
        if (newSelection.first.name == showOtherLocales) {
          showSelectLocaleDialog(context, setLocaleCallBack: setLocaleCallBack);
        } else {
          LocaleSwitcher.current = newSelection.first;
          setLocaleCallBack?.call(context);
        }
      },
    );
  }
}
