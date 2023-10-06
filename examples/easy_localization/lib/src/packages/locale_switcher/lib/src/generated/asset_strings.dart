// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A flag of a country, rounded by default.
///
/// First positional argument is iso code of the country - can be used string
/// or [Flags] helper.
class CircleFlag extends StatelessWidget {
  final double size;

  /// Use [Flags] class or [countryCodeToContent] map to get the flag you want.
  final Flag flag;

  /// [Clip] option for widget [ClipPath].
  ///
  /// This option have no effect if [shape] == null.
  final Clip clipBehavior;

  /// Clip the flag by [ShapeBorder], default: [CircleBorder].
  ///
  /// If null, return square flag.
  final ShapeBorder? shape;

  const CircleFlag(
    this.flag, {
    super.key,
    this.size = 48,
    this.shape = const CircleBorder(eccentricity: 0),
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final svg = SizedBox(
      width: size,
      height: size,
      child: flag.svg,
    );

    return shape == null
        ? svg
        : ClipPath(
            clipper: ShapeBorderClipper(
              shape: shape!,
              textDirection: Directionality.maybeOf(context),
            ),
            clipBehavior: clipBehavior,
            child: svg,
          );
  }
}

final countryCodeToContent = {
  'de': Flags.DE,
  'northern_cyprus': Flags.NORTHERN_CYPRUS,
  'vn': Flags.VN,
  'us-hi': Flags.US_HI,
  'us': Flags.US,
  'hausa': Flags.HAUSA,
};

class Flag {
  final String svgString;

  const Flag(this.svgString);

  SvgPicture get svg => SvgPicture(SvgStringLoader(svgString));
}

class Flags {
  const Flags._();

  static const instance = Flags._();

  Flag? operator [](String key) => countryCodeToContent[key];

  Iterable<String> get values => countryCodeToContent.keys;

  static const Flag DE = Flag(
      '''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g><path fill="#ffda44" d="m0 345 256.7-25.5L512 345v167H0z"/><path fill="#d80027" d="m0 167 255-23 257 23v178H0z"/><path fill="#333" d="M0 0h512v167H0z"/></g></svg>''');
  static const Flag NORTHERN_CYPRUS = Flag(
      '''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g><path fill="#eee" d="M0 0h512v512H0z"/><path fill="#d80027" d="M138 167a89 89 0 1 0 62.3 152.6 72 72 0 0 1-34.3 8.7h-.1a72.3 72.3 0 1 1 34.4-136 89 89 0 0 0-62.3-25.4zm85.2 42.2v35.7l-34 11 34 11.1v35.9l21-29 34 11.1-21-28.9 21-29-34 11.1-21-29zM0 89v33.4h512V89zm0 334h512v-33.4H0z"/></g></svg>''');
  static const Flag VN = Flag(
      '''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g><path fill="#d80027" d="M0 0h512v512H0z"/><path fill="#ffda44" d="m256 133.6 27.6 85H373L300.7 271l27.6 85-72.3-52.5-72.3 52.6 27.6-85-72.3-52.6h89.4z"/></g></svg>''');
  static const Flag US_HI = Flag(
      '''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g><path fill="#eee" d="M0 256 256 0h256v64l-24 67.6 24 60.4v64l-30.9 71.1L512 384v64l-255.2 33.9L0 448v-64l33.4-57.7z"/><path fill="#d80027" d="M0 448h512v64H0zm0-192h512v64l-256 17.8L0 320z"/><path fill="#0052b4" d="M0 320h512v64H0z"/><path fill="#d80027" d="M236.4 64H512v64l-275.6 15z"/><path fill="#0052b4" d="M236.4 128H512v64H236.4z"/><path fill="#eee" d="M0 0h33.3L64 20.9 97.4 0h109L256 31.7V64l-21.4 31.6L256 128v31.7l-20 31.5 20 48.3.1 16.5-21.8-9.3-8.4 9.3h-44.7l-33-12.7-18.5 12.7H97.4L66 235.4 33.3 256H0V128l21-31.6L0 64z"/><path fill="#d80027" d="M33.3 0v64H0v64h33.3v144.4h64.1V128H256V64H97.4V0zm96.4 159.7L238.9 269h30.2L159.8 159.7z"/><path fill="#0052b4" d="M206.5 0 175 31.7h81V0zm-31.6 159.7 81.1 79.8v-79.8zM129.7 205v51h51.5z"/></g></svg>''');
  static const Flag US = Flag(
      '''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g><path fill="#eee" d="M0 256 256 0h256v55.7l-20.7 34.5 20.7 32.2v66.8l-21.2 32.7L512 256v66.8l-24 31.7 24 35.1v66.7l-259.1 28.3L0 456.3v-66.7l27.1-33.3L0 322.8z"/><path fill="#d80027" d="M256 256h256v-66.8H236.9zm-19.1-133.6H512V55.7H236.9zM512 512v-55.7H0V512zM0 389.6h512v-66.8H0z"/><path fill="#0052b4" d="M0 0h256v256H0z"/><path fill="#eee" d="M15 14.5 6.9 40H-20L1.7 55.8l-8.3 25.5L15 65.5l21.6 15.8-8.2-25.4L50.2 40H23.4zm91.8 0L98.5 40H71.7l21.7 15.8-8.3 25.5 21.7-15.8 21.7 15.8-8.3-25.4L142 40h-26.8zm91.9 0-8.3 25.6h-26.8l21.7 15.8-8.3 25.5 21.7-15.8 21.6 15.7-8.2-25.3 21.7-16H207zM15 89.2l-8.3 25.5H-20l21.7 15.8-8.3 25.5L15 140l21.6 15.7-8.2-25.3 21.7-16H23.4zm91.8 0-8.3 25.5H71.8l21.7 15.8-8.3 25.5 21.7-15.8 21.6 15.7-8.2-25.3 21.7-16h-26.8zm91.8 0-8.3 25.5h-26.8l21.7 15.8-8.3 25.5 21.7-15.8 21.6 15.7-8.2-25.3 21.7-16H207zM15 163.6l-8.3 25.5H-20L1.6 205l-8.3 25.5L15 214.6l21.7 15.8-8.3-25.4 21.7-15.9H23.3zm91.8 0-8.3 25.5H71.7L93.4 205l-8.3 25.5 21.7-15.8 21.7 15.8-8.3-25.4 21.7-15.9h-26.8zm91.8 0-8.3 25.5h-26.8l21.7 15.8-8.3 25.5 21.7-15.8 21.7 15.8L212 205l21.7-15.9H207z"/></g></svg>''');
  static const Flag HAUSA = Flag(
      '''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g><circle cx="256" cy="256" r="256" fill="#eee"/><path fill="#6da544" d="m218 154 38-84 38 84-140 140-84-38 84-38 140 140-38 84-38-84 140-140 84 38-84 38z"/><path fill="#333" d="M244.5 29.5c0 40.5-11.2 78.5-30.7 110.8l-49-49a45.1 45.1 0 0 0-63.7 0l-9.9 9.8a45.1 45.1 0 0 0 0 63.7l49.1 49a214.2 214.2 0 0 1-110.8 30.7v23c40.5 0 78.5 11.2 110.8 30.7l-49 49a45.1 45.1 0 0 0 0 63.7l9.8 9.9a45.1 45.1 0 0 0 63.7 0l49-49.1a214.2 214.2 0 0 1 30.7 110.8h23c0-40.5 11.2-78.5 30.7-110.8l49 49a45.1 45.1 0 0 0 63.7 0l9.9-9.8a45.1 45.1 0 0 0 0-63.7l-49.1-49a214.2 214.2 0 0 1 110.8-30.7v-23c-40.5 0-78.5-11.2-110.8-30.7l49-49a45.1 45.1 0 0 0 0-63.7l-9.8-9.9a45.1 45.1 0 0 0-63.7 0l-49 49.1a214.2 214.2 0 0 1-30.7-110.8h-23zM256 92.2a233.8 233.8 0 0 0 27.7 62.6L256 182.5l-27.7-27.7A233.8 233.8 0 0 0 256 92.2zM133 98a25 25 0 0 1 17.6 7.4l52 51.8a215.9 215.9 0 0 1-45.4 45.3l-51.8-51.9a24.7 24.7 0 0 1 0-35.3l9.9-10A25 25 0 0 1 133 98zm246 0c6.4 0 12.8 2.4 17.7 7.4l10 9.9a24.7 24.7 0 0 1 0 35.3l-52 52a215.9 215.9 0 0 1-45.2-45.3l51.9-52A25 25 0 0 1 379 98zm-162.3 73.5 25.2 25.1-45.3 45.3-25.2-25.2a236.7 236.7 0 0 0 45.3-45.3zm78.6 0a236.7 236.7 0 0 0 45.2 45.2l-25.1 25.2-45.3-45.3 25.2-25.1zM256 210.6l45.3 45.3-45.3 45.3-45.3-45.3 45.3-45.3zm-101.2 17.6 27.7 27.7-27.7 27.7A233.8 233.8 0 0 0 92.2 256a233.8 233.8 0 0 0 62.6-27.7zm202.4 0a233.8 233.8 0 0 0 62.6 27.7 233.8 233.8 0 0 0-62.6 27.7L329.5 256l27.7-27.7zM196.6 270l45.3 45.3-25.2 25.1a236.7 236.7 0 0 0-45.3-45.2l25.2-25.2zm118.8 0 25.1 25.2a236.7 236.7 0 0 0-45.2 45.3l-25.2-25.2 45.3-45.3zm-158.1 39.4a215.9 215.9 0 0 1 45.2 45.3l-51.9 51.8a24.7 24.7 0 0 1-35.3 0l-10-9.9a24.7 24.7 0 0 1 0-35.3l52-51.9zm197.4 0 52 51.9a24.7 24.7 0 0 1 0 35.3l-10 10a24.7 24.7 0 0 1-35.3 0l-52-52a215.9 215.9 0 0 1 45.4-45.2zm-98.7 20 27.7 27.7a233.8 233.8 0 0 0-27.7 62.6 233.8 233.8 0 0 0-27.7-62.6l27.7-27.7z"/></g></svg>''');
}
