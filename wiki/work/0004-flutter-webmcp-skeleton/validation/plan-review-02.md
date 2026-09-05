# Plan review — round 02

- Work item: 0004-flutter-webmcp-skeleton
- Reviewed artifacts: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md`, `wiki/work/0004-flutter-webmcp-skeleton/02-criteria.md`, `wiki/work/0004-flutter-webmcp-skeleton/03-tasks.md` (working tree at `663cf48`, tree clean)
- Reviewer: plan validator (blind — criteria + artifacts + repository only)
- Date: 2026-09-05

## Verdict

**PASS**

Zero blockers: every one of AC-001 through AC-033 has an implementing step and an owning task, every step serves at least one criterion, no step or criterion is uncheckable, the plan contains no fenced code, no task is marked `[P]` and no two tasks own the same file, and every load-bearing factual claim I could execute against the toolchain (Flutter 3.47.0, `AnalysisOptionsMigration`'s seven-entry check and idempotence, single-root `dart analyze` reaching the nested `example/` package, `dart:js_interop_unsafe`'s `has`/`hasProperty`, the minimal-`PATH` premise, the pub.dev name) reproduced exactly as written; five `IMPORTANT` findings remain and should be closed or recorded with an owner before the implement phase starts.

## Verification performed

### 1. Fenced code blocks in the plan, and wiki lint

```
$ python3 tools/lint_wiki.py; echo "EXIT=$?"
lint_wiki: clean (0 warning(s)).
EXIT=0

$ grep -n '```' wiki/work/0004-flutter-webmcp-skeleton/01-plan.md; echo "fences exit=$?"
fences exit=1

$ grep -rn "fence" tools/lint_wiki.py
tools/lint_wiki.py:41:FENCE = re.compile(r"^\s*(```|~~~)")
tools/lint_wiki.py:357:  f"{rel(plan)}:{lineno}: fenced code block in a plan. Plans are prose "
```

The linter does check plans for fences, and the plan has none. No finding.

### 2. The pinned Flutter version literal (`01-plan.md:35`)

```
$ flutter --version
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
Tools • Dart 3.13.0 • DevTools 2.60.0

$ flutter --version --machine | head -3
  "frameworkVersion": "3.47.0",
  "channel": "[user-branch]",
  "flutterRoot": "/Users/ortalcohen/fvm/versions/3.47.0"

$ fvm list           (excerpt)
│ 3.47.0 │ stable │ 3.47.0 │ 3.13.0 │ Aug 12, 2026 │ ● │
```

`3.47.0` is the exact installed release, it is a real *stable* release (so step 10's "Flutter stable SDK at one pinned version literal" is installable in CI), and `01-plan.md:33`'s note that a non-`stable` channel label is expected on this machine matches the observed `[user-branch]` (FVM). The claim at `01-plan.md:35` is true. No finding.

### 3. `AnalysisOptionsMigration` — source read and reproduced

Source (`/Users/ortalcohen/fvm/versions/3.47.0/packages/flutter_tools/lib/src/migrations/analysis_options_migration.dart:39-69`) lists exactly the seven entries the plan names, sets `needsMigration` only when one is missing, and returns before printing/writing otherwise. Invocation is `project.dart:428-431` inside `ensureReadyForPlatformSpecificTooling`; `flutter pub get` reaches it for the root project *and* the example (`commands/packages.dart:400-419`), and `FlutterCommand` defaults `regeneratePlatformSpecificToolingDuringVerify => true` (`runner/flutter_command.dart:2036`). Every sentence of `01-plan.md:19` matches the source.

Empirical check, my own scratch Flutter package with a pre-migrated root (9 entries) and example (8 entries):

```
$ shasum analysis_options.yaml example/analysis_options.yaml     # BEFORE
f709205896ac436e5778a3fc1e73b98caa748f40  analysis_options.yaml
0476067c84b6513b79be7e327998ca8f2e61477a  example/analysis_options.yaml
$ flutter pub get           # once, at the root only
... + web 1.1.1 ... Got dependencies in `./example`.
$ shasum analysis_options.yaml example/analysis_options.yaml     # AFTER
f709205896ac436e5778a3fc1e73b98caa748f40  analysis_options.yaml
0476067c84b6513b79be7e327998ca8f2e61477a  example/analysis_options.yaml
```

AC-006 negative case, injected (`ios/**` removed from the root list, then one `flutter pub get`):

```
409d46763c69dd98f2b6d48b521ad705aab90482  analysis_options.yaml   # before the run
Upgrading analysis_options.yaml to exclude build and platform directories.
f8d1a804e77af2b9fe3bbb0e7ccde12dad993a2c  analysis_options.yaml   # after the run
    - .dart_tool/**
    - ios/**            <- re-added at the end of the list
```

AC-006's committed-vs-after-first-run comparison is the correct check and its negative case fires exactly as `02-criteria.md:19` describes. The idempotence argument at `01-plan.md:35`, `:43` and `:104` is correct: the second run finds all seven present and returns at line 68 of the migration, so a run-versus-run comparison genuinely cannot distinguish a pre-migrated file from a mutated one.

### 4. Does one root `dart analyze` reach a nested `example/` under its own options file?

Fresh scratch tree (root package + nested `example/` package, each with its own `analysis_options.yaml`; root enables `public_member_api_docs`, example has an unused local, `example/build/bad.dart` has an undefined function):

```
$ dart analyze --fatal-infos --fatal-warnings          # baseline
warning - example/lib/main.dart:2:7 - The value of the local variable 'unusedLocal' isn't used. - unused_local_variable
   info - lib/v2root.dart:3:7 - Missing documentation for a public member. - public_member_api_docs
2 issues found.  EXIT=2
```

Both halves of AC-005 are real from a single root invocation: a warning under `example/lib/` and an info under `lib/`, both fatal. `example/build/bad.dart` is silent while the exclusion is present.

AC-007's negative case, injected (`build/**` deleted from `example/analysis_options.yaml`, root's `example/build/**` left in place):

```
  error - example/build/bad.dart:2:3 - The function 'totallyUndeclaredIdentifier' isn't defined. - undefined_function
3 issues found.  EXIT=3
```

This settles the question the plan's "second, redundant `example/build/**` entry in the root file as a safeguard" (`01-plan.md:69`) raises: the root entry does *not* suppress the example's own context, so AC-007's negative case is genuinely injectable.

AC-008's negative case, injected (`publish_to` removed from the example manifest, path dependency kept):

```
warning - example/pubspec.yaml:7:5 - Publishable packages can't have 'path' dependencies. - invalid_dependency
3 issues found.  EXIT=2
```

### 5. AC-002's minimal-`PATH` premise, and shell resolution of `flutter`/`dart`

```
$ /bin/bash -c 'command -v flutter; command -v dart'
/Users/ortalcohen/.local/bin/flutter
/Users/ortalcohen/.local/bin/dart
$ env PATH=/usr/bin:/bin /bin/bash -c 'command -v flutter || echo no-flutter; command -v dart || echo no-dart; command -v python3'
no-flutter
no-dart
/usr/bin/python3
```

Both binaries are real executables on `PATH` (not only zsh aliases), so `tools/check.sh` can call them from a non-interactive shell; and `/usr/bin:/bin` resolves `python3` but neither `flutter` nor `dart`, exactly as `02-criteria.md:15` asserts. The AC-002 negative case therefore reaches stage 1 successfully and fails at stage 2, as written.

### 6. Web-transport API claims (`01-plan.md:13`, `:39`, `:65`)

```
$ grep -n "bool has(\|hasProperty" .../dart-sdk/lib/js_interop_unsafe/js_interop_unsafe.dart
34:  /// Shorthand helper for [hasProperty] ...
36:  bool has(String property) => hasProperty(property.toJS).toDart;
41:  external JSBoolean hasProperty(JSAny property);
$ grep -n "extension type Document" ~/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/dom/dom.dart
1340:extension type Document._(JSObject _) implements Node, JSObject {
```

`document.has('modelContext')` is a real, compiling call with `package:web` 1.1.1 (which resolved during the pub-get run above, confirming the `>=1.1.1` lower bound at `01-plan.md:57`). No typed getter is needed, so the plan's decision to create no interop-extension file is sound.

### 7. Package name (`01-plan.md:9`)

```
$ curl -s -o /dev/null -w "%{http_code}" https://pub.dev/packages/webmcp_pilot   -> 404
$ curl -s -o /dev/null -w "%{http_code}" https://pub.dev/packages/flutter_lints  -> 200   (control)
```

`webmcp_pilot` is unclaimed. Claim true.

### 8. Repository facts the plan depends on

```
$ head -1 README.md
# Agent workflow scaffold
$ grep -n -i "third-party" README.md
36:**Cursor** reads `AGENTS.md` natively. To also pick up ... include third-party plugins, skills and other configs ...
$ grep -rn "Cursor setting" wiki/adr/0002-share-agent-config-between-claude-code-and-cursor.md
69:- Setup instructions in `README.md` name the Cursor setting that must be enabled ...
$ wc -l AGENTS.md            ->  69      (AC-030's 200-line ceiling has headroom)
$ grep -n "Checks" AGENTS.md ->  (no match; step 9 adds the section)
$ git check-ignore -v example/build/web/x.dart ; build/x.dart ; pubspec.lock ; .dart_tool/x.json
rc=1 rc=1 rc=1 rc=1          (no pattern matches today; step 1 is required, AC-033 negative is injectable)
$ cat .github/workflows/checks.yml   ->  one job (`wiki`), no `needs:` key anywhere
```

All of AC-024, AC-027, AC-030, AC-033's premises hold against the real tree.

### 9. `03-tasks.md` structure, ownership and citations

Structure matches `wiki/templates/03-tasks.md`: Legend, Groups, Serialised files, Test tasks, all present, guidance comments removed. Extracted every task row's owned-file list programmatically:

```
DUPLICATE FILES: {}
```

No file is owned by two tasks, and no row carries `[P]`, so there is no parallelism hazard to cross-check. Every AC-001..AC-033 appears in at least one `Satisfies` cell. The citation *accuracy* problems are F-002 below.

### 10. Criteria quality sweep

```
$ grep -niE "correctly|properly|as expected|appropriately" 02-criteria.md ; echo rc=$?
rc=1
```

No uncheckable wording. Every row has a concrete negative-case mutation; I injected AC-005, AC-006, AC-007 and AC-008's and observed the stated failures above, and verified AC-002's, AC-028's (`git ls-files` reads the index, so a working-tree rename is invisible to it) and AC-033's premises by inspection of real tool behaviour.

### 11. Whole-document consistency of shared mechanisms

| Mechanism | Mentions | Agree? |
|---|---|---|
| Root exclusion list = 9 entries | `:35`, `:43`, `:69` | Yes |
| Example exclusion list = 8 entries | `:43`, `:69` | Yes |
| Rationale prose about which file owns which exclusion | `:21` | Loosely — see F-006 (NIT) |
| Flutter version literal `3.47.0`, single source | `:35`, `:51`, AC-026 | Yes |
| Forbidden-import scan scope (`lib/`, `example/lib/`) | `:41`, `:71`, AC-018 | Yes |
| Secret-marker scan scope (`lib/`, `example/lib/`, `tools/`, `.github/`) | `:41`, `:71`, AC-032 | Yes |
| Full-suite literal `bash tools/check.sh` | `:15`, `:49`, `:51`, `:73`, AC-025, tasks 5.1/6.1/6.2 | Yes |
| Six stages, fixed order | `:15`, `:45`, `:67`, AC-001 | Yes |
| CI push not required for step 10 / AC-026 | `:51`, `:90`, AC-026 | Yes — round-1 F-001 is closed |
| LICENSE gate does not stall README/AGENTS/CHANGELOG | `:49` | Yes for AC-025/027/030 — but see F-003 for AC-028 |
| Step 3 ends with transport-shaped unresolved refs only | `:37` | Internally consistent, but contradicts `:39`/`:65` on where `WebMcpTransport` lives — F-001 |

## Findings

### F-001 — Step 3 says `WebMcpTransport` is declared in `lib/src/webmcp_exceptions.dart`; step 4 and the Interfaces section put it in `lib/src/transport/webmcp_transport.dart`

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:37` (against `:39`, `:65`, and `03-tasks.md:27-28`)
- Criterion affected: none directly (AC-017 indirectly)
- Observation: line 37 reads "including the transport types step 4 has not yet created — `WebMcpTransport` and the exception types are declared here in `lib/src/webmcp_exceptions.dart`". Read literally, task 2.1 declares `WebMcpTransport` in the exceptions file, which leaves task 2.2's `lib/src/transport/webmcp_transport.dart` (`:39`, owned exclusively by task 2.2 at `03-tasks.md:28`) with nothing to hold, and the Transport-seam paragraph (`:65`) describes that interface as part of step 4's seam. Read the other way — the reading the same sentence's own completion condition implies, since it expects unresolved references naming "a transport file under `lib/src/transport/`" — `WebMcpTransport` is *not* written in step 3 at all, and line 37's clause is simply wrong about the file. The document supports both readings and states each in a different place.
- Why it matters: the two readings put a public exported type in two different files owned by two different tasks. If task 2.1 takes the literal reading and task 2.2 takes the Interfaces reading, the public library exports the type twice and the export conflict surfaces only when step 4 completes. This is a shared-choice decision the plan is supposed to settle, not the implementer.

### F-002 — `03-tasks.md`'s criteria citations do not line up with the files each task owns

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/03-tasks.md:21`, `:27`, `:28`, `:34`, `:40`, `:53`, `:54`
- Criterion affected: AC-008, AC-020, AC-025, AC-028
- Observation: four mismatches, verified against the owned-file extraction in section 9 above.
  (a) AC-020's behaviour is the transport notification emitted from `unregisterTool` in `lib/src/webmcp.dart` — `02-criteria.md:33`'s negative case deletes exactly that call. That file is owned solely by task 2.1 (`:27`), which cites only "AC-009–AC-017"; AC-020 is cited by task 2.2 (`:28`), which owns only files under `lib/src/transport/` and therefore cannot add the call without violating exclusive ownership. Task 2.1's parenthetical "transport-dependent parts land in 2.2" points at a task that cannot land them.
  (b) AC-025 requires *both* `AGENTS.md`'s literal and the workflow step's literal. `AGENTS.md` is owned by task 6.1 (`:53`, which cites AC-025); `.github/workflows/checks.yml` is owned by task 6.2 (`:54`), which does not cite AC-025.
  (c) AC-028 lists eight paths. Task 6.1 cites it as "(partial)" and owns three of them; the other five (`lib/`, `test/`, `example/`, `pubspec.yaml`, `analysis_options.yaml`) are owned by tasks 1.2, 2.1, 3.1 and 4.1 (`:21`, `:27`, `:34`, `:40`), none of which cites AC-028.
  (d) AC-008 is governed by `publish_to` in `example/pubspec.yaml` (task 4.1, `:40`, which does cite it) but is also cited by task 1.2 (`:21`), which owns only the root manifest and options file.
- Why it matters: `wiki/conventions/naming.md:25` makes the citation the mechanism that proves coverage. Where the citing task cannot touch the governing file, the citation asserts a coverage that the task boundary forbids, and a task-by-task implementer can close every task with a criterion still unimplemented.

### F-003 — AC-028 cannot pass until a human supplies the copyright holder, and `02-criteria.md` gives it no pending state

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:49`; `wiki/work/0004-flutter-webmcp-skeleton/02-criteria.md:41` (contrast `:39`)
- Criterion affected: AC-028
- Observation: the round-1 decoupling holds — step 9's completion condition lists the README diff, `CHANGELOG.md`, the `AGENTS.md` edit and `lint_wiki.py` as one group, and `LICENSE` separately and explicitly "not gating the rest of this step", so AC-025, AC-027 and AC-030 are no longer stalled. AC-028, however, requires `LICENSE` to exist on disk *and* be tracked, and it is written with no conditional half. AC-026 shows the plan knows how to express this: `02-criteria.md:39` carves its second half out in the criterion text itself ("this second half is not required for this work item to be complete ... record this half as pending rather than failing"). AC-028 has no equivalent sentence, so at verification time it will read as a plain failure.
- Why it matters: the licence decision is a legitimate human gate (`01-plan.md:92`), but the criteria document is the frozen contract the implementation validator scores against. An indefinitely-deferred criterion with no recorded pending state either blocks the work item's completion or invites a silent skip — and `02-criteria.md` freezes when the implement phase starts, so this cannot be added later without another recorded round.

### F-004 — Step 5's hygiene test scans `example/lib/`, which step 6 has not yet created, and the missing-directory behaviour is undecided

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:41` (against `:43` and `:71`)
- Criterion affected: AC-018, AC-032
- Observation: step 5 writes `test/repo_hygiene_test.dart`, whose forbidden-import scan "reads the Dart files under `lib/` and `example/lib/` only" and whose secret scan reads "every tracked file ... under `lib/`, `example/lib/`, `tools/` and `.github/`". `example/` is created in step 6 (`:43`), and step 5's completion condition is "`flutter test` at the root exits zero". The plan never says whether a scope directory that does not exist is a failure or a skip, nor whether the scan enumerates via `git ls-files` (the word "tracked" implies it) or a directory walk — and at step 5 nothing is committed yet, so a `git ls-files`-based scan would see none of the new files either.
- Why it matters: the implementer must invent both decisions to finish step 5, and the two obvious choices differ in outcome: "missing directory is a failure" makes step 5 uncompletable until step 6, while "skip silently" makes a scan that walks zero files pass — a vacuous pass no criterion detects, since AC-018 and AC-032's positive checks are satisfied by "zero offending files".

### F-005 — Steps 1, 8, 10 and 11 complete only when evidence is written to "the implementation notes" and "the verification artifact", neither of which names a path or exists as a defined artifact

- Severity: IMPORTANT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:33`, `:47`, `:51`, `:53`, `:104`
- Criterion affected: none
- Observation: four completion conditions and one risk mitigation (`:79`) depend on these two destinations. `wiki/conventions/naming.md:17-18` fixes exactly `00-research.md`, `01-plan.md`, `02-criteria.md`, `03-tasks.md` and `validation/<phase>-review-NN.md` inside a work item; `wiki/conventions/workflow.md`'s Phase 5 says to paste the check-suite output but names no file, and `wiki/templates/` contains no verification or notes template.

  ```
  $ ls wiki/templates/
  00-research.md 01-plan.md 02-criteria.md 03-tasks.md STATE.yaml adr.md validation-report.md
  $ grep -rn "verification artifact\|implementation notes\|04-\|05-" wiki/conventions/ wiki/templates/ wiki/INDEX.md
  (no matches)
  ```
- Why it matters: step 8's and step 11's *only* completion conditions are "both outputs are pasted into the verification artifact". An implementer cannot close either step without inventing a filename, and `03-tasks.md:47` and `:60` give tasks 5.2 and 7.1 no owned file at all, so two tasks would each choose independently.

### F-006 — The rationale paragraph at `:21` describes the root exclusion list differently from the operative lists at `:35` and `:69`

- Severity: NIT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:21`
- Criterion affected: none
- Observation: line 21 says "the root file's own exclusion list is for the root tree, which has no `build/` of its own to exclude beyond what `.gitignore`-style patterns already keep untracked", which reads as though the root list contains neither `build/**` nor `example/build/**`. Lines 35 and 69 both specify nine entries including both of those. The operative statements agree with each other and with step 6; only the rationale is loose.
- Why it matters: low. An implementer following line 21 alone would write eight entries and be caught immediately by step 2's "contains all nine exclusion entries" check.

### F-007 — Two cosmetic defects in `03-tasks.md`

- Severity: NIT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/03-tasks.md:34` and `:69`
- Criterion affected: none
- Observation: task 3.1's `Satisfies` cell reads "AC-009–AC-021, AC-018, AC-032" — AC-018 already falls inside the stated range. The "Serialised files" table at `:69` carries a placeholder row `| — | — |` rather than being left empty under its "No file is touched by more than one task" note.
- Why it matters: none functionally; the duplicate citation is the sort of thing that makes a coverage audit ambiguous.

### F-008 — The check script is called "a POSIX shell script" in one place and "strict-mode shell" in another, invoked as `bash`

- Severity: NIT
- Location: `wiki/work/0004-flutter-webmcp-skeleton/01-plan.md:15` (against `:45`, `:73` and `02-criteria.md:16`)
- Criterion affected: none
- Observation: `:15` says POSIX shell; `:45` says strict-mode shell; the fixed invocation literal is `bash tools/check.sh` (`:73`); AC-003's negative case mutates "the strict-mode setting". Which settings constitute strict mode (`set -eu` is POSIX, `set -o pipefail` is not) is left open.
- Why it matters: low — the invocation literal is `bash`, so pipefail is available either way. Worth one clarifying word so AC-003's negative case names a definite thing to remove.

## Recurrence check

- Previous round: `wiki/work/0004-flutter-webmcp-skeleton/validation/plan-review-01.md` (read only after this round's findings were formed, and only to compare finding sets)
- Recurring findings: none

Round 1's nine findings were re-checked against the current text rather than against the author's claim that they were fixed:

| Round 1 | Status now | Evidence |
|---|---|---|
| F-001 BLOCKER — rollback said the CI push was required | Closed | `:90` now states the push happens only on separate human authorization and that step 10's completion does not require it; agrees with `:51` and AC-026 |
| F-002 — `.dart_tool` exclusion claimed but never written | Closed | `.dart_tool/**` is an explicit entry at `:35`, `:43`, `:69` |
| F-003 — scan scopes differed between `:41` and `:71` | Closed | Both now read `lib/` + `example/lib/` (imports) and the four-directory set (secrets) |
| F-004 — step 3's completion condition unsatisfiable | Closed as stated; a *different* defect now sits in the replacement sentence | See F-001 this round — the new text is about which file declares `WebMcpTransport`, not about whether the condition can be met |
| F-005 — version literal never chosen | Closed and independently verified | `:35` pins `3.47.0`; `flutter --version` confirms |
| F-006 — no `03-tasks.md` | Closed | File exists, matches the template, ownership is exclusive |
| F-007 — LICENSE gate stalled AC-025/027/030 | Closed for those three; AC-028 remains | See F-003 this round |
| F-008, F-009 NITs | Closed | `:35`/`:43` now say "immediately after being authored, before any command touched it"; `:43` spells out eight-vs-nine |

- Oscillating: no. No finding this round is materially identical to one from round 1. Two findings (F-001, F-003) sit on lines that round 1 also touched, but each names a different defect — a fix-side drift, not a repetition — and both are `IMPORTANT`, not blockers. If a third round produces another finding at `01-plan.md:37` or on the LICENSE gate, that would be oscillation and should be escalated rather than iterated.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | Plan — a shared interface decision (which file declares an exported type) must be settled in `01-plan.md` |
| F-002 | Plan — `03-tasks.md` is a plan-phase artifact; correct the citations, not the code |
| F-003 | Plan, with a human escalation attached — AC-028's pending state must be written into `02-criteria.md` before it freezes, and the copyright-holder question put to a human (`wiki/conventions/workflow.md`, "Human gates": a decision with legal impact) |
| F-004 | Plan — the missing-directory and enumeration behaviour is a shared decision `01-plan.md:41`/`:71` must state |
| F-005 | Plan — name the artifact paths, or add the artifact to `wiki/conventions/naming.md` in the same change |
| F-006, F-007, F-008 | Plan — NITs; close opportunistically, never a reason to open a round |
