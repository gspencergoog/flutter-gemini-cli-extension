#!/usr/bin/env bash
# Copyright 2025 The Flutter Authors.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

unset CD_PATH

# Get the directory where the script is located.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The root of the repository.
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT"

GITHUB_REF=${GITHUB_REF:-refs/tags/HEAD}
tag_name=${GITHUB_REF#refs/tags/}
os=$(uname -s | tr '[:upper:]' '[:lower:]')

if [[ $os == 'darwin' ]]; then
  arch=$(uname -m | tr '[:upper:]' '[:lower:]')
else
  arch='x64'
fi

archive_name="$os.$arch.flutter.tar"
rm -f "$archive_name"

# Create the archive of the extension sources that are in the git ref.
git archive --format=tar -o "$archive_name" "$tag_name" \
  gemini-extension.json \
  commands/ \
  LICENSE \
  README.md \
  flutter.md

gzip --force "$archive_name"
archive_name="${archive_name}.gz"

if [[ -n $GITHUB_ENV ]]; then
  echo "ARCHIVE_NAME=$archive_name" >> $GITHUB_ENV
else
  echo "Archive written to $archive_name"
fi