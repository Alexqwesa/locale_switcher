import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';

/// Icon representing the language.
///
/// For special values like [showOtherLocales] it will provide custom widget.
///
/// You can use [LocaleManager.reassignFlags] to change global defaults.
/// or just provide your own [child] widget.
class LangIconWithToolTip extends StatelessWidget {
  final String toolTipPrefix;

  final double? radius;

  /// If zero - used Icon, otherwise first N letters of language code.
  ///
  /// Have no effect if [child] is not null.
  /// Can not be used with [useEmoji].
  final int useNLettersInsteadOfIcon;

  /// Clip the flag by [ShapeBorder], default: [CircleBorder].
  ///
  /// If null, return square flag.
  final ShapeBorder? shape;

  /// OPTIONAL: your custom widget here,
  ///
  /// If null: will be shown either flag from [localeNameFlag] or flag of country
  /// (assigned to language in [LocaleManager].reassignFlags)
  final Widget? child;

  /// An entry of [SupportedLocaleNames].
  final LocaleName? localeNameFlag;

  /// Use Emoji instead of svg flag.
  ///
  /// Have no effect if [child] is not null
  /// Can not be used with [useNLettersInsteadOfIcon]..
  final bool useEmoji;

  /// Just a shortcut to use as tear-off in builders of
  /// widgets that generate lists of elements.
  ///
  /// See example for [LocaleSwitcher.custom].
  const LangIconWithToolTip.forIconBuilder(
    this.localeNameFlag,
    bool _, {
    super.key,
    this.toolTipPrefix = '',
    this.radius,
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.child,
    this.langCode,
    this.useEmoji = false,
  });

  const LangIconWithToolTip({
    super.key,
    this.langCode,
    this.toolTipPrefix = '',
    this.radius,
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.child,
    this.localeNameFlag,
    this.useEmoji = false,
  })  : assert(langCode != null || localeNameFlag != null),
        assert(!useEmoji || (useEmoji == (useNLettersInsteadOfIcon == 0)));

  /// Have no effect if [localeNameFlag] is provided.
  final String? langCode;

  @override
  Widget build(BuildContext context) {
    final locCode = localeNameFlag?.name ?? langCode ?? '??';

    if (locCode == showOtherLocales) {
      return SizedBox(
          height: (radius ?? 28) * 0.7,
          child: FittedBox(child: SupportedLocaleNames.flagForOtherLocales));
    }
    final lang = languageToCountry[locCode] ??
        <String>[locCode, 'Unknown language code: $locCode'];

    var flag = child;
    if (useEmoji && locCode != systemLocale) {
      final emoji = localeNameFlag?.locale?.emoji;
      flag ??= (emoji != null)
          ? SizedBox(height: radius, child: FittedBox(child: Text(emoji)))
          : null;
    }
    flag ??= localeNameFlag?.flag != null
        ? CircleFlag(
            shape: shape, size: radius ?? 48, child: localeNameFlag?.flag!)
        : null;
    flag ??= Flags.instance[(lang[0]).toLowerCase()] != null
        ? CircleFlag(
            shape: shape,
            size: radius ?? 48,
            child: Flags.instance[(lang[0]).toLowerCase()]!.svg)
        : null;
    if (locCode != systemLocale && locCode != showOtherLocales) {
      if (flag == null || useNLettersInsteadOfIcon > 0) {
        flag = child ??
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: FittedBox(
                  child: Text(
                locCode.toUpperCase(),
                semanticsLabel: localeNameFlag?.language ?? lang[1],
              )),
            );
      }
    }

    var nLetters = useNLettersInsteadOfIcon;
    if (nLetters == 0 &&
        Flags.instance[(lang[0] as String).toLowerCase()] == null) {
      nLetters = 2;
    }

    final fittedIcon = FittedBox(
      child: Tooltip(
          message: toolTipPrefix + (localeNameFlag?.language ?? lang[1]),
          waitDuration: const Duration(milliseconds: 50),
          preferBelow: true,
          child: flag ?? const Icon(Icons.error_outline_rounded)),
    );

    return (radius != null)
        ? SizedBox(
            width: radius,
            height: radius,
            child: fittedIcon,
          )
        : fittedIcon;
  }
}
