---
id: 0004-impl-review-01
title: Flutter WebMCP skeleton implementation review round 01
status: active
owner: validator
last_verified: 2026-09-10
applies_to: ["lib/**", "test/**", "example/**", "tools/check.sh"]
summary: Independent implementation validation with isolated mutation evidence and three findings.
---

# Implementation review — round 01

- Work item: 0004-flutter-webmcp-skeleton
- Reviewed artifact: implementation working tree and index relative to `dccbad724308ce93f75fb95580282b18292ad0df`; package sources, tests, example, manifests, check script, license, changelog, README, ignore rules, AGENTS checks and workflow.
- Captured implementation snapshot: synthetic temporary commit `aad36edce1467895c17d7b2248970c74502ff197`. All findings refer to this captured source state. The orchestrator later reported an author edit adding the AC-017 typedef reference during review; that repair was not rechecked and does not change this single-round verdict.
- Reviewer: independent validator subagent
- Date: 2026-09-10
- Inputs: frozen acceptance criteria, implementation artifact/diff, validation rubric and report template. No author plan, notes, transcript or implementation assessment was read. The orchestrator supplied only the normative secret-marker sentence when AC-032's undefined reference was identified.

## Verdict

**FAIL**

AC-017 omits an explicitly required public type reference, and the complete test stage accepts valid forbidden multiline imports under AC-018 and AC-044. AC-032's exhaustive marker contract is also undefined in the permitted normative material.

## Verification performed

All runtime checks were executed by this reviewer using `/Users/ortalcohen/fvm/versions/3.47.0/bin` prepended to PATH. Initial sandbox SDK-cache writes failed; approved cache access allowed actual checks to run. No source files were repaired or edited in the real checkout. Mutations ran one at a time in `/private/tmp/webmcp-validator-xeh_qiad`, a synthetic committed snapshot, with original source restored after each. The slow timing mutation used a separate script copy and reached source stages only after source mutations finished. Static mutations used a second temporary directory. The actual author's tracking change was inspected once after notification; it is not inferred from the synthetic index.

The initial snapshot omitted the scaffold CLAUDE.md, so the first preflight-removal probe encountered wiki lint instead of dependencies. CLAUDE.md was copied byte-for-byte and committed only in the temporary snapshot; the completed probe is separately recorded. An initial static jobs predicate accidentally counted trigger entries; the corrected predicate restricts parsing to the jobs section. Neither harness correction changed implementation source or revisited a validation finding.

### Actual checkout full suite, root and alternate working directory

Root command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH /usr/bin/time -p bash tools/check.sh`

Pasted output excerpt (exit 0):

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Stage 2 passed: dependencies
Formatted 23 files (0 changed) in 0.03 seconds.
Stage 3 passed: format
No issues found!
Stage 4 passed: analysis
00:00 +29: All tests passed!
00:00 +1: All tests passed!
Stage 5 passed: tests
✓ Built build/web
Stage 6 passed: build
real 28.92
user 45.72
sys 5.48
```

Warm second command, working directory `/private/tmp`: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH /usr/bin/time -p bash /Users/ortalcohen/Documents/GitHub/flutter_webmcp/tools/check.sh` (exit 0). Pasted output:

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
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:00 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +29: All tests passed!
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             17.6s
✓ Built build/web
Stage 6 passed: build
real 27.27
user 30.79
sys 4.27
```

The build's font-family diagnostic is visible above; the compiler and script both exited zero. These checks prove VM behavior and compilation, not browser WebMCP calls or a GitHub Actions run. AC-026 explicitly permits the unrequested CI/push half to remain pending.

### Per-criterion results

Every row names its implemented evidence and an independently exercised negative. “Conditional” means the visible probe works but the complete normative set cannot be established; it is not counted as an unconditional pass.

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `tools/check.sh:4,20` | Yes — Stage deletion produced only stages 2–6; fixed order predicate rejected it. |
| AC-002 | pass | `tools/check.sh:7` | Yes — Minimal PATH failed before stages; deleting preflight reached dependencies after wiki. |
| AC-003 | pass | `tools/check.sh:15,34` | Yes — Inverted assertion stopped at stage 5; removing strict mode and the test guard ran build and returned zero. |
| AC-004 | pass | `tools/check.sh:27` | Yes — Malformed whitespace returned 1 and named lib/src/webmcp.dart. |
| AC-005 | pass | `tools/check.sh:31; analysis_options.yaml:17` | Yes — Unused example variable and undocumented root public method produced warning plus info, exit 2. |
| AC-006 | pass | `analysis_options.yaml:4; example/analysis_options.yaml:4` | Yes — Cold committed-snapshot checksums stayed equal; missing ios exclusion triggered migration and a diff. |
| AC-007 | pass | `example/analysis_options.yaml:5` | Yes — Excluded build probe passed; deleting nested build exclusion exposed undefined_function, exit 3. |
| AC-008 | pass | `example/pubspec.yaml:3` | Yes — Removing publish_to produced invalid_dependency, exit 2. |
| AC-009 | pass | `lib/src/webmcp.dart:24,53; test/registry_test.dart:22` | Yes — Deleting insertion failed listing assertions. |
| AC-010 | pass | `lib/src/webmcp.dart:36; test/registry_test.dart:35` | Yes — Direct source insertion bypassed collision validation and failed the assertion. |
| AC-011 | pass | `lib/src/webmcp.dart:28; test/registry_test.dart:50` | Yes — Removing duplicate guard failed exception assertions. |
| AC-012 | pass | `lib/src/webmcp.dart:18; test/registry_test.dart:65` | Yes — Widened pattern failed invalid-name tests; independent invalid cases kept listing unchanged. |
| AC-013 | pass | `lib/src/webmcp.dart:62; test/registry_test.dart:76` | Yes — Empty argument map returned null instead of 42; independent identity/await check passed. |
| AC-014 | pass | `lib/src/webmcp.dart:66; test/registry_test.dart:87` | Yes — Fallback to first handler failed missing-tool expectations. |
| AC-015 | pass | `lib/src/webmcp.dart:43; test/registry_test.dart:109` | Yes — Throwing for second unregister failed idempotence. |
| AC-016 | pass | `lib/src/webmcp.dart:74; test/transport_selection_test.dart:26` | Yes — Retaining fake transport failed; independent populated reset returned noop and cleared listing. |
| AC-017 | fail | `test/webmcp_public_surface_test.dart:24` | Yes — Exception/action export deletions and private import were rejected; required WebMcpToolHandler identifier is absent (F-001). |
| AC-018 | fail | `test/repo_hygiene_test.dart:18,29` | Yes — Single-line forbidden import failed; valid multiline dart:io import passed the complete test stage (F-002). |
| AC-019 | pass | `lib/src/transport/transport_selector.dart:1; test/transport_selection_test.dart:26` | Yes — Web-default mutation failed VM compilation. |
| AC-020 | pass | `lib/src/webmcp.dart:32,48; test/transport_selection_test.dart:36` | Yes — Missing unregister notification failed two-event sequence assertion. |
| AC-021 | pass | `lib/src/transport/transport_web.dart:18,24; test/transport_web_source_test.dart:6` | Yes — Renamed transport identifier failed source contract test. |
| AC-022 | pass | `example/lib/example_tools.dart:13; example/test/example_tools_test.dart:8` | Yes — Renamed example read tool failed expected name list. |
| AC-023 | pass | `tools/check.sh:38; example/web/index.html:1` | Yes — Deleting web entry returned 1: project not configured for web. |
| AC-024 | pass | `.github/workflows/checks.yml:9,29` | Yes — Exactly wiki and package jobs; adding needs failed structural predicate. |
| AC-025 | pass | `.github/workflows/checks.yml:49; AGENTS.md:73` | Yes — Changing documented full-suite command to sh failed literal comparison. |
| AC-026 | pass; CI log pending | `.github/workflows/checks.yml:43` | Yes — Second version literal failed count predicate; local SDK reports 3.47.0. No push or live CI log. |
| AC-027 | pass | `README.md:1,11` | Yes — Original HEAD README is unchanged suffix; third-party toggle rewording failed comparison. |
| AC-028 | pass | `CHANGELOG.md:1; LICENSE:1; pubspec.yaml:1` | Yes — Actual disk and index include all required paths after author tracking step; renamed changelog failed existence check. |
| AC-029 | pass | `pubspec.yaml:20` | Yes — Adding android failed web-only key predicate. |
| AC-030 | pass | `AGENTS.md:71` | Yes — Checks heading deletion failed predicate; 76 lines, all four commands present, wiki lint clean. |
| AC-031 | pass | `tools/check.sh:20` | Yes — Warm full run 27.27 seconds; inserted 400-second sleep exceeded 300-second bound (timing output below). |
| AC-032 | conditional: marker set undefined | `test/repo_hygiene_test.dart:65,92; wiki/work/0004-flutter-webmcp-skeleton/02-criteria.md:63` | Yes — Tracked YAML synthetic AWS marker failed and named file/marker; exhaustive marker equivalence [UNVERIFIED] (F-003). |
| AC-033 | pass | `.gitignore:30` | Yes — All six paths matched; removal of example build pattern returned no match. |
| AC-034 | pass | `lib/src/webmcp_scope.dart:39,64; test/webmcp_scope_test.dart:22` | Yes — Both close-without-unregister and source-bypasses-ownership mutations failed. |
| AC-035 | pass | `lib/src/webmcp_scope.dart:28; test/webmcp_scope_test.dart:38` | Yes — Marking duplicate name owned failed skip/ownership assertions. |
| AC-036 | pass | `lib/src/webmcp_scope.dart:23,64,76; test/webmcp_scope_test.dart:60` | Yes — Removing closed guard failed StateError assertion. |
| AC-037 | pass | `lib/src/webmcp_scope.dart:28; test/webmcp_scope_test.dart:76` | Yes — Catching all WebMcpException swallowed invalid name and failed assertion. |
| AC-038 | pass | `lib/src/widgets/webmcp_screen.dart:30,37; test/widget_layer_test.dart:65` | Yes — Removing scope close on disposal left registration and failed. |
| AC-039 | pass | `lib/src/widgets/webmcp_action.dart:64,76; test/widget_layer_test.dart:75` | Yes — Prefixing action name failed literal name expectation. |
| AC-040 | pass | `lib/src/widgets/webmcp_action.dart:73; test/widget_layer_test.dart:85` | Yes — AbsorbPointer child wrapper failed identity/callback expectations. |
| AC-041 | pass | `lib/src/widgets/webmcp_action.dart:67; test/widget_layer_test.dart:109` | Yes — Captured callback returned first value after rebuild and failed. |
| AC-042 | pass | `lib/src/widgets/webmcp_action.dart:56; test/widget_layer_test.dart:165` | Yes — Fallback scope prevented missing-scope exception and failed. |
| AC-043 | pass | `lib/src/webmcp_scope.dart:28; test/widget_layer_test.dart:185` | Yes — Rethrowing duplicate exception made duplicate-screen pump fail. |
| AC-044 | fail | `test/repo_hygiene_test.dart:18,42` | Yes — Single-line Flutter import failed; valid multiline Flutter import passed complete test stage (F-002). |
| AC-045 | pass | `test/webmcp_scope_test.dart:1; test/repo_hygiene_test.dart:61` | Yes — Adding Flutter test import failed hygiene boundary; existing scope tests use package:test and never pump. |
| AC-046 | pass | `example/lib/example_screen.dart:15,59; example/lib/main.dart:3,16` | Yes — Deleting example screen produced missing URI and undefined class errors. |

## Findings

### F-001 — Public-surface test never names the handler typedef

- Severity: BLOCKER
- Location: `test/webmcp_public_surface_test.dart:24`
- Criterion affected: AC-017
- Observation: The handler is declared as a local function and inferred through the tool constructor. Whole-word inspection finds zero `WebMcpToolHandler` identifiers anywhere in this test, although AC-017 explicitly requires naming this type at least once. All other listed public type names are present.
- Why it matters: The frozen public-surface contract is not met, and this file does not directly establish that a consumer can name the exported handler typedef. Passing the existing test does not establish this missing assertion.

### F-002 — Line-based import scans accept valid forbidden directives

- Severity: BLOCKER
- Location: `test/repo_hygiene_test.dart:18` (patterns at lines 29 and 42)
- Criteria affected: AC-018, AC-044
- Observation: The scans apply regular expressions separately to each line. A valid directive split after a line comment places the import keyword and URI on different lines. In isolation, adding `import // valid multiline directive` followed by ` 'dart:io';` to example/lib/example_tools.dart passed all 29 root tests and the example test. The same shape with ` 'package:flutter/widgets.dart';` in lib/src/webmcp.dart also passed the entire test stage. The prescribed single-line probes were correctly rejected.
- Why it matters: Both criteria require the test stage to reject any matching import directive. They do not restrict this to single-line syntax, and no offending path or import is reported for these valid directives.

### F-003 — Exhaustive secret-marker conformance has no fixed comparison set

- Severity: BLOCKER
- Location: `wiki/work/0004-flutter-webmcp-skeleton/02-criteria.md:63`
- Criterion affected: AC-032
- Observation: The criterion delegates its exact marker list to the plan's Interfaces section. On request, the orchestrator supplied the normative sentence only: “And it fails if any file under lib/, example/lib/, tools/ or .github/ contains any of the fixed literal markers for a private-key header, an AWS access-key prefix, or the words for an application key or a password used as an assignment target. All four lists are fixed here so no step invents its own.” The orchestrator confirmed no additional literal list exists there. This names categories but no fixed literal set. The implemented regex and synthetic AWS YAML rejection are verified; correspondence to an authoritative complete marker list is [UNVERIFIED].
- Why it matters: Independent validation cannot determine whether all required marker spellings and prefix forms are covered without inventing acceptance details. This is a normative-definition gap, not a demonstrated failure of the implemented synthetic AWS probe.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | implement |
| F-002 | implement |
| F-003 | plan |

This report classifies defects and evidence only; disposition belongs to the main agent. No fixes or next-phase decisions are prescribed.

## Detailed command evidence

The following are pasted command outputs, with explicit excerpts where long compiler traces or repeated test names are omitted. Exit statuses are captured process return codes. Mutation names identify the one isolated change preceding each command. Snapshot setup used `git init`, `git add .`, and a synthetic local commit under /private/tmp only; no real-checkout commit or push occurred.

### AC006 cold dependencies

Command: `flutter pub get && (cd example && flutter pub get)`

Exit: 0; wall time: 1.57 seconds. Pasted output:

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
```

### AC006 checksums

Command: `SHA256 committed blobs versus after first dependency run`

Exit: 0. Pasted output:

```text
({'analysis_options.yaml': '82a7e1ba26651381e2b269e6e9c3899e3b6eb30a655b15546ac3911982d63554', 'example/analysis_options.yaml': '057d9e7ac76d22002c3d152858da3f450165588ace6e55ccdf90662b70ff1432'}, {'analysis_options.yaml': '82a7e1ba26651381e2b269e6e9c3899e3b6eb30a655b15546ac3911982d63554', 'example/analysis_options.yaml': '057d9e7ac76d22002c3d152858da3f450165588ace6e55ccdf90662b70ff1432'})
```

### baseline snapshot test

Command: `flutter test --reporter expanded && (cd example && flutter test --reporter expanded)`

Exit: 0; wall time: 10.84 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-validator-xeh_qiad/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +1: /private/tmp/webmcp-validator-xeh_qiad/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +2: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +3: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +4: /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +5: /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +6: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:00 +7: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:00 +8: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:00 +9: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +10: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +11: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixi
[... output excerpt; intervening lines omitted ...]
callback
00:00 +19: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +20: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action copies its input schema
00:00 +21: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +22: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +23: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +24: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +25: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +26: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +27: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +28: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +29: All tests passed!
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
```

### AC009 omitted insertion

Command: `flutter test --reporter expanded test/registry_test.dart`

Exit: 1; wall time: 1.87 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +0 -1: registers tools and lists them in ascending order [E]
  Expected: ['alpha', 'middle', 'zeta']
    Actual: MappedListIterable<WebMcpTool, String>:[]
     Which: at location [0] is MappedListIterable<WebMcpTool, String>:[] which shorter than expected
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 28:5                        main.<fn>
  
00:00 +0 -1: registers sources through duplicate validation
00:00 +0 -2: registers sources through duplicate validation [E]
  Expected: an object with length of <2>
    Actual: []
     Which: has length of <0>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 39:5                        main.<fn>
  
00:00 +0 -2: rejects duplicates without replacing the first handler
00:00 +0 -3: rejects duplicates without replacing the first handler [E]
  Expected: throws <Instance of 'WebMcpDuplicateToolException'> with `toolName`: 'same'
    Actual: <Closure: () => void>
     Which: returned <null>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 52:5                        main.<fn>
  
00:00 +0 -3: validates empty, long, and unsupported names
00:00 +0 -4: validates empty, long, and unsupported names [E]
  Expected: an object with length of <1>
    Actual: []
     Which: has length of <0>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 73:5                        main.<fn>
  
00:00 +0 -4: passes arguments through and awaits the handler
00:00 +0 -5: passes arguments through and awaits the handler [E]
  WebMcpToolNotFoundException: No registered tool has this name. (tool: echo)
  package:webmcp_pilot/src/webmcp.dart 68:7  WebMcp.invokeTool
  test/registry_test.dart 84:34              main.<fn>
  
00:00 +0 -5: throws for a missing tool without invoking another handler
00:00 +1 -5: unregister is idempotent
00:00 +1 -6: unregister is idempotent [E]
  Expected: true
    Actual: <false>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 111:5                       main.<fn>
  
00:00 +1 -6: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: passes arguments through and awaits the handler
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers sources through duplicate validation
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers tools and lists them in ascending order
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: rejects duplicates without replacing the first handler
  ... and 2 more
```

### AC010 source bypasses validation

Command: `flutter test --reporter expanded test/registry_test.dart`

Exit: 1; wall time: 1.46 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +1 -1: registers sources through duplicate validation [E]
  Expected: throws <Instance of 'WebMcpDuplicateToolException'>
    Actual: <Closure: () => void>
     Which: returned <null>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 42:5                        main.<fn>
  
00:00 +1 -1: rejects duplicates without replacing the first handler
00:00 +2 -1: validates empty, long, and unsupported names
00:00 +3 -1: passes arguments through and awaits the handler
00:00 +4 -1: throws for a missing tool without invoking another handler
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers sources through duplicate validation
```

### AC011 duplicate overwrites

Command: `flutter test --reporter expanded test/registry_test.dart`

Exit: 1; wall time: 1.5 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +1 -1: registers sources through duplicate validation [E]
  Expected: throws <Instance of 'WebMcpDuplicateToolException'>
    Actual: <Closure: () => void>
     Which: returned <null>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 42:5                        main.<fn>
  
00:00 +1 -1: rejects duplicates without replacing the first handler
00:00 +1 -2: rejects duplicates without replacing the first handler [E]
  Expected: throws <Instance of 'WebMcpDuplicateToolException'> with `toolName`: 'same'
    Actual: <Closure: () => void>
     Which: returned <null>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 52:5                        main.<fn>
  
00:00 +1 -2: validates empty, long, and unsupported names
00:00 +2 -2: passes arguments through and awaits the handler
00:00 +3 -2: throws for a missing tool without invoking another handler
00:00 +4 -2: unregister is idempotent
00:00 +5 -2: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers sources through duplicate validation
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: rejects duplicates without replacing the first handler
```

### AC012 name rule widened

Command: `flutter test --reporter expanded test/registry_test.dart`

Exit: 1; wall time: 1.6 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +3 -1: validates empty, long, and unsupported names [E]
  Expected: throws <Instance of 'WebMcpInvalidToolNameException'>
    Actual: <Closure: () => void>
     Which: returned <null>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 67:7                        main.<fn>
  
00:00 +3 -1: passes arguments through and awaits the handler
00:00 +4 -1: throws for a missing tool without invoking another handler
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: validates empty, long, and unsupported names
```

### AC013 arguments replaced

Command: `flutter test --reporter expanded test/registry_test.dart`

Exit: 1; wall time: 1.48 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +4: passes arguments through and awaits the handler
00:00 +4 -1: passes arguments through and awaits the handler [E]
  Expected: <42>
    Actual: <null>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 84:5                        main.<fn>
  
00:00 +4 -1: throws for a missing tool without invoking another handler
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: passes arguments through and awaits the handler
```

### AC014 missing name fallback

Command: `flutter test --reporter expanded test/registry_test.dart`

Exit: 1; wall time: 1.51 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +4: passes arguments through and awaits the handler
00:00 +5: throws for a missing tool without invoking another handler
00:00 +5 -1: throws for a missing tool without invoking another handler [E]
  Expected: throws <Instance of 'WebMcpToolNotFoundException'> with `toolName`: 'missing'
    Actual: <Instance of 'Future<Object?>'>
     Which: emitted <0>
  
  package:matcher                                    expectLater
  package:flutter_test/src/widget_tester.dart 507:8  expectLater
  test/registry_test.dart 96:11                      main.<fn>
  
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: throws for a missing tool without invoking another handler
```

### AC015 missing unregister throws

Command: `flutter test --reporter expanded test/registry_test.dart`

Exit: 1; wall time: 1.46 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +4: passes arguments through and awaits the handler
00:00 +5: throws for a missing tool without invoking another handler
00:00 +6: unregister is idempotent
00:00 +6 -1: unregister is idempotent [E]
  WebMcpToolNotFoundException: No registered tool has this name. (tool: temporary)
  package:webmcp_pilot/src/webmcp.dart 46:7  WebMcp.unregisterTool
  test/registry_test.dart 113:28             main.<fn>
  
00:00 +6 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: unregister is idempotent
```

### AC016 reset retains transport

Command: `flutter test --reporter expanded test/transport_selection_test.dart`

Exit: 1; wall time: 1.55 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart
00:00 +0: selects noop on the Dart VM and resets transport
00:00 +0 -1: selects noop on the Dart VM and resets transport [E]
  Expected: 'noop'
    Actual: 'fake'
     Which: is different.
            Expected: noop
              Actual: fake
                      ^
             Differ at offset 0
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/transport_selection_test.dart 32:5             main.<fn>
  
00:00 +0 -1: notifies registration and unregistration in order
00:00 +1 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
```

### AC017a exception export removed

Command: `flutter test --reporter expanded test/webmcp_public_surface_test.dart`

Exit: 1; wall time: 1.15 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart
test/webmcp_public_surface_test.dart:45:14: Error: Undefined name 'WebMcpException'.
      expect(WebMcpException, isNotNull);
             ^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:46:14: Error: Undefined name 'WebMcpInvalidToolNameException'.
      expect(WebMcpInvalidToolNameException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:47:14: Error: Undefined name 'WebMcpDuplicateToolException'.
      expect(WebMcpDuplicateToolException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:48:14: Error: Undefined name 'WebMcpToolNotFoundException'.
      expect(WebMcpToolNotFoundException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:49:14: Error: Undefined name 'WebMcpScopeMissingException'.
      expect(WebMcpScopeMissingException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^
00:00 +0 -1: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart [E]
  Failed to load "/private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart":
  Compilation failed for testPath=/private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart: test/webmcp_public_surface_test.dart:45:14: Error: Undefined name 'WebMcpException'.
        expect(WebMcpException, isNotNull);
               ^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:46:14: Error: Undefined name 'WebMcpInvalidToolNameException'.
        expect(WebMcpInvalidToolNameException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:47:14: Error: Undefined name 'WebMcpDuplicateToolException'.
        expect(WebMcpDuplicateToolException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:48:14: Error: Undefined name 'WebMcpToolNotFoundException'.
        expect(WebMcpToolNotFoundException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:49:14: Error: Undefined name 'WebMcpScopeMissingException'.
        expect(WebMcpScopeMissingException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart
```

### AC017b action export removed

Command: `flutter test --reporter expanded test/webmcp_public_surface_test.dart`

Exit: 1; wall time: 1.22 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart
test/webmcp_public_surface_test.dart:44:14: Error: Undefined name 'WebMcpAction'.
      expect(WebMcpAction, isNotNull);
             ^^^^^^^^^^^^
00:00 +0 -1: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart [E]
  Failed to load "/private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart":
  Compilation failed for testPath=/private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart: test/webmcp_public_surface_test.dart:44:14: Error: Undefined name 'WebMcpAction'.
        expect(WebMcpAction, isNotNull);
               ^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart
```

### AC017c private test import

Command: `flutter test --reporter expanded test/repo_hygiene_test.dart`

Exit: 1; wall time: 1.59 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +2 -1: public and scope tests preserve their import boundaries [E]
  Expected: not contains 'package:webmcp_pilot/src/'
    Actual: 'import \'package:webmcp_pilot/src/webmcp.dart\';\n'
              'import \'package:flutter_test/flutter_test.dart\';\n'
              'import \'package:webmcp_pilot/webmcp_pilot.dart\';\n'
              '\n'
              'final class _Source implements WebMcpToolSource {\n'
              '  @override\n'
              '  List<WebMcpTool> getWebMcpTools() => <WebMcpTool>[];\n'
              '}\n'
              '\n'
              'final class _Transport implements WebMcpTransport {\n'
              '  @override\n'
              '  String get id => \'public\';\n'
              '\n'
              '  @override\n'
              '  void onToolRegistered(WebMcpTool tool) {}\n'
              '\n'
              '  @override\n'
              '  void onToolUnregistered(String name) {}\n'
              '}\n'
              '\n'
              'void main() {\n'
              '  test(\n'
              '    \'exports the complete public API and seven registry operations\',\n'
              '    () async {\n'
              '      Object? handler(Map<String, Object?> arguments) => arguments[\'value\'];\n'
              '      final WebMcpTool tool = WebMcpTool(\n'
              '        name: \'public.tool\',\n'
              '        description: \'Public tool\',\n'
              '        handler: handler,\n'
              '      );\n'
              '      final WebMcp registry = WebMcp.instance;\n'
              '      registry.reset(_Transport());\n'
              '      registry.registerTool(tool);\n'
              '      registry.registerSource(_Source());\n'
              '      expect(registry.tools.single, same(tool));\n'
              '      expect(\n'
              '        await registry.invokeTool(\'public.tool\', const {\'value\': \'ok\'}),\n'
              '        \'ok\',\n'
              '      );\n'
              '      expect(registry.transportId, \'public\');\n'
              '      expect(registry.unregisterTool(\'public.tool\'), isTrue);\n'
              '\n'
              '      expect(WebMcpScope, isNotNull);\n'
              '      expect(WebMcpScreen, isNotNull);\n'
              '      expect(WebMcpAction, isNotNull);\n'
              '      expect(WebMcpException, isNotNull);\n'
              '      expect(WebMcpInvalidToolNameException, isNotNull);\n'
              '      expect(WebMcpDuplicateToolException, isNotNull);\n'
              '      expect(WebMcpToolNotFoundException, isNotNull);\n'
              '      expect(WebMcpScopeMissingException, isNotNull);\n'
              '    },\n'
              '  );\n'
              '}\n'
              ''
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 60:5                    main.<fn>
  
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
```

### AC018 forbidden import

Command: `flutter test --reporter expanded test/repo_hygiene_test.dart`

Exit: 1; wall time: 1.54 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +0 -1: library and example sources avoid forbidden imports [E]
  Expected: empty
    Actual: ['example/lib/example_tools.dart: import \'dart:html\';']
  example/lib/example_tools.dart: import 'dart:html';
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 37:5                    main.<fn>
  
00:00 +0 -1: Flutter imports stay inside the widget layer
00:00 +1 -1: public and scope tests preserve their import boundaries
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

### AC019 web default

Command: `flutter test --reporter expanded test/transport_selection_test.dart`

Exit: 1; wall time: 1.86 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart
lib/src/transport/transport_web.dart:2:8: Error: Dart library 'dart:js_interop' is not available on this platform.
import 'dart:js_interop';
       ^
Context: The unavailable library 'dart:js_interop' is imported through these packages:

    /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart => package:webmcp_pilot => dart:js_interop
    /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart => package:webmcp_pilot => package:web => dart:js_interop
    ...

Detailed import paths for (some of) the these imports:

    listener.dart => /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport_selector.dart => package:webmcp_pilot/src/transport/transport_web.dart => dart:js_interop
    listener.dart => /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport_selector.dart => package:webmcp_pilot/src/transport/transport_web.dart => package:web/web.dart => package:web/src/dom.dart => package:web/src/dom/accelerometer.dart => dart:js_interop
    listener.dart => /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport
[... output excerpt; intervening lines omitted ...]
from 'dart:core'.
          completer.completeError(e);
                                  ^
  /Users/ortalcohen/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/helpers/http.dart:249:34: Error: The argument type 'void Function(Object, [StackTrace?])' can't be assigned to the parameter type 'void Function(ProgressEvent)?'.
   - 'Object' is from 'dart:core'.
   - 'StackTrace' is from 'dart:core'.
      xhr.onError.listen(completer.completeError);
                                   ^
  /Users/ortalcohen/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/helpers/http.dart:252:46: Error: The getter 'toJS' isn't defined for the type 'String'.
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'toJS'.
        xhr.send(sendData is String ? sendData.toJS : sendData.jsify());
                                               ^^^^
  /Users/ortalcohen/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/helpers/http.dart:252:62: Error: The method 'jsify' isn't defined for the type 'Object'.
   - 'Object' is from 'dart:core'.
  Try correcting the name to the name of an existing method, or defining a method named 'jsify'.
        xhr.send(sendData is String ? sendData.toJS : sendData.jsify());
                                                               ^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: loading /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart
```

### AC020 missing unregister notification

Command: `flutter test --reporter expanded test/transport_selection_test.dart`

Exit: 1; wall time: 1.96 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart
00:00 +0: selects noop on the Dart VM and resets transport
00:00 +1: notifies registration and unregistration in order
00:00 +1 -1: notifies registration and unregistration in order [E]
  Expected: ['registered:observed', 'unregistered:observed']
    Actual: ['registered:observed']
     Which: at location [1] is ['registered:observed'] which shorter than expected
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/transport_selection_test.dart 48:5             main.<fn>
  
00:00 +1 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: notifies registration and unregistration in order
```

### AC021 transport identifier changed

Command: `flutter test --reporter expanded test/transport_web_source_test.dart`

Exit: 1; wall time: 1.95 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/transport_web_source_test.dart
00:00 +0: web transport retains its detection-only contract
00:00 +0 -1: web transport retains its detection-only contract [E]
  Expected: contains 'web-detection'
    Actual: 'import \'dart:developer\' as developer;\n'
              'import \'dart:js_interop\';\n'
              'import \'dart:js_interop_unsafe\';\n'
              '\n'
              'import \'package:web/web.dart\';\n'
              '\n'
              'import \'../webmcp_tool.dart\';\n'
              'import \'webmcp_transport.dart\';\n'
              '\n'
              '/// Creates the browser feature-detection transport.\n'
              'WebMcpTransport createDefaultTransport() => WebDetectionTransport();\n'
              '\n'
              '/// Detects browser WebMCP support and logs registry changes.\n'
              'final class WebDetectionTransport implements WebMcpTransport {\n'
              '  /// Creates a transport and records whether WebMCP appears available.\n'
              '  WebDetectionTransport()\n'
              '    : _isAvailable = document.hasProperty(\'modelContext\'.toJS).toDart {\n'
              '    _write(\'modelContext detected: $_isAvailable; tools not published\');\n'
              '  }\n'
              '\n'
              '  final bool _isAvailable;\n'
              '\n'
              '  @override\n'
              '  String get id => \'renamed\';\n'
              '\n'
              '  @override\n'
              '  void onToolRegistered(WebMcpTool tool) {\n'
              '    _write(\'registered ${tool.name}; tools not published\');\n'
              '  }\n'
              '\n'
              '  @override\n'
              '  void onToolUnregistered(String name) {\n'
              '    _write(\'unregistered $name; tools not published\');\n'
              '  }\n'
              '\n'
              '  void _write(String message) {\n'
              '    developer.log(message, name: \'webmcp_pilot\');\n'
              '  }\n'
              '}\n'
              ''
     Which: does not contain 'web-detection'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/transport_web_source_test.dart 9:5             main.<fn>
  
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/transport_web_source_test.dart: web transport retains its detection-only contract
```

### AC022 tool renamed

Command: `cd example && flutter test --reporter expanded`

Exit: 1; wall time: 1.44 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +0 -1: registers two imperative tools and increments the counter [E]
  Expected: ['example.counter.increment', 'example.counter.read']
    Actual: MappedListIterable<WebMcpTool, String>:[
              'example.counter.increment',
              'example.counter.renamed'
            ]
     Which: at location [1] is 'example.counter.renamed' instead of 'example.counter.read'
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/example_tools_test.dart 12:5                   main.<fn>
  
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart: registers two imperative tools and increments the counter
```

### AC034a close does not unregister

Command: `flutter test --reporter expanded test/webmcp_scope_test.dart`

Exit: 1; wall time: 1.62 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +0 -1: adds direct and source tools, then closes [E]
  Expected: empty
    Actual: [Instance of 'WebMcpTool', Instance of 'WebMcpTool']
  
  package:matcher                   expect
  test/webmcp_scope_test.dart 33:5  main.<fn>
  
00:00 +0 -1: skips duplicates and never removes another owner
00:00 +1 -1: remove is limited to names owned by the scope
00:00 +2 -1: close is idempotent and closed scopes reject additions
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +4 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: adds direct and source tools, then closes
```

### AC034b source bypasses ownership

Command: `flutter test --reporter expanded test/webmcp_scope_test.dart`

Exit: 1; wall time: 1.48 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +0 -1: adds direct and source tools, then closes [E]
  Expected: ['direct', 'source']
    Actual: ['direct']
     Which: at location [1] is ['direct'] which shorter than expected
  
  package:matcher                   expect
  test/webmcp_scope_test.dart 30:5  main.<fn>
  
00:00 +0 -1: skips duplicates and never removes another owner
00:00 +1 -1: remove is limited to names owned by the scope
00:00 +2 -1: close is idempotent and closed scopes reject additions
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +4 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: adds direct and source tools, then closes
```

### AC035 skipped duplicate marked owned

Command: `flutter test --reporter expanded test/webmcp_scope_test.dart`

Exit: 1; wall time: 1.44 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +1: skips duplicates and never removes another owner
00:00 +1 -1: skips duplicates and never removes another owner [E]
  Expected: empty
    Actual: ['shared']
  
  package:matcher                   expect
  test/webmcp_scope_test.dart 43:5  main.<fn>
  
00:00 +1 -1: remove is limited to names owned by the scope
00:00 +2 -1: close is idempotent and closed scopes reject additions
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +4 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
```

### AC036 closed guard removed

Command: `flutter test --reporter expanded test/webmcp_scope_test.dart`

Exit: 1; wall time: 1.52 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +1: skips duplicates and never removes another owner
00:00 +2: remove is limited to names owned by the scope
00:00 +3: close is idempotent and closed scopes reject additions
00:00 +3 -1: close is idempotent and closed scopes reject additions [E]
  Expected: throws <Instance of 'StateError'>
    Actual: <Closure: () => bool>
     Which: returned <true>
  
  package:matcher                   expect
  test/webmcp_scope_test.dart 65:5  main.<fn>
  
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +4 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
```

### AC037 broad exception catch

Command: `flutter test --reporter expanded test/webmcp_scope_test.dart`

Exit: 1; wall time: 1.52 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +1: skips duplicates and never removes another owner
00:00 +2: remove is limited to names owned by the scope
00:00 +3: close is idempotent and closed scopes reject additions
00:00 +4: invalid names propagate without becoming owned or skipped
00:00 +4 -1: invalid names propagate without becoming owned or skipped [E]
  Expected: throws <Instance of 'WebMcpInvalidToolNameException'>
    Actual: <Closure: () => bool>
     Which: returned <false>
  
  package:matcher                   expect
  test/webmcp_scope_test.dart 78:5  main.<fn>
  
00:00 +4 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
```

### AC038 screen disposal removed

Command: `flutter test --reporter expanded test/widget_layer_test.dart`

Exit: 1; wall time: 1.78 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: empty
  Actual: [Instance of 'WebMcpTool']

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:72:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart line 72
The test description was:
  screen mixin registers while mounted and closes on dispose
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +0 -1: screen mixin registers while mounted and closes on dispose [E]
  Test failed. See exception logs above.
  The test description was: screen mixin registers while mounted and closes on dispose
  
00:00 +0 -1: action registers verbatim and unregisters independently
00:00 +1 -1: action returns the identical tappable child
00:00 +2 -1: action forwards invocation to the latest callback
00:00 +3 -1: action keeps its mounted descriptor identity until replacement
00:00 +4 -1: action copies its input schema
00:00 +5 -1: action without a screen reports the tool and registers nothing
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
```

### AC039 action name prefixed

Command: `flutter test --reporter expanded test/widget_layer_test.dart`

Exit: 1; wall time: 1.8 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: 'literal.name'
  Actual: '_ScreenState.literal.name'
   Which: is different.
          Expected: literal.na ...
            Actual: _ScreenSta ...
                    ^
           Differ at offset 0

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:79:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart line 79
The test description was:
  action registers verbatim and unregisters independently
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +1 -1: action registers verbatim and unregisters independently [E]
  Test failed. See exception logs above.
  The test description was: action registers verb
[... output excerpt; intervening lines omitted ...]
rown, this was the stack:
#0      WebMcp.invokeTool (package:webmcp_pilot/src/webmcp.dart:68:7)
#1      main.<anonymous closure> (file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:205:34)
<asynchronous suspension>
#2      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

The test description was:
  duplicate actions preserve the first owner
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +4 -4: duplicate actions preserve the first owner [E]
  Test failed. See exception logs above.
  The test description was: duplicate actions preserve the first owner
  
00:00 +4 -4: invalid action names fail loudly
00:00 +5 -4: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action forwards invocation to the latest callback
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action registers verbatim and unregisters independently
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: duplicate actions preserve the first owner
```

### AC040 absorbing child

Command: `flutter test --reporter expanded test/widget_layer_test.dart`

Exit: 1; wall time: 1.87 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: same instance as GestureDetector:<GestureDetector(startBehavior: start)>
  Actual: AbsorbPointer:<AbsorbPointer(absorbing: true)>

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:104:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart line 104
The test description was:
  action returns the identical tappable child
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +2 -1: action returns the identical tappable child [E]
  Test failed. See exception logs above.
  The test description was: action returns the identical tappable child
  
00:00 +2 -1: action forwards invocation to the latest callback
00:00 +3 -1: action keeps its mounted descriptor identity until replacement
00:00 +4 -1: action copies its input schema
00:00 +5 -1: action without a screen reports the tool and registers nothing
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action returns the identical tappable child
```

### AC041 stale handler

Command: `flutter test --reporter expanded test/widget_layer_test.dart`

Exit: 1; wall time: 1.72 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
00:00 +3: action forwards invocation to the latest callback
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: 'second'
  Actual: 'first'
   Which: is different.
          Expected: second
            Actual: first
                    ^
           Differ at offset 0

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:122:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart line 122
The test description was:
  action forwards invocation to the latest callback
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +3 -1: action forwards invocation to the latest callback [E]
  Test failed. See exception logs above.
  The test description was: action forwards invocation to the latest callback
  
00:00 +3 -1: action keeps its mounted descriptor identity until replacement
00:00 +4 -1: action copies its input schema
00:00 +5 -1: action without a screen reports the tool and registers nothing
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action forwards invocation to the latest callback
```

### AC042 missing scope fallback

Command: `flutter test --reporter expanded test/widget_layer_test.dart`

Exit: 1; wall time: 1.78 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
00:00 +3: action forwards invocation to the latest callback
00:00 +4: action keeps its mounted descriptor identity until replacement
00:00 +5: action copies its input schema
00:00 +6: action without a screen reports the tool and registers nothing
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: <Instance of 'WebMcpScopeMissingException'>
  Actual: <null>
   Which: is not an instance of 'WebMcpScopeMissingException'

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:179:7)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart line 179
The test description was:
  action without a screen reports the tool and registers nothing
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +6 -1: action without a screen reports the tool and registers nothing [E]
  Test failed. See exception logs above.
  The test description was: action without a screen reports the tool and registers nothing
  
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
```

### AC043 duplicate catch removed

Command: `flutter test --reporter expanded test/widget_layer_test.dart`

Exit: 1; wall time: 1.81 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
00:00 +3: action forwards invocation to the latest callback
00:00 +4: action keeps its mounted descriptor identity until replacement
00:00 +5: action copies its input schema
00:00 +6: action without a screen reports the tool and registers nothing
00:00 +7: duplicate actions preserve the first owner
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following WebMcpDuplicateToolException was thrown building _Screen-[<'second'>](state:
_ScreenState#9f26d):
A tool with this name is already registered. (tool: shared)

The relevant error-causing widget was:
  _Screen-[<'second'>]
  _Screen:file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:195:13

When the exception was thrown, this was the stack:
#0      WebMcp.registerTool (package:webmcp_pilot/src/webmcp.dart:29:7)
#1      WebMcpScope.addTool (package:webmcp_pilot/src/webmcp_scope.dart:25:23)
#2      _WebMcpActionState.didChangeDependencies (package:webmcp_pilot/src/widgets/webmcp_action.dart:62:23)
#3      StatefulElement._firstBuild (package:flutter/src/widgets/framework.dart:5981:11)
#4      ComponentElement.mount (package:flutter/src/widgets/framework.dart:5806:5)
...     Normal element mounting (9 frames)
#13     Element.inflateWidget (package:flutter/src/widgets/framework.dar
[... output excerpt; intervening lines omitted ...]
mous closure> (file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart:207:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart line 207
The test description was:
  duplicate actions preserve the first owner
════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following message was thrown:
Multiple exceptions (3) were detected during the running of the current test, and at least one was
unexpected.
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +7 -1: duplicate actions preserve the first owner [E]
  Test failed. See exception logs above.
  The test description was: duplicate actions preserve the first owner
  
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: duplicate actions preserve the first owner
```

### AC044 flutter outside widget layer

Command: `flutter test --reporter expanded test/repo_hygiene_test.dart`

Exit: 1; wall time: 1.56 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +1 -1: Flutter imports stay inside the widget layer [E]
  Expected: empty
    Actual: ['lib/src/webmcp.dart: import \'package:flutter/widgets.dart\';']
  lib/src/webmcp.dart: import 'package:flutter/widgets.dart';
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 50:5                    main.<fn>
  
00:00 +1 -1: public and scope tests preserve their import boundaries
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
```

### AC045 scope test flutter dependency

Command: `flutter test --reporter expanded test/repo_hygiene_test.dart`

Exit: 1; wall time: 1.5 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +2 -1: public and scope tests preserve their import boundaries [E]
  Expected: not contains 'package:flutter_test/'
    Actual: 'import \'package:flutter_test/flutter_test.dart\';\n'
              'import \'package:test/test.dart\';\n'
              'import \'package:webmcp_pilot/webmcp_pilot.dart\';\n'
              '\n'
              'WebMcpTool _tool(String name, Object? value) => WebMcpTool(\n'
              '  name: name,\n'
              '  description: \'Tool $name\',\n'
              '  handler: (Map<String, Object?> arguments) => value,\n'
              ');\n'
              '\n'
              'final class _Source implements WebMcpToolSource {\n'
              '  _Source(this.tool);\n'
              '\n'
              '  final WebMcpTool tool;\n'
              '\n'
              '  @override\n'
              '  List<WebMcpTool> getWebMcpTools() => <WebMcpTool>[tool];\n'
              '}\n'
              '\n'
              'void main() {\n'
              '  setUp(WebMcp.instance.reset);\n'
              '\n'
              '  test(\'adds direct and source tools, then closes\', () {\n'
              '    final WebMcpScope scope = WebMcpScope(scopeName: \'scope\');\n'
              '    expect(scope.addTool(_tool(\'direct\', 1)), isTrue);\n'
              '    scope.addSource(_Source(_tool(\'source\',
[... output excerpt; intervening lines omitted ...]
 expect(\n'
              '      () => scope.addTool(_tool(\'late\', null)),\n'
              '      throwsA(isA<StateError>()),\n'
              '    );\n'
              '    expect(\n'
              '      () => scope.addSource(_Source(_tool(\'later\', null))),\n'
              '      throwsA(isA<StateError>()),\n'
              '    );\n'
              '    expect(WebMcp.instance.tools, isEmpty);\n'
              '  });\n'
              '\n'
              '  test(\'invalid names propagate without becoming owned or skipped\', () {\n'
              '    final WebMcpScope scope = WebMcpScope(scopeName: \'invalid\');\n'
              '    expect(\n'
              '      () => scope.addTool(_tool(\'invalid name\', null)),\n'
              '      throwsA(isA<WebMcpInvalidToolNameException>()),\n'
              '    );\n'
              '    expect(scope.ownedNames, isEmpty);\n'
              '    expect(scope.skippedNames, isEmpty);\n'
              '    expect(WebMcp.instance.tools, isEmpty);\n'
              '  });\n'
              '}\n'
              ''
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 61:5                    main.<fn>
  
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
```

### AC002 minimal PATH

Command: `bash tools/check.sh`

Exit: 1; wall time: 0.01 seconds. Pasted output:

```text
Preflight failed: missing required binary: flutter
```

### AC002 preflight removed

Command: `PATH=/usr/bin:/bin bash tools/check.sh`

Exit: 1; wall time: 0.14 seconds. Pasted output:

```text
Preflight: flutter and dart found
error: CLAUDE.md: missing. Claude Code does not read AGENTS.md directly.

1 error(s), 0 warning(s).
Stage 1 failed: wiki lint
```

### AC004 unformatted file

Command: `dart format --output=none --set-exit-if-changed lib test example/lib example/test`

Exit: 1; wall time: 0.14 seconds. Pasted output:

```text
Changed lib/src/webmcp.dart
Formatted 23 files (1 changed) in 0.03 seconds.
```

### AC005 warning and info in nested and root source

Command: `dart analyze --fatal-infos --fatal-warnings`

Exit: 2; wall time: 4.56 seconds. Pasted output:

```text
Analyzing webmcp-validator-xeh_qiad...

warning - example/lib/main.dart:6:7 - The value of the local variable 'unusedLocal' isn't used. Try removing the variable or using it. - unused_local_variable
   info - lib/src/webmcp.dart:79:8 - Missing documentation for a public member. Try adding documentation for the member. - public_member_api_docs

2 issues found.
```

### AC006 missing migration exclusion

Command: `flutter pub get && git diff -- analysis_options.yaml`

Exit: 0; wall time: 0.45 seconds. Pasted output:

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
Upgrading analysis_options.yaml to exclude build and platform directories.
diff --git a/analysis_options.yaml b/analysis_options.yaml
index 31657c4..930dd29 100644
--- a/analysis_options.yaml
+++ b/analysis_options.yaml
@@ -4,13 +4,13 @@ analyzer:
   exclude:
     - build/**
     - android/**
-    - ios/**
     - web/**
     - windows/**
     - macos/**
     - linux/**
     - example/build/**
     - .dart_tool/**
+    - ios/**
 
 linter:
   rules:
```

### AC007 build error excluded

Command: `dart analyze --fatal-infos --fatal-warnings`

Exit: 0; wall time: 3.97 seconds. Pasted output:

```text
Analyzing webmcp-validator-xeh_qiad...
No issues found!
```

### AC007 nested exclusion removed

Command: `dart analyze --fatal-infos --fatal-warnings`

Exit: 3; wall time: 3.95 seconds. Pasted output:

```text
Analyzing webmcp-validator-xeh_qiad...

  error - example/build/validation_probe.dart:1:15 - The function 'undeclaredIdentifier' isn't defined. Try importing the library that defines 'undeclaredIdentifier', correcting the name to the name of an existing function, or defining a function named 'undeclaredIdentifier'. - undefined_function

1 issue found.
```

### AC008 publishability removed

Command: `dart analyze --fatal-infos --fatal-warnings`

Exit: 2; wall time: 3.91 seconds. Pasted output:

```text
Analyzing webmcp-validator-xeh_qiad...

warning - example/pubspec.yaml:12:5 - Publishable packages can't have 'path' dependencies. Try adding a 'publish_to: none' entry to mark the package as not for publishing or remove the path dependency. - invalid_dependency

1 issue found.
```

### AC023 missing web entry

Command: `cd example && flutter build web`

Exit: 1; wall time: 0.29 seconds. Pasted output:

```text
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
This project is not configured for the web.
To configure this project for the web, run flutter create . --platforms web
```

### AC046 missing example screen

Command: `dart analyze --fatal-infos --fatal-warnings`

Exit: 3; wall time: 4.14 seconds. Pasted output:

```text
Analyzing webmcp-validator-xeh_qiad...

  error - example/lib/main.dart:3:8 - Target of URI doesn't exist: 'example_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - example/lib/main.dart:16:36 - Invalid constant value. - invalid_constant
  error - example/lib/main.dart:16:36 - The method 'ExampleScreen' isn't defined for the type 'WebMcpPilotExample'. Try correcting the name to the name of an existing method, or defining a method named 'ExampleScreen'. - undefined_method

3 issues found.
```

### AC018 multiline forbidden import bypass

Command: `flutter test --reporter expanded test/repo_hygiene_test.dart`

Exit: 0; wall time: 1.85 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +3: implementation files contain no fixed secret markers
00:00 +4: All tests passed!
```

### AC044 multiline Flutter import bypass

Command: `flutter test --reporter expanded test/repo_hygiene_test.dart`

Exit: 0; wall time: 1.48 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +3: implementation files contain no fixed secret markers
00:00 +4: All tests passed!
```

### AC003 failing assertion halts before build

Command: `bash tools/check.sh`

Exit: 1; wall time: 7.45 seconds. Pasted output:

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
Analyzing webmcp-validator-xeh_qiad...
No issues found!
Stage 4 passed: analysis
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /pri
[... output excerpt; intervening lines omitted ...]
ebmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +19 -1: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +20 -1: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:00 +21 -1: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:00 +22 -1: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:01 +23 -1: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:01 +24 -1: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:01 +25 -1: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:01 +26 -1: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:01 +27 -1: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:01 +28 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: validates empty, long, and unsupported names
Stage 5 failed: tests
```

### AC032 yaml synthetic secret marker

Command: `flutter test --reporter expanded test/repo_hygiene_test.dart`

Exit: 1; wall time: 1.45 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +3: implementation files contain no fixed secret markers
00:00 +3 -1: implementation files contain no fixed secret markers [E]
  Expected: empty
    Actual: ['.github/workflows/checks.yml:   # AKIAABCDEFGHIJKLMNOP']
  .github/workflows/checks.yml:   # AKIAABCDEFGHIJKLMNOP
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 107:5                   main.<fn>
  
00:00 +3 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
```

### AC018 valid multiline import full test stage

Command: `flutter test --reporter expanded && (cd example && flutter test --reporter expanded)`

Exit: 0; wall time: 5.02 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-validator-xeh_qiad/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +1: /private/tmp/webmcp-validator-xeh_qiad/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +2: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +3: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +4: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +5: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +6: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +7: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +8: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +10: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +11: /private/tmp/webmcp-val
[... output excerpt; intervening lines omitted ...]
/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +22: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +23: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +24: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +25: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +26: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +27: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +28: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +29: All tests passed!
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
```

### AC044 valid multiline Flutter import full test stage

Command: `flutter test --reporter expanded && (cd example && flutter test --reporter expanded)`

Exit: 0; wall time: 4.75 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +4: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +5: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +6: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: unregister is idempotent
00:00 +7: /private/tmp/webmcp-validator-xeh_qiad/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +8: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +9: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +10: /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: notifies registration and unregistration in order
00:00 +11: /private/tmp/webmcp-validator-xeh_qiad/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:00 +12: /priv
[... output excerpt; intervening lines omitted ...]
/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +22: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +23: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +24: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +25: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +26: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +27: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +28: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +29: All tests passed!
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
```

### AC002 preflight removal after complete snapshot

Command: `PATH=/usr/bin:/bin bash tools/check.sh`

Exit: 1; wall time: 0.16 seconds. Pasted output:

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
tools/check.sh: line 18: flutter: command not found
Stage 2 failed: dependencies
```

### AC003 failure guard removed

Command: `bash tools/check.sh`

Exit: 0; wall time: 29.45 seconds. Pasted output:

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
Analyzing webmcp-validator-xeh_qiad...
No issues found!
Stage 4 passed: analysis
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /pri
[... output excerpt; intervening lines omitted ...]
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             18.7s
✓ Built build/web
Stage 6 passed: build
```

### installed SDK version

Command: `flutter --version`

Exit: 0; wall time: 0.19 seconds. Pasted output:

```text
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
Engine • hash 59d54a2b2896a6bbf356c94b7fac7b9e235bdacd (revision 5f77625673) (29 days ago) • 2026-08-11 16:38:36.000Z
Tools • Dart 3.13.0 • DevTools 2.60.0
```

### AC001 wiki stage deleted

Command: `bash tools/check.sh`

Exit: 0; wall time: 28.16 seconds. Pasted output:

```text
Preflight: flutter and dart found
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
Formatted 23 files (0 changed) in 0.05 seconds.
Stage 3 passed: format
Analyzing webmcp-validator-xeh_qiad...
No issues found!
Stage 4 passed: analysis
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /private/tmp/webmcp-validator-xeh_qiad/test/registry_test.dart:
[... output excerpt; intervening lines omitted ...]
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             17.6s
✓ Built build/web
Stage 6 passed: build
```

### independent AC012 AC013 AC016 edge checks

Command: `flutter test --reporter expanded test/independent_validation_test.dart`

Exit: 0; wall time: 1.57 seconds. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/test/independent_validation_test.dart
00:00 +0: independent AC012 AC013 AC016 edge checks
00:00 +1: All tests passed!
```

### AC024 independent jobs

Command: `python3 /private/tmp/webmcp-validator-static.py`

Exit: 0. Pasted output:

```text
baseline predicate: True
mutated predicate: False
```

### AC025 identical check command

Command: `python3 /private/tmp/webmcp-validator-static.py`

Exit: 0. Pasted output:

```text
baseline predicate: True
mutated predicate: False
```

### AC026 version count

Command: `python3 /private/tmp/webmcp-validator-static.py`

Exit: 0. Pasted output:

```text
baseline predicate: True
mutated predicate: False
```

### AC027 preserved original README

Command: `python3 /private/tmp/webmcp-validator-static.py`

Exit: 0. Pasted output:

```text
baseline predicate: True
mutated predicate: False
```

### AC028 existence and actual tracking

Command: `git ls-files -- lib example test README.md CHANGELOG.md analysis_options.yaml pubspec.yaml LICENSE; Python filesystem existence checks`

Exit: 0. Pasted output:

```text
lib: exists=True tracked=True
example: exists=True tracked=True
test: exists=True tracked=True
README.md: exists=True tracked=True
CHANGELOG.md: exists=True tracked=True
analysis_options.yaml: exists=True tracked=True
pubspec.yaml: exists=True tracked=True
LICENSE: exists=True tracked=True
negative renamed CHANGELOG.md: exists=False
```

### AC029 web-only platforms

Command: `python3 /private/tmp/webmcp-validator-static.py`

Exit: 0. Pasted output:

```text
baseline predicate: True
mutated predicate: False
```

### AC030 checks heading commands and line budget

Command: `python3 /private/tmp/webmcp-validator-static.py`

Exit: 0. Pasted output:

```text
baseline predicate: True
mutated predicate: False
```

### AC033 ignore rules

Command: `git check-ignore -v build/x example/build/web/x.dart .dart_tool/x example/.dart_tool/x pubspec.lock example/pubspec.lock`

Exit: 0. Pasted output:

```text
.gitignore:30:/build/	build/x
.gitignore:33:/example/build/	example/build/web/x.dart
.gitignore:31:/.dart_tool/	.dart_tool/x
.gitignore:34:/example/.dart_tool/	example/.dart_tool/x
.gitignore:32:/pubspec.lock	pubspec.lock
.gitignore:35:/example/pubspec.lock	example/pubspec.lock
negative exit=1; output=''
```

### AC017 required type identifiers

Command: `Python whole-word search in test/webmcp_public_surface_test.dart`

Exit: 1. Pasted output:

```text
WebMcpScope: True
WebMcpScreen: True
WebMcpAction: True
WebMcpTool: True
WebMcpToolHandler: False
WebMcpToolSource: True
WebMcpTransport: True
WebMcpException: True
WebMcpInvalidToolNameException: True
WebMcpDuplicateToolException: True
WebMcpToolNotFoundException: True
WebMcpScopeMissingException: True
```

### AC001 fixed stage order

Command: `python3 /private/tmp/webmcp-validator-static.py`

Exit: 0. Pasted output:

```text
baseline predicate: True
mutated predicate: False
```

### AC-031 delayed timing mutation

Mutation: a separate copy of tools/check.sh included `sleep 400` immediately after preflight. Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH /usr/bin/time -p bash /private/tmp/webmcp-validator-xeh_qiad/tools/check-slow.sh`. Timing output excerpt:

```text
ons preserve the first owner
00:00 +20: /private/tmp/webmcp-validator-xeh_qiad/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +21: /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +22: /private/tmp/webmcp-validator-xeh_qiad/test/transport_selection_test.dart: notifies registration and unregistration in order
00:00 +23: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +24: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +25: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +26: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +27: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +28: /private/tmp/webmcp-validator-xeh_qiad/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +29: All tests passed!
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-validator-xeh_qiad/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             17.9s
✓ Built build/web
Stage 6 passed: build
real 429.54
user 32.48
sys 5.24
```
