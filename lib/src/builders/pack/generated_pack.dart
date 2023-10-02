final package = <String, dynamic>{
  'locale_switcher':
      r'''/// # A widget for switching the locale of your application.
///
library locale_switcher;

export './src/lang_icon_with_tool_tip.dart';
export './src/locale_manager.dart';
export './src/locale_switcher.dart';
export './src/show_select_locale_dialog.dart';

// export 'package:locale_switcher/src/locale_store.dart';
''',
  'src': <String, dynamic>{
    'lang_icon_with_tool_tip': r'''import 'package:flutter/material.dart';

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
    this.langCode,
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
    required this.langCode,
    this.toolTipPrefix = '',
    this.radius,
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.child,
  });

  final String langCode;

  @override
  Widget build(BuildContext context) {
    if (langCode == showOtherLocales) {
      return LocaleSwitcher.iconButton(
        useStaticIcon:
            ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
                ? LocaleStore.languageToCountry[showOtherLocales]![2]
                : const Icon(Icons.expand_more),
      );
    }

    final lang = LocaleStore.languageToCountry[langCode] ??
        [langCode, 'Unknown language code: $langCode'];

    var nLetters = useNLettersInsteadOfIcon;
    if (nLetters == 0 &&
        Flags.instance[(lang[0] as String).toLowerCase()] == null) {
      nLetters = 2;
    }

    final Widget defaultChild = child ??
        ((nLetters > 0 && langCode != LocaleStore.systemLocale)
            ? ClipOval(
                // text
                child: SizedBox(
                    width: radius ?? 48,
                    height: radius ?? 48,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: FittedBox(
                          child: Text(
                        langCode.toUpperCase(),
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
''',
    'locale_manager': r'''import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'locale_store.dart';

// todo:
/// An alternative to LocaleManager,
// Future<void> openStorageAndReadLocale({
//   ifReadEmpty = LocaleStore.systemLocale,
// }) async {
//   return LocaleStore.init();
// }

/// This should be a parent to either [MaterialApp] or [CupertinoApp].
///
/// It:
/// - Rebuilds the child widget when the [locale] changes.
/// - Observes changes in the system locale.
/// - Saves the current locale to [SharedPreferences].
/// - Loads the last used locale from [SharedPreferences].
class LocaleManager extends StatefulWidget {
  /// Either [MaterialApp] or [CupertinoApp].
  final Widget child;

  /// Store locale in [SharedPreferences].
  final bool storeLocale;

  /// A name of key used to store locale in [SharedPreferences].
  final String sharedPreferenceName;

  /// Make sure what static data only initialized once.
  static bool isInitialized = false;

  /// Add or change language to flag mapping.
  ///
  /// Example:
  /// {'en': ['GB', 'English', <Icon>]}
  /// (first two options are required, third is optional)
  final Map<String, List>? reassignFlags;

  /// [ValueNotifier] with current language code, could be 'system'.
  ///
  /// Will automatically update [LocaleManager.locale].
  /// Value of this notifier should be either from [supportedLocales] or 'system'.
  static ValueNotifier<String> get languageCode => LocaleStore.languageCode;

  /// A [ValueListenable] with current locale.
  ///
  /// Use [LocaleStore.languageCode] to update this notifier.
  static ValueNotifier<Locale> get locale => LocaleStore.locale;

  final List<Locale>? _supportedLocales;

  const LocaleManager({
    super.key,
    required this.child,
    this.reassignFlags,
    this.storeLocale = true,
    this.sharedPreferenceName = 'LocaleSwitcherCurrentLocale',

    /// This parameter is ONLY needed if the [child] parameter is not [MaterialApp]
    /// or [CupertinoApp].
    ///
    /// Note: [MaterialApp] or [CupertinoApp] and this widget should still be inside the
    /// same `build` method, otherwise it will not listen to [locale] notifier!
    ///
    /// Example:
    /// ```dart
    /// Widget build(BuildContext context) {
    /// return LocaleManager(
    ///   supportedLocales: AppLocalizations.supportedLocales,
    ///   child: SomeOtherWidget(
    ///     child: MaterialApp(
    ///       locale: LocaleManager.locale.value,
    ///       supportedLocales: AppLocalizations.supportedLocales,
    /// ```
    List<Locale>? supportedLocales,
  }) : _supportedLocales = supportedLocales;

  @override
  State<LocaleManager> createState() => _LocaleManagerState();
}

class _LocaleManagerState extends State<LocaleManager> {
  void updateParent() => setState(() {
        context.visitAncestorElements((element) {
          element.markNeedsBuild();
          return false; // rebuild only first parent
        });
      });

  /// init [LocaleStore]'s delegate and supportedLocales
  void _readAppLocalization(Widget child) {
    LocaleStore.initSystemLocaleObserverAndLocaleUpdater();
    if (widget._supportedLocales != null) {
      LocaleStore.setSupportedLocales(widget._supportedLocales!);
    } else if (child.runtimeType == MaterialApp) {
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
    } else {
      throw UnimplementedError(
          "The child should be either CupertinoApp or MaterialApp class");
    }
  }

  @override
  void initState() {
    if (!LocaleManager.isInitialized) {
      // reassign flags
      if (widget.reassignFlags != null) {
        for (final MapEntry(:key, :value) in widget.reassignFlags!.entries) {
          LocaleStore.languageToCountry[key] = value;
        }
      }

      // init LocaleStore delegate and supportedLocales
      _readAppLocalization(widget.child);
    }

    super.initState();

    LocaleStore.locale.addListener(updateParent);

    if (!LocaleManager.isInitialized) {
      if (widget.storeLocale) {
        Future.microtask(() => LocaleStore.init(
              sharedPreferenceName: widget.sharedPreferenceName,
            ));
      }
    }

    LocaleManager.isInitialized = true;
  }

  @override
  void dispose() {
    LocaleStore.locale.removeListener(updateParent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
''',
    'locale_store': r'''import 'dart:developer' as dev;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './preference_repository.dart';
import '../locale_switcher.dart';

// extension AppLocalizationsExt on BuildContext {
//   AppLocalizations get l10n => AppLocalizations.of(this);
// }

// extension LocaleWithDelegate on Locale {
//   /// Get class with translation strings for this locale.
//   AppLocalizations get tr => lookupAppLocalizations(this);
// }

abstract class LocaleStore {
  /// A special locale name - app will use `system` default locale.
  static const String systemLocale = 'system';

  /// Auto-updatable value, auto-update started after first access to [locale].
  static String currentSystemLocale = 'en';

  // todo: use ChangeNotifier to check values.
  // todo: store list of recently used locales
  /// Value of this notifier should be either from [supportedLocales] or 'system'.
  static ValueNotifier<String> get languageCode {
    if (__observer == null) {
      initSystemLocaleObserverAndLocaleUpdater();
      // _locale.value = platformDispatcher.locale;
      // todo: try to read pref here?
    }
    return _languageCode;
  }

  /// Current [Locale], use [LocaleStore.setLocale] to update it.
  ///
  /// [LocaleStore.languageCode] contains the real value that stored in [SharedPreferences].
  static ValueNotifier<Locale> get locale {
    if (__observer == null) {
      initSystemLocaleObserverAndLocaleUpdater();
      _locale.value = TestablePlatformDispatcher.platformDispatcher.locale;
    }
    return _locale;
  }

  /// List of supported locales, setup by [LocaleManager]
  static List<Locale> supportedLocales = [];

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String innerSharedPreferenceName = 'LocaleSwitcherCurrentLocale';

  /// If initialized: locale will be stored in [SharedPreferences].
  static get _pref => PreferenceRepository.pref;

  static final _locale = ValueNotifier<Locale>(const Locale('en'));
  static final _languageCode = ValueNotifier<String>(systemLocale);

  static _LocaleObserver? __observer;

  /// Map flag to country.
  /// https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
  static Map<String, List<dynamic>> languageToCountry = {
    // use OS locale
    LocaleStore.systemLocale: [
      'System',
      'OS locale',
      // if (!kIsWeb && Platform.isAndroid) const Icon(Icons.android),
      // if (!kIsWeb && Platform.isIOS) const Icon(Icons.phone_iphone),
      const Icon(Icons.language),
    ],
    // if not all locales shown - add this symbol
    showOtherLocales: [
      'Other',
      'Show other locales',
      const Icon(Icons.expand_more)
    ],
    // English
    'en': ['US', 'English'],
    // Spanish
    'es': ['ES', 'Español'],
    // French
    'fr': ['FR', 'Français'],
    // German
    'de': ['DE', 'Deutsch'],
    // Italian
    'it': ['IT', 'Italiano'],
    // Portuguese
    'pt': ['BR', 'Português'],
    // Dutch
    'nl': ['NL', 'Nederlands'],
    // Russian
    'ru': ['RU', 'Русский'],
    // Chinese (Simplified)
    'zh': ['CN', '中文'],
    // Japanese
    'ja': ['JP', '日本語'],
    // Korean
    'ko': ['KR', '한국어'],
    // Arabic
    'ar': ['SA', 'العربية'],
    // Hindi
    'hi': ['IN', 'हिन्दी'],
    // Bengali
    'bn': ['BD', 'বাঙালি'],
    // Turkish
    'tr': ['TR', 'Türkçe'],
    // Vietnamese
    'vi': ['VN', 'Tiếng Việt'],
    // Greek
    'el': ['GR', 'Ελληνικά'],
    // Polish
    'pl': ['PL', 'Polski'],
    // Ukrainian
    'uk': ['UA', 'Українська'],
    // Thai
    'th': ['TH', 'ไทย'],
    // Indonesian
    'id': ['ID', 'Bahasa Indonesia'],
    // Malay
    'ms': ['MY', 'Bahasa Melayu'],
    // Swedish
    'sv': ['SE', 'Svenska'],
    // Finnish
    'fi': ['FI', 'Suomi'],
    // Norwegian
    'no': ['NO', 'Norsk'],
  };

  /// Set locale with checks.
  ///
  /// It save locale into [SharedPreferences],
  /// and allow to use [systemLocale].
  static void _setLocale(String langCode) {
    late Locale newLocale;
    if (langCode == systemLocale || langCode == '') {
      newLocale = TestablePlatformDispatcher.platformDispatcher.locale;
      // languageCode.value = systemLocale;
    } else if (langCode == showOtherLocales) {
      dev.log('Error wrong locale name: $showOtherLocales');
    } else {
      newLocale = Locale(langCode);
      // languageCode.value = newLocale.languageCode;
    }

    _pref?.setString(innerSharedPreferenceName, languageCode.value);
    locale.value = newLocale;
  }

  // AppLocalizations get tr => lookupAppLocalizations(locale);
  static void initSystemLocaleObserverAndLocaleUpdater() {
    if (__observer == null) {
      WidgetsFlutterBinding.ensureInitialized();
      __observer = _LocaleObserver(onChanged: (_) {
        currentSystemLocale =
            TestablePlatformDispatcher.platformDispatcher.locale.languageCode;
        if (languageCode.value == systemLocale) {
          locale.value = TestablePlatformDispatcher.platformDispatcher.locale;
        }
      });
      WidgetsBinding.instance.addObserver(
        __observer!,
      );

      languageCode.addListener(() => _setLocale(languageCode.value));
    }
  }

  /// Create and init [LocaleStore] class.
  ///
  /// - It also add observer for changes in system locale,
  /// - and init [SharedPreferences].
  static Future<void> init({
    List<Locale>? supportedLocales,
    LocalizationsDelegate? delegate,
    sharedPreferenceName = 'LocaleSwitcherCurrentLocale',
  }) async {
    if (_pref != null) {
      throw UnsupportedError('You cannot initialize class LocaleStore twice!');
    }
    //
    // > init inner vars
    //
    setSupportedLocales(supportedLocales);
    //
    // > init shared preference
    //
    innerSharedPreferenceName = sharedPreferenceName;
    await PreferenceRepository.init();
    //
    // > read locale from sharedPreference
    //
    String langCode = systemLocale;
    if (_pref != null) {
      langCode = _pref!.getString(innerSharedPreferenceName) ?? langCode;
    }
    languageCode.value = langCode;
  }

  static void setSupportedLocales(
    List<Locale>? supportedLocales,
  ) {
    if (supportedLocales != null) {
      LocaleStore.supportedLocales = supportedLocales;
    }
  }
}

class TestablePlatformDispatcher {
  static PlatformDispatcher? overridePlatformDispatcher;

  static PlatformDispatcher get platformDispatcher {
    if (overridePlatformDispatcher != null) {
      return overridePlatformDispatcher!;
    } else {
      return WidgetsBinding.instance.platformDispatcher;
    }
  }
}

/// Observer used to notify the caller when the locale changes.
class _LocaleObserver extends WidgetsBindingObserver {
  final void Function(List<Locale>? locales) onChanged;

  _LocaleObserver({required this.onChanged});

  @override
  void didChangeLocales(List<Locale>? locales) {
    onChanged(locales);
  }
}
''',
    'locale_switcher': r'''import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

typedef LocaleSwitchBuilder = Widget Function(List<String>, BuildContext);

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
    Key? key,
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
      key: key,
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
    Key? key,
    int numberOfShown = 200,
    bool showOsLocale = true,
    SliverGridDelegate? gridDelegate,
    Function(BuildContext)? additionalCallBack,
    int? useNLettersInsteadOfIcon,
    ShapeBorder? shape = const CircleBorder(eccentricity: 0),
  }) {
    return LocaleSwitcher._(
      key: key,
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
    Key? key,
    required LocaleSwitchBuilder builder,
    int numberOfShown = 4,
    bool showOsLocale = true,
  }) {
    return LocaleSwitcher._(
      key: key,
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
    Key? key,
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
      key: key,
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
    Key? key,
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
      key: key,
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

    final staticLocales = <String>[
      if (showOsLocale) LocaleStore.systemLocale,
      ...LocaleStore.supportedLocales
          .take(numberOfShown) // chose most used
          .map((e) => e.languageCode),
    ];

    return ValueListenableBuilder(
      valueListenable: LocaleStore.languageCode,
      builder: (BuildContext context, value, Widget? child) {
        var locales = [...staticLocales];
        if (!locales.contains(LocaleStore.languageCode.value)) {
          locales.last = LocaleStore.languageCode.value;
        }
        if (LocaleStore.supportedLocales.length > numberOfShown) {
          locales.add(showOtherLocales);
        }

        return switch (_type) {
          _Switcher.custom => builder!(locales, context),
          _Switcher.menu => DropDownMenuLanguageSwitch(
              locales: locales,
              title: title,
              useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
              showLeading: showLeading,
              shape: shape,
            ),
          _Switcher.grid => GridOfLanguages(
              gridDelegate: gridDelegate,
              additionalCallBack: additionalCallBack,
              shape: shape,
            ),
          _Switcher.iconButton => SelectLocaleButton(
              radius: iconRadius ?? 32,
              popUpWindowTitle: title ?? '',
              updateIconOnChange: (useStaticIcon != null),
              useStaticIcon: useStaticIcon,
              toolTipPrefix: toolTipPrefix ?? '',
              useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
              shape: shape,
            ),
          _Switcher.segmentedButton => TitleOfLangSwitch(
              padding: padding,
              crossAxisAlignment: crossAxisAlignment,
              titlePositionTop: titlePositionTop,
              titlePadding: titlePadding,
              title: title,
              child: SegmentedButtonSwitch(
                locales: locales,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
            ),
        };
      },
    );
  }
}
''',
    'preference_repository':
        r'''import 'package:shared_preferences/shared_preferences.dart';


class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static SharedPreferences? pref;

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }
}
''',
    'preference_repository_stub':
        r'''/// Stub class, in case: shared_preferences: false
class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static bool? pref;

  // stub
  static Future<void> init() async {}
}
''',
    'show_select_locale_dialog': r'''import 'package:flutter/material.dart';
import '../locale_switcher.dart';

/// Show popup dialog to select Language.
Future<void> showSelectLocaleDialog(
  BuildContext context, {
  String title = 'Select language',
  double? width,
  double? height,
  SliverGridDelegate? gridDelegate,
}) {
  final size = MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: width ?? size.width * 0.6,
          height: height ?? size.height * 0.6,
          child: LocaleSwitcher.grid(
            gridDelegate: gridDelegate,
            additionalCallBack: (context) => Navigator.of(context).pop(),
          ),
        ),
        actions: <Widget>[
          Row(
            children: [
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
            ],
          )
        ],
      );
    },
  );
}
''',
    'locale_switch_sub_widgets': <String, dynamic>{
      'drop_down_menu_language_switch':
          r'''import 'package:flutter/material.dart';
import '../../locale_switcher.dart';
import '../locale_store.dart';

class DropDownMenuLanguageSwitch extends StatelessWidget {
  final String? title;

  final int useNLettersInsteadOfIcon;

  final bool showLeading;

  final ShapeBorder? shape;

  const DropDownMenuLanguageSwitch({
    super.key,
    required this.locales,
    this.title,
    this.useNLettersInsteadOfIcon = 0,
    this.showLeading = true,
    this.shape = const CircleBorder(eccentricity: 0),
  });

  final List<String> locales;

  @override
  Widget build(BuildContext context) {
    const radius = 38.0;
    final localeEntries = locales
        .map<DropdownMenuEntry<String>>(
          (e) => DropdownMenuEntry<String>(
            value: e,
            label: LocaleStore.languageToCountry[e]?[1] ?? e,
            leadingIcon: showLeading
                ? SizedBox(
                    width: radius,
                    height: radius,
                    key: ValueKey('item-$e'),
                    child: FittedBox(
                        child: (LocaleStore.languageToCountry[e] ?? const [])
                                    .length >
                                2
                            ? LocaleStore.languageToCountry[e]![2] ??
                                LangIconWithToolTip(
                                  langCode: e,
                                  radius: radius,
                                  useNLettersInsteadOfIcon:
                                      useNLettersInsteadOfIcon,
                                  shape: shape,
                                )
                            : LangIconWithToolTip(
                                langCode: e,
                                radius: radius,
                                useNLettersInsteadOfIcon:
                                    useNLettersInsteadOfIcon,
                                shape: shape,
                              )),
                  )
                : null,
          ),
        )
        .toList();

    return DropdownMenu<String>(
      initialSelection: LocaleStore.languageCode.value,
      leadingIcon: showLeading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: LangIconWithToolTip(
                langCode: LocaleStore.languageCode.value,
                radius: 32,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
            )
          : null,
      // controller: colorController,
      label: const Text('Language'),
      dropdownMenuEntries: localeEntries,
      onSelected: (String? langCode) {
        if (langCode != null) {
          if (langCode == showOtherLocales) {
            showSelectLocaleDialog(context);
          } else {
            LocaleManager.languageCode.value = langCode;
          }
        }
      },
      enableSearch: true,
    );
  }
}
''',
      'grid_of_languages': r'''import 'package:flutter/material.dart';
import '../../locale_switcher.dart';
import '../locale_store.dart';

/// This is the [GridView] used by [showSelectLocaleDialog] internally.
class GridOfLanguages extends StatelessWidget {
  final SliverGridDelegate? gridDelegate;
  final Function(BuildContext)? additionalCallBack;

  final ShapeBorder? shape;

  const GridOfLanguages({
    super.key,
    this.gridDelegate,
    this.additionalCallBack,
    this.shape = const CircleBorder(eccentricity: 0),
  });

  @override
  Widget build(BuildContext context) {
    final locales = [
      LocaleStore.systemLocale,
      ...LocaleStore.supportedLocales.map((e) => e.languageCode),
    ];

    return GridView(
      gridDelegate: gridDelegate ??
          const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
      children: [
        ...locales.map((langCode) {
          final lang = LocaleStore.languageToCountry[langCode] ??
              [langCode, 'Unknown locale'];
          return Card(
            child: InkWell(
              onTap: () {
                LocaleManager.languageCode.value = langCode;
                additionalCallBack?.call(context);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child:
                          LangIconWithToolTip(langCode: langCode, shape: shape),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      lang[1],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                ],
              ),
            ),
          );
        })
      ],
    );
  }
}
''',
      'segmented_button_switch': r'''import 'package:flutter/material.dart';

import '../../locale_switcher.dart';
import '../locale_store.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final List<String> locales;
  final int useNLettersInsteadOfIcon;

  final double? radius;

  final ShapeBorder? shape;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.radius = 32,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: locales.map<ButtonSegment<String>>(
        (e) {
          final curRadius =
              e == LocaleStore.systemLocale ? (radius ?? 24) * 5 : radius;
          return ButtonSegment<String>(
            value: e,
            tooltip: LocaleStore.languageToCountry[e]?[1] ?? e,
            label: Padding(
              padding: e == LocaleStore.systemLocale
                  ? const EdgeInsets.all(0.0)
                  : const EdgeInsets.all(8.0),
              child: FittedBox(
                child: (LocaleStore.languageToCountry[e] ?? const []).length > 2
                    ? LocaleStore.languageToCountry[e]![2] ??
                        LangIconWithToolTip(
                          langCode: e,
                          radius: curRadius,
                          useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                          shape: shape,
                        )
                    : LangIconWithToolTip(
                        langCode: e,
                        radius: curRadius,
                        useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                        shape: shape,
                      ),
              ),
            ),
          );
        },
      ).toList(),
      selected: {LocaleManager.languageCode.value},
      multiSelectionEnabled: false,
      onSelectionChanged: (Set<String> newSelection) {
        if (newSelection.first == showOtherLocales) {
          showSelectLocaleDialog(context);
        } else {
          LocaleManager.languageCode.value = newSelection.first;
        }
      },
    );
  }
}
''',
      'select_locale_button': r'''import 'package:flutter/material.dart';

import '../../locale_switcher.dart';
import '../locale_store.dart';

/// IconButton to show and select a language.
///
/// In popup window will be displayed [LocaleSwitcher.grid].
class SelectLocaleButton extends StatelessWidget {
  final bool updateIconOnChange;

  final String toolTipPrefix;

  final double radius;

  final Widget? useStaticIcon;

  final String popUpWindowTitle;

  final int useNLettersInsteadOfIcon;

  final ShapeBorder? shape;

  const SelectLocaleButton({
    super.key,
    this.updateIconOnChange = true,
    this.toolTipPrefix = 'Current language: ',
    this.radius = 32,
    this.useStaticIcon,
    this.popUpWindowTitle = "",
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocaleStore.languageCode,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: useStaticIcon ??
              LangIconWithToolTip(
                toolTipPrefix: toolTipPrefix,
                langCode: LocaleStore.languageCode.value,
                radius: radius,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
          // tooltip: LocaleStore.languageToCountry[showOtherLocales]?[1] ??
          //     "Other locales",
          onPressed: () =>
              showSelectLocaleDialog(context, title: popUpWindowTitle),
        );
      },
    );
  }
}
''',
      'title_of_lang_switch': r'''import 'package:flutter/material.dart';

class TitleOfLangSwitch extends StatelessWidget {
  final Widget child;

  const TitleOfLangSwitch({
    super.key,
    required this.padding,
    required this.crossAxisAlignment,
    required this.titlePositionTop,
    required this.titlePadding,
    required this.title,
    required this.child,
  });

  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final bool titlePositionTop;
  final EdgeInsets titlePadding;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (titlePositionTop)
            Padding(
              padding: titlePadding,
              child: Center(child: Text(title ?? '')),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!titlePositionTop)
                Padding(
                  padding: titlePadding,
                  child: Center(child: Text(title ?? '')),
                ),
              Expanded(
                child: child,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
''',
    },
  },
};
