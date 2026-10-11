# Plan review — round 01

- Work item: 0019-library-maintenance-wins
- Reviewed artifact: `wiki/work/0019-library-maintenance-wins/01-plan.md` and `wiki/work/0019-library-maintenance-wins/02-criteria.md` (working tree at `bf6d479`)
- Reviewer: plan-validator
- Date: 2026-10-11

## Verdict

**FAIL**

Three blockers stop the plan from passing. The plan's stated test-surface outcome rests on an export inventory that the code contradicts. Step 4 would trip the analyzer if followed literally. AC-002's check method cannot match the real dry-run output, and its negative case passes no matter what.

## Verification performed

Fenced code and vague wording:

    $ rg -c '```' wiki/work/0019-library-maintenance-wins/01-plan.md; echo "fence-exit=$?"
    fence-exit=1
    $ rg -n -i "correctly|properly|as expected" wiki/work/0019-library-maintenance-wins/02-criteria.md; echo "vague-exit=$?"
    vague-exit=1

Public library exports. Every export has no `show` or `hide`, so each file's whole public namespace is exported:

    $ rg -n "^export" lib/webmcp_flutter.dart | rg -v " show | hide "
    1:export 'src/page/page.dart';
    2:export 'src/transport/native_publisher_boundary.dart';
    3:export 'src/transport/webmcp_native_capabilities.dart';
    4:export 'src/transport/webmcp_native_publisher.dart';
    5:export 'src/transport/webmcp_transport.dart';
    6:export 'src/webmcp.dart';
    ... (lines 7-13 likewise unfiltered)

Exported names that the surface test does not reference and that the plan does not add:

    $ for n in WebMcpNativeReasonCode ... WebMcpToolCallHandler; do printf "%s refs_in_surface_test=%s\n" $n $(rg -cw $n test/webmcp_public_surface_test.dart || echo 0); done
    WebMcpNativeReasonCode refs_in_surface_test=0
    WebMcpNativeInvocationContext refs_in_surface_test=0
    WebMcpNativeToolActivityKind refs_in_surface_test=0
    webMcpNativeRegistrationObject refs_in_surface_test=0
    WebMcpNativeInvocationHandler refs_in_surface_test=0
    WebMcpNativeRegistration refs_in_surface_test=0
    WebMcpNativeBoundary refs_in_surface_test=0
    WebMcpNativeBoundaryException refs_in_surface_test=0
    createWebMcpNativeBoundary refs_in_surface_test=0
    webMcpNativeBoundaryFactory refs_in_surface_test=0
    webMcpNativeMaxJsonDepth refs_in_surface_test=0
    webMcpNativeMaxJsonBytes refs_in_surface_test=0
    webMcpNativeMaxRegistrations refs_in_surface_test=0
    webMcpNativeMaxOperations refs_in_surface_test=0
    webMcpNativeMaxOutstandingExecutions refs_in_surface_test=0
    webMcpNativeOperationRetention refs_in_surface_test=0
    webMcpNativeClock refs_in_surface_test=0
    WebMcpToolActivitySubscription refs_in_surface_test=0
    WebMcpRegistryResetObserver refs_in_surface_test=0
    WebMcpLogKind refs_in_surface_test=0
    webMcpRecordLog refs_in_surface_test=0
    WebMcpToolCallHandler refs_in_surface_test=0

The declarations are at `lib/src/transport/native_publisher_boundary.dart:5,35,50,71,89,95,101,124,133,137`, `lib/src/transport/webmcp_native_publisher.dart:12,15,18,21,24,27,30,515`, `lib/src/webmcp.dart:44,50,98` and `lib/src/webmcp_tool.dart:12`.

The ten names the plan does add exist and are exported, and the constant values match the plan:

    lib/src/page/page.dart:5    show WebMcpAppSession, WebMcpEvidenceKind, WebMcpNavigatorAdapter;
    lib/src/page/page.dart:9-13 WebMcpPageErrorCode, ..., webMcpMaxSafeInteger, webMcpPageProtocolVersion;
    lib/src/page/page.dart:15   show WebMcpBindingViewProvider, WebMcpViewBinding, WebMcpViewProvider;
    lib/src/webmcp_typed_input.dart:4:const int webMcpSafeIntegerMinimum = -9007199254740991;
    lib/src/webmcp_typed_input.dart:7:const int webMcpSafeIntegerMaximum = 9007199254740991;
    lib/src/webmcp_typed_input.dart:10:enum WebMcpInputShape {
    lib/src/page/webmcp_page_protocol.dart:4:const int webMcpPageProtocolVersion = 1;
    lib/src/page/webmcp_page_protocol.dart:7:const int webMcpMaxSafeInteger = 9007199254740991;
    lib/src/page/webmcp_page_protocol.dart:12:  invalidArguments,
    lib/src/page/webmcp_page_protocol.dart:45:  duplicateRequest,

Act guard order, read at `lib/src/page/webmcp_page.dart:942-1080`. Integer normalization happens at line 703. The supported set at 996-1008 includes `longPress`. The fence `requestId < 1 || requestId > webMcpMaxSafeInteger` is at line 1010. The fingerprint and duplicate check are at 1013-1033. `actionUnavailable` is at 1045. The `allowLongPress` policy check is at 1077. `_highestRequestId` starts at 0 (line 79). This confirms the plan's guard-order claim. It also confirms that the AC-010 and AC-011 negative cases would fail as stated: without the lower bound, requestId 0 returns `duplicateRequest`; without the upper bound, the request dispatches. The existing exact-repeat test reuses the pre-dispatch read (`test/page/webmcp_page_test.dart:132-157`). The private `_act` helper takes `required int requestId` (`test/page/webmcp_page_test.dart:1266-1283`).

The page test currently imports source libraries, not the public library:

    test/page/webmcp_page_test.dart:9:import 'package:webmcp_flutter/src/page/page.dart';
    test/page/webmcp_page_test.dart:10:import 'package:webmcp_flutter/src/webmcp.dart';
    test/page/webmcp_page_test.dart:11:import 'package:webmcp_flutter/src/webmcp_tool.dart';
    test/page/webmcp_page_test.dart:12:import 'package:webmcp_flutter/src/webmcp_tool_source.dart';

Scratch analysis in a temporary copy of the package (the repository was not touched). I combined the file's existing import block with an added public-library import:

    $ (cd $S && dart analyze --fatal-infos --fatal-warnings test/page/scratch_test.dart; echo "exit=$?")
       info - scratch_test.dart:9:8 - The import of 'package:webmcp_flutter/src/page/page.dart' is unnecessary because all of the used elements are also provided by the import of 'package:webmcp_flutter/webmcp_flutter.dart'. Try removing the import directive. - unnecessary_import
       info - scratch_test.dart:10:8 - The import of 'package:webmcp_flutter/src/webmcp.dart' is unnecessary ... - unnecessary_import
       info - scratch_test.dart:11:8 - The import of 'package:webmcp_flutter/src/webmcp_tool.dart' is unnecessary ... - unnecessary_import
       info - scratch_test.dart:12:8 - The import of 'package:webmcp_flutter/src/webmcp_tool_source.dart' is unnecessary ... - unnecessary_import
    exit=1

The scratch run also reported `avoid_print` infos on the scratch body and a `rendering.dart` unnecessary-import info that came only from the scratch body's narrow usage. Neither is relevant to the finding.

AC-015 negative case confirmed in a scratch copy. A doc comment placed above the first export, with no `library` directive:

    info - webmcp_flutter.dart:1:1 - Dangling library doc comment. Add a 'library' directive after the library comment. - dangling_library_doc_comments
    exit=1

The pattern the plan cites exists:

    lib/src/page/page.dart:1:/// Automatic single-view page observation and guarded action APIs.
    lib/src/page/page.dart:2:library;

Publish dry run on the base working tree:

    $ flutter pub publish --dry-run > /tmp/dryrun_base.txt 2>&1; echo "exit=$?"
    exit=0
    2:Downloading packages...
    13:9 packages have newer versions incompatible with dependency constraints.
    16:├── CHANGELOG.md (2 KB)
    17:├── LICENSE (1 KB)
    18:├── README.md (32 KB)
    19:├── example
    ...
    │   │   └── main.dart (1 KB)
    ├── lib
    ...
    │   └── webmcp_flutter.dart (<1 KB)
    68:├── packages
    96:└── spikes
    150:Package has 0 warnings.
    $ rg -c "lib/webmcp_flutter.dart|example/lib/main.dart" /tmp/dryrun_base.txt; echo "count-exit=$?"
    count-exit=1

The listing is a tree. Full relative paths such as `lib/webmcp_flutter.dart` never appear as strings, even though both files are in the archive. The word `packages` also appears in pub's own non-listing lines 2 and 13.

Workflow toolchain claims:

    .github/workflows/publish.yml:28:      - uses: flutter-actions/setup-flutter@v4   (channel stable, version 3.47.0)
    .github/workflows/release.yml:56:      - uses: actions/setup-python@v5            (python-version "3.12")
    .github/workflows/release.yml:61:        uses: subosito/flutter-action@v2         (flutter-version 3.47.0)
    .github/workflows/release.yml:67:        run: bash tools/check.sh
    tools/check.sh:20:python3 tools/lint_wiki.py || stage_failed 1 "wiki lint"
    tools/check.sh:74:echo "Stage 8 passed: occupied pub.dev versions test"

Other facts checked: `pubspec.yaml:5` is `homepage:` and there is no `issue_tracker`. `git show HEAD:example/README.md` returns `fatal: path 'example/README.md' does not exist in 'HEAD'`. The example pubspec declares relative path dependencies on `../packages/webmcp_flutter_annotations` and `../packages/webmcp_flutter_generator`. `README.md:353-355` mentions a matching retry without naming the six fields. `STATE.yaml` records no base commit.

Criterion coverage (plan review: each criterion mapped to the step that addresses it):

- AC-001, AC-002, AC-003: step 1 (`01-plan.md:25`). AC-002's check method is defective; see F-003.
- AC-004, AC-005, AC-006: step 2 (`01-plan.md:27`) and the shared decisions (`01-plan.md:46-48`).
- AC-007: Approach (`01-plan.md:11`), which leaves release.yml unedited, and Out of scope (`01-plan.md:77`).
- AC-008, AC-009: step 3 (`01-plan.md:29`).
- AC-010 to AC-013: step 4 (`01-plan.md:31`). The import instruction is defective; see F-002.
- AC-014: step 5 (`01-plan.md:33`).
- AC-015: step 6 (`01-plan.md:35`).
- AC-016: step 7 (`01-plan.md:37`).
- AC-017: steps 6, 7 and 8, plus the shared decision at `01-plan.md:54`.
- AC-018: step 8 (`01-plan.md:39`).
- AC-019: step 9 (`01-plan.md:41`).
- AC-020: shared decision at `01-plan.md:55` and Out of scope (`01-plan.md:78-79`).
- NF-001, NF-002: shared decision at `01-plan.md:46`.
- NF-003: step 9 (`01-plan.md:41`), whose scope is narrower; see F-006.

No criterion is left unaddressed. Every step maps to at least one criterion.

## Per-criterion results

Not applicable to a plan review. Criterion coverage is recorded under Verification performed.

## Findings

### F-001 — The plan's test-surface outcome rests on an incomplete export inventory

- Severity: BLOCKER
- Location: `wiki/work/0019-library-maintenance-wins/01-plan.md:5` and `wiki/work/0019-library-maintenance-wins/01-plan.md:13`. Source of the count: `wiki/work/0019-library-maintenance-wins/00-research.md:9` and `wiki/work/0019-library-maintenance-wins/00-research.md:57-60`.
- Criterion affected: AC-008, AC-009
- Observation: The Goal says that after the change the surface test "names every symbol the public library exports, and pins the value of each exported integer constant". The Approach calls the ten added names "the ten missing symbols". The public library (`lib/webmcp_flutter.dart:1-13`) exports whole files with no `show` filter. At least 22 further exported names remain unreferenced after step 3, listed under Verification performed. Five of them are exported integer constants that the plan never pins: `webMcpNativeMaxJsonDepth`, `webMcpNativeMaxJsonBytes`, `webMcpNativeMaxRegistrations`, `webMcpNativeMaxOperations` and `webMcpNativeMaxOutstandingExecutions` (`lib/src/transport/webmcp_native_publisher.dart:12-24`). The research enumerates ten symbols without establishing that the list is exhaustive.
- Why it matters: This is a false assumption about the codebase. The steps cannot deliver the Goal as written, and the criteria (AC-008 and AC-009 list only the ten) cannot detect the gap. Verify would either pass a Goal that is untrue or fail with no criterion to point to.

### F-002 — Step 4's import instruction trips the fatal-infos analyzer gate as written

- Severity: BLOCKER
- Location: `wiki/work/0019-library-maintenance-wins/01-plan.md:31` ("The test imports webMcpMaxSafeInteger from the public library, not from a source file"), against `test/page/webmcp_page_test.dart:9-12`
- Criterion affected: AC-015 (analyzer run), AC-019
- Observation: The page test already gets `webMcpMaxSafeInteger` through `package:webmcp_flutter/src/page/page.dart`. The plan does not say whether the public import is added next to the four existing source imports or replaces them. A scratch analysis showed that adding the public import beside them makes all four source imports `unnecessary_import` infos, so `dart analyze --fatal-infos --fatal-warnings` exits 1. The plan does not decide how the existing imports are handled and does not list this as a risk.
- Why it matters: An implementer following step 4 literally breaks the analysis stage of `tools/check.sh`, which fails AC-015's analyzer check and AC-019. The risk is visible from the code but is not mentioned in the plan.

### F-003 — AC-002's check method cannot match the dry-run output, and its negative case passes vacuously

- Severity: BLOCKER
- Location: `wiki/work/0019-library-maintenance-wins/02-criteria.md:13` (AC-002), also `wiki/work/0019-library-maintenance-wins/02-criteria.md:12` (AC-001). Echoed at `wiki/work/0019-library-maintenance-wins/01-plan.md:25` and `wiki/work/0019-library-maintenance-wins/01-plan.md:85`.
- Criterion affected: AC-001, AC-002
- Observation: `flutter pub publish --dry-run` prints the archive as a tree, with indented segments such as `├── lib` and `│   └── webmcp_flutter.dart`. AC-002 says to "search the dry-run listing for each of the six paths" (for example `lib/webmcp_flutter.dart` and `example/lib/main.dart`). On the base tree that search finds zero matches even though both files are in the archive (`count-exit=1` above), so a correct implementation fails the check as written. AC-002's negative case is a search for `test/webmcp_public_surface_test.dart` being absent. That passes for any tree output, including one that did ship `test/`, so it detects nothing. For AC-001, a plain search for `packages` also matches pub's non-listing lines 2 and 13 ("Downloading packages...", "9 packages have newer versions..."). "As listed path segments" is the only guard, and the criterion leaves it undefined.
- Why it matters: An uncheckable criterion with a vacuous negative case passes or fails independently of what was built. The criteria need a check method that can be applied to the actual output format before they freeze.

### F-004 — "Work-item base commit" is never pinned

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/02-criteria.md:14,17,18,25,31` (AC-003, AC-006, AC-007, AC-014, AC-020) and `wiki/work/0019-library-maintenance-wins/01-plan.md:27,85,87`. `wiki/work/0019-library-maintenance-wins/STATE.yaml` has no base field.
- Criterion affected: AC-001, AC-003, AC-006, AC-007, AC-014, AC-020
- Observation: Six criteria compare against "the work-item base commit", but neither artifact names a revision or says where to record one. `release.yml` pushes version-bump commits to `main` on every merge (`.github/workflows/release.yml:19-22,133-141`), so `main` can move during the work item. AC-014's version-equality check depends on which commit counts as base.
- Why it matters: This is an undecided shared choice. The implementer and the verifier can pick different revisions and get different diff results.

### F-005 — The check-job risk mitigation calls the toolchain "the same" when the setup action differs

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/01-plan.md:61`, against `.github/workflows/release.yml:61` and `wiki/work/0019-library-maintenance-wins/01-plan.md:47`
- Criterion affected: none
- Observation: The mitigation says the check job "uses the same Flutter and Python versions as the release job". The versions match (3.47.0 and 3.12), but the check job uses `flutter-actions/setup-flutter@v4` while release.yml uses `subosito/flutter-action@v2`. The mitigation does not acknowledge that difference.
- Why it matters: Minor. The stated trigger still detects the risk.

### F-006 — Step 9 formatter scope is narrower than NF-003

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/01-plan.md:41`, against `wiki/work/0019-library-maintenance-wins/02-criteria.md:39`
- Criterion affected: NF-003
- Observation: Step 9 runs the formatter "on lib and test". NF-003's command also covers `example/lib` and `example/test`.
- Why it matters: Minor. The plan edits no Dart file under `example/`, and `tools/check.sh` stage 3 covers the full set.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research (the inventory of unreferenced exports is incomplete; the plan's Goal inherits it) |
| F-002 | plan |
| F-003 | plan (criteria are authored in the plan phase) |
| F-004 | plan |
