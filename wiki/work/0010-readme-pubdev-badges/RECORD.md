---
id: work-0010-readme-pubdev-badges
title: "Add pub.dev and project badges to the README"
status: active
owner: ortalcohen
last_verified: 2026-09-11
applies_to: ["README.md"]
summary: Quick-change record for adding package, CI, and license badges to the README.
---

# Add pub.dev and project badges to the README

## What changed and why

Added a compact badge row to the package README so pub.dev displays the package's
current version, pub.dev score signals, CI status, and license. Each badge links
to the relevant package, score, workflow, or repository license page.

## File touched

`README.md` (badge row added below the title).

## Five qualifying conditions

1. One requested source file changed - yes, only `README.md` was edited; this record and its state are workflow artifacts.
2. No new dependency - yes, the change uses external badge image URLs only.
3. No public interface, exported symbol, route, or schema change - yes, documentation only.
4. No data model, migration, or stored data change - yes, none involved.
5. No security, privacy, authentication, authorisation, or payment surface touched - yes, none touched.

## Test that covers it

The README was inspected after the edit and every badge has a non-empty image URL,
an HTTPS destination, and a destination matching the repository's verified package,
workflow, or license metadata. The network check for pub.dev was unavailable in
this environment, so live rendering and current pub.dev values remain
`[UNVERIFIED]`.

## Check output

`git diff --check`, the local badge validation, and `python3 tools/lint_wiki.py`
passed. The full repository suite reached wiki lint successfully, then stopped at
dependency setup because the pinned Flutter SDK cache is not writable in this
environment:

```
$ PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH bash tools/check.sh
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 71: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.stamp.tmp.46302: Operation not permitted
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 78: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.realm: Operation not permitted
Stage 2 failed: dependencies
```

The full suite is therefore `[UNVERIFIED]` beyond Stage 1; this is an SDK-cache
permission blocker, not evidence of a README defect.
