---
id: adr-0003-webmcp-detection-first-registry
title: "ADR 0003: Use a singleton registry with a detection-only browser boundary"
status: superseded
superseded_by: adr-0004-use-semantic-page-boundaries-and-app-observation
owner: unassigned
last_verified: 2026-09-10
applies_to: ["lib/**"]
summary: The initial package keeps a singleton registry and limits browser integration to capability detection while WebMCP remains experimental.
---

# ADR 0003: Use a singleton registry with a detection-only browser boundary

- Status: superseded by ADR 0004
- Date: 2026-09-10
- Deciders: unassigned

## Context and problem statement

How should the initial package expose explicit actions while the browser WebMCP API remains experimental?

## Decision drivers

- Keep ownership deterministic across live screens.
- Keep browser API churn outside the product registry.
- Avoid claiming browser behavior that has not been implemented or verified.

## Considered options

- A process-wide registry with a browser boundary that only detects availability.
- A widget-tree registry that publishes directly to the browser API.
- A browser-first implementation whose external API is the source of truth.

## Decision outcome

Use a process-wide singleton registry as the source of truth, with lifetime-bounded scopes over its operations and a browser boundary that only checks `document.modelContext`. The first live registration wins; a later scoped duplicate is skipped and owns nothing. Browser publishing and router integration remain deferred.

## Consequences

- Positive: Ownership stays deterministic and the external browser surface can change without redefining the product registry.
- Negative: The skeleton is not a working browser WebMCP publisher. Consumers must explicitly name actions and maintain global uniqueness.

## Confirmation

The public contract must describe detection-only behavior until browser calls exist. Registry and lifecycle checks must preserve first-registration-wins, scoped duplicate skipping, ownership-based teardown, and the absence of browser publication. A future publishing implementation must add browser integration evidence before this ADR is superseded.

## Pros and cons of the options

### Singleton registry with detection-only transport

- Pros: deterministic ownership and an isolated external API boundary.
- Cons: no browser publication in the initial release; global names require consumer discipline.

### Widget-tree registry publishing directly

- Pros: lifecycle and browser registration could be colocated.
- Cons: couples ownership to a widget tree and binds lifecycle code to an unstable browser surface.

### Browser-first implementation

- Pros: could expose browser tools sooner if the API remains unchanged.
- Cons: makes an experimental external API the package’s source of truth.

## More information

- [WebMCP product contract](../product/webmcp-contract.md)
- [Work item 0004 plan](../work/0004-flutter-webmcp-skeleton/01-plan.md)
- [Work item 0004 frozen criteria](../work/0004-flutter-webmcp-skeleton/02-criteria.md)
- [Chrome WebMCP overview](https://developer.chrome.com/docs/ai/webmcp)
