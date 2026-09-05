# Plan review — round 01

- Work item: 0003-flutter-webmcp-skeleton
- Reviewed artifact: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md` and `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md` at git revision `663cf48` (working tree clean)
- Reviewer: plan validator (blind — no author transcript or self-assessment consulted)
- Date: 2026-09-05

## Verdict

**FAIL**

The plan's single load-bearing tooling decision rests on a misattributed cause: the `analysis_options.yaml` rewrite is performed by the Flutter tool's pub hook, which the plan's own check script invokes three times, so switching the analyzer binary does not prevent it and AC-006 cannot pass on an unmodified checkout as planned.

## Verification performed

### Plan is prose only — no fenced code

```
$ python3 tools/lint_wiki.py; echo "EXIT=$?"
lint_wiki: clean (0 warning(s)).
EXIT=0

$ grep -n '```\|~~~' wiki/work/0003-flutter-webmcp-skeleton/01-plan.md
(no output)
```

`tools/lint_wiki.py:352-361` (`check_plan_is_prose`) enforces this; it passes. No finding.

### Criteria are free of vague terms and all numbered

```
$ grep -nEi "\b(correctly|properly|as expected|appropriately|reasonable|sensible|robust|clean|good)\b" wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md
(no output)

$ grep -c "^| AC-" wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md
31
```

31 criteria, AC-001..AC-031, none using a banned term. No finding.

### Installed toolchain

```
$ /Users/ortalcohen/.local/bin/flutter --version
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
Engine • hash 59d54a2b2896a6bbf356c94b7fac7b9e235bdacd (revision 5f77625673) (24 days ago)
Tools • Dart 3.13.0 • DevTools 2.60.0

$ /Users/ortalcohen/.local/bin/dart --version
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"

$ ls -l /Users/ortalcohen/.local/bin/flutter
... -> /Users/ortalcohen/fvm/default/bin/flutter
```

The toolchain is FVM-managed and reports channel `[user-branch]`, not `stable`.

### Does one `dart analyze` from the repository root reach a nested `example/` package under its own options file?

Scratch reproduction built at `.../scratchpad/repro`: root package `root_pkg` with
`analysis_options.yaml` enabling `prefer_single_quotes` and excluding `example/build/**`;
nested `example/` package `ex_pkg` with its own `analysis_options.yaml` excluding `build/**`;
`example/lib/main.dart` containing an unused local and a double-quoted string;
`example/build/bad.dart` calling an undeclared function.

```
$ dart analyze --fatal-infos --fatal-warnings .   # from the root package
Analyzing ....

warning - example/lib/main.dart:2:7 - The value of the local variable 'unusedLocalOnPurpose' isn't used. ... - unused_local_variable

1 issue found.
EXIT=2
```

Confirms three of the plan's claims (`01-plan.md:19`, `01-plan.md:71`): the single root
invocation does reach `example/lib/`; the example is a separate analysis context (the root's
`prefer_single_quotes` did **not** fire on the example's double-quoted string); and
`example/build/` is suppressed. Removing only the `build/**` entry from
`example/analysis_options.yaml` and re-running:

```
Analyzing ....

  error - example/build/bad.dart:2:3 - The function 'undeclaredIdentifierHere' isn't defined. ... - undefined_function
warning - example/lib/main.dart:2:7 - ... - unused_local_variable

2 issues found.
EXIT=3
```

AC-005 and AC-007 negative cases are both genuine and injectable. Note also that the root
file's `example/build/**` entry did **not** suppress it — the example context's own file is
load-bearing, exactly as `01-plan.md:71` states.

### AC-008 negative case

Removing `publish_to: none` from `example/pubspec.yaml` and adding the path dependency:

```
warning - example/pubspec.yaml:7:5 - Publishable packages can't have 'path' dependencies. Try adding a 'publish_to: none' entry ... - invalid_dependency
EXIT=3
```

Genuine and injectable.

### AC-019 negative case

```
$ dart run vm_js.dart      # a VM script importing dart:js_interop
vm_js.dart:1:8: Error: Dart library 'dart:js_interop' is not available on this platform.
import 'dart:js_interop';
       ^
```

Swapping the conditional-export branches does break the VM compile. Genuine.

### Which binary rewrites `analysis_options.yaml`?

Flutter tool source, this SDK:

```
$ grep -rn "AnalysisOptionsMigration" /Users/ortalcohen/fvm/default/packages/flutter_tools/lib/src/project.dart
31:import 'migrations/analysis_options_migration.dart';
429:      AnalysisOptionsMigration(this, globals.logger),
```

`project.dart:428-431` runs the migration inside `ensureReadyForPlatformSpecificTooling`,
**before** the `isPlugin || !anyPlatformEnabled` early return at `project.dart:442`. Callers:

```
$ grep -rn "regeneratePlatformSpecificTooling" .../flutter_tools/lib/
src/runner/flutter_command.dart:1982-1987   (verifyThenRunCommand, default-on at :2036)
src/commands/packages.dart:400              (flutter pub get, the project)
src/commands/packages.dart:412              (flutter pub get, the example/ project)
```

Empirical confirmation, scratch Flutter package `.../scratchpad/frepro` with a committed
`analysis_options.yaml`:

```
$ shasum analysis_options.yaml
3d78aee428615e1dc385c3e37e5bd8d25c49eb4f  analysis_options.yaml

$ flutter pub get
...
Changed 7 dependencies!
Upgrading analysis_options.yaml to exclude build and platform directories.

$ cat analysis_options.yaml
analyzer:
  exclude:
    - example/build/**
    - build/**
    - android/**
    - ios/**
    - web/**
    - windows/**
    - macos/**
    - linux/**
linter:
  rules:
    - prefer_single_quotes

$ shasum analysis_options.yaml
731b379afd453bf4f269f336c2a73660abe4ecae  analysis_options.yaml
```

Restored the file, then:

```
$ flutter test
...
Upgrading analysis_options.yaml to exclude build and platform directories.
00:00 +1: All tests passed!
$ shasum analysis_options.yaml
731b379afd453bf4f269f336c2a73660abe4ecae  analysis_options.yaml   # mutated again
```

Restored the file, then:

```
$ dart analyze --fatal-infos .
Analyzing ....
No issues found!
EXIT=0
$ cat analysis_options.yaml    # unchanged
```

So `dart analyze` is clean, but `flutter pub get` and `flutter test` both mutate. See F-001.

### Repository state the plan asserts

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

$ head -1 README.md
# Agent workflow scaffold

$ grep -n -i "third-party" README.md
36:**Cursor** reads `AGENTS.md` natively. To also pick up the skills and subagents in `.claude/`, enable **Cursor Settings → Rules, Skills, Subagents → include third-party plugins, skills and other configs**. ...
```

Step 10's described README edit (`01-plan.md:51`) is structurally executable: line 1 is a
level-one heading, insertion above it yields two sequential level-one headings, and the
Cursor sentence at line 36 is untouched by an insertion above line 1. No finding.

```
$ grep -n "^  [a-z]*:$" .github/workflows/checks.yml
  wiki:
```

One job today; step 11 adds a second. Consistent.

```
$ wc -l AGENTS.md
      69 AGENTS.md
```

Well under the 200-line cap AC-029 asserts. No finding.

```
$ ls -la wiki/work/0003-flutter-webmcp-skeleton/validation/
total 0
drwxr-xr-x@ 2 ... .
drwxr-xr-x@ 8 ... ..
```

Empty. See F-002.

```
$ git remote -v
origin	https://github.com/ortal83cohen/project-AI-skeleton (fetch)
origin	https://github.com/ortal83cohen/project-AI-skeleton (push)
```

See F-006.

```
$ /bin/sh -c 'echo $PATH' | tr : '\n' | grep -c .
$ for d in ~/.local/bin ~/fvm/default/bin ~/flutter/bin; do ls $d/flutter; done
/Users/ortalcohen/.local/bin/flutter
/Users/ortalcohen/fvm/default/bin/flutter
/Users/ortalcohen/flutter/bin/flutter
```

Three separate PATH entries provide `flutter`. See F-005.

### AC-027 negative case, reproduced in a throwaway git repository

```
$ git init -q . && git add CHANGELOG.md && git commit -qm init
$ mv CHANGELOG.md CHANGES.md
$ git ls-files
CHANGELOG.md
$ git status --porcelain
 D CHANGELOG.md
?? CHANGES.md
```

`git ls-files` still lists all names after the rename. See F-008.

### Parallelism

```
$ ls wiki/work/0003-flutter-webmcp-skeleton/
00-research.md  01-plan.md  02-criteria.md  STATE.yaml  research  validation
```

No `03-tasks.md` exists, so there are no parallel markers to cross-check. Not applicable this
round.

## Criterion-to-step coverage

Every criterion AC-001..AC-029 and AC-031 maps to an implementing step. AC-030 does not; see
F-010. Steps 1-12 each serve at least one criterion except step 5's web half; see F-009.

| Criterion | Implementing step |
|---|---|
| AC-001, AC-002, AC-003, AC-004 | step 8 (`01-plan.md:47`), step 9 (`:49`) |
| AC-005, AC-006, AC-007 | step 3 (`:37`), step 8 (`:47`) |
| AC-008, AC-021, AC-022 | step 7 (`:45`) |
| AC-009 – AC-016 | step 4 (`:39`), step 6 (`:43`) |
| AC-017, AC-018, AC-031 | step 6 (`:43`) |
| AC-019, AC-020 | step 5 (`:41`), step 6 (`:43`) |
| AC-023, AC-024, AC-025 | step 11 (`:53`), step 10 (`:51`) |
| AC-026, AC-029 | step 10 (`:51`) |
| AC-027 | steps 3, 4, 6, 7, 10 |
| AC-028 | step 3 (`:37`) |
| AC-030 | **none** — see F-010 |

## Findings

### F-001 — The analyzer-binary rationale misattributes the cause of the `analysis_options.yaml` rewrite, and the plan's own check script triggers that rewrite three times

- Severity: BLOCKER
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:19` (rationale), `:69` (check stages 2, 5, 6), `:71` (analysis scope); `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:19` (AC-006)
- Criterion affected: AC-006, and consequentially AC-001, AC-005, AC-007
- Observation: `01-plan.md:19` states "`flutter analyze` rewrites a committed `analysis_options.yaml` in place the first time it runs in a workspace" and makes the whole `dart analyze` decision rest on that. The rewrite is performed by `AnalysisOptionsMigration`, invoked from `FlutterProject.ensureReadyForPlatformSpecificTooling` (`flutter_tools/lib/src/project.dart:428-431`), which every Flutter command with `shouldRunPub == true` reaches — including `flutter pub get` (`flutter_tools/lib/src/commands/packages.dart:400` for the project and `:412` for its `example/`) and every command routed through `FlutterCommand.verifyThenRunCommand` (`flutter_tools/lib/src/runner/flutter_command.dart:1982-1987`, default-on at `:2036`). Reproduced above: `flutter pub get` and `flutter test` each rewrote a committed `analysis_options.yaml` and printed the exact notice the plan attributes to `flutter analyze`; `dart analyze` left the file byte-identical. The plan's check script (`01-plan.md:69`) runs `flutter pub get` at the root and in `example/` (stage 2), `flutter test` in both (stage 5) and `flutter build web` (stage 6). `01-plan.md:71` further specifies that the two committed options files exclude `example/build/` and `.dart_tool` "and nothing else" — which guarantees the migration's `needsMigration` test (`analysis_options_migration.dart:49-65`) is true and the injection fires on the first run of a fresh checkout.
- Why it matters: AC-006 asserts both options files are byte-identical to their committed contents after a full run. As planned, that fails on an unmodified checkout, so AC-006's positive case does not hold and its negative case (switch to `flutter analyze`) is not a discriminating mutation. `01-plan.md:71`'s stated analysis scope also becomes false after the first run, because seven directory exclusions nobody reviewed are now in the file. Every CI run then starts from a dirty tree — the precise failure mode the plan says it is preventing. The plan's risk table (`:81-87`) does not mention this risk at all.

### F-002 — The risk table asserts a validation-round state that does not exist

- Severity: BLOCKER
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:86`
- Criterion affected: none
- Observation: the row claims "The prior plan-validation rounds one through three already exist for this work item, so a review of this rewritten plan would be round four, which `tools/lint_wiki.py` rejects", rates it High/High, declares it "Not resolvable inside this plan" and escalates to a human before validation starts. `ls -la wiki/work/0003-flutter-webmcp-skeleton/validation/` shows the directory is empty. `tools/lint_wiki.py:377-418` (`check_reviews`) scans `item / "validation"` per work-item folder and caps `max(seen) > 3` within that folder only; this report is `plan-review-01.md` in `0003`, i.e. round 1. `wiki/work/0003-flutter-webmcp-skeleton/STATE.yaml:25` itself records that "Validation restarts at round 1 for both phases in this folder", contradicting the risk row in the same work item.
- Why it matters: a false High/High risk that demands human escalation before validation can proceed stops the pipeline on a condition that is not real, and it is stated as verified fact in an artifact whose non-negotiable rule (`AGENTS.md:12`) is never to assert an unverified fact. An implementer reading `:86` has no way to tell it is wrong without re-deriving the linter's behaviour.

### F-003 — The package name is deferred to an external query but hardcoded in the frozen criteria and throughout the plan

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:9` and `:33` (step 1 defers), against `:13`, `:39`, `:59`, `:61`, `:67` (hardcode `webmcp_pilot`) and `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:30` (AC-017 names `lib/webmcp_pilot.dart`)
- Criterion affected: AC-017
- Observation: step 1 says the name is `webmcp_pilot` unless a pub.dev query finds it taken, in which case `webmcp_autopilot` is used. Step 4 (`:39`) nonetheless names the file `lib/webmcp_pilot.dart` as the thing it creates, and AC-017's criterion and negative case both name `lib/webmcp_pilot.dart` explicitly. `02-criteria.md:5-6` says the criteria freeze when the implement phase starts, i.e. after step 1 has run.
- Why it matters: if step 1 selects the fallback, AC-017 and its negative case reference a file that does not exist, and the criterion becomes uncheckable without an edit to a frozen document. The plan states at `:9` that step 1 "settles this before any file names the package", but the criteria already name it.

### F-004 — Step 2's completion condition contradicts the step's own edit, and its stable-channel premise does not hold on the target toolchain

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:35`
- Criterion affected: none
- Observation: the step adds ignore entries to `.gitignore` and then declares itself complete "when the entries exist and `git status --porcelain` is empty on the untouched tree". Adding entries to a tracked `.gitignore` makes `git status --porcelain` non-empty until the change is committed, so the condition as written can never be observed at the point the step ends. The same step requires capturing versions "from the installed stable-channel SDK"; the installed SDK reports `channel [user-branch]` (FVM-managed, output pasted above), so the premise is false on the machine the plan targets.
- Why it matters: an implementer cannot tell whether step 2 is done, and the recorded toolchain provenance the step exists to produce will not match the wording of the instruction.

### F-005 — AC-002's stated mutation does not achieve its own precondition on the target machine

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:15`
- Criterion affected: AC-002
- Observation: the check method says to invoke the script "with the search path stripped of the Flutter SDK bin directory" (singular). Three distinct PATH entries on this machine each provide a `flutter` binary: `/Users/ortalcohen/.local/bin/flutter`, `/Users/ortalcohen/fvm/default/bin/flutter`, `/Users/ortalcohen/flutter/bin/flutter` (listing pasted above). Stripping one leaves the binary resolvable, so the criterion's triggering condition ("absent from the executable search path") is not reached and neither the positive nor the negative observation can be made as written.
- Why it matters: the criterion silently passes — the script prints its normal output and nobody notices the precondition was never established.

### F-006 — The `repository` manifest field is sourced from an origin remote that is not this package's repository

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:59`
- Criterion affected: none
- Observation: the plan fixes the `repository` field as "the canonical HTTPS URL of this repository's `origin` remote, read from the git configuration rather than typed from memory". `git remote -v` returns `https://github.com/ortal83cohen/project-AI-skeleton`, a workflow-scaffold repository, not a WebMCP package repository. No criterion checks this field.
- Why it matters: the instruction is mechanically executable and produces a wrong value, and nothing in the criteria set catches it. It carries into the manifest of a package the plan intends to publish later.

### F-007 — AC-005's stated inference is false; no criterion exercises `--fatal-infos`

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:18`
- Criterion affected: AC-005
- Observation: the negative case declares an unused local in `example/lib/main.dart` and states this proves "that the one invocation reaches the nested package and that infos are fatal". Reproduced above: the diagnostic emitted is `warning - ... unused_local_variable`, and `dart analyze` treats warnings as fatal by default. The mutation therefore proves nothing about infos. `01-plan.md:69` (stage 4) and `:71` make infos fatal specifically so that the root file's public-member documentation lint is enforced; no criterion in the set exercises an info-severity diagnostic.
- Why it matters: the criterion asserts evidence its own check does not produce, and the fatal-infos setting — which the documentation lint depends on — would survive being deleted from the script without any criterion failing.

### F-008 — AC-027's negative case does not fail under AC-027's own check method

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:40`
- Criterion affected: AC-027
- Observation: the check method is "List the tracked files at the repository root and confirm all eight names are present"; the negative case is "Rename `CHANGELOG.md` to `CHANGES.md`. Re-run the listing: one of the eight names is missing." Reproduced in a throwaway repository above: after `mv CHANGELOG.md CHANGES.md`, `git ls-files` still prints `CHANGELOG.md`, because it lists the index, not the worktree. The listing is unchanged and the check passes.
- Why it matters: the criterion has, in effect, no working negative case, so it cannot distinguish a satisfied repository from a broken one.

### F-009 — No criterion exercises the web half of step 5

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:41` and `:67`
- Criterion affected: none
- Observation: step 5 creates `lib/src/transport/transport_web.dart` (`WebDetectionTransport`, identifier `web-detection`, `dart:js_interop_unsafe` presence check, one `dart:developer` log line per construction and per notification) and `lib/src/interop/document_model_context.dart` (the `modelContext` extension member). AC-019 asserts only the non-web identifier on the VM; AC-020 uses an injected fake. `02-criteria.md:54` explicitly excludes browser behaviour. The only coverage of these two files is incidental compilation during AC-022's `flutter build web`.
- Why it matters: the identifier string, the log lines and the presence-check call site can all be wrong or absent and every criterion still passes. Either a criterion is missing or these two files are scope beyond what the criteria require.

### F-010 — AC-030 has no implementing step

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:48`; no corresponding step in `01-plan.md:33-55`
- Criterion affected: AC-030
- Observation: AC-030 requires the warm-checkout run to finish under five minutes. No step states a runtime budget, no step says where the timing is measured or recorded, and step 12 (`01-plan.md:55`) — the only step that runs the suite from a clean tree — asks only for the output and the exit status.
- Why it matters: the criterion is checkable in principle but nothing in the plan produces the measurement, so it will be discovered unmet at verification time rather than designed for.

### F-011 — AC-025's negative case requires an acknowledged unrevertible push of a knowingly-broken branch

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:38`; `01-plan.md:93`
- Criterion affected: AC-025
- Observation: the negative case says to change the pinned version literal "to a version string that is not a published Flutter release, then push the branch", observe the failed run, "Restore the literal and push again". `01-plan.md:93` states plainly that a pushed branch "stays in the remote's history along with its Actions run and logs until someone deletes the branch explicitly; reverting a local commit does not remove it".
- Why it matters: the criteria set requires an operation the plan's own rollback section classifies as not undoable, against a shared remote, and neither document names who authorises it or on which branch it is performed.

### F-012 — Compound criteria whose negative case exercises only one conjunct

- Severity: IMPORTANT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/02-criteria.md:30` (AC-017), `:41` (AC-028)
- Criterion affected: AC-017, AC-028
- Observation: AC-017 asserts both an import restriction ("no import naming any path under `lib/src/`, no relative import into `lib/`") and full public-surface exercise; its negative case deletes an export from the public library, which exercises only the latter — adding a `lib/src/` import to the test would leave the suite compiling and passing. AC-028 asserts both that the platforms map contains web and nothing else and that dependencies resolve; its negative case changes a dependency constraint, exercising only the second.
- Why it matters: the unexercised half of each criterion is the half that is easy to get wrong and has no failing case to catch it.

### F-013 — The pub.dev README will carry the scaffold documentation

- Severity: NIT
- Location: `wiki/work/0003-flutter-webmcp-skeleton/01-plan.md:9` and `:51`; `README.md:1-73`
- Criterion affected: none
- Observation: rooting the package at the repository root makes `README.md` the pub.dev README (`:9`), and step 10 inserts the package section above the existing 73 lines, which are the agent-workflow scaffold's own documentation (`# Agent workflow scaffold`, `## Start here`, `## The pipeline`, `## Setup`, `## Layout`, `## Why it is shaped this way`). AC-026 requires those lines be preserved byte-identically.
- Why it matters: cosmetic only while publishing is out of scope; noted so the later publishing work item does not discover it late.

## Recurrence check

- Previous round: none — first round in `wiki/work/0003-flutter-webmcp-skeleton/validation/`. The directory is empty (`ls -la` output pasted above), and `tools/lint_wiki.py:377-418` scopes the round cap to this folder. Predecessor work items were not consulted, per the review brief.
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan — the analyzer-binary decision, the check-stage order and the committed exclusion list are all plan-level choices; AC-006 must be re-derived once the real cause is established. A supporting fact about Flutter tool behaviour was asserted without verification, so the underlying tooling claim should be re-established in research before the plan is rewritten. |
| F-002 | plan — a false statement of repository state inside the plan's risk table. |
| F-003 | plan — an undecided shared name leaking into a document that freezes. |
| F-004 | plan — step completion condition and toolchain premise. |
| F-005 | plan — criterion check method. |
| F-006 | plan — a fixed interface value that resolves to a wrong URL. |
| F-007 | plan — criterion evidence claim and a missing criterion for fatal infos. |
| F-008 | plan — criterion check method and negative case. |
| F-009 | plan — either a missing criterion or scope beyond the criteria. |
| F-010 | plan — criterion without an implementing step. |
| F-011 | plan — criterion requiring an unrevertible shared-remote action. |
| F-012 | plan — criterion negative cases. |
| F-013 | plan — informational; no action required this work item. |
