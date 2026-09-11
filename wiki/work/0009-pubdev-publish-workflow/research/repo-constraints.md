# Research: Repository constraints for GitHub Actions publish workflow

## Question

What constraints does this repository already impose on a new GitHub Actions publish job: existing checks workflow, package name/version, changelog format, wiki pipeline rules, and prior pub.dev release work in 0005, so a new workflow does not fight CI or republish an existing version.

## Answer

The repository enforces several hard constraints on automated publishing: the checks workflow already runs on all branches including main (creating potential test duplication), package webmcp_flutter version 0.1.1 is already defined and 0.1.0 was previously published to pub.dev, the wiki lint must pass before any publication, and the workflow must respect the frozen publication rules from work item 0005. The main branch is the default target for automation.

## Findings

### Existing CI workflow runs on all branches

- Claim: The checks workflow runs on all branches including main via the "**" pattern
- Evidence: `.github/workflows/checks.yml` line 4 specifies `branches: ["**"]`
- Source: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/.github/workflows/checks.yml:4

### Current package metadata and version

- Claim: The package is named webmcp_flutter at version 0.1.1 
- Evidence: `pubspec.yaml` specifies `name: webmcp_flutter` and `version: 0.1.1`
- Source: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/pubspec.yaml:1,3

### Previously published versions must not be reused

- Claim: Version 0.1.0 was successfully published to pub.dev and must never be reused
- Evidence: Work item 0005 STATE.yaml contains `name_gate: "Published webmcp_flutter0.1.0; hosted exact-version API and archive verified. Never attempt to reuse this version."`
- Source: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0005-pubdev-release-readiness/STATE.yaml:58

### Wiki lint enforcement requirement

- Claim: The wiki lint must pass before any release work
- Evidence: AGENTS.md line 20 states "Every change goes through the pipeline in `wiki/conventions/workflow.md`" and tools/check.sh line 20 runs `python3 tools/lint_wiki.py` as stage 1
- Source: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/AGENTS.md:20, /Users/ortalcohen/Documents/GitHub/flutter_webmcp/tools/check.sh:20

### Default branch is main

- Claim: The repository's default branch is main
- Evidence: `git symbolic-ref refs/remotes/origin/HEAD` returns `refs/remotes/origin/main`
- Source: git command output from repository

### Required files exist

- Claim: LICENSE and README.md files exist at repository root
- Evidence: Glob searches find LICENSE and README.md files in root directory
- Source: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/LICENSE, /Users/ortalcohen/Documents/GitHub/flutter_webmcp/README.md

### Changelog format follows conventional structure

- Claim: CHANGELOG.md uses version-based sections with dates
- Evidence: Entries follow "## 0.1.1 - 2026-09-10" and "## 0.1.0 - 2026-09-10" format
- Source: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/CHANGELOG.md:3,7

### Prior publication established version control rules

- Claim: Work item 0005 established rules that interactive publication with explicit confirmation is required
- Evidence: 34-final-publication-controls.md documents the corrected command is "ordinary interactive `dart pub publish`, retaining validation and explicit confirmation"
- Source: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0005-pubdev-release-readiness/34-final-publication-controls.md:19

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Extend existing checks.yml workflow | Add publish job to existing workflow with conditional execution on main branch and tags | Low implementation cost | Rejected: Would duplicate test execution since checks already runs on push to main |
| Create separate publish workflow | New workflow file triggered only on version tags, avoiding test duplication | Medium implementation cost | Chosen: Prevents duplicate CI runs and provides cleaner separation of concerns |

## Constraints discovered

- Version 0.1.0 is permanently reserved and cannot be republished
- Current version 0.1.1 is already defined in pubspec.yaml
- Any new workflow must pass wiki lint validation before proceeding
- The repository requires interactive confirmation for publication (no fully automated publishing)
- Main branch is the target for version tag-based automation
- Workflow must respect the existing 6-stage folder structure under wiki/work/ for any planning artifacts

## Unresolved

- [UNRESOLVED: Whether the automated workflow should handle version bumping or require manual pubspec.yaml changes before tagging]
- [UNRESOLVED: Specific tag naming convention to trigger the workflow (v0.1.2 vs 0.1.2)]
- [UNRESOLVED: Whether to implement dry-run validation in CI before allowing interactive publication]

## Sources

- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/.github/workflows/checks.yml (consulted 2026-09-10)
- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/pubspec.yaml (consulted 2026-09-10)
- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/CHANGELOG.md (consulted 2026-09-10)
- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/AGENTS.md (consulted 2026-09-10)
- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/tools/check.sh (consulted 2026-09-10)
- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0005-pubdev-release-readiness/STATE.yaml (consulted 2026-09-10)
- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0005-pubdev-release-readiness/34-final-publication-controls.md (consulted 2026-09-10)
- /Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/conventions/workflow.md (consulted 2026-09-10)