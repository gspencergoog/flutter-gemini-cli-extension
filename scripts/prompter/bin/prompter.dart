// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/args.dart';
import 'package:file/local.dart';
import 'package:prompter/src/prompter_runner.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints this usage information.',
    )
    ..addOption(
      'source',
      defaultsTo: 'prompts',
      help: 'The directory containing the .prompt files.',
    )
    ..addOption(
      'output',
      defaultsTo: 'commands',
      help: 'The directory where the .toml files will be generated.',
    );

  final results = parser.parse(args);

  if (results['help'] as bool) {
    print(parser.usage);
    return;
  }

  await PrompterRunner(fileSystem: const LocalFileSystem()).run(
    sourceDirPath: results['source'] as String,
    outputDirPath: results['output'] as String,
  );
}
