import 'package:flutter/cupertino.dart';
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
    return ValueListenableBuilder(
        valueListenable: LocaleSwitcher.locale,
        builder: (context, _, unUsed) => widget.child);
  }
}
