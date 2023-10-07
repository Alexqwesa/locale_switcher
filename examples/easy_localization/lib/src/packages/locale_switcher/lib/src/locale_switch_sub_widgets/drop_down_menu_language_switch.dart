import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class DropDownMenuLanguageSwitch extends StatelessWidget {
  final String? title;

  final int useNLettersInsteadOfIcon;

  final bool showLeading;

  final ShapeBorder? shape;

  final Function(BuildContext)? setLocaleCallBack;

  const DropDownMenuLanguageSwitch({
    super.key,
    required this.locales,
    this.title,
    this.useNLettersInsteadOfIcon = 0,
    this.showLeading = true,
    this.shape = const CircleBorder(eccentricity: 0),
    this.setLocaleCallBack,
  });

  final LocaleNameFlagList locales;

  @override
  Widget build(BuildContext context) {
    const radius = 38.0;
    final localeEntries = locales
        .map<DropdownMenuEntry<LocaleNameFlag>>(
          (e) => DropdownMenuEntry<LocaleNameFlag>(
            value: e,
            label: e.language,
            leadingIcon: showLeading
                ? SizedBox(
                    width: radius,
                    height: radius,
                    key: ValueKey('item-${e.name}'),
                    child: FittedBox(
                        child: LangIconWithToolTip(
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

    return DropdownMenu<LocaleNameFlag>(
      initialSelection: CurrentLocale.current,
      leadingIcon: showLeading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: LangIconWithToolTip(
                // key: const ValueKey('DDMLeading'), // todo: bugreport this duplicate
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
            showSelectLocaleDialog(context,
                setLocaleCallBack: setLocaleCallBack);
          } else {
            CurrentLocale.current = langCode;
            setLocaleCallBack?.call(context);
          }
        }
      },
      enableSearch: true,
    );
  }
}
