import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// Show popup dialog to select Language.
Future<void> showSelectLocaleDialog(
  BuildContext context, {
  String title = 'Select language',
  double? width,
  double? height,
  SliverGridDelegate? gridDelegate,
  Function(BuildContext)? setLocaleCallBack,
  bool useEmoji = false,
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
            useEmoji: useEmoji,
            gridDelegate: gridDelegate,
            setLocaleCallBack: (context) {
              setLocaleCallBack?.call(context);
              Navigator.of(context).pop();
            },
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
