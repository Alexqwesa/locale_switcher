import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';
import 'package:locale_switcher/src/locale_store.dart';

/// IconButton to show and select a language.
///
/// In popup window will be displayed [LocaleSwitcher.grid].
class SelectLocaleButton extends StatelessWidget {
  final bool updateIconOnChange;

  final String toolTipPrefix;

  final double radius;

  final Widget? icon;

  const SelectLocaleButton({
    super.key,
    this.updateIconOnChange = true,
    this.toolTipPrefix = '',
    this.radius = 32,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocaleStore.realLocaleNotifier,
      builder: (BuildContext context, value, Widget? child) {
        return IconButton(
          icon: icon ??
              (updateIconOnChange
                  ? LangIconWithToolTip(
                      // langCode: LocaleManager.locale.value.languageCode,
                      toolTipPrefix: toolTipPrefix,
                      langCode: LocaleStore.realLocaleNotifier.value,
                      radius: radius,
                    )
                  : LocaleStore.languageToCountry[showOtherLocales]?[2] ??
                      const Icon(Icons.language)),
          tooltip: LocaleStore.languageToCountry[showOtherLocales]?[1] ??
              "Other locales",
          onPressed: () => showSelectLocaleDialog(context),
        );
      },
    );
  }
}

/// Show popup dialog to select Language.
Future<void> showSelectLocaleDialog(
  BuildContext context, {
  String title = 'Select language',
  double? width,
  double? height,
  SliverGridDelegate? gridDelegate,
}) {
  final size = MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: width ?? size.width * 0.6,
          height: height ?? size.height * 0.6,
          child: LocaleSwitcher.grid(
            gridDelegate: gridDelegate,
            additionalCallBack: (context) => Navigator.of(context).pop(),
          ),
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
