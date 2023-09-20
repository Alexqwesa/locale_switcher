import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

const showOtherLocales = 'show_other_locales';

enum _Switcher {
  toggle,
  menu,
  custom,
}

typedef LocaleSwitchBuilder = Widget Function(List<String>);

/// A Widget to switch locale of App.
///
/// Use either: [LocaleSwitcher.toggle] or [LocaleSwitcher.menu] or [LocaleSwitcher.custom]
class LocaleSwitcher extends StatelessWidget {
  /// A text describing switcher
  ///
  /// default: 'Choose the language:'
  /// pass null if not needed.
  final String? title;

  /// Title position,
  ///
  /// default `true` - on Top
  /// use `false` to show at Left side
  final bool titlePositionTop;

  /// Number of shown flags
  final int numberOfShown;

  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;
  final EdgeInsets titlePadding;

  final _Switcher _type;

  /// Show option to use language of OS.
  final bool showOsLocale;

  /// Create you own locale switcher widget:
  ///
  /// Example:
  /// ```dart
  /// LocaleSwitcher.custom(
  ///   builder: (locales) {
  ///     return AnimatedToggleSwitch<String>.rolling(
  ///       current: LocaleManager.realLocaleNotifier.value,
  ///       values: locales,
  ///       loading: false,
  ///       onChanged: (langCode) async {
  ///         if (langCode == showOtherLocales) {
  ///           showSelectLocaleDialog(context);
  ///         } else {
  ///           LocaleManager.realLocaleNotifier.value = langCode;
  ///         }
  ///       },
  ///       iconBuilder: getIconForLanguage,
  ///     );
  ///   })
  /// ```
  final LocaleSwitchBuilder? builder;

  /// A Widget to switch locale of App.
  const LocaleSwitcher._({
    super.key,
    this.showOsLocale = true,
    this.title = 'Choose language:',
    this.numberOfShown = 4,
    this.titlePositionTop = true,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.padding = const EdgeInsets.all(8),
    this.titlePadding = const EdgeInsets.all(4),
    type = _Switcher.toggle,
    this.builder,
  }) : _type = type;

  /// A Widget to switch locale of App with [ToggleLanguageSwitch].
  factory LocaleSwitcher.toggle({
    Key? key,
    String? title = 'Choose language:',
    int numberOfShown = 4,
    bool showOsLocale = true,
    bool titlePositionTop = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
    EdgeInsets padding = const EdgeInsets.all(8),
    EdgeInsets titlePadding = const EdgeInsets.all(4),
  }) {
    return LocaleSwitcher._(
      key: key,
      title: title,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      titlePositionTop: titlePositionTop,
      crossAxisAlignment: crossAxisAlignment,
      padding: padding,
      titlePadding: titlePadding,
      type: _Switcher.toggle,
    );
  }

  /// A Widget to switch locale of App with [DropDownMenuLanguageSwitch]
  factory LocaleSwitcher.menu({
    Key? key,
    String? title = 'Choose language:',
    int numberOfShown = 200,
    bool showOsLocale = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return LocaleSwitcher._(
      key: key,
      title: title,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      crossAxisAlignment: crossAxisAlignment,
      padding: padding,
      type: _Switcher.menu,
    );
  }

  /// A Widget to switch locale of App with your own widget:
  ///
  ///
  /// Example:
  /// ```dart
  /// LocaleSwitcher.custom(
  ///   builder: (locales) {
  ///     return AnimatedToggleSwitch<String>.rolling(
  ///       current: LocaleManager.realLocaleNotifier.value,
  ///       values: locales,
  ///       loading: false,
  ///       onChanged: (langCode) async {
  ///         if (langCode == showOtherLocales) {
  ///           showSelectLocaleDialog(context);
  ///         } else {
  ///           LocaleManager.realLocaleNotifier.value = langCode;
  ///         }
  ///       },
  ///       iconBuilder: getIconForLanguage,
  ///     );
  ///   })
  /// ```
  factory LocaleSwitcher.custom({
    Key? key,
    required LocaleSwitchBuilder builder,
    int numberOfShown = 200,
    bool showOsLocale = true,
  }) {
    return LocaleSwitcher._(
        key: key,
        title: null,
        showOsLocale: showOsLocale,
        numberOfShown: numberOfShown,
        type: _Switcher.custom,
        builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    // Prepare list of languageCodes where systemLocale is first and length == numberOfShown
    // final systemLocaleExist = (LocaleStore.supportedLocales ?? []).where(
    //   (element) => element == WidgetsBinding.instance.platformDispatcher.locale,
    // );
    final staticLocales = <String>[
      if (showOsLocale) LocaleStore.systemLocale,
      // if (systemLocaleExist.isNotEmpty) systemLocaleExist.first.languageCode,
      ...(LocaleStore.supportedLocales ?? [])
          // .where((element) =>
          //     element != WidgetsBinding.instance.platformDispatcher.locale)
          .take(numberOfShown) // chose most used
          .map((e) => e.languageCode),
    ];

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (_type == _Switcher.toggle && titlePositionTop)
            Padding(
              padding: titlePadding,
              child: Center(child: Text(title ?? '')),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_type == _Switcher.toggle && !titlePositionTop)
                Padding(
                  padding: titlePadding,
                  child: Center(child: Text(title ?? '')),
                ),
              ValueListenableBuilder(
                valueListenable: LocaleStore.realLocaleNotifier,
                builder: (BuildContext context, value, Widget? child) {
                  var locales = [...staticLocales];
                  if (!locales.contains(LocaleStore.realLocaleNotifier.value)) {
                    locales.last = LocaleStore.realLocaleNotifier.value;
                  }
                  if ((LocaleStore.supportedLocales?.length ?? 0) >
                      numberOfShown) {
                    locales.add(showOtherLocales);
                  }

                  return switch (_type) {
                    _Switcher.toggle => Expanded(
                        child: ToggleLanguageSwitch(locales: locales),
                      ),
                    _Switcher.menu => DropDownMenuLanguageSwitch(
                        locales: locales, title: title),
                    _Switcher.custom => builder!(locales),
                  };
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DropDownMenuLanguageSwitch extends StatelessWidget {
  final String? title;

  const DropDownMenuLanguageSwitch({
    super.key,
    required this.locales,
    this.title,
  });

  final List<String> locales;

  @override
  Widget build(BuildContext context) {
    final localeEntries = locales
        .map<DropdownMenuEntry<String>>(
          (e) => DropdownMenuEntry<String>(
            value: e,
            label: LocaleStore.languageToCountry[e]?[1] ?? e,
            leadingIcon:
                (LocaleStore.languageToCountry[e] ?? const []).length > 2
                    ? LocaleStore.languageToCountry[e]![2] ??
                        getIconForLanguage(e, null, 40)
                    : getIconForLanguage(e, null, 40),
          ),
        )
        .toList();

    return DropdownMenu<String>(
      initialSelection: LocaleStore.realLocaleNotifier.value,
      leadingIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            getIconForLanguage(LocaleStore.realLocaleNotifier.value, null, 32),
      ),
      // controller: colorController,
      label: const Text('Language'),
      dropdownMenuEntries: localeEntries,
      onSelected: (String? langCode) {
        if (langCode != null) {
          if (langCode == showOtherLocales) {
            showSelectLocaleDialog(context);
          } else {
            LocaleManager.realLocaleNotifier.value = langCode;
          }
        }
      },
      enableSearch: true,
    );
  }
}

class ToggleLanguageSwitch extends StatelessWidget {
  const ToggleLanguageSwitch({
    super.key,
    required this.locales,
  });

  final List<String> locales;

  @override
  Widget build(BuildContext context) {
    return AnimatedToggleSwitch<String>.rolling(
      allowUnlistedValues: true,
      current: LocaleManager.realLocaleNotifier.value,
      values: locales,
      loading: false,
      onChanged: (langCode) async {
        if (langCode == showOtherLocales) {
          showSelectLocaleDialog(context);
        } else {
          LocaleManager.realLocaleNotifier.value = langCode;
        }
      },
      style: const ToggleStyle(backgroundColor: Colors.black12),
      iconBuilder: getIconForLanguage,
    );
  }
}
