# Plan review — round 01

- Work item: 0016-user-facing-feature-opportunities
- Reviewed artifact: `wiki/work/0016-user-facing-feature-opportunities/01-plan.md` against `wiki/work/0016-user-facing-feature-opportunities/02-criteria.md`, at git revision bc1d786 (work-item files untracked)
- Reviewer: plan-validator
- Date: 2026-09-25

## Verdict

**FAIL**

Two construction rules in the plan contradict call sites that already invoke `WebMcpTool.handler`. An implementer cannot make `handler` optional, or add a widget call handler, without a decision the plan does not make.

## Verification performed

```
$ python3 - <<'PY'
from pathlib import Path
import re
p = Path('wiki/work/0016-user-facing-feature-opportunities')
plan = (p/'01-plan.md').read_text()
criteria = (p/'02-criteria.md').read_text()
ids = sorted(set(re.findall(r'AC-\d{3}', criteria)))
print('criteria IDs:', ids, 'count', len(ids))
assert not re.search(r'^\s*(```|~~~)', plan, re.M)
print('PASS: plan has no fenced code blocks')
print('vague matches', len(re.findall(r'correctly|properly|as expected', criteria, re.I)))
empty_neg = 0
for line in criteria.splitlines():
    if re.match(r'\| AC-\d{3} ', line):
        parts = [c.strip() for c in line.split('|')]
        if len(parts) >= 5 and parts[4] == '':
            empty_neg += 1
            print('empty neg', parts[1])
print('empty negative columns', empty_neg)
print('plan mentions webmcp_page', 'webmcp_page' in plan)
print('plan mentions onInvoke', 'onInvoke' in plan)
PY
git rev-parse --short HEAD
rg -n "tool\.handler\(" lib --glob '*.dart'
rg -n "required this.onInvoke" lib/src/widgets/webmcp_action.dart
```

```
criteria IDs: ['AC-001', 'AC-002', 'AC-003', 'AC-004', 'AC-005', 'AC-006', 'AC-007', 'AC-008', 'AC-009', 'AC-010', 'AC-011', 'AC-012', 'AC-013', 'AC-014', 'AC-015'] count 15
PASS: plan has no fenced code blocks
vague matches 0
empty negative columns 0
plan mentions webmcp_page False
plan mentions onInvoke False
bc1d786
lib/src/webmcp.dart:142:    return tool.handler(arguments);
lib/src/page/webmcp_page.dart:641:          result = tool.handler(arguments);
lib/src/transport/webmcp_native_publisher.dart:335:      result = await tool.handler(normalizedInput);
18:    required this.onInvoke,
```

No `03-tasks.md` is present. The plan steps are sequential and do not mark parallel file owners.

AC-001 through AC-015 each have a negative case and none use an uncheckable word. Steps 1 through 6 name the signal, descriptors, activity, decode, structured errors, logger, and non-web registration those criteria require. Rollback is stated. The plan has no fenced code.

## Findings

### F-001 — Page dispatch still calls handler while the plan makes handler optional

- Severity: BLOCKER
- Location: `wiki/work/0016-user-facing-feature-opportunities/01-plan.md:39`
- Criterion affected: none
- Observation: Step 2 names `WebMcp.invokeTool` as the local caller that prefers `callHandler`. `lib/src/page/webmcp_page.dart:641` also calls `tool.handler(arguments)` when wrapping a source tool. Line 51 of the plan says a tool with neither `handler` nor `callHandler` throws, so `handler` cannot stay required. The plan does not mention `webmcp_page.dart`.
- Why it matters: A call-handler-only tool, which the plan allows, is not callable from the page wrapper, and making `handler` nullable leaves `webmcp_page.dart:641` without a decided target.

### F-002 — WebMcpAction always supplies handler and the plan also adds callHandler

- Severity: BLOCKER
- Location: `wiki/work/0016-user-facing-feature-opportunities/01-plan.md:11`
- Criterion affected: AC-004
- Observation: Line 11 gives `WebMcpAction` the optional call handler, and line 51 rejects a tool constructed with both `handler` and `callHandler`. `lib/src/widgets/webmcp_action.dart:18` requires `onInvoke`, and line 67 always passes that callback as `handler`. The plan never says whether `onInvoke` stays required or is omitted when a call handler is set.
- Why it matters: Threading a call handler through the widget as the widget is written constructs a tool with both callbacks, which the plan forbids. AC-004's rebuild check is on that same widget.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan |
| F-002 | plan |
