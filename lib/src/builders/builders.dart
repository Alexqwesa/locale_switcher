library builder;

import 'package:build/build.dart';
import 'package:locale_switcher_dev/src/builders/package_builder.dart';

Builder packageBuilder([BuilderOptions? options]) {
  return PackageBuilder();
}
