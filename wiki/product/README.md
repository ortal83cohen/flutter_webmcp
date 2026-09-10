---
id: product-readme
title: Product knowledge
status: active
owner: unassigned
last_verified: 2026-09-10
applies_to: ["**"]
summary: What the product does, its domain rules and its constraints. Grown one shipped feature at a time.
---

# Product knowledge

The repository contains a detection-first local WebMCP-style registry for
Flutter web. Read [webmcp-contract.md](webmcp-contract.md) for the product
boundary: explicit action declarations, lifetime-bounded exposure, globally
unique names, local invocation semantics, custom transport failure behavior,
and detection-only browser integration. The browser API is experimental. The
package does not publish tools to the browser or accept browser-originated
invocations.

## What belongs here

Facts about the product that an agent cannot derive by reading the code:

- domain rules and the reason they exist;
- external contracts — what a third party expects from us, and what we expect from them;
- constraints that are not visible in the source: licence terms, regulatory requirements, agreements with other teams, load characteristics;
- deliberate omissions and the reason for them.

## What does not belong here

Anything an agent can derive faster by reading the code, running it, or reading `git log`:

- directory layouts and file inventories;
- lists of dependencies;
- architecture narratives that restate the module structure;
- API surfaces that the source already declares.

This exclusion is deliberate and it is the most counter-intuitive rule in this wiki. Prose overviews of a repository are measurably worse than nothing: they do not improve an agent's task success and they raise its cost by more than a fifth, because the agent reads the summary instead of the source and then reads the source anyway. Procedural knowledge that triggers when relevant — a skill, a path-scoped rule — is where documentation pays for itself.

If you find yourself writing a paragraph that describes what the code already says, delete it and write a skill instead.

## Structure, once there is content

One file per domain area, named after the area. Each carries the frontmatter from `../conventions/naming.md`, and each is listed in `../INDEX.md` with a line saying when to read it. The index line matters more than the document: an agent decides whether to open a file based on that one sentence. The initial domain document is [webmcp-contract.md](webmcp-contract.md).
