# Copyright 2025 The Flutter Authors.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

if (-not $env:GITHUB_REF) { $env:GITHUB_REF = "refs/tags/HEAD" }
$tagName = $env:GITHUB_REF.Substring($env:GITHUB_REF.LastIndexOf("/") + 1)
$archiveName = "win32.flutter.zip"

git archive --format=zip -o $archiveName $tagName gemini-extension.json commands/ LICENSE README.md flutter.md

echo "ARCHIVE_NAME=$archiveName" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
