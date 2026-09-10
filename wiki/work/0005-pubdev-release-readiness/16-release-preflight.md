# Release preflight and final deploy plan

## Decision

Prepare the first public release as `webmcp_flutter` version `0.1.0`, a stable release with a strictly detection-only contract. Do not use a prerelease for this launch: the stated objective includes pub.dev search visibility, and Dart documents that prereleases do not appear in search results or replace the stable README and documentation. The package must describe only the in-process registry, Flutter widget lifecycle helpers, browser capability detection, and logging that exist today. Browser tool publication, browser invocation, DOM discovery, and a WebMCP bridge remain outside this release.

This document is a deploy plan and evidence record. It authorizes no upload, source edit, Git mutation, account login, or publisher change.

## Current evidence

The current manifest declares `name: webmcp_flutter`, `version: 0.1.0`, Dart `^3.13.0`, and web-only platform support. The public barrel is `lib/webmcp_flutter.dart`. Work item 0006 records a passed independent implementation review for the rename and a fresh full-suite exit of zero. That suite proves the current local source, tests, example build, analysis, formatting, and wiki lint at the reviewed checkout; it does not prove that a publish archive is acceptable or that hosted installation works.

An unauthenticated request to `https://pub.dev/api/packages/webmcp_flutter` returned HTTP 404 on 2026-09-10. This supports current availability only; it neither reserves the name nor proves that pub.dev will accept the first upload. Recheck immediately before the upload.

The configured Git remote is `https://github.com/ortal83cohen/project-AI-skeleton`. An unauthenticated GitHub repository request returned HTTP 200, `private: false`, and `visibility: public`, while the root contents request returned HTTP 404 with `This repository is empty.` The remote is publicly accessible but does not contain this project. It is therefore not a truthful `repository` or `homepage` value for this release. The initial manifest should omit those optional URL fields. A later release may add the existing URL only after the actual candidate source is publicly present there, or add another verified public project URL; the plan does not guess or require a repository rename.

The pinned SDK command `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH dart pub publish --help` lists `--dry-run`, `--force`, `--skip-validation`, and `--directory`. It lists no archive-output or archive-extraction option. The plan must not depend on an invented write-archive flag. The official command reference likewise describes dry-run as validation without upload. Exact help and dry-run output is retained in `18-preflight-output.md`.

The required pinned-SDK dry-run resolved dependencies, displayed the intended file list and a 389 KB compressed archive, then exited 65. It reported two publication errors: potential AWS access keys in `wiki/work/0004-flutter-webmcp-skeleton/validation/impl-review-01.md`. It also reported five potential issues: a tracked ignored stale `lib/webmcp_pilot.dart`, 36 modified tracked files, no homepage or repository field, plural top-level `tools`, and a changelog that does not mention `0.1.0`. This candidate cannot be published as-is.

## Official requirements and recommendations

Dart's publishing documentation states that publishing is durable, that the package includes files below the root except hidden paths and paths ignored by `.pubignore` or `.gitignore`, and that a root `.pubignore` overrides the root `.gitignore`. It requires inspection of the dry-run file list. The dry-run validates pubspec and layout and shows intended files. Source: https://dart.dev/tools/pub/publishing.

The pubspec reference requires a hosted package name, version, and English description, and requires a lower SDK bound. `homepage` and `repository` are optional, although Dart asks publishers to provide at least one when truthful. `issue_tracker`, documentation, topics, funding, and verified-publisher metadata are also optional. The current package already has required name, version, description, SDK constraint, dependencies, and supported platform declaration. Source: https://dart.dev/tools/pub/pubspec.

The layout guide says a package's principal public library should usually match the package name, examples belong under `example`, tests belong under `test`, and private development scripts conventionally belong under singular `tool`. These are layout conventions. The dry-run currently treats plural `tools` as a potential issue, not one of its blocking errors. Source: https://dart.dev/tools/pub/package-layout.

Requirements for this launch are: a zero-error dry-run for the exact candidate; no secrets or personal data in the archive; required package metadata; a valid license; the importable library and all runtime files; a README and changelog that truthfully match `0.1.0`; a usable example; an available package name at upload time; and an authorized Google Account for the first upload. A verified publisher, public source URL, issue tracker, documentation URL, topics, screenshots, automated publishing, and team uploader setup are recommendations or later improvements, not launch requirements.

## Candidate contents and `.pubignore` default

Keep the public package payload focused on consumer material: `lib/**`, `LICENSE`, `README.md`, `CHANGELOG.md`, `pubspec.yaml`, and the runnable consumer example under `example/lib/**`, `example/web/**`, `example/pubspec.yaml`, and `example/analysis_options.yaml`. Keep any example asset only if the example declares or consumes it.

Create a root `.pubignore` during release implementation because the publish payload needs different rules from Git. It should explicitly exclude repository-agent configuration, CI configuration, IDE and OS files, generated caches and builds, lockfiles for this library package and example, wiki history, root development configuration, root tests, example tests, and internal repository tooling. In concrete path terms, exclude `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.cursor/`, `.github/`, `.idea/`, `.DS_Store`, `.dart_tool/`, `build/`, `pubspec.lock`, `analysis_options.yaml`, `wiki/`, `test/`, `example/.dart_tool/`, `example/build/`, `example/pubspec.lock`, `example/test/`, and `tools/`.

Excluding `tools/` while shipping `test/` would break the repository-hygiene tests because those tests exercise repository-only tooling and layout assumptions. The payload therefore excludes both `tools/` and the root `test/` tree coherently. Verification remains in the public source repository when one exists and in the release evidence, while the distributed package retains only runtime and consumer-example material. Do not add `false_secrets` merely to suppress the two current detections; excluding historical wiki evidence removes the irrelevant files from the consumer archive and avoids normalizing secret-shaped fixtures in published metadata.

Because `.pubignore` overrides `.gitignore`, repeat every relevant generated, local, environment, key, and secret exclusion in `.pubignore`; do not assume `.gitignore` continues to protect the payload. After adding it, inspect every dry-run path. If an unexpected file appears, stop and update the exclusion deliberately. If an expected runtime or example file is absent, stop and narrow the exclusion.

## Ordered release work

1. Prepare one clean candidate from the accepted rename state without altering the detection-only public behavior. Remove the stale tracked `lib/webmcp_pilot.dart` from the candidate index as part of the already completed rename record, preserve `lib/webmcp_flutter.dart`, and resolve every unrelated dirty-file warning through normal review and commit discipline. Do not revert or overwrite unrelated local work.
2. Replace the scaffold portion of `README.md` with consumer documentation. Lead with hosted installation for `webmcp_flutter: ^0.1.0`, show the public barrel import, include the working example, and state explicitly that the package detects browser capability but does not publish or invoke browser WebMCP tools. Document current registry ownership, duplicate-name behavior, lifecycle behavior, and web-only support without implying a bridge.
3. Replace the `Unreleased` changelog heading with a `0.1.0` entry dated for the eventual release. Describe the initial registry, widget lifecycle helpers, example, detection, and explicit detection-only limitation. Do not claim browser integration.
4. Add the minimal `.pubignore` described above. Leave optional source URLs absent while the configured remote is empty. Do not rename `tools/` solely for pub layout; it is repository infrastructure and is excluded together with its dependent tests.
5. Re-run the existing full suite with the pinned Flutter 3.47.0 toolchain after all release-file edits. Retain the exact output and exit code. A prior green suite cannot validate later README, changelog, ignore, or index changes.
6. Run the pinned-SDK dry-run and retain its complete file list, sizes, diagnostics, compressed size, and exit code. The launch gate is exit zero with no errors and no warnings. Inspect that only the intended runtime, metadata, and example paths are present. Do not use `--ignore-warnings`, `--skip-validation`, or `--force` to bypass evidence.
7. Validate the exact payload without relying on a nonexistent archive-output option. Reproduce the dry-run-selected tree in a disposable directory using the reviewed inclusion list, then point a clean disposable Flutter web consumer at that directory. Resolve dependencies, compile an import of `package:webmcp_flutter/webmcp_flutter.dart`, exercise the README usage, run any payload-contained example check that remains applicable, and build web. Record the payload file inventory and hashes so the tested tree can be compared with the final dry-run list. If pub's supported commands change and expose an official archive option later, prefer that verified option after checking `--help` again.
8. Recheck `https://pub.dev/api/packages/webmcp_flutter` immediately before upload. HTTP 404 remains the name gate; any package record or ambiguity stops this release for a new naming decision. Confirm the exact manifest still says `webmcp_flutter` and `0.1.0`.
9. Present the candidate evidence and the authenticated publishing identity to the user for the final production decision. The remaining account choice is intentionally a human gate because the first publisher becomes the initial authorized uploader. Record whether the upload will use an individual Google Account and whether transfer to a verified publisher is planned later. Do not capture or publish personal account data in the repository.
10. Only after explicit upload authorization, run the ordinary publish command from the exact reviewed clean candidate. Do not use `--force` for the first release. Review the displayed final contents and confirm interactively. After upload, verify the public package page, hosted dependency resolution for `^0.1.0`, API documentation, Example and Changelog tabs, web platform badge, and a clean external web build. Record the immutable version and results.

## Launch gates

The release is ready for a final upload decision only when all of the following are true:

- The exact candidate is clean and identified by an immutable Git commit, and the candidate contains the accepted `webmcp_flutter` rename with no stale old barrel.
- The README and `0.1.0` changelog describe the detection-only scope accurately and their examples compile from the tested payload.
- The archive contains only the approved metadata, runtime library, and consumer example files; it contains no wiki, agent configuration, repository tooling, repository tests, caches, lockfiles, credentials, personal data, or secret-shaped validation fixtures.
- The pinned full suite exits zero after the final candidate edits.
- `dart pub publish --dry-run` exits zero without errors or warnings, and its complete intended file list matches the reviewed payload inventory.
- A clean disposable Flutter web consumer resolves the payload, compiles the public import and README usage, and builds for web.
- The public registry check still returns no existing package record for `webmcp_flutter`.
- The user has named and authorized the Google Account that will own the first upload, reviewed the exact `0.1.0` candidate, and explicitly approved the production publication.

## Plan unknowns and post-upload checks

No implementation design choice remains open. The stable version, detection-only scope, package name, payload boundary, URL omission, and validation sequence have defaults above. Two facts cannot be resolved in a plan-only pass: whether the name remains available at the future upload instant, and which authorized Google Account the user will select for the first publication. Both are launch-time gates rather than reasons to change source now.

Publication itself is irreversible in the practical sense documented by pub.dev. If post-upload verification finds a minor defect, stop promotion and prepare a corrected higher version. Consider retraction only under current pub.dev rules and only after a separate production decision; retraction is not deletion.

## Warning-policy correction

The controlled diagnostic in `23-warning-policy-evidence.md` supersedes this document's earlier instruction to omit optional source URLs through launch. With all other observed diagnostics removed, a sanitized minimal candidate without `homepage` or `repository` still produced the sole warning recommending one of those fields and exited 65. Therefore the zero-warning, zero-exit dry-run gate and URL omission cannot both be satisfied under the pinned SDK without a bypass flag. This plan retains the stronger no-bypass release policy.

Before the final candidate dry-run, publish the actual reviewed project source at a verified publicly readable repository URL and add that truthful URL in the manifest's `repository` field. The current remote URL becomes acceptable only after its public repository contains the actual release source; its current empty state remains insufficient. This is a launch preparation step, not authorization to push, rename a repository, or expose the current dirty checkout. Re-run the unauthenticated repository and contents checks after the source is published, then require the ordinary dry-run to exit zero with no warnings. This correction supersedes the earlier URL-omission instructions in Current evidence, Official requirements and recommendations, Ordered release work step 4, and Plan unknowns and post-upload checks. All other release defaults remain unchanged.

## Final narrow warning waiver

The second controlled run in `23-warning-policy-evidence.md` supersedes the source-publication requirement in the preceding Warning-policy correction. On the same candidate, `dart pub publish --dry-run --ignore-warnings` reported exactly the single recommendation to add `homepage` or `repository`, reported no errors or other warnings, and exited zero. The supported `--ignore-warnings` option retains validation and is distinct from `--skip-validation` and `--force`.

The final policy is to omit the optional URL fields while no truthful public source URL exists and allow only this exact missing-`homepage`/`repository` warning. Run the ordinary dry-run first and require that its complete diagnostics contain zero errors and exactly that one warning. Then run the dry-run with `--ignore-warnings` on the identical candidate and require exit zero, the identical file list, zero errors, and the same single warning. Any additional or changed warning, any error, any payload difference, or any nonzero waiver-run exit stops the release. No source-repository publication, repository rename, or Git push is required to meet this plan. `--skip-validation` and `--force` remain prohibited.
