# Implementation evidence: Rename package to webmcp_flutter

## Implemented scope

The root package is `webmcp_flutter`, its sole public barrel is `lib/webmcp_flutter.dart`, and the example is `webmcp_flutter_example`. Imports, logger labels, active README and product documentation, example branding, and web metadata use the approved identity. The barrel exports are byte-identical to the pre-rename barrel. Version, license, dependencies other than renamed local package keys, platforms, public API, and runtime logic were not changed.

No files were staged, committed, pushed, or published. Historical work artifacts were not rewritten by the implementation.

The isolated implementation diff against `/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/webmcp-rename-baseline-dwu_5ap6` is `/private/tmp/webmcp-rename-implementation.diff`.

## Initial full-suite result

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH bash tools/check.sh`

Exit status: 1.

Full output:

```text
Preflight: flutter and dart found
error: wiki/work/0006-rename-webmcp-flutter/validation/plan-review-01.md: missing '## Verification performed'. A verdict without pasted command output is an assertion, not evidence.
error: wiki/work/0006-rename-webmcp-flutter/validation/plan-review-01.md: missing '## Recurrence check'. Without it an oscillating loop is indistinguishable from progress.
error: wiki/work/0006-rename-webmcp-flutter/validation/research-review-01.md: missing '## Verification performed'. A verdict without pasted command output is an assertion, not evidence.
error: wiki/work/0006-rename-webmcp-flutter/validation/research-review-01.md: missing '## Recurrence check'. Without it an oscillating loop is indistinguishable from progress.

4 error(s), 0 warning(s).
Stage 1 failed: wiki lint
```

The validator-owned reports were repaired append-only by their owner. A subsequent suite then reached Stage 6 but found an old generated example entrypoint after the package rename.

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH bash tools/check.sh`

Exit status: 1.

Relevant exact output from the otherwise-passing run and the complete failure section:

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Stage 2 passed: dependencies
Formatted 23 files (0 changed) in 0.03 seconds.
Stage 3 passed: format
Analyzing flutter_webmcp...
No issues found!
Stage 4 passed: analysis
00:02 +39: All tests passed!
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...

Unexpected wasm dry run failure (255):

'record-use' is now enabled by default; this flag is no longer required.
'record-use' is now enabled by default; this flag is no longer required.
Unhandled exception:
Unsupported operation: Cannot extract a file path from a org-dartlang-untranslatable-uri URI
#0      _Uri.toFilePath (dart:core/uri.dart:3432)
#1      DryRunSummarizer._lintChecks (package:dart2wasm/dry_run.dart:204)
#2      DryRunSummarizer.summarize (package:dart2wasm/dry_run.dart:278)
#3      _runCfePhase (package:dart2wasm/compile.dart:356)
<asynchronous suspension>
#4      compile (package:dart2wasm/compile.dart:245)
<asynchronous suspension>
#5      generateWasm (package:dart2wasm/generate_wasm.dart:78)
<asynchronous suspension>
#6      main (file:///Volumes/Work/s/w/ir/x/w/sdk/pkg/dart2wasm/bin/dart2wasm.dart:10)
<asynchronous suspension>

Use --no-wasm-dry-run to disable these warnings.
Target dart2js failed: ProcessException: Process exited abnormally with exit code 1:
Error: Couldn't resolve the package 'webmcp_pilot_example' in 'package:webmcp_pilot_example/main.dart'.
.dart_tool/flutter_build/7adebe6e15f68719d7cc554acc8a541e/main.dart:12:8:
Error: Not found: 'package:webmcp_pilot_example/main.dart'
import 'package:webmcp_pilot_example/main.dart' as entrypoint;
       ^
.dart_tool/flutter_build/7adebe6e15f68719d7cc554acc8a541e/main.dart:21:22:
Error: Undefined name 'main'.
      if (entrypoint.main is _UnaryFunction) {
                     ^^^^
.dart_tool/flutter_build/7adebe6e15f68719d7cc554acc8a541e/main.dart:22:28:
Error: Undefined name 'main'.
        return (entrypoint.main as _UnaryFunction)(<String>[]);
                           ^^^^
.dart_tool/flutter_build/7adebe6e15f68719d7cc554acc8a541e/main.dart:24:26:
Error: Undefined name 'main'.
      return (entrypoint.main as _NullaryFunction)();
                         ^^^^
Error: Compilation failed.
Compiling lib/main.dart for the Web...                           1,323ms
Error: Failed to compile application for the Web.
Stage 6 failed: build
```

The stale generated state was removed with `flutter clean` in `example/`; its exact output and exit status were:

```text
Deleting build...                                                   32ms
Deleting .dart_tool...                                              31ms
```

Exit status: 0.

## Final full suite

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH bash tools/check.sh`

Exit status: 0.

Full output:

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
Formatted 23 files (0 changed) in 0.03 seconds.
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
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:00 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: notifies registration and unregistration in order
00:01 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction ignores exports, comments, strings, and conditional values
00:01 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for initial newlines in triple strings
00:01 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for encoded import URIs
00:01 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction preserves raw ordinary literal content
00:01 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:01 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction classifies only the fixed forbidden import families
00:01 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every fixed header and the bare AWS prefix
00:01 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every assignment spelling and separator
00:01 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures does not infer markers outside the exhaustive set
00:01 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:01 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:01 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:01 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:01 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:01 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:01 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:01 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:01 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:01 +39: All tests passed!
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
```

## Identity and generated-metadata checks

The active old-identity scan command was:

`rg -n --hidden --glob '!wiki/work/**' --glob '!build/**' --glob '!.dart_tool/**' --glob '!example/.dart_tool/**' 'webmcp_pilot|WebMCP Pilot' pubspec.yaml lib test example README.md wiki/product/webmcp-contract.md`

Exit status: 1. Output: none, which is the expected absence result.

Resolved metadata inspection output:

```text
example/.dart_tool/package_graph.json:3:    "webmcp_flutter_example"
example/.dart_tool/package_graph.json:7:      "name": "webmcp_flutter_example",
example/.dart_tool/package_graph.json:11:        "webmcp_flutter"
example/.dart_tool/package_graph.json:44:      "name": "webmcp_flutter",
.dart_tool/package_config.json:365:      "name": "webmcp_flutter",
example/.dart_tool/package_config.json:167:      "name": "webmcp_flutter",
example/.dart_tool/package_config.json:173:      "name": "webmcp_flutter_example",
.dart_tool/package_graph.json:3:    "webmcp_flutter"
.dart_tool/package_graph.json:7:      "name": "webmcp_flutter",
```

Command: `git diff --check`

Exit status: 0. Output: none.
