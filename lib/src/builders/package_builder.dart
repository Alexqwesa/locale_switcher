// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:locale_switcher_dev/src/builders/pack/generated_pack.dart';
import 'package:locale_switcher_dev/src/builders/read_and_write_pubspec.dart';
import 'package:locale_switcher_dev/src/builders/write_filtered_file.dart';
import 'package:locale_switcher_dev/src/builders/write_map_as_files.dart';
import 'package:path/path.dart';

class PackageBuilder implements Builder {
  PackageBuilder();

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$package$': ['lib/src/packages/locale_switcher/pubspec.yaml'],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // final getVersionFrom = AssetId('locale_switcher_dev', 'build.yaml');
    if (buildStep.inputId.package == 'locale_switcher_dev') {
      return;
    }

    Future<void> writer(String file, String output) async {
      final path = file.substring(0, file.length - basename(file).length);
      if (!Directory(path).existsSync()) {
        Directory(path).createSync(recursive: true);
      }
      File(file).writeAsStringSync(output);
      // final id = AssetId(buildStep.inputId.package, file);
      // return buildStep.writeAsString(id, output);
    }

    // write pubspec.yaml
    final (path, flags, filterFlags) =
        await readAndWritePubspec(buildStep, writer);

    // write .dart files
    writeMapAsFiles(package, writer, path: join(path, 'lib'));

    // write asset_strings.dart
    final assets = AssetId('locale_switcher_dev',
        join('lib', 'src', 'builders', 'pack', 'asset_strings.txt'));
    final assetStrings = writeFilteredFile(
      await buildStep.readAsString(assets),
      flags,
      filterFlags,
    );
    writer(join(path, 'lib', 'src', 'generated', 'asset_strings.dart'),
        assetStrings);
  }
}
