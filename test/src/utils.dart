// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/html/html_generator.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';

Directory sdkDir;
PackageMeta sdkPackageMeta;
PackageGraph testPackageGraph;
PackageGraph testPackageGraphGinormous;
PackageGraph testPackageGraphSmall;
PackageGraph testPackageGraphErrors;
PackageGraph testPackageGraphSdk;

final Directory testPackageBadDir = new Directory('testing/test_package_bad');
final Directory testPackageDir = new Directory('testing/test_package');
final Directory testPackageMinimumDir =
    new Directory('testing/test_package_minimum');
final Directory testPackageWithEmbedderYaml =
    new Directory('testing/test_package_embedder_yaml');
final Directory testPackageWithNoReadme =
    new Directory('testing/test_package_small');
final Directory testPackageIncludeExclude =
    new Directory('testing/test_package_include_exclude');
final Directory testPackageImportExportError =
    new Directory('testing/test_package_import_export_error');
final Directory testPackageOptions =
    new Directory('testing/test_package_options');
final Directory testPackageOptionsImporter =
    new Directory('testing/test_package_options_importer');
final Directory testPackageToolError =
    new Directory('testing/test_package_tool_error');

/// Convenience factory to build a [DartdocGeneratorOptionContext] and associate
/// it with a [DartdocOptionSet] based on the current working directory and/or
/// the '--input' flag.
Future<DartdocGeneratorOptionContext> generatorContextFromArgv(
    List<String> argv) async {
  DartdocOptionSet optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc', [createDartdocOptions, createGeneratorOptions]);
  optionSet.parseArguments(argv);
  return new DartdocGeneratorOptionContext(optionSet, null);
}

/// Convenience factory to build a [DartdocOptionContext] and associate it with a
/// [DartdocOptionSet] based on the current working directory.
Future<DartdocOptionContext> contextFromArgv(List<String> argv) async {
  DartdocOptionSet optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc', [createDartdocOptions]);
  optionSet.parseArguments(argv);
  return new DartdocOptionContext(optionSet, Directory.current);
}

void delete(Directory dir) {
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}

void init({List<String> additionalArguments}) async {
  sdkDir = defaultSdkDir;
  sdkPackageMeta = new PackageMeta.fromDir(sdkDir);
  additionalArguments ??= <String>[];

  testPackageGraph = await bootBasicPackage(
      'testing/test_package', ['css', 'code_in_comments', 'excluded'],
      additionalArguments: additionalArguments);
  testPackageGraphGinormous = await bootBasicPackage(
      'testing/test_package', ['css', 'code_in_commnets', 'excluded'],
      additionalArguments:
          additionalArguments + ['--auto-include-dependencies']);

  testPackageGraphSmall = await bootBasicPackage(
      'testing/test_package_small', [],
      additionalArguments: additionalArguments);

  testPackageGraphErrors = await bootBasicPackage(
      'testing/test_package_doc_errors', ['css', 'code_in_comments', 'excluded'],
      additionalArguments: additionalArguments);
  testPackageGraphSdk = await bootSdkPackage();
}

Future<PackageGraph> bootSdkPackage() async {
  return new PackageBuilder(await contextFromArgv(['--input', sdkDir.path]))
      .buildPackageGraph();
}

Future<PackageGraph> bootBasicPackage(
    String dirPath, List<String> excludeLibraries,
    {List<String> additionalArguments}) async {
  Directory dir = new Directory(dirPath);
  additionalArguments ??= <String>[];
  return new PackageBuilder(await contextFromArgv([
            '--input',
            dir.path,
            '--sdk-dir',
            sdkDir.path,
            '--exclude',
            excludeLibraries.join(','),
          ] +
          additionalArguments))
      .buildPackageGraph();
}
