import 'package:flutter/material.dart';
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
