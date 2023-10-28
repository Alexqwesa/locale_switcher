import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_locale.dart';
import 'package:locale_switcher/src/preference_repository.dart';

import 'locale_store.dart';
import 'locale_switch_sub_widgets/drop_down_menu_language_switch.dart';
import 'locale_switch_sub_widgets/grid_of_languages.dart';
import 'locale_switch_sub_widgets/segmented_button_switch.dart';
import 'locale_switch_sub_widgets/select_locale_button.dart';

/// A special name for wrapper [LocaleName] to use as button that show other locales.
const showOtherLocales = 'show_other_locales_button';

/// A special name for wrapper [LocaleName] to use as system locale option.
const systemLocale = 'system';

/// Names of possible [LocaleSwitcher] constructors.
///
/// Mostly used internally by [LocaleSwitcher].
enum LocaleSwitcherType {
  menu,
  custom,
  grid,
  iconButton,
  segmentedButton,
}

typedef LocaleSwitchBuilder = Widget Function(
    SupportedLocaleNames, BuildContext);

/// A Widget to switch locale of App.
///
/// Use any of these constructors to create widget:
/// - [LocaleSwitcher.segmentedButton],
/// - [LocaleSwitcher.iconButton],
/// - [LocaleSwitcher.menu],
/// - [LocaleSwitcher.custom].
class LocaleSwitcher extends StatefulWidget {
  /// Use Emoji instead of svg flag.
  ///
  /// Can not be used with [useNLettersInsteadOfIcon].
  final bool useEmoji;

  /// Just width of the widget.
  final double? width;

  /// Currently selected entry in [supportedLocaleNames] that contains [Locale].
  ///
  /// You can update it by using any value in [supportedLocaleNames],
  /// if you are not sure that your locale exist in list of supportedLocales(in [supportedLocaleNames]):
  /// use [LocaleSwitcher.trySetLocale].
  ///
  /// The notifier [localeIndex] is the underlying notifier for this value.
  static LocaleName get current => CurrentLocale.current;

  static set current(LocaleName value) => CurrentLocale.current = value;

  // final void Function(BuildContext)? readLocaleCallback;// todo:

  /// Update supportedLocales (that used to generated [LocaleStore.supportedLocaleNames]).
  ///
  /// Use in case [MaterialApp].supportedLocales changed.
  // or readSupportedLocales
  // add localizationCallback (with/withOutContext)
  // todo:
  static List<Locale> readLocales(List<Locale> supportedLocales) {
    if (supportedLocales.isEmpty && LocaleStore.supportedLocales.isEmpty) {
      supportedLocales = const [Locale('en')];
    }

    if (!identical(LocaleStore.supportedLocales, supportedLocales)) {
      LocaleStore.supportedLocales = supportedLocales;
      LocaleStore.supportedLocaleNames = SupportedLocaleNames(supportedLocales);
    }

    return supportedLocales;
  }

  /// [ValueNotifier] with index of currently used [LocaleName] in list [supportedLocaleNames].
  static ValueNotifier<int> get localeIndex => CurrentLocale.notifier;

  /// A list of generated [LocaleName]s for supportedLocales.
  ///
  /// Note: [supportedLocales] should be the same as [MaterialApp].supportedLocales
  static SupportedLocaleNames get supportedLocaleNames =>
      LocaleStore.supportedLocaleNames;

  /// A ReadOnly [ValueNotifier] with current locale.
  ///
  /// If selected systemLocale - value can be outside of range of supportedLocales.
  /// Use [localeBestMatch] if you needed locale in range of supportedLocales.
  ///
  /// Use [LocaleSwitcher.current] or [LocaleSwitcher.localeIndex].value to update this notifier.
  static ValueNotifier<Locale> get locale => CurrentLocale.locale;

  /// A ReadOnly [Locale], in range of supportedLocales, if selected systemLocale it try to guess.
  ///
  /// Use [LocaleSwitcher.current] to update this value.
  // Todo: just locale? currentSupportedLocale? allowedLocale? matchedLocale?
  static Locale get localeBestMatch => LocaleSwitcher.current.bestMatch;

  /// Currently selected entry in [supportedLocaleNames] that contains [Locale].
  ///
  /// You can update it by using any value in [supportedLocaleNames],
  /// if you are not sure that your locale exist in list of supportedLocales(in [supportedLocaleNames]):
  /// use [LocaleSwitcher.trySetLocale].
  ///
  /// The notifier [localeIndex] is the underlying notifier for this value.
  // static   find = LocaleMatcher;

  /// A text describing switcher
  final String? title;

  /// Number of shown flags
  final int numberOfShown;

  /// What constructor was used to create this instance.
  final LocaleSwitcherType type;

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

  /// Function called after choosing new current `Locale` (actually [LocaleName]).
  ///
  /// Useful for [LocaleSwitcher.grid] - if you want to close popup window after new selection.
  ///
  /// Only Required if:
  /// if you use `easy_localization` and `locale_switcher` (not needed for `locale_switcher_dev`),
  /// set up it like this:
  /// ```dart
  ///   LocaleSwitcher.<any_constructor>(
  ///     setLocaleCallBack: (context) => context.setLocale(LocaleSwitcher.localeBestMatch),
  ///     ...
  /// ```
  final Function(BuildContext)? setLocaleCallBack;

  /// Only for [LocaleSwitcher.iconButton] - use static icon.
  final Icon? useStaticIcon;

  /// Only for [LocaleSwitcher.iconButton].
  final String? toolTipPrefix;

  /// Only for [LocaleSwitcher.iconButton].
  final double? iconRadius;

  /// If null or 0 - used Icon, otherwise first N letters of language code.
  ///
  /// Can not be used with [useEmoji].
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
    this.type = LocaleSwitcherType.segmentedButton,
    this.builder,
    this.gridDelegate,
    this.setLocaleCallBack,
    this.toolTipPrefix,
    this.useStaticIcon,
    this.iconRadius,
    this.useNLettersInsteadOfIcon = 0,
    this.showLeading = true,
    this.shape = const CircleBorder(eccentricity: 0),
    this.useEmoji = false,
    this.width,
  }) : assert(!useEmoji || (useEmoji == (useNLettersInsteadOfIcon == 0)));

  /// A Widget to switch locale of App with [DropDownMenu](https://api.flutter.dev/flutter/material/DropdownMenu-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/), [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart).
  factory LocaleSwitcher.menu({
    Key? key,
    String? title = 'Language:',
    int numberOfShown = 200,
    bool showOsLocale = true,
    int? useNLettersInsteadOfIcon,
    bool useEmoji = false,
    double width = 250,
    bool showLeading = true,
    ShapeBorder? shape = const CircleBorder(eccentricity: 0),
    Function(BuildContext)? setLocaleCallBack,
  }) {
    return LocaleSwitcher._(
      key: key,
      title: title,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      type: LocaleSwitcherType.menu,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      showLeading: showLeading,
      shape: shape,
      setLocaleCallBack: setLocaleCallBack,
      useEmoji: useEmoji,
      width: width,
    );
  }

  /// A Widget to switch locale of App with [GridView](https://api.flutter.dev/flutter/widgets/GridView-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/),
  /// [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart) - click on icon in AppBar to see this widget.
  factory LocaleSwitcher.grid({
    Key? key,
    int numberOfShown = 200,
    bool showOsLocale = true,
    SliverGridDelegate? gridDelegate,
    Function(BuildContext)? setLocaleCallBack,
    int? useNLettersInsteadOfIcon,
    ShapeBorder? shape = const CircleBorder(eccentricity: 0),
    useEmoji = false,
  }) {
    return LocaleSwitcher._(
      key: key,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      type: LocaleSwitcherType.grid,
      gridDelegate: gridDelegate,
      setLocaleCallBack: setLocaleCallBack,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      shape: shape,
      useEmoji: useEmoji,
    );
  }

  /// A Widget to switch locale of App with your own widget:
  ///
  /// Example:
  /// ```dart
  /// LocaleSwitcher.custom(
  ///   builder: (supportedLocNames) { // widget AnimatedToggleSwitch from package:
  ///     return AnimatedToggleSwitch<LocaleName>.rolling( // animated_toggle_switch
  ///       current: LocaleSwitcher.current,
  ///       values: supportedLocNames,
  ///       loading: false,
  ///       onChanged: (curLocaleName) {
  ///         if (curLocaleName.name == showOtherLocales)
  ///           showSelectLocaleDialog(context);
  ///         } else {
  ///           LocaleSwitcher.current = curLocaleName;
  ///           // next for easy_localization with locale_switcher ONLY - NOT for locale_switcher_dev !
  ///           // context.setLocale(LocaleSwitcher.localeBestMatch);
  ///         }
  ///       },
  ///       iconBuilder: LangIconWithToolTip.forIconBuilder,
  ///     );
  ///   })
  /// ```
  factory LocaleSwitcher.custom({
    Key? key,
    required LocaleSwitchBuilder builder,
    int numberOfShown = 4,
    bool showOsLocale = true,
    // Function(BuildContext)? setLocaleCallBack,
  }) {
    return LocaleSwitcher._(
      key: key,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      type: LocaleSwitcherType.custom,
      builder: builder,
      // setLocaleCallBack: null,
    );
  }

  /// A Widget to switch locale of App with [IconButton](https://api.flutter.dev/flutter/material/IconButton-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/),
  /// [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart) - it is an icon in AppBar.
  ///
  /// In popup window will be displayed [LocaleSwitcher.grid].
  factory LocaleSwitcher.iconButton({
    Key? key,
    String? toolTipPrefix = 'Current language: ',
    bool useEmoji = false,

    /// Title of popup dialog.
    String? title = 'Select language: ',
    Icon? useStaticIcon,
    double? iconRadius = 32,
    // required LocaleSwitchBuilder builder,
    int numberOfShown = 200,
    bool showOsLocale = true,
    int? useNLettersInsteadOfIcon,
    ShapeBorder? shape = const CircleBorder(eccentricity: 0),
    Function(BuildContext)? setLocaleCallBack,
  }) {
    return LocaleSwitcher._(
      key: key,
      title: title,
      toolTipPrefix: toolTipPrefix,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      useStaticIcon: useStaticIcon,
      iconRadius: iconRadius,
      type: LocaleSwitcherType.iconButton,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      shape: shape,
      setLocaleCallBack: setLocaleCallBack,
      useEmoji: useEmoji,
      // builder: builder,
    );
  }

  /// A Widget to switch locale of App with [SegmentedButton](https://api.flutter.dev/flutter/material/SegmentedButton-class.html).
  ///
  /// Example: [online app](https://alexqwesa.github.io/locale_switcher/),
  /// [source code](https://github.com/Alexqwesa/locale_switcher/blob/main/example/lib/main.dart) .
  factory LocaleSwitcher.segmentedButton({
    Key? key,
    bool useEmoji = false,

    /// Width of widget, null for auto.
    double? width,
    // double? iconRadius = 32,
    // required LocaleSwitchBuilder builder,
    int numberOfShown = 4,
    bool showOsLocale = true,
    int? useNLettersInsteadOfIcon,
    ShapeBorder? shape,
    Function(BuildContext)? setLocaleCallBack,
  }) {
    return LocaleSwitcher._(
      key: key,
      showOsLocale: showOsLocale,
      numberOfShown: numberOfShown,
      type: LocaleSwitcherType.segmentedButton,
      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon ?? 0,
      shape: shape,
      setLocaleCallBack: setLocaleCallBack,
      useEmoji: useEmoji,
      width: width,
      // builder: builder,
    );
  }

  @override
  State<LocaleSwitcher> createState() => _LocaleSwitcherState();
}

class _LocaleSwitcherState extends State<LocaleSwitcher> {
  final globalKey = GlobalKey();

  late final SupportedLocaleNames staticLocales;
  late final SupportedLocaleNames locales;

  @override
  void initState() {
    // check: is it inited?
    if (LocaleStore.supportedLocales.isEmpty) {
      // todo: use CurrentLocale
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
          LocaleSwitcher.readLocales(supportedLocales);
        } else if (child.runtimeType == CupertinoApp) {
          final supportedLocales =
              (child as CupertinoApp).supportedLocales.toList(growable: false);
          if (supportedLocales.isEmpty) {
            throw UnsupportedError(
                'CupertinoApp should have initialized supportedLocales parameter');
          }
          LocaleSwitcher.readLocales(supportedLocales);
        }
      }
    }

    final skip = widget.showOsLocale ? 0 : 1;
    locales = SupportedLocaleNames.fromEntries(
      LocaleStore.supportedLocaleNames.entries
          .skip(skip) // first is system locale
          .take(widget.numberOfShown + 1 - skip) // chose most used
      ,
    );

    if (!locales.names.contains(LocaleSwitcher.current.name)) {
      locales.replaceLast(localeName: LocaleSwitcher.current);
    }
    if (LocaleStore.supportedLocales.length > widget.numberOfShown) {
      locales
          .addShowOtherLocales(); //setLocaleCallBack: widget.setLocaleCallBack);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // send globalKey
    final stateBox = _StateBoxToAccessContext(key: globalKey);
    PreferenceRepository.sendGlobalKeyToRepository(globalKey);

    final child = ValueListenableBuilder(
      valueListenable: CurrentLocale.notifier,
      builder: (BuildContext context, index, Widget? child) {
        // always show current locale
        if (!locales.names.contains(LocaleSwitcher.current.name)) {
          if (locales.last.name == showOtherLocales) {
            locales[locales.length - 2] = LocaleSwitcher.current;
          } else {
            locales.replaceLast(localeName: LocaleSwitcher.current);
          }
        }

        // todo: add 0.5 second delayed check of app locale ? post frame callback ?

        return switch (widget.type) {
          LocaleSwitcherType.custom => widget.builder!(locales, context),
          LocaleSwitcherType.menu => DropDownMenuLanguageSwitch(
              locales: locales,
              title: widget.title,
              useNLettersInsteadOfIcon: widget.useNLettersInsteadOfIcon,
              showLeading: widget.showLeading,
              shape: widget.shape,
              setLocaleCallBack: widget.setLocaleCallBack,
              useEmoji: widget.useEmoji,
              width: widget.width,
            ),
          LocaleSwitcherType.grid => GridOfLanguages(
              gridDelegate: widget.gridDelegate,
              setLocaleCallBack: widget.setLocaleCallBack,
              shape: widget.shape,
              useEmoji: widget.useEmoji,
            ),
          LocaleSwitcherType.iconButton => SelectLocaleButton(
              radius: widget.iconRadius ?? 32,
              popUpWindowTitle: widget.title ?? '',
              updateIconOnChange: (widget.useStaticIcon != null),
              useStaticIcon: widget.useStaticIcon,
              toolTipPrefix: widget.toolTipPrefix ?? '',
              useNLettersInsteadOfIcon: widget.useNLettersInsteadOfIcon,
              shape: widget.shape,
              setLocaleCallBack: widget.setLocaleCallBack,
              useEmoji: widget.useEmoji,
            ),
          LocaleSwitcherType.segmentedButton => SegmentedButtonSwitch(
              locales: locales,
              useNLettersInsteadOfIcon: widget.useNLettersInsteadOfIcon,
              shape: widget.shape,
              setLocaleCallBack: widget.setLocaleCallBack,
              useEmoji: widget.useEmoji,
              width: widget.width,
            ),
        };
      },
    );

    if (widget.width == null) {
      return IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: child),
            stateBox,
          ],
        ),
      );
    } else {
      return SizedBox(
        width: widget.width!,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: child),
            stateBox,
          ],
        ),
      );
    }

    // return LayoutBuilder(builder: (context, constraints) {
    //
    //   Widget sizedChild = ConstrainedBox(
    //     constraints: BoxConstraints(
    //       maxWidth: max(constraints.minWidth, constraints.maxWidth - 1),
    //       maxHeight: constraints.maxHeight,
    //     ),
    //     child: child,
    //   );
    //
    //   return IntrinsicWidth(
    //     child: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         Expanded(child: sizedChild),
    //         sBox,
    //       ],
    //     ),
    //   );
    // });
  }
}

class _StateBoxToAccessContext extends StatefulWidget {
  const _StateBoxToAccessContext({
    super.key,
  });

  @override
  State<_StateBoxToAccessContext> createState() =>
      _StateBoxToAccessContextState();
}

class _StateBoxToAccessContextState extends State<_StateBoxToAccessContext> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 1, height: 1);
  }
}
