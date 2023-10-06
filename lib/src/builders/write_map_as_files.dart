import 'package:path/path.dart' show join;
// import 'generated_pack.dart';

void writeMapAsFiles(Map<String, dynamic> package,
    Future<void> Function(String file, String output) writer,
    {path = 'lib/'}) {

  for (final key in package.keys) {
    if (package[key].runtimeType == String) {
      writer(join(path, '$key.dart'), package[key]);
    } else if (package[key] is Map) {
      writeMapAsFiles(package[key], writer, path: join(path, key));
    } else {
      throw StateError('unknown key = $key');
    }
  }
}
