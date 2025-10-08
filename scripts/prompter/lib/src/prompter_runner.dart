// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' hide Directory, File;

import 'package:dotprompt_dart/dotprompt_dart.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;

class PrompterRunner {
  PrompterRunner({FileSystem? fileSystem, this.exitFunction = exit})
    : fileSystem = fileSystem ?? const LocalFileSystem();

  final FileSystem fileSystem;
  final void Function(int) exitFunction;

  Future<void> run({
    required String sourceDirPath,
    required String outputDirPath,
  }) async {
    final sourceDir = fileSystem.directory(sourceDirPath);
    final outputDir = fileSystem.directory(outputDirPath);

    if (!await sourceDir.exists()) {
      stderr.writeln('Source directory not found: ${sourceDir.path}');
      exitFunction(2);
      return;
    }

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    await for (final fileEntity in sourceDir.list()) {
      if (fileEntity is File &&
          fileEntity.path.endsWith('.prompt') &&
          !p.basename(fileEntity.path).startsWith('_')) {
                                var fileContent = await fileEntity.readAsString();

                                // Manually handle partials
                                final partialRegex = RegExp(r'{{>\s*(\w+)\s*}}');
                                fileContent = fileContent.replaceAllMapped(partialRegex, (match) {
                                  final partialName = match.group(1);
                                  final partialFile = fileSystem
                                      .file(p.join(sourceDir.path, '_$partialName.prompt'));
                                  if (partialFile.existsSync()) {
                                    var partialContent = partialFile.readAsStringSync();
                                    // We need to strip the frontmatter from the partial, if it exists.
                                    if (partialContent.startsWith('---')) {
                                      final parts = partialContent.split('---');
                                      if (parts.length > 2) {
                                        partialContent = parts.sublist(2).join('---').trim();
                                      }
                                    }
                                    return partialContent;
                                  }
                                  return match.group(0)!; // If partial not found, leave the tag as is
                                });

                                final prompt = DotPrompt(fileContent);

                                final renderedContent = prompt.render({
                                  'metadata': prompt.frontMatter.metadata,
                                });        final promptName = p.basenameWithoutExtension(fileEntity.path);
        final tomlFile = fileSystem.file(
          p.join(outputDir.path, '$promptName.toml'),
        );
        final relativePath = p.relative(
          tomlFile.path,
          from: sourceDir.parent.path,
        );

        final content =
            '''
# Copyright 2025 The Flutter Authors.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This file is generated from a .prompt file. Do not edit directly.
# To edit this file, edit the corresponding .prompt file and run the prompter tool.
# The source prompt file is $relativePath

# This command can be invoked with: /$promptName (or /flutter:$promptName in case of collisions).

$renderedContent
''';
        await tomlFile.writeAsString(content);
        print('Generated ${tomlFile.path}');
      }
    }
  }
}
