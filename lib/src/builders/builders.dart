library builder;

import 'package:build/build.dart';
import 'package:locale_switcher_dev/src/builders/pack/pack_builder.dart';
import 'package:locale_switcher_dev/src/builders/package_builder.dart';

Builder packageBuilder([BuilderOptions? options]) {
  return PackageBuilder();
}

Builder packBuilder([BuilderOptions? options]) {
  return PackBuilder();
}