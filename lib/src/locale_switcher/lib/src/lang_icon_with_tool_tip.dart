import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
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
  /// (assigned to language in [LocaleManager])
  final Widget? child;

  /// An entry of [LocaleNameFlagList].
  final LocaleNameFlag? localeNameFlag;

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
    final locCode = langCode ?? localeNameFlag?.name ?? '??';

    if (locCode == showOtherLocales) {
      return CurrentLocale.flagForOtherLocalesButton;
    }

    final lang = LocaleStore.languageToCountry[locCode] ??
        [locCode, 'Unknown language code: $locCode'];

    var nLetters = useNLettersInsteadOfIcon;
    if (nLetters == 0 &&
        Flags.instance[(lang[0] as String).toLowerCase()] == null) {
      nLetters = 2;
    }

    final Widget defaultChild = child ??
        (useNLettersInsteadOfIcon == 0 ? localeNameFlag?.flag : null) ??
        ((nLetters > 0 && locCode != LocaleStore.systemLocale)
            ? ClipOval(
                // text
                child: SizedBox(
                    width: radius ?? 48,
                    height: radius ?? 48,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: FittedBox(
                          child: Text(
                        locCode.toUpperCase(),
                        semanticsLabel: lang[1],
                      )),
                    )),
              )
            : lang.length <= 2 // i.e. no custom image
                ? CircleFlag(
                    Flags.instance[(lang[0] as String).toLowerCase()]!,
                    // ovalShape: false,
                    shape: shape,
                    size: radius ?? 48,
                  )
                : (shape != null)
                    ? ClipPath(
                        child: lang[2],
                        clipper: ShapeBorderClipper(
                          shape: shape!,
                          textDirection: Directionality.maybeOf(context),
                        ),
                      )
                    : lang[2]);

    return FittedBox(
      child: Tooltip(
          message: toolTipPrefix + lang[1],
          waitDuration: const Duration(milliseconds: 50),
          preferBelow: true,
          child: defaultChild),
    );
  }
}
