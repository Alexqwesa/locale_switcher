final package = <String, dynamic>{  'locale_switcher': r'''/// # A widget for switching the locale of your application.
///
library locale_switcher;

export 'package:locale_switcher/src/lang_icon_with_tool_tip.dart';
export 'package:locale_switcher/src/locale_manager.dart';
export 'package:locale_switcher/src/locale_name_flag_list.dart';
export 'package:locale_switcher/src/public_extensions.dart';
export 'package:locale_switcher/src/locale_switcher.dart';
export 'package:locale_switcher/src/show_select_locale_dialog.dart';
''',
 
    'src': <String, dynamic>{  'lang_icon_with_tool_tip': r'''import 'package:flutter/material.dart';
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
''',
  'locale_manager': r'''import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

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

  /// [ValueNotifier] with index of [localeNameFlags] currently used.
  static ValueNotifier<int> get localeIndex => CurrentLocale.notifier;

  /// A list of generated [LocaleNameFlag]s for supportedLocales.
  ///
  /// [supportedLocales] should be the same as [MaterialApp].supportedLocales
  static LocaleNameFlagList get localeNameFlags => LocaleStore.localeNameFlags;

  /// A [ValueListenable] with current locale.
  ///
  /// Use [LocaleStore.localeIndex] to update this notifier.
  // static ValueNotifier<Locale> get locale => LocaleStore.locale;

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
    ///     child: MaterialApp(
    ///       locale: CurrentLocale.current.locale,
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
    ///       locale: CurrentLocale.current.locale,
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

  /// init [LocaleStore]'s supportedLocales
  void _readAppLocalization(Widget child) {
    // LocaleStore.initSystemLocaleObserverAndLocaleUpdater();
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

    CurrentLocale.allNotifiers.addListener(updateParent);

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
    CurrentLocale.allNotifiers.removeListener(updateParent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
''',
  'locale_name_flag_list': r'''import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_observable.dart';
import 'package:locale_switcher/src/locale_store.dart';
import 'package:locale_switcher/src/preference_repository.dart';

class CurrentSystemLocale {
  static LocaleObserver? __observer;

  /// Listen on system locale.
  static ValueNotifier<Locale> get currentSystemLocale {
    initSystemLocaleObserverAndLocaleUpdater();
    return __currentSystemLocale;
  }

  static final __currentSystemLocale = ValueNotifier(const Locale('en'));

  static void initSystemLocaleObserverAndLocaleUpdater() {
    if (__observer == null) {
      WidgetsFlutterBinding.ensureInitialized();
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

abstract class CurrentLocale extends CurrentSystemLocale {
  static late final ValueNotifier<int> _allNotifiers;

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

  static LocaleNameFlagList get store => LocaleStore.localeNameFlags;

  static ValueNotifier<int> get notifier => _index;
  static final _index = ValueNotifier(0);

  static int get index => _index.value;

  static set index(int value) {
    if (value < LocaleStore.localeNameFlags.length && value >= 0) {
      _index.value = value;

      PreferenceRepository.write(
          LocaleStore.innerSharedPreferenceName, current.name);
    }
  }

  static LocaleNameFlag get current => LocaleStore.localeNameFlags[index];

  static set current(LocaleNameFlag value) {
    var idx = LocaleStore.localeNameFlags.indexOf(value);
    if (idx >= 0 && idx < LocaleStore.localeNameFlags.length) {
      index = idx;
    } else {
      idx = LocaleStore.localeNameFlags.indexOf(byName(value.name));
      if (idx >= 0 && idx < LocaleStore.localeNameFlags.length) {
        index = idx;
      }
    }
  }

  static LocaleNameFlag? byName(String name) {
    if (store.names.contains(name)) {
      return store.entries[store.names.indexOf(name)];
    }
    return null;
  }

  static LocaleNameFlag? byLocale(Locale locale) {
    if (store.locales.contains(locale)) {
      return store.entries[store.locales.indexOf(locale)];
    }
    return null;
  }

  // todo try more
  // read all user locales? similarity check?
  static void tryToSetLocale(String langCode) {
    var loc = byName(langCode);
    if (loc != null) {
      current = loc; //??  byName(LocaleStore.systemLocale) ;
    }
  }

  static Widget get flagForOtherLocalesButton => LocaleSwitcher.iconButton(
        useStaticIcon:
            ((LocaleStore.languageToCountry[showOtherLocales]?.length ?? 0) > 2)
                ? LocaleStore.languageToCountry[showOtherLocales]![2]
                : const Icon(Icons.expand_more),
      );
}

// supportedLocalesWithFlags
// current locale
// with Notifier?
/// A list of generated [LocaleNameFlag]s for supportedLocales.
///
/// [supportedLocales] should be the same as [MaterialApp].supportedLocales
class LocaleNameFlagList with ListMixin<LocaleNameFlag> {
  final List<Locale> supportedLocales;
  final locales = <Locale?>[];
  final names = <String>[];

// final flags = <Widget?>[];

  final entries = <LocaleNameFlag>[];

  LocaleNameFlagList(this.supportedLocales, {bool showOsLocale = true}) {
    if (showOsLocale) {
      locales.add(null);
      names.add(LocaleStore.systemLocale);
      entries.add(
        SystemLocaleNameFlag(flag: findFlagFor(LocaleStore.systemLocale)),
      );
    }

    for (final loc in supportedLocales) {
      locales.add(loc);
      names.add(loc.toString());
      entries.add(
        LocaleNameFlag(name: names.last, locale: locales.last),
      );
    }
  }

  LocaleNameFlagList.fromEntries(
    Iterable<LocaleNameFlag> list, {
    this.supportedLocales = const <Locale>[],
    bool addOsLocale = false,
  }) {
    if (addOsLocale) {
      locales.add(null);
      names.add(LocaleStore.systemLocale);
      entries.add(
        LocaleNameFlag(
            name: names.last,
            locale: locales.last,
            flag: findFlagFor(LocaleStore.systemLocale)),
      );
    }
    entries.addAll(list);
    for (final e in entries) {
      locales.add(e.locale);
      names.add(e.name);
    }
  }

  bool replaceLast({String? str, LocaleNameFlag? localeName}) {
    LocaleNameFlag? entry = localeName;

    if (str != null) {
      entry ??= CurrentLocale.byName(str);
    }
    if (entry != null) {
      locales.last = entry.locale;
      names.last = entry.name;
      entries.last = entry;
      return true;
    }
    return false;
// final loc = str.toLocale();
// locales.last = loc;
// names.last = loc.toString();
// entries.last = LocaleNameFlag(
//     name: names.last, locale: locales.last, flag: flags.last);
  }

  /// Will search [LocaleStore.localeNameFlags] for name and add it.
  void addName(String str) {
    if (str == showOtherLocales) {
      locales.add(null);
      names.add(showOtherLocales);
      entries.add(
        LocaleNameFlag(
            name: names.last,
            locale: locales.last,
            flag: CurrentLocale.flagForOtherLocalesButton),
      );
    } else {
      final entry = CurrentLocale.byName(str);
      if (entry != null) {
        locales.add(entry.locale);
        names.add(entry.name);
        entries.add(entry);
      }
    }
  }

  @override
  int get length => entries.length;

  @override
  operator [](int index) {
    return entries[index];
  }

  @override
  void operator []=(int index, LocaleNameFlag entry) {
    locales[index] = entry.locale;
    names[index] = entry.name;
    entries[index] = entry;
  }

  @override
  set length(int newLength) {
    entries.length = newLength;
    locales.length = newLength;
    names.length = newLength;
  }
}

/// Just record of [Locale], it's name and flag.
class LocaleNameFlag {
  String? _language;

  Widget? _flag;

  final String name;

  final Locale? locale;

  LocaleNameFlag({
    this.name = '',
    this.locale,
    Widget? flag,
    String? language,
  })  : _flag = flag,
        _language = language;

  Widget? get flag {
    // todo not null
    _flag ??= locale?.flag() ?? findFlagFor(name);
    return _flag;
  }

  String get language {
    _language ??= (LocaleStore.languageToCountry[name]?[1]! ??
            LocaleStore.languageToCountry[name.substring(0, 2)]) ??
        '';
    return _language!;
  }
}

/// Just record of [Locale], it's name and flag.
class SystemLocaleNameFlag extends LocaleNameFlag {
  @override
  Locale get locale => CurrentSystemLocale.currentSystemLocale.value;

  ValueNotifier<Locale> get notifier =>
      CurrentSystemLocale.currentSystemLocale;

  SystemLocaleNameFlag({
    super.flag,
    super.language,
  }) : super(name: LocaleStore.systemLocale);
}
''',
  'locale_observable': r'''
import 'package:flutter/foundation.dart';
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

// extension AppLocalizationsExt on BuildContext {
//   AppLocalizations get l10n => AppLocalizations.of(this);
// }

// extension LocaleWithDelegate on Locale {
//   /// Get class with translation strings for this locale.
//   AppLocalizations get tr => lookupAppLocalizations(this);
// }

abstract class LocaleStore {
  /// A special locale name to use system locale.
  static const String systemLocale = 'system';

  // todo: use ChangeNotifier to check values.
  // todo: store list of recently used locales
  /// Value of this notifier should be either from [supportedLocales] or 'system'.
  // static ValueNotifier<String> get languageCode {
  //   if (__observer == null) {
  //     initSystemLocaleObserverAndLocaleUpdater();
  //     // todo: try to read pref here?
  //   }
  //   return _languageCode;
  // }

  /// Current [Locale], use [LocaleStore.setLocale] to update it.
  ///
  /// [LocaleStore.localeIndex] contains the real value that stored in [SharedPreferences].
  // static ValueNotifier<Locale> get locale {
  //   if (__observer == null) {
  //     initSystemLocaleObserverAndLocaleUpdater();
  //     _locale.value = TestablePlatformDispatcher.platformDispatcher.locale;
  //   }
  //   return _locale;
  // }

  /// List of supported locales.
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static List<Locale> supportedLocales = [];

  /// List of helpers based on supported locales - [LocaleNameFlag].
  ///
  /// Usually setup by [LocaleManager], but have fallBack setup in [LocaleSwitcher].
  static LocaleNameFlagList localeNameFlags =
      LocaleNameFlagList(<Locale>[const Locale('en', 'US')]);

  /// If initialized: locale will be stored in [SharedPreferences].
  static get _pref => PreferenceRepository.pref;

  // static final _locale = ValueNotifier<Locale>(const Locale('en'));
  // static final _languageCode = ValueNotifier<String>(systemLocale);
  //
  // static LocaleObserver? __observer;

  /// Set locale with checks.
  ///
  /// It save locale into [SharedPreferences],
  /// and allow to use [systemLocale].
  // static void _setLocale(String langCode) {
  //   late Locale newLocale;
  //   if (langCode == systemLocale || langCode == '') {
  //     newLocale = TestablePlatformDispatcher.platformDispatcher.locale;
  //     // languageCode.value = systemLocale;
  //   } else if (langCode == showOtherLocales) {
  //     newLocale = locale.value; // on error: leave current
  //     dev.log('Error wrong locale name: $showOtherLocales');
  //   } else {
  //     newLocale = Locale(langCode);
  //     // languageCode.value = newLocale.toString();
  //   }
  //
  //   PreferenceRepository.write(innerSharedPreferenceName, languageCode.value);
  //   locale.value = newLocale;
  // }

  // AppLocalizations get tr => lookupAppLocalizations(locale);

  /// A name of key used to store locale in [SharedPreferences].
  ///
  /// Set it via [LocaleManager].[sharedPreferenceName]
  static String innerSharedPreferenceName = 'LocaleSwitcherCurrentLocale';

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

  /// Init [LocaleStore] class.
  ///
  /// - It also init and read [SharedPreferences] (if available).
  static Future<void> init({
    List<Locale>? supportedLocales,
    // LocalizationsDelegate? delegate,
    sharedPreferenceName = 'LocaleSwitcherCurrentLocale',
  }) async {
    if (_pref == null) {
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
        langCode =
            PreferenceRepository.read(innerSharedPreferenceName) ?? langCode;
        CurrentLocale.tryToSetLocale(langCode);
      }
    }
  }

  static void setSupportedLocales(
    List<Locale>? supportedLocales,
  ) {
    if (supportedLocales != null) {
      LocaleStore.supportedLocales = supportedLocales;
      LocaleStore.localeNameFlags = LocaleNameFlagList(supportedLocales);
    }
  }
}
''',
  'locale_switcher': r'''import 'package:flutter/cupertino.dart';
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
/// Use either:
/// - [LocaleSwitcher.segmentedButton],
/// - [LocaleSwitcher.iconButton],
/// - [LocaleSwitcher.menu],
/// - [LocaleSwitcher.custom].
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
    if (LocaleStore.supportedLocales.isEmpty) { // todo: use CurrentLocale
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
      valueListenable: CurrentLocale.notifier,
      builder: (BuildContext context, index, Widget? child) {
        var locales = LocaleNameFlagList.fromEntries(staticLocales.entries);
        if (!locales.names.contains(CurrentLocale.current.name)) {
          locales.replaceLast(localeName: CurrentLocale.current);
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
  'preference_repository_easy_localization': r'''import 'dart:developer' as dev;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_switcher/src/locale_name_flag_list.dart';

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
    if (context != null && CurrentLocale.current.locale != null) {
      await EasyLocalization.of(context)
          ?.setLocale(CurrentLocale.current.locale!);
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
  'public_extensions': r'''import 'package:flutter/widgets.dart';
import 'package:locale_switcher/src/generated/asset_strings.dart';
import 'package:locale_switcher/src/locale_store.dart';

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

enum LocaleNotFoundFallBack {
  full,
  countryCodeThenFull,
}

Widget? findFlagFor(String str) {
  final value = LocaleStore.languageToCountry[str] ?? const [];
  if (value.length > 2 && value[2] != null) return value[2];
  if (countryCodeToContent.containsKey(value[1])) {
    return Flags.instance[value[1]]?.svg;
  }
  return null;
}

extension LocaleFlag on Locale {
  /// Search for flag for given locale
  Widget flag({LocaleNotFoundFallBack fallBack = LocaleNotFoundFallBack.full}) {
    final str = toString();
    // check full
    final flag = findFlagFor(str);
    if (flag != null) return flag;

    final localeList = str.split('_');
    // create fallback
    late final Widget fb;
    if (fallBack == LocaleNotFoundFallBack.full) {
      fb = Text(str);
    } else if (fallBack == LocaleNotFoundFallBack.countryCodeThenFull) {
      if (localeList.length > 1) {
        fb = Text(localeList.last);
      } else {
        fb = Text(str);
      }
    } else {
      fb = Text(str.substring(0, 2));
    }

    switch (localeList.length) {
      case 1:
      // already checked by findFlagFor(str)
      case 2:
        if (localeList.last.length != 4) {
          // second is not scriptCode
          return findFlagFor(localeList.last) ?? fb;
        } else {
          return findFlagFor(localeList.first) ?? fb;
        }
      case 3:
        final flag = findFlagFor(localeList.last);
        if (flag != null) return flag;
        return findFlagFor(localeList.first) ?? fb;
      default:
        return fb;
    }
  }
}
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
 
    'locale_switch_sub_widgets': <String, dynamic>{  'drop_down_menu_language_switch': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

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

  final LocaleNameFlagList locales;

  @override
  Widget build(BuildContext context) {
    const radius = 38.0;
    final localeEntries = locales
        .map<DropdownMenuEntry<LocaleNameFlag>>(
          (e) => DropdownMenuEntry<LocaleNameFlag>(
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
                                  localeNameFlag: e,
                                  radius: radius,
                                  useNLettersInsteadOfIcon:
                                      useNLettersInsteadOfIcon,
                                  shape: shape,
                                )
                            : LangIconWithToolTip(
                                localeNameFlag: e,
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

    return DropdownMenu<LocaleNameFlag>(
      initialSelection: CurrentLocale.current ,
      leadingIcon: showLeading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: LangIconWithToolTip(
                localeNameFlag: CurrentLocale.current,
                radius: 32,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
              ),
            )
          : null,
      // controller: colorController,
      label: const Text('Language'),
      dropdownMenuEntries: localeEntries,
      onSelected: (LocaleNameFlag? langCode) {
        if (langCode != null) {
          if (langCode.name == showOtherLocales) {
            showSelectLocaleDialog(context);
          } else {
            CurrentLocale.current = langCode;
          }
        }
      },
      enableSearch: true,
    );
  }
}
''',
  'grid_of_languages': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

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
    final locales = LocaleStore.localeNameFlags;

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
                CurrentLocale.current = langCode;
                additionalCallBack?.call(context);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child:
                          LangIconWithToolTip(localeNameFlag: langCode, shape: shape),
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

import '../locale_store.dart';

class SegmentedButtonSwitch extends StatelessWidget {
  final LocaleNameFlagList locales;
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
    return SegmentedButton<LocaleNameFlag>(
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: locales.map<ButtonSegment<LocaleNameFlag>>(
        (e) {
          final curRadius =
              e.name == LocaleStore.systemLocale ? (radius ?? 24) * 5 : radius;
          return ButtonSegment<LocaleNameFlag>(
            value: e,
            tooltip: LocaleStore.languageToCountry[e]?[1] ?? e,
            label: Padding(
              padding: e.name == LocaleStore.systemLocale
                  ? const EdgeInsets.all(0.0)
                  : const EdgeInsets.all(8.0),
              child: FittedBox(
                child: (LocaleStore.languageToCountry[e] ?? const []).length > 2
                    ? LocaleStore.languageToCountry[e]![2] ??
                        LangIconWithToolTip(
                          localeNameFlag: e,
                          radius: curRadius,
                          useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                          shape: shape,
                        )
                    : LangIconWithToolTip(
                        localeNameFlag: e,
                        radius: curRadius,
                        useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                        shape: shape,
                      ),
              ),
            ),
          );
        },
      ).toList(),
      selected: {CurrentLocale.current},
      multiSelectionEnabled: false,
      onSelectionChanged: (Set<LocaleNameFlag> newSelection) {
        if (newSelection.first.name == showOtherLocales) {
          showSelectLocaleDialog(context);
        } else {
          CurrentLocale.current = newSelection.first;
        }
      },
    );
  }
}
''',
  'select_locale_button': r'''import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

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
      valueListenable: CurrentLocale.allNotifiers,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: useStaticIcon ??
              LangIconWithToolTip(
                toolTipPrefix: toolTipPrefix,
                localeNameFlag: CurrentLocale.current,
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