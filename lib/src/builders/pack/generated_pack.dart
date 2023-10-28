final package = <String, dynamic>{
  'locale_switcher':
      r'''/// # A widget for switching the locale of your application.
///
library locale_switcher;

export 'package:locale_switcher/src/lang_icon_with_tool_tip.dart';
export 'package:locale_switcher/src/locale_manager.dart';
export 'package:locale_switcher/src/locale_matcher.dart';
export 'package:locale_switcher/src/locale_name.dart';
export 'package:locale_switcher/src/locale_switcher.dart';
export 'package:locale_switcher/src/public_extensions.dart';

// export 'package:locale_switcher/src/current_locale.dart';
export 'package:locale_switcher/src/show_select_locale_dialog.dart';
export 'package:locale_switcher/src/supported_locale_names.dart';
export 'package:locale_switcher/src/locale_switch_sub_widgets/title_of_locale_switch.dart';
''',
  'src': <String, dynamic>{
    'current_locale': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_system_locale.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/preference_repository.dart';

/// An indexes and notifiers to work with [LocaleSwitcher.supportedLocaleNames].
///
/// [current] and [index] - are pointed at current active entry in
/// [LocaleSwitcher.supportedLocaleNames], have setters, correspond notifier - [notifier].
abstract class CurrentLocale extends CurrentSystemLocale {
  static late final ValueNotifier<int> _allNotifiers;
  static final _index = ValueNotifier(0);
  static late final ValueNotifier<Locale> _locale;

  /// Listen on both system locale and currently selected [LocaleName].
  ///
  /// In case [systemLocale] is selected: it didn't try to guess
  /// which [LocaleName] is best match, and just return OS locale.
  /// (Your localization system should select best match).
  static ValueNotifier<Locale> get locale {
    try {
      return _locale;
    } catch (e) {
      _locale = ValueNotifier<Locale>(const Locale('en'));
      _locale.value = current.locale!;
      allNotifiers.addListener(() => _locale.value = current.locale!);
      CurrentSystemLocale.currentSystemLocale
          .addListener(() => _allNotifiers.value++);
      return _locale;
    }
  }

  /// Listen on system locale.
  static ValueNotifier<int> get allNotifiers {
    try {
      return _allNotifiers;
    } catch (e) {
      _allNotifiers = ValueNotifier<int>(0);
      notifier.addListener(() => _allNotifiers.value++);
      CurrentSystemLocale.currentSystemLocale
          .addListener(() => _allNotifiers.value++);
      return _allNotifiers;
    }
  }

  /// ValueNotifier of [index] of selected [LocaleSwitcher.supportedLocaleNames].
  static ValueNotifier<int> get notifier => _index;

  /// Index of selected [LocaleSwitcher.supportedLocaleNames].
  ///
  /// Can be set here.
  static int get index => _index.value;

  static set index(int value) {
    if (value < LocaleStore.supportedLocaleNames.length && value >= 0) {
      if (LocaleStore.supportedLocaleNames[value].name != showOtherLocales) {
        // just double check
        _index.value = value;

        PreferenceRepository.write(LocaleStore.prefName, current.name);
      }
    }
  }

  /// Currently selected entry in [LocaleName].
  ///
  /// You can update this value directly, or
  /// if you are not sure that your locale exist in list of supportedLocales:
  /// use [CurrentLocale.trySetLocale].
  static LocaleName get current => LocaleStore.supportedLocaleNames[index];

  static set current(LocaleName value) {
    var idx = LocaleStore.supportedLocaleNames.indexOf(value);
    if (idx >= 0 && idx < LocaleStore.supportedLocaleNames.length) {
      index = idx;
    } else {
      idx = LocaleStore.supportedLocaleNames
          .indexOf(LocaleMatcher.byName(value.name));
      if (idx >= 0 && idx < LocaleStore.supportedLocaleNames.length) {
        index = idx;
      }
    }
  }
}
''',
    'current_system_locale': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_observable.dart';

/// Observe change in system locale.
///
/// Public access to it notifier via [CurrentLocale.byName(LocaleManager.systemLocale)]
abstract class CurrentSystemLocale {
  static LocaleObserver? __observer;

  /// Listen on system locale.
  static ValueNotifier<Locale> get currentSystemLocale {
    initSystemLocaleObserver();
    return __currentSystemLocale;
  }

  static final __currentSystemLocale = ValueNotifier(const Locale('en'));

  static void initSystemLocaleObserver() {
    if (__observer == null) {
      WidgetsFlutterBinding.ensureInitialized();
      __currentSystemLocale.value =
          TestablePlatformDispatcher.platformDispatcher.locale;
      __observer = LocaleObserver(onChanged: (_) {
        __currentSystemLocale.value =
            TestablePlatformDispatcher.platformDispatcher.locale;
      });
      WidgetsBinding.instance.addObserver(
        __observer!,
      );
    }
  }
}
''',
    'lang_icon_with_tool_tip': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';

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
''',
    'locale_manager': r'''import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// This should be a parent to either [MaterialApp] or [CupertinoApp].
///
/// It:
/// - Rebuilds the child widget when the [locale] changes.
/// - Activate observing changes in the system locale.
/// - Setup(and activate) auto-save of the current locale to [SharedPreferences].
/// - Loads the last used locale from [SharedPreferences] (on first load only).
// todo: deactivate observing changes in the system locale(if not used).
class LocaleManager extends StatefulWidget {
  /// Either [MaterialApp] or [CupertinoApp].
  final Widget child;

  /// Store locale in [SharedPreferences].
  final bool storeLocale;

  /// A name of key used to store locale in [SharedPreferences].
  final String sharedPreferenceName;

  /// Make sure what static data only initialized once.
  static bool isInitialized = false;

  /// Add or change records for language in prebuilt flag mapping.
  ///
  /// Example:
  /// {'en': ['GB', 'English', <Icon>]}
  /// (first two options are required, third is optional)
  ///
  /// Note: keys are in lower cases.
  ///
  /// Note 2: prebuilt map here: [languageToCountry]
  final Map<String, List>? reassignFlags;

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
  ///     child: MaterialApp(
  ///       locale: LocaleSwitcher.current.locale,
  ///       supportedLocales: AppLocalizations.supportedLocales,
  /// ```
  ///
  /// Another Example:
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return LocaleManager(
  ///   supportedLocales: AppLocalizations.supportedLocales, // in this case it required
  ///   child: SomeOtherWidget(
  ///     child: MaterialApp(
  ///       locale: LocaleSwitcher.current.locale,
  ///       supportedLocales: AppLocalizations.supportedLocales,
  /// ```
  final List<Locale>? supportedLocales;

  const LocaleManager({
    super.key,
    required this.child,
    this.reassignFlags,
    this.storeLocale = true,
    this.sharedPreferenceName = LocaleStore.defaultPrefName,
    this.supportedLocales,
  });

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

  /// init [LocaleStore]'s supportedLocales
  void _readAppLocalization(Widget child) {
    // LocaleStore.initSystemLocaleObserverAndLocaleUpdater();
    if (widget.supportedLocales != null) {
      LocaleSwitcher.readLocales(
          widget.supportedLocales ?? [const Locale('en')]);
    } else if (child.runtimeType == MaterialApp) {
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
          languageToCountry[key.toLowerCase()] = value;
        }
      }

      // init LocaleStore delegate and supportedLocales
      _readAppLocalization(widget.child);
    }

    super.initState();

    LocaleSwitcher.locale.addListener(updateParent);

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
    LocaleSwitcher.locale.removeListener(updateParent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
''',
    'locale_matcher': r'''import 'dart:ui';

import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// Parameter for [LocaleMatcher.trySetLocale] and [LocaleMatcher.tryFindLocale].
enum IfLocaleNotFound {
  doNothing,
  useFirst,
  useSystem,
}

/// Helper, allow to find [LocaleName] in [LocaleSwitcher.supportedLocaleNames].
class LocaleMatcher {
  /// Global storage of [LocaleName] - instance of [SupportedLocaleNames].
  static SupportedLocaleNames get supported => LocaleStore.supportedLocaleNames;

  static LocaleName? byName(String name) {
    if (supported.names.contains(name.toLowerCase())) {
      return supported.entries[supported.names.indexOf(name.toLowerCase())];
    }
    return null;
  }

  /// Search by first 2 letter, return first found or null.
  static LocaleName? byLanguage(String name) {
    final pattern = name.substring(0, 2);
    final String langName = supported.names.firstWhere(
      (element) => element.startsWith(pattern),
      orElse: () => '',
    );
    if (supported.names.contains(langName)) {
      return supported.entries[supported.names.indexOf(langName)];
    }
    return null;
  }

  /// Search by [Locale], return exact match or null.
  static LocaleName? byLocale(Locale locale) {
    if (supported.locales.contains(locale)) {
      return supported.entries[supported.locales.indexOf(locale)];
    }
    return null;
  }

  /// Try to set [Locale] by string in [LocaleSwitcher.supportedLocaleNames].
  ///
  /// Just wrapper around: [tryFindLocale] and [LocaleSwitcher.current] = newValue;
  ///
  /// If not found: do [ifLocaleNotFound]
  static void trySetLocale(String langCode,
      {IfLocaleNotFound ifLocaleNotFound = IfLocaleNotFound.doNothing}) {
    var loc = tryFindLocale(langCode, ifLocaleNotFound: ifLocaleNotFound);
    if (loc != null) {
      LocaleSwitcher.current = loc;
    }
  }

  /// Try to find [Locale] by string in [LocaleSwitcher.supportedLocaleNames].
  ///
  /// If not found: do [ifLocaleNotFound]
  // todo: similarity check?
  static LocaleName? tryFindLocale(String langCode,
      {IfLocaleNotFound ifLocaleNotFound = IfLocaleNotFound.doNothing}) {
    var loc = byName(langCode) ?? byLanguage(langCode);
    if (loc != null) {
      return loc;
    }
    switch (ifLocaleNotFound) {
      case IfLocaleNotFound.doNothing:
        return null;
      case IfLocaleNotFound.useSystem:
        if (byName(systemLocale) != null) {
          return byName(systemLocale)!;
        }
        return null;
      case IfLocaleNotFound.useFirst:
        if (supported.names.first != systemLocale) {
          return supported.entries.first;
        } else if (supported.names.length > 2) {
          return supported.entries[1];
        }
        return null;
    }
  }
}
''',
    'locale_name': r'''import 'package:flutter/widgets.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/system_locale_name.dart';

/// Wrapper around [Locale], it's name, flag, language and few helpers.
///
/// Created to allow special names, like: [showOtherLocales] and [systemLocale].
///
/// A [bestMatch] is either: locale itself OR closest match (for [systemLocale]).
class LocaleName {
  /// cache
  String? _language;

  /// cache
  Widget? _flag;

  /// Either [Locale].toString() or one of special names, like: [systemLocale] or [showOtherLocales].
  final String name;

  /// Is [Locale] for ordinary locales, null for [showOtherLocales], dynamic for [systemLocale].
  ///
  /// For [systemLocale] it can return unsupported locale,
  /// use [bestMatch] to be sure that returned locale is in [supportedLocales] list.
  final Locale? locale;

  @override
  String toString() {
    return '$name|${locale?.languageCode}';
  }

  /// Exact [Locale] for regular locales, and guess for [systemLocale].
  ///
  /// Unlike [locale] properties, it try to find matching locale in [supportedLocales].
  Locale get bestMatch {
    // exact
    if (name != systemLocale &&
        name != showOtherLocales &&
        LocaleStore.supportedLocaleNames.names.contains(name)) {
      return LocaleSwitcher.current.locale!;
    }
    // guess
    switch (name) {
      case showOtherLocales:
        if (LocaleStore.supportedLocaleNames.length > 2) {
          return LocaleStore.supportedLocaleNames[1].locale ??
              const Locale('en');
        } else {
          return const Locale('en');
        }
      case systemLocale:
        return LocaleMatcher.tryFindLocale(locale!.toString())?.locale ??
            const Locale('en');
      default:
        return locale ?? const Locale('en');
    }
  }

  LocaleName({
    this.name = '',
    this.locale,
    Widget? flag,
    String? language,
  })  : _flag = flag,
        _language = language;

  /// Find flag for [name].
  ///
  /// Search in [LocaleManager.reassignFlags] for locale first, then [Flags.instance].
  ///
  /// For systemLocale or [showOtherLocales] only look into [LocaleManager.reassignFlags].
  Widget? get flag {
    if (name == showOtherLocales || name == systemLocale) {
      if (languageToCountry[name] != null &&
          languageToCountry[name]!.length > 2) {
        _flag = languageToCountry[name]?[2];
      }
    }
    _flag ??= locale?.flag(fallBack: null);
    if (_flag == null && locale?.toString() != name) {
      _flag = findFlagFor(language: name);
    }
    return _flag;
  }

  /// Search in [LocaleManager.reassignFlags] first, and if not found return [name].
  String get language {
    _language ??= (languageToCountry[name.toLowerCase()]?[1] ??
            languageToCountry[name.substring(0, 2).toLowerCase()]?[1]) ??
        name;
    return _language!;
  }

  /// A special [LocaleName] for [systemLocale].
  factory LocaleName.system({Widget? flag}) {
    return SystemLocaleName(flag: flag);
  }
}
''',
    'locale_observable': r'''import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
class LocaleObserver extends WidgetsBindingObserver {
  final void Function(List<Locale>? locales) onChanged;

  LocaleObserver({required this.onChanged});

  @override
  void didChangeLocales(List<Locale>? locales) {
    onChanged(locales);
  }
}
''',
    'locale_store': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/preference_repository.dart';

/// Inner storage.
abstract class LocaleStore {
  /// List of supported locales.
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static List<Locale> supportedLocales = [];

  /// List of helpers based on supported locales - [LocaleName].
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static SupportedLocaleNames supportedLocaleNames =
      SupportedLocaleNames(<Locale>[const Locale('en')]);

  /// If initialized: locale will be stored in [SharedPreferences].
  static get _pref => PreferenceRepository.pref;

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String prefName = 'LocaleSwitcherCurrentLocaleName';
  static const defaultPrefName = 'LocaleSwitcherCurrentLocaleName';

  /// Init [LocaleStore] class.
  ///
  /// - It also init and read [SharedPreferences] (if available).
  static Future<void> init({
    List<Locale>? supportedLocales,
    // LocalizationsDelegate? delegate,
    sharedPreferenceName = defaultPrefName,
  }) async {
    if (_pref == null) {
      //
      // > init inner vars
      //
      if (supportedLocales != null) {
        LocaleSwitcher.readLocales(supportedLocales);
      }
      //
      // > init shared preference
      //
      prefName = sharedPreferenceName;
      await PreferenceRepository.init();
      //
      // > read locale from sharedPreference
      //
      String langCode = systemLocale;
      if (_pref != null) {
        langCode = PreferenceRepository.read(prefName) ?? langCode;
        LocaleMatcher.trySetLocale(langCode);
      }
    }
  }
}
''',
    'locale_switcher': r'''import 'package:flutter/cupertino.dart';
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
''',
    'preference_repository': r'''import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static SharedPreferences? pref;

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  static String? read(String innerSharedPreferenceName) {
    return pref?.getString(innerSharedPreferenceName);
  }

  static Future<bool>? write(String innerSharedPreferenceName, languageCode) {
    return pref?.setString(innerSharedPreferenceName, languageCode);
  }

  // stub, only needed for system like: easy_localization
  static void sendGlobalKeyToRepository(GlobalKey key) {}
}
''',
    'preference_repository_easy_localization':
        r'''// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// This class will try to access easy_localization via context.
class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static bool? pref;

  // todo: also store LocaleManager key
  static GlobalKey? _lastUsedKey;

  static Future<void> init() async {
    pref = true;
  }

  static String? read(String innerSharedPreferenceName) {
    final context = _lastUsedKey?.currentState?.context;
    if (context != null) {
      return EasyLocalization.of(context)?.locale.languageCode;
    }

    // dev.log(
    //     "Context of LocaleSwitcher not found! can't get easy_localization locale!");
    return null;
  }

  static Future<bool>? write(
      String innerSharedPreferenceName, languageCode) async {
    final context = _lastUsedKey?.currentState?.context;
    if (context != null && LocaleSwitcher.current.locale != null) {
      await EasyLocalization.of(context)
          ?.setLocale(LocaleSwitcher.current.bestMatch);
      return true;
    }

    dev.log(
        "Context of LocaleSwitcher not found! can't set easy_localization locale!");
    return false;
  }

  // only needed for system like: easy_localization
  static void sendGlobalKeyToRepository(GlobalKey key) {
    _lastUsedKey = key;
  }
}
''',
    'preference_repository_stub': r'''import 'package:flutter/widgets.dart';

/// Stub class, in case: shared_preferences: false
class PreferenceRepository {
  /// If initialized: locale will be stored in [SharedPreferences].
  static bool? pref;

  // stub
  static Future<void> init() async {}

  static String? read(String innerSharedPreferenceName) {
    return null;
  }

  static Future<bool>? write(String innerSharedPreferenceName, languageCode) {
    return null;
  }

  // stub, only needed for system like: easy_localization
  static void sendGlobalKeyToRepository(GlobalKey key) {}
}
''',
    'public_extensions': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';

/// Map language to country, (and -optionally- a custom flag).
///
/// Keys are in lowerCase!, can be just language or full locale name.
/// Value is a list of: country code, language name and (optionally) flag widget.
///
/// You can also use [LocaleManager.reassignFlags] to update these values.
///
/// Do not remove first two keys!
// https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
final Map<String, List<dynamic>> languageToCountry = {
  /// special entry name for [LocaleSwitcher.supportedLocaleNames] - OS locale
  systemLocale: [
    'System',
    'OS locale',
    // if (!kIsWeb && Platform.isAndroid) const Icon(Icons.android),
    // if (!kIsWeb && Platform.isIOS) const Icon(Icons.phone_iphone),
    const Icon(Icons.language),
  ],

  /// special entry name for [LocaleSwitcher.supportedLocaleNames]
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

extension StringToLocale on String {
  /// Convert string to [Locale] object
  Locale toLocale({String separator = '_'}) {
    final localeList = split(separator);
    switch (localeList.length) {
      case 2:
        return localeList.last.length == 4 // scriptCode length is 4
            ? Locale.fromSubtags(
                languageCode: localeList.first,
                scriptCode: localeList.last,
              )
            : Locale(localeList.first, localeList.last);
      case 3:
        return Locale.fromSubtags(
          languageCode: localeList.first,
          scriptCode: localeList[1],
          countryCode: localeList.last,
        );
      default:
        return Locale(localeList.first);
    }
  }
}

/// Parameter for [Locale.flag] extension.
enum FlagNotFoundFallBack {
  /// if not found - return [Locale].toString()
  full,

  /// if not found - return emoji or [Locale].toString()
  emojiThenFull,

  /// if not found - return [Locale.countryCode] string or [Locale].toString()
  countryCodeThenFull,

  /// if not found - return emoji or [Locale.countryCode] string or [Locale].toString()
  emojiThenCountryCodeThenFull,

  /// if not found - return [Locale.countryCode] string or null
  countryCodeThenNull,

  // todo: more options
}

/// Try to find a flag by language or country string.
Widget? findFlagFor({String? language, String? country}) {
  if (language != null) {
    final str = language.toLowerCase();
    if (languageToCountry.containsKey(str)) {
      final value = languageToCountry[str];
      if (value != null) {
        if (value.length > 2 && value[2] != null) return value[2];
        return findFlagFor(country: value[0]);
      }
    }
  }
  if (country != null) {
    final str = country.toLowerCase();
    if (countryCodeToContent.containsKey(str)) {
      return Flags.instance[str]?.svg;
    }
  }
  return null;
}

/// Offset of the emoji flags in Unicode table.
const emojiOffset = 127397;

extension LocaleFlag on Locale {
  /// Return Unicode character with flag or languageCode.
  ///
  /// Search by country code first, then by [languageToCountry] map, if not found
  /// return [languageCode]
  ///
  /// Note: flag may look different for different platforms!.
  ///
  /// Note 2: svg images in this package is simplified to look good at small size,
  /// these emoji may not.
  String get emoji {
    // Emoji for country
    if (countryCode?.length == 2) {
      return String.fromCharCodes([
        countryCode!.codeUnitAt(0) + emojiOffset,
        countryCode!.codeUnitAt(1) + emojiOffset
      ]);
    }

    // get country's code from languageToCountry
    final str = languageCode.toLowerCase();
    if (languageToCountry.containsKey(str)) {
      final value = languageToCountry[str];
      if (value != null && value.length > 1) {
        final cc = (value[0] as String).toUpperCase().codeUnits;
        // todo: check range!
        return String.fromCharCodes([cc[0] + emojiOffset, cc[1] + emojiOffset]);
      }
    }

    return countryCode ?? languageCode;
  }

  /// Search for a flag for the given locale
  Widget? flag(
      {FlagNotFoundFallBack? fallBack = FlagNotFoundFallBack.emojiThenFull}) {
    final str = toString();

    // check full
    var flag = findFlagFor(language: str);
    if (flag != null) return flag;

    final localeList = str.split('_');
    // create fallback
    Widget? fb;
    switch (fallBack) {
      case null:
      // nothing
      case FlagNotFoundFallBack.full:
        fb = Text(str);
      case FlagNotFoundFallBack.emojiThenFull:
        final em = emoji;
        if (em != languageCode && em != countryCode) {
          fb = Text(em);
        } else {
          fb = Text(str);
        }
      case FlagNotFoundFallBack.countryCodeThenFull:
        if (localeList.length > 1) {
          fb = Text(localeList.last);
        } else {
          fb = Text(str);
        }
      case FlagNotFoundFallBack.emojiThenCountryCodeThenFull:
        final em = emoji;
        if (em != languageCode && em != countryCode) {
          fb = Text(em);
        } else {
          if (localeList.length > 1) {
            fb = Text(localeList.last);
          } else {
            fb = Text(str);
          }
        }
      case FlagNotFoundFallBack.countryCodeThenNull:
        if (localeList.length > 1) {
          fb = Text(localeList.last);
        }
    }

    if (str.length > 2) {
      fb = findFlagFor(language: str.substring(0, 2)) ?? fb;
    }

    switch (localeList.length) {
      case 1:
      // already checked by findFlagFor(str)
      case 2:
        if (localeList.last.length != 4) {
          // second is not scriptCode
          return findFlagFor(country: localeList.last) ?? fb;
        } else {
          return fb;
        }
      case 3:
        return findFlagFor(country: localeList.last) ?? fb;
      default:
        return fb;
    }
  }
}

// extension AppLocalizationsExt on BuildContext {
//   AppLocalizations get l10n => AppLocalizations.of(this);
// }

// extension LocaleWithDelegate on Locale {
//   /// Get class with translation strings for this locale.
//   AppLocalizations get tr => lookupAppLocalizations(this);
// }
''',
    'show_select_locale_dialog': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// Show popup dialog to select Language.
Future<void> showSelectLocaleDialog(
  BuildContext context, {
  String title = 'Select language',
  double? width,
  double? height,
  SliverGridDelegate? gridDelegate,
  Function(BuildContext)? setLocaleCallBack,
  bool useEmoji = false,
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
            useEmoji: useEmoji,
            gridDelegate: gridDelegate,
            setLocaleCallBack: (context) {
              setLocaleCallBack?.call(context);
              Navigator.of(context).pop();
            },
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
    'supported_locale_names': r'''import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// A list of generated [LocaleName]s for supportedLocales.
///
/// [supportedLocales] should be the same as [MaterialApp].supportedLocales
class SupportedLocaleNames with ListMixin<LocaleName> {
  final List<Locale> supportedLocales;
  final locales = <Locale?>[];
  final names = <String>[];
  final entries = <LocaleName>[];

  SupportedLocaleNames(this.supportedLocales, {bool showOsLocale = true}) {
    if (showOsLocale) {
      locales.add(null);
      names.add(systemLocale);
      entries.add(
        LocaleName.system(flag: findFlagFor(language: systemLocale)),
      );
    }

    for (final loc in supportedLocales) {
      locales.add(loc);
      names.add(loc.toString().toLowerCase());
      entries.add(
        LocaleName(name: names.last, locale: locales.last),
      );
    }
  }

  SupportedLocaleNames.fromEntries(
    Iterable<LocaleName> list, {
    this.supportedLocales = const <Locale>[],
    bool addOsLocale = false,
  }) {
    if (addOsLocale) {
      locales.add(null);
      names.add(systemLocale);
      entries.add(
        LocaleName.system(flag: findFlagFor(language: systemLocale)),
      );
    }
    entries.addAll(list);
    for (final e in entries) {
      locales.add(e.locale);
      names.add(e.name);
    }
  }

  bool replaceLast({String? str, LocaleName? localeName}) {
    LocaleName? entry = localeName;

    if (str != null) {
      entry ??= LocaleMatcher.byName(str);
    }
    if (entry != null) {
      locales.last = entry.locale;
      names.last = entry.name;
      entries.last = entry;
      return true;
    }
    return false;
  }

  /// Will search [LocaleStore.supportedLocaleNames] for name and add it.
  bool addName(String str) {
    if (str == showOtherLocales) {
      addShowOtherLocales();
      return true;
    } else {
      final entry = LocaleMatcher.byName(str);
      if (entry != null && !entries.contains(entry)) {
        locales.add(entry.locale);
        names.add(entry.name);
        entries.add(entry);
        return true;
      }
    }
    return false;
  }

  @override
  int get length => entries.length;

  @override
  operator [](int index) {
    return entries[index];
  }

  @override
  void operator []=(int index, LocaleName entry) {
    locales[index] = entry.name == systemLocale ? null : entry.locale;
    names[index] = entry.name;
    entries[index] = entry;
  }

  @override
  set length(int newLength) {
    entries.length = newLength;
    locales.length = newLength;
    names.length = newLength;
  }

  /// Add special entry into [SupportedLocaleNames].
  ///
  /// You should make sure to handle this entry selection in your widget.
  // todo: {Null Function() onTap = ...}
  void addShowOtherLocales({
    String name = showOtherLocales,
    Widget? flag,
    // Function(BuildContext)? setLocaleCallBack,
  }) {
    locales.add(null);
    names.add(showOtherLocales);
    entries.add(
      LocaleName(
          name: names.last,
          locale: locales.last,
          flag: flag ?? flagForOtherLocales),
      // setLocaleCallBack: setLocaleCallBack
    );
  }

  /// Just flag for [showOtherLocales].
  static Widget get flagForOtherLocales =>
      ((languageToCountry[showOtherLocales]?.length ?? 0) > 2)
          ? languageToCountry[showOtherLocales]![2]
          : const Icon(Icons.expand_more);
}
''',
    'system_locale_name': r'''import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_system_locale.dart';

/// A special [LocaleName] for [systemLocale].
// todo: singleton?
class SystemLocaleName extends LocaleName {
  @override
  Locale get locale => CurrentSystemLocale.currentSystemLocale.value;

  ValueNotifier<Locale> get notifier => CurrentSystemLocale.currentSystemLocale;

  SystemLocaleName({
    super.flag,
    // super.language,
  }) : super(name: systemLocale);
}
''',
    'locale_switch_sub_widgets': <String, dynamic>{
      'drop_down_menu_language_switch':
          r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class DropDownMenuLanguageSwitch extends StatelessWidget {
  final String? title;

  final int useNLettersInsteadOfIcon;

  final bool showLeading;

  final ShapeBorder? shape;

  final Function(BuildContext)? setLocaleCallBack;

  final bool useEmoji;

  final double? width;

  const DropDownMenuLanguageSwitch({
    super.key,
    required this.locales,
    this.title,
    this.useNLettersInsteadOfIcon = 0,
    this.showLeading = true,
    this.shape = const CircleBorder(eccentricity: 0),
    this.setLocaleCallBack,
    this.useEmoji = false,
    this.width,
  });

  final SupportedLocaleNames locales;

  @override
  Widget build(BuildContext context) {
    const radius = 38.0;
    int indexOfSelected = locales.indexOf(LocaleSwitcher.current);
    if (indexOfSelected == -1) {
      indexOfSelected = 0;
    }
    final localeEntries = locales
        .map<DropdownMenuEntry<LocaleName>>(
          (e) => DropdownMenuEntry<LocaleName>(
            value: e,
            label: e.language,
            leadingIcon: showLeading
                ? SizedBox(
                    width: radius,
                    height: radius,
                    key: ValueKey('item-${e.name}'),
                    child: FittedBox(
                        child: LangIconWithToolTip(
                      useEmoji: useEmoji,
                      localeNameFlag: e,
                      radius: radius,
                      useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                      shape: shape,
                    )),
                  )
                : null,
          ),
        )
        .toList();

    return DropdownMenu<LocaleName>(
      width: width,
      initialSelection: LocaleSwitcher.current,
      leadingIcon: showLeading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: radius - 8,
                child: FittedBox(
                  child: localeEntries[indexOfSelected].leadingIcon!,
                ),
              ),
            )
          : null,
      // controller: colorController,
      label: title != null ? Text(title!) : null,
      dropdownMenuEntries: localeEntries,
      onSelected: (LocaleName? langCode) {
        if (langCode != null) {
          if (langCode.name == showOtherLocales) {
            showSelectLocaleDialog(
              context,
              useEmoji: useEmoji,
              setLocaleCallBack: setLocaleCallBack,
            );
          } else {
            LocaleSwitcher.current = langCode;
            setLocaleCallBack?.call(context);
          }
        }
      },
      enableSearch: true,
    );
  }
}

// class LeadingIcon extends StatelessWidget {
//   const LeadingIcon({
//     super.key,
//     required this.radius,
//     required this.localeEntries,
//     required this.indexOfSelected,
//   });
//
//   final double radius;
//   final List<DropdownMenuEntry<LocaleName>> localeEntries;
//   final int indexOfSelected;
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     if (runtimeType != other.runtimeType) return false;
//     return (other as LeadingIcon).key == key;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         height: radius - 8,
//         child: FittedBox(
//           child: ValueListenableBuilder(
//               valueListenable: LocaleSwitcher.localeIndex,
//               builder: (context, index, _) {
//                 return localeEntries[indexOfSelected].leadingIcon!;
//               }),
//         ),
//       ),
//     );
//   }
// }
''',
      'grid_of_languages': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// This is the [GridView] used by [showSelectLocaleDialog] internally.
class GridOfLanguages extends StatelessWidget {
  final SliverGridDelegate? gridDelegate;
  final Function(BuildContext)? setLocaleCallBack;

  final ShapeBorder? shape;

  final bool useEmoji;

  const GridOfLanguages({
    super.key,
    this.gridDelegate,
    this.setLocaleCallBack,
    this.shape = const CircleBorder(eccentricity: 0),
    this.useEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    final locales = LocaleStore.supportedLocaleNames;

    return GridView(
      gridDelegate: gridDelegate ??
          const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
      children: [
        ...locales.map((locNameFlag) {
          final lang = languageToCountry[locNameFlag] ??
              [locNameFlag.name, locNameFlag.language];
          return Card(
            child: InkWell(
              onTap: () {
                LocaleSwitcher.current = locNameFlag;
                setLocaleCallBack?.call(context);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: LangIconWithToolTip(
                        useEmoji: useEmoji,
                        localeNameFlag: locNameFlag,
                        shape: shape,
                      ),
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
import 'package:locale_switcher/locale_switcher.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final SupportedLocaleNames locales;
  final int useNLettersInsteadOfIcon;

  final double? radius;

  final ShapeBorder? shape;

  final Function(BuildContext)? setLocaleCallBack;

  final bool useEmoji;

  final double? width;

  const SegmentedButtonSwitch({
    super.key,
    required this.locales,
    this.useNLettersInsteadOfIcon = 0,
    this.radius,
    this.shape,
    this.setLocaleCallBack,
    this.useEmoji = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final height = (radius ?? (useEmoji ? 42 : 34));
    final segmentedButton = LayoutBuilder(
      builder: (context, constrains) {
        final inSet = (constrains.maxHeight - height) / 2;
        double scale = 1;
        if (constrains.maxWidth < (width ?? 0)) {
          scale = constrains.maxWidth / width! / 3;
        } else if (constrains.maxWidth < (height * 3 * locales.length)) {
          scale = constrains.maxWidth / (height * 3 * locales.length) / 3;
        }

        return SegmentedButton<LocaleName>(
          emptySelectionAllowed: false,
          showSelectedIcon: false,
          segments: locales.map<ButtonSegment<LocaleName>>(
            (e) {
              return ButtonSegment<LocaleName>(
                value: e,
                tooltip: e.language,
                label: Padding(
                  padding:
                      // e.name == systemLocale
                      //     ? const EdgeInsets.all(0.0)
                      //     :
                      EdgeInsets.fromLTRB(
                          inSet * scale, inSet, inSet * scale, inSet),
                  child: LangIconWithToolTip(
                    useEmoji: useEmoji,
                    localeNameFlag: e,
                    radius: e.name == systemLocale ? (radius ?? 36) : height,
                    useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                    shape: shape,
                  ),
                ),
              );
            },
          ).toList(),
          selected: {LocaleSwitcher.current},
          multiSelectionEnabled: false,
          onSelectionChanged: (Set<LocaleName> newSelection) {
            if (newSelection.first.name == showOtherLocales) {
              showSelectLocaleDialog(context,
                  setLocaleCallBack: setLocaleCallBack);
            } else {
              LocaleSwitcher.current = newSelection.first;
              setLocaleCallBack?.call(context);
            }
          },
        );
      },
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: segmentedButton,
      );
    } else {
      return segmentedButton;
    }
  }
}
''',
      'select_locale_button': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/current_locale.dart';

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

  final Function(BuildContext)? setLocaleCallBack;

  final bool useEmoji;

  const SelectLocaleButton({
    super.key,
    this.updateIconOnChange = true,
    this.toolTipPrefix = 'Current language: ',
    this.radius = 32,
    this.useStaticIcon,
    this.popUpWindowTitle = "",
    this.useNLettersInsteadOfIcon = 0,
    this.shape = const CircleBorder(eccentricity: 0),
    this.setLocaleCallBack,
    this.useEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CurrentLocale.allNotifiers,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: useStaticIcon ??
              LangIconWithToolTip(
                useEmoji: useEmoji,
                toolTipPrefix: toolTipPrefix,
                localeNameFlag: LocaleSwitcher.current,
                radius: radius,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
          onPressed: () => showSelectLocaleDialog(
            context,
            title: popUpWindowTitle,
            setLocaleCallBack: setLocaleCallBack,
            useEmoji: useEmoji,
          ),
        );
      },
    );
  }
}
''',
      'title_of_locale_switch': r'''import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// Just a little helper - title for the widget [LocaleSwitch].
class TitleForLocaleSwitch extends StatelessWidget {
  const TitleForLocaleSwitch(
      {super.key,
      required this.child,
      this.title = 'Choose language:',
      this.titlePositionTop = true,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.padding = const EdgeInsets.all(8),
      this.titlePadding = const EdgeInsets.all(4),
      this.childSize});

  final Widget child;
  final Size? childSize;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;

  /// Title position,
  ///
  /// default `true` - on Top
  /// use `false` to show at Left side
  final bool titlePositionTop;
  final EdgeInsets titlePadding;
  final String? title;

  @override
  Widget build(BuildContext context) {
    double? width;
    if (child is LocaleSwitcher) {
      width = (child as LocaleSwitcher).width;
      if (childSize == null && width == null) {
        if ((child as LocaleSwitcher).type == LocaleSwitcherType.menu) {
          width = 300;
        } else {
          final shown = min((child as LocaleSwitcher).numberOfShown,
              LocaleSwitcher.supportedLocaleNames.length);
          width = shown * 2.5 * 48;
          width += (child as LocaleSwitcher).showOsLocale ? 48 : 0;
        }
      }
    }

    return LayoutBuilder(builder: (context, constrains) {
      if ((width ?? 0) > constrains.maxWidth) {
        width = constrains.maxWidth - padding.left - padding.right;
      }
      return Center(
        child: Padding(
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
                  SizedBox(
                      width: childSize?.width ?? width,
                      height: childSize?.height ?? 48,
                      child: child),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
''',
    },
  },
};
