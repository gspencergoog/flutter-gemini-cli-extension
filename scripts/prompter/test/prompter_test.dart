// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:prompter/prompter.dart';
import 'package:test/test.dart';

void main() {
  group('PrompterRunner', () {
    late FileSystem fileSystem;
    late Directory sourceDir;
    late Directory outputDir;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      sourceDir = fileSystem.directory('prompts')..createSync();
      outputDir = fileSystem.directory('commands')..createSync();
    });

    test('generates .toml file from .prompt file with template', () async {
      final promptFile = sourceDir.childFile('test.prompt');
      await promptFile.writeAsString('''
---
model: test-model
input:
  default:
    name: World
---
description = "Hello, {{name}}!"
''');

      final runner = PrompterRunner(fileSystem: fileSystem);
      await runner.run(
        sourceDirPath: sourceDir.path,
        outputDirPath: outputDir.path,
      );

      final tomlFile = outputDir.childFile('test.toml');
      expect(await tomlFile.exists(), isTrue);

      final content = await tomlFile.readAsString();
      expect(
        content,
        contains('# This file is generated from a .prompt file.'),
      );
      expect(content, contains('description = "Hello, World!"'));
    });

    test('exits with code 2 if source directory does not exist', () async {
      var exitCode = 0;
      final runner = PrompterRunner(
        fileSystem: fileSystem,
        exitFunction: (code) {
          exitCode = code;
        },
      );
      await runner.run(
        sourceDirPath: 'non_existent_dir',
        outputDirPath: outputDir.path,
      );

      expect(exitCode, 2);
    });

    test('creates output directory if it does not exist', () async {
      final newOutputDir = fileSystem.directory('new_commands');
      final runner = PrompterRunner(fileSystem: fileSystem);
      await runner.run(
        sourceDirPath: sourceDir.path,
        outputDirPath: newOutputDir.path,
      );

      expect(await newOutputDir.exists(), isTrue);
    });

    test('does nothing if source directory is empty', () async {
      final runner = PrompterRunner(fileSystem: fileSystem);
      await runner.run(
        sourceDirPath: sourceDir.path,
        outputDirPath: outputDir.path,
      );

      expect(await outputDir.list().isEmpty, isTrue);
    });

    test('ignores non-prompt files in source directory', () async {
      await sourceDir.childFile('test.txt').writeAsString('some text');
      final runner = PrompterRunner(fileSystem: fileSystem);
      await runner.run(
        sourceDirPath: sourceDir.path,
        outputDirPath: outputDir.path,
      );

      expect(await outputDir.list().isEmpty, isTrue);
    });

    test('ignores subdirectories in source directory', () async {
      await sourceDir.childDirectory('subdir').create();
      final runner = PrompterRunner(fileSystem: fileSystem);
      await runner.run(
        sourceDirPath: sourceDir.path,
        outputDirPath: outputDir.path,
      );

      expect(await outputDir.list().isEmpty, isTrue);
    });

    test('ignores files starting with an underscore', () async {
      await sourceDir.childFile('_test.prompt').writeAsString('''
---
model: test-model
---
description = "This should be ignored"
''');
      final runner = PrompterRunner(fileSystem: fileSystem);
      await runner.run(
        sourceDirPath: sourceDir.path,
        outputDirPath: outputDir.path,
      );

      expect(await outputDir.list().isEmpty, isTrue);
    });

    test('handles partials and metadata correctly', () async {
      final promptFile = sourceDir.childFile('test.prompt');
      await promptFile.writeAsString('''
---
metadata:
  description: "A test prompt"
---
description = "{{ metadata.description }}"
prompt = """
{{> partial}}
"""
''');

      final partialFile = sourceDir.childFile('_partial.prompt');
      await partialFile.writeAsString('This is a partial.');

      final runner = PrompterRunner(fileSystem: fileSystem);
      await runner.run(
        sourceDirPath: sourceDir.path,
        outputDirPath: outputDir.path,
      );

      final tomlFile = outputDir.childFile('test.toml');
      expect(await tomlFile.exists(), isTrue);

      final content = await tomlFile.readAsString();
      expect(content, contains('description = "A test prompt"'));
      expect(content, contains('This is a partial.'));
    });
  });
}
