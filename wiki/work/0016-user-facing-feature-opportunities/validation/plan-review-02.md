# Plan review — round 02

- Work item: 0016-user-facing-feature-opportunities
- Reviewed artifact: `wiki/work/0016-user-facing-feature-opportunities/01-plan.md` against `wiki/work/0016-user-facing-feature-opportunities/02-criteria.md`, at git revision bc1d786 (work-item files untracked)
- Reviewer: plan-validator
- Date: 2026-09-25

## Verdict

**PASS**

Every acceptance criterion has a step, a negative case, and a decided call path. No blocker invalidates the approach.

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
for token in ['webmcp_page', 'onInvoke', 'onCall', 'callHandler', 'title', 'exposedTo', 'toolactivated', 'toolcancel', 'withDecodedArguments', 'WebMcpToolException', 'logHook', 'NoopWebMcpNativeBoundary', 'pubspec.yaml']:
    print(f'plan mentions {token}:', token in plan)
PY
git rev-parse --short HEAD
rg -n "tool\.handler\(" lib --glob '*.dart'
rg -n "return WebMcpTool\(" lib/src/page/webmcp_page.dart
rg -n "required this.onInvoke" lib/src/widgets/webmcp_action.dart
rg -n "platforms:" -A 3 pubspec.yaml
```

```
criteria IDs: ['AC-001', 'AC-002', 'AC-003', 'AC-004', 'AC-005', 'AC-006', 'AC-007', 'AC-008', 'AC-009', 'AC-010', 'AC-011', 'AC-012', 'AC-013', 'AC-014', 'AC-015', 'AC-016', 'AC-017'] count 17
PASS: plan has no fenced code blocks
vague matches 0
empty negative columns 0
plan mentions webmcp_page: True
plan mentions onInvoke: True
plan mentions onCall: True
plan mentions callHandler: True
plan mentions title: True
plan mentions exposedTo: True
plan mentions toolactivated: True
plan mentions toolcancel: True
plan mentions withDecodedArguments: True
plan mentions WebMcpToolException: True
plan mentions logHook: True
plan mentions NoopWebMcpNativeBoundary: True
plan mentions pubspec.yaml: True
bc1d786
lib/src/webmcp.dart:142:    return tool.handler(arguments);
lib/src/transport/webmcp_native_publisher.dart:335:      result = await tool.handler(normalizedInput);
lib/src/page/webmcp_page.dart:641:          result = tool.handler(arguments);
619:    return WebMcpTool(
18:    required this.onInvoke,
29:platforms:
30-  web:
```

No `03-tasks.md` is present. The plan steps are sequential and do not mark parallel file owners.

AC-001 through AC-017 each have a negative case and none use an uncheckable word. The plan names the signal, the single widget callback, page dispatch, descriptors, activity, decode, structured errors, the logger, and non-web registration those criteria require. Rollback is stated. The plan has no fenced code.

`lib/src/webmcp.dart:142`, `lib/src/transport/webmcp_native_publisher.dart:335`, and `lib/src/page/webmcp_page.dart:641` still call `tool.handler`. The plan at lines 11 and 39 assigns `callHandler` when set and `handler` otherwise, including the page wrapper with a null signal. `lib/src/widgets/webmcp_action.dart:18` still requires `onInvoke`. The plan at lines 11 and 53 requires exactly one of `onInvoke` or `onCall` and stores only the matching tool callback. `pubspec.yaml:30` lists web only. Step 5 adds the other Flutter platforms. `lib/src/transport/native_publisher_boundary_web.dart:54` takes one execute argument. Step 5 reads the second argument's signal. `cancelledBeforeDispatch` remains the skip path at `lib/src/transport/webmcp_native_publisher.dart:314`.

## Findings

### F-001 — Page source wrapper rebuilds a tool without title or exposedTo

- Severity: IMPORTANT
- Location: `wiki/work/0016-user-facing-feature-opportunities/01-plan.md:39`
- Criterion affected: none
- Observation: Step 2 tells the page source wrapper to prefer `callHandler`. `lib/src/page/webmcp_page.dart:619` builds the registered tool from name, description, input schema, annotations, and a handler. Title and `exposedTo` are fields of `WebMcpTool`, not of annotations. The plan never says the wrapper copies them.
- Why it matters: A source tool that sets a title or an origin list is published through that rebuilt tool, so those registration members are omitted. Debugging survives only because it sits on the annotations object the wrapper already copies.

## Recurrence check

- Previous round: `wiki/work/0016-user-facing-feature-opportunities/validation/plan-review-01.md`
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan |
