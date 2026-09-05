# Plan review — round 01

- Work item: 0004-flutter-webmcp-skeleton
- Reviewed artifact: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md` against `wiki/work/0004-flutter-webmcp-skeleton/02-criteria.md` (working tree at `15c0f0e`, both files uncommitted)
- Reviewer: plan-validator
- Date: 2026-09-05

## Verdict

**CONDITIONAL**

Every criterion has an implementing step, every step serves a criterion, and every load-bearing claim I could reproduce (the analyzer migration's trigger and idempotence, the single-invocation nested-package analysis, the pub.dev name, the minimal-`PATH` preflight assumption) held up under direct test — but the Rollback section states that step 10's completion condition requires pushing a branch, which step 10 and AC-026 both explicitly deny, and that contradiction sits on the one action in this plan the author gated behind a human's go-ahead.

## Verification performed

### Fenced code blocks — none, lint clean

```
$ python3 tools/lint_wiki.py; echo "EXIT=$?"
lint_wiki: clean (0 warning(s)).
EXIT=0

$ grep -n '```' wiki/work/0004-flutter-webmcp-skeleton/01-plan.md; echo "grep exit=$?"
grep exit=1
$ grep -n '~~~' wiki/work/0004-flutter-webmcp-skeleton/01-plan.md; echo "exit=$?"
exit=1
```

`tools/lint_wiki.py:352-361` is the check that would have caught a fence; I also grepped both fence styles directly. Zero fenced blocks, zero snippets, zero pseudo-code in `01-plan.md`.

### Section order and completeness

`01-plan.md` headings, in order: Goal (3), Approach (7), Why this approach (17), Steps (31), Interfaces and shared decisions (55), Risks (75), Rollback (86), Out of scope (94), Verification approach (98). This matches `wiki/templates/01-plan.md` exactly. Every one of the eleven steps names what it touches and a completion condition. The Risks table (lines 77-84) has six rows, each with a mitigation and a trigger.

### `AnalysisOptionsMigration` — source read and behaviour reproduced

Toolchain in use:

```
$ fvm flutter --version --machine
  "frameworkVersion": "3.47.0", "channel": "[user-branch]",
  "dartSdkVersion": "3.13.0", "flutterRoot": "/Users/ortalcohen/fvm/versions/3.47.0"
$ dart --version
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"
```

`/Users/ortalcohen/fvm/versions/3.47.0/packages/flutter_tools/lib/src/migrations/analysis_options_migration.dart:39-69` holds exactly the seven entries the plan names, and only rewrites when one is missing:

```
    const excludesToExclude = <String>[
      'build/**', 'android/**', 'ios/**', 'web/**', 'windows/**', 'macos/**', 'linux/**',
    ];
    ...
        for (final requiredExclude in excludesToExclude) {
          if (!exclude.contains(requiredExclude)) { needsMigration = true; break; }
        }
    if (!needsMigration) { return; }
```

Call sites confirm the plan's reachability claim:

```
$ grep -rn "AnalysisOptionsMigration" .../flutter_tools/lib/
.../lib/src/project.dart:429:      AnalysisOptionsMigration(this, globals.logger),
$ grep -rn "regeneratePlatformSpecificTooling" .../runner/flutter_command.dart .../commands/packages.dart
.../commands/packages.dart:400:        await project.regeneratePlatformSpecificTooling(
.../commands/packages.dart:412:            await exampleProject.regeneratePlatformSpecificTooling(
.../runner/flutter_command.dart:1982:    if (regeneratePlatformSpecificToolingDuringVerify) {
.../runner/flutter_command.dart:2036:  bool get regeneratePlatformSpecificToolingDuringVerify => true;
```

Empirical reproduction in a scratch Flutter package (complete seven-entry list committed):

```
$ shasum analysis_options.yaml
ffaf86938af1a4438daa6f0adbf69b1a30f3008c  analysis_options.yaml
$ fvm flutter pub get   # one run
Changed 24 dependencies!
$ shasum analysis_options.yaml
ffaf86938af1a4438daa6f0adbf69b1a30f3008c  analysis_options.yaml
```

Then with `ios/**` removed — the exact mutation AC-006's negative case prescribes:

```
COMMITTED(missing ios): 4cc4f1a96b87c690ff6b96c57f173f56ba3bd0bc
--- run 1 ---
Got dependencies!
Upgrading analysis_options.yaml to exclude build and platform directories.
AFTER RUN1: 5b0040ac8a430195b38d077b3d604017f452bc80
--- run 2 ---
Got dependencies!
AFTER RUN2: 5b0040ac8a430195b38d077b3d604017f452bc80
```

This confirms the plan's central reasoning at `01-plan.md:19,35,43,104` and AC-006 at `02-criteria.md:19`: the file mutates on the first run and is byte-stable on the second, so a run-versus-run comparison is blind to it and committed-state-versus-after-first-run is the only comparison that catches it. The plan says this in all four places it raises the mechanism, and says the same thing in each.

### One `dart analyze` from the root reaching a nested `example/` package

Scratch repository: root package with its own `analysis_options.yaml` (seven entries plus `example/build/**` plus a public-member documentation rule), nested `example/` package with its own pubspec and its own `analysis_options.yaml`, plus a deliberately broken file at `example/build/bad.dart`.

Clean state:

```
$ fvm dart analyze --fatal-infos --fatal-warnings <root>
Analyzing nested...
No issues found!
EXIT=0
```

With AC-005's two mutations applied (unused local in `example/lib/main.dart`, undocumented public method in root `lib/`):

```
Analyzing nested...
warning - example/lib/main.dart:3:9 - The value of the local variable 'unusedLocal' isn't used. ... - unused_local_variable
   info - lib/root.dart:6:8 - Missing documentation for a public member. ... - public_member_api_docs
2 issues found.
EXIT=2
```

So the single root invocation does reach the nested package, the nested options file governs it (the doc rule does not leak into `example/`), and both infos and warnings are fatal. I also confirmed the doc rule fires inside `lib/src/`, which AC-005's negative case depends on:

```
info - lib/src/inner.dart:3:8 - Missing documentation for a public member. ... - public_member_api_docs
EXIT=1
```

and that it does *not* fire on files under `test/` (so the root doc rule will not turn the clean-tree analysis red through the test suite):

```
# test/some_test.dart with an undocumented public class present
Analyzing nested...
No issues found!
EXIT=0
```

AC-007's negative case reproduces exactly as written — removing `build/**` from `example/analysis_options.yaml` surfaces the error even though the root file still carries `example/build/**`:

```
error - example/build/bad.dart:2:3 - The function 'totallyUndeclaredIdentifier' isn't defined. ... - undefined_function
EXIT=3
```

which independently confirms the plan's claim at `01-plan.md:69` that the root's `example/build/**` entry is redundant and the example's own entry is the load-bearing one.

AC-008's negative case also reproduces:

```
warning - example/pubspec.yaml:10:5 - Publishable packages can't have 'path' dependencies. Try adding a 'publish_to: none' entry ... - invalid_dependency
EXIT=2
```

AC-019's negative case mechanism holds — a web-only library import is a compile error on the VM:

```
$ fvm dart run bin/webimport.dart
bin/webimport.dart:1:8: Error: Dart library 'dart:js_interop' is not available on this platform.
```

`platforms: web:` in a pubspec does not block VM tests (relevant to AC-029 coexisting with step 5):

```
$ fvm flutter test
00:00 +1: All tests passed!
EXIT=0
```

### Repository state

```
$ git ls-files README.md
README.md
$ wc -l README.md
      73 README.md
$ grep -n "^#" README.md
1:# Agent workflow scaffold
5:## Start here
22:## The pipeline
32:## Setup
46:## Layout
63:## Why it is shaped this way
```

`README.md:36` holds the Cursor sentence AC-027 protects, and `wiki/adr/0002-share-agent-config-between-claude-code-and-cursor.md:55,63` does depend on it. `.github/workflows/checks.yml` defines exactly one job today (`wiki`, line 9), so step 10's "add a second job" and AC-024's "exactly two jobs" agree with reality. `AGENTS.md` is 69 lines, leaving AC-030's 200-line ceiling comfortable. `git remote -v` is `https://github.com/ortal83cohen/project-AI-skeleton`, matching the URL the plan quotes at line 57.

```
$ curl -s -o /dev/null -w "%{http_code}\n" https://pub.dev/packages/webmcp_pilot
404
$ curl -s -o /dev/null -w "%{http_code}\n" https://pub.dev/api/packages/webmcp_pilot
404
```

`webmcp_pilot` is unclaimed, as `01-plan.md:9` states. Dependency claims check out too: `package:web` latest is `1.1.1` (so a caret range with lower bound 1.1.1 resolves), `flutter_lints` latest is `6.0.0`, and `dart:js_interop_unsafe` really does expose `has`/`hasProperty` (`.../dart-sdk/lib/js_interop_unsafe/js_interop_unsafe.dart:36`).

AC-002's minimal-`PATH` premise holds on this machine, in a non-interactive shell where the `fvm` aliases do not exist:

```
$ /bin/sh -c 'PATH=/usr/bin:/bin; command -v python3; echo "python3 rc=$?"; command -v flutter; echo "flutter rc=$?"; command -v dart; echo "dart rc=$?"'
/usr/bin/python3
python3 rc=0
flutter rc=1
dart rc=1
```

A secret-marker false-positive scan over the directories AC-032 covers returns nothing, so the clean-tree half of AC-032 is achievable:

```
$ grep -rniE "password|api[_-]?key|app[_-]?key|secret|AKIA|BEGIN [A-Z ]*PRIVATE KEY" tools/ .github/
(no output)
```

### Gating of the two human-dependent items

- `01-plan.md:49` (LICENSE): "this step does not start until a human has supplied that exact string, and no placeholder or invented name is written in its place", with the completion condition "`LICENSE` contains the human-supplied copyright-holder string". This is a real stop, not a silent default.
- `01-plan.md:51` (CI push): "it needs a human's explicit, in-the-moment go-ahead before it happens — this plan does not grant that in advance ... AC-026's second half is recorded as unverified pending that decision rather than treated as failing or as silently skipped." Also a real stop, and it matches AC-026 at `02-criteria.md:39`. See F-001 for the place that contradicts it.

## Criterion-to-step coverage

Plan reviews get coverage, not per-criterion pass/fail. Every criterion has at least one implementing step; every step serves at least one criterion.

| Criterion | Implementing step | Notes |
|---|---|---|
| AC-001 | Step 7 (`:45`), Step 11 (`:53`) | preflight + six stages, fixed order at `:67` |
| AC-002 | Step 7 (`:45`), Interfaces (`:67`) | premise verified above |
| AC-003 | Step 7 (`:45`), Step 8 (`:47`) | |
| AC-004 | Step 7 (`:45`), Interfaces (`:67`) | four paths agree with `:73` and AC-004 |
| AC-005 | Step 7 (`:45`), Interfaces (`:67`,`:69`) | reproduced above |
| AC-006 | Step 2 (`:35`), Step 6 (`:43`), Verification (`:104`) | all four mentions agree |
| AC-007 | Step 6 (`:43`), Interfaces (`:69`) | reproduced above |
| AC-008 | Step 6 (`:43`), Interfaces (`:57`) | reproduced above |
| AC-009 – AC-016 | Step 3 (`:37`), Step 5 (`:41`) | data shapes and error types fixed at `:59-63` |
| AC-017 | Step 3 (`:37`), Step 5 (`:41`) | seven public operations enumerated at `:59` |
| AC-018 | Step 5 (`:41`), Interfaces (`:71`) | scope disagreement — see F-003 |
| AC-019 – AC-021 | Step 4 (`:39`), Step 5 (`:41`) | selector and literal strings fixed at `:65` |
| AC-022 | Step 6 (`:43`) | |
| AC-023 | Step 6 (`:43`), Step 7 (`:45`) | |
| AC-024, AC-025 | Step 9 (`:49`), Step 10 (`:51`), Interfaces (`:73`) | literal `bash tools/check.sh` identical at `:49`, `:51`, `:73` |
| AC-026 | Step 10 (`:51`) | contradicted by Rollback — see F-001 |
| AC-027 | Step 9 (`:49`) | |
| AC-028 | Steps 2, 3, 5, 6, 9 | |
| AC-029 | Step 2 (`:35`), Interfaces (`:57`) | |
| AC-030 | Step 9 (`:49`), Interfaces (`:73`) | |
| AC-031 | Step 11 (`:53`) | treated as a gate, not an observation |
| AC-032 | Step 5 (`:41`), Interfaces (`:71`) | |
| AC-033 | Step 1 (`:33`) | six patterns named |

Reverse direction: steps 1-11 each serve at least one criterion. Step 8 exists only to satisfy AC-003's failure demonstration and step 11 only AC-001/AC-031; both are named as such. No step is scope creep.

Criteria quality: no criterion uses "correctly", "properly", "as expected" or "appropriately" (`tools/lint_wiki.py:363-375` enforces this and passes). Every criterion carries a negative case that is a concrete mutation of a file, not a restatement of the positive; I reproduced the mutations behind AC-005, AC-006, AC-007, AC-008 and AC-019 directly and they all fail the way the criterion says.

## Findings

### F-001 — Rollback says the CI push is required; step 10 and AC-026 say it is not

- Severity: BLOCKER
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:90`
- Criterion affected: AC-026
- Observation: The Rollback section reads "any branch pushed to the remote to observe CI, **which step 10's completion condition requires**, stays in the remote's history along with its Actions run and logs until someone deletes the branch explicitly". Step 10 at line 51 states the opposite in the same document: "Pushing a branch to observe both jobs run (AC-026's second half) is a separate, later action **this step's completion does not require**: it needs a human's explicit, in-the-moment go-ahead before it happens — this plan does not grant that in advance". `02-criteria.md:39` sides with step 10: "this second half is not required for this work item to be complete, since it depends on a push this plan cannot authorize on anyone's behalf."
- Why it matters: The one external, non-revertible action in this plan is the one the two sections disagree about. An implementer who reads Rollback as the authority pushes a branch to `https://github.com/ortal83cohen/project-AI-skeleton` without the human go-ahead the plan elsewhere insists on, and the plan itself notes at line 90 that the branch, its Actions run and its logs survive any revert. The contradiction also makes step 10's completion condition ambiguous: an implementer cannot tell whether the step is done after the workflow file is written or only after CI has been observed.

### F-002 — Interfaces claims `.dart_tool` is excluded by explicit entries; no step writes such an entry, and the exclusion actually comes from the analyzer's hidden-directory default

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:69` (against `:35`)
- Criterion affected: AC-005 (indirectly; no outcome changes)
- Observation: Line 69 states "everything under any `.dart_tool` directory, excluded by explicit entries rather than by the analyzer's hidden-directory behaviour". No step writes those entries. Step 2 at line 35 enumerates the root file's list as exactly "all seven of `build/**`, `android/**`, `ios/**`, `web/**`, `windows/**`, `macos/**`, `linux/**`, plus `example/build/**`" and makes "contains all eight exclusion entries" its completion condition; line 69's own second half repeats the same eight. I placed a Dart file with an undefined-function error at `<root>/.dart_tool/generated_bad.dart` in the scratch repository, whose options file has no `.dart_tool` entry, and analysis did not report it — the hidden-directory behaviour the plan says it is not relying on is exactly what is doing the work.
- Why it matters: The Interfaces section is the part of the plan that is supposed to be authoritative once implementation fans out, and here it describes a mechanism the steps do not implement. An implementer reconciling the two either adds entries step 2 does not list, or ships a file whose behaviour rests on a tool default the plan explicitly disclaims. The observable analysis result is the same either way, which is why this is not a blocker, but the plan's stated analysis scope is not the one the committed files will produce.

### F-003 — The forbidden-import scan's directory scope differs between step 5 and the Interfaces section

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:41` (against `:71`)
- Criterion affected: AC-018
- Observation: Step 5 says `test/repo_hygiene_test.dart` "runs two independent scans over the fixed directory set `lib/`, `example/lib/`, `tools/` and `.github/` — a forbidden-import scan that reads only the Dart files in that set ... and a secret-token scan that reads every tracked file in that set". Interfaces line 71 scopes the forbidden-import scan differently: "fails if any Dart file under `lib/` or `example/lib/` imports ...", and only the secret-token half is scoped to all four directories. AC-018 at `02-criteria.md:31` matches Interfaces, not step 5.
- Why it matters: The plan says at line 71 "Both lists are fixed here so no step invents its own", but the scope is not fixed — two paragraphs give two answers. It happens to be inert today because no Dart file exists under `tools/` or `.github/` (`git ls-files` shows `.py`, `.sh`, `.yml`, `.json`, `.md` only), so neither reading changes any criterion's outcome now; it stops being inert the moment a Dart helper lands in `tools/`.

### F-004 — Step 3's completion condition cannot be satisfied, because the public surface it must export is created in step 4

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:37`
- Criterion affected: none directly
- Observation: Step 3 says "The public library exports exactly the symbols listed in the Interfaces section" and "Complete when `dart analyze` from the repository root reports zero issues". The Interfaces section at line 59 puts `WebMcpTransport` in that export list, and lines 59 and 65 make `WebMcp.reset` install "a freshly created default one" via `createDefaultTransport` and `transportId` read from a transport. Both `lib/src/transport/webmcp_transport.dart` and the selector that declares `createDefaultTransport` are created in step 4 (line 39). At the end of step 3 the export line names a file that does not exist and `lib/src/webmcp.dart` references an undeclared type, so analysis reports unresolved-URI and undefined-class errors, not zero issues.
- Why it matters: A completion condition that cannot be met is not a gate. The implementer either merges steps 3 and 4 on their own initiative or writes a throwaway stub, and in both cases the plan's step boundary — the thing that makes progress checkable — has been renegotiated silently at implementation time.

### F-005 — The pinned Flutter version literal is never chosen, yet step 2 depends on it

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:57` (against `:33` and `:51`)
- Criterion affected: AC-026
- Observation: Interfaces line 57 fixes the manifest's Dart constraint as "the Dart version bundled with the pinned Flutter release", written in step 2. The pin itself is not introduced until step 10 ("installs the Flutter stable SDK at one pinned version literal", line 51), and no line anywhere states which release that is or requires it to equal the toolchain step 1 records. Line 27 makes the single literal the sole defence against drift: "The Flutter version is therefore pinned in exactly one place". The machine's toolchain is Flutter 3.47.0 on channel `[user-branch]` with Dart 3.13.0, which step 1 (line 33) explicitly accepts as a non-`stable` channel label, so the CI pin and the local SDK are not the same object and nothing in the plan ties them together.
- Why it matters: Step 2 cannot write the `environment` lower bound without knowing a value step 10 chooses, and if the two diverge the divergence is invisible: with no committed lock file (line 27) and a formatter whose output style is gated on the SDK version, a CI pin different from the development SDK turns the format and analysis stages red on a commit that is green locally. The plan raises the analogous risk for `flutter_lints` (line 79) but not for the SDK pin it made single-source-of-truth.

### F-006 — No `03-tasks.md` exists, so the implement phase has nothing to execute and parallelism could not be cross-checked

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/` (directory listing: `00-research.md`, `01-plan.md`, `02-criteria.md`, `STATE.yaml`, `research/`, `validation/`)
- Criterion affected: none
- Observation: `wiki/conventions/workflow.md:31` lists `03-tasks.md` among the work item's artifacts and `workflow.md:92` makes it the thing Phase 4 executes: "Work through `03-tasks.md` in dependency order. Tasks marked `[P]` may run in parallel subagents". `wiki/conventions/naming.md:25` requires each task to cite the criteria it satisfies. The file is absent. `tools/lint_wiki.py` does not check for it (`check_work_items`, lines 312-349, only warns on a missing `01-plan.md`), so its absence passes lint.
- Why it matters: The Phase 2 gate at `workflow.md:61` is only "plan exists, criteria exist, lint passes", so this does not block the plan review itself — but it does mean I could not perform the parallelism-safety check at all, and the implement phase will start without the artifact the workflow tells it to execute. Note for the record: `01-plan.md`'s eleven steps are strictly sequential with no parallel markers, so nothing in the plan as written creates a two-tasks-one-file hazard.

### F-007 — Step 9 blocks its ungated README and `AGENTS.md` edits behind the human-gated licence decision

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:49`
- Criterion affected: AC-025, AC-027, AC-030
- Observation: Step 9 gates on the copyright holder — "this step does not start until a human has supplied that exact string" — and then sequences everything else behind that answer: "Once that answer exists, the README edit inserts one new top-level section ... `AGENTS.md` gains a `## Checks` section". Step 10 (line 51) needs the `## Checks` literal to exist for AC-025's equality check, and step 11 runs the whole suite. So one unanswered licensing question stalls AC-025, AC-027 and AC-030 as well as AC-028's `LICENSE` entry.
- Why it matters: The gate itself is right and I am not questioning it — a licence naming a copyright holder is exactly the kind of decision an agent must not invent. What is avoidable is the coupling: three criteria that have nothing to do with licensing inherit a human dependency, and the plan gives no way to proceed on them while the question is outstanding. Step 10's own gate (line 51) shows the alternative shape — proceed, and record the gated half as pending.

### F-008 — "Checksum as committed beforehand" is asked for at a point where nothing has been committed

- Severity: NIT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:35` and `:43`
- Criterion affected: AC-006
- Observation: Step 2 authors `analysis_options.yaml` as a new file and then requires "the file's checksum after that one run equals its checksum as committed beforehand"; step 6 uses the same wording for `example/analysis_options.yaml`. At both points the file is newly written and uncommitted, so there is no committed blob to hash. AC-006 (`02-criteria.md:19`) states the check properly, on "a tree freshly checked out from the commit and never yet touched by any Flutter command", with `git show HEAD:analysis_options.yaml | shasum` as the example.
- Why it matters: The substance is unambiguous everywhere it appears (before-first-run versus after-first-run, never run-versus-run), so an implementer will hash the authored file before running anything and get the right answer. Only the word "committed" is out of place in the step ordering.

### F-009 — "Exactly as step 2 describes for the root file" imports the root's `example/build/**` entry into the example's own options file

- Severity: NIT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:43`
- Criterion affected: AC-006
- Observation: Step 6 says `example/analysis_options.yaml` "is written pre-migrated exactly as step 2 describes for the root file, with `build/**` among its own exclusions". Step 2's list is eight entries including `example/build/**`, which inside `example/` would mean `example/example/build`. Interfaces line 69 resolves it — seven entries for the example file, the eighth for the root only — but the step and the Interfaces section have to be read together to get there.
- Why it matters: A stray `example/build/**` line in the example's options file would be harmless to every criterion, so this costs a moment of reading, nothing more.

## Recurrence check

- Previous round: none — first round. `wiki/work/0004-flutter-webmcp-skeleton/validation/` was empty before this report (`ls -la` returned only `.` and `..`), and per the review brief this work item's artifacts were judged on their own, without reference to any predecessor folder.
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 (BLOCKER) | plan — a contradiction between two sections of `01-plan.md`; resolved by making the Rollback section agree with step 10 and AC-026, not by anything an implementer does |
| F-002 (IMPORTANT) | plan — the Interfaces section's stated analysis scope does not match what step 2 writes |
| F-003 (IMPORTANT) | plan — a shared decision (scan scope) is stated twice with two answers |
| F-004 (IMPORTANT) | plan — step boundary and completion condition |
| F-005 (IMPORTANT) | plan — an undecided shared value the Interfaces section already depends on |
| F-006 (IMPORTANT) | plan — a missing plan-phase artifact (`03-tasks.md`) |
| F-007 (IMPORTANT) | plan — step sequencing around a human gate |
| F-008, F-009 (NIT) | plan — wording only; neither blocks |
