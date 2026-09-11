# Plan review — round 03

- Work item: 0008-automatic-page-agent
- Reviewed artifact: wiki/work/0008-automatic-page-agent/16-gate-revision-plan.md against the combined contract in 02-criteria.md, 14-observation-criteria.md, and 17-gate-revision-criteria.md, with incorporated 01-plan.md, 13-observation-plan.md, 03-tasks.md, 15-observation-tasks.md, and 18-gate-revision-tasks.md
- Reviewer: plan-validator, independent blind review
- Date: 2026-09-10

## Verdict

**CONDITIONAL**

The revised contract covers generator retention, fail-closed single-view semantics, honest Chrome cancellation capabilities, authenticated-Chrome-only native support, resource-proof timing, and rollback, but one named blocker must close: the Step 6 / example-task supersession is internally contradictory and can reimpose native-agent proof as a development gate, contrary to AC-030.

## Verification performed

Read only the three plans, three criteria files, three task files, wiki/conventions/validation-rubrics.md, wiki/conventions/workflow.md, wiki/conventions/naming.md, and wiki/templates/validation-report.md. Prior plan reviews were read only after findings were formed. Research, spike evidence, implementation source, STATE.yaml, and author notes were not read.

Command:

```text
python3 - <<'PY'
from pathlib import Path
import re
root = Path('wiki/work/0008-automatic-page-agent')
files = ('01-plan.md', '13-observation-plan.md', '16-gate-revision-plan.md')
FENCE = re.compile(r'^\s*(```|~~~)')
for name in files:
    text = (root / name).read_text()
    hits = [f'{i}:{line}' for i, line in enumerate(text.splitlines(), 1) if FENCE.search(line)]
    print(f'{name}: lines={len(text.splitlines())} fence_hits={len(hits)}')
    for h in hits:
        print(h)
PY
```

Output:

```text
01-plan.md: lines=146 fence_hits=0
13-observation-plan.md: lines=99 fence_hits=0
16-gate-revision-plan.md: lines=91 fence_hits=0
```

Command:

```text
python3 - <<'PY'
from pathlib import Path
import re
root = Path('wiki/work/0008-automatic-page-agent')
VAGUE = re.compile(r'\b(correctly|properly|as expected|appropriately)\b', re.I)
for name in ('02-criteria.md', '14-observation-criteria.md', '17-gate-revision-criteria.md'):
    hits = []
    for i, line in enumerate((root / name).read_text().splitlines(), 1):
        if VAGUE.search(line):
            hits.append(i)
    print(f'{name}: vague_hits={hits or 0}')
PY
```

Output:

```text
02-criteria.md: vague_hits=0
14-observation-criteria.md: vague_hits=0
17-gate-revision-criteria.md: vague_hits=0
```

Command:

```text
python3 tools/lint_wiki.py
```

Output:

```text
lint_wiki: clean (0 warning(s)).
```

These commands were executed by this reviewer. No runtime, browser, release, benchmark, or generator check was run or claimed complete. Those remain future implementation and gate work.

Targeted contract checks (plan text only, not runtime proof):

- Clause supersession: 16-gate-revision-plan.md lists numbered replacements for 01-plan.md and 13-observation-plan.md; 17-gate-revision-criteria.md maps AC-001 through AC-028 onto AC-029 through AC-035. The mapping is explicit except for the example-publication clause recorded as F-001.
- Cancellation: AC-007 is narrowed to cancel-before-dispatch at the Chrome boundary; AC-029 requires unavailable post-start invocation cancellation, continued-callback tolerance, no replay, and no termination claim. That matches 16-gate-revision-plan.md:26-27, :37, :57 and 18-gate-revision-tasks.md R2.1/R2.2/R7.2. It does not restore 01-plan.md's former requirement to use invocation cancellation as a browser capability.
- Native support: AC-030 and AC-035, 16-gate-revision-plan.md:13 and :91, and 18-gate-revision-tasks.md R7.1/R8.3 forbid support, delivery, release, or completion from page-conformance, direct executeTool, WebDriver/CDP, simulated, or unauthenticated runs. Official Chrome plus authenticated natural-language model-selected calls are required.
- Dependency order: 18-gate-revision-tasks.md:71-75 sequences R1 freeze, then publisher ownership, then page contracts, then limits, then example integration, then generator, then authenticated proof, then verification. Authentication is not required for R2-R6. R2.2 serializes page-operation accounting through owner 2.2 rather than editing page files concurrently. No task is marked parallel.
- Generator: retained by 16-gate-revision-plan.md:40 and :50, 17-gate-revision-criteria.md:25-31 and :74, and 18-gate-revision-tasks.md R6.1/R8.3. It is not converted into an implicit follow-up or treated as MVP-complete.
- Rollback: 16-gate-revision-plan.md:73-79 disables automatic exposure, detaches listeners and browser registrations, preserves local tools/transports/data, fail-closes on safety regression, and keeps generator failure from erasing criteria or handwritten sources.
- Fenced code: none in the three plans, per the command output above.

## Per-criterion results

Implementation verdicts are not applicable. Rows record whether the revised/superseded planning contract still assigns the criterion. Paths are relative to wiki/work/0008-automatic-page-agent/.

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | covered, narrowed | 17-gate-revision-criteria.md:13; 16-gate-revision-plan.md:22; 18-gate-revision-tasks.md:31 | Planned: zero/multiple-view rejection, not functional multi-view support |
| AC-002 | covered, narrowed | 17-gate-revision-criteria.md:14; 16-gate-revision-plan.md:23; 18-gate-revision-tasks.md:24 | Planned: cancel-before-dispatch yes; post-start AbortSignal unavailable |
| AC-003 | covered, refined by AC-019 | 17-gate-revision-criteria.md:15; 13-observation-plan.md:41; 18-gate-revision-tasks.md:31 | Planned: unwrapped/no-adapter/no-boundary exposure fails closed |
| AC-004 | covered unchanged | 17-gate-revision-criteria.md:16; 01-plan.md:67; 18-gate-revision-tasks.md:34 | Planned: malformed fields / raw node IDs rejected |
| AC-005 | covered, refined by AC-021/AC-032 | 17-gate-revision-criteria.md:17; 16-gate-revision-plan.md:47; 18-gate-revision-tasks.md:32 | Planned: stale/old-owner handles cannot dispatch |
| AC-006 | covered, refined by AC-019/020/031/033 | 17-gate-revision-criteria.md:18; 16-gate-revision-plan.md:59; 18-gate-revision-tasks.md:33 | Planned: covered/unknown/multi-view scopes inactive |
| AC-007 | covered; Chrome cancel = before dispatch | 17-gate-revision-criteria.md:19; 01-plan.md:85; 16-gate-revision-plan.md:26 | Planned: duplicate id and cancel-before-dispatch; post-dispatch governed by AC-029 |
| AC-008 | covered unchanged | 17-gate-revision-criteria.md:20; 01-plan.md:97; 18-gate-revision-tasks.md:42 | Planned: secrets/setText without opt-in refused |
| AC-009 | covered; semantic subset separate from AC-027 | 17-gate-revision-criteria.md:21; 01-plan.md:75; 18-gate-revision-tasks.md:41 | Planned: expired cursors / unbuilt rows partial or rejected |
| AC-010 | covered unchanged | 17-gate-revision-criteria.md:22; 01-plan.md:105; 18-gate-revision-tasks.md:24 | Planned: browser failure does not drop local tools |
| AC-011 | covered, post-start cancel superseded | 17-gate-revision-criteria.md:23; 16-gate-revision-plan.md:27; 18-gate-revision-tasks.md:24 | Planned: invalid wire / cancel-before-dispatch safe; no in-flight termination claim |
| AC-012 | covered; generator stage retained | 17-gate-revision-criteria.md:24; 16-gate-revision-plan.md:50; 18-gate-revision-tasks.md:54 | Planned: unsupported signatures fail generation |
| AC-013 | covered; generator lifecycle retained | 17-gate-revision-criteria.md:25; 01-plan.md:63; 18-gate-revision-tasks.md:54 | Planned: late/disposed/unauthorized sources cannot invoke obsolete instances |
| AC-014 | covered; proof source superseded by AC-030/AC-035 | 17-gate-revision-criteria.md:26; 16-gate-revision-plan.md:25; 18-gate-revision-tasks.md:60 | Planned: harness/conformance/direct calls cannot promote support — see F-001 for example-task conflict |
| AC-015 | covered and extended | 17-gate-revision-criteria.md:27; 16-gate-revision-plan.md:55; 18-gate-revision-tasks.md:67 | Planned: capability/view/owner reasons without content |
| AC-016 | covered as narrowed by AC-026 and AC-029 | 17-gate-revision-criteria.md:28; 13-observation-plan.md:71; 16-gate-revision-plan.md:38 | Planned: no new dispatch after disposal; no termination of started work |
| AC-017 | covered unchanged | 17-gate-revision-criteria.md:29; 16-gate-revision-plan.md:89; 18-gate-revision-tasks.md:68 | Planned: missing measurements/checks cannot be release evidence |
| AC-018 | covered; generator/provider not silently removed | 17-gate-revision-criteria.md:30; 16-gate-revision-plan.md:85; 18-gate-revision-tasks.md:69 | Planned: unshipped generator/provider cannot be documented as delivered |
| AC-019 | covered unchanged | 17-gate-revision-criteria.md:31; 13-observation-plan.md:41; 18-gate-revision-tasks.md:31 | Planned: reused observer / no boundary fails |
| AC-020 | covered except platform-back-gesture MVP proof | 17-gate-revision-criteria.md:32; 16-gate-revision-plan.md:35; 18-gate-revision-tasks.md:33 | Planned: unknown gesture/transition stays inactive |
| AC-021 | covered; owner-replacement proof moved to implementation | 17-gate-revision-criteria.md:33; 16-gate-revision-plan.md:36; 18-gate-revision-tasks.md:32 | Planned: late callbacks after owner change cannot publish |
| AC-022 | covered; immediate polling baseline | 17-gate-revision-criteria.md:34; 16-gate-revision-plan.md:37; 18-gate-revision-tasks.md:48 | Planned: unsupported waits advertise polling; DOM/toolchange is not observe |
| AC-023 | covered unchanged | 17-gate-revision-criteria.md:35; 13-observation-plan.md:57; 18-gate-revision-tasks.md:34 | Planned: foreign/pagination cursors return gap |
| AC-024 | covered unchanged | 17-gate-revision-criteria.md:36; 13-observation-plan.md:67; 18-gate-revision-tasks.md:34 | Planned: Future/frame/human change is not backendConfirmed |
| AC-025 | covered; optional adapters remain later stage | 17-gate-revision-criteria.md:37; 13-observation-plan.md:75; 15-observation-tasks.md:33 | Planned: unselected providers/direct callbacks not auto-captured |
| AC-026 | covered with AC-029 interpretation | 17-gate-revision-criteria.md:38; 13-observation-plan.md:71; 16-gate-revision-plan.md:38 | Planned: no handler start after page disposal; abort does not terminate callback |
| AC-027 | covered; numeric caps unchanged, proof phase via AC-034 | 17-gate-revision-criteria.md:39; 13-observation-plan.md:61; 18-gate-revision-tasks.md:41 | Planned: one-over-limit busy/resourceLimit; no live-owner eviction |
| AC-028 | covered; native completion evidence strengthened | 17-gate-revision-criteria.md:40; 16-gate-revision-plan.md:91; 18-gate-revision-tasks.md:42 | Planned: forbidden metadata and missing native/release evidence block claims |
| AC-029 | covered | 17-gate-revision-criteria.md:62; 16-gate-revision-plan.md:57; 18-gate-revision-tasks.md:24 | Planned: in-flight-cancel claim, replay, or unbounded tracking fails |
| AC-030 | covered, with F-001 conflict on example-task done-when | 17-gate-revision-criteria.md:63; 16-gate-revision-plan.md:13; 18-gate-revision-tasks.md:48 | Planned: unauthenticated/direct/simulated runs cannot set supported |
| AC-031 | covered | 17-gate-revision-criteria.md:64; 16-gate-revision-plan.md:59; 18-gate-revision-tasks.md:31 | Planned: two views expose no page nodes/handles/actions |
| AC-032 | covered | 17-gate-revision-criteria.md:65; 16-gate-revision-plan.md:47; 18-gate-revision-tasks.md:32 | Planned: old owner unusable between change and recapture |
| AC-033 | covered | 17-gate-revision-criteria.md:66; 16-gate-revision-plan.md:35; 18-gate-revision-tasks.md:33 | Planned: frame/timeout/quietness cannot activate unknown gesture state |
| AC-034 | covered | 17-gate-revision-criteria.md:67; 16-gate-revision-plan.md:39; 18-gate-revision-tasks.md:41 | Planned: unrun component cap checks cannot pass |
| AC-035 | covered | 17-gate-revision-criteria.md:68; 16-gate-revision-plan.md:91; 18-gate-revision-tasks.md:60 | Planned: skipped step, other browser, or non-model-selected call blocks support |

## Findings

### F-001 — Example-publication supersession contradicts AC-030 development permission

- Severity: BLOCKER
- Location: `wiki/work/0008-automatic-page-agent/16-gate-revision-plan.md:25`
- Criterion affected: AC-030, AC-014
- Defect class: plan
- Observation: The revision states that 01-plan.md Step 6 still requires publishing the minimal example only after the (now lengthened) real-agent trace. The same plan then instructs implementers to integrate that example without a support claim (16-gate-revision-plan.md:49). 18-gate-revision-tasks.md:48 (R5.1) treats the example as closable on page-conformance while unsupported, and 18-gate-revision-tasks.md:73-75 places R5 before authenticated R7 and says authentication is not a prerequisite for R2-R6. Uncancelled 03-tasks.md:27 still says task 2.3 is done only when the real agent trace observes the control effect, and 18-gate-revision-tasks.md:6 says example work is not cancelled.
- Why it matters: An implementer cannot tell whether landing the example before authenticated Chrome proof is allowed. Reading 16-gate-revision-plan.md:25 and 03-tasks.md:27 reimposes native-agent success as a development gate for the example, which AC-030 and 16-gate-revision-plan.md:13 forbid. Reading R5.1 and sequence step 6 allows the example to land unsupported. Clause supersession for Step 6 is therefore not unambiguous.

## Recurrence check

- Previous round: wiki/work/0008-automatic-page-agent/validation/plan-review-02.md
- Recurring findings: none. Round 01 and round 02 reported no findings. F-001 is new to this gate-revision contract.
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan |
