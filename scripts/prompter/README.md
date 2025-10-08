# prompter

A command-line tool to generate `.toml` files from `.prompt` files.

## Overview

This tool is a command-line utility for processing `.prompt` files and generating `.toml` files. It is designed to be used as part of the build process for the Gemini CLI extension to keep the command configurations in sync with their prompt sources.

The `prompter` tool uses the `dotprompt_dart` library to parse and render the `.prompt` files, which use a combination of YAML front matter and Mustache templates.

## Usage

To use the `prompter` tool, run it from the command line with the following arguments:

```bash
dart run prompter --source <source_directory> --output <output_directory>
```

-   `--source`: The directory containing the `.prompt` files. Defaults to `prompts/`.
-   `--output`: The directory where the `.toml` files will be generated. Defaults to `commands/`.

The tool will find all `.prompt` files in the source directory, process them, and write the output to corresponding `.toml` files in the output directory.
