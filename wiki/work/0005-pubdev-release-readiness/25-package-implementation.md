# Package and browser transport implementation

Tasks 1.2 and 1.4 were implemented on 2026-09-10 within their assigned file ownership. This artifact records focused implementation evidence only. The complete-source suite, publish dry-run, payload inventory, external consumer checks and blind implementation review remain Group 2 work.

## Release metadata and consumer boundary

- `pubspec.yaml` retains `webmcp_flutter` version `0.1.0`, Dart `^3.13.0`, web-only support and now declares Flutter `>=3.47.0`. Optional project URLs remain absent.
- `CHANGELOG.md` now has a dated `0.1.0 - 2026-09-10` entry describing the local registry, asynchronous invocation, Flutter lifecycle integration, detection-only browser transport and example/check coverage.
- `.pubignore` retains consumer runtime, metadata and example files while excluding repository tests, tools, wiki, root analysis configuration, agent/CI/editor configuration, generated output, lockfiles, environment files, credential-shaped files and local OS/cache material. The `CLAUDE.local.md` exclusion and every relevant generated/environment exclusion from `.gitignore` are repeated explicitly.

## Internal transport observation and browser fixture

`WebDetectionTransport` now exposes its construction-time property-presence result through the internal read-only `isAvailable` getter. Its internal constructor accepts an optional log sink so the browser test can observe the actual transport's messages; the production default still calls `developer.log` with logger name `webmcp_flutter`. No transport symbol or getter was added to `lib/webmcp_flutter.dart`.

The browser-only test saves the original own descriptor of `document.modelContext`, deletes any controllable own marker, requires the property to be absent, and restores the original descriptor in teardown. The absent branch constructs the actual transport and asserts `isAvailable == false`. The present branch defines a configurable marker, constructs the actual transport and asserts `isAvailable == true`. It then invokes registration and removal notifications on that transport, verifies the marker remains identical and unmodified, and asserts these exact messages:

```text
modelContext detected: false; tools not published
modelContext detected: true; tools not published
registered browser_fixture; tools not published
unregistered browser_fixture; tools not published
```

The test fails rather than skips if Chrome exposes an inherited `modelContext`, which keeps the absent case controlled.

## Focused verification

Command:

`/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart format lib/src/transport/transport_web.dart test/transport_web_browser_test.dart`

Exact output and exit:

```text
Formatted test/transport_web_browser_test.dart
Formatted 2 files (1 changed) in 0.01 seconds.
Exit: 0
```

Command:

`CHROME_EXECUTABLE='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' /Users/ortalcohen/fvm/versions/3.47.0/bin/flutter test --platform chrome test/transport_web_browser_test.dart --reporter expanded`

Exact output and exit:

```text
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_browser_test.dart
00:00 +0: reports modelContext absent when the marker is missing
00:00 +1: reports modelContext present without publishing registry changes
00:00 +2: All tests passed!
Exit: 0
```

Command:

`/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart analyze --fatal-infos --fatal-warnings lib/src/transport/transport_web.dart test/transport_web_browser_test.dart`

Exact output and exit:

```text
Analyzing transport_web.dart, transport_web_browser_test.dart...
No issues found!
Exit: 0
```

Command:

`git diff --check -- pubspec.yaml CHANGELOG.md .pubignore lib/src/transport/transport_web.dart test/transport_web_browser_test.dart`

Exact output and exit:

```text
Exit: 0
```

## Remaining gates

No unresolved issue was found within the focused implementation and browser test. This evidence does not establish the complete-source suite, the final `.pubignore` payload inventory, publish warning policy, external consumer behavior or publication readiness; those remain assigned to Group 2.
