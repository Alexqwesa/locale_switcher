import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

class DropDownMenuLanguageSwitch extends StatelessWidget {
  final String? title;

  const DropDownMenuLanguageSwitch({
    super.key,
    required this.locales,
    this.title,
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
            leadingIcon: SizedBox(
              width: radius,
              height: radius,
              key: ValueKey('item-$e'),
              child: FittedBox(
                child: (LocaleStore.languageToCountry[e] ?? const []).length > 2
                    ? LocaleStore.languageToCountry[e]![2] ??
                        getIconForLanguage(e, null, radius)
                    : getIconForLanguage(e, null, radius),
              ),
            ),
          ),
        )
        .toList();

    return DropdownMenu<String>(
      initialSelection: LocaleStore.realLocaleNotifier.value,
      leadingIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            getIconForLanguage(LocaleStore.realLocaleNotifier.value, null, 32),
      ),
      // controller: colorController,
      label: const Text('Language'),
      dropdownMenuEntries: localeEntries,
      onSelected: (String? langCode) {
        if (langCode != null) {
          if (langCode == showOtherLocales) {
            showSelectLocaleDialog(context);
          } else {
            LocaleManager.realLocaleNotifier.value = langCode;
          }
        }
      },
      enableSearch: true,
    );
  }
}
