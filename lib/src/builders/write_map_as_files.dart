import 'dart:io';

import 'package:path/path.dart' show join;
// import 'generated_pack.dart';

void writeMapAsFiles(Map<String, dynamic> package, {path = 'lib/'}) {
  if (!Directory(path).existsSync()) {
    Directory(path).createSync(recursive: true);
  }

  for (final key in package.keys) {
    if (package[key].runtimeType == String) {
      File(join(path, '$key.dart')).writeAsStringSync(package[key]);
    } else if (package[key] is Map) {
      writeMapAsFiles(package[key], path: join(path, key));
    } else {
      throw StateError('unknown key = $key');
    }
  }
}
