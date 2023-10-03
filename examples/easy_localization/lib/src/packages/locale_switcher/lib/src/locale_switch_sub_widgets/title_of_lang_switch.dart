import 'package:flutter/material.dart';

class TitleOfLangSwitch extends StatelessWidget {
  final Widget child;

  const TitleOfLangSwitch({
    super.key,
    required this.padding,
    required this.crossAxisAlignment,
    required this.titlePositionTop,
    required this.titlePadding,
    required this.title,
    required this.child,
  });

  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final bool titlePositionTop;
  final EdgeInsets titlePadding;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (titlePositionTop)
            Padding(
              padding: titlePadding,
              child: Center(child: Text(title ?? '')),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!titlePositionTop)
                Padding(
                  padding: titlePadding,
                  child: Center(child: Text(title ?? '')),
                ),
              Expanded(
                child: child,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
