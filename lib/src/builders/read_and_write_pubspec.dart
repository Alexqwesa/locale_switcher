import 'package:build/build.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import 'pack/generated_pack.dart';

Future<(String, List<String>, bool)> readAndWritePubspec(BuildStep buildStep,
    Future<void> Function(String file, String output) writer) async {
  var path = 'lib/src/packages/locale_switcher/';
  final input = AssetId(buildStep.inputId.package, 'pubspec.yaml');
  final pubspecYaml = loadYaml(await buildStep.readAsString(input)) as Map?;
  var deps = '';
  var comments = '';
  var flags = <String>[];
  var filterFlags = true;
  // final flags = [];
  if (pubspecYaml case {'locale_switcher': final Map ls}) {
    if (ls case {'flags': final flags_}) {
      if (flags_ is bool) {
        if (flags_) {
          deps += '''  flutter_svg: ^2.0.7 \n''';
          comments += '\n# Supported all flags: $flags_ \n';
          filterFlags = false;
        } else {
          filterFlags = true; // there will be no match with empty flags
          comments += '\n# Supported no flags \n';
        }
      } else if (flags_ is YamlList) {
        flags = flags_.map<String>((element) => element as String).toList();
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

  // warning

  if (pubspecYaml case {'dependencies': final Map psDep}) {
    if (psDep case {'locale_switcher': final psLS}) {
      if (psLS case {'path': final _}) {
        // good
      } else {
        print(
            "===== Warning: don't forget to use 'path: $path' for locale_switcher: =====");
      }
    }
  }

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

  final output = AssetId(buildStep.inputId.package, join(path, 'pubspec.yaml'));
  print("Writing locale_switch ${output.path}");
  writer(join(path, 'pubspec.yaml'), fileHeader + deps + comments);

  return (path, flags, filterFlags);
}
