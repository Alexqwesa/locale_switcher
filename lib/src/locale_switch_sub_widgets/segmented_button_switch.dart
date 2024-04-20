import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final SupportedLocaleNames locales;
  final LocaleSwitcher widget;
  final ItemBuilder itemBuilder;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    required this.widget,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final radius = widget.iconRadius;
    final setLocaleCallBack = widget.setLocaleCallBack;
    final width = widget.width;

    final height = radius;
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
            padding: EdgeInsets.all(inSet),
            child: SizedBox(
                height: widget.iconRadius,
                child: FittedBox(fit: BoxFit.fitHeight, child: itemBuilder(e))),
          ),
        );
      },
    ).toList();
  }
}
