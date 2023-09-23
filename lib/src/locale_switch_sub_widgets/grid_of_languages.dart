import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// This is the [GridView] used by [showSelectLocaleDialog] internally.
class GridOfLanguages extends StatelessWidget {
  final SliverGridDelegate? gridDelegate;
  final Function(BuildContext)? additionalCallBack;

  const GridOfLanguages({
    super.key,
    this.gridDelegate,
    this.additionalCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final locales = [
      LocaleStore.systemLocale,
      ...LocaleStore.supportedLocales.map((e) => e.languageCode),
    ];

    return GridView(
      gridDelegate: gridDelegate ??
          const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
      children: [
        ...locales.map((langCode) {
          final lang = LocaleStore.languageToCountry[langCode] ??
              [langCode, 'Unknown locale'];
          return InkWell(
            onTap: () {
              LocaleManager.languageCode.value = langCode;
              additionalCallBack?.call(context);
            },
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: LangIconWithToolTip(langCode: langCode),
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
