# Research: Legacy changelog migration and package scope

## Question

How can request-based release notes start safely when the root changelog still has legacy `Unreleased` content, and which package records belong to this work item?

## Answer

Scope the request-based changelog to the root `webmcp_flutter` package. Do not assign the legacy `Unreleased` bullets to an existing or future version from heading order alone: preserve them verbatim and block a request release until a one-time, evidence-backed disposition records whether they were already published, remain pending, or must be moved to a specifically verified version.

New release-note text may come only from the shared design request records supplied for this work item. Commit messages and pull-request text are not release-history evidence and must not be used to reconstruct or embellish notes.

## Evidence

### The root changelog contains unresolved legacy content

- The root package currently declares `webmcp_flutter` version `0.1.4` (`pubspec.yaml:1-3`).
- `CHANGELOG.md` has numbered sections for `0.1.4`, `0.1.3`, and `0.1.2`, each with the generic bullet `Automated patch release from main.` (`CHANGELOG.md:3-13`).
- A non-empty `Unreleased` section follows those newer sections and contains product claims about automatic page semantics, optional annotation/generator packages, and preserved manual behavior (`CHANGELOG.md:15-22`). Its position proves only the current Markdown layout; it does not prove which archive, if any, contained those changes.
- Earlier release research verified only `0.1.0` and `0.1.1` as published at that time (`wiki/work/0009-pubdev-publish-workflow/00-research.md:25-29`). The repository's operator document repeats only those two as irreversible publications (`wiki/product/release-pipeline.md:50-55`).
- `[UNVERIFIED]` Whether `0.1.2`, `0.1.3`, or `0.1.4` was successfully published. Numbered local headings and the current pubspec version are insufficient proof of external publication.
- `[UNVERIFIED]` Whether any legacy `Unreleased` bullet was present in the payload of a published version. No inspected local record maps those bullets to an exact published archive.

### Existing automation cannot safely decide the migration

- Work item 0009 deliberately made the bump helper own only `pubspec.yaml` and `CHANGELOG.md` mechanics (`wiki/work/0009-pubdev-publish-workflow/STATE.yaml:54-59`). Its plan inserts a dated version at the top after checking only for a duplicate computed version (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:17-17`, `wiki/work/0009-pubdev-publish-workflow/01-plan.md:27-27`).
- The prior plan explicitly excluded release notes beyond the changelog section and package re-scoping (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:101-103`). It therefore supplies no authority to interpret or rewrite the legacy bullets.
- Published versions are treated as irreversible in the existing plan (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:95-99`). A silent carry-forward could publicly reannounce old work, while silently assigning it backward would fabricate history.

### Package scope is the root package only

- Work item 0009 is titled and planned specifically for publishing `webmcp_flutter` (`wiki/work/0009-pubdev-publish-workflow/STATE.yaml:1-4`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:3-5`).
- The repository also contains separate package manifests for `webmcp_flutter_annotations` version `0.1.0` and `webmcp_flutter_generator` version `0.1.0` (`packages/webmcp_flutter_annotations/pubspec.yaml:1-4`; `packages/webmcp_flutter_generator/pubspec.yaml:1-4`). The generator consumer fixture is explicitly non-publishable (`packages/webmcp_flutter_generator/example/pubspec.yaml:1-4`).
- No `packages/*/CHANGELOG.md` file exists in the inspected repository inventory. `[UNVERIFIED]` Whether either nested package has ever been published; local versions do not establish publication.
- `.pubignore` excludes repository-only, CI, cache, and lockfile material but has no explicit `/packages/` rule (`.pubignore:1-43`). `[UNRESOLVED]` Whether the nested package trees enter the root package archive under pub's default rules; resolve later by inspecting the exact dry-run payload before publication.

## Options considered

| Option | Effect | Decision |
|---|---|---|
| Assign legacy bullets to `0.1.4` from their location | Produces a tidy history but asserts an unproved payload mapping | Reject: retroactively fabricates release history. |
| Copy legacy bullets into the next request release | Avoids losing text but can announce already-shipped work again | Reject unless exact pending status is verified first. |
| Delete legacy bullets when request notes begin | Removes ambiguity | Reject: destroys an audit trail and violates the repository's preservation rule. |
| Preserve legacy text and block release pending explicit disposition | Keeps evidence intact and prevents accidental reannouncement | Chosen: fail closed until each legacy bullet is classified from verified evidence. |
| Expand request changelogs to all package manifests | Couples independent package versions and missing changelogs | Reject: existing release scope is the root package only. |

## Planning constraints

- Define a one-time migration gate before request-based notes can publish: every existing legacy bullet must be retained verbatim and classified as already published, still pending, or unresolved, with evidence for any version assignment.
- An unresolved classification blocks release-note generation or publication; it must not be silently copied into a new version section.
- Generate new note text only from the work item's shared design request records. This is an input constraint from the user request, not a repository-history claim.
- Do not mine commit messages or pull-request content, invent missing rationale, or backfill earlier numbered releases.
- Read and write only the root `CHANGELOG.md` and root `pubspec.yaml` for this work item. Nested package release support requires a separate scope decision, changelog policy, criteria, and publication-history verification.
- Validate the exact root publish payload before any real publication because the current `.pubignore` does not settle nested-package inclusion.

## Unresolved

- `[UNRESOLVED: Which published archive, if any, first contained each legacy Unreleased change?]`
- `[UNRESOLVED: Are root versions 0.1.2, 0.1.3, and 0.1.4 actually published externally?]`
- `[UNRESOLVED: Have webmcp_flutter_annotations or webmcp_flutter_generator ever been published?]`
- `[UNRESOLVED: Does the root dry-run archive include files under packages/ with the current .pubignore?]`

## Sources

- `CHANGELOG.md` (consulted 2026-09-11)
- `pubspec.yaml` (consulted 2026-09-11)
- `.pubignore` (consulted 2026-09-11)
- `packages/webmcp_flutter_annotations/pubspec.yaml` (consulted 2026-09-11)
- `packages/webmcp_flutter_generator/pubspec.yaml` (consulted 2026-09-11)
- `packages/webmcp_flutter_generator/example/pubspec.yaml` (consulted 2026-09-11)
- `wiki/work/0009-pubdev-publish-workflow/STATE.yaml` (consulted 2026-09-11)
- `wiki/work/0009-pubdev-publish-workflow/00-research.md` (consulted 2026-09-11)
- `wiki/work/0009-pubdev-publish-workflow/01-plan.md` (consulted 2026-09-11)
- `wiki/product/release-pipeline.md` (consulted 2026-09-11)
- User-provided work-item design constraint (received 2026-09-11)
