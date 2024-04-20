import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';

typedef ItemBuilder = LangIconWithToolTip Function(LocaleName e);

/// How to display Locales for countries with multiple languages:
///
/// See also:
/// - [countriesWithMulti] - list of countries with multiple languages,
/// - [popularInCountry] - for [MultiLangCountries.auto],
/// - [languageToCountry] - list of all languages.
enum MultiLangCountries {
  /// Will be displayed big flag, and small language code.
  flagWithSmallLang,

  /// The same as [flagWithSmallLang], but for most popular Language - just flag.
  auto,

  /// Will be displayed big Language code, and small flag.
  langWithSmallFlag,

  /// Only show language code(text).
  onlyLanguage,

  /// Only show Flag.
  onlyFlag,

  /// Will be displayed big Language code, and small country code.
  asBigLittle
}

/// Icon representing the language (with tooltip).
///
/// It will search icon, in this order:
/// - in [Locale.flag],
/// - in [languageToCountry],
/// - or if [useEmoji] will search emoji,
/// - or if [useNLettersInsteadOfIcon] will just show letters.
///
/// For special values like [showOtherLocales] and [systemLocale]
/// there are exist special values in [languageToCountry] map.
///
/// You can use [LocaleManager.reassignFlags] or [languageToCountry] to change global defaults.
///
/// Or just provide your own [child] widget.
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
  /// If null, it will search icon:
  /// - in [Locale.flag],
  /// - in [languageToCountry],
  /// - or if [useEmoji] will search emoji,
  /// - or if [useNLettersInsteadOfIcon] will just show letters.
  final Widget? child;

  /// An entry of [SupportedLocaleNames].
  final LocaleName? localeNameFlag;

  /// Use Emoji instead of svg flag.
  ///
  /// Have no effect if [child] is not null
  /// Can not be used with [useNLettersInsteadOfIcon]..
  final bool useEmoji;

  /// How to display Locales for countries with multiple languages:
  ///
  /// see [MultiLangCountries].
  final MultiLangCountries multiLangCountries;

  /// Force all Locales to be displayed as [MultiLangCountries].
  final bool forceMulti;

  /// Padding for special icons ([systemLocale], [showOtherLocales]).
  final double specialFlagsPadding;

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
    this.multiLangCountries = MultiLangCountries.auto,
    this.forceMulti = false,
    this.specialFlagsPadding = 3.5,
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
    this.multiLangCountries = MultiLangCountries.auto,
    this.forceMulti = false,
    this.specialFlagsPadding = 3.5,
  })  : assert(langCode != null || localeNameFlag != null),
        assert(!useEmoji || (useEmoji == (useNLettersInsteadOfIcon == 0)));

  /// Have no effect if [localeNameFlag] is provided.
  final String? langCode;

  @override
  String toStringShort() {
    return "LangIcon: $langCode | ${localeNameFlag?.name} | ${localeNameFlag?.locale} ";
  }

  @override
  Widget build(BuildContext context) {
    final locCode = localeNameFlag?.name ?? langCode ?? '??';
    final lang = languageToCountry[locCode] ??
        <String>[locCode, 'Unknown language code: $locCode'];

    final fittedIcon = Tooltip(
      message: toolTipPrefix + (localeNameFlag?.language ?? lang[1]),
      waitDuration: const Duration(milliseconds: 50),
      preferBelow: true,
      child: switch (locCode) {
        systemLocale => Padding(
            padding: EdgeInsets.all(specialFlagsPadding),
            child: FittedBox(
              child:
                  languageToCountry[locCode]?[2] ?? const Icon(Icons.language),
            ),
          ),
        showOtherLocales => Padding(
            padding: EdgeInsets.all(specialFlagsPadding),
            child: FittedBox(child: SupportedLocaleNames.flagForOtherLocales),
          ),
        _ => fittedFlag(getFlag(), locCode, lang),
      },
    );

    return (radius != null)
        ? SizedBox(
            width: radius,
            height: radius,
            child: fittedIcon,
          )
        : fittedIcon;
  }

  /// Get flag for this widget
  Widget? getFlag() {
    final locCode = localeNameFlag?.name ?? langCode ?? '??';
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

    if (flag == null || useNLettersInsteadOfIcon > 0) {
      flag = child ??
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: FittedBox(
                child: Text(
              (countriesWithMulti.containsKey(locCode))
                  ? locCode.split('_').first.toUpperCase()
                  : locCode.split('_').last.toUpperCase(),
              semanticsLabel: localeNameFlag?.language ?? lang[1],
            )),
          );
    }

    return flag;
  }

  /// Wrap flag with required widgets.
  ///
  /// also, here is logic for enum [MultiLangCountries].
  FittedBox fittedFlag(Widget? flag, String locCode, List lang) {
    const flagError = Icon(Icons.error_outline_rounded);

    // Simple case - country with one language
    if (!forceMulti && !countriesWithMulti.containsKey(locCode)) {
      return FittedBox(
        child: flag ?? flagError,
      );
    }

    // Country with many languages
    final language = locCode.split('_').first.toUpperCase();
    final country = lang.first.toLowerCase();
    final mlc = useNLettersInsteadOfIcon > 0
        ? MultiLangCountries.asBigLittle
        : multiLangCountries;

    return FittedBox(
      child: switch (mlc) {
        MultiLangCountries.auto when language == country =>
          flag ?? Text(language),
        MultiLangCountries.auto
            when language ==
                popularInCountry[country.toLowerCase()]?.toUpperCase() =>
          flag ?? Text(language),
        MultiLangCountries.auto when flag == null => DoubleFlag(
            radius: radius,
            wTop: Text(language),
            wDown: Text(country),
          ),
        MultiLangCountries.auto => DoubleFlag(
            radius: radius,
            wTop: flag!,
            wDown: Text(language),
          ),
        MultiLangCountries.flagWithSmallLang when flag != null => DoubleFlag(
            radius: radius,
            wTop: flag,
            wDown: Text(language),
          ),
        MultiLangCountries.flagWithSmallLang => Text(locCode),
        MultiLangCountries.langWithSmallFlag => DoubleFlag(
            radius: radius,
            wTop: Text(language),
            wDown: flag ?? Text(country),
          ),
        MultiLangCountries.asBigLittle when language.length >= 2 => DoubleFlag(
            radius: radius,
            wTop: Text(language),
            wDown: Text(country),
          ),
        MultiLangCountries.asBigLittle => Text(language),
        MultiLangCountries.onlyLanguage => Text(language),
        // TODO: Handle this case.
        MultiLangCountries.onlyFlag => FittedBox(
            child: Tooltip(
              message: toolTipPrefix + (localeNameFlag?.language ?? lang[1]),
              waitDuration: const Duration(milliseconds: 50),
              preferBelow: true,
              child: flag ?? flagError,
            ),
          ),
      },
    );
  }
}
