# Plan review — round 03

- Work item: 0002-flutter-webmcp-stack
- Reviewed artifact: `wiki/work/0002-flutter-webmcp-stack/01-plan.md` and `wiki/work/0002-flutter-webmcp-stack/02-criteria.md`, at git revision `663cf48` (working tree clean at review start)
- Reviewer: plan validator (blind — reviewed the two artifacts and the repository only; no author transcript or self-assessment consulted)
- Date: 2026-09-04

## Verdict

**FAIL**

Three blockers: the plan leaves the analysis binary undecided while one of the two candidates (`flutter analyze`, the one step 3 names) demonstrably rewrites the committed `analysis_options.yaml` that step 3 writes; AC-017's check method is self-contradictory and its distinctive claim has no case that fails when it is false; and AC-004 is satisfied by no step. This is round 3 of a cap of 3, and the recurrence check below shows the loop is oscillating — the plan should be rewritten rather than patched a third time.

## Verification performed

All commands run by me from the repository root unless stated.

### Wiki linter (plan-is-prose check, AC-021)

```
$ python3 tools/lint_wiki.py; echo "EXIT=$?"
lint_wiki: clean (0 warning(s)).
EXIT=0
```

### Fenced code blocks in `01-plan.md`

```
$ grep -c '```' wiki/work/0002-flutter-webmcp-stack/01-plan.md
0
$ grep -nE '^    [^ |-]' wiki/work/0002-flutter-webmcp-stack/01-plan.md
(no output)
```

Zero fenced blocks, zero indented code blocks. `tools/lint_wiki.py:352-360` (`check_plan_is_prose`) confirms this is the rule the linter enforces. **No finding.**

### Vague-term scan of `02-criteria.md`

```
$ grep -niE 'correctly|properly|as expected|appropriate|reasonable|gracefully|robust|sensible|adequate' wiki/work/0002-flutter-webmcp-stack/02-criteria.md
(no matches; the only hits for a broader pattern were "clean checkout" on AC-001/AC-016/AC-019 and "(clean, or ...)" on AC-026, which are precise, not vague)
```

`tools/lint_wiki.py:45` defines `VAGUE = re.compile(r"\b(correctly|properly|as expected|appropriately)\b", re.I)` and `:363-374` applies it per AC line. **No finding.**

### AC-021's claim about the linter's own checks — verified TRUE

AC-021 (`02-criteria.md:36`) asserts the linter fails on a fenced block in `01-plan.md`, a duplicated work-item number, and a vague term in a criterion. All three exist:
- fenced block: `tools/lint_wiki.py:352-360`
- duplicate work-item number: `tools/lint_wiki.py:324-326`
- vague term: `tools/lint_wiki.py:370-374`

**No finding.**

### `README.md` actual state vs. step 2's description — verified TRUE

```
$ git ls-files README.md && wc -l README.md && grep -n "^#" README.md
README.md
      73 README.md
1:# Agent workflow scaffold
5:## Start here
22:## The pipeline
32:## Setup
46:## Layout
63:## Why it is shaped this way
```

Step 2 (`01-plan.md:47`) describes it as "73 lines, opening with the level-1 heading `# Agent workflow scaffold` followed by five level-2 sections". Exactly correct. Inserting one new `#` section above line 1 without touching lines 1-73 is structurally executable and leaves every existing heading at its current level.

The ADR-referenced sentence AC-025 protects exists:

```
$ grep -n "include third-party" README.md
36:**Cursor** reads `AGENTS.md` natively. To also pick up the skills and subagents in `.claude/`, enable **Cursor Settings → Rules, Skills, Subagents → include third-party plugins, skills and other configs**. ...
$ grep -n -i "README\|Cursor Settings" wiki/adr/0002-share-agent-config-between-claude-code-and-cursor.md
69:- Setup instructions in `README.md` name the Cursor setting that must be enabled, so a missing capability is diagnosable rather than mysterious.
80:- `README.md` — setup, including the Cursor setting.
```

`tools/lint_wiki.py` contains no reference to `README.md` (`grep -n "README" tools/lint_wiki.py` → no output), so two sequential H1s create no lint failure. **No finding.**

### CI workflow current job count — verified TRUE

`.github/workflows/checks.yml` defines exactly one job, `wiki` (`.github/workflows/checks.yml:9`), with a placeholder comment at `:25-27` inviting the product job. Step 12's "Add a second job" is accurate. **No finding.**

### Installed toolchain

```
$ flutter --version
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (3 weeks ago) • 2026-08-11 11:53:49 -0700
Tools • Dart 3.13.0 • DevTools 2.60.0
$ dart --version
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"
$ which flutter dart fvm
flutter: aliased to fvm flutter
dart: aliased to fvm dart
/opt/homebrew/bin/fvm
```

Dart 3.13.0 comfortably satisfies the plan's 3.4 SDK floor; the risk row at `01-plan.md:107` is adequately mitigated. `fvm` is already installed, so step 2's `.fvmrc` approach is workable on this machine.

### Single root-level analyze reaching a nested `example/` package — built a scratch reproduction

I did not take the plan's claim on faith. I built a two-package tree at `/private/tmp/.../scratchpad/anz`: a root package with `analysis_options.yaml` enabling `public_member_api_docs`, and `example/` as a nested package with its own `pubspec.yaml` (path dependency on the root) and its own `analysis_options.yaml` doing `include: ../analysis_options.yaml` plus `public_member_api_docs: false`. Root `lib/root_file.dart` has two undocumented public members; `example/lib/main.dart` has an undocumented public member **and** an unused import (the latter is an error under *both* rule sets, so it is the probe for whether `example/` was reached at all). Both packages were `pub get`-resolved first.

```
$ dart analyze --fatal-infos .
Analyzing ....

warning - example/lib/main.dart:1:8 - Unused import: 'dart:convert'. Try removing the import directive. - unused_import
   info - lib/root_file.dart:7:7 - Missing documentation for a public member. Try adding documentation for the member. - public_member_api_docs
   info - lib/root_file.dart:8:7 - Missing documentation for a public member. Try adding documentation for the member. - public_member_api_docs

3 issues found.
EXIT=2
```

```
$ flutter analyze --fatal-infos
Upgrading analysis_options.yaml to exclude build and platform directories.
Analyzing anz...

warning • Unused import: 'dart:convert'. Try removing the import directive • example/lib/main.dart:1:8 • unused_import
   info • Missing documentation for a public member. Try adding documentation for the member • lib/root_file.dart:7:7 • public_member_api_docs
   info • Missing documentation for a public member. Try adding documentation for the member • lib/root_file.dart:8:7 • public_member_api_docs

3 issues found. (ran in 0.3s)
EXIT=1
```

**The plan's central claim is TRUE and I confirm it.** One invocation from the root reaches `example/` as a separate nested context; the root's strict `public_member_api_docs` fires on root files and does *not* fire on `example/lib`, proving `example/`'s own relaxed rule set is the one applied there. No second invocation is needed. Step 11's stated mechanism (`01-plan.md:65`, `:95`) is correct. **No finding on the mechanism itself** — see F-001 and F-005 for the two side effects the plan does not account for.

### `flutter analyze` mutates the committed options file — reproduced twice

Restored the options file to the exact shape step 3 specifies (`analyzer: language:` with strict casts/inference/raw types, plus the linter rule) and re-ran:

```
$ md5 -q analysis_options.yaml
8212bb3c2ee2603b5aafab072387ccca
$ flutter analyze --fatal-infos
Upgrading analysis_options.yaml to exclude build and platform directories.
...
$ cat analysis_options.yaml
analyzer:
  exclude:
    - build/**
    - android/**
    - ios/**
    - web/**
    - windows/**
    - macos/**
    - linux/**
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
linter:
  rules:
    - public_member_api_docs
```

`dart analyze` does not do this:

```
$ B=$(md5 -q analysis_options.yaml); dart analyze --fatal-infos . >/dev/null 2>&1; A=$(md5 -q analysis_options.yaml)
$ [ "$B" = "$A" ] && echo "RESULT: dart analyze did NOT mutate analysis_options.yaml"
RESULT: dart analyze did NOT mutate analysis_options.yaml
```

See F-001.

### Analyzer walks `example/build/`, but not `.dart_tool/`

Placed a Dart file with an unused import at `example/build/web/generated_thing.dart` and another at `example/.dart_tool/flutter_build/generated_entry.dart`:

```
$ dart analyze --fatal-infos .
warning - example/build/web/generated_thing.dart:1:8 - Unused import: 'dart:convert'. ... - unused_import
   info - lib/root_file.dart:7:7 - ... - public_member_api_docs
   info - lib/root_file.dart:8:7 - ... - public_member_api_docs

3 issues found.
```

`.dart_tool/` is excluded by default; `example/build/` is **not**. See F-005.

### `example/` without `publish_to: none` fails the root analyze stage

```
$ dart analyze --fatal-infos .
warning - example/pubspec.yaml:8:5 - Publishable packages can't have 'path' dependencies. Try adding a 'publish_to: none' entry to mark the package as not for publishing or remove the path dependency. - invalid_dependency
...
EXIT=2
```

Adding `publish_to: none` to `example/pubspec.yaml` clears it. See F-004.

### Conditional export keyed on `dart.library.js_interop` — verified TRUE

Built `lib/resolver.dart` doing `export 'noop_variant.dart' if (dart.library.js_interop) 'web_variant.dart';`, where `web_variant.dart` imports `dart:js_interop`, and ran it on the VM:

```
$ dart run bin/probe.dart
resolved on this target: noop
EXIT=0
```

The interop file is not loaded on the VM. The mechanism the plan commits to at `01-plan.md:25` and `:53` works as described, and the risk row at `01-plan.md:103` is correctly framed. **No finding.**

### Top-level `platforms: web:` on a non-plugin package

Declared `platforms:\n  web:` in the scratch root manifest; `dart pub get` resolved and `dart analyze` raised no pubspec diagnostic against it. Step 2's web-only platform declaration is valid. **No finding.**

### `03-tasks.md` / parallelism

```
$ ls wiki/work/0002-flutter-webmcp-stack/
00-research.md  01-plan.md  02-criteria.md  STATE.yaml  research/  validation/
```

No `03-tasks.md` exists, so there are no parallel markers to cross-check. Nothing to report; noting it so the absence is not read as a silent pass.

### Plan structure against the template

`wiki/templates/01-plan.md` prescribes Goal, Approach, Why this approach, Steps, Interfaces and shared decisions, Risks, Rollback, Out of scope, Verification approach. `01-plan.md` carries all nine in that exact order (`:15`, `:19`, `:29`, `:43`, `:71`, `:97`, `:111`, `:115`, `:126`), preceded by an extra "Scope note and unresolved-item check" section at `:3`. Every step names what it touches and a completion condition. **No finding.**

## Criterion coverage map

The template's per-criterion table is scoped to implementation reviews; for a plan review the equivalent question is whether each criterion has an implementing step and each step serves a criterion. Both directions are tabulated.

| Criterion | Implementing step(s) | Covered |
|---|---|---|
| AC-001 | Step 2 (`:47`), step 10 (`:63`), step 11 stage 1 (`:65`) | yes |
| AC-002 | Steps 2, 3, 4, 9, 10 | yes |
| AC-003 | Step 2 (`:47`) | yes |
| AC-004 | none — see F-006 | **no** |
| AC-005 | Step 9 (`:61`) | yes |
| AC-006 | Step 4 (`:51`), step 9 (`:61`) | yes |
| AC-007 | Step 9 (`:61`) | yes |
| AC-008 | Step 9 (`:61`) | yes |
| AC-009 | Step 9 (`:61`) | yes |
| AC-010 | Step 9 (`:61`), facade decision (`:77`) | yes |
| AC-011 | Step 5 (`:53`), step 9 (`:61`) | yes |
| AC-012 | Step 9 (`:61`), step 7 (`:57`) | yes |
| AC-013 | Step 8 (`:59`), step 9 (`:61`) | yes |
| AC-014 | Step 10 (`:63`) | yes |
| AC-015 | Step 10 (`:63`) | yes |
| AC-016 | Step 11 (`:65`) | yes |
| AC-017 | Step 3 (`:49`), step 11 (`:65`) | step exists, criterion unusable — F-002 |
| AC-018 | Step 13 (`:69`) | yes |
| AC-019 | Step 11 (`:65`) | yes |
| AC-020 | Step 12 (`:67`) | yes |
| AC-021 | Step 11 (`:65`) | yes |
| AC-022 | Verification approach (`:142`) — no build step needed | yes |
| AC-023 | Step 9 (`:61`) | yes |
| AC-024 | Step 5 (`:53`), step 9 (`:61`) | yes |
| AC-025 | Step 2 (`:47`) | yes |
| AC-026 | Step 13 (`:69`) | yes |

Reverse direction: every step serves at least one criterion. Step 1 (`:45`) serves AC-003 via the name decision that `02-criteria.md:5` defers to; step 7 (`:57`) serves AC-012 and AC-014; the `.fvmrc` half of step 2 serves AC-020's "pinned Flutter release" clause. No scope creep found.

## Findings

### F-001 — The analysis binary is undecided, and the one step 3 names rewrites the committed `analysis_options.yaml` the same step writes

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:49` (step 3 names `flutter analyze`), against `:65` (step 11) and `:95` ("Check command contents"), which say only "static analysis" / "a single static-analysis invocation"; risk table at `:99-109`
- Criterion affected: AC-017, AC-019, AC-022
- Observation: Step 3 writes `analysis_options.yaml` with an `analyzer: language:` block and names `flutter analyze` as its completion check. Step 11 and the shared-decision list at `:95` specify the check script's analysis stage only as "a single static-analysis invocation from the repository root with infos fatal" and never name the executable. The two candidates are not interchangeable. Running `flutter analyze` against the exact options shape step 3 specifies prints `Upgrading analysis_options.yaml to exclude build and platform directories.` and rewrites the file in place, prepending an `analyzer: exclude:` block containing `build/**`, `android/**`, `ios/**`, `web/**`, `windows/**`, `macos/**`, `linux/**`. I reproduced this twice, with and without an `analyzer:` key already present; the pasted before/after and the md5 comparison showing `dart analyze` leaves the file byte-identical are in the Verification section above.
- Why it matters: The plan's own "Check command contents" (`:95`) presents the analysis stage as a read-only verification step, and the rollback section (`:113`) enumerates exactly three edited files — `README.md`, `.github/workflows/checks.yml`, `.gitignore`. If the implementer picks `flutter analyze`, `tools/check.sh` becomes a writer of a fourth committed source file: every local run and every CI run mutates `analysis_options.yaml`, dirtying a clean checkout, and the injected `exclude` silently redefines the analysis surface (including `web/**`, which then propagates into `example/`'s context through the `include: ../analysis_options.yaml` that step 10 at `:63` specifies) with a rule set step 3 never decided. If the implementer picks `dart analyze`, the file is untouched but `example/build/` is no longer excluded (F-005). The plan decides neither, the risk table has no row for the mutation, and the two choices produce materially different check-script behaviour and different AC-017 outcomes. Per the plan's own standard at `:71` ("the decisions every step must build against ... error handling, configuration. Decide them here"), this is exactly the class of choice that must not be left to the implementer.

### F-002 — AC-017's check method is self-contradictory, and its distinctive claim has no case that fails when it is false

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/02-criteria.md:32`
- Criterion affected: AC-017
- Observation: The criterion requires the invocation to "exit with status 0 and report no issue in `lib/`, `test/` or `example/`". The "How it is checked" column in the same row requires "read the exit code and the issue count, **confirming issues from both the root package and `example/` are reported by that one invocation**". These cannot both hold: a run that reports no issue has no issues from `example/` to confirm. The negative case injects an undocumented public member and an unused import into "one file in `lib/`" only. My reproduction establishes that the *only* observable signal that the root invocation reached `example/` is a diagnostic whose path lies under `example/` — with a clean `example/`, the output of a run that reaches it and a run that does not are byte-identical.
- Why it matters: AC-017 was written to lock down the plan's load-bearing single-invocation claim (`01-plan.md:65`, `:95`). As written it does not. An implementation whose analysis stage silently never reaches `example/` — because the analyzer was invoked with an explicit `lib/ test/` path list, or because an `exclude` entry swallowed it (see F-001, where `flutter analyze` injects exclusions on its own) — passes every check the criterion states and passes its negative case, because that negative case only exercises `lib/`. This is an uncheckable criterion that silently passes everything, which is the failure mode the criteria rubric exists to prevent.

### F-003 — AC-004 is satisfied by no step

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/02-criteria.md:19` (AC-004), against `wiki/work/0002-flutter-webmcp-stack/01-plan.md:61` (step 9's test list) and `:55` (step 6's completion condition)
- Criterion affected: AC-004
- Observation: AC-004 requires a concrete artifact: "A test file under `test/` that imports only the public library and exercises all seven operations" — construct a tool, register, list, invoke, unregister, install a transport, construct a static route source — "with no import from any `src/` path", with `flutter analyze` and `flutter test` both exiting 0, and with a negative case that deletes an export line and expects an undefined-name compile error. Step 9 enumerates the tests to write ("registration and ordering, duplicate and invalid names, unregister idempotence, unknown-tool invocation, transport call routing through a fake transport, install-transport ordering ..., graceful behaviour and log content ..., navigation-tool generation including the conflict case", plus the two import scans) and closes with "Complete when `flutter test` at the root exits zero with **every listed case present**" — a closed list that does not include this test. Step 6's completion condition is the nearest thing, but it is a completion check rather than a committed test artifact, it covers five of the seven operations (no tool construction as a distinct assertion, no static route source), and it says nothing about the `src/`-import prohibition, which is the criterion's distinctive assertion and appears nowhere in `01-plan.md`.
- Why it matters: At verify time there is no artifact to point AC-004 at, and the implementer following step 9's closed list will not produce one. The public-surface guarantee — that consumers never need an `src/` import — is the one thing AC-004 exists to protect and the one thing no step commits to checking.

### F-004 — Step 10's enumeration of the example manifest omits the field that keeps the root analysis stage at exit 0

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:63` (step 10)
- Criterion affected: AC-017, AC-019
- Observation: Step 10 enumerates the example package's manifest as "its own `pubspec.yaml` with a path dependency on the root package and a committed lock file". It does not include `publish_to: none`, although step 2 at `:47` explicitly specifies that field for the root manifest and names it "an accident guard". An example package that declares a path dependency without `publish_to: none` produces `warning - example/pubspec.yaml:8:5 - Publishable packages can't have 'path' dependencies. ... - invalid_dependency` from the single root analyze invocation, which exits 2. Output pasted above.
- Why it matters: AC-017 requires the analysis stage to exit 0 and report no issue in `example/`; AC-019 requires the whole check script to exit 0 on a clean checkout. As step 10 is written, the stage fails from the first run. A `flutter create`-generated app scaffold supplies `publish_to: 'none'` by default and would mask this, but the plan enumerates the manifest's contents explicitly, so an implementer writing the manifest from the plan rather than from the generator will hit it and will have to diagnose a diagnostic the plan never mentions.

### F-005 — The analysis stage has no path scope, and `example/build/` is walked by the analyzer

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:65` (step 11) and `:95` ("Check command contents")
- Criterion affected: AC-017, AC-019
- Observation: The plan scopes the *format* stage deliberately and says why — "a format check scoped to `lib/`, `test/`, `example/lib/` and `example/test/` (not the whole repository tree, so generated output under `example/build/` or `.dart_tool/` is never walked)" (`:95`). The *analysis* stage in the very next clause is specified as an unscoped single invocation from the repository root with no exclusion at all. My reproduction shows the analyzer excludes `.dart_tool/` by default but does **not** exclude `example/build/`: a Dart file placed at `example/build/web/generated_thing.dart` was analyzed and reported, while one at `example/.dart_tool/flutter_build/generated_entry.dart` was not. Step 10's own completion condition (`:63`) and AC-014 (`02-criteria.md:29`) both require `flutter build web` to have run in `example/`, so `example/build/` exists in the tree by the time the check script runs.
- Why it matters: The plan identifies `example/build/` as a hazard for one stage and leaves the adjacent stage exposed to it. Whether it bites depends entirely on the undecided choice in F-001: under `flutter analyze` the tool's injected `build/**` exclusion happens to cover it as a side effect of mutating a committed file; under `dart analyze` nothing covers it. Whether a `flutter build web` output tree actually contains an analyzable `.dart` file is `[UNVERIFIED]` — I demonstrated the traversal mechanism, not a concrete failing file — but the plan should not be relying on an accident of a tool's self-modifying behaviour for a property it explicitly reasoned about one clause earlier.

### F-006 — AC-020's procedure contradicts AC-020's own condition

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/02-criteria.md:35`
- Criterion affected: AC-020
- Observation: The criterion conditions on "when a branch **touching only `wiki/`** is pushed, the wiki job shall report success regardless of the package job's outcome". The "How it is checked" column instructs: "push a branch that (a) touches only a file under `wiki/` **and** (b) transiently points the package job's check-script invocation at a nonexistent path". Step (b) requires editing `.github/workflows/checks.yml`, which is not under `wiki/`, and it must be edited on the pushed branch because GitHub Actions runs the workflow definition from the pushed ref. (a) and (b) cannot both be true of one branch.
- Why it matters: The check is not executable as literally written; the implementer has to guess which half of the contradiction to honour. The intent is recoverable, but a criterion is the artifact the verify phase is held to, and this one describes a push that cannot be constructed.

### F-007 — AC-007's and AC-008's negative cases are restatements of their positive assertions, not cases that fail

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/02-criteria.md:22` (AC-007) and `:23` (AC-008)
- Criterion affected: AC-007, AC-008
- Observation: AC-007's positive already asserts that "a second unregister call for the same name shall return without throwing and leave the list unchanged". Its negative-case column then asks to "assert that unregistering a name that was never registered returns without throwing" — a second no-throw assertion on a neighbouring input, not a case that fails. AC-008's negative-case column is explicit about the restatement: "The not-found branch is itself the failing case; additionally, invoking a registered name shall not throw the not-found exception" — both clauses are already in the criterion's positive statement, so the column adds no discriminating case. Contrast the columns that do work: AC-011 replaces the log sink with a discarding one, AC-024 makes the no-op transport's publish throw, AC-022 prepends `sleep 200`, AC-012 and AC-023 inject a forbidden import. Those are injections; these two are not.
- Why it matters: The rubric's evidence rule is "at least one negative test per criterion: a case that should fail and does". Neither criterion is uncheckable — a broken implementation that throws on repeat-unregister still fails AC-007's positive — but neither negative column establishes anything the positive did not, so the discriminating power the column is supposed to add is absent. See the recurrence check: this is the third consecutive round in which this defect class is reported, each time at a different set of AC IDs.

### F-008 — Rollback asserts no external service is contacted, which three of the plan's own steps contradict

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:113`
- Criterion affected: none
- Observation: The rollback section states "No data is written, no external service is contacted, no package is published, no secret is provisioned, and nothing outside this repository changes." Step 1 (`:45`) checks pub.dev; step 2 (`:47`) completes on `flutter pub get`, which contacts the package server; step 12 (`:67`) completes "when a pushed branch shows both jobs green", and AC-020 (`02-criteria.md:35`) requires pushing a deliberately broken workflow to GitHub Actions. A branch pushed to the remote is also not undone by "reverting the implementation commit", which is the only rollback action described.
- Why it matters: The claim is factually wrong within the plan's own steps, and the pushed validation branch is a real artifact left outside the described rollback. Low impact — none of these is a one-way door, and `publish_to: none` genuinely guards the only expensive one — but the sentence overstates the containment.

### F-009 — The `.fvmrc` data shape and how CI reads the pinned version out of it are unstated

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:47` (step 2 writes `.fvmrc`) and `:67` (step 12 "installs ... the exact Flutter release named in `.fvmrc`")
- Criterion affected: AC-020
- Observation: The plan does not state `.fvmrc`'s field name or format, nor whether the CI job parses the file at runtime or duplicates the version literal in the workflow. Both files have a single owning step, so there is no collision risk.
- Why it matters: A duplicated literal drifts silently from the file it is supposed to mirror, which is the exact failure mode the risk row at `:109` is trying to close. Worth deciding, but the implementer can decide it alone without blocking anyone.

## Recurrence check

- Previous rounds: `wiki/work/0002-flutter-webmcp-stack/validation/plan-review-01.md` (FAIL), `wiki/work/0002-flutter-webmcp-stack/validation/plan-review-02.md` (CONDITIONAL)
- Recurring findings: F-002, F-006, F-007 (by defect class and, for F-006, by exact location)
- Oscillating: **yes**

I formed the findings above from the artifacts and the repository before reading either earlier report, then compared finding sets as the rubric requires. No finding is verbatim identical to a predecessor, but three defect *classes* have now been reported in all three rounds, each time relocated rather than closed:

1. **The analysis stage / AC-017.** Round 1 F-004 (IMPORTANT): "Whether `example/` is covered by the analysis stage is left to the implementer, but AC-017 requires it", at `01-plan.md:64` / `02-criteria.md:32`. Round 2 F-001 (BLOCKER): "The stated reason for the fourth check-script stage is false, and it contradicts AC-017", at `01-plan.md:64` and `:94`. Round 3 F-001 and F-002 (BLOCKER), at `01-plan.md:49`/`:65`/`:95` and `02-criteria.md:32`. Three rounds, three blockers or importants, same stage, same criterion — the plan resolved *reach* and immediately opened *binary choice*, *scope* and *checkability* in its place.

2. **"The negative case restates the positive."** Round 1 F-006 (IMPORTANT) at `02-criteria.md:35`. Round 2 F-007 (IMPORTANT) at `02-criteria.md:26`, `:35`, `:42`, `:44`. Round 3 F-007 (IMPORTANT) at `02-criteria.md:22` and `:23`. The specific rows named in each round were rewritten; the class was never swept. AC-011, AC-020, AC-022 and AC-024 now have genuine injections, and AC-007 and AC-008 — untouched, unexamined — carry the identical defect.

3. **`02-criteria.md:35` (AC-020) specifically.** Flagged in round 1 (F-006), round 2 (F-007), and round 3 (F-006 above). Three consecutive rounds against one line, for a different reason each time. Under the rubric's "if a finding is materially identical, the loop is not converging", one line drawing a finding in every round of a three-round cap is the clearest possible signal.

**Recommendation: stop iterating and escalate.** `wiki/conventions/validation-rubrics.md:57` caps the phase at three rounds and requires a rewrite rather than a fourth patch; `:59` requires aborting to a human on oscillation. Both triggers have fired. The pattern across the three rounds is a plan being patched at the exact coordinates each report names while the surrounding class of defect stays open, which is what the rubric's oscillation rule is designed to catch. The plan should be rewritten from a clean draft, and `02-criteria.md` should be swept as a whole for the negative-case class rather than row by row.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 (analysis binary undecided; `flutter analyze` mutates the options file) | plan — an undecided shared design choice plus a missing risk row; both live in `01-plan.md`. Do not resolve it by picking a binary in `tools/check.sh` at implement time. |
| F-002 (AC-017 self-contradictory, no failing case for its distinctive claim) | plan — criteria defect. `02-criteria.md` is not yet frozen (`02-criteria.md:9`), so it is corrected in the plan phase, not by a silent edit later. |
| F-003 (AC-004 has no implementing step) | plan — step 9's test list at `01-plan.md:61` is the closed contract that omits it. |
| F-004 (example manifest omits `publish_to: none`) | plan — step 10's enumeration at `01-plan.md:63`. |
| F-005 (analysis stage unscoped over `example/build/`) | plan — step 11 and the shared decision at `01-plan.md:65`, `:95`. |
| F-006 (AC-020 procedure contradicts its condition) | plan — criteria defect at `02-criteria.md:35`. |
| F-007 (AC-007/AC-008 negative cases restate the positive) | plan — criteria defect at `02-criteria.md:22`, `:23`. |
| F-008 (rollback overstates containment) | plan — `01-plan.md:113`. |
| F-009 (`.fvmrc` shape unstated) | plan — `01-plan.md:47`, `:67`. Lowest priority; may be carried as a follow-up with an owner. |

All nine findings route to the plan phase. None is an implementation defect, because no implementation exists yet. Given the recurrence verdict, the routing target is a rewritten plan rather than a fourth patch of the current one.
