String writeFilteredFile(
    String input, List<String> includePattern, bool filterFlags) {
  final includePatternUpper = includePattern.map((e) => e.toUpperCase());
  const filter = ": Flags.";
  const filter2 = "  static const Flag ";

  if (!filterFlags) {
    return input;
  } else {
    final out = input
        .replaceAll("\n      '''<svg ", " '''<svg ")
        .split('\n')
        .where((element) {
      if (element.contains(filter)) {
        for (final pattern in includePattern) {
          if (element.contains('$filter${pattern.toUpperCase()},')) {
            return true;
          }
        }
        return false;
      } else if (element.contains(filter2)) {
        for (final pattern in includePatternUpper) {
          if (element.contains(filter2 + pattern + ' ')) {
            return true;
          }
        }
        return false;
      } else {
        return true;
      }
    });

    return out.join('\n');
  }
}
