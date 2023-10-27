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
    this.radius,
    this.shape,
    this.setLocaleCallBack,
    this.useEmoji = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final height = (radius ?? (useEmoji ? 42 : 34));
    final segmentedButton = LayoutBuilder(
      builder: (context, constrains) {
        final inSet = (constrains.maxHeight - height) / 2;
        double scale = 1;
        if (constrains.maxWidth < (width ?? 0)) {
          scale = constrains.maxWidth / width! / 3;
        } else if (constrains.maxWidth < (height * 3 * locales.length)) {
          scale = constrains.maxWidth / (height * 3 * locales.length) / 3;
        }

        return SegmentedButton<LocaleName>(
          emptySelectionAllowed: false,
          showSelectedIcon: false,
          segments: locales.map<ButtonSegment<LocaleName>>(
            (e) {
              return ButtonSegment<LocaleName>(
                value: e,
                tooltip: e.language,
                label: Padding(
                  padding:
                      // e.name == systemLocale
                      //     ? const EdgeInsets.all(0.0)
                      //     :
                      EdgeInsets.fromLTRB(
                          inSet * scale, inSet, inSet * scale, inSet),
                  child: LangIconWithToolTip(
                    useEmoji: useEmoji,
                    localeNameFlag: e,
                    radius: e.name == systemLocale ? (radius ?? 36) : height,
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
