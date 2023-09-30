import 'dart:io';

void writeFilteredFile(
    String input, List<String> includePattern, String outPath) {
  final includePatternUpper = includePattern.map((e) => e.toUpperCase());
  const filter = ": Flags.";
  const filter2 = "  static const Flag ";
  final out = input
      .replaceAll("Flag(\n      '''", "Flag(      '''")
      .split('\n')
      .where((element) {
    if (element.contains(filter)) {
      for (final pattern in includePattern) {
        if (element.contains(pattern)) {
          return true;
        }
      }
      return false;
    } else if (element.contains(filter2)) {
      for (final pattern in includePatternUpper) {
        if (element.contains(pattern)) {
          return true;
        }
      }
      return false;
    } else {
      return true;
    }
  });

  final dir = Directory('lib/src/packages/locale_switcher/lib/src/generated/');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  File(outPath).writeAsStringSync(out.join('\n'));
}
