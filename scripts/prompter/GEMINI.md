# Gemini Context: `prompter` Package

## Overview

This document provides context for the `prompter` package, a command-line tool used to generate `.toml` files from `.prompt` source files.

## Purpose

The `prompter` tool is a utility designed to streamline the management of command prompts for the Gemini CLI extension. It automates the process of generating the `.toml` command configuration files from `.prompt` source files, which are easier to read, maintain, and reuse.

## Implementation Details

The `prompter` tool is a Dart command-line application located in the `scripts/prompter` directory. It uses the `dotprompt_dart` library to parse and render the `.prompt` files.

The core logic is implemented in the `PrompterRunner` class, which is responsible for:

-   Parsing command-line arguments for the source and output directories.
-   Finding all `.prompt` files in the source directory.
-   Processing each `.prompt` file using the `dotprompt_dart` library.
-   Writing the generated `.toml` files to the output directory.

## File Layout

The `prompter` package has the following file structure:

```
scripts/prompter/
├── bin/
│   └── prompter.dart       # Main entry point of the application.
├── lib/
│   ├── prompter.dart       # Main library file.
│   └── src/
│       └── prompter_runner.dart # Core logic of the tool.
├── test/
│   └── prompter_test.dart  # Unit tests for the tool.
├── pubspec.yaml            # Package definition and dependencies.
├── README.md               # Package documentation.
├── DESIGN.md               # Design document for the tool.
└── IMPLEMENTATION.md       # Implementation plan for the tool.
```
