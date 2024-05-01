import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// Just a little helper - title for the widget [LocaleSwitch].
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

  /// A widget to switch locale.
  final Widget child;

  /// A size of child.
  final Size? childSize;

  /// Default padding of whole widget.
  ///
  /// Default: EdgeInsets.all(8)
  final EdgeInsets padding;

  /// Alignment of column.
  ///
  /// Default: CrossAxisAlignment.center
  final CrossAxisAlignment crossAxisAlignment;

  /// Title position,
  ///
  /// default `true` - on Top
  /// use `false` to show at Left side
  final bool titlePositionTop;

  /// Padding of title.
  ///
  /// Default: EdgeInsets.all(4)
  final EdgeInsets titlePadding;

  /// Title text.
  ///
  /// Default: 'Choose language:'
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

    return LayoutBuilder(builder: (context, constrains) {
      if ((width ?? 0) > constrains.maxWidth) {
        width = constrains.maxWidth - padding.left - padding.right;
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
    });
  }
}
