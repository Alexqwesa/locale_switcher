import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

class SelectLocaleButton extends StatelessWidget {
  const SelectLocaleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: LocaleStore.languageToCountry[showOtherLocales]?[2] ??
          const Icon(Icons.language),
      tooltip: LocaleStore.languageToCountry[showOtherLocales]?[1] ??
          "Other locales",
      onPressed: () => showSelectLocaleDialog(context),
    );
  }
}

Future<void> showSelectLocaleDialog(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select language'),
        content: SizedBox(
          width: size.width * 0.6,
          height: size.height * 0.6,
          child: const ListOfLanguages(),
        ),
        actions: <Widget>[
          Row(
            children: [
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
            ],
          )
        ],
      );
    },
  );
}

class ListOfLanguages extends StatelessWidget {
  const ListOfLanguages({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = [
      LocaleStore.systemLocale,
      ...?LocaleStore.supportedLocales?.map((e) => e.languageCode),
    ];

    return GridView(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
      ),
      children: [
        ...locales.map((e) {
          final lang =
              LocaleStore.languageToCountry[e] ?? [e, 'Unknown locale'];
          return InkWell(
            onTap: () {
              LocaleStore.setLocale(e);
              Navigator.of(context).pop();
            },
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: FittedBox(
                      child: (lang.length > 2)
                          ? ClipOval(child: lang[2])
                          : CircleFlag(
                              (lang[0] as String).toLowerCase(),
                              size: 30,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      lang[1],
                      style: Theme.of(context).textTheme.titleLarge,
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
