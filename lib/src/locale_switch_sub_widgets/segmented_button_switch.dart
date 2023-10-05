import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

import '../locale_store.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final LocaleNameFlagList locales;
  final int useNLettersInsteadOfIcon;

  final double? radius;

  final ShapeBorder? shape;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.radius = 32,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<LocaleNameFlag>(
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: locales.map<ButtonSegment<LocaleNameFlag>>(
        (e) {
          final curRadius =
              e.name == LocaleStore.systemLocale ? (radius ?? 24) * 5 : radius;
          return ButtonSegment<LocaleNameFlag>(
            value: e,
            tooltip: LocaleStore.languageToCountry[e]?[1] ?? e,
            label: Padding(
              padding: e.name == LocaleStore.systemLocale
                  ? const EdgeInsets.all(0.0)
                  : const EdgeInsets.all(8.0),
              child: FittedBox(
                child: (LocaleStore.languageToCountry[e] ?? const []).length > 2
                    ? LocaleStore.languageToCountry[e]![2] ??
                        LangIconWithToolTip(
                          localeNameFlag: e,
                          radius: curRadius,
                          useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                          shape: shape,
                        )
                    : LangIconWithToolTip(
                        localeNameFlag: e,
                        radius: curRadius,
                        useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                        shape: shape,
                      ),
              ),
            ),
          );
        },
      ).toList(),
      selected: {CurrentLocale.current},
      multiSelectionEnabled: false,
      onSelectionChanged: (Set<LocaleNameFlag> newSelection) {
        if (newSelection.first.name == showOtherLocales) {
          showSelectLocaleDialog(context);
        } else {
          CurrentLocale.current = newSelection.first;
        }
      },
    );
  }
}
