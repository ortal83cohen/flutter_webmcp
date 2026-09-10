# Implementation review — round 01

- Work item: 0005-pubdev-release-readiness
- Reviewed artifact: frozen `19-criteria-consolidated.md` with normative `21-release-decisions.md` and final warning policy in `23-warning-policy-evidence.md`; complete source at observed HEAD `4689c66b4d4f3198040a9d6d8a770dee3a695235`; immutable 22-file payload identified by `27-payload-inventory.json`, SHA-256 `d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e`.
- Reviewer: independent release_review agent
- Date: 2026-09-10

## Verdict

**PASS**

Every applicable preupload implementation criterion is met by independent execution and artifact inspection; private launch authorization/account/availability and postpublication checks remain phase-deferred and are not asserted complete.

## Verification performed

The reviewer read the criteria, normative contract, comparison evidence expressly referenced by AC-001, runtime/source artifacts, payload inventories, reproduction helpers, raw command evidence, rubric and template. Implementation self-assessments 24/25 and author reasoning were not review inputs. Source and payload were not edited. Disposable copies and this report are the only reviewer-authored artifacts; Flutter generated its ordinary resolution/build files while running the requested suite.

All Flutter/Dart commands below use `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH` and `CI=true`. Browser execution also sets `CHROME_EXECUTABLE=/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`. The reviewer used the original complete source for the six-stage suite and browser test. Packaging and external consumers used an independent byte-identical copy of the already verified payload; every included original/source/copy byte was rechecked afterward. No original payload was altered. The reviewed published-path inventory contains 22 files, including the example; no tests, wiki, tools or generated caches enter it.

The sandboxed first suite attempt failed at SDK cache writes. This was an environment permission failure, followed by a complete approved run with the same command and source; its output is retained here, not silently counted as a pass.

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH CI=true bash tools/check.sh`

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 71: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.stamp.tmp.11979: Operation not permitted
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 78: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.realm: Operation not permitted
Stage 2 failed: dependencies
Exit: 1
```

### Complete canonical suite output

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`.

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH CI=true bash tools/check.sh` (approved SDK cache access).

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
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
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Stage 2 passed: dependencies
Formatted 24 files (0 changed) in 0.04 seconds.
Stage 3 passed: format
Analyzing flutter_webmcp...
No issues found!
Stage 4 passed: analysis
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
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: source registration retains tools added before a later failure
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes handler result and exception objects through unchanged
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: input schema is shallow copied and is not runtime validation
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: unregister is idempotent
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:01 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:01 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:01 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:01 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: disabled child does not disable direct tool invocation
00:01 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:01 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:01 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:01 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:01 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:01 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:01 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:01 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for initial newlines in triple strings
00:01 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: notifies registration and unregistration in order
00:01 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for encoded import URIs
00:01 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: registration notification failure propagates after mutation
00:01 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: registration notification failure propagates after mutation
00:01 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:01 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:01 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:02 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction classifies only the fixed forbidden import families
00:02 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every fixed header and the bare AWS prefix
00:02 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every assignment spelling and separator
00:02 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures does not infer markers outside the exhaustive set
00:02 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:02 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:02 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:02 +39: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:02 +40: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:02 +41: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:02 +42: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:02 +43: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:02 +44: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:02 +45: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:02 +46: All tests passed!
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             19.4s
✓ Built build/web
Stage 6 passed: build

Exit: 0
```

### versions

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`.

Command: `flutter --version`

```text
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
Engine • hash 59d54a2b2896a6bbf356c94b7fac7b9e235bdacd (revision 5f77625673) (29 days ago) • 2026-08-11 16:38:36.000Z
Tools • Dart 3.13.0 • DevTools 2.60.0

Exit: 0
```

### dart-version

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`.

Command: `dart --version`

```text
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"

Exit: 0
```

### browser

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`.

Command: `flutter test --platform chrome test/transport_web_browser_test.dart --reporter expanded`

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

### dry

Working directory: `/private/tmp/webmcp-review-010/payload`.

Command: `dart pub publish --dry-run`

```text
Resolving dependencies...
Downloading packages...
+ _fe_analyzer_shared 103.0.0 (107.0.0 available)
+ analyzer 13.3.0 (14.3.0 available)
+ args 2.7.0
+ async 2.13.1
+ boolean_selector 2.1.2
+ characters 1.4.1
+ cli_config 0.2.0
+ clock 1.1.3
+ collection 1.19.1
+ convert 3.1.2
+ coverage 1.15.1
+ crypto 3.0.7
+ fake_async 1.3.3
+ file 7.0.1
+ flutter 0.0.0 from sdk flutter
+ flutter_lints 6.0.0
+ flutter_test 0.0.0 from sdk flutter
+ frontend_server_client 4.0.0
+ glob 2.2.0
+ http_multi_server 3.2.2
+ http_parser 4.1.2
+ io 1.1.0
+ leak_tracker 11.0.2
+ leak_tracker_flutter_testing 3.0.10
+ leak_tracker_testing 3.0.2
+ lints 6.1.0
+ logging 1.3.0
+ matcher 0.12.20
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ mime 2.1.0
+ node_preamble 2.0.2
+ package_config 2.2.0 (3.0.0 available)
+ path 1.9.1
+ pool 1.5.3
+ pub_semver 2.2.1
+ shelf 1.4.2
+ shelf_packages_handler 3.0.2
+ shelf_static 1.1.3
+ shelf_web_socket 3.0.0
+ sky_engine 0.0.0 from sdk flutter
+ source_map_stack_trace 2.1.2
+ source_maps 0.10.14
+ source_span 1.10.2
+ stack_trace 1.12.2
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ term_glyph 1.2.2
+ test 1.31.1 (1.32.0 available)
+ test_api 0.7.12 (0.7.14 available)
+ test_core 0.6.18 (0.6.20 available)
+ typed_data 1.4.0
+ vector_math 2.4.2
+ vm_service 15.3.0
+ watcher 1.2.1
+ web 1.1.1
+ web_socket 1.0.1
+ web_socket_channel 3.0.3
+ webkit_inspection_protocol 1.2.1
+ yaml 3.1.4
Changed 60 dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
├── CHANGELOG.md (<1 KB)
├── LICENSE (1 KB)
├── README.md (3 KB)
├── example
│   ├── analysis_options.yaml (<1 KB)
│   ├── lib
│   │   ├── example_screen.dart (2 KB)
│   │   ├── example_tools.dart (<1 KB)
│   │   └── main.dart (<1 KB)
│   ├── pubspec.yaml (<1 KB)
│   └── web
│       └── index.html (<1 KB)
├── lib
│   ├── src
│   │   ├── transport
│   │   │   ├── transport_noop.dart (<1 KB)
│   │   │   ├── transport_selector.dart (<1 KB)
│   │   │   ├── transport_web.dart (1 KB)
│   │   │   └── webmcp_transport.dart (<1 KB)
│   │   ├── webmcp.dart (2 KB)
│   │   ├── webmcp_exceptions.dart (1 KB)
│   │   ├── webmcp_scope.dart (2 KB)
│   │   ├── webmcp_tool.dart (<1 KB)
│   │   ├── webmcp_tool_source.dart (<1 KB)
│   │   └── widgets
│   │       ├── webmcp_action.dart (2 KB)
│   │       └── webmcp_screen.dart (1 KB)
│   └── webmcp_flutter.dart (<1 KB)
└── pubspec.yaml (<1 KB)

Total compressed archive size: 7 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 65
```

### waived

Working directory: `/private/tmp/webmcp-review-010/payload`.

Command: `dart pub publish --dry-run --ignore-warnings`

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
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
├── CHANGELOG.md (<1 KB)
├── LICENSE (1 KB)
├── README.md (3 KB)
├── example
│   ├── analysis_options.yaml (<1 KB)
│   ├── lib
│   │   ├── example_screen.dart (2 KB)
│   │   ├── example_tools.dart (<1 KB)
│   │   └── main.dart (<1 KB)
│   ├── pubspec.yaml (<1 KB)
│   └── web
│       └── index.html (<1 KB)
├── lib
│   ├── src
│   │   ├── transport
│   │   │   ├── transport_noop.dart (<1 KB)
│   │   │   ├── transport_selector.dart (<1 KB)
│   │   │   ├── transport_web.dart (1 KB)
│   │   │   └── webmcp_transport.dart (<1 KB)
│   │   ├── webmcp.dart (2 KB)
│   │   ├── webmcp_exceptions.dart (1 KB)
│   │   ├── webmcp_scope.dart (2 KB)
│   │   ├── webmcp_tool.dart (<1 KB)
│   │   ├── webmcp_tool_source.dart (<1 KB)
│   │   └── widgets
│   │       ├── webmcp_action.dart (2 KB)
│   │       └── webmcp_screen.dart (1 KB)
│   └── webmcp_flutter.dart (<1 KB)
└── pubspec.yaml (<1 KB)

Total compressed archive size: 7 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 0
```

### consumer-get

Working directory: `/private/tmp/webmcp-review-010/consumer`.

Command: `flutter pub get`

```text
Resolving dependencies...
Downloading packages...
+ characters 1.4.1
+ collection 1.19.1
+ flutter 0.0.0 from sdk flutter
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ sky_engine 0.0.0 from sdk flutter
+ vector_math 2.4.2
+ web 1.1.1
+ webmcp_flutter 0.1.0 from path /private/tmp/webmcp-review-010/payload
Changed 9 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

Exit: 0
```

### consumer-analyze

Working directory: `/private/tmp/webmcp-review-010/consumer`.

Command: `flutter analyze --fatal-infos --fatal-warnings`

```text
Analyzing consumer...                                           
No issues found! (ran in 2.9s)

Exit: 0
```

### consumer-build

Working directory: `/private/tmp/webmcp-review-010/consumer`.

Command: `flutter build web`

```text
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             20.5s
✓ Built build/web

Exit: 0
```

### example-get

Working directory: `/private/tmp/webmcp-review-010/payload/example`.

Command: `flutter pub get`

```text
Resolving dependencies...
Downloading packages...
+ async 2.13.1
+ boolean_selector 2.1.2
+ characters 1.4.1
+ clock 1.1.3
+ collection 1.19.1
+ fake_async 1.3.3
+ flutter 0.0.0 from sdk flutter
+ flutter_lints 6.0.0
+ flutter_test 0.0.0 from sdk flutter
+ leak_tracker 11.0.2
+ leak_tracker_flutter_testing 3.0.10
+ leak_tracker_testing 3.0.2
+ lints 6.1.0
+ matcher 0.12.20
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ path 1.9.1
+ sky_engine 0.0.0 from sdk flutter
+ source_span 1.10.2
+ stack_trace 1.12.2
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ term_glyph 1.2.2
+ test_api 0.7.12 (0.7.14 available)
+ vector_math 2.4.2
+ vm_service 15.3.0
+ web 1.1.1
+ webmcp_flutter 0.1.0 from path ..
Changed 28 dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.

Exit: 0
```

### example-build

Working directory: `/private/tmp/webmcp-review-010/payload/example`.

Command: `flutter build web`

```text
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             19.4s
✓ Built build/web

Exit: 0
```

### negative-build

Working directory: `/private/tmp/webmcp-review-010/negative-consumer`.

Command: `flutter build web`

```text
Resolving dependencies...
Downloading packages...
+ characters 1.4.1
+ collection 1.19.1
+ flutter 0.0.0 from sdk flutter
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ sky_engine 0.0.0 from sdk flutter
+ vector_math 2.4.2
+ web 1.1.1
+ webmcp_flutter 0.1.0 from path /private/tmp/webmcp-review-010/negative-payload
Changed 9 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Target dart2js failed: ProcessException: Process exited abnormally with exit code 1:
lib/main.dart:2:8:
Error: Error when reading '../negative-payload/lib/webmcp_flutter.dart': Error reading '../negative-payload/lib/webmcp_flutter.dart'  (No such file or directory)
import 'package:webmcp_flutter/webmcp_flutter.dart';
       ^
lib/main.dart:16:10:
Error: Type 'WebMcpScreen' not found.
    with WebMcpScreen<CounterPage> {
         ^^^^^^^^^^^^
lib/main.dart:28:16:
Error: The method 'WebMcpAction' isn't defined for the type '_CounterPageState'.
 - '_CounterPageState' is from 'package:review_consumer/main.dart' ('lib/main.dart').
        child: WebMcpAction(
               ^^^^^^^^^^^^
Error: Compilation failed.
  Command: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart compile js --platform-binaries=/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/flutter_web_sdk/kernel --invoker=flutter_tool -Ddart.vm.product=true -DFLUTTER_VERSION=3.47.0 -DFLUTTER_CHANNEL=[user-branch] -DFLUTTER_GIT_URL=https://github.com/flutter/flutter.git -DFLUTTER_FRAMEWORK_REVISION=4cf2416426 -DFLUTTER_ENGINE_REVISION=5f77625673 -DFLUTTER_DART_VERSION=3.13.0 -DFLUTTER_WEB_USE_SKIA=true -DFLUTTER_WEB_USE_SKWASM=false -DFLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/5f77625673248ee5846fbcaf5d3e1a3878386fd7/ --write-resources --enable-experiment=record-use --native-null-assertions --no-source-maps -O4 --minify -o /private/tmp/webmcp-review-010/negative-consumer/.dart_tool/flutter_build/bb89beeb72ebc00d67bdc100aa647b2b/app.dill --packages=/private/tmp/webmcp-review-010/negative-consumer/.dart_tool/package_config.json --cfe-only /private/tmp/webmcp-review-010/negative-consumer/.dart_tool/flutter_build/bb89beeb72ebc00d67bdc100aa647b2b/main.dart
#0      RunResult.throwException (package:flutter_tools/src/base/process.dart:153:5)
#1      _DefaultProcessUtils.run (package:flutter_tools/src/base/process.dart:379:19)
<asynchronous suspension>
#2      Dart2JSTarget.build (package:flutter_tools/src/build_system/targets/web.dart:219:5)
<asynchronous suspension>
#3      _BuildInstance._invokeInternal (package:flutter_tools/src/build_system/build_system.dart:937:9)
<asynchronous suspension>
#4      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#5      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#6      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#7      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#8      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#9      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#10     FlutterBuildSystem.build (package:flutter_tools/src/build_system/build_system.dart:684:16)
<asynchronous suspension>
#11     WebBuilder.buildWeb (package:flutter_tools/src/web/compile.dart:107:34)
<asynchronous suspension>
#12     BuildWebCommand.runCommand (package:flutter_tools/src/commands/build_web.dart:293:5)
<asynchronous suspension>
#13     FlutterCommand.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command.dart:1663:27)
<asynchronous suspension>
#14     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#15     CommandRunner.runCommand (package:args/command_runner.dart:212:13)
<asynchronous suspension>
#16     FlutterCommandRunner.runCommand.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:496:9)
<asynchronous suspension>
#17     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#18     FlutterCommandRunner.runCommand (package:flutter_tools/src/runner/flutter_command_runner.dart:431:5)
<asynchronous suspension>
#19     FlutterCommandRunner.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:307:33)
<asynchronous suspension>
#20     run.<anonymous closure>.<anonymous closure> (package:flutter_tools/runner.dart:104:11)
<asynchronous suspension>
#21     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#22     main (package:flutter_tools/executable.dart:103:3)
<asynchronous suspension>

Compiling lib/main.dart for the Web...                             15.5s
Error: Failed to compile application for the Web.

Exit: 1
```

### Publisher exclusion negative case

Working directory: `/private/tmp/webmcp-review-010/exclusion-payload`.

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH CI=true dart pub publish --dry-run --ignore-warnings`

This separate disposable copy adds the actual `.pubignore` and 11 harmless synthetic files at excluded paths. Their full names and construction appear in the helper below. The actual publisher list is compared to the approved 22-file inventory; none of the probes enters the package. No credentials were used.

```text
Resolving dependencies...
Downloading packages...
+ _fe_analyzer_shared 103.0.0 (107.0.0 available)
+ analyzer 13.3.0 (14.3.0 available)
+ args 2.7.0
+ async 2.13.1
+ boolean_selector 2.1.2
+ characters 1.4.1
+ cli_config 0.2.0
+ clock 1.1.3
+ collection 1.19.1
+ convert 3.1.2
+ coverage 1.15.1
+ crypto 3.0.7
+ fake_async 1.3.3
+ file 7.0.1
+ flutter 0.0.0 from sdk flutter
+ flutter_lints 6.0.0
+ flutter_test 0.0.0 from sdk flutter
+ frontend_server_client 4.0.0
+ glob 2.2.0
+ http_multi_server 3.2.2
+ http_parser 4.1.2
+ io 1.1.0
+ leak_tracker 11.0.2
+ leak_tracker_flutter_testing 3.0.10
+ leak_tracker_testing 3.0.2
+ lints 6.1.0
+ logging 1.3.0
+ matcher 0.12.20
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ mime 2.1.0
+ node_preamble 2.0.2
+ package_config 2.2.0 (3.0.0 available)
+ path 1.9.1
+ pool 1.5.3
+ pub_semver 2.2.1
+ shelf 1.4.2
+ shelf_packages_handler 3.0.2
+ shelf_static 1.1.3
+ shelf_web_socket 3.0.0
+ sky_engine 0.0.0 from sdk flutter
+ source_map_stack_trace 2.1.2
+ source_maps 0.10.14
+ source_span 1.10.2
+ stack_trace 1.12.2
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ term_glyph 1.2.2
+ test 1.31.1 (1.32.0 available)
+ test_api 0.7.12 (0.7.14 available)
+ test_core 0.6.18 (0.6.20 available)
+ typed_data 1.4.0
+ vector_math 2.4.2
+ vm_service 15.3.0
+ watcher 1.2.1
+ web 1.1.1
+ web_socket 1.0.1
+ web_socket_channel 3.0.3
+ webkit_inspection_protocol 1.2.1
+ yaml 3.1.4
Changed 60 dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
├── CHANGELOG.md (<1 KB)
├── LICENSE (1 KB)
├── README.md (3 KB)
├── example
│   ├── analysis_options.yaml (<1 KB)
│   ├── lib
│   │   ├── example_screen.dart (2 KB)
│   │   ├── example_tools.dart (<1 KB)
│   │   └── main.dart (<1 KB)
│   ├── pubspec.yaml (<1 KB)
│   └── web
│       └── index.html (<1 KB)
├── lib
│   ├── src
│   │   ├── transport
│   │   │   ├── transport_noop.dart (<1 KB)
│   │   │   ├── transport_selector.dart (<1 KB)
│   │   │   ├── transport_web.dart (1 KB)
│   │   │   └── webmcp_transport.dart (<1 KB)
│   │   ├── webmcp.dart (2 KB)
│   │   ├── webmcp_exceptions.dart (1 KB)
│   │   ├── webmcp_scope.dart (2 KB)
│   │   ├── webmcp_tool.dart (<1 KB)
│   │   ├── webmcp_tool_source.dart (<1 KB)
│   │   └── widgets
│   │       ├── webmcp_action.dart (2 KB)
│   │       └── webmcp_screen.dart (1 KB)
│   └── webmcp_flutter.dart (<1 KB)
└── pubspec.yaml (<1 KB)

Total compressed archive size: 7 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 0
```

### inventory

Command: `python3 /private/tmp/webmcp-review-010/verify.py`

```text
PASS: all 22 payload paths, sizes and SHA-256 match source inventory, original payload and current source
PASS: reviewer payload is an exact fresh copy with no extra files
Created independent fresh README consumer and missing-barrel negative consumer
Payload inventory SHA-256: d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e

Exit: 0
```

### negatives

Command: `python3 /private/tmp/webmcp-review-010/negative_checks.py`

```text
EXPECTED REJECTION: AC-001 missing pinned comparison hashes: 14-kicknext-comparison.md
EXPECTED REJECTION: AC-001 missing pinned comparison hashes: 15-intentcall-comparison.md
EXPECTED REJECTION: AC-002 fabricated source URL
EXPECTED REJECTION: AC-003 stale package name
EXPECTED REJECTION: AC-003 mismatched version
EXPECTED REJECTION: AC-003 wrong SDK minimum
EXPECTED REJECTION: AC-008/010 changed approved bytes
EXPECTED REJECTION: AC-008/011 added repository-only file
Prepared 11 synthetic ignored-path probes for actual publisher exclusion check
HEAD: 4689c66b4d4f3198040a9d6d8a770dee3a695235
PASS: MIT bytes unchanged from original HEAD; no wiki paths deleted
Index SHA-256: 75604696f8f9699feae95968dcf413a891f9bae4d373b203001d06acff7e8f74

Exit: 0
```

### final-checks

Command: `python3 /private/tmp/webmcp-review-010/final_checks.py`

```text
PASS: dry actual publication listing exactly matches all 22 approved paths; exact optional-URL warning only; zero errors
PASS: waived actual publication listing exactly matches all 22 approved paths; exact optional-URL warning only; zero errors
PASS: exclusions actual publication listing exactly matches all 22 approved paths; exact optional-URL warning only; zero errors
EXPECTED REJECTION: AC-008 unaccepted second warning
PASS: consumer resolves ONLY to /private/tmp/webmcp-review-010/payload and has built web/index.html
PASS: payload/example resolves ONLY to /private/tmp/webmcp-review-010/payload and has built web/index.html
PASS: all included bytes unchanged in /Users/ortalcohen/Documents/GitHub/flutter_webmcp
PASS: all included bytes unchanged in /private/tmp/webmcp-release-010-run/payload
PASS: all included bytes unchanged in /private/tmp/webmcp-review-010/payload
Index SHA-256: 75604696f8f9699feae95968dcf413a891f9bae4d373b203001d06acff7e8f74
git diff --check output: (empty)

Exit: 0
```

### Artifact and chronology inspection

The reviewer inspected `README.md:3`, `README.md:75`, `pubspec.yaml:1`, `example/pubspec.yaml:3`, `CHANGELOG.md:3`, `lib/webmcp_flutter.dart:1`, the semantic implementations and tests, and `.pubignore:1` against `.gitignore:1`. The consumer sample uses the public import, no obsolete scaffold instructions, and no native interoperability claim. The original MIT bytes are unchanged, and the historical Git diff contains no deleted wiki paths. Recovery at `17-plan-consolidated.md:46` requires a corrected higher version and fresh gates after publication, with no overwrite of published bytes.

Observed reviewer starting HEAD was `4689c66b4d4f3198040a9d6d8a770dee3a695235` with a clean tracked working tree. The baseline inventory refers to an earlier dirty source context, while read-only current history contains later commits. The reviewer did not observe who made those commits and makes no claim about that actor or their authorization. Included source/payload identity remains verified independently of commit history. The index hash captured during this review and at its end is identical (`75604696f8f9699feae95968dcf413a891f9bae4d373b203001d06acff7e8f74`); no reviewer Git mutation occurred. This report does not certify unobserved historical actor behavior.

Negative evidence is bounded: the metadata/hash/warning probes test the review's acceptance predicates against deliberately invalid evidence, while actual Dart tests exercise runtime rejection/limit behavior; the browser, absent-barrel build and publisher-exclusion probes exercise real tools. Launch and hosted negative cases cannot be executed before their phases and are marked deferred below.

### Reproduction helpers used by the reviewer


`/private/tmp/webmcp-review-010/verify.py`

```python
from pathlib import Path
import shutil,re,json,hashlib,subprocess,os
r=Path('/private/tmp/webmcp-review-010'); repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp'); original=Path('/private/tmp/webmcp-release-010-run/payload')
rows=json.loads((repo/'wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json').read_text())
source={v['path']:v for v in json.loads((repo/'wiki/work/0005-pubdev-release-readiness/26-source-inventory.json').read_text())}
def check(root):
 for v in rows:
  p=root/v['path']; assert p.stat().st_size==v['size'] and hashlib.sha256(p.read_bytes()).hexdigest()==v['sha256'],v['path']
check(original);check(repo)
assert all(source[v['path']]==v for v in rows)
print('PASS: all',len(rows),'payload paths, sizes and SHA-256 match source inventory, original payload and current source')
shutil.copytree(original,r/'payload',ignore=shutil.ignore_patterns('.dart_tool','build','pubspec.lock'))
check(r/'payload')
assert sorted(str(p.relative_to(r/'payload')) for p in (r/'payload').rglob('*') if p.is_file())==[v['path'] for v in rows]
print('PASS: reviewer payload is an exact fresh copy with no extra files')
for name,negative in [('consumer',False),('negative-consumer',True)]:
 payload=r/'payload'
 if negative:
  payload=r/'negative-payload';shutil.copytree(r/'payload',payload);(payload/'lib/webmcp_flutter.dart').unlink()
 dst=r/name;dst.mkdir();(dst/'lib').mkdir();(dst/'web').mkdir()
 snippets=re.findall(r'```dart\s*\n(.*?)```',(original/'README.md').read_text(),re.S);main=[s for s in snippets if 'void main(' in s];assert len(main)==1
 (dst/'lib/main.dart').write_text(main[0]);(dst/'pubspec.yaml').write_text('name: review_consumer\npublish_to: none\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n  webmcp_flutter:\n    path: '+str(payload)+'\nflutter:\n  uses-material-design: true\n')
 (dst/'web/index.html').write_text('<!DOCTYPE html><html><head><base href="$FLUTTER_BASE_HREF"><meta charset="utf-8"><title>Review consumer</title></head><body><script src="flutter_bootstrap.js" async></script></body></html>\n')
print('Created independent fresh README consumer and missing-barrel negative consumer')
print('Payload inventory SHA-256:',hashlib.sha256((repo/'wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json').read_bytes()).hexdigest())
```

`/private/tmp/webmcp-review-010/negative_checks.py`

```python
from pathlib import Path
import re,json,hashlib,subprocess,shutil
r=Path('/private/tmp/webmcp-review-010');repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp');w=repo/'wiki/work/0005-pubdev-release-readiness';rows=json.loads((w/'27-payload-inventory.json').read_text())
def rejected(label,fn):
 try:fn()
 except (AssertionError,ValueError): print('EXPECTED REJECTION:',label);return
 raise RuntimeError('Negative case was accepted: '+label)
def pinned(text):assert re.search(r'\b[a-f0-9]{64}\b',text)
for f in ['14-kicknext-comparison.md','15-intentcall-comparison.md']:
 text=(w/f).read_text();pinned(text);rejected('AC-001 missing pinned comparison hashes: '+f,lambda:pinned(re.sub(r'\b[a-f0-9]{64}\b','[UNVERIFIED]',text)))
def metadata(text):
 for line in ['name: webmcp_flutter','version: 0.1.0','  sdk: ^3.13.0','  flutter: ">=3.47.0"']:assert line in text
 assert not re.search(r'^(homepage|repository):',text,re.M)
text=(repo/'pubspec.yaml').read_text();metadata(text)
rejected('AC-002 fabricated source URL',lambda:metadata(text+'\nrepository: https://invalid.example/synthetic\n'))
rejected('AC-003 stale package name',lambda:metadata(text.replace('name: webmcp_flutter','name: obsolete_fixture')))
rejected('AC-003 mismatched version',lambda:metadata(text.replace('version: 0.1.0','version: 0.2.0')))
rejected('AC-003 wrong SDK minimum',lambda:metadata(text.replace('^3.13.0','^3.12.0')))
def identity(actual):assert actual==rows
changed=json.loads(json.dumps(rows));changed[0]['sha256']='0'*64
rejected('AC-008/010 changed approved bytes',lambda:identity(changed))
extra=json.loads(json.dumps(rows));extra.append({'path':'wiki/synthetic.md','size':1,'sha256':'0'*64})
rejected('AC-008/011 added repository-only file',lambda:identity(extra))
shutil.copytree(r/'payload',r/'exclusion-payload',ignore=shutil.ignore_patterns('.dart_tool','build','pubspec.lock'))
shutil.copyfile(repo/'.pubignore',r/'exclusion-payload/.pubignore')
for name in ['.env','.env.example','dummy.pem','dummy.key','secrets/synthetic.txt','test/synthetic.dart','tools/synthetic.py','wiki/synthetic.md','example/test/synthetic.dart','.DS_Store','build/synthetic.txt']:
 p=r/'exclusion-payload'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('Synthetic exclusion probe only.\n')
print('Prepared 11 synthetic ignored-path probes for actual publisher exclusion check')
# Capture reviewer-observed preservation, without inferring who made earlier commits.
print('HEAD:',subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip())
assert subprocess.check_output(['git','diff','dccbad724308ce93f75fb95580282b18292ad0df','--','LICENSE'],cwd=repo)==b''
assert not subprocess.check_output(['git','diff','--diff-filter=D','--name-only','dccbad724308ce93f75fb95580282b18292ad0df','--','wiki'],cwd=repo)
print('PASS: MIT bytes unchanged from original HEAD; no wiki paths deleted')
print('Index SHA-256:',hashlib.sha256((repo/'.git/index').read_bytes()).hexdigest())
```

`/private/tmp/webmcp-review-010/final_checks.py`

```python
from pathlib import Path
import json,hashlib,re,urllib.parse,subprocess
r=Path('/private/tmp/webmcp-review-010');repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp');rows=json.loads((repo/'wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json').read_text())
def paths(text):
 result=[];stack=[];started=False
 for line in text.splitlines():
  if line.startswith('Publishing webmcp_flutter 0.1.0 '):started=True;continue
  if not started:continue
  if line.startswith('Total compressed archive size:'):break
  m=re.match(r'^((?:│   |    )*)[├└]── (.+)$',line)
  if not m:continue
  depth=len(m[1])//4;f=re.match(r'^(.*) \([^()]+\)$',m[2]);stack=stack[:depth]
  if f:result.append('/'.join(stack+[f[1]]))
  else:stack.append(m[2])
 return sorted(result)
warning='* It\'s strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml'
def policy(text):
 assert [l for l in text.splitlines() if l.startswith('* ')]==[warning]
 assert 'Package has 1 warning.' in text and 'error' not in text.lower()
for label in ['dry','waived','exclusions']:
 text=(r/(label+'.log')).read_text();assert paths(text)==[v['path'] for v in rows];policy(text)
 print('PASS:',label,'actual publication listing exactly matches all 22 approved paths; exact optional-URL warning only; zero errors')
try:policy((r/'waived.log').read_text()+'\n* Synthetic unexpected warning\n')
except AssertionError:print('EXPECTED REJECTION: AC-008 unaccepted second warning')
else:raise AssertionError('Unexpected warning accepted')
for name in ['consumer','payload/example']:
 cfg=r/name/'.dart_tool/package_config.json';raw=cfg.read_text();pkg=next(p for p in json.loads(raw)['packages'] if p['name']=='webmcp_flutter');target=Path(urllib.parse.unquote(urllib.parse.urlparse(urllib.parse.urljoin(cfg.as_uri(),pkg['rootUri'])).path)).resolve()
 assert target==r/'payload' and str(repo) not in raw;assert (r/name/'build/web/index.html').is_file()
 print('PASS:',name,'resolves ONLY to',target,'and has built web/index.html')
for root in [repo,Path('/private/tmp/webmcp-release-010-run/payload'),r/'payload']:
 for v in rows:
  p=root/v['path'];assert p.stat().st_size==v['size'] and hashlib.sha256(p.read_bytes()).hexdigest()==v['sha256']
 print('PASS: all included bytes unchanged in',root)
print('Index SHA-256:',hashlib.sha256((repo/'.git/index').read_bytes()).hexdigest())
print('git diff --check output:',subprocess.check_output(['git','diff','--check'],cwd=repo,text=True).strip() or '(empty)')
```

`/private/tmp/webmcp-review-010/run_checks.py`

```python
import os,subprocess,json
from pathlib import Path
r=Path('/private/tmp/webmcp-review-010'); repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp'); env=os.environ.copy();env['PATH']='/Users/ortalcohen/fvm/versions/3.47.0/bin:'+env['PATH'];env['CI']='true';env['CHROME_EXECUTABLE']='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
checks=[('versions',repo,['flutter','--version']),('dart-version',repo,['dart','--version']),('browser',repo,['flutter','test','--platform','chrome','test/transport_web_browser_test.dart','--reporter','expanded']),('dry',r/'payload',['dart','pub','publish','--dry-run']),('waived',r/'payload',['dart','pub','publish','--dry-run','--ignore-warnings']),('consumer-get',r/'consumer',['flutter','pub','get']),('consumer-analyze',r/'consumer',['flutter','analyze','--fatal-infos','--fatal-warnings']),('consumer-build',r/'consumer',['flutter','build','web']),('example-get',r/'payload/example',['flutter','pub','get']),('example-build',r/'payload/example',['flutter','build','web']),('negative-build',r/'negative-consumer',['flutter','build','web'])]
for label,cwd,cmd in checks:
 p=subprocess.run(cmd,cwd=cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
 (r/(label+'.log')).write_text(p.stdout);(r/(label+'.json')).write_text(json.dumps({'cmd':cmd,'cwd':str(cwd),'exit':p.returncode}));print(label,': exit',p.returncode,flush=True)
```

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | PASS — pre-freeze comparison evidence reused as required | `14-kicknext-comparison.md:15`; `15-intentcall-comparison.md:9`; `08-capability-comparison.md:12`; `21-release-decisions.md:28` | Yes: stripped-hash comparison evidence rejected by the review predicate. Inspected every matrix gap against the explicit dispositions, including unsupported parity, uncertain repeated attachment and custom failures; no undecided release contract retained. |
| AC-002 | PASS — selection/metadata; PHASE-DEFERRED — immediate launch account, name/version and redistribution authority | `pubspec.yaml:1`; `21-release-decisions.md:9`; `21-release-decisions.md:47`; `23-warning-policy-evidence.md:65`; `LICENSE:1` | Yes: fabricated repository URL rejected; actual manifest omits optional URLs and uses the precise accepted warning. Occupied-name/reused-version/authority stops are deferred launch tests, not claims of live availability. |
| AC-003 | PASS | `pubspec.yaml:1`; `example/pubspec.yaml:3`; `lib/webmcp_flutter.dart:1`; `CHANGELOG.md:3`; `README.md:103` | Yes: stale name, mismatched version and altered SDK minimum rejected. Public-import consumer compiles; missing public barrel fails. No broader tested-matrix claim appears. |
| AC-004 | PASS | `README.md:3`; `README.md:9`; `README.md:27`; `README.md:106`; consumer analysis/build output above | Yes: deleting the barrel from a fresh disposable payload makes the exact README sample fail to compile; source inspection rejects the interpretation that the example publishes or accepts browser calls. |
| AC-005 | PASS | `README.md:75`; `README.md:88`; `README.md:93`; `wiki/product/webmcp-contract.md:57`; `test/registry_test.dart:52`; `test/transport_selection_test.dart:87`; `lib/src/webmcp.dart:24` | Yes: real suite exercises invalid/duplicate/missing tools, failed sequential registration retaining prior items, nested schema mutation, unchanged mounted metadata/latest callback, disabled-child direct invocation, throwing registration/removal notifications without rollback, and reset with no prior-transport notifications. |
| AC-006 | PASS | `test/transport_web_browser_test.dart:27`; `test/transport_web_browser_test.dart:41`; `test/transport_web_browser_test.dart:50`; `test/transport_web_browser_test.dart:63`; `lib/src/transport/transport_web.dart:14`; `lib/webmcp_flutter.dart:1` | Yes: real Chrome marker-absent assertion returns false; marker-present assertion returns true; actual transport logs tools not published; marker unchanged and no tool property created. Setup/teardown controls/restores the property, and detection class is absent from the public barrel. |
| AC-007 | PASS — only Flutter 3.47.0/Dart 3.13.0 | `tools/check.sh:1`; full suite/version/browser outputs above | Yes: initial real sandbox cache denial fails the suite at stage 2 and is recorded; subsequent complete approved run executes all six stages and exits zero, plus actual Chrome test. Runtime negative tests also execute in the suite. No skipped stage is counted as passing. |
| AC-008 | PASS | `.pubignore:1`; `.pubignore:24`; `27-payload-inventory.json:1`; `21-release-decisions.md:47`; actual dry/waived/exclusions/final-check outputs above | Yes: ordinary dry-run exits 65 with exactly the permitted URL warning; unchanged waived run exits zero. A second synthetic warning, altered digest and extra wiki path fail review predicates. Actual publisher excludes all 11 synthetic sensitive/repository/generated paths. All 22 real payload paths/sizes/hashes match source and every actual publication list. |
| AC-009 | PASS — preupload; PHASE-DEFERRED — exact hosted-version consumer after upload | `README.md:27`; `example/pubspec.yaml:14`; `27-payload-inventory.json:1`; independent consumer/example/negative/provenance outputs above | Yes: independent fresh consumer resolves only the reviewed payload, analyzes and builds; shipped example resolves that same copy and builds. Fresh missing-barrel payload/consumer fails compilation with the missing public import, so no repository fallback masks a defect. Hosted resolution is deferred. |
| AC-010 | PASS — preupload candidate identity/gate definition; PHASE-DEFERRED — explicit launch approval, upload and hosted presentation | `21-release-decisions.md:49`; `21-release-decisions.md:53`; `19-criteria-consolidated.md:23`; `27-payload-inventory.json:1` | Yes for applicable identity portion: altered candidate digest rejected. No upload executed by reviewer. Missing approval/account selection, occupied name and hosted-failure recovery are launch/postpublication negatives and remain deferred; this PASS does not approve upload or identify an account. |
| AC-011 | PASS — inspected implementation/artifact preservation; unobserved historical actor attribution not asserted | `LICENSE:1`; `.pubignore:24`; `17-plan-consolidated.md:46`; `test/repo_hygiene_test.dart:1`; preservation and exclusions outputs above | Yes: actual publisher excludes synthetic environment/key/secret and wiki/test/tool paths; canonical hygiene tests exercise synthetic secret markers; altered/extra inventory records rejected. MIT unchanged and no wiki deletion in inspected history; reviewer index hash unchanged. Higher-version recovery avoids immutable-byte replacement. Earlier external Git chronology is stated without an unverified actor attribution. |

All relative work-item evidence paths in this table refer to `wiki/work/0005-pubdev-release-readiness/`; repository source and product wiki paths retain their stated repository-relative meaning.

## Findings

None in the applicable preupload implementation scope. Expected negative-case failures and the narrowly accepted publication diagnostic are not unresolved implementation failures. Deferred launch/postpublication gates are not represented as passed execution.

## Recurrence check

- Previous round: none — first implementation round for this work item.
- Recurring findings: none.
- Oscillating: no.

## Routing

| Finding | Belongs to phase |
|---|---|
| None | No defect routing verdict required. |
