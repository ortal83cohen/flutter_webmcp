# Plan review — round 03

- Work item: 0003-flutter-webmcp-skeleton
- Reviewed artifact: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md` and `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md` (untracked working tree, `git status --porcelain` reports `?? wiki/work/0003-flutter-webmcp-skeleton/`)
- Reviewer: plan validator (adversarial, blind)
- Date: 2026-09-05

## Verdict

**FAIL**

Two blockers, and both are the unrepaired residue of findings already raised in round 02 — the AC-006 check method survives verbatim in the plan's own steps and verification section (including the quoted phrase round 02 named), and the format-path fix was applied to the check stage but not to the documented command it contradicts — so this is the third round with the same two defects live and the loop is oscillating, not converging.

## Verification performed

Every claim below was produced by a command run during this review. Nothing is taken from the plan's own assertions.

### Wiki lint and the prose-only rule

```
$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).
exit=0

$ grep -n '```' wiki/work/0003-flutter-webmcp-skeleton/01-plan.md
grep exit=1 (1 = none found)
$ grep -n '^~~~' wiki/work/0003-flutter-webmcp-skeleton/01-plan.md
exit=1
```

`tools/lint_wiki.py:340` (`check_plan_is_prose`) walks `wiki/work/*/01-plan.md` off the filesystem, so it scanned this untracked work item. No fenced code block, no tilde fence. The prose-only rule is satisfied.

### Toolchain and repository state

```
$ flutter --version
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Tools • Dart 3.13.0 • DevTools 2.60.0
$ dart --version
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"
```

Both binaries resolve to Dart 3.13.0, and the channel is `[user-branch]`, not `stable` — exactly what step 1 (`01-plan.md:33`) anticipates. Claim confirmed.

```
$ git remote -v
origin	https://github.com/ortal83cohen/project-AI-skeleton (fetch)
origin	https://github.com/ortal83cohen/project-AI-skeleton (push)
```

Matches the URL quoted at `01-plan.md:57`.

```
$ grep -n "^# " README.md
1:# Agent workflow scaffold
$ grep -n -i "third-party" README.md
36:**Cursor** reads `AGENTS.md` natively. To also pick up the skills and subagents in `.claude/`, enable **Cursor Settings → Rules, Skills, Subagents → include third-party plugins, skills and other configs**. ...
$ grep -n "^jobs:\|^  [a-z_-]*:" .github/workflows/checks.yml
8:jobs:
9:  wiki:
$ wc -l AGENTS.md
      69 AGENTS.md
```

One level-one heading in `README.md`, the ADR-referenced Cursor sentence present at `README.md:36`, exactly one CI job (`wiki`), and `AGENTS.md` at 69 lines against AC-030's 200-line ceiling. Every repository-state claim in the plan checks out.

```
$ curl -s -o /dev/null -w "HTTP %{http_code}\n" https://pub.dev/api/packages/webmcp_pilot
HTTP 404
```

`01-plan.md:9`'s package-name claim confirmed independently.

```
$ grep -n -A3 "^environment" ~/.pub-cache/hosted/pub.dev/web-1.1.1/pubspec.yaml
6:environment:
7-  sdk: ^3.4.0
```

`01-plan.md:57`'s "never below 3.4 because `package:web` requires it" confirmed.

### AC-002 — the minimal-PATH prediction

```
$ env PATH=/usr/bin:/bin sh -c 'command -v flutter; echo "flutter rc=$?"; command -v dart; echo "dart rc=$?"; command -v python3; echo "python3 rc=$?"'
flutter rc=1
dart rc=1
/usr/bin/python3
python3 rc=0
```

`PATH=/usr/bin:/bin` resolves `python3` but neither `flutter` nor `dart` on this machine. AC-002's revised negative case (`02-criteria.md:15`) — preflight removed, stage 1 wiki lint passes on `python3` alone, failure surfaces at stage 2 which needs `flutter` — is accurate and injectable. **Sound.**

### AC-006 — reproduced in both directions

First, the mechanism in the SDK. `AnalysisOptionsMigration` at
`~/fvm/default/packages/flutter_tools/lib/src/migrations/analysis_options_migration.dart:39-47` holds exactly the seven entries the plan lists; `:58-63` sets `needsMigration` if any is absent; `:67-69` returns early otherwise; `:71-73` prints the notice; `:85-92` appends only the missing entries and rewrites. It runs at `project.dart:428-431`, *before* the `isPlugin || !anyPlatformEnabled` early return at `:442`, so it fires for a plain library package with no platform folders. `flutter_command.dart:1983` reaches it via `regeneratePlatformSpecificToolingIfApplicable`. Every mechanical claim at `01-plan.md:19` is correct.

Then the empirical reproduction the review was asked for, on a probe package with a Flutter dependency:

```
--- complete 7-entry list, one `flutter pub get` ---
checksum BEFORE any flutter command: 1592a23f6c0e51762088d10ee39ea670112425de
Changed 24 dependencies!
checksum AFTER first run:            1592a23f6c0e51762088d10ee39ea670112425de

--- same file with `ios/**` removed, one `flutter pub get` ---
checksum BEFORE:  61d49dce9feb66010044387d00db4d30dd00ce1d
Resolving dependencies...
Got dependencies!
Upgrading analysis_options.yaml to exclude build and platform directories.
checksum AFTER first run: 328e94590e3083d471c8361359eaaf1f13d676c3

--- a second `flutter pub get` on that same healed file ---
Got dependencies!
checksum AFTER second run: 328e94590e3083d471c8361359eaaf1f13d676c3
```

AC-006 as written in `02-criteria.md:19` is **sound**: committed-checksum versus after-first-run-checksum separates the two cases (equal vs. different). The third block is the load-bearing observation for finding F-001 below — run-one and run-two checksums are byte-identical (`328e9459…` twice) on a file that *was* incorrectly incomplete and *was* mutated.

The same migration also fires for the nested example package:

```
$ (cd probe/example && flutter pub get)
Got dependencies!
Upgrading analysis_options.yaml to exclude build and platform directories.
before: 5c20a6a56dfb1da9ec11bb15c8ca0f8b6045a688
after:  023d07b135a3d901a242e2b31196c6e520e8f2fb
```

### AC-005 and AC-007 — reproduced on a structural probe

A probe replicating the planned layout (root package + `lib/src/`, nested `example/` with its own manifest and options file, a bad file under `example/build/`), one `dart analyze` from the root:

```
$ dart analyze --fatal-infos --fatal-warnings
Analyzing probe...

warning - example/lib/main.dart:2:9 - The value of the local variable 'unusedLocal' isn't used. ... - unused_local_variable
   info - lib/src/webmcp.dart:6:7 - Missing documentation for a public member. ... - public_member_api_docs

2 issues found.
exit=2
```

Three things this establishes, all of which AC-005 (`02-criteria.md:18`) depends on: one root-level `dart analyze` does reach the nested `example/` package; `public_member_api_docs` *does* fire inside `lib/src/` (it is not restricted to the public-facing library); and `--fatal-infos` makes the info fatal. The file under `example/build/` is absent from the report, so AC-007's positive case holds. **Both sound.**

The non-obvious risk in AC-007 is whether the root file's redundant `example/build/**` entry masks the negative case. It does not:

```
--- build/** removed from example/analysis_options.yaml ONLY;
--- root analysis_options.yaml:12 still contains "example/build/**"
$ dart analyze --fatal-infos --fatal-warnings
  error - example/build/bad.dart:2:3 - The function 'thisIdentifierDoesNotExist' isn't defined. ... - undefined_function
warning - example/lib/main.dart:2:9 - ...
   info - lib/src/webmcp.dart:6:7 - ...
3 issues found.
exit=3
```

AC-007's negative case is genuinely injectable, and `01-plan.md:69`'s claim that the example's own options file is the entry that actually governs is confirmed.

### AC-004 — the formatter names the file

```
$ dart format --output=none --set-exit-if-changed lib
Changed lib/src/ugly.dart
Formatted 3 files (1 changed) in 0.01 seconds.
exit=1
```

Check-only mode names the offending file and exits non-zero, as AC-004 (`02-criteria.md:17`) requires. **Sound.**

### The removed interop file

```
$ grep -n -i -e "document_model_context" -e "interop" 01-plan.md 02-criteria.md
02-criteria.md:32 (AC-019, "no browser interop file shall be loaded" — generic, not this file)
01-plan.md:13, :29, :39, :65 (all state the file is deliberately absent)
```

No dangling reference to `lib/src/interop/document_model_context.dart` survives anywhere in either artifact. The mechanism is also coherent:

```
$ grep -n "extension\|bool has(" $DARTSDK/lib/js_interop_unsafe/js_interop_unsafe.dart
33:extension JSObjectUnsafeUtilExtension on JSObject {
36:  bool has(String property) => hasProperty(property.toJS).toDart;

$ grep -n "^extension type Document\b" ~/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/dom/dom.dart
1340:extension type Document._(JSObject _) implements Node, JSObject {
$ grep -n "external Document get document" ~/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/dom/dom.dart
1317:external Document get document;
```

`has(String)` is an extension on `JSObject`; `Document` implements `JSObject`; `document` is a top-level getter. A string-keyed presence check against `document` needs no typed `external` getter. **Sound — the file was correctly removed, not merely deleted.**

### AC-025 — the full-suite literal

```
$ grep -n -e "check\.sh" -e "check script" -e "full suite" -e "full-suite" 01-plan.md 02-criteria.md
```

`bash tools/check.sh` appears as the fixed literal at `01-plan.md:49`, `:51` and `:73`, and in AC-025 at `02-criteria.md:38`. No stale competing phrasing survives. The two remaining bare mentions of `tools/check.sh` (`01-plan.md:15`, `:102`; `02-criteria.md:14`, `:50`) refer to the script as a file, not to the documented command literal, and do not make AC-025 ambiguous. **Sound.**

### Criterion coverage sweep

Every `AC-NNN` maps to at least one step: AC-001–005 to step 7 (`:45`); AC-006 to steps 2 and 6 (`:35`, `:43`); AC-007/008/022/023 to step 6; AC-009–016 to steps 3 and 5 (`:37`, `:41`); AC-017/018/020/032 to step 5; AC-019/021 to steps 4 and 5; AC-024/026 to step 10 (`:51`); AC-025 to steps 9 and 10; AC-027/028/030 to step 9 (`:49`); AC-029 to step 2; AC-031 to step 11 (`:53`, but see F-003); AC-033 to step 1 (`:33`). No step is orphaned: every one of the eleven serves at least one criterion. `02-criteria.md` has 33 criteria and `tools/lint_wiki.py:353-360`'s vague-term scan is clean; a manual sweep for `reasonable`, `sensible`, `suitable`, `should`, `etc.` returned only AC-009's "a valid tool", whose validity rule is pinned precisely by AC-012 and `01-plan.md:63`.

Parallelism: there is no `03-tasks.md` in this work item, so there are no parallel markers to cross-check.

## Per-criterion results

Not applicable — the rubric reserves the per-criterion table for implementation reviews. The coverage sweep above stands in its place, and criteria whose construction was individually reproduced (AC-002, AC-004, AC-005, AC-006, AC-007) are reported under Verification performed.

## Findings

### F-001 — The plan's own steps and verification section still specify the run-versus-run comparison that AC-006 explicitly forbids, and still call it "the only proof that matters"

- Severity: BLOCKER
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:35` (step 2), `:43` (step 6), `:104` (Verification approach); contradicts `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:19` (AC-006)
- Criterion affected: AC-006
- Observation: AC-006 was rewritten correctly and now compares the committed blob's checksum against the checksum after exactly one dependency-stage run, with an explicit warning in its own negative-case cell: "the comparison must be committed-state versus after-first-run, never run-versus-run — a mutation that fires once and then stabilizes is invisible to a run-versus-run comparison." The plan was not brought into line. Step 2's completion condition (`:35`) still reads "a second `flutter pub get` run leaves the file's checksum unchanged". Step 6's (`:43`) still reads "a second dependency-resolution run leaves `example/analysis_options.yaml`'s checksum unchanged". The Verification approach (`:104`) still reads "checked by running the dependency stage twice in direct succession and confirming each file's checksum is unchanged between the two runs, which is the only proof that matters, since it demonstrates the migration found nothing to add rather than merely asserting the list is present once." My reproduction above shows that last sentence is affirmatively false: on a file that was committed incomplete and *was* rewritten by the migration, run one and run two both hash to `328e94590e3083d471c8361359eaaf1f13d676c3`. Run-versus-run stability demonstrates nothing about whether the migration found something to add. Step 2's second clause does not rescue it either — "contains all eight exclusion entries" is evaluated after the first run has already re-added anything missing, so it is true of a broken commit too.
- Why it matters: the verify phase follows the plan, not the criteria cell's parenthetical. An implementer executing step 2 and step 6 as written, and a verifier following `:104`, would both record a green result for AC-006 on evidence that provably cannot distinguish the passing case from the failing one. This is the exact failure mode the criteria are meant to prevent — an uncheckable check that silently passes everything — and the plan asserts it is the *only* proof that matters, which will actively steer the verifier away from the correct comparison AC-006 specifies.

### F-002 — The documented format command covers "the three source paths" while the format stage it is supposed to mirror covers four, and the three are never enumerated

- Severity: BLOCKER
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:73` ("format is the Dart formatter over the three source paths"), contradicting `:67` ("over exactly the four paths `lib`, `test`, `example/lib` and `example/test`"); consumed by step 9 at `:49`
- Criterion affected: AC-030 (the `## Checks` section must name a format command), adjacent to AC-004
- Observation: the Check stages paragraph fixes the format stage at four paths. The Documented commands paragraph, six lines later, describes the format command a developer is told to run as covering "the three source paths". No list of three paths exists anywhere in the plan — the analysis scope at `:69` also names four (`lib/`, `test/`, `example/lib/`, `example/test/`). Step 9 (`:49`) instructs the implementer to write "the four commands from the Interfaces section" into `AGENTS.md`, so the implementer must type a format command whose path list the plan states two different ways and enumerates only in the version it is not pointing at.
- Why it matters: the step cannot be executed without asking which three, so it fails the granularity bar outright. Worse, if the implementer resolves it by taking `:73` literally, the documented command and the enforced stage diverge permanently: a developer formats three directories, the fourth drifts out of shape, and the check suite fails at stage 3 on a directory the documented command never touched. This is an undecided shared choice sitting in the one paragraph whose entire purpose is to fix command strings character for character.

### F-003 — AC-031's time budget is measured by step 11 but satisfied by no step, and step 11 is explicitly complete whether or not the budget is met

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:53` (step 11, "the warm run's elapsed time is recorded whether or not it meets the budget stated in the criteria"); criterion at `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:50`
- Criterion affected: AC-031
- Observation: AC-031 is a hard assertion — the warm run "shall complete in under five minutes of wall-clock time". Step 11 measures the figure and then declares itself complete regardless of the result. No other step constrains the suite's duration, the Risks table (`:79-84`) has no row for the suite exceeding its budget, and the plan states no response if it does.
- Why it matters: a criterion with a measuring step but no satisfying step and no failure response is a criterion that cannot fail the work item. Either AC-031 is a real gate — in which case step 11's completion condition contradicts it and the plan owes a mitigation — or it is a recorded observation, in which case it should not be phrased as a "shall".

### F-004 — Step 9 must write a `LICENSE` whose copyright holder the plan never names

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:49` (step 9 creates `LICENSE`); risk row at `:83`; escalation note at `:92`; criterion at `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:41` (AC-028 requires `LICENSE` to exist and be tracked)
- Criterion affected: AC-028
- Observation: the licence *type* is decided — MIT, named at `:83`. The copyright holder is not. `:83` says "The MIT licence and its copyright line are proposed here", but no copyright line appears at `:83`, in the Interfaces section (`:57-73`), or anywhere else in the plan. `:92` correctly escalates the item to a human. Step 9 nonetheless has no gate on that answer arriving, and AC-028 requires the file to exist.
- Why it matters: the implementer reaches step 9 and must either invent a copyright holder — which `AGENTS.md`'s non-negotiables forbid — or stop and ask, which is the question the plan was supposed to have answered. The escalation is correctly identified; it is simply not wired into the step that depends on it.

### F-005 — AC-026's second half cannot be verified without a push whose authorization the plan defers to a decision it does not own, with no stated fallback

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:51` (step 10's completion condition); acknowledged at `:90`; criterion at `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:39` (AC-026)
- Criterion affected: AC-026
- Observation: step 10 now says the pushed-branch check happens "once the implementer performing this step has explicitly decided to push, since this repository's standing rule requires a person's explicit go-ahead for every push and this plan does not grant a standing exception". Two problems. First, the rule is attributed to "this repository", and it is not written there — a repository-wide search found no such rule outside this plan itself:

```
$ grep -rn -i -e "git push" -e "explicit consent" -e "go-ahead" --include="*.md" --include="*.mdc" --include="*.yml" . | grep -v "^./wiki/work/"
(no matches)
```

  The rule is real as an operating constraint on the agent, but sourcing it to the repository is unverifiable as stated, and `AGENTS.md`'s non-negotiables are explicit that an unverified fact is marked, not asserted. Second, the sentence assigns the decision to "the implementer", while the same sentence requires "a person's explicit go-ahead"; in this pipeline the implementer is an agent, so the two halves name different deciders. AC-026's first half (one version literal in the file) is a pure file read, but its second half — "when a completed run's package-job log is read, the printed resolved-version line shall contain that same literal" — has no path to verification without the push, and the plan states no fallback if the go-ahead is withheld.
- Why it matters: a criterion whose verification depends on a human decision the plan cannot make needs a stated alternative, or the verify phase stalls on a criterion it cannot close. The safety instinct here is right; the wiring is incomplete.

### F-006 — AC-033 is numbered out of sequence relative to the table it sits in

- Severity: NIT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:44` (AC-033, last row of the functional table) versus `:50-51` (AC-031 and AC-032 in the non-functional table)
- Criterion affected: none
- Observation: AC-033 was appended to the functional table after AC-030, so reading the document top to bottom yields 001–030, 033, then 031, 032.
- Why it matters: cosmetic only. Worth a line when the criteria are frozen, so a reader scanning for a gap at 031/032 does not conclude a criterion was dropped.

## Recurrence check

- Previous round: `wiki/work/0003-flutter-webmcp-skeleton/validation/plan-review-02.md` (CONDITIONAL, 1 BLOCKER + 6 IMPORTANT + 3 NIT)
- Recurring findings: **F-001 and F-002**
- Oscillating: **yes**

F-001 is materially identical to round 02's F-001, whose heading reads "AC-006's check method cannot distinguish a migrated file from an unmigrated one; the plan repeats the same method three times and calls it 'the only proof that matters'". The criteria half of that finding was closed correctly and I re-verified it empirically. The plan half was not touched: `01-plan.md:35`, `:43` and `:104` still carry the method, and `:104` still carries the quoted phrase the previous round called out by name. This is the same defect, in the same work item, in the same three locations, for a second consecutive round.

F-002 is the direct residue of round 02's F-010 ("The format stage does not cover `example/test/`, which the analysis stage does cover"). That fix was applied at `01-plan.md:67` and not at `:73`, converting a coverage gap into an internal contradiction. Same cell, second consecutive round, defect not converged.

The remaining round-02 findings were independently re-verified as genuinely closed: F-002 (AC-002's stage-1 prediction — confirmed by the PATH probe above), F-003 (AC-033 now exists at `02-criteria.md:44`), F-004 (scan scopes unified at `01-plan.md:71` and AC-032), F-005 (the `bash tools/check.sh` literal, grep above), F-007 (`document_model_context.dart` removed with no dangling reference, and the replacement mechanism verified against `dart:js_interop_unsafe` and `package:web`), F-008 (`:39` now scopes the condition to `lib/`), F-009 (`:57` now gives the publishing-decision reason).

This is round 3 of a 3-round budget, and two findings recur. Per `wiki/conventions/validation-rubrics.md:57-59`, the correct action is not a fourth round — it is to stop and escalate to a human. Both recurring defects are small, mechanical text edits with a single unambiguous correct form, which is itself the signal worth escalating: they were identified precisely, partially applied, and the unapplied half went unnoticed twice.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan — the criteria are correct; three plan sentences contradict them and must be brought into line before implementation reads them |
| F-002 | plan — a shared command string is stated two ways and never enumerated; only the plan can settle it |
| F-003 | plan — either the step's completion condition or AC-031's phrasing must move; a criteria change requires a recorded round |
| F-004 | plan, with human escalation — the copyright holder is a person's decision, not the implementer's |
| F-005 | plan, with human escalation — the push authorization and AC-026's fallback both need a person |
| F-006 | plan — cosmetic, fold into whichever edit closes the blockers |

Recommended action: **escalate to a human rather than opening round 4.** The round cap is exhausted and two findings have now survived a repair round each.
