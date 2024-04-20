import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

class DropDownMenuLanguageSwitch extends StatelessWidget {
  final ItemBuilder itemBuilder;

  final LocaleSwitcher widget;

  const DropDownMenuLanguageSwitch({
    super.key,
    required this.locales,
    required this.itemBuilder,
    required this.widget,
  });

  final SupportedLocaleNames locales;

  @override
  Widget build(BuildContext context) {
    final radius = widget.iconRadius;
    int indexOfSelected = locales.indexOf(LocaleSwitcher.current);
    if (indexOfSelected == -1) {
      indexOfSelected = 0;
    }
    final localeEntries = locales
        .map<DropdownMenuEntry<LocaleName>>(
          (e) => DropdownMenuEntry<LocaleName>(
            value: e,
            label: e.language,
            leadingIcon: widget.showLeading
                ? SizedBox(
                    width: radius,
                    height: radius,
                    key: ValueKey('item-${e.name}'),
                    child: itemBuilder(e),
                  )
                : null,
          ),
        )
        .toList();

    return DropdownMenu<LocaleName>(
      width: widget.width,
      initialSelection: LocaleSwitcher.current,
      leadingIcon: widget.showLeading
          ? Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: max(0, radius - 8),
                child: FittedBox(
                  child: localeEntries[indexOfSelected].leadingIcon!,
                ),
              ),
            )
          : null,
      // controller: colorController,
      label: widget.title != null ? Text(widget.title!) : null,
      dropdownMenuEntries: localeEntries,
      onSelected: (LocaleName? langCode) {
        if (langCode != null) {
          if (langCode.name == showOtherLocales) {
            showSelectLocaleDialog(
              context,
              useEmoji: widget.useEmoji,
              setLocaleCallBack: widget.setLocaleCallBack,
            );
          } else {
            LocaleSwitcher.current = langCode;
            widget.setLocaleCallBack?.call(context);
          }
        }
      },
      enableSearch: true,
    );
  }
}
