# Research stream: request capture and workflow enforcement

## Question

Where must request records integrate with the agent workflow, and what can repository checks actually enforce, so every feature/change request is retained through quick changes, full-route completion, route migration, and cancellation?

## Answer

Create one immutable, machine-readable request file as soon as an implementation request enters `/build`, `/feature`, or `/quick-change`, before routing or clarification can lose it. Link that request to exactly one numbered work item, carry the link when a quick route is promoted to full, and let only verified completion mark it `ready`; cancellation must remain a terminal, reason-bearing record. Repository lint can validate all checked-in structure and transitions, but cannot prove that an unseen conversation was captured or that an uncommitted request file ever existed.

## Findings

### Capture must precede route selection

- `build` is the normal request entry point and reads pointers or asks clarification before choosing a route; it currently creates no durable artifact before dispatch (`.claude/skills/build/SKILL.md:3-4`, `:16-20`, `:34-40`). A record created only inside the selected route leaves pre-routing cancellation and clarification outside the history.
- Users may invoke a route or phase directly, because `build` explicitly yields to named skills (`.claude/skills/build/SKILL.md:4`). Therefore capture instructions must exist in the always-on workflow contract and in both route skills, not only in `build`.
- `feature` creates its work item only after deciding that the quick route does not apply (`.claude/skills/feature/SKILL.md:18-24`). `quick-change` creates its record after implementation and checks (`.claude/skills/quick-change/SKILL.md:30-40`). Both are too late to guarantee a record of cancelled or interrupted requests.

### Every request needs an explicit work-item link, including quick changes

- Full changes already receive a numbered folder and `STATE.yaml` (`wiki/conventions/workflow.md:21-37`; `.claude/skills/feature/SKILL.md:22-24`). Quick changes also create a numbered folder with `RECORD.md` and state, but only after the change is made (`.claude/skills/quick-change/SKILL.md:36-40`).
- Work-item numbers are never reused, including abandoned items (`wiki/conventions/workflow.md:23`; `wiki/conventions/naming.md:15-18`). This supports allocating a work-item identity when the request is accepted, regardless of later outcome.
- The linter presently infers `quick` from `RECORD.md`, instead of parsing `STATE.yaml.route` (`tools/lint_wiki.py:328-343`). It checks only that `id`, `route`, and `phase` text occur (`tools/lint_wiki.py:328-335`), so it cannot establish a request-to-work-item relation or consistency between declared and inferred route.

### Promotion and cancellation have no defined transition

- The quick skill says to abandon the route and open a full work item when scope expands (`.claude/skills/quick-change/SKILL.md:26-28`), but it does not say whether the original request identity is retained, linked, or duplicated.
- The workflow says numbers survive abandonment (`wiki/conventions/workflow.md:23`) and existing state files demonstrate an undocumented `phase: superseded` convention (`wiki/work/0002-flutter-webmcp-stack/STATE.yaml:1-9`; `wiki/work/0003-flutter-webmcp-skeleton/STATE.yaml:1-9`). The state template does not permit or describe cancellation or supersession: its phase comment lists only the six phases plus `done` (`wiki/templates/STATE.yaml:4-9`).
- `STATE.yaml` is the only mutable work-item file and all other artifacts are append-or-supersede (`wiki/conventions/workflow.md:37`). A cancelled request therefore needs an explicit terminal status and reason in state and/or an append-only request record; deleting the folder would violate the repository's never-delete rule (`AGENTS.md:16`).

### `ready` must be derived from verification evidence

- The repository forbids completion while a test fails or work is partial (`AGENTS.md:12-16`). Full-route completion requires implementation `PASS`, pasted full-suite output, clean wiki lint, and documentation (`wiki/conventions/workflow.md:94-114`; `.claude/skills/feature/SKILL.md:79-95`). The definition of done additionally requires per-criterion evidence and `STATE.yaml phase: done` (`wiki/conventions/definition-of-done.md:21-47`).
- Quick completion requires a green full suite with pasted output, `RECORD.md`, and clean lint (`.claude/skills/quick-change/SKILL.md:44-46`). Thus a request must not be labelled `ready` merely because code exists; `ready` should be valid only when the linked route's existing completion gate is satisfied.
- `tools/check.sh` runs wiki lint first, then dependencies, formatting, analysis, tests, builds, and release-helper tests (`tools/check.sh:20-71`). Adding request validation to `lint_wiki.py` makes malformed checked-in records fail both the focused wiki check and the full suite.

### Structural enforcement is possible; conversational completeness is not

- The linter intentionally uses only Python's standard library and simple text parsing (`tools/lint_wiki.py:17-25`, `:74-92`). A per-request JSON file is compatible with that approach through the standard `json` module and provides stricter parsing than extending the current substring checks for YAML.
- The linter enumerates existing work-item directories and validates their on-disk contents (`tools/lint_wiki.py:312-349`); it does not inspect Git history, commits, PRs, tickets, or chat transcripts. Records can therefore be independent of commits and PRs, but lint can only prove that every checked-in work item has a valid request link and every checked-in request points to a valid work item.
- No repository-side check can prove a negative about input it cannot observe: a user conversation bypassing these skills, a request cancelled before any file write, or a local record never committed remains invisible. Always-on instructions and all entry-point skills reduce this gap; CI cannot eliminate it.

## Integration options

| Option | Integration | Strengths | Limits |
|---|---|---|---|
| Per-request JSON plus mandatory work-item backlink (recommended) | Create `wiki/requests/<stable-id>.json` before route selection; allocate/link a numbered work item immediately; store request ID in `STATE.yaml`; update request lifecycle without tying it to a commit or PR. | Standard-library validation; one identity survives route promotion; cancellation is auditable; release tooling can select only verified `ready` records. | Requires coordinated changes to workflow, templates, `build`, `feature`, `quick-change`, and lint. CI still cannot see uncaptured conversations. |
| Request metadata only inside `STATE.yaml` | Add original request and lifecycle fields to each work item. | Fewer files and direct association. | `STATE.yaml` is mutable, so original wording/history is easier to overwrite; weak schema parsing today; request aggregation is less clean. |
| Derive changelog from Git commits or PRs | Infer requests from commit/PR metadata. | Fits conventional release tooling. | Violates the chosen commit/PR-independent design; misses cancelled requests and local work; cannot represent one request spanning route changes reliably. |

## Recommended enforcement points

1. `AGENTS.md` and `wiki/conventions/workflow.md`: define request capture as a prerequisite to any route, the mandatory one-to-one work-item link, terminal lifecycle values, promotion semantics, cancellation reasons, and the rule that only verified completion yields `ready`.
2. `.claude/skills/build/SKILL.md`: capture verbatim normalized request data before clarification and dispatch, then pass the request ID to the chosen route.
3. `.claude/skills/feature/SKILL.md` and `.claude/skills/quick-change/SKILL.md`: create or adopt the linked work item before implementation; direct invocation must perform capture itself; promotion must retain the request ID and supersede/link the first work item rather than mint a second request.
4. `wiki/templates/STATE.yaml` and a request template/schema: make linkage and terminal states explicit. Keep the original request immutable; append lifecycle events or restrict mutations to named state fields.
5. `tools/lint_wiki.py`: parse every JSON record, require unique IDs and required fields, validate allowed lifecycle transitions as represented on disk, verify bidirectional request/work-item links, require cancellation reasons, reject `ready` unless the linked quick/full completion artifacts satisfy deterministic structural gates, and reject orphan records/work items.
6. `tools/check.sh`: no separate stage is necessary if request lint is part of Stage 1 (`tools/check.sh:20-21`); focused tests for the linter should cover malformed JSON, orphan links, route promotion, premature `ready`, and cancellation.

## Enforcement limits and unresolved questions

- `[UNRESOLVED: What stable request-ID format and filename convention should be canonical?]` It must be generated without relying on a commit or PR and remain collision-safe across concurrent agents.
- `[UNRESOLVED: Is the relationship strictly one request to one work item, or may a promoted quick work item point to a successor full work item while the request retains one active/canonical work-item link?]` The shared design requires every request to link to a work item, but promotion needs an explicit historical-link rule.
- `[UNRESOLVED: Which terminal value names are required: ready, cancelled, superseded, rejected, or a smaller set?]` Existing work items use undocumented `superseded`; the template and linter do not validate phase values.
- `[UNRESOLVED: How should lint prove pasted check output is fresh and successful?]` It can require artifact markers, but current lint does not execute or cryptographically bind prior output to the current tree. The full suite itself remains the live proof.
- `[UNRESOLVED: Must cancelled requests allocate a complete work-item folder immediately, or may a minimal linked folder contain only STATE.yaml plus the request record?]` The answer affects warning behavior because a full item without `01-plan.md` currently produces only a warning (`tools/lint_wiki.py:339-343`).

## Sources consulted

- `AGENTS.md` (2026-09-11)
- `.claude/skills/build/SKILL.md` (2026-09-11)
- `.claude/skills/feature/SKILL.md` (2026-09-11)
- `.claude/skills/quick-change/SKILL.md` (2026-09-11)
- `wiki/INDEX.md` and `wiki/conventions/{workflow,naming,definition-of-done}.md` (2026-09-11)
- `wiki/templates/STATE.yaml` (2026-09-11)
- `tools/check.sh` and `tools/lint_wiki.py` (2026-09-11)
- `wiki/work/0002-flutter-webmcp-stack/STATE.yaml` and `wiki/work/0003-flutter-webmcp-skeleton/STATE.yaml` (2026-09-11)
