import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_locale.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';
import 'package:locale_switcher/src/locale_store.dart';

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

  /// Analog [LangIconWithToolTip] but for Strings.
  const LangIconWithToolTip.forStringIconBuilder(
    this.langCode,
    bool _, {
    super.key,
    this.toolTipPrefix = '',
    this.radius,
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.child,
    this.localeNameFlag,
  });

  /// Can be used as tear-off inside [LocaleSwitcher.custom] for builders
  /// in classes like [AnimatedToggleSwitch](https://pub.dev/documentation/animated_toggle_switch/latest/animated_toggle_switch/AnimatedToggleSwitch-class.html).
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
  }) : assert(langCode != null || localeNameFlag != null);

  /// Have no effect if [localeNameFlag] is provided.
  final String? langCode;

  @override
  Widget build(BuildContext context) {
    final locCode = localeNameFlag?.name ?? langCode ?? '??';

    if (locCode == showOtherLocales) {
      return CurrentLocale.buttonFlagForOtherLocales;
    }
    final lang = LocaleStore.languageToCountry[locCode] ??
        <String>[locCode, 'Unknown language code: $locCode'];

    var flag = child;
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
