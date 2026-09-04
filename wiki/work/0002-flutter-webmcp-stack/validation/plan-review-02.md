# Plan review — round 02

- Work item: 0002-flutter-webmcp-stack
- Reviewed artifact: `wiki/work/0002-flutter-webmcp-stack/01-plan.md` against `wiki/work/0002-flutter-webmcp-stack/02-criteria.md`, at git revision 663cf48 (working tree clean)
- Reviewer: plan-validator
- Date: 2026-09-04

## Verdict

**CONDITIONAL**

Every acceptance criterion has an implementing step and the plan is prose-only, but two blockers must close first: the check script's fourth stage rests on a statement about analyzer scope that I ran and disproved, and the `README.md` edit in step 2 is not executable as written against the actual `README.md`.

## Verification performed

Wiki linter (the plan's prose-only rule is machine-enforced by `check_plan_is_prose`, `tools/lint_wiki.py:352`):

```
$ python3 tools/lint_wiki.py; echo "EXIT=$?"
lint_wiki: clean (0 warning(s)).
EXIT=0
```

I also read all 138 lines of `01-plan.md` directly: no fenced block, no snippet, no pseudo-code, no inline code beyond identifier and path names. Section order is goal (`01-plan.md:14`), approach (`:18`), reasoning over alternatives (`:28`), steps with a "Touches" clause in each (`:42`), interfaces and shared decisions (`:70`), risks (`:96`), rollback (`:110`), out of scope (`:114`), verification approach (`:125`) — matching `wiki/templates/01-plan.md` and the order required by `wiki/conventions/workflow.md:55`.

Repository state the plan asserts:

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

```
$ grep -n -i "readme" wiki/adr/0002-share-agent-config-between-claude-code-and-cursor.md
69:- Setup instructions in `README.md` name the Cursor setting that must be enabled, so a missing capability is diagnosable rather than mysterious.
80:- `README.md` — setup, including the Cursor setting.
```

The CI workflow has exactly one job today, so step 12's "add a second job" is accurate:

```
$ grep -n "^jobs:\|^  [a-z]" .github/workflows/checks.yml
8:jobs:
9:  wiki:
```

Toolchain actually installed:

```
$ flutter --version | head -3
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (3 weeks ago) • 2026-08-11 11:53:49 -0700
Tools • Dart 3.13.0 • DevTools 2.60.0
$ dart --version
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"
```

The SDK floor of 3.4 named in step 2 resolves against this. Note `flutter` and `dart` are shell aliases to `fvm flutter` / `fvm dart` and the reported channel is `[user-branch]`, not `stable` (see F-010).

Analyzer scope, tested in a scratch tree with a root package and a nested `example/` package that has its own `pubspec.yaml` and its own `analysis_options.yaml` — exactly the layout step 11 describes:

```
$ ls anlz1 anlz1/example
anlz1: analysis_options.yaml  example  lib  pubspec.yaml
anlz1/example: analysis_options.yaml  lib  pubspec.yaml
$ cd anlz1 && dart analyze
Analyzing anlz1...
  error - example/lib/bad.dart:1:23 - A value of type 'String' can't be assigned to a variable of type 'int'. ... - invalid_assignment
1 issue found.
DART_ANALYZE_EXIT=3
$ cd anlz1 && flutter analyze --no-pub
Analyzing anlz1...
  error • A value of type 'String' can't be assigned to a variable of type 'int'. ... • example/lib/bad.dart:1:23 • invalid_assignment
1 issue found. (ran in 0.3s)
```

Both a root `dart analyze` and a root `flutter analyze` do reach the nested example package. See F-001.

Formatter scope, same scratch tree, with `build/` listed in `.gitignore` and a stray `.dart_tool/` file:

```
$ cat .gitignore
build/
$ dart format --output=none --set-exit-if-changed .
Changed build/web/gen.dart
Changed example/lib/bad.dart
Changed lib/root_ok.dart
Formatted 3 files (3 changed) in 0.01 seconds.
FORMAT_EXIT=1
```

`dart format` skips hidden `.dart_tool/` but does descend into a git-ignored, non-hidden `build/`. See F-009.

Research claims the plan restates:

```
$ grep -c "\[UNRESOLVED" wiki/work/0002-flutter-webmcp-stack/00-research.md
8
```

The plan says seven (`01-plan.md:7`). See F-005.

The tool-name rule in `01-plan.md:80` (1–128 characters, ASCII letter/digit/underscore/hyphen/period) matches `00-research.md:32` verbatim — verified, no finding.

The three linter behaviours AC-021's negative case relies on all exist: fenced block in a plan (`tools/lint_wiki.py:352-359`), duplicate work-item number (`tools/lint_wiki.py:323-325`), vague term in a criterion (`tools/lint_wiki.py:363-374`). AC-021 is sound.

Parallelism safety could not be checked and needs no finding: `03-tasks.md` does not exist yet, and it is not a plan-phase gate artifact — the plan gate is "plan exists, criteria exist, lint passes" (`wiki/conventions/workflow.md:61`) and `.claude/skills/implement/SKILL.md:22` writes the task file from the plan if absent. There are therefore no parallel markers to cross-check in this round.

## Criterion coverage

Coverage mapping only — this is a plan review, not an implementation review, so these are not per-criterion pass verdicts.

| Criterion | Implementing step(s) in `01-plan.md` | Covered |
|---|---|---|
| AC-001 | steps 2 (`:46`), 10 (`:62`) | yes |
| AC-002 | steps 2, 3, 4, 9, 10 | yes, but see F-004 |
| AC-003 | step 2 (`:46`) | yes |
| AC-004 | steps 6 (`:54`), 8 (`:58`), interfaces (`:74`) | yes |
| AC-005 | steps 6, 9 (`:60`) | yes |
| AC-006 | steps 4 (`:50`), 9; rule at `:80` | yes |
| AC-007 | steps 6, 9; error policy at `:86` | yes |
| AC-008 | steps 6, 9; error policy at `:86` | yes |
| AC-009 | steps 5 (`:52`), 9; ordering at `:22` | yes |
| AC-010 | steps 6, 9; facade member at `:76`; policy at `:84` | yes |
| AC-011 | steps 5, 9; logging at `:88` | yes |
| AC-012 | step 9 (`:60`) | yes |
| AC-013 | steps 8 (`:58`), 9; naming rule at `:90` | yes |
| AC-014 | step 10 (`:62`) | yes |
| AC-015 | step 10 (`:62`) | yes |
| AC-016 | step 11 (`:64`) | yes, but see F-009 |
| AC-017 | steps 3 (`:48`), 11 (`:64`) | contested — see F-001 |
| AC-018 | step 13 (`:68`) | yes |
| AC-019 | step 11 (`:64`), interfaces (`:94`) | yes, but see F-001 |
| AC-020 | step 12 (`:66`) | yes, but see F-007 |
| AC-021 | step 11 (`:64`) | yes |
| AC-022 | risk row (`:103`) only | weak — see F-006, F-007 |
| AC-023 | step 9 (`:60`), verification (`:133`) | yes, but see F-008 |
| AC-024 | steps 5, 9; error policy (`:86`) | yes, but see F-007 |

Steps satisfying no criterion: the `README.md` top-section content in step 2 (`01-plan.md:46`) — see F-003.

## Findings

### F-001 — The stated reason for the fourth check-script stage is false, and it contradicts AC-017

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:64` (repeated as a design decision at `:94`)
- Criterion affected: AC-017, AC-019
- Observation: The plan states "Analysis runs as two separate invocations, one per package, because `example/` has its own `pubspec.yaml` and its own `analysis_options.yaml`; a single root-directory invocation does not reach it." I built exactly that layout and ran both analyzers from the root; both reported the error in `example/lib/bad.dart` (output pasted above, `dart analyze` exit 3, `flutter analyze --no-pub` one issue found). The analyzer creates a separate context per nested `pubspec.yaml`/`analysis_options.yaml` and still analyzes it. Meanwhile AC-017 (`02-criteria.md:32`) requires that the root analysis "exit 0 and report no issue in `lib/`, `test/` or `example/`" — under the plan's stated model the root invocation cannot report on `example/` at all, so the criterion's `example/` clause would be satisfied only vacuously.
- Why it matters: An implementer who obeys `AGENTS.md`'s "never claim a check passed without pasting the output" will run the root analyzer, see it reach `example/`, and then face an undecided question the plan does not answer: keep the now-redundant fourth stage (required by AC-019's seven named banners, `02-criteria.md:34`) or drop it and break the stage count the criterion pins. The plan also does not say which analysis options and which fatality flags govern `example/` files when they are reached by the root invocation, which is the substantive part of the decision.

### F-002 — Step 2's `README.md` merge is not executable against the actual `README.md`

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:46`; target file `README.md:1`, `README.md:5`, `README.md:22`, `README.md:32`, `README.md:46`, `README.md:63`
- Criterion affected: none directly (AC-002 only requires `README.md` to exist)
- Observation: The step says the existing content "moves under a new `## Repository tooling` heading immediately below the new section, verbatim". The existing content is not a flat block: `README.md` opens with the H1 `# Agent workflow scaffold` at line 1 and contains five H2 sections at lines 5, 22, 32, 46 and 63. An H1 and five H2s cannot sit "under" a new H2 without demoting all six, and demoting them contradicts "verbatim". The step also never states the heading text or heading level of the new top section it inserts, nor what happens to the existing H1 title once the document is no longer only about the scaffold.
- Why it matters: The implementer must ask which of two incompatible readings applies — demote (not verbatim, and it rewrites the ADR-referenced section's heading level) or keep (a `## Repository tooling` heading immediately followed by an `# Agent workflow scaffold` H1, and two H1s in one file). The step's own completion condition ("the existing Cursor-settings instruction is still present in `README.md` under its new heading") passes under either reading, so it does not resolve the question.

### F-003 — The `README.md` top section satisfies no acceptance criterion, and no criterion protects the ADR-referenced text

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:46`; `02-criteria.md:17` (AC-002, the only criterion naming `README.md`)
- Criterion affected: none
- Observation: Step 2 requires new prose stating the package name, what it does, the origin-trial warning and the three differentiation commitments. No criterion checks any of that. Conversely, `wiki/adr/0002-share-agent-config-between-claude-code-and-cursor.md:69` and `:80` depend on the Cursor-settings instruction (`README.md:34`) staying present, and no criterion asserts it survives the edit — only the plan's own step-completion sentence does.
- Why it matters: Either the section is scope creep or AC-002 is missing a clause. Under the frozen-criteria rule (`AGENTS.md`, artifact rules), adding that clause after implementation starts costs a recorded validation round; adding it now is free. The regression that would actually hurt — silently dropping the ADR-referenced Cursor instruction — is currently guarded by nothing that runs.

### F-004 — Verification approach says six layout paths; AC-002 lists eight

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:129`
- Criterion affected: AC-002
- Observation: The plan says layout is checked "by asserting the presence of the six pub-layout paths". AC-002 (`02-criteria.md:17`) enumerates eight: `lib/`, `test/`, `example/`, `README.md`, `CHANGELOG.md`, `LICENSE`, `analysis_options.yaml`, `pubspec.yaml`. The plan does not say which six it means.
- Why it matters: The verification approach is what the implementer builds the check from. A six-path check leaves two paths unasserted and AC-002 partially unverified, and nothing in the plan says which two are dropped.

### F-005 — Unresolved-item count is wrong and three items are not handled

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:7` and the bullets at `:9`–`:12`
- Criterion affected: none
- Observation: The plan says the research artifact "lists seven `[UNRESOLVED]` items" and that "each is handled rather than answered". `grep -c` returns 8 (output pasted above). The plan's bullets account for `00-research.md:118` (chrome flags), `:119` (`outputSchema`), `:120` (shadowing), `:121` (capability diff) and `:123` (pana rule text). `00-research.md:122` (whether `dart-lang/web` already has an open proposal to add `modelContext` to the generated `Document` type), `:124` (whether the MCP-B toolkit is still the maintained reference) and `:125` (`intentcall_platform` as a third prior-art package) are not mentioned anywhere in the plan.
- Why it matters: `00-research.md:122` bears directly on step 7 (`01-plan.md:56`), which commits to the extension-with-external-members workaround — whether that workaround is written for clean removal later depends on that unresolved item. A blanket "each is handled" claim tells the implementer the question set is closed when it is not.

### F-006 — Verification approach overclaims that every criterion is exit-code checked with an injected negative

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:127`
- Criterion affected: AC-020, AC-022, AC-023
- Observation: The sentence states that every criterion "is checked by a command whose exit code decides the outcome, and each has an injected negative case that must produce a non-zero exit before the positive result counts". The plan's own later paragraphs contradict this: CI is checked "by pushing the branch and reading both job results" (`:137`), the secret half of AC-023 is "a manual diff review" (`:133`), and AC-022's wall-time budget is nowhere in the verification section at all — it appears only as a mitigation clause in a risk row (`:103`).
- Why it matters: AC-022 has no owning step and no stated measurement procedure. An implementer reading `:127` will believe the coverage is uniform and will not notice that three criteria need a different, non-exit-code procedure that the plan never describes.

### F-007 — Three criteria state a negative case that restates the positive instead of naming an injection

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/02-criteria.md:26` (AC-011), `:35` (AC-020), `:42` (AC-022), `:44` (AC-024)
- Criterion affected: AC-011, AC-020, AC-022, AC-024
- Observation: AC-011's negative column asserts that "zero lines, more than one line, or a line lacking the tool name fails the test" — that describes the positive assertion's failure modes, not a case that is made to fail. AC-022's is "a run exceeding 180 seconds fails this criterion", again a restatement, and the criterion measures "a developer machine" that is never identified, so the same script can pass on one machine and fail on another with no defect. AC-024 defers to AC-011 and describes a hypothetical broken build rather than an injection. AC-020's negative case adds a `needs:` edge and then looks for "a delayed or blocked wiki-job run" — both jobs still succeed, and "delayed" has no threshold, so there is no defined failing observation. By contrast AC-005 through AC-010, AC-012 through AC-017 and AC-021 all name a concrete transient mutation and the failure it must produce; these four are the outliers.
- Why it matters: `wiki/conventions/validation-rubrics.md:44` requires a case that should fail and does. A negative case that cannot fail lets the implementation validator record a pass with no evidence behind it.

### F-008 — The network/secret scan's deny-list and its secret half are undecided

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:60`; `02-criteria.md:43` (AC-023)
- Criterion affected: AC-023
- Observation: Step 9 specifies the scan as failing on "`dart:io`'s `HttpClient`/`Socket`, `package:http`, or similar". "Or similar" leaves the deny-list to the implementer, and the criterion's own wording ("an HTTP or socket library") does not close it either. The second half of AC-023 — no file containing "a credential, token, key or personal email address" — is delegated to "a manual review step in the same test file's doc comment", which is a reminder, not a check, and has no pass/fail record and no negative case.
- Why it matters: An import-based deny-list is a fixed enumeration; leaving it open means the check that ships and the check the implementation validator expects can differ. The secret half will be recorded as satisfied on the strength of a doc comment. Related and undecided in the same step: step 2 (`01-plan.md:46`) writes a `LICENSE` "carrying the MIT text" without stating the copyright holder string, which is exactly the kind of literal that the manual review is supposed to catch.

### F-009 — The repository-wide format stage has no stated path scope, and `dart format` ignores `.gitignore`

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:64` and `:94`; interacts with `02-criteria.md:29` (AC-014) and `:31` (AC-016)
- Criterion affected: AC-016, AC-022
- Observation: The format stage is specified only as "a repository-wide format check that fails on any unformatted file", with no traversal root and no exclusion policy. I verified that `dart format --output=none --set-exit-if-changed .` skips hidden `.dart_tool/` but descends into a `build/` directory that `.gitignore` excludes (output pasted above). AC-014 requires `flutter build web` inside `example/`, which creates `example/build/` in the same tree that the format stage walks, and step 2 (`01-plan.md:46`) only gitignores that output — which the formatter does not consult. The risk table (`:98`–`:108`) has no row for generated output entering a repository-wide stage.
- Why it matters: Whether the check script is run before or after a developer has built the example changes what the format stage walks, and the plan gives the implementer no rule to decide the traversal scope. The same traversal is the cheapest way to blow the AC-022 wall-time budget on a machine with build output present.

### F-010 — The plan assumes a stable-channel Flutter locally; the installed toolchain reports `[user-branch]` via fvm

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:62` (step 10 commits the example lock), `:66` (step 12 installs stable in CI), `:108` (the risk row that assumes the mitigation)
- Criterion affected: AC-001, AC-020
- Observation: The plan's mitigation for the lockfile risk is that "step 10 generates the lock with whatever stable-channel Flutter is available at implementation time; CI installs the same stable channel in step 12". The installed toolchain reports `Flutter 3.47.0 • channel [user-branch]` and both `flutter` and `dart` are aliases to `fvm`. No fvm pin is tracked in the repository — `git ls-files` shows no `.fvmrc` and no `.fvm/` entry — so nothing records which Flutter version produced the committed `example/pubspec.lock`, and CI's "stable channel" will be whichever version is stable on the day the job runs.
- Why it matters: The risk row rates this Low on the assumption that the local channel is stable. It is not, so the mitigation as written does not apply and the trigger ("`flutter pub get` inside `example/` in CI reports a lock/SDK mismatch") is more likely than rated. The plan also does not say whether the fvm pin should be committed alongside the lock it anchors.

### F-011 — Where the web-side fallback to the no-op transport happens is undecided

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:24`, against `:52` (step 5, the resolver), `:56` (step 7) and `:82` (the transport decision)
- Criterion affected: AC-010, AC-011
- Observation: Line 24 says the no-op transport is "the default on any non-web target, and the fallback on web when detection fails", and then says the web-only implementation performs the detection itself and, in this phase, logs instead of calling the browser. Nothing states which component performs the fallback: whether the web branch of the conditional export returns the detection transport unconditionally, or inspects detection at resolution time and returns `NoopWebMcpTransport` instead. The consequence is observable — the active-transport identifier that AC-010 reads (`02-criteria.md:25`) and the log line AC-011 pins (`:26`) differ between the two designs on a web target. Relatedly, the conditional-export condition itself is never named anywhere in the plan (`:24`, `:52`, `:82`) even though the risk row at `:102` rates an interop leak into a VM compilation as Medium likelihood and High impact, and the plan names every other interop identifier explicitly.
- Why it matters: These are exactly the shared decisions the plan's own Interfaces section exists to close (`wiki/templates/01-plan.md:35-39`). Left open, the transport file and the test file can be written against different answers.

### F-012 — Web-only platform declaration sits beside a VM-support commitment without reconciliation

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:46`; `02-criteria.md:18` (AC-003) against `:26` (AC-011) and `:44` (AC-024)
- Criterion affected: none
- Observation: Step 2 requires "a top-level web-only platform declaration" while the design's second differentiation commitment (`01-plan.md:32`) is a non-browser transport and AC-011/AC-024 pin behaviour on the Dart VM. Nothing functional breaks — the declaration affects pub.dev presentation and `pana`, both out of scope — but the plan never says how the declaration will be revised when the dev-time transport lands.
- Why it matters: Style and future-consistency only; it does not block implementation.

### F-013 — Rollback omits `STATE.yaml`

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:112`, against `:44` (step 1)
- Criterion affected: none
- Observation: Rollback lists three edited files and calls everything else new. Step 1 also appends a decision entry to `STATE.yaml`.
- Why it matters: Immaterial — `STATE.yaml` is the work item's mutable state file and is deliberately not reverted (`wiki/conventions/workflow.md:37`). Recorded for completeness only.

## Recurrence check

- Previous round: `wiki/work/0002-flutter-webmcp-stack/validation/plan-review-01.md`. I reviewed the plan blind and formed the findings above before comparing; for the comparison I used the round-one blocker record in `wiki/work/0002-flutter-webmcp-stack/STATE.yaml:22-36` rather than the report body.
- Recurring findings: none materially identical. Round one's `plan-F-002` (facade exposes no active-transport identifier) and `plan-F-003` (AC-023 has no implementing step) are closed and I confirmed the closures independently — the identifier is specified at `01-plan.md:76` and exercised in steps 6 and 9, and AC-023 now has the scan in step 9 (`:60`). Round one's `plan-F-001` said step 2 treated `README.md` as new and left replace-versus-merge undecided; that is closed — the step now names the file as tracked and specifies a merge. My F-002 is a different defect introduced by that fix: the merge instruction is structurally impossible against the file's actual heading tree.
- Oscillating: no. But this is the second consecutive round with a blocker in the same paragraph (`01-plan.md:46`, step 2's `README.md` edit). If a third round produces another finding there, treat it as oscillation and escalate rather than opening round four — the round cap is 3 (`wiki/conventions/validation-rubrics.md:57`).

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | Plan — the claim and the stage it justifies are both plan text; do not resolve it in code |
| F-002 | Plan — step 2 must state the resulting heading tree before anyone edits `README.md` |
| F-003 | Plan and criteria — either drop the section or add the AC-002 clause before criteria freeze |
| F-004 | Plan |
| F-005 | Plan — the miscount is plan text; the three unhandled items are research-owned (`00-research.md:122`, `:124`, `:125`) and only need a handling sentence, not new research, since none blocks this skeleton |
| F-006 | Plan |
| F-007 | Plan — `02-criteria.md`, closable now, not after freeze |
| F-008 | Plan |
| F-009 | Plan |
| F-010 | Plan — record the toolchain pin decision; no research needed, the version is pasted above |
| F-011 | Plan |
| F-012 | Plan (NIT) |
| F-013 | Plan (NIT) |
