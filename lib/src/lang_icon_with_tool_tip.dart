import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// Just icon, no action assigned.
class LangIconWithToolTip extends StatelessWidget {
  final String toolTipPrefix;

  final double? radius;

  const LangIconWithToolTip({
    super.key,
    required this.langCode,
    this.toolTipPrefix = '',
    this.radius,
  });

  final String langCode;

  @override
  Widget build(BuildContext context) {
    final lang = LocaleStore.languageToCountry[langCode]!; // todo: use ??
    return FittedBox(
      child: Tooltip(
        message: toolTipPrefix + lang[1],
        child: lang.length <= 2
            ? CircleFlag(
                (lang[0] as String).toLowerCase(),
                size: radius ?? 48,
              )
            : ClipOval(child: lang[2]),
      ),
    );
  }
}
