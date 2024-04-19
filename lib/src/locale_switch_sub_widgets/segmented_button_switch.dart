import 'dart:math';

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

  final ItemBuilder itemBuilder;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.radius,
    this.shape,
    this.setLocaleCallBack,
    this.useEmoji = false,
    this.width,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final height = (radius ?? (useEmoji ? 42 : 34));
    final segmentedButton = LayoutBuilder(
      builder: (context, constrains) {
        final scale = min(1, height / 32);
        final inSet = max(0.0, scale * (constrains.maxHeight - height) / 2);

        return SegmentedButton<LocaleName>(
          emptySelectionAllowed: false,
          showSelectedIcon: false,
          segments: segmentBuilder(inSet, height),
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

  segmentBuilder(double inSet, double height) {
    return locales.map<ButtonSegment<LocaleName>>(
      (e) {
        return ButtonSegment<LocaleName>(
          value: e,
          tooltip: e.language,
          label: Padding(
            padding:
                // e.name == systemLocale
                //     ? const EdgeInsets.all(0.0)
                //     :
                EdgeInsets.all(inSet),
            child: SizedBox(
                height: radius ?? 32,
                child: FittedBox(fit: BoxFit.fitHeight, child: itemBuilder(e))),
          ),
        );
      },
    ).toList();
  }
}
