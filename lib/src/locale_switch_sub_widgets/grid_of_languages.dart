import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// This is the [GridView] used by [showSelectLocaleDialog] internally.
class GridOfLanguages extends StatelessWidget {
  final SliverGridDelegate? gridDelegate;
  final Function(BuildContext)? setLocaleCallBack;

  final ItemBuilder itemBuilder;

  const GridOfLanguages({
    super.key,
    this.gridDelegate,
    this.setLocaleCallBack,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final locales = LocaleStore.supportedLocaleNames;

    return GridView(
      gridDelegate: gridDelegate ??
          const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
      children: [
        ...locales.map((final LocaleName locNameFlag) {
          final lang = languageToCountry[locNameFlag.name] ??
              [locNameFlag.name, locNameFlag.language];
          return Card(
            child: InkWell(
              onTap: () {
                LocaleSwitcher.current = locNameFlag;
                setLocaleCallBack?.call(context);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FittedBox(child: itemBuilder(locNameFlag))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      lang[1],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                ],
              ),
            ),
          );
        })
      ],
    );
  }
}
