import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// Just a little helper - title of the widget [LocaleSwitch].
class TitleForLocaleSwitch extends StatelessWidget {
  const TitleForLocaleSwitch(
      {super.key,
      required this.child,
      this.title = 'Choose language:',
      this.titlePositionTop = true,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.padding = const EdgeInsets.all(8),
      this.titlePadding = const EdgeInsets.all(4),
      this.childSize});

  final Widget child;
  final Size? childSize;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;

  /// Title position,
  ///
  /// default `true` - on Top
  /// use `false` to show at Left side
  final bool titlePositionTop;
  final EdgeInsets titlePadding;
  final String? title;

  @override
  Widget build(BuildContext context) {
    double? width;
    if (child is LocaleSwitcher) {
      width = (child as LocaleSwitcher).width;
      if (childSize == null && width == null) {
        if ((child as LocaleSwitcher).type == LocaleSwitcherType.menu) {
          width = 300;
        } else {
          final shown = min((child as LocaleSwitcher).numberOfShown,
              LocaleSwitcher.supportedLocaleNames.length);
          width = shown * 2.5 * 48;
          width += (child as LocaleSwitcher).showOsLocale ? 48 : 0;
        }
      }
    }

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            if (titlePositionTop)
              Padding(
                padding: titlePadding,
                child: Center(child: Text(title ?? '')),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!titlePositionTop)
                  Padding(
                    padding: titlePadding,
                    child: Center(child: Text(title ?? '')),
                  ),
                SizedBox(
                    width: childSize?.width ?? width,
                    height: childSize?.height ?? 48,
                    child: child),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
