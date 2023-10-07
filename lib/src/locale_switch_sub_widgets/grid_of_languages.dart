import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// This is the [GridView] used by [showSelectLocaleDialog] internally.
class GridOfLanguages extends StatelessWidget {
  final SliverGridDelegate? gridDelegate;
  final Function(BuildContext)? setLocaleCallBack;

  final ShapeBorder? shape;

  const GridOfLanguages({
    super.key,
    this.gridDelegate,
    this.setLocaleCallBack,
    this.shape = const CircleBorder(eccentricity: 0),
  });

  @override
  Widget build(BuildContext context) {
    final locales = LocaleStore.localeNameFlags;

    return GridView(
      gridDelegate: gridDelegate ??
          const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
      children: [
        ...locales.map((langCode) {
          final lang = LocaleStore.languageToCountry[langCode] ??
              [langCode.name, langCode.language];
          return Card(
            child: InkWell(
              onTap: () {
                CurrentLocale.current = langCode;
                setLocaleCallBack?.call(context);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: LangIconWithToolTip(
                          localeNameFlag: langCode, shape: shape),
                    ),
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
