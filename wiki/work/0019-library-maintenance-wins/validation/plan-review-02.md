# Plan review — round 02

- Work item: 0019-library-maintenance-wins
- Reviewed artifact: `wiki/work/0019-library-maintenance-wins/01-plan.md` and `wiki/work/0019-library-maintenance-wins/02-criteria.md` (working tree, HEAD `bf6d4795e0f339043487c4f007f1365573adf762`)
- Reviewer: plan-validator
- Date: 2026-10-11

## Verdict

**FAIL**

One blocker remains. Step 8 and AC-018 require the public README to say that reusing a requestId with any one of the six fingerprint fields changed returns `duplicateRequest`. The act guard contradicts this for `pageId`, `mountToken` and `revision`: it rejects those requests with other codes before the fingerprint is compared.

## Verification performed

Base commit and working tree:

    $ git rev-parse HEAD && git cat-file -t bf6d4795e0f339043487c4f007f1365573adf762 && git status --short
    bf6d4795e0f339043487c4f007f1365573adf762
    commit
    ?? wiki/work/0019-library-maintenance-wins/

Fenced code in the plan and vague wording in either artifact:

    $ rg -c '```' wiki/work/0019-library-maintenance-wins/01-plan.md; echo "fence-exit=$?"
    fence-exit=1
    $ rg -n -i "correctly|properly|as expected" .../02-criteria.md .../01-plan.md; echo "vague-exit=$?"
    vague-exit=1

`.pubignore` uses rooted entries with leading and trailing slashes (`.pubignore:2-5`, for example `/test/` and `/example/test/`). It has no entry for `packages` or `spikes`.

`publish.yml` at base: the `on` block is at lines 11-14. The `publish` job (lines 17-44) has `name: Publish to pub.dev`, `runs-on: ubuntu-latest`, `permissions` `id-token: write` and `contents: read`, `actions/checkout@v4`, and `flutter-actions/setup-flutter@v4` with stable 3.47.0. `release.yml:56-67` uses `actions/setup-python@v5` with Python "3.12", `subosito/flutter-action@v2` with 3.47.0, and `bash tools/check.sh`. Its checkout uses `fetch-depth: 0` (line 54).

Whether `tools/check.sh` needs git history or the network, given that the plan's check job does not decide the checkout depth:

    $ rg -n "git |git\b|fetch|curl|pub.dev|urllib|subprocess" tools/test_bump_patch_version.sh tools/test_occupied_pubdev_versions.sh tools/lint_wiki.py
    tools/test_occupied_pubdev_versions.sh:130:if grep -E 'https?://|[[:space:]]git[[:space:]]|^git[[:space:]]' "$PARSER" >/dev/null; then
    tools/test_bump_patch_version.sh:479:    if grep -E 'https?://|[[:space:]]git[[:space:]]|^git[[:space:]]' "$HELPER_SCRIPT" >/dev/null; then
    $ rg -n "^import|subprocess|git" tools/lint_wiki.py
    19:import argparse
    20:import datetime as dt
    21:import re
    22:import sys

Neither stage 7 nor stage 8 shells out to git or the network. Their only git matches are guard greps that assert the helper does not do so. A default shallow checkout does not break the suite. `tools/check.sh:74` prints `Stage 8 passed: occupied pub.dev versions test`.

Scratch dry run with the two proposed entries appended to `.pubignore`, in a copy at `/tmp/pv02` (the repository was not touched; the copy has since been deleted):

    $ printf '\n# Companion packages and spikes are repository-only\n/packages/\n/spikes/\n' >> .pubignore
    $ flutter pub publish --dry-run > /tmp/pv02_dry.txt 2>&1; echo "exit=$?"
    exit=65
    $ rg -n "^[│├└ ]*[├└]── (packages|spikes)\b" /tmp/pv02_dry.txt; echo "pkg-spikes-entry-exit=$?"
    pkg-spikes-entry-exit=1
    16:├── CHANGELOG.md (2 KB)
    17:├── LICENSE (1 KB)
    18:├── README.md (32 KB)
    19:├── example
    35:│   │   └── main.dart (1 KB)
    39:├── lib
    67:│   └── webmcp_flutter.dart (<1 KB)
    86:Package has 1 warning.

    $ git checkout -- .pubignore && flutter pub publish --dry-run > /tmp/pv02_base.txt 2>&1; echo "exit=$?"
    exit=65
    68:├── packages
    96:└── spikes
    157:  .claude/skills/build/SKILL.md
    162:Package has 1 warning.
    $ ls .claude/skills/build
    ls: .claude/skills/build: No such file or directory
    $ git ls-files .claude/skills/build      (in the real repository)
    .claude/skills/build/SKILL.md

The one warning appears with and without the change. It concerns `.claude/skills/build/SKILL.md`, which my `rsync --exclude build` copy dropped. It is an artifact of the scratch copy, not of the plan, and the exit code 65 comes from that warning. The proposed entries remove both tree entries and keep every parent-and-name pair that AC-002 requires, except `example/README.md`, which the scratch did not create. The AC-001 negative case (both names present at base) holds.

Surface test: `test/webmcp_public_surface_test.dart:2` imports the public library, and none of the ten inventory names appear in it (lines 43-72). `WebMcpViewBinding` is declared at `lib/src/page/webmcp_view_provider.dart:4`. It reaches the public library only through the `show` at `lib/src/page/page.dart:15`, and `lib/webmcp_flutter.dart:1-13` does not export `webmcp_view_provider.dart` directly. So the AC-008 negative case (a compile failure) holds. Constant values are confirmed at `lib/src/page/webmcp_page_protocol.dart:4,7` and `lib/src/webmcp_typed_input.dart:4,7`. The research now scopes the ten names as a non-exhaustive inventory (`00-research.md:9,59,105`), and the plan Goal matches (`01-plan.md:5`).

Page test imports and coverage gaps:

    test/page/webmcp_page_test.dart:9:import 'package:webmcp_flutter/src/page/page.dart';
    ...:12:import 'package:webmcp_flutter/src/webmcp_tool_source.dart';
    $ rg -n "webMcpMaxSafeInteger|requestId: 0|longPress" test/page/webmcp_page_test.dart
    (no output)

The page barrel already exports `webMcpMaxSafeInteger` (`lib/src/page/page.dart:12`). The four boundaries are untested today. The test named "stale revision, handle, and request order refuse dispatch" is at `test/page/webmcp_page_test.dart:103`. It reuses the pre-dispatch read for its exact repeat (lines 131-153). The `_act` helper posts all six fingerprint fields plus `requestId` to `'$pageId.page.act'` (lines 1266-1283).

Act guard order, `lib/src/page/webmcp_page.dart:942-1080`:

    976-982  pageId != widget.pageId || mountToken != _mountToken || !_mountedOwner -> scopeGone
    990-994  revision != _revision || _window?.revision != revision            -> staleSnapshot
    1007-1008 action not in supported set (includes longPress)                 -> unsupportedAction
    1010     requestId < 1 || requestId > webMcpMaxSafeInteger                 -> invalidArguments
    1015-1033 fingerprint of pageId, mountToken, revision, handle, action, arguments;
              requestId <= _highestRequestId -> cached receipt if fingerprint matches, else duplicateRequest
    1077     longPress && !allowLongPress                                       -> policyDenied

This order confirms step 4's sequence and AC-010 to AC-013, including both mutation negative cases. It also shows that a same-requestId retry with a changed `pageId` or `mountToken` returns `scopeGone`, and one with a changed `revision` returns `staleSnapshot` unless the new revision is current. `_normalizeInteger` at lines 703-713 passes a Dart `int` through unchanged, so `webMcpMaxSafeInteger + 1` reaches the fence at line 1010.

Docs and metadata: `pubspec.yaml:3,5` have `version: 0.1.11` and `homepage:`, with no `issue_tracker`, and the same lines are at base. `lib/webmcp_flutter.dart` contains export lines only. `README.md:353-357` describes a matching retry without naming fields.

Criterion coverage (each criterion mapped to the plan step that addresses it):

- AC-001, AC-002, AC-003: step 1 (`01-plan.md:25`) and the verification approach (`01-plan.md:85`).
- AC-004, AC-005, AC-006: step 2 (`01-plan.md:27`), the approach (`01-plan.md:11`), and the shared decisions (`01-plan.md:46-48`).
- AC-007: the approach (`01-plan.md:11`) and Out of scope (`01-plan.md:77`).
- AC-008, AC-009: step 3 (`01-plan.md:29`).
- AC-010 to AC-013: step 4 (`01-plan.md:31`).
- AC-014: step 5 (`01-plan.md:33`).
- AC-015: step 6 (`01-plan.md:35`).
- AC-016: step 7 (`01-plan.md:37`).
- AC-017: steps 6, 7 and 8, and the shared decision at `01-plan.md:54`.
- AC-018: step 8 (`01-plan.md:39`). The step and the criterion require a false statement; see F-001.
- AC-019: step 9 (`01-plan.md:41`).
- AC-020: the shared decision at `01-plan.md:55` and Out of scope (`01-plan.md:78-79`).
- NF-001, NF-002: the shared decision at `01-plan.md:46`.
- NF-003: step 9 (`01-plan.md:41`).

Every criterion is addressed by a step, and every step maps to at least one criterion.

## Per-criterion results

Not applicable to a plan review. Criterion coverage is recorded under Verification performed.

## Findings

### F-001 — The README sentence required by step 8 and AC-018 misstates the act guard

- Severity: BLOCKER
- Location: `wiki/work/0019-library-maintenance-wins/01-plan.md:39` (step 8) and `wiki/work/0019-library-maintenance-wins/02-criteria.md:29` (AC-018). The justification is at `01-plan.md:21` and the source claim at `00-research.md:65`. The contradicting code is `lib/src/page/webmcp_page.dart:976-994`.
- Criterion affected: AC-018, AC-017 (the README lines reviewed for accuracy)
- Observation: Step 8 instructs the implementer to add a sentence to the public README stating that "the same requestId with any of those changed returns duplicateRequest", where "those" are `pageId`, `mountToken`, `revision`, `handle`, `action` and `arguments`. AC-018 requires that a changed field under the same requestId returns `duplicateRequest`. In the act guard, a changed `pageId` or `mountToken` returns `scopeGone` at lines 976-982, and a changed `revision` that is not current returns `staleSnapshot` at lines 990-994. Both checks run before the fingerprint comparison at lines 1015-1033. Only a change to `handle`, to `action` within the supported set, or to `arguments`, or to a `revision` that is still current, reaches the `duplicateRequest` branch. The research claim at `00-research.md:65` is accurate for the fingerprint branch alone. The plan widens it into a statement about the whole act path.
- Why it matters: The plan assumes something about the codebase that is false, and the criterion would freeze it. A literal implementation publishes inaccurate retry semantics in the package README. A verifier checking AC-018 would pass the inaccurate sentence, because the criterion demands it. The new page test pins only the changed-action case (step 4), so no test would catch the mismatch.

### F-002 — The validator-warning risk points to a step 1 completion condition that does not exist

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/01-plan.md:62`, against `wiki/work/0019-library-maintenance-wins/01-plan.md:25`
- Criterion affected: none (no criterion checks for new dry-run warnings after step 1)
- Observation: The mitigation reads "Step 1 completion requires reading the dry-run warnings", but step 1's completion condition (line 25) covers only tree entries and says nothing about warnings. The only step that mentions "no new warning" is step 5 (line 33). In my scratch run, adding the two entries did not change the warning set: one warning both before and after, and it was a scratch artifact.
- Why it matters: The mitigation relies on a check that the step does not tell the implementer to run. If a new warning appeared, nothing in step 1 or in the criteria would surface it. The forced publish at `.github/workflows/publish.yml:44` would proceed regardless.

### F-003 — The check job's runner and checkout action are not decided

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/01-plan.md:11`, `wiki/work/0019-library-maintenance-wins/01-plan.md:27` and `wiki/work/0019-library-maintenance-wins/01-plan.md:46-47`
- Criterion affected: none directly. It bears on the environment risk at `01-plan.md:61`.
- Observation: The shared decisions fix the job identifier, the permissions, the Flutter and Python setup actions and versions, and the command. They do not state the runner image for the new job, which GitHub Actions requires, or which checkout action and version it uses. The existing jobs use `runs-on: ubuntu-latest` and `actions/checkout@v4` (`.github/workflows/publish.yml:19,24` and `.github/workflows/release.yml:34,51`). The plan states neither as the choice for the check job. I verified that the suite does not depend on full git history, so checkout depth is not a correctness issue.
- Why it matters: These are shared configuration choices left to the implementer. The runner image decides the environment in which stage 6 (`flutter build web`) and stage 5 (tests) run. That environment is the thing the risk row at line 61 tries to keep aligned with release.yml.

## Recurrence check

- Previous round: `wiki/work/0019-library-maintenance-wins/validation/plan-review-01.md`
- Recurring findings: none. Round 01's F-001 (export inventory), F-002 (page test import), F-003 (tree-format archive check), F-004 (unpinned base commit), F-005 (setup action wording) and F-006 (formatter scope) are each resolved in the current text, at `01-plan.md:5`, `01-plan.md:31`, `02-criteria.md:12-13`, `01-plan.md:5`, `01-plan.md:61` and `01-plan.md:41` respectively. This round's F-001 concerns step 8 and AC-018. Both were present in round 01's artifact, but round 01 did not report them. F-001 is a new finding, not a repeat.
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan (the step 8 wording and AC-018 are plan-phase artifacts; the research claim at `00-research.md:65` is accurate for the fingerprint branch it describes) |
