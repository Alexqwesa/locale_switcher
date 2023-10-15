/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 30 (10 per locale)
///
/// Built on 2023-10-15 at 07:05 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, _StringsEn> {
  en(languageCode: 'en', build: _StringsEn.build),
  de(languageCode: 'de', build: _StringsDe.build),
  vi(languageCode: 'vi', build: _StringsVi.build);

  const AppLocale(
      {required this.languageCode,
      this.scriptCode,
      this.countryCode,
      required this.build}); // ignore: unused_element

  @override
  final String languageCode;
  @override
  final String? scriptCode;
  @override
  final String? countryCode;
  @override
  final TranslationBuilder<AppLocale, _StringsEn> build;

  /// Gets current instance managed by [LocaleSettings].
  _StringsEn get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
  Translations._(); // no constructor

  static _StringsEn of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, _StringsEn>(context).translations;
}

/// The provider for method B
class TranslationProvider
    extends BaseTranslationProvider<AppLocale, _StringsEn> {
  TranslationProvider({required super.child})
      : super(settings: LocaleSettings.instance);

  static InheritedLocaleData<AppLocale, _StringsEn> of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, _StringsEn>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
  _StringsEn get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, _StringsEn> {
  LocaleSettings._() : super(utils: AppLocaleUtils.instance);

  static final instance = LocaleSettings._();

  // static aliases (checkout base methods for documentation)
  static AppLocale get currentLocale => instance.currentLocale;
  static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
  static AppLocale setLocale(AppLocale locale,
          {bool? listenToDeviceLocale = false}) =>
      instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
  static AppLocale setLocaleRaw(String rawLocale,
          {bool? listenToDeviceLocale = false}) =>
      instance.setLocaleRaw(rawLocale,
          listenToDeviceLocale: listenToDeviceLocale);
  static AppLocale useDeviceLocale() => instance.useDeviceLocale();
  @Deprecated('Use [AppLocaleUtils.supportedLocales]')
  static List<Locale> get supportedLocales => instance.supportedLocales;
  @Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]')
  static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
  static void setPluralResolver(
          {String? language,
          AppLocale? locale,
          PluralResolver? cardinalResolver,
          PluralResolver? ordinalResolver}) =>
      instance.setPluralResolver(
        language: language,
        locale: locale,
        cardinalResolver: cardinalResolver,
        ordinalResolver: ordinalResolver,
      );
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, _StringsEn> {
  AppLocaleUtils._()
      : super(baseLocale: _baseLocale, locales: AppLocale.values);

  static final instance = AppLocaleUtils._();

  // static aliases (checkout base methods for documentation)
  static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
  static AppLocale parseLocaleParts(
          {required String languageCode,
          String? scriptCode,
          String? countryCode}) =>
      instance.parseLocaleParts(
          languageCode: languageCode,
          scriptCode: scriptCode,
          countryCode: countryCode);
  static AppLocale findDeviceLocale() => instance.findDeviceLocale();
  static List<Locale> get supportedLocales => instance.supportedLocales;
  static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class _StringsEn implements BaseTranslations<AppLocale, _StringsEn> {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsEn.build(
      {Map<String, Node>? overrides,
      PluralResolver? cardinalResolver,
      PluralResolver? ordinalResolver})
      : assert(overrides == null,
            'Set "translation_overrides: true" in order to enable this feature.'),
        $meta = TranslationMetadata(
          locale: AppLocale.en,
          overrides: overrides ?? {},
          cardinalResolver: cardinalResolver,
          ordinalResolver: ordinalResolver,
        ) {
    $meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <en>.
  @override
  final TranslationMetadata<AppLocale, _StringsEn> $meta;

  /// Access flat map
  dynamic operator [](String key) => $meta.getTranslation(key);

  late final _StringsEn _root = this; // ignore: unused_field

  // Translations
  late final _StringsMainScreenEn mainScreen = _StringsMainScreenEn._(_root);
  String get example => 'An example of usage of locale_switcher ';
  String get chooseLanguage => 'Please choose language';
  String get increment => 'Increment';
  String get counterDescription =>
      'You have pushed the button this many times:';
  String get showIcons => 'Show icons: ';
  String get circleOrSquare => 'Circle or square: ';
}

// Path: mainScreen
class _StringsMainScreenEn {
  _StringsMainScreenEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'An English Title';
  String counter({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: 'You pressed ${n} time.',
        other: 'You pressed ${n} times.',
      );
  String get tapMe => 'Tap me';
}

// Path: <root>
class _StringsDe implements _StringsEn {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsDe.build(
      {Map<String, Node>? overrides,
      PluralResolver? cardinalResolver,
      PluralResolver? ordinalResolver})
      : assert(overrides == null,
            'Set "translation_overrides: true" in order to enable this feature.'),
        $meta = TranslationMetadata(
          locale: AppLocale.de,
          overrides: overrides ?? {},
          cardinalResolver: cardinalResolver,
          ordinalResolver: ordinalResolver,
        ) {
    $meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <de>.
  @override
  final TranslationMetadata<AppLocale, _StringsEn> $meta;

  /// Access flat map
  @override
  dynamic operator [](String key) => $meta.getTranslation(key);

  @override
  late final _StringsDe _root = this; // ignore: unused_field

  // Translations
  @override
  late final _StringsMainScreenDe mainScreen = _StringsMainScreenDe._(_root);
  @override
  String get example => 'Ein Beispiel für die Verwendung von locale_switcher';
  @override
  String get chooseLanguage => 'Bitte wählen Sie die Sprache aus';
  @override
  String get increment => 'Erhöhen';
  @override
  String get counterDescription => 'Sie haben den Knopf so oft gedrückt:';
  @override
  String get showIcons => 'Symbole anzeigen: ';
  @override
  String get circleOrSquare => 'Kreis oder Quadrat: ';
}

// Path: mainScreen
class _StringsMainScreenDe implements _StringsMainScreenEn {
  _StringsMainScreenDe._(this._root);

  @override
  final _StringsDe _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Ein deutscher Titel';
  @override
  String counter({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(
        n,
        one: 'Du hast einmal gedrückt.',
        other: 'Du hast ${n} mal gedrückt.',
      );
  @override
  String get tapMe => 'Drück mich';
}

// Path: <root>
class _StringsVi implements _StringsEn {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsVi.build(
      {Map<String, Node>? overrides,
      PluralResolver? cardinalResolver,
      PluralResolver? ordinalResolver})
      : assert(overrides == null,
            'Set "translation_overrides: true" in order to enable this feature.'),
        $meta = TranslationMetadata(
          locale: AppLocale.vi,
          overrides: overrides ?? {},
          cardinalResolver: cardinalResolver,
          ordinalResolver: ordinalResolver,
        ) {
    $meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <vi>.
  @override
  final TranslationMetadata<AppLocale, _StringsEn> $meta;

  /// Access flat map
  @override
  dynamic operator [](String key) => $meta.getTranslation(key);

  @override
  late final _StringsVi _root = this; // ignore: unused_field

  // Translations
  @override
  late final _StringsMainScreenVi mainScreen = _StringsMainScreenVi._(_root);
  @override
  String get example => 'Một ví dụ về cách sử dụng locale_switcher';
  @override
  String get chooseLanguage => 'Vui lòng chọn ngôn ngữ';
  @override
  String get increment => 'Tăng';
  @override
  String get counterDescription => 'Bạn đã nhấn nút này nhiều lần:';
  @override
  String get showIcons => 'Hiển thị biểu tượng: ';
  @override
  String get circleOrSquare => 'Tròn hoặc vuông: ';
}

// Path: mainScreen
class _StringsMainScreenVi implements _StringsMainScreenEn {
  _StringsMainScreenVi._(this._root);

  @override
  final _StringsVi _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Tiêu đề Tiếng Viet';
  @override
  String counter({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(
        n,
        one: 'Bạn đã nhấn ${n} lần.',
        other: 'Bạn đã nhấn ${n} lần.',
      );
  @override
  String get tapMe => 'Chạm vào tôi';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
  dynamic _flatMapFunction(String path) {
    switch (path) {
      case 'mainScreen.title':
        return 'An English Title';
      case 'mainScreen.counter':
        return ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
              n,
              one: 'You pressed ${n} time.',
              other: 'You pressed ${n} times.',
            );
      case 'mainScreen.tapMe':
        return 'Tap me';
      case 'example':
        return 'An example of usage of locale_switcher ';
      case 'chooseLanguage':
        return 'Please choose language';
      case 'increment':
        return 'Increment';
      case 'counterDescription':
        return 'You have pushed the button this many times:';
      case 'showIcons':
        return 'Show icons: ';
      case 'circleOrSquare':
        return 'Circle or square: ';
      default:
        return null;
    }
  }
}

extension on _StringsDe {
  dynamic _flatMapFunction(String path) {
    switch (path) {
      case 'mainScreen.title':
        return 'Ein deutscher Titel';
      case 'mainScreen.counter':
        return ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(
              n,
              one: 'Du hast einmal gedrückt.',
              other: 'Du hast ${n} mal gedrückt.',
            );
      case 'mainScreen.tapMe':
        return 'Drück mich';
      case 'example':
        return 'Ein Beispiel für die Verwendung von locale_switcher';
      case 'chooseLanguage':
        return 'Bitte wählen Sie die Sprache aus';
      case 'increment':
        return 'Erhöhen';
      case 'counterDescription':
        return 'Sie haben den Knopf so oft gedrückt:';
      case 'showIcons':
        return 'Symbole anzeigen: ';
      case 'circleOrSquare':
        return 'Kreis oder Quadrat: ';
      default:
        return null;
    }
  }
}

extension on _StringsVi {
  dynamic _flatMapFunction(String path) {
    switch (path) {
      case 'mainScreen.title':
        return 'Tiêu đề Tiếng Viet';
      case 'mainScreen.counter':
        return ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(
              n,
              one: 'Bạn đã nhấn ${n} lần.',
              other: 'Bạn đã nhấn ${n} lần.',
            );
      case 'mainScreen.tapMe':
        return 'Chạm vào tôi';
      case 'example':
        return 'Một ví dụ về cách sử dụng locale_switcher';
      case 'chooseLanguage':
        return 'Vui lòng chọn ngôn ngữ';
      case 'increment':
        return 'Tăng';
      case 'counterDescription':
        return 'Bạn đã nhấn nút này nhiều lần:';
      case 'showIcons':
        return 'Hiển thị biểu tượng: ';
      case 'circleOrSquare':
        return 'Tròn hoặc vuông: ';
      default:
        return null;
    }
  }
}
