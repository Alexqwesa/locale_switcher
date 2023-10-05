// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';

class PackBuilder implements Builder {
  PackBuilder();

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$package$': const ['lib/src/builders/pack/generated_pack.dart']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (buildStep.inputId.package != 'locale_switcher') {
      return;
    }

    final outFile = AssetId(
        buildStep.inputId.package, 'lib/src/builders/pack/generated_pack.dart');

    print("Writing generated pack ${outFile.path}");

    // const packagePath = "lib/src/locale_switcher/";
    const packagePath = "";
    var package = generateMapFromDir(
      '${packagePath}lib/',
      header: 'final package = <String, dynamic>{',
      end: "",
    );
    var srcPack = generateMapFromDir(
      '${packagePath}lib/src/',
      header: "  'src': <String, dynamic>{",
      end: "",
    );
    var subPack = generateMapFromDir(
      '${packagePath}lib/src/locale_switch_sub_widgets/',
      header: "  'locale_switch_sub_widgets': <String, dynamic>{",
      end: "},\n",
    );

    final out = "$package \n  $srcPack \n  $subPack \n},\n};";

    return buildStep.writeAsString(outFile, out);
  }
}

String generateMapFromDir(dir,
    {String end = '};\n', header = 'final mapName = <String, dynamic>{'}) {
  var newFileContent = header;
  for (final file in [...Directory(dir).listSync()]
    ..sort((a, b) => a.path.compareTo(b.path))) {
    if (file is File) {
      var baseName = file.path.split('/').last;
      baseName = baseName.substring(0, baseName.length - 5); // cut .dart
      newFileContent += "  '$baseName': r'''${file.readAsStringSync()}''',\n";
    }
  }

  return newFileContent + end;
}
