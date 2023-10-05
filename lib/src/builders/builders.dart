// ignore_for_file: depend_on_referenced_packages

library builder;

import 'package:build/build.dart';
import 'package:locale_switcher/src/builders/pack/pack_builder.dart';

Builder packBuilder([BuilderOptions? options]) {
  return PackBuilder();
}
