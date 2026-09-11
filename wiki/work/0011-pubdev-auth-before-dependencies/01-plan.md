# Plan: Prevent pub.dev OIDC auth from breaking dependency resolution

## Goal

The tag-triggered publishing workflow shall resolve the package's public dependencies successfully before pub.dev OIDC authentication is installed, while retaining temporary OIDC authentication for the dry-run and final publication.

## Approach

Replace the reusable publishing workflow invocation with a small repository-owned workflow. It will check out the tagged source, install Flutter, resolve dependencies without a pub.dev token, install Dart OIDC authentication, restore Flutter tooling, and run the dry-run and publication commands.

The existing tag trigger and OIDC permission remain unchanged. No long-lived pub.dev credential will be added, and the release workflow remains outside this change.

## Why this approach

Keeping the reusable workflow preserves less repository code but preserves the failing order. Adding a long-lived token would bypass the symptom at the cost of a larger credential surface. The custom workflow is selected because the official guide permits custom workflows and the dependency-resolution boundary is the specific observed failure.

## Steps

1. Record the observed workflow order, the authorization failure, and the OIDC constraints in this work item.
2. Replace the publish job definition with the ordered custom workflow while keeping tag matching and OIDC permissions intact.
3. Validate YAML structure, wiki lint, and the repository diff; report the GitHub Actions rerun as pending external verification.

## Interfaces and shared decisions

The package remains `webmcp_flutter`; tags remain `v` followed by semantic version numbers; publication remains authenticated by GitHub OIDC; no repository or package credentials are stored in source control.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| OIDC remains invalid at pub.dev | Medium | High | Keep the final publication steps OIDC-authenticated and require a tagged rerun | The rerun fails after authentication with a token validation error |
| Flutter setup shadows the intended Dart binary | Low | Medium | Set up Flutter again after OIDC provisioning, matching the official workflow's Flutter requirement | Dry-run cannot load Flutter package metadata |

## Rollback

Restore the prior publish workflow from version control if the custom ordering fails and the reusable workflow is repaired upstream.

## Out of scope

Changing pub.dev package administration, GitHub repository secrets, release versioning, branch protection, or pushing a tag.

## Verification approach

Check the workflow text for the required ordering and permissions, run wiki lint and whitespace validation, and inspect the final diff. A successful GitHub Actions tag run is required to confirm the external OIDC exchange and publication.
