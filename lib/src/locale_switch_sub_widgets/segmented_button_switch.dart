import 'package:flutter/material.dart';

import '../../locale_switcher.dart';
import '../locale_store.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final List<String> locales;
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
    return SegmentedButton<String>(
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: locales.map<ButtonSegment<String>>(
        (e) {
          final curRadius =
              e == LocaleStore.systemLocale ? (radius ?? 24) * 5 : radius;
          return ButtonSegment<String>(
            value: e,
            tooltip: LocaleStore.languageToCountry[e]?[1] ?? e,
            label: Padding(
              padding: e == LocaleStore.systemLocale
                  ? const EdgeInsets.all(0.0)
                  : const EdgeInsets.all(8.0),
              child: FittedBox(
                child: (LocaleStore.languageToCountry[e] ?? const []).length > 2
                    ? LocaleStore.languageToCountry[e]![2] ??
                        LangIconWithToolTip(
                          langCode: e,
                          radius: curRadius,
                          useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                          shape: shape,
                        )
                    : LangIconWithToolTip(
                        langCode: e,
                        radius: curRadius,
                        useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                        shape: shape,
                      ),
              ),
            ),
          );
        },
      ).toList(),
      selected: {LocaleManager.languageCode.value},
      multiSelectionEnabled: false,
      onSelectionChanged: (Set<String> newSelection) {
        if (newSelection.first == showOtherLocales) {
          showSelectLocaleDialog(context);
        } else {
          LocaleManager.languageCode.value = newSelection.first;
        }
      },
    );
  }
}