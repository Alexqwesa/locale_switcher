import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_name_flag_list.dart';
import 'package:locale_switcher/src/preference_repository.dart';

import 'locale_store.dart';
import 'locale_switch_sub_widgets/drop_down_menu_language_switch.dart';
import 'locale_switch_sub_widgets/grid_of_languages.dart';
import 'locale_switch_sub_widgets/segmented_button_switch.dart';
import 'locale_switch_sub_widgets/select_locale_button.dart';
import 'locale_switch_sub_widgets/title_of_lang_switch.dart';

const showOtherLocales = 'show_other_locales_button';

enum _Switcher {
  menu,
  custom,
  grid,
  iconButton,
  segmentedButton,
}

typedef LocaleSwitchBuilder = Widget Function(LocaleNameFlagList, BuildContext);

/// A Widget to switch locale of App.
///
/// Use either: [LocaleSwitcher.toggle] or [LocaleSwitcher.menu] or [LocaleSwitcher.custom]
class LocaleSwitcher extends StatefulWidget {
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
  ///       current: LocaleManager.languageCode.value,
  ///       values: locales,
  ///       loading: false,
  ///       onChanged: (langCode) {
  ///         if (langCode == showOtherLocales) {
  ///           showSelectLocaleDialog(context);
  ///         } else {
  ///           LocaleManager.languageCode.value = langCode;
  ///         }
  ///       },
  ///       iconBuilder: LangIconWithToolTip.forIconBuilder,
  ///     );
  ///   })
  /// ```
  final LocaleSwitchBuilder? builder;

  /// Only for [LocaleSwitcher.grid] constructor
  final SliverGridDelegate? gridDelegate;

  /// Only for [LocaleSwitcher.grid] constructor
  final Function(BuildContext)? additionalCallBack;

  /// Only for [LocaleSwitcher.iconButton] - use static icon.
  final Icon? useStaticIcon;

  /// Only for [LocaleSwitcher.iconButton].
  final String? toolTipPrefix;

  /// Only for [LocaleSwitcher.iconButton].
  final double? iconRadius;

  /// If null or 0 - used Icon, otherwise first N letters of language code.
  final int useNLettersInsteadOfIcon;

  /// Show leading icon in drop down menu
  final bool showLeading;

  /// Shape of flags.
  ///
  /// Default: [CircleBorder] for all except [LocaleSwitcher.segmentedButton].
  ///
  /// Null for square.
  final ShapeBorder? shape;

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
    type = _Switcher.segmentedButton,
    this.builder,
    this.gridDelegate,
    this.additionalCallBack,
    this.toolTipPrefix,
    this.useStaticIcon,
    this.iconRadius,
    this.useNLettersInsteadOfIcon = 0,
    this.showLeading = true,
    this.shape = const CircleBorder(eccentricity: 0),
  }) : _type = type;

  /// A Widget to switch locale of App with [DropDownMenu](https://api.flutter.dev/flutter/material/DropdownMenu-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/), [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart).
  factory LocaleSwitcher.menu({
    GlobalKey? key,
    String? title = 'Choose language:',
    int numberOfShown = 200,
    bool showOsLocale = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    EdgeInsets padding = const EdgeInsets.all(8),
    int? useNLettersInsteadOfIcon,
    bool showLeading = true,
    ShapeBorder? shape = const CircleBorder(eccentricity: 0),
  }) {
    return LocaleSwitcher._(
      key: key ?? GlobalKey(),
      title: title,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      crossAxisAlignment: crossAxisAlignment,
      padding: padding,
      type: _Switcher.menu,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      showLeading: showLeading,
      shape: shape,
    );
  }

  /// A Widget to switch locale of App with [GridView](https://api.flutter.dev/flutter/widgets/GridView-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/),
  /// [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart) - click on icon in AppBar to see this widget.
  factory LocaleSwitcher.grid({
    GlobalKey? key,
    int numberOfShown = 200,
    bool showOsLocale = true,
    SliverGridDelegate? gridDelegate,
    Function(BuildContext)? additionalCallBack,
    int? useNLettersInsteadOfIcon,
    ShapeBorder? shape = const CircleBorder(eccentricity: 0),
  }) {
    return LocaleSwitcher._(
      key: key ?? GlobalKey(),
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      type: _Switcher.grid,
      gridDelegate: gridDelegate,
      additionalCallBack: additionalCallBack,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      shape: shape,
    );
  }

  /// A Widget to switch locale of App with your own widget:
  ///
  /// Example:
  /// ```dart
  /// LocaleSwitcher.custom(
  ///   builder: (locales) {
  ///     return AnimatedToggleSwitch<String>.rolling(
  ///       current: LocaleManager.languageCode.value,
  ///       values: locales,
  ///       loading: false,
  ///       onChanged: (langCode) {
  ///         if (langCode == showOtherLocales) {
  ///           showSelectLocaleDialog(context);
  ///         } else {
  ///           LocaleManager.languageCode.value = langCode;
  ///         }
  ///       },
  ///       iconBuilder: LangIconWithToolTip.forIconBuilder,
  ///     );
  ///   })
  /// ```
  factory LocaleSwitcher.custom({
    GlobalKey? key,
    required LocaleSwitchBuilder builder,
    int numberOfShown = 4,
    bool showOsLocale = true,
  }) {
    return LocaleSwitcher._(
      key: key ?? GlobalKey(),
      title: null,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      type: _Switcher.custom,
      builder: builder,
    );
  }

  /// A Widget to switch locale of App with [IconButton](https://api.flutter.dev/flutter/material/IconButton-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/),
  /// [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart) - it is an icon in AppBar.
  ///
  /// In popup window will be displayed [LocaleSwitcher.grid].
  factory LocaleSwitcher.iconButton({
    GlobalKey? key,
    String? toolTipPrefix = 'Current language: ',
    String? title = 'Select language: ',
    Icon? useStaticIcon,
    double? iconRadius = 32,
    // required LocaleSwitchBuilder builder,
    int numberOfShown = 200,
    bool showOsLocale = true,
    int? useNLettersInsteadOfIcon,
    ShapeBorder? shape = const CircleBorder(eccentricity: 0),
  }) {
    return LocaleSwitcher._(
      key: key ?? GlobalKey(),
      title: title,
      toolTipPrefix: toolTipPrefix,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      useStaticIcon: useStaticIcon,
      iconRadius: iconRadius,
      type: _Switcher.iconButton,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      shape: shape,
      // builder: builder,
    );
  }

  /// A Widget to switch locale of App with [SegmentedButton](https://api.flutter.dev/flutter/material/SegmentedButton-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/),
  /// [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart) .
  factory LocaleSwitcher.segmentedButton({
    GlobalKey? key,
    // double? iconRadius = 32,
    // required LocaleSwitchBuilder builder,
    String? title = 'Choose language:',
    int numberOfShown = 4,
    bool showOsLocale = true,
    bool titlePositionTop = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
    EdgeInsets padding = const EdgeInsets.all(8),
    EdgeInsets titlePadding = const EdgeInsets.all(4),
    int? useNLettersInsteadOfIcon,
    ShapeBorder? shape,
  }) {
    return LocaleSwitcher._(
      key: key ?? GlobalKey(),
      title: title,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      titlePositionTop: titlePositionTop,
      crossAxisAlignment: crossAxisAlignment,
      padding: padding,
      titlePadding: titlePadding,
      type: _Switcher.segmentedButton,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      shape: shape,
      // builder: builder,
    );
  }

  @override
  State<LocaleSwitcher> createState() => LocaleSwitcherState();
}

class LocaleSwitcherState extends State<LocaleSwitcher> {
  @override
  void initState() {
    super.initState();

    PreferenceRepository.sendGlobalKeyToRepository(widget.key as GlobalKey);
    // check: is it inited?
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
  }

  /// Optional, should be used only for [MaterialApp].supportedLocales
  ///
  /// will speed up [LocaleSwitcher]
  // or readSupportedLocales
  // add localizationCallback (with/withOutContext)
  static List<Locale> readLocales(List<Locale> supportedLocales) {
    if (supportedLocales.isEmpty) {
      supportedLocales = const [Locale('en')];
    }

    if (!identical(LocaleStore.supportedLocales, supportedLocales)) {
      LocaleStore.setSupportedLocales(supportedLocales);
    }

    return supportedLocales;
  }

  @override
  Widget build(BuildContext context) {
    final staticLocales = LocaleNameFlagList.fromEntries(
      LocaleStore.localeNameFlags.entries
          .skip(1) // first is system locale
          .take(widget.numberOfShown) // chose most used
      ,
      addOsLocale: widget.showOsLocale,
    );

    return ValueListenableBuilder(
      valueListenable: LocaleStore.languageCode,
      builder: (BuildContext context, value, Widget? child) {
        var locales = LocaleNameFlagList.fromEntries(staticLocales.entries);
        if (!locales.names.contains(LocaleStore.languageCode.value)) {
          locales.replaceLast(LocaleStore.languageCode.value);
        }
        if (LocaleStore.supportedLocales.length > widget.numberOfShown) {
          locales.addName(showOtherLocales);
        }
        // todo: add 0.5 second delayed check of app locale ?

        return switch (widget._type) {
          _Switcher.custom => widget.builder!(locales, context),
          _Switcher.menu => DropDownMenuLanguageSwitch(
              locales: locales,
              title: widget.title,
              useNLettersInsteadOfIcon: widget.useNLettersInsteadOfIcon,
              showLeading: widget.showLeading,
              shape: widget.shape,
            ),
          _Switcher.grid => GridOfLanguages(
              gridDelegate: widget.gridDelegate,
              additionalCallBack: widget.additionalCallBack,
              shape: widget.shape,
            ),
          _Switcher.iconButton => SelectLocaleButton(
              radius: widget.iconRadius ?? 32,
              popUpWindowTitle: widget.title ?? '',
              updateIconOnChange: (widget.useStaticIcon != null),
              useStaticIcon: widget.useStaticIcon,
              toolTipPrefix: widget.toolTipPrefix ?? '',
              useNLettersInsteadOfIcon: widget.useNLettersInsteadOfIcon,
              shape: widget.shape,
            ),
          _Switcher.segmentedButton => TitleOfLangSwitch(
              padding: widget.padding,
              crossAxisAlignment: widget.crossAxisAlignment,
              titlePositionTop: widget.titlePositionTop,
              titlePadding: widget.titlePadding,
              title: widget.title,
              child: SegmentedButtonSwitch(
                locales: locales,
                useNLettersInsteadOfIcon: widget.useNLettersInsteadOfIcon,
                shape: widget.shape,
              ),
            ),
        };
      },
    );
  }
}
