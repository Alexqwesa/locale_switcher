import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// Just icon, no action assigned.
class LangIconWithToolTip extends StatelessWidget {
  final String toolTipPrefix;

  final double? radius;

  final int useNLettersInsteadOfIcon;

  final TextStyle? textStyle;

  const LangIconWithToolTip({
    super.key,
    required this.langCode,
    this.toolTipPrefix = '',
    this.radius,
    this.useNLettersInsteadOfIcon = 0,
    this.textStyle,
  });

  final String langCode;

  @override
  Widget build(BuildContext context) {
    final lang = LocaleStore.languageToCountry[langCode]!; // todo: use ??

    return FittedBox(
      child:
          (useNLettersInsteadOfIcon > 0 && langCode != LocaleStore.systemLocale)
              ? ClipOval(
                  child: SizedBox(
                      width: radius ?? 48,
                      height: radius ?? 48,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: FittedBox(
                            child: Text(
                          langCode.toUpperCase(),
                          semanticsLabel: lang[1],
                          style: textStyle,
                        )),
                      )),
                )
              : Tooltip(
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
