import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// This is the [GridView] used by [showSelectLocaleDialog] internally.
class GridOfLanguages extends StatelessWidget {
  final SliverGridDelegate? gridDelegate;
  final Function(BuildContext)? additionalCallBack;

  final ShapeBorder? shape;

  const GridOfLanguages({
    super.key,
    this.gridDelegate,
    this.additionalCallBack,
    this.shape = const CircleBorder(eccentricity: 0),
  });

  @override
  Widget build(BuildContext context) {
    final locales = [
      LocaleStore.systemLocale,
      ...LocaleStore.supportedLocales.map((e) => e.toLanguageTag()),
    ];

    return GridView(
      gridDelegate: gridDelegate ??
          const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
      children: [
        ...locales.map((localeCode) {
          final lang = LocaleStore.languageToCountry[localeCode] ??
              [localeCode, 'Unknown locale'];
          return Card(
            child: InkWell(
              onTap: () {
                LocaleManager.languageTag.value = localeCode;
                additionalCallBack?.call(context);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child:
                          LangIconWithToolTip(localeCode: localeCode, shape: shape),
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
