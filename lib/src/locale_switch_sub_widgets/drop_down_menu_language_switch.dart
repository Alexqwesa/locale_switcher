import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class DropDownMenuLanguageSwitch extends StatelessWidget {
  final String? title;

  final int useNLettersInsteadOfIcon;

  final bool showLeading;

  final ShapeBorder? shape;

  final Function(BuildContext)? setLocaleCallBack;

  final bool useEmoji;

  final double width;

  const DropDownMenuLanguageSwitch({
    super.key,
    required this.locales,
    this.title,
    this.useNLettersInsteadOfIcon = 0,
    this.showLeading = true,
    this.shape = const CircleBorder(eccentricity: 0),
    this.setLocaleCallBack,
    this.useEmoji = false,
    this.width = 250,
  });

  final SupportedLocaleNames locales;

  @override
  Widget build(BuildContext context) {
    const radius = 38.0;
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
              child: LangIconWithToolTip(
                useEmoji: useEmoji,
                // key: GlobalKey(),  // post frame callback error - bugreport
                // key: const ValueKey('DDMLeading'), // todo: bugreport this duplicate
                localeNameFlag: LocaleSwitcher.current,
                radius: 32,
                useNLettersInsteadOfIcon: useNLettersInsteadOfIcon,
                shape: shape,
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
