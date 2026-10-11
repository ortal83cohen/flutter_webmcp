# Research: Library maintenance wins

## Question

Which small changes tighten the published `webmcp_flutter` archive, stop an unchecked version tag from publishing, close the known public-API and `requestId` test gaps, and add the missing package and example documentation?

## Answer

The published archive currently includes `packages/` and `spikes/`, and `.pubignore` does not exclude either. `publish.yml` publishes on any matching version tag and does not run `tools/check.sh`. This work item's public-surface inventory is ten named symbols that the surface test does not reference. That inventory is not a claim that those are the only unreferenced exports. Four `requestId` boundary cases are untested. `pubspec.yaml` has no `issue_tracker`, `lib/webmcp_flutter.dart` has no library documentation, and `example/README.md` does not exist.

The blocking open questions from the research streams are closed below as recorded decisions. The only remaining unresolved item does not block the plan.

## Findings

### Published archive includes packages and spikes

- Claim: A dry run lists both `packages/` and `spikes/` in the archive, at a compressed size of 144 KB.
- Evidence: `dart pub publish --dry-run` output recorded by the archive stream.
- Source: `wiki/work/0019-library-maintenance-wins/research/publish-archive.md` lines 13–17; command run 2026-10-11.

### pubignore does not exclude those directories

- Claim: `.pubignore` excludes tests, tools, wiki, example tests, agent configuration, secrets, and generated files. It does not exclude `/packages/` or `/spikes/`.
- Evidence: The full ignore file was read.
- Source: `.pubignore` lines 1–43; `wiki/work/0019-library-maintenance-wins/research/publish-archive.md` lines 19–23.

### Neither directory is part of the root library

- Claim: No file under `lib/` imports `packages/` or `spikes/`. The companion packages have their own pubspecs and are not dependencies of the root package. `tools/check.sh` tests the companion packages from the workspace and never runs `spikes/`.
- Evidence: Repository search and the check script stages.
- Source: `wiki/work/0019-library-maintenance-wins/research/publish-archive.md` lines 25–47; `tools/check.sh` lines 25–67.

### Excluding packages changes the published example

- Claim: `example/pubspec.yaml` depends on the companion packages through relative paths. Excluding `/packages/` makes those paths unresolvable in a package downloaded from pub.dev. Those companion packages are not established as published.
- Evidence: Path dependencies at `example/pubspec.yaml` lines 14–27. README says publication availability of the companion packages is not established.
- Source: `example/pubspec.yaml` lines 14–27; `README.md` lines 470–472.

### Decision: exclude both directories and keep path dependencies

- Claim: `/packages/` and `/spikes/` will be excluded. The example path dependencies stay, because there are no published versions to retarget. `example/README.md` must say the example is run from a repository checkout.
- Evidence: Retargeting would require packages that the repository does not claim are published. CI runs from the checkout, where the paths still exist.
- Source: `wiki/work/0019-library-maintenance-wins/research/publish-archive.md` lines 55–76; `README.md` lines 470–472.

### A tag can publish without the check suite

- Claim: `release.yml` runs `bash tools/check.sh` before it tags. `publish.yml` runs dependency install, a dry run, and `flutter pub publish --force`, with no check suite. Its tag filter matches any `v[0-9]+.[0-9]+.[0-9]+` tag.
- Evidence: The two workflows and the check script.
- Source: `.github/workflows/release.yml` lines 66–67; `.github/workflows/publish.yml` lines 12–14 and 24–44; `tools/check.sh` lines 1–74.

### Decision: add a check job inside the tag-triggered publish workflow

- Claim: The smallest safe change is a `check` job in `publish.yml` that runs `tools/check.sh`, with the existing publish job depending on it. The tag trigger stays. The check in `release.yml` stays. The Flutter pin stays `3.47.0`, using the Flutter setup action already used by `publish.yml`.
- Evidence: A `workflow_run` trigger would leave the publication run triggered by something other than a tag push, which the release pipeline says pub.dev does not accept. Moving the check out of `release.yml` would weaken the gate around its own write steps.
- Source: `wiki/product/release-pipeline.md` lines 18–23; `wiki/work/0019-library-maintenance-wins/research/publish-workflow.md` lines 70–98; `.github/workflows/publish.yml` lines 28–31.

### This work item's surface-test inventory is ten named symbols

- Claim: The surface test does not reference `WebMcpEvidenceKind`, `WebMcpPageErrorCode`, `webMcpMaxSafeInteger`, `webMcpPageProtocolVersion`, `WebMcpBindingViewProvider`, `WebMcpViewBinding`, `WebMcpViewProvider`, `WebMcpInputShape`, `webMcpSafeIntegerMinimum`, or `webMcpSafeIntegerMaximum`. These ten are the inventory for this work item. The public library exports additional names through unfiltered exports, and this finding does not claim the ten are every unreferenced export.
- Evidence: The first seven are exported by the page barrel. The last three are declared in the typed-input library, which the public library exports. None of the ten names appear in the surface test. `lib/webmcp_flutter.dart` exports whole libraries without a `show` filter.
- Source: `lib/src/page/page.dart` lines 4–15; `lib/src/webmcp_typed_input.dart` lines 4–10; `lib/webmcp_flutter.dart` lines 1–13; `test/webmcp_public_surface_test.dart` lines 43–72.

### requestId has two fences and four untested cases

- Claim: A normalised `requestId` below 1 or above `webMcpMaxSafeInteger` returns `invalidArguments`. The maximum is `9007199254740991` and the protocol version is `1`. A repeated latest id returns the cached receipt only when the six-field fingerprint matches; otherwise it returns `duplicateRequest`. Tests cover an ordinary success, an exact repeat, and an out-of-order lower id. They do not cover zero, the maximum, one above the maximum, or the same id with a different action.
- Evidence: The act guard, the protocol constants, and the existing page tests.
- Source: `lib/src/page/webmcp_page.dart` lines 1010–1032; `lib/src/page/webmcp_page_protocol.dart` lines 4–7; `wiki/work/0019-library-maintenance-wins/research/tests-and-docs.md` lines 26–48.

### Documentation gaps

- Claim: `pubspec.yaml` has `repository` and `homepage` and no `issue_tracker`. `lib/webmcp_flutter.dart` is export statements only. `example/README.md` does not exist. The root README describes a matching retry without saying that the six wire fields must match.
- Evidence: The files and a glob that found no example README.
- Source: `pubspec.yaml` lines 4–5; `lib/webmcp_flutter.dart` lines 1–13; `README.md` lines 352–355; `wiki/work/0019-library-maintenance-wins/research/tests-and-docs.md` lines 50–66.

### Decision: issue tracker URL and library documentation

- Claim: `issue_tracker` will be `https://github.com/ortal83cohen/flutter_webmcp/issues`. That is the tracker. The existing README link ending in `/issues/new/choose` remains the issue-creation form and is not copied into the field. The public library file will gain a short library doc comment naming `WebMcp`, `WebMcpPage`, and `WebMcpNativePublisher`, pointing readers to the README, and stating that browser publication is experimental. It will not claim that the companion packages are on pub.dev.
- Evidence: The repository and homepage already use that GitHub repository. The library file currently has no doc comment.
- Source: `pubspec.yaml` lines 4–5; `README.md` lines 14–16; `lib/webmcp_flutter.dart` lines 1–13.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Exclude both `/packages/` and `/spikes/` | Two rooted ignore entries; repository checks stay unchanged | Published example path dependencies to the companion packages no longer resolve | Chosen. Neither directory is part of the root library. |
| Exclude only `/spikes/` | One ignore entry | The archive still ships companion-package sources, tests, and fixtures | Rejected. It leaves the larger unrelated tree in the consumer archive. |
| Retarget the example to published companion versions before excluding `packages/` | Replace path dependencies with version constraints | Those packages are not established as published | Rejected. The constraints would not resolve. |
| Check job inside `publish.yml` | Tag trigger remains; publish waits for `tools/check.sh` | The suite runs again on a normal release | Chosen. It closes a manually pushed tag without changing the pub.dev trigger. |
| Publish only after `release.yml` through `workflow_run` | Publication starts from the release workflow result | The publication run is no longer started by the tag push | Rejected. The release pipeline says pub.dev accepts an automated publish only from a tag-triggered run. |
| Extend the existing surface and page tests | Add the missing assertions and four boundary cases in the current test files | Small edits in two test files | Chosen. The private act path is already reached by the widget tests. |
| Add a separate unit test for the private act method | Reach the private method without the widget harness | Needs a new access seam | Rejected. The widget tests already call the public tool. |

## Constraints discovered

- Pub includes files under the package root except hidden files and paths ignored by `.pubignore` or `.gitignore`. A root `.pubignore` overrides `.gitignore` for that directory. Source: https://dart.dev/tools/pub/publishing#what-files-are-published, consulted 2026-10-11.
- `tools/check.sh` needs Flutter and Dart on the path and validates the whole checkout, including the companion packages and example. Source: `tools/check.sh` lines 7–13 and 22–67.
- `webMcpMaxSafeInteger + 1` is a valid Dart integer, so the upper fence is reachable without a floating-point conversion. Source: `lib/src/page/webmcp_page_protocol.dart` line 7.
- Integer-valued doubles are normalised before the fence, so the upper-bound rejection case must send an integer above the maximum. Source: `wiki/work/0019-library-maintenance-wins/research/tests-and-docs.md` lines 81–82.
- Documentation must not say the annotation or generator packages are published on pub.dev. Source: `README.md` lines 470–472.
- Const integers need value assertions. An `isNotNull` check does not establish the protocol contract. Source: `lib/src/page/webmcp_page_protocol.dart` lines 4–7; `lib/src/webmcp_typed_input.dart` lines 4–7.

## Unresolved

- [UNRESOLVED: Whether GitHub protected-tag rulesets are available on this repository's plan. This does not block the plan because the chosen enforcement is the workflow file, not a repository ruleset.]
- [UNRESOLVED: Which exported names outside this work item's ten-symbol inventory are still unreferenced by the surface test. That inventory is intentionally not exhaustive. Covering the remaining exports is a later work item.]

## Sources

- `wiki/work/0019-library-maintenance-wins/research/publish-archive.md`, consulted 2026-10-11.
- `wiki/work/0019-library-maintenance-wins/research/publish-workflow.md`, consulted 2026-10-11.
- `wiki/work/0019-library-maintenance-wins/research/tests-and-docs.md`, consulted 2026-10-11.
- `.pubignore`, `.github/workflows/publish.yml`, `.github/workflows/release.yml`, `tools/check.sh`, `pubspec.yaml`, `lib/webmcp_flutter.dart`, `lib/src/page/page.dart`, `lib/src/page/webmcp_page.dart`, `lib/src/page/webmcp_page_protocol.dart`, `lib/src/webmcp_typed_input.dart`, `test/webmcp_public_surface_test.dart`, `example/pubspec.yaml`, `README.md`, and `wiki/product/release-pipeline.md`, consulted 2026-10-11.
- https://dart.dev/tools/pub/publishing#what-files-are-published, consulted 2026-10-11.
