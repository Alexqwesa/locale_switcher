import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/src/locale_store.dart';

//todo:
/// An alternative to LocaleManager,
// Future<void> openStorageAndReadLocale({
//   ifReadEmpty = LocaleStore.systemLocale,
// }) async {
//   return LocaleStore.init();
// }

/// This should be a parent to either [MaterialApp] or [CupertinoApp].
///
/// It will:
/// - observe system locale,
/// - listen to locale change [],
/// - save current locale to [SharedPreference].
class LocaleManager extends StatefulWidget {
  /// Either [MaterialApp] or [CupertinoApp].
  final Widget child;

  /// Store locale in [SharedPreferences].
  final bool storeLocale;

  /// A name of key used to store locale in [SharedPreferences].
  final String sharedPreferenceName;

  /// Make sure what static data only initialized once.
  static bool isInitialized = false;

  /// A [ValueListenable] with current locale.
  static ValueNotifier<Locale> get locale => LocaleStore.locale;

  const LocaleManager({
    super.key,
    required this.child,
    this.storeLocale = true,
    this.sharedPreferenceName = 'LocaleSwitcherCurrentLocale',
  });

  @override
  State<LocaleManager> createState() => _LocaleManagerState();
}

class _LocaleManagerState extends State<LocaleManager> {
  void updateParent() => setState(() {
        context.visitAncestorElements((element) {
          element.markNeedsBuild();
          return false;
        });
      });

  @override
  void initState() {
    if (!LocaleManager.isInitialized) {
      // init LocaleStore
      final child = widget.child;
      LocaleStore.initSystemLocaleObserver();
      if (child.runtimeType == MaterialApp) {
        final delegate = (child as MaterialApp).localizationsDelegates?.first;
        final supportedLocales = child.supportedLocales.toList(growable: false);
        if (delegate == null) {
          throw UnsupportedError(
              'MaterialApp should have initialized: delegate and supportedLocales parameters');
        }
        LocaleStore.setLocaleAndDelegate(supportedLocales, delegate);
      } else if (child.runtimeType == CupertinoApp) {
        final delegate = (child as CupertinoApp).localizationsDelegates?.first;
        final supportedLocales = child.supportedLocales.toList(growable: false);
        if (delegate == null) {
          throw UnsupportedError(
              'CupertinoApp should have initialized: delegate and supportedLocales parameters');
        }
        LocaleStore.setLocaleAndDelegate(supportedLocales, delegate);
      } else {
        throw UnimplementedError(
            "The child should be either CupertinoApp or MaterialApp class");
      }
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
