import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  /// Current language code, could be 'system'.
  ///
  /// Value of this notifier should be either from [supportedLocales] or 'system'.
  static ValueNotifier<String> get realLocaleNotifier =>
      LocaleStore.realLocaleNotifier;

  /// A [ValueListenable] with current locale.
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
