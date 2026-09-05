# Plan review — round 02

- Work item: 0003-flutter-webmcp-skeleton
- Reviewed artifacts: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md`, `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md` (working tree at `663cf48`, both files untracked/uncommitted at review time)
- Reviewer: plan validator (blind — plan and criteria only; `STATE.yaml` was read for phase/round metadata and does contain the author's own round-1 summary, which was read only after the findings below were fixed)
- Date: 2026-09-05

## Verdict

**CONDITIONAL**

The approach is sound and every load-bearing toolchain claim in the plan was reproduced and holds, but one acceptance criterion (AC-006) is verified by a method that empirically cannot detect the failure it exists to catch, so as written it passes a broken tree.

## Verification performed

### Plan is prose only (no fenced code)

```
$ python3 tools/lint_wiki.py; echo "EXIT=$?"
lint_wiki: clean (0 warning(s)).
EXIT=0

$ grep -n '```' wiki/work/0003-flutter-webmcp-skeleton/01-plan.md; echo "fence-grep-exit=$?"
fence-grep-exit=1

$ grep -n -iE "correctly|properly|as expected" wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md; echo "(exit $?)"
(exit 1)
```

`tools/lint_wiki.py:352` (`check_plan_is_prose`) and `:363` (`check_criteria`, vague-term scan) both pass. Zero fenced blocks, zero snippets, zero pseudo-code in `01-plan.md`. Section order is Goal (`:3`), Approach (`:7`), Why this approach (`:17`), Steps (`:31`), Interfaces and shared decisions (`:55`), Risks (`:75`), Rollback (`:86`), Out of scope (`:94`), Verification approach (`:98`). Every step at `:33`–`:53` names the files it touches and a completion condition.

### `AnalysisOptionsMigration` — read the SDK source, then reproduced it

Active toolchain: `Flutter 3.47.0 • channel [user-branch] • Tools • Dart 3.13.0` (FVM). Source read: `/Users/ortalcohen/fvm/versions/3.47.0/packages/flutter_tools/lib/src/migrations/analysis_options_migration.dart`.

- `:39-47` — the required list is exactly the seven entries the plan names at `01-plan.md:19`.
- `:49-65` — `needsMigration` is set only if `analyzer` is not a map, `analyzer.exclude` is not a list, or any of the seven is not `contains`ed. Extra entries are irrelevant.
- `:67-69` — returns without writing when nothing is missing.
- `:71-73` — prints exactly `Upgrading analysis_options.yaml to exclude build and platform directories.`
- `:85-92` — appends only the missing entries and rewrites the file in place.
- Call site: `flutter_tools/lib/src/project.dart:429` inside `ensureReadyForPlatformSpecificTooling`, reached from `regeneratePlatformSpecificTooling` (`project.dart:388`), called from `flutter_command.dart:1982-1983` in `verifyThenRunCommand`.

Empirical confirmation, scratch package with the full seven-entry list:

```
$ shasum analysis_options.yaml
ffaf86938af1a4438daa6f0adbf69b1a30f3008c  .../repro/a/analysis_options.yaml
$ fvm flutter pub get   (run 1)
Changed 7 dependencies!
--- after run1 ---
ffaf86938af1a4438daa6f0adbf69b1a30f3008c
$ fvm flutter pub get   (run 2)
Got dependencies!
--- after run2 ---
ffaf86938af1a4438daa6f0adbf69b1a30f3008c
```

Byte-identical. With `ios/**` removed:

```
$ shasum analysis_options.yaml -> 4cc4f1a96b87c690ff6b96c57f173f56ba3bd0bc
$ fvm flutter pub get
Upgrading analysis_options.yaml to exclude build and platform directories.
$ shasum analysis_options.yaml -> 5b0040ac8a430195b38d077b3d604017f452bc80   (ios/** appended)
```

`dart analyze` does not run it, `flutter test` does:

```
$ (missing ios/**) shasum -> 4cc4f1a96b87c690ff6b96c57f173f56ba3bd0bc
$ fvm dart analyze
Analyzing a... No issues found!
$ shasum -> 4cc4f1a96b87c690ff6b96c57f173f56ba3bd0bc   (unchanged)

$ (root package, missing ios/**) shasum -> d01c2f9b43b7735895484a1fdb8ddc40e5ca3186
$ fvm flutter test
Upgrading analysis_options.yaml to exclude build and platform directories.
$ shasum -> db5863dc1af2b38f9d0fd5bcdd2096fac4cf65ea   (ios/** appended at line 12)
```

Verdict on the claim at `01-plan.md:19`: **accurate in every particular**, including the seven entries, the idempotence, the message text, the `dart analyze` exemption, and the `flutter test` / `verifyThenRunCommand` path.

### One root `dart analyze` reaching a nested `example/` package

Scratch reproduction: root package `repro_root` with `lib/`, its own `analysis_options.yaml` (flutter_lints + `public_member_api_docs: true` + the seven excludes + `example/build/**`), and a nested `example/` package with its own `pubspec.yaml`, `analysis_options.yaml` (flutter_lints only) and path dependency on the root.

```
$ fvm dart analyze --fatal-infos --fatal-warnings          # AC-005 negative, both mutations applied
Analyzing root...
warning - example/lib/main.dart:5:9 - The value of the local variable 'unusedLocal' isn't used. - unused_local_variable
   info - lib/repro_root.dart:6:7 - Missing documentation for a public member. - public_member_api_docs
2 issues found.
EXIT=2
```

One invocation from the root reaches the nested package, and both a warning under `example/lib/` and an info under `lib/` are reported and fatal. AC-005 is constructible as written.

AC-007, transient `example/build/web/generated.dart` calling an undeclared function:

```
$ fvm dart analyze --fatal-infos --fatal-warnings          # positive
Analyzing root... No issues found!   EXIT=0

# negative: build/** removed from example/analysis_options.yaml, root example/build/** kept
$ fvm dart analyze --fatal-infos --fatal-warnings
error - example/build/web/generated.dart:2:3 - The function 'undeclaredIdentifierThatDoesNotExist' isn't defined. - undefined_function
1 issue found.   EXIT=3
```

AC-007's negative fires; the root file's redundant `example/build/**` entry does not mask it, exactly as `01-plan.md:69` claims.

AC-008, `publish_to` removed from `example/pubspec.yaml`:

```
warning - example/pubspec.yaml:10:5 - Publishable packages can't have 'path' dependencies. Try adding a 'publish_to: none' entry ... - invalid_dependency
```

Confirms `01-plan.md:57`.

### Transport seam (AC-019, AC-005 interaction)

Built the conditional export from `01-plan.md:65` in the scratch package: `export 'transport_noop.dart' if (dart.library.js_interop) 'transport_web.dart';`, with a web implementation importing `dart:developer`, `dart:js_interop`, `dart:js_interop_unsafe` and `package:web`.

```
$ fvm dart analyze --fatal-infos --fatal-warnings      # transport_web.dart raised no platform diagnostic
$ fvm flutter test
00:00 +1: All tests passed!                            # noop selected on the VM

# AC-019 negative: branches swapped
$ fvm flutter test
.../web-1.1.1/lib/src/helpers/http.dart:252:62: Error: The method 'jsify' isn't defined for the type 'Object'.
00:00 +0 -1: Some tests failed.
```

AC-019's negative case fires as written.

### Repository state the plan asserts

```
$ git ls-files README.md          -> README.md
$ wc -l README.md                 -> 73
$ grep -n "^#" README.md
1:# Agent workflow scaffold
5:## Start here
22:## The pipeline
32:## Setup
46:## Layout
63:## Why it is shaped this way
$ grep -n -i cursor README.md | sed -n 2p
36:**Cursor** reads `AGENTS.md` natively. To also pick up the skills and subagents in `.claude/` ... include third-party plugins ...
```

Step 9's edit (a new level-one heading inserted above line 1, existing lines byte-identical below, two sequential H1s) is structurally executable; the ADR-referenced Cursor sentence is at `README.md:36`, well below the insertion point, so AC-027 is checkable. `tools/lint_wiki.py` imposes no constraint on README heading structure (`check_instruction_bridge` at `:100` only checks `AGENTS.md` ≤ 200 lines and `CLAUDE.md` ≤ 40 lines; `AGENTS.md` is 69 lines today, so AC-030's ceiling is not at risk).

```
$ cat .github/workflows/checks.yml   -> one job key (`wiki:` at :9) plus a placeholder comment at :25-27
$ git remote -v                      -> origin https://github.com/ortal83cohen/project-AI-skeleton
$ curl -o /dev/null -w '%{http_code}' https://pub.dev/api/packages/webmcp_pilot   -> 404
$ pub.dev api: web latest 1.1.1 (1.1.1 exists); flutter_lints latest 6.0.0
$ fvm flutter pub get with `platforms:\n  web:` and `web: ^1.1.1`  -> EXIT=0
```

Current job count is one, so step 10's "add a second job" and AC-024's "exactly two jobs" are consistent. The package name and the `package:web` lower bound in `01-plan.md:9` and `:57` are accurate as of today.

### PATH preflight (AC-002)

```
$ env -i PATH=/usr/bin:/bin sh -c 'command -v flutter; echo flutter_rc=$?; command -v dart; echo dart_rc=$?; command -v python3'
flutter_rc=1
dart_rc=1
/usr/bin/python3

$ env -i PATH=/usr/bin:/bin HOME=$HOME sh -c 'python3 tools/lint_wiki.py; echo "stage1_exit=$?"'
lint_wiki: clean (0 warning(s)).
stage1_exit=0

$ sh -lc 'command -v flutter dart'
/Users/ortalcohen/.local/bin/flutter
/Users/ortalcohen/.local/bin/dart
```

The AC-002 precondition holds (`/usr/bin:/bin` resolves neither `flutter` nor `dart`), and real `flutter`/`dart` binaries — not just interactive shell aliases — are on the non-interactive PATH, so `tools/check.sh` will find them. But stage 1 (`python3 tools/lint_wiki.py`) *succeeds* under that minimal PATH; see F-002.

### Parallelism

```
$ ls wiki/work/0003-flutter-webmcp-skeleton/ | grep -c 03-tasks
0
```

No `03-tasks.md` exists, so there are no parallel markers to cross-check. Not applicable this round.

## Criterion coverage

Plan-phase analogue of the per-criterion table: every `AC-NNN` mapped to the step that implements it.

| Criterion | Implementing step | Coverage |
|---|---|---|
| AC-001 | step 7 (`01-plan.md:45`) | covered |
| AC-002 | step 7 preflight (`:45`, Interfaces `:67`) | covered — negative case defective, F-002 |
| AC-003 | steps 7, 8 (`:45`, `:47`) | covered |
| AC-004 | step 7 stage 3 (`:45`, `:67`) | covered |
| AC-005 | steps 2, 7 (`:35`, `:67`, `:69`) | covered, reproduced above |
| AC-006 | steps 2, 6 (`:35`, `:43`) | step exists — check method defective, F-001 |
| AC-007 | step 6 (`:43`), Interfaces `:69` | covered, reproduced above |
| AC-008 | step 6 (`:43`), Interfaces `:57` | covered, reproduced above |
| AC-009 – AC-016 | steps 3, 5 (`:37`, `:41`), Interfaces `:59`–`:63` | covered |
| AC-017 | step 5 (`:41`), Interfaces `:59` | covered |
| AC-018 | step 5 (`:41`), Interfaces `:71` | covered |
| AC-019 | steps 4, 5 (`:39`, `:41`) | covered, reproduced above |
| AC-020 | steps 3, 4, 5 | covered |
| AC-021 | steps 4, 5 (`:39`, `:41`) | covered |
| AC-022 | step 6 (`:43`) | covered |
| AC-023 | step 6 (`:43`) | covered — `WebProject.existsSync` at `project.dart:1187` requires `web/index.html`, and `build_web.dart:262-264` aborts with "This project is not configured for the web", so the negative fires |
| AC-024 | step 10 (`:51`) | covered |
| AC-025 | steps 9, 10 (`:49`, `:51`, `:73`) | covered — exact command literal undecided, F-005 |
| AC-026 | step 10 (`:51`) | covered — authorization gap, F-006 |
| AC-027 | step 9 (`:49`) | covered |
| AC-028 | steps 2, 3, 5, 6, 9 | covered |
| AC-029 | step 2 (`:35`), Interfaces `:57` | covered |
| AC-030 | step 9 (`:49`), Interfaces `:73` | covered |
| AC-031 | step 11 (`:53`) | covered |
| AC-032 | step 5 (`:41`), Interfaces `:71` | covered — scope contradiction, F-004 |

Steps serving no criterion: step 1's `.gitignore` work (`01-plan.md:33`) — see F-003. Every other step serves at least one criterion.

## Findings

### F-001 — AC-006's check method cannot distinguish a migrated file from an unmigrated one; the plan repeats the same method three times and calls it "the only proof that matters"

- Severity: BLOCKER
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:19` (AC-006, columns 3 and 4); `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:104`, and the same method as step completion conditions at `01-plan.md:35` and `:43`
- Criterion affected: AC-006
- Observation: AC-006's check method is "Run the dependency stage twice; compare each file's checksum between the two runs", and the criterion text is "shall have the same checksum after the second run as after the first". Its negative case, however, compares a different pair: "the file's checksum after this run differs from its checksum **before**". Under the criterion's own stated method the negative case does not fail. Reproduced with an `analysis_options.yaml` missing `ios/**`:

```
before any run: 4cc4f1a96b87c690ff6b96c57f173f56ba3bd0bc
after run 1   : 5b0040ac8a430195b38d077b3d604017f452bc80    <- migration fired here
after run 2   : 5b0040ac8a430195b38d077b3d604017f452bc80    <- identical to run 1
```

  The migration is idempotent (`analysis_options_migration.dart:67-69`), so after it fires once the file is stable forever. Checksum(after run 1) == checksum(after run 2) holds for a *mutated* committed file exactly as it holds for a correct one. `01-plan.md:104` asserts this comparison "is the only proof that matters, since it demonstrates the migration found nothing to add" — that inference is false; it demonstrates only that the migration has already run. The same defective condition is the sole guard on `example/analysis_options.yaml` at `01-plan.md:43`.
- Why it matters: AC-006 is the only criterion guarding the pre-migrated state, and that state is the entire fix carried into this plan. As written the criterion passes a tree whose committed options files were rewritten by the first `flutter pub get`, which is the failure mode it exists to catch. An uncheckable criterion silently passes everything.

### F-002 — AC-002's negative case predicts a failure at stage 1 that cannot occur, because stage 1 needs only `python3`

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:15` (AC-002, column 4); stage order fixed at `01-plan.md:67`
- Criterion affected: AC-002
- Observation: the negative case states that with the preflight removed and `PATH` set to `/usr/bin:/bin`, "the run now reaches stage 1 and fails there with a shell 'command not found' message". Stage 1 is `python3 tools/lint_wiki.py` (`01-plan.md:67`), and `/usr/bin/python3` exists on this machine:

```
$ env -i PATH=/usr/bin:/bin sh -c 'command -v python3'
/usr/bin/python3
$ env -i PATH=/usr/bin:/bin HOME=$HOME sh -c 'python3 tools/lint_wiki.py; echo "stage1_exit=$?"'
lint_wiki: clean (0 warning(s)).
stage1_exit=0
```

  Stage 1 passes and prints its stage line; the first `command not found` occurs at stage 2 (dependencies). The mutation still produces *a* failure, but not the one the criterion tells the checker to observe.
- Why it matters: the criteria file freezes at implement start. An implementer who runs the stated mutation observes something other than the stated outcome and must either record a false observation or open a validation round to amend a frozen criterion.

### F-003 — Step 1's `.gitignore` work is implemented by no criterion

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:33`; no matching row in `02-criteria.md:14-50`
- Criterion affected: none
- Observation: step 1 adds ignore entries for both `build/` and `.dart_tool/` directories and both `pubspec.lock` files, and its completion condition is `git check-ignore -v`. No acceptance criterion mentions `.gitignore` or a lock file:

```
$ grep -n -o -i -E ".{0,30}(gitignore|lock).{0,20}" wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md
15:atus. | Remove the preflight block from the script and
49:n under five minutes of wall-clock time. | Run the scr
61:tform other than web, and any lock file being committe
```

Line 15 matches the word "block" and line 49 matches "wall-clock"; neither concerns `.gitignore` or a lock file.

  The only mention is in "Explicitly not required" at `02-criteria.md:61`, which forbids committing a lock file but does not require the ignore entries that keep it uncommitted. AC-028 (`:41`) checks that eight paths are tracked; nothing checks that build output and lock files are *not* tracked.
- Why it matters: `example/build/` is produced by the build stage on every run. If the ignore entries are wrong or missing, the first commit after a check run carries build output and both lock files into the repository, and no criterion in the frozen set fails.

### F-004 — The secret-scan scope is stated three different ways; the criterion's negative case exercises only the narrowest

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:41` (step 5: "scans the **Dart sources** under `lib/`, `example/lib/`, `tools/` and `.github/`") versus `01-plan.md:71` (Interfaces: "fails if **any file** under `lib/`, `example/lib/`, `tools/` or `.github/` contains any of the fixed literal markers") versus `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:50` (AC-032: "any **tracked file** under `lib/`, `example/lib/`, `tools/` or `.github/`")
- Criterion affected: AC-032
- Observation: `tools/` and `.github/` contain no Dart sources at all (they hold `lint_wiki.py`, `check.sh` and `checks.yml`), so under step 5's wording the scan of those two directories inspects nothing, while under the Interfaces and AC-032 wording it inspects shell, Python and YAML. AC-032's negative case plants the marker in `example/lib/main.dart`, a Dart file, so it fires identically under either reading and never discriminates between them.
- Why it matters: the implementer has to pick one scope with no way to decide from the plan, and the criterion cannot tell the two apart afterwards. The narrow reading leaves a credential pasted into `.github/workflows/checks.yml` — the single most likely place for one — unscanned, with a green check suite.

### F-005 — The full-suite command literal is never fixed, while AC-025 requires character-for-character identity between two files written in different steps

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:73` ("the full suite is the check script invoked through the shell", "runs the full-suite command verbatim"), steps 9 (`:49`) and 10 (`:51`); `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:38` (AC-025)
- Criterion affected: AC-025
- Observation: the plan names the command only descriptively. `bash tools/check.sh`, `sh tools/check.sh`, `./tools/check.sh` and `tools/check.sh` all satisfy "the check script invoked through the shell", and step 7 (`:45`) makes the script executable and root-relative, so all four would run. Step 9 writes the string into `AGENTS.md`; step 10 writes it into the workflow. AC-025 then demands the two be identical "character for character".
- Why it matters: this is the one naming choice the plan leaves to the implementer that a criterion tests for exact equality, and it is written twice, in two steps, into two files. Deciding it in the plan costs one sentence; leaving it open costs a validation round if the two differ by a prefix.

### F-006 — Step 10's completion condition requires a push to the remote and names no authorizer

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:51` ("a pushed branch shows both jobs green"), acknowledged at `:90`; `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:39` (AC-026, "read a completed run's package-job log")
- Criterion affected: AC-026
- Observation: the plan explicitly accepts the cost at `:90` — the branch, its Actions run and its logs stay in the remote's history until someone deletes the branch, and a local revert does not remove them. It does not say who authorizes that push. `AGENTS.md` and the repository's operating rules require explicit user consent for a push; `.github/workflows/checks.yml:4-5` triggers on `branches: ["**"]`, so any pushed branch spends CI minutes immediately. Note this is a *normal* push, not the deliberately-broken push the earlier criteria required — AC-026's method (`02-criteria.md:39`) and `01-plan.md:102` correctly avoid that, and AC-024 (`:37`) is a pure file read needing no push, so the CI-independence criterion is literally constructible as written.
- Why it matters: a step whose completion condition cannot be met without an action the implementer is not authorized to take stalls mid-implementation, and the plan gives no named owner to unblock it.

### F-007 — `lib/src/interop/document_model_context.dart` is created, used by nothing, and checked by nothing

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:39` (step 4 creates it), `:13` and `:65` (its purpose and the transport's actual detection mechanism); no criterion in `02-criteria.md` names it
- Criterion affected: none
- Observation: `:65` specifies that the web transport records presence "using the presence check from `dart:js_interop_unsafe`" and "never reads the `modelContext` value". The interop file's whole content is an extension declaring an external `modelContext` member on `package:web`'s `Document`. Nothing in the plan imports it, and my reproduction confirms the presence check compiles and analyzes cleanly without it (`web.document.has('modelContext')` needs only `dart:js_interop_unsafe`). AC-021 (`02-criteria.md:34`) checks `transport_web.dart`'s source text; no criterion mentions the interop file.
- Why it matters: the plan introduces an unreferenced file with an unchecked contract into `lib/`, published surface area for a future work item, and the check suite cannot tell whether it is right, wrong or empty. Either a step needs it wired in or a criterion needs to pin it.

### F-008 — Step 4's completion condition is falsified by step 5

- Severity: NIT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:39` ("the only file in the package naming either implementation file is the selector") against `:41` (`test/transport_web_source_test.dart` "reads `lib/src/transport/transport_web.dart` as text")
- Criterion affected: none
- Observation: the source-text test necessarily names `transport_web.dart` by path, so after step 5 the step-4 condition is false as literally worded. It is true at the moment step 4 completes.
- Why it matters: only if the implementer re-checks step 4's condition at the end of implementation, which the plan does not ask for. Phrasing.

### F-009 — The stated reason for omitting `repository` from the manifest does not follow from the plan's own rooting decision

- Severity: NIT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:57` ("this repository's own `origin` remote resolves to a general agent-workflow scaffold repository, not a location dedicated to this package, so writing that URL into the manifest would record a wrong fact")
- Criterion affected: none
- Observation: `git remote -v` gives `origin https://github.com/ortal83cohen/project-AI-skeleton`. The characterization of that repository as a general agent-workflow scaffold is fair — `README.md:1` reads "# Agent workflow scaffold". But `01-plan.md:9` roots the package at this repository's root, which makes this remote the place the package's source actually lives; pub's `repository` field records where the source is, not whether the repository is dedicated to one package. The omission itself is fine and is explicitly out of scope (`02-criteria.md:59`, `01-plan.md:96`); only the "would record a wrong fact" justification is unestablished.
- Why it matters: nothing in this work item. Flagged so the publishing work item does not inherit "the origin URL is wrong" as a settled premise when the real reason is that the field is deferred.

### F-010 — The format stage does not cover `example/test/`, which the analysis stage does cover

- Severity: NIT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:67` (format over "exactly the three paths `lib`, `test` and `example/lib`") against `:69` (analysis covers `example/test/`) and `:43` (step 6 creates `example/test/example_tools_test.dart`)
- Criterion affected: none (AC-004 at `02-criteria.md:17` matches the narrower scope)
- Observation: the one Dart file under `example/test/` is analyzed but never format-checked, so formatting drift there is invisible to the suite.
- Why it matters: cosmetic and consistent between the plan and AC-004; noted only because the exclusion looks accidental rather than argued.

## Recurrence check

- Previous round: `wiki/work/0003-flutter-webmcp-skeleton/validation/plan-review-01.md` (read only after the findings above were fixed, solely for this section)
- Recurring findings: none materially identical
- Oscillating: no — but see the proximity notes below

Three of this round's findings land on cells that round 1 also flagged. None is the same defect, and each of round 1's is verifiably closed:

- Round 1 F-001 (BLOCKER, AC-006): the claim was that the check script itself triggers the rewrite and the analyzer-binary choice was the wrong axis. **Closed** — I reproduced the pre-migrated file surviving two `flutter pub get` runs byte-identically, and read the SDK source that makes it so. This round's F-001 is a different defect on the same criterion: the *verification method* cannot detect the mutation. Second consecutive finding against AC-006, though not the same one. If round 3 produces a third AC-006 finding, escalate rather than iterate.
- Round 1 F-005 (IMPORTANT, AC-002): the mutation did not achieve its own precondition. **Closed** — `/usr/bin:/bin` resolves neither `flutter` nor `dart`, as I confirmed. This round's F-002 is about the *predicted failure point* being wrong for a different reason (`python3` is present). Same cell, different mechanism; this is the closest thing to a recurrence in this report and is the one to watch.
- Round 1 F-011 (IMPORTANT, deliberately-broken push): **closed** — `02-criteria.md:39` and `01-plan.md:102` now check the pin by reading the workflow and a prior run's log. This round's F-006 is the residual and much weaker point that a normal push is still required with no named authorizer.

Round 1's other findings are closed and were re-verified where checkable: F-003 (package name settled and pub.dev-verified — HTTP 404 confirmed today), F-004 (step 1 rewritten, FVM channel premise corrected), F-006 (`repository` field removed), F-007 (AC-005 now exercises an info-severity diagnostic — reproduced above), F-008 (AC-027/028 check the working tree), F-009 (AC-021 and `transport_web_source_test.dart` added), F-010 (AC-030 now implemented by step 9), F-012 (AC-017's negative split into two mutations).

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 (BLOCKER) | plan — the defect is in `02-criteria.md`'s check method and its three restatements in `01-plan.md`; the criterion must be re-specified before the criteria freeze, not worked around in implementation |
| F-002 | plan — criteria artifact |
| F-003 | plan — a missing criterion, not a missing step |
| F-004 | plan — contradiction between step 5, the Interfaces section and AC-032 |
| F-005 | plan — undecided shared naming choice |
| F-006 | plan, with human escalation for the push authorization |
| F-007 | plan — either a step wires the file in or a criterion pins it |
| F-008, F-009, F-010 | plan — phrasing, never blocking |

No finding routes to research: every claim the plan carries from `00-research.md` that this review touched was verified directly against the Flutter SDK source or reproduced on this machine, and all held.
