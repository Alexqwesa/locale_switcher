import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final LocaleNameFlagList locales;
  final int useNLettersInsteadOfIcon;

  final double? radius;

  final ShapeBorder? shape;

  final Function(BuildContext)? setLocaleCallBack;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.radius = 32,
    this.shape,
    this.setLocaleCallBack,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<LocaleNameFlag>(
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: locales.map<ButtonSegment<LocaleNameFlag>>(
        (e) {
          final curRadius = radius;
          return ButtonSegment<LocaleNameFlag>(
            value: e,
            tooltip: e.language,
            label: Padding(
              padding:
                  // e.name == LocaleStore.systemLocale
                  //     ? const EdgeInsets.all(0.0)
                  //     :
                  const EdgeInsets.all(8.0),
              child: LangIconWithToolTip(
                localeNameFlag: e,
                radius: curRadius,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
            ),
          );
        },
      ).toList(),
      selected: {CurrentLocale.current},
      multiSelectionEnabled: false,
      onSelectionChanged: (Set<LocaleNameFlag> newSelection) {
        if (newSelection.first.name == showOtherLocales) {
          showSelectLocaleDialog(context, setLocaleCallBack: setLocaleCallBack);
        } else {
          CurrentLocale.current = newSelection.first;
          setLocaleCallBack?.call(context);
        }
      },
    );
  }
}