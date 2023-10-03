import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:locale_switcher_dev/src/builders/pack/generated_pack.dart';
import 'package:locale_switcher_dev/src/builders/write_filtered_file.dart';
import 'package:locale_switcher_dev/src/builders/write_map_as_files.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class PackageBuilder implements Builder {
  PackageBuilder();

  @override
  Map<String, List<String>> get buildExtensions => {
        'pubspec.yaml': ['lib/src/packages/locale_switcher/pubspec.yaml']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // final getVersionFrom = AssetId('locale_switcher_dev', 'build.yaml');
    if (buildStep.inputId.package == 'locale_switcher_dev') {
      return;
    }

    var path = 'lib/src/packages/locale_switcher/';
    final input = AssetId(buildStep.inputId.package, 'pubspec.yaml');
    final pubspecYaml = loadYaml(await buildStep.readAsString(input)) as Map?;
    var deps = '';
    var comments = '';
    var flags = <String>[];
    // final flags = [];
    if (pubspecYaml case {'locale_switcher': final Map ls}) {
      if (ls case {'flags': final flags_}) {
        if (flags_.runtimeType == YamlList) {
          flags = (flags_ as YamlList)
              .map<String>((element) => element as String)
              .toList();
          if (flags.isNotEmpty) {
            deps += '''  flutter_svg: ^2.0.7 \n''';
            comments += '\n# Supported flags: $flags \n';
          }
        }
      }

      var pref = '''  shared_preferences: ^2.2.1 \n''';
      if (ls case {'shared_preferences': final sharedPreferences}) {
        if (!sharedPreferences) {
          pref = '';
          package['src']['preference_repository'] =
              package['src']['preference_repository_stub'];
        }
      }

      if (ls case {'easy_localization': final easy}) {
        if (easy) {
          pref = '  easy_localization:';
          package['src']['preference_repository'] =
              package['src']['preference_repository_easy_localization'];
        }
      }

      deps += pref;

      if (ls case {'package_path': String packagePath}) {
        if (packagePath.isNotEmpty) {
          path = packagePath;
        }
      }
    }
    writeMapAsFiles(package, path: join(path, 'lib'));

    // warning

    if (pubspecYaml case {'dependencies': final Map psDep}) {
      if (psDep case {'locale_switcher': final psLS}) {
        if (psLS case {'path': final psLS}) {
          // good
        } else {
          print(
              "===== Warning: don't forget to use path: for locale_switcher: =====");
        }
      }
    }

    // const packagePath = "lib/src/locale_switcher/";
    final assets = AssetId('locale_switcher',
        join('lib', 'src', 'generated', 'asset_strings.dart'));
    writeFilteredFile(
      await buildStep.readAsString(assets),
      flags,
      join(path, 'lib', 'src', 'generated', 'asset_strings.dart'),
    );

    const fileHeader = '''
name: locale_switcher
description: A small widget for switching the locale of your application.

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
''';

    final output =
        AssetId(buildStep.inputId.package, join(path, 'pubspec.yaml'));
    print("Writing locale_switch ${output.path}");
    // if (output.path == 'lib/src/packages/locale_switcher/pubspec.yaml') {
    //   return buildStep.writeAsString(output, fileHeader + deps + comments);
    // } else {
    File(join(path, 'pubspec.yaml'))
        .writeAsStringSync(fileHeader + deps + comments);
    // }
  }
}
