import 'package:flutter/material.dart';
import 'package:locale_switcher/locale_switcher.dart';

/// Builder function for [LocaleSwitcher.multiLangWidget].
typedef MultiLangBuilder = Widget Function(Widget wTop, Widget wDown,
    [double? radius, Key? key]);

/// A Widget to display multi language locales for [LocaleSwitcher].
///
/// [wTop] - Bigger background widget,
/// [wDown] - Small sticker on rightDown corner.
///
/// See also:
/// [LocaleSwitcher.multiLangWidget] - look here first,
/// [LocaleSwitcher.multiLangCountries],
/// [LocaleSwitcher.multiLangWidget].
class MultiLangFlag extends StatelessWidget {
  /// Bigger background widget
  final Widget wTop;

  /// Small sticker on rightDown corner.
  final Widget wDown;

  /// Size/Radius of full widget.
  final double? radius;

  const MultiLangFlag({
    super.key,
    required this.wTop,
    required this.wDown,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final rad = radius ?? 48;
    final pad = rad / 6;

    final top = (wTop is Text)
        ? Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, pad),
            child: wTop,
          )
        : wTop;

    return SizedBox(
      width: rad,
      height: rad,
      child: Stack(
        children: [
          Positioned(
              height: rad,
              width: rad,
              top: 0,
              left: 0,
              child: FittedBox(fit: BoxFit.fitHeight, child: top)),
          Positioned(
              height: rad / 2.2,
              width: rad / 1.6,
              top: rad / 1.6,
              left: rad / 2.2,
              child: Container(
                decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).canvasColor,
                  // gradient: LinearGradient(
                  //     stops: const [0, 0.3, 1],
                  //     begin: Alignment.topLeft,
                  //     end: Alignment.bottomRight,
                  //     colors: [
                  //       Theme.of(context).cardColor.withAlpha(10),
                  //       Colors.white,
                  //       Colors.white,
                  //       // Colors.white,
                  //
                  //       // Theme.of(context).cardColor.withAlpha(20),
                  //     ])
                ),
              )),
          Positioned(
              height: rad / 1.6,
              width: rad / 1.6,
              top: rad / 2.0,
              left: rad / 2.3,
              child: FittedBox(child: wDown)),
        ],
      ),
    );
  }
}
