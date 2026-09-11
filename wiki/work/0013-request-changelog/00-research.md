# Research: Request-based release changelog

## Question

How can agent requests become durable, auditable release notes without using commit or pull-request text, including retry and migration failures?

## Answer

Use explicit request records and immutable release reservations, with separate publication confirmations. This is a proposed design, not an implemented capability; current automation inserts a generic release bullet and has neither request selection nor confirmation storage ([release research](research/release.md)).

## Findings

### Capture and enforcement

The entry skills currently allocate durable work records after routing, or after quick implementation; always-on capture must precede both. Existing lint checks structure rather than conversations, and cannot prove that an unseen request was recorded ([capture research](research/capture.md), sources and line references therein). Design decision: allocate a UUID request plus minimal numbered work item before clarification, retain the same identities on route promotion, and capture sanitized English summaries rather than raw conversations.

### Release durability

Current release automation pushes its release commit before its tag and publication runs separately without a confirmation step. A successful branch push followed by failed tag push therefore needs same-version recovery. Recomputing the request set on retry would make a version unstable ([release research](research/release.md)). Design decision: retain commit-then-tag, freeze the exact selection in the release commit, never move tags, and store immutable confirmation files on main after remote identity verification.

### Historical migration and scope

The root changelog contains numbered generic entries and nonempty legacy Unreleased text. Neither heading order nor local versions proves external publication. Separate nested packages exist, but their publication status is [UNVERIFIED] ([migration research](research/migration.md)). Design decision: scope publication to the root package; preserve numbered history and gate activation on evidence-backed legacy disposition and exact payload inspection.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Commit or PR inference | Infer note text from development messages | Low | Rejected by the requested provenance rule and ambiguous request boundaries. |
| Mutable work-state notes only | Store notes in existing state | Low | Rejected because immutable request identity and release snapshots become difficult to audit. |
| JSON requests, reservations, confirmations | Explicit records control selection and delivery | Moderate | Chosen: standard-library validation and repeatable same-version recovery. |
| Atomic branch and tag push | Commit and tag advance together | Compatibility validation | Deferred; support and tag-trigger behavior are [UNVERIFIED], while existing ordering can be repaired explicitly. |
| Release every internal-only batch | Invent a generic maintenance entry | Low | Rejected: internal-only batches produce no release; public maintenance entries require explicit meaningful record text. |

## Constraints discovered

All implementation remains future work. No third-party runtime dependency is needed by the proposed JSON/Python design. Existing checks, irreversible publication policy, and never-delete wiki rule remain applicable ([workflow](../../conventions/workflow.md), [release research](research/release.md)). Structural CI enforcement cannot establish human relevance or unseen conversational completeness. Git object identities and path diffs may establish integrity and coverage, but never supply note text.

## Unresolved

- [UNRESOLVED: Which published payload, if any, contains each legacy Unreleased claim?] Release activation remains blocked until evidence-backed dispositions exist.
- [UNRESOLVED: Does the configured publisher support rerunning the original tag workflow with its existing trust context?] Controlled integration evidence is an activation gate; no tag recreation fallback is allowed.
- [UNRESOLVED: Which exact remote archive and checksum response can prove uploaded payload identity?] Implementation must document and test the official registry contract before enabling publication confirmation.
- [UNRESOLVED: What currently enters the exact root package archive?] Inspect the dry-run payload before activation, including nested packages and exclusion of request metadata.

## Sources

Consulted 2026-09-11: [capture stream](research/capture.md), [release stream](research/release.md), [migration stream](research/migration.md), [workflow](../../conventions/workflow.md), [naming](../../conventions/naming.md), and the four phase templates under `wiki/templates/`. Streams retain the underlying local file and line references. No external publication was verified for this plan.

## Design decision supersession — 2026-09-11

The user-scope clarification supersedes the internal-only no-release choice in Options considered. All new completed requests, including internal, documentation and maintenance changes, contribute sanitized meaningful release notes. Visibility and classification govern presentation, not eligibility. The rejected alternative is permanently withholding internal ready requests; the final chosen design includes every ready unreserved request and performs a successful no-op only when that set is empty. This is a scope decision, not a newly verified repository fact.
