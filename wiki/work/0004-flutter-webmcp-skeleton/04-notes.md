# Implementation and verification notes

## Implementation notes

### Toolchain

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/flutter --version`

    Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
    Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
    Engine • hash 59d54a2b2896a6bbf356c94b7fac7b9e235bdacd (revision 5f77625673) (29 days ago) • 2026-08-11 16:38:36.000Z
    Tools • Dart 3.13.0 • DevTools 2.60.0

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart --version`

    Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"

Both binaries are from `/Users/ortalcohen/fvm/versions/3.47.0/bin` and report the same Dart 3.13.0 toolchain.

### Flutter lifecycle confirmation

The installed Flutter 3.47.0 source documentation for `BuildContext.findAncestorStateOfType` says to save an ancestor reference from `State.didChangeDependencies`, and the `State` lifecycle documentation says `didChangeDependencies` is called immediately after `initState`. `WebMcpAction` therefore performs its once-only ancestor lookup in `didChangeDependencies`, as required by the plan.

### GitHub Actions input confirmation

The official `subosito/flutter-action` README was read from `https://raw.githubusercontent.com/subosito/flutter-action/main/README.md`. Its "Use specific version and channel" example for `subosito/flutter-action@v2` uses the input names `channel` and `flutter-version`, which are the names used by `.github/workflows/checks.yml`.

### License authorization

The human supplied the exact copyright-holder string `flutter_webmcp`. The MIT license records `Copyright (c) 2026 flutter_webmcp`.

### Manifest note

`test/webmcp_scope_test.dart` must use `package:test` to prove the scope is testable without importing `package:flutter_test`. The root manifest therefore declares `test` directly as a development dependency rather than relying on the transitive copy brought by `flutter_test`; this avoids the analyzer's `depend_on_referenced_packages` finding. This is the minimal dependency needed to satisfy frozen AC-045.

## Verification artifact

Verification output is appended below as the implementation proceeds. Live GitHub Actions execution remains `[UNVERIFIED]` because no branch push was authorized.

### Ignore-path proof

Command: `git check-ignore -v` for the six generated paths required by AC-033.

    .gitignore:30:/build/ build/output.txt
    .gitignore:31:/.dart_tool/ .dart_tool/package_config.json
    .gitignore:32:/pubspec.lock pubspec.lock
    .gitignore:33:/example/build/ example/build/web/index.html
    .gitignore:34:/example/.dart_tool/ example/.dart_tool/package_config.json
    .gitignore:35:/example/pubspec.lock example/pubspec.lock

### First dependency-run checksum proof

The clean snapshot's committed blobs and files after the first dependency stage produced identical checksums. The command exited zero and `git status --porcelain` printed no output.

    09b02e2f7af1b37315cec095022a9311c6c9db52  -
    09b02e2f7af1b37315cec095022a9311c6c9db52  analysis_options.yaml
    0476067c84b6513b79be7e327998ca8f2e61477a  -
    0476067c84b6513b79be7e327998ca8f2e61477a  example/analysis_options.yaml

### Final isolated cold run

The snapshot at `/private/tmp/webmcp-final-cold-warm.PSfBlW` was created without either `.dart_tool/` directory, either build directory, or either lock file. It was initialized as a synthetic local Git repository and was clean before the run. `bash tools/check.sh` exited zero. The command output was:

    Preflight: flutter and dart found
    lint_wiki: clean (0 warning(s)).
    Stage 1 passed: wiki lint
    Resolving dependencies...
    Downloading packages...
    Changed 60 dependencies!
    Resolving dependencies in `./example`...
    Got dependencies in `./example`.
    Stage 2 passed: dependencies
    Formatted 23 files (0 changed) in 0.03 seconds.
    Stage 3 passed: format
    Analyzing webmcp-final-cold-warm.PSfBlW...
    No issues found!
    Stage 4 passed: analysis
    00:00 +29: All tests passed!
    00:00 +1: All tests passed!
    Stage 5 passed: tests
    Compiling lib/main.dart for the Web... 18.0s
    Built build/web
    Stage 6 passed: build

After the run, `example/build/web/index.html` existed, `git status --porcelain` printed no output, and the before/after checksums remained identical as shown above.

### Final isolated warm timed run

Command: `/usr/bin/time -p bash tools/check.sh`, with the pinned SDK first on `PATH`. It exited zero. The command output was:

    Preflight: flutter and dart found
    lint_wiki: clean (0 warning(s)).
    Stage 1 passed: wiki lint
    Resolving dependencies...
    Got dependencies!
    Resolving dependencies in `./example`...
    Got dependencies in `./example`.
    Got dependencies!
    Stage 2 passed: dependencies
    Formatted 23 files (0 changed) in 0.03 seconds.
    Stage 3 passed: format
    Analyzing webmcp-final-cold-warm.PSfBlW...
    No issues found!
    Stage 4 passed: analysis
    00:01 +29: All tests passed!
    00:00 +1: All tests passed!
    Stage 5 passed: tests
    Compiling lib/main.dart for the Web... 17.8s
    Built build/web
    Stage 6 passed: build
    real 29.34
    user 31.76
    sys 4.78

The measured wall-clock time was 29.34 seconds, below AC-031's 300-second ceiling.

### Structural proof

The final local checks produced:

    lint_wiki: clean (0 warning(s)).
    git diff --check: no output
    AGENTS.md: 76 lines
    README.md first heading: # webmcp_pilot
    README.md preserved former first heading: # Agent workflow scaffold
    CI jobs: wiki, package
    CI dependency keys: none
    Flutter version literals in workflow: 3.47.0 (one occurrence)
    Package check command in workflow: bash tools/check.sh (one occurrence)
    Flutter imports under lib/: lib/src/widgets/webmcp_screen.dart and lib/src/widgets/webmcp_action.dart only
    Scope test flutter_test imports and widget pump calls: none
    Example screen: WebMcpScreen mixin and WebMcpAction present
    Example main: imports and mounts ExampleScreen

The isolated snapshot also confirmed that `lib/`, `example/`, `test/`, `README.md`, `CHANGELOG.md`, `analysis_options.yaml`, `pubspec.yaml`, and `LICENSE` all exist and are tracked.

### Pending external evidence

The workflow file is verified locally. A live GitHub Actions run and its resolved-version log remain `[UNVERIFIED]` because no push was authorized; AC-026 explicitly treats this external half as pending rather than failing.
