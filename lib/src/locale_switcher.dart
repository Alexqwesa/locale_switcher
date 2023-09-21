import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/locale_switch_sub_widgets/drop_down_menu_language_switch.dart';
import 'package:locale_switcher/src/locale_switch_sub_widgets/grid_of_languages.dart';
import 'package:locale_switcher/src/locale_switch_sub_widgets/toggle_language_switch.dart';

const showOtherLocales = 'show_other_locales';

enum _Switcher {
  toggle,
  menu,
  custom,
  grid,
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

  /// Only for LocaleSwitcher.grid constructor
  final SliverGridDelegate? gridDelegate;

  final Function(BuildContext)? additionalCallBack;

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
    this.gridDelegate,
    this.additionalCallBack,
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

  /// A Widget to switch locale of App with [DropDownMenuLanguageSwitch]
  factory LocaleSwitcher.grid({
    Key? key,
    int numberOfShown = 200,
    bool showOsLocale = true,
    SliverGridDelegate? gridDelegate,
    Function(BuildContext)? additionalCallBack,
  }) {
    return LocaleSwitcher._(
      key: key,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      type: _Switcher.grid,
      gridDelegate: gridDelegate,
      additionalCallBack: additionalCallBack,
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
// todo: move to initState ?
    if (LocaleStore.supportedLocales.isEmpty) {
// assume it was not inited
      final child = context.findAncestorWidgetOfExactType<MaterialApp>() ??
          context.findAncestorWidgetOfExactType<CupertinoApp>();
      if (child != null) {
        if (child.runtimeType == MaterialApp) {
          final supportedLocales =
              (child as MaterialApp).supportedLocales.toList(growable: false);
          if (supportedLocales.isEmpty) {
            throw UnsupportedError(
                'MaterialApp should have initialized supportedLocales parameter');
          }
          LocaleStore.setSupportedLocales(supportedLocales);
        } else if (child.runtimeType == CupertinoApp) {
          final supportedLocales =
              (child as CupertinoApp).supportedLocales.toList(growable: false);
          if (supportedLocales.isEmpty) {
            throw UnsupportedError(
                'CupertinoApp should have initialized supportedLocales parameter');
          }
          LocaleStore.setSupportedLocales(supportedLocales);
        }
      }
    }

// Prepare list of languageCodes where systemLocale is first and length == numberOfShown
// final systemLocaleExist = (LocaleStore.supportedLocales ?? []).where(
//   (element) => element == WidgetsBinding.instance.platformDispatcher.locale,
// );
    final staticLocales = <String>[
      if (showOsLocale) LocaleStore.systemLocale,
// if (systemLocaleExist.isNotEmpty) systemLocaleExist.first.languageCode,
      ...LocaleStore.supportedLocales
// .where((element) =>
//     element != WidgetsBinding.instance.platformDispatcher.locale)
          .take(numberOfShown) // chose most used
          .map((e) => e.languageCode),
    ];

    return ValueListenableBuilder(
      valueListenable: LocaleStore.realLocaleNotifier,
      builder: (BuildContext context, value, Widget? child) {
        var locales = [...staticLocales];
        if (!locales.contains(LocaleStore.realLocaleNotifier.value)) {
          locales.last = LocaleStore.realLocaleNotifier.value;
        }
        if (LocaleStore.supportedLocales.length > numberOfShown) {
          locales.add(showOtherLocales);
        }

        return switch (_type) {
          _Switcher.toggle => ToggleLanguageSwitch(
              padding: padding,
              crossAxisAlignment: crossAxisAlignment,
              titlePositionTop: titlePositionTop,
              titlePadding: titlePadding,
              title: title,
              locales: locales,
            ),
          _Switcher.menu =>
            DropDownMenuLanguageSwitch(locales: locales, title: title),
          _Switcher.custom => builder!(locales),
          // TODO: Handle this case.
          _Switcher.grid => GridOfLanguages(
              gridDelegate: gridDelegate,
              additionalCallBack: additionalCallBack,
            ),
        };
      },
    );
  }
}
