# Research: pub.dev release readiness

## Question

What is missing before the current webmcp_pilot package can be published responsibly to pub.dev?

## Answer

The root package has a license, public library, example and tests, but release documentation and evidence are incomplete. This is a plan for a detection-first registry release, not an app-store deployment or a browser bridge implementation. See the three research streams below for source evidence.

## Findings

The package audit is recorded in [04-package-audit.md](04-package-audit.md), the source and quality audit in [05-quality-audit.md](05-quality-audit.md), and current official requirements in [06-publishing-rules.md](06-publishing-rules.md). Their raw evidence is retained unchanged.

### Classification and evidence clarifications

README cleanup, versioned release notes, verified project URLs and the prior capability comparison are project release gates, not claims that pub rejects all packages without them. Repository/homepage metadata is recommended by Dart. LICENSE and valid package metadata are publishing requirements. Sources: https://dart.dev/tools/pub/publishing and https://dart.dev/tools/pub/pubspec (accessed 2026-09-10).

The tracked-file approximation in 04-package-audit.md is not an archive manifest. In particular, hidden directories such as .claude, .cursor and .github are normally excluded by pub. Visible wiki, tools, AGENTS.md and CLAUDE.md require deliberate review. A .pubignore overrides the .gitignore in its directory, so generated-file exclusions must be preserved. Source: https://dart.dev/tools/pub/publishing (accessed 2026-09-10).

The MIT license exists. The previous work item records user authorization for its holder wording; this plan preserves it rather than reopening that decision. Redistribution rights for any additional material remain to be verified. Source: ../0004-flutter-webmcp-skeleton/STATE.yaml, decision implement dated 2026-09-10.

Both current SDK probes stopped at the same cache-permission error. These are unresolved environment checks, not proven source defects; earlier suite evidence remains historical and does not validate a future release candidate. Exact commands and output are in 04-package-audit.md and 05-quality-audit.md.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Detection-first prerelease | Ship documented existing scope after release gates | Packaging and verification work | Recommended provisional release direction; final version requires owner decision |
| Detection-first stable 0.1.0 | Keep current version with the same documented scope | Same release gates, stronger consumer expectations | Viable if owner accepts this as the public contract |
| Full browser integration first | Expand transport and browser execution capability | New research, interfaces and tests | Deferred; not required for truthful publication of current scope |
| Immediate publication | Upload existing tree | Lowest immediate effort | Rejected because documentation and verification gaps remain |

## Constraints discovered

Preserve existing staged changes and all historical wiki artifacts. Do not publish, commit, push, or change source during this planning request. The first release scope must explicitly disclose no browser tool publication. Source: user request, AGENTS.md, README.md:9 and ../0004-flutter-webmcp-skeleton/STATE.yaml.

## Unresolved

- [UNRESOLVED: final release channel/version, canonical public URLs, name availability and publisher account ownership.]
- [UNRESOLVED: capability comparison required by work item 0004; complete before freezing implementation criteria, route scope-changing findings back to planning.]
- [UNRESOLVED: successful full suite, dry-run archive manifest and warnings, browser runtime detection and tested compatibility.]

## Sources

All sources were inspected on 2026-09-10. See the three linked research streams for repository line references, official URLs and exact command output. No publication was attempted.
