<!-- Research artifact for work item 0019-library-maintenance-wins -->

# Research: publish.yml / release.yml relationship and check-suite gate

## Question

How does `.github/workflows/publish.yml` relate to `.github/workflows/release.yml` and
`tools/check.sh`, and what is the smallest safe change so a version tag cannot publish
`webmcp_flutter` without the repository check suite passing?

## Answer

`release.yml` owns the full check suite (via `tools/check.sh`) and the version-tag creation.
`publish.yml` owns only pub.dev publication and is triggered solely by tag pushes, with no
check-suite step of its own. Because `publish.yml` fires on any conforming tag push — not only
the one that `release.yml` creates — a manually pushed tag today bypasses all checks and
publishes immediately. The smallest safe code change is to add a `check` job that runs
`tools/check.sh` inside `publish.yml` and declare `needs: check` on the existing `publish` job.
This satisfies pub.dev's requirement that publication come from a tag-triggered workflow run
while making the check suite unavoidable regardless of how the tag was created.

## Findings

### release.yml runs check.sh before tagging

- Claim: `release.yml` invokes `bash tools/check.sh` in the "Run package check suite" step,
  which must succeed before any version bump, commit, or tag push happens.
- Evidence: The step is defined at line 67 of `release.yml` and precedes the version-bump, tag
  collision check, commit, and push steps at lines 112–147.
- Source: `.github/workflows/release.yml` lines 67–68

### publish.yml has no check-suite step

- Claim: `publish.yml` does not call `tools/check.sh` or any equivalent quality gate. Its only
  steps after checkout are `flutter pub get`, a `--dry-run` publish, and the live publish.
- Evidence: The workflow contains three steps (lines 24–44): checkout, dependency install,
  `flutter pub publish --dry-run`, and `flutter pub publish --force`. No test, analysis, format,
  or build stage is present.
- Source: `.github/workflows/publish.yml` lines 24–44

### publish.yml fires on any conforming tag, not only release.yml tags

- Claim: The `on.push.tags` filter `v[0-9]+.[0-9]+.[0-9]+` matches any tag of that form,
  regardless of who or what pushed it. A developer with push access can push such a tag
  manually, and `publish.yml` will run without `release.yml` or `tools/check.sh` ever having
  run.
- Evidence: The trigger block contains no `workflow_run` condition or external branch-check
  requirement; it is a plain tag-push filter.
- Source: `.github/workflows/publish.yml` lines 12–14

### pub.dev OIDC requires a tag-triggered run

- Claim: pub.dev's automated publishing via GitHub Actions OIDC accepts only a workflow run
  whose trigger is a tag push; a `workflow_run` trigger would not satisfy this requirement
  because the triggering event for that outer run would be `workflow_run`, not `push`.
- Evidence: Documented in `wiki/product/release-pipeline.md` lines 18–23 ("Pub.dev accepts an
  automated publish only from a workflow run that a git tag push started") and confirmed by the
  `release.yml` header comment (lines 5–11).
- Source: `wiki/product/release-pipeline.md` lines 18–23;
  `.github/workflows/release.yml` lines 5–11

### tools/check.sh runs eight stages covering the full package set

- Claim: `tools/check.sh` runs wiki lint, pub-get across all packages, format, analysis, tests,
  web build, version-bump test, and occupied-versions test — in that order. A single stage
  failure aborts the entire script.
- Evidence: Stages 1–8 are defined at lines 20–74 with `stage_failed` guards.
- Source: `tools/check.sh` lines 1–74

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **A – Add `check` job in `publish.yml` with `needs: check` on the publish job** | A new job runs `tools/check.sh` inside the tag-triggered workflow, the publish job is blocked until it passes. The tag-triggered run type is preserved, so pub.dev OIDC is satisfied. | Check suite runs twice in the normal release flow (once in `release.yml`, once in `publish.yml`), adding ~5–10 minutes of CI per release. One step: add one job and one `needs:` line. | **Chosen.** Smallest code change; closes the gap regardless of tag origin; no repository-settings dependency. |
| **B – Move check.sh invocation from `release.yml` into `publish.yml` only** | Remove the check step from `release.yml`, rely solely on `publish.yml`. | A push to `main` that fails to produce a tag (e.g., version-collision) would still leave main in an unchecked state. Removes the gate on the bump step itself. | Rejected. Weakens the release.yml gate without fully closing the manual-tag gap; `release.yml` still needs the check to protect its own write steps. |
| **C – GitHub repository ruleset with required status checks on tag pattern** | A protected-tag ruleset requires the check suite to pass before a tag is accepted. | Repository-settings change only, no file change; requires GitHub rulesets (available on all plans). No double-run of check.sh. | Rejected for this research scope. Not a code change and depends on admin access being exercised; code-level enforcement (Option A) is self-contained in the repository. |
| **D – `workflow_run` trigger referencing `release.yml`** | `publish.yml` fires only when `release.yml` completes successfully. | Breaks pub.dev OIDC because the triggering event is `workflow_run`, not `push`. pub.dev rejects the authentication. | Rejected. Incompatible with pub.dev's OIDC requirement documented in `wiki/product/release-pipeline.md` lines 18–23. |

## Constraints discovered

1. **pub.dev OIDC is tag-trigger-only.** Any option that changes the `publish.yml` trigger away
   from `on.push.tags` breaks automated publishing. The trigger must remain.
   Source: `wiki/product/release-pipeline.md` lines 18–23.

2. **The loop guard in `release.yml` is commit-message–based**, not actor-based. A token push
   reports the token owner, not the bot actor, so actor comparison would not guard correctly.
   Source: `.github/workflows/release.yml` lines 35–37.

3. **check.sh requires Flutter and Dart binaries** installed before it can run. Option A would
   need a Flutter setup step before invoking `check.sh` in `publish.yml` — identical to what
   `release.yml` already does at lines 61–65.
   Source: `tools/check.sh` lines 7–13; `.github/workflows/release.yml` lines 60–65.

4. **check.sh is a single shell script for the whole monorepo.** It touches the generator,
   annotations, and example packages, not just the root package. Running it in `publish.yml`
   therefore validates more than strictly needed for publication, but there is no lighter
   partial-check variant today.
   Source: `tools/check.sh` lines 22–74.

## Unresolved

- [UNRESOLVED: Does GitHub's rulesets feature for protected tags (Option C) require a specific
  plan tier for this repository, or is it available on the free plan?]
- [UNRESOLVED: Is there a Flutter/Dart version pin in `release.yml` (3.47.0) that should also
  be kept in sync in `publish.yml`, or should `publish.yml` declare it independently?]

## Sources

| Source | Consulted |
|---|---|
| `.github/workflows/publish.yml` (full file) | 2026-10-11 |
| `.github/workflows/release.yml` (full file) | 2026-10-11 |
| `tools/check.sh` (full file) | 2026-10-11 |
| `wiki/product/release-pipeline.md` (full file) | 2026-10-11 |
| `wiki/work/0019-library-maintenance-wins/STATE.yaml` | 2026-10-11 |
