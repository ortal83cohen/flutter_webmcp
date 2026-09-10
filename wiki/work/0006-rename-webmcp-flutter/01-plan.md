# Plan: Rename package to webmcp_flutter

## Goal

Consumers and the example use the accepted webmcp_flutter identity and its single public barrel, with existing behavior preserved.

## Approach

Rename the root manifest identity and public barrel, then update root test imports, the hygiene guard, internal logger labels, and README. Preserve the barrel's exports and all implementation behavior.

Rename the example package and its path dependency, imports, display text, and web metadata. Regenerate ignored dependency metadata, including the example lockfile, through dependency resolution. Update active product documentation while preserving historical work artifacts.

## Why this approach

The mechanical new-only rename follows 00-research.md. A compatibility barrel is rejected because the package is unpublished and would acquire an unnecessary second public entry point. Release preparation is a separate work item.

## Steps

1. Update package identity, rename the barrel, and update root consumers and identity labels together.
2. Update example identity and consumers, then resolve dependencies for both packages with the pinned Flutter SDK.
3. Verify the rename and unchanged behavior, recording full-suite output and disposable negative probes.
4. Update active product documentation and record validation evidence without modifying historical artifacts.

## Interfaces and shared decisions

The root package is webmcp_flutter, its only barrel is lib/webmcp_flutter.dart, and the example package is webmcp_flutter_example. Human-facing branding is WebMCP Flutter. Version, license, exported symbols, dependencies, platforms, and runtime semantics stay unchanged. Existing local changes remain intact; ignored metadata stays ignored.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| Stale imports or package metadata | Medium | Compilation fails | Resolve both packages and run their tests | Import resolution failure |
| Unrelated local edits overwritten | Low | User work lost | Compare against the supplied pre-rename snapshot | Diff includes unrelated changes |
| Historical evidence rewritten | Low | Audit trail lost | Restrict wiki edits to current work and active product knowledge | Earlier work artifact differs |

## Rollback

Reverse only this work item's rename changes using the supplied pre-rename snapshot, restore the old barrel name, and resolve dependencies again. Preserve all pre-existing staged and unstaged changes and retain wiki artifacts with a recorded rollback disposition.

## Out of scope

Publishing, package-name reservation, account permissions, release-readiness gates in work item 0005, new features, compatibility shims, version changes, and commits or staging.

## Verification approach

Use the Flutter SDK under /Users/ortalcohen/fvm/versions/3.47.0/bin first on the executable search path. Run the full repository check script and wiki lint with exact output recorded. Inspect active references and generated package resolution, exercise existing public-import and example tests, and use disposable copies for each criterion's deliberate failure case. Compare rename changes against the supplied baseline to verify preserved behavior, metadata, and historical records.
