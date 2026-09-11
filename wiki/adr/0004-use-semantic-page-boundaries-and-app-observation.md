---
id: adr-0004-use-semantic-page-boundaries-and-app-observation
title: "ADR 0004: Use semantic page boundaries and application-owned observation"
status: active
owner: unassigned
last_verified: 2026-09-10
applies_to: ["lib/src/page/**", "lib/src/transport/**", "packages/**", "example/**"]
summary: Automatic agent access is bounded by explicit semantic pages, Navigator evidence, and one application-owned observation session.
---

# ADR 0004: Use semantic page boundaries and application-owned observation

- Status: accepted
- Date: 2026-09-10
- Deciders: repository maintainers

## Context and problem statement

How can consumers expose selected Flutter pages with little repetitive tool
registration while preserving authorization, lifecycle ownership, navigation
correctness, privacy, and the existing registry and transport contracts?

## Decision drivers

1. Opt-in exposure with no global widget-tree fallback.
2. Current-state validation immediately before semantic dispatch.
3. Stable observation and receipts across page disposal and navigation.
4. Composition with consumer Navigators, observers, dispatchers, and transports.
5. Fixed resource and privacy boundaries.
6. Honest separation between direct browser conformance and native-agent proof.

## Considered options

- Explicit manual tool registration for every page control.
- Global widget or semantics inspection inferred from navigation alone.
- Explicit semantic page boundaries with forwarding Navigator observers and one
  application observation broker.
- Generalized state-management and service proxy interception.

## Decision outcome

Use `WebMcpPage` as the only automatic semantic exposure boundary.
`WebMcpNavigatorAdapter` instances provide route, transition, branch, and modal
activity evidence but never substitute for the boundary. One
`WebMcpAppSession` owns bounded observation events and operation receipts.

Exactly one Flutter view is supported. Missing, multiple, ambiguous, inactive,
covered, unknown-transition, or disposed scopes fail closed. Acts revalidate
the current mount, revision, handle, semantic node, availability, action, and
policy before dispatch.

The native publisher mirrors the existing registry additively and does not
replace custom transports. Generated domain adapters expose only annotated
public instance methods and receive a consumer-created live instance.

## Consequences

- Positive: ordinary Flutter semantics can be read and operated without one
  descriptor per widget.
- Positive: manual tools, generated domain actions, and automatic page tools
  share one ownership and publication path.
- Positive: observation survives route disposal without retaining page content
  or inactive scope identities.
- Negative: every participating Navigator needs a forwarding adapter and
  persistent branches need explicit selection evidence.
- Negative: multiple Flutter views, positive waits, generated route wrapping,
  generalized state proxies, and platform-back claims remain separate work.
- Negative: direct Chrome API conformance cannot establish native-agent support.

## Confirmation

Repository tests cover semantic isolation, navigation and modal matrices,
owner replacement, stale actions, privacy, bounded observation, operation
retention, native publisher ownership, and generated live-instance behavior.
The full repository gate runs all package analyses and tests. Native support
requires a separate authenticated official-Chrome model-selected trace.

## Pros and cons of the options

Manual registration is explicit and remains available, but repeats descriptors
for controls already represented by semantics. Global inspection minimizes
setup but cannot prove ownership, activity, or privacy and was rejected.
Semantic boundaries plus forwarding observers require small integration code
but make exposure and lifecycle evidence explicit. Generalized proxies could
cover more domain behavior but would expand framework coupling and lifecycle
risk beyond the MVP.

## More information

- [Automatic page-agent state](../work/0008-automatic-page-agent/STATE.yaml)
- [Observation research](../work/0008-automatic-page-agent/12-observation-research.md)
- [Gate revision criteria](../work/0008-automatic-page-agent/17-gate-revision-criteria.md)
- [WebMCP product contract](../product/webmcp-contract.md)
