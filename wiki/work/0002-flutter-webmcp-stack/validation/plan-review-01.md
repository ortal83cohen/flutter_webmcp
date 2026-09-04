# Plan review — round 01

- Work item: 0002-flutter-webmcp-stack
- Reviewed artifact: `wiki/work/0002-flutter-webmcp-stack/01-plan.md` and `wiki/work/0002-flutter-webmcp-stack/02-criteria.md`, at git revision 663cf48 (working tree clean)
- Reviewer: plan validator (blind — criteria and artifacts only)
- Date: 2026-09-04

## Verdict

**FAIL**

Two criteria (AC-010, AC-023) cannot be satisfied by any step or interface the plan states, and step 2 contradicts the repository's actual state by treating an existing, load-bearing `README.md` as a new file — each is a plan-phase defect that must close before implementation.

## Verification performed

Wiki linter, run from the repository root:

```
$ python3 tools/lint_wiki.py; echo "EXIT=$?"
lint_wiki: clean (0 warning(s)).
EXIT=0
```

The linter's plan check reads every line of `01-plan.md` and errors on the first fence (`tools/lint_wiki.py:352-360`, regex `FENCE` at line 41). Clean exit confirms **zero fenced code blocks, snippets or pseudo-code in `01-plan.md`** — the prose-only rule holds. Independent confirmation:

```
$ grep -c '^\s*\(```\|~~~\)' wiki/work/0002-flutter-webmcp-stack/01-plan.md
0
```

Section order in `01-plan.md` against the plan-phase gate in `wiki/conventions/workflow.md:58-66` ("goal, approach, reasoning for the approach over alternatives, sequence of steps, what each step touches, risks, what is out of scope"):

```
$ grep -n '^## ' wiki/work/0002-flutter-webmcp-stack/01-plan.md
3:## Scope note and unresolved-item check
14:## Goal
18:## Approach
28:## Why this approach
42:## Steps
70:## Interfaces and shared decisions
96:## Risks
109:## Rollback
113:## Out of scope
124:## Verification approach
```

Order is correct and complete; every numbered step names what it touches and a completion condition (`01-plan.md:44-68`). No finding here.

Vague-term check on the criteria — the linter scans every line carrying an `AC-NNN` for `correctly|properly|as expected|appropriately` (`tools/lint_wiki.py:45`, `363-374`); the clean run above proves none is present. Manual re-check:

```
$ grep -nic "correctly\|properly\|as expected\|appropriately" wiki/work/0002-flutter-webmcp-stack/02-criteria.md
0
```

Repository state the plan asserts things about:

```
$ ls -a /Users/ortalcohen/Documents/GitHub/flutter_webmcp
.claude .cursor .github .gitignore AGENTS.md CLAUDE.md README.md tools wiki
$ git ls-files README.md .gitignore .github/workflows/checks.yml
.github/workflows/checks.yml
.gitignore
README.md
$ wc -l README.md
      73 README.md
```

`.github/workflows/checks.yml` holds exactly one job (`wiki`) plus a comment reserving the second job — the plan's premise at `01-plan.md:66` and AC-020 is accurate.

Toolchain availability, since every criterion from AC-001 onward assumes it:

```
$ flutter --version | head -2
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Tools • Dart 3.13.0
```

Dart 3.13 clears the plan's 3.4 SDK floor (`01-plan.md:46`). Note the channel is `[user-branch]` (fvm-managed, no `.fvmrc` committed), not `stable`.

Remote exists, so AC-020's "when the branch is pushed, both jobs shall report success" is executable:

```
$ git remote -v
origin	https://github.com/ortal83cohen/project-AI-skeleton (fetch)
```

Parallelism cross-check: **not performed — `03-tasks.md` does not exist yet.**

```
$ ls wiki/work/0002-flutter-webmcp-stack
00-research.md  01-plan.md  02-criteria.md  STATE.yaml  research  validation
```

No parallel markers exist to verify. `wiki/conventions/workflow.md:98` makes `03-tasks.md` a Phase 4 input, so its absence is not a finding at this gate, but the file-ownership check it enables has not happened and cannot be inferred from this review.

## Criterion coverage map

Not a per-criterion pass/fail (that is an implementation review); this maps each criterion to the step that would satisfy it.

| Criterion | Covering step / decision | Covered |
|---|---|---|
| AC-001 | steps 2, 10, 11 (`01-plan.md:46,62,64`) | yes |
| AC-002 | steps 2, 3, 4, 9, 10 (`:46,48,50,60,62`) | yes |
| AC-003 | step 2 (`:46`) | yes |
| AC-004 | steps 6, 8 + library structure (`:54,58,74`) | yes |
| AC-005 | steps 6, 9 (`:54,60`) | yes |
| AC-006 | step 4 + name rule (`:50,80`) | yes |
| AC-007 | step 6 + error handling (`:54,86`) | yes |
| AC-008 | steps 6, 9 + error handling (`:54,60,86`) | yes |
| AC-009 | step 9 (`:60`) | yes |
| AC-010 | step 6 + `:84` — but unobservable, see F-002 | **no** |
| AC-011 | steps 5, 9 + logging (`:52,60,88`) | yes |
| AC-012 | step 9 (`:60`) | yes |
| AC-013 | steps 8, 9 + routing seam (`:58,60,90`) | yes |
| AC-014 | step 10 (`:62`) | yes |
| AC-015 | step 10 (`:62`) | yes |
| AC-016 | step 11 (`:64`) | yes |
| AC-017 | step 3, 11 (`:48,64`) — example scope open, see F-004 | partial |
| AC-018 | step 13 (`:68`) | yes |
| AC-019 | step 11 (`:64`) — output format open, see F-005 | partial |
| AC-020 | step 12 (`:66`) | yes |
| AC-021 | steps 11, 12 (`:64,66`) | yes |
| AC-022 | risk row (`:103`) only; no step | acceptable (measurement) |
| AC-023 | none, see F-003 | **no** |
| AC-024 | steps 5, 9 + error handling (`:52,60,86`) | yes |

No step fails to serve a criterion; there is no scope creep in the step list.

## Findings

### F-001 — Step 2 writes a `README.md` that already exists and is load-bearing; the rollback section states it is a new file

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:46` and `:111`
- Criterion affected: AC-002 (and the plan's own rollback claim)
- Observation: step 2 instructs "Write `README.md` stating what the package does, its origin-trial status warning and the three differentiation commitments", and line 111 asserts "Every artifact in this work item is a new file, except two additive edits: a second job appended to `.github/workflows/checks.yml` and new entries in `.gitignore`." A tracked 73-line `README.md` already exists (`git ls-files README.md`; `README.md:1` "# Agent workflow scaffold"), and it is the documented home of the Cursor setup instruction — `README.md:36` names the "Cursor Settings → Rules, Skills, Subagents → include third-party plugins" toggle, and `wiki/adr/0002-share-agent-config-between-claude-code-and-cursor.md:69` and `:80` record that file as the confirmation and reference for that ADR. The plan nowhere decides whether the package README replaces, prepends to, or merges with the existing content.
- Why it matters: the implementer must guess between overwriting (silently invalidating a stated ADR consequence and losing repository setup documentation) and merging (a different file shape than the plan describes). The rollback paragraph is also factually wrong about what the change touches, so the stated blast radius understates the change by one committed file.

### F-002 — AC-010's check needs an active-transport identifier the planned facade does not expose

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:76` (facade member list) against `02-criteria.md:25` (AC-010)
- Criterion affected: AC-010
- Observation: AC-010's check method is "register a tool, attempt installation, assert the throw, then assert the active transport identifier is unchanged", and its negative case is "installing a transport while no tool is registered ... shall change the active transport identifier". `01-plan.md:76` enumerates the facade exhaustively — "It offers: register a tool, unregister by name, invoke by name with an input map, read the registered tools as an unmodifiable list in insertion order, install a transport, query whether the active transport reports browser support, set a log sink, and reset." There is no member returning the active transport or its identifier. `01-plan.md:82` gives the transport interface "a stable string identifier for logging", but nothing in the plan makes it readable from outside. `01-plan.md:74` further restricts the public library to a fixed export list and says "Nothing else is public".
- Why it matters: the criterion is unsatisfiable as written without an unplanned public member. The implementer will invent one (a getter, a test-only hook, or a `src/` import in the test), and a shared public-API decision made at implementation time is exactly the class of choice `wiki/conventions/workflow.md:64` requires the plan to settle.

### F-003 — AC-023 is addressed by no step and by no line of the verification approach

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:60` (step 9 test list) and `:126-136` (verification approach), against `02-criteria.md:43` (AC-023)
- Criterion affected: AC-023
- Observation: AC-023 requires that a scan of `lib/` and `example/lib/` find no HTTP or socket library import and no credential, token, key or personal email address, checked by "A scan for network-library imports plus a review of the diff for literal secrets". Step 9 specifies exactly one scanning test and scopes it narrowly: "one test that scans `lib/` and fails if a web-only import appears outside the designated file or if any file imports the deprecated legacy interop libraries" — network libraries and `example/lib/` are outside both conditions. `grep -ni "secret\|credential\|socket" 01-plan.md` returns only line 111, in the rollback prose ("no secret is provisioned"). Meanwhile `01-plan.md:126` claims "Every criterion in `02-criteria.md` is checked by a command whose exit code decides the outcome, and each has an injected negative case" — AC-022 and AC-023 have no such command anywhere in the plan.
- Why it matters: an implementer following the plan literally ships without the network/secret scan, and the verify phase then fails a security-and-privacy criterion. The completeness claim at line 126 makes the gap harder to notice, not easier.

### F-004 — Whether `example/` is covered by the analysis stage is left to the implementer, but AC-017 requires it

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:64` (and `:94`), against `02-criteria.md:32` (AC-017)
- Criterion affected: AC-017
- Observation: AC-017 requires analysis to "exit with status 0 and report no issue in `lib/`, `test/` or `example/`". The plan's check-command contents name only "static analysis at the root with infos fatal" (`:64` and `:94`) — one invocation, no statement about whether it reaches the nested `example/` package, which has its own `pubspec.yaml` and its own `analysis_options.yaml` relaxing the documentation rule (`:62`). The plan does not decide whether a second analysis stage runs inside `example/`.
- Why it matters: `example/` is a separate package with its own analysis context and its own relaxed rule set; whether one root invocation satisfies the criterion is an assumption the plan neither states nor tests. Two implementers write two different `tools/check.sh`, and only one of them passes AC-017.

### F-005 — The check script's per-stage output is not specified, but AC-019's check method depends on it

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:64`, against `02-criteria.md:34` (AC-019)
- Criterion affected: AC-019
- Observation: AC-019 is checked by "Run the check script; read the exit code and confirm each of the six stages appears in its output", and its negative case requires each injection to "produce a non-zero exit and name the stage that failed". Step 11 specifies only ordering and stop-on-first-failure ("runs, in order and stopping at the first failure: ... First failure stops the run and sets a non-zero exit"). Nothing in the plan requires the script to emit a stage banner or name the failing stage.
- Why it matters: a straightforward `set -e` script satisfies every word of step 11 and still fails AC-019's stated check method, because six bare command invocations do not "name the stage that failed". This surfaces only at verification, after the script is written.

### F-006 — AC-020's negative case is not a case that fails

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/02-criteria.md:35`
- Criterion affected: AC-020
- Observation: the negative-case column reads "The wiki job shall run without a Flutter installation, so a change touching only `wiki/` shall not require the package job to have installed Flutter for the wiki job to report a result." That restates a desired property of the positive case; it names no injection, no broken state, and no observation that would come out different if the requirement were violated. Every other structural criterion in the file names a transient mutation and a revert (for example `:16`, `:17`, `:27`, `:29`).
- Why it matters: `wiki/conventions/validation-rubrics.md:44` requires "At least one negative test per criterion: a case that should fail and does". Without one, AC-020 passes for any workflow file that happens to contain two jobs, including one where the wiki job gained a `needs:` edge or a Flutter setup step.

### F-007 — AC-022 attributes its 180-second budget to the plan, which states no figure

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/02-criteria.md:42`, against `01-plan.md:103`
- Criterion affected: AC-022
- Observation: AC-022's negative-case column says "the figure is a budget decided in the plan". The plan's only reference is the risk row at `:103` — "the wall-time ceiling is an acceptance criterion measured in the verify phase" — which points back at the criteria file. No number appears anywhere in `01-plan.md`. The criterion also states both that a run over 180 seconds fails it and that "the measured number is recorded whether or not it passes", which are in tension about whether exceeding the budget blocks.
- Why it matters: circular attribution only; the number is unambiguous in `02-criteria.md:42`, so the criterion remains checkable.

### F-008 — Step 3's completion condition references a `lib/` no earlier step creates

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:48`
- Criterion affected: none
- Observation: step 3 is complete "when `flutter analyze` runs against an empty `lib/` without error", but `lib/` is first populated in step 4 (`:50`) and step 2 (`:46`) creates only the five root metadata files.
- Why it matters: trivially resolvable by creating the directory; noted so the completion condition is not read as a contradiction.

### F-009 — Local toolchain is not on the channel CI will pin, and the risk table has no row for the divergence

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/01-plan.md:40` and `:66`
- Criterion affected: none
- Observation: line 40 makes the committed `example/pubspec.lock` "the reproducibility anchor" and says "CI additionally pins the Flutter channel"; step 12 installs "the Flutter stable channel". The developer machine here runs `Flutter 3.47.0 • channel [user-branch]` under fvm, and no `.fvmrc` is committed (`ls -a` output above). The risk table (`:98-107`) has a row for the SDK floor failing to resolve but none for the lock file being generated on a different channel than CI resolves against.
- Why it matters: low impact — an app lock file that disagrees with the CI SDK is usually re-resolved rather than fatal — but it is the one reproducibility assumption in the plan that the local environment already contradicts.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | Plan (Phase 2) — step 2 and the rollback paragraph must account for the existing `README.md` and decide replace-versus-merge |
| F-002 | Plan (Phase 2) — the facade surface in `## Interfaces and shared decisions`, or AC-010's check method; criteria are not yet frozen (`02-criteria.md:9`) |
| F-003 | Plan (Phase 2) — step 9's test scope or the verification approach must name the AC-023 scan |
| F-004 | Plan (Phase 2) — check-command contents |
| F-005 | Plan (Phase 2) — check-command contents |
| F-006 | Plan (Phase 2) — criteria authored in the plan phase; criteria are not yet frozen |
| F-007 | Plan (Phase 2) — wording only |
| F-008 | Plan (Phase 2) — wording only |
| F-009 | Plan (Phase 2) — risk table row, optional |

No finding routes to research: the plan's factual claims about WebMCP, the interop pattern, the registry choice and the incumbent package all trace to `00-research.md` and carry the research artifact's own `[UNVERIFIED]` markers where the research left them open. No one-way door was identified; `01-plan.md:111`'s escalation-not-needed conclusion holds once F-001 is corrected.
