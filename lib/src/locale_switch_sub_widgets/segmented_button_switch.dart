import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final SupportedLocaleNames locales;
  final int useNLettersInsteadOfIcon;

  final double? radius;

  final ShapeBorder? shape;

  final Function(BuildContext)? setLocaleCallBack;

  final bool useEmoji;

  final double? width;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.radius = 32,
    this.shape,
    this.setLocaleCallBack,
    this.useEmoji = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final segmentedButton = LayoutBuilder(
      builder: (context, constrains) {
        double scale = 1;
        if (constrains.maxWidth < (width ?? 0)) {
          scale = constrains.maxWidth / width! / 3;
        } else if (constrains.maxWidth <
            ((radius ?? 32) * 3 * locales.length)) {
          scale =
              constrains.maxWidth / ((radius ?? 32) * 3 * locales.length) / 3;
        }

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
                      EdgeInsets.fromLTRB(
                    8 * scale,
                    8,
                    8 * scale,
                    8,
                  ),
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
              showSelectLocaleDialog(context,
                  setLocaleCallBack: setLocaleCallBack);
            } else {
              LocaleSwitcher.current = newSelection.first;
              setLocaleCallBack?.call(context);
            }
          },
        );
      },
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: segmentedButton,
      );
    } else {
      return segmentedButton;
    }
  }
}
