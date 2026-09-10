#!/bin/sh
set -eu

REPOSITORY_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPOSITORY_ROOT"

for binary in flutter dart; do
  if ! command -v "$binary" >/dev/null 2>&1; then
    echo "Preflight failed: missing required binary: $binary" >&2
    exit 1
  fi
done
echo "Preflight: flutter and dart found"

stage_failed() {
  echo "Stage $1 failed: $2" >&2
  exit 1
}

python3 tools/lint_wiki.py || stage_failed 1 "wiki lint"
echo "Stage 1 passed: wiki lint"

flutter pub get || stage_failed 2 "dependencies"
(cd example && flutter pub get) || stage_failed 2 "dependencies"
(cd packages/webmcp_flutter_annotations && dart pub get) ||
  stage_failed 2 "annotation dependencies"
(cd packages/webmcp_flutter_generator && dart pub get) ||
  stage_failed 2 "generator dependencies"
(cd packages/webmcp_flutter_generator/example && flutter pub get) ||
  stage_failed 2 "generator fixture dependencies"
echo "Stage 2 passed: dependencies"

dart format --output=none --set-exit-if-changed \
  lib test example/lib example/test \
  packages/webmcp_flutter_annotations/lib \
  packages/webmcp_flutter_generator/lib \
  packages/webmcp_flutter_generator/test \
  packages/webmcp_flutter_generator/example/lib \
  packages/webmcp_flutter_generator/example/test ||
  stage_failed 3 "format"
echo "Stage 3 passed: format"

dart analyze --fatal-infos --fatal-warnings || stage_failed 4 "analysis"
(cd packages/webmcp_flutter_annotations &&
  dart analyze --fatal-infos --fatal-warnings) ||
  stage_failed 4 "annotation analysis"
(cd packages/webmcp_flutter_generator &&
  dart analyze --fatal-infos --fatal-warnings) ||
  stage_failed 4 "generator analysis"
(cd packages/webmcp_flutter_generator/example &&
  dart analyze --fatal-infos --fatal-warnings) ||
  stage_failed 4 "generator fixture analysis"
echo "Stage 4 passed: analysis"

flutter test || stage_failed 5 "tests"
(cd example && flutter test) || stage_failed 5 "tests"
(cd packages/webmcp_flutter_generator && dart test) ||
  stage_failed 5 "generator tests"
(cd packages/webmcp_flutter_generator/example && flutter test) ||
  stage_failed 5 "generator fixture tests"
echo "Stage 5 passed: tests"

(cd example && flutter build web) || stage_failed 6 "build"
test -f example/build/web/index.html || stage_failed 6 "build"
(cd packages/webmcp_flutter_generator/example &&
  dart run build_runner build) ||
  stage_failed 6 "generator build"
echo "Stage 6 passed: build"

sh tools/test_bump_patch_version.sh || stage_failed 7 "version bump test"
echo "Stage 7 passed: version bump test"
