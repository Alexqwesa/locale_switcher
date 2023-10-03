import 'package:flutter/material.dart';

import 'generated/asset_strings.dart';
import 'locale_store.dart';
import 'locale_switcher.dart';

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
  /// If null: will be shown flag of country assigned to language or ...
  final Widget? child;

  /// Can be used as tear-off inside [LocaleSwitcher.custom] for builders in classes like [AnimatedToggleSwitch](https://pub.dev/documentation/animated_toggle_switch/latest/animated_toggle_switch/AnimatedToggleSwitch-class.html).
  const LangIconWithToolTip.forIconBuilder(
    this.localeCode,
    bool _, {
    super.key,
    this.toolTipPrefix = '',
    this.radius,
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.child,
  });

  const LangIconWithToolTip({
    super.key,
    required this.localeCode,
    this.toolTipPrefix = '',
    this.radius,
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.child,
  });

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    if (localeCode == showOtherLocales) {
      return LocaleSwitcher.iconButton(
        useStaticIcon:
            ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
                ? LocaleStore.languageToCountry[showOtherLocales]![2]
                : const Icon(Icons.expand_more),
      );
    }

    final lang = LocaleStore.languageToCountry[localeCode] ??
        [localeCode, 'Unknown language code: $localeCode'];

    var nLetters = useNLettersInsteadOfIcon;
    if (nLetters == 0 &&
        Flags.instance[(lang[0] as String).toLowerCase()] == null) {
      nLetters = 2;
    }

    final Widget defaultChild = child ??
        ((nLetters > 0 && localeCode != LocaleStore.systemLocale)
            ? ClipOval(
                // text
                child: SizedBox(
                    width: radius ?? 48,
                    height: radius ?? 48,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: FittedBox(
                          child: Text(
                        localeCode.toUpperCase(),
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
