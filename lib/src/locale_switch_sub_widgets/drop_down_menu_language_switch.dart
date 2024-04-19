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

// class LeadingIcon extends StatelessWidget {
//   const LeadingIcon({
//     super.key,
//     required this.radius,
//     required this.localeEntries,
//     required this.indexOfSelected,
//   });
//
//   final double radius;
//   final List<DropdownMenuEntry<LocaleName>> localeEntries;
//   final int indexOfSelected;
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     if (runtimeType != other.runtimeType) return false;
//     return (other as LeadingIcon).key == key;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         height: radius - 8,
//         child: FittedBox(
//           child: ValueListenableBuilder(
//               valueListenable: LocaleSwitcher.localeIndex,
//               builder: (context, index, _) {
//                 return localeEntries[indexOfSelected].leadingIcon!;
//               }),
//         ),
//       ),
//     );
//   }
// }
