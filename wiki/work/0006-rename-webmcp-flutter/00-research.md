# Research: Rename package to webmcp_flutter

## Question

What active repository references must change to rename the unpublished package from `webmcp_pilot` to `webmcp_flutter` without changing behavior or performing release work?

## Answer

The rename is mechanical but spans the root manifest and barrel, consumer imports, hygiene assertions, example identity and copy, logger labels, and generated dependency metadata. Use only `lib/webmcp_flutter.dart`; because this source is unpublished, retaining `lib/webmcp_pilot.dart` as a compatibility alias would create an unsupported second entry point without a consumer compatibility need.

## Findings

### Package and public entry point

- Claim: The root identity is `webmcp_pilot`, version `0.1.0`, and the single public barrel is `lib/webmcp_pilot.dart`; rename the manifest and barrel while leaving version, dependencies, platforms, exports, license, and behavior unchanged.
- Evidence: `pubspec.yaml:1-21`; `lib/webmcp_pilot.dart:1-8`; `LICENSE:1-3`.
- Source: repository files, inspected 2026-09-10.

### Active consumers and guards

- Claim: Root package imports occur in five root tests, and the hygiene guard embeds the old package prefix; all must use `package:webmcp_flutter/webmcp_flutter.dart` or `package:webmcp_flutter/src/` respectively.
- Evidence: `test/registry_test.dart:2`; `test/transport_selection_test.dart:2`; `test/webmcp_public_surface_test.dart:2`; `test/webmcp_scope_test.dart:2`; `test/widget_layer_test.dart:3`; `test/repo_hygiene_test.dart:250-266`.
- Source: repository search and files, inspected 2026-09-10.

### Example and visible identity

- Claim: Rename the example package to `webmcp_flutter_example`, its root path dependency to `webmcp_flutter`, and its root/example imports; update its description, page title, metadata, and app-bar label to WebMCP Flutter.
- Evidence: `example/pubspec.yaml:1-13`; `example/lib/example_tools.dart:1`; `example/lib/example_screen.dart:2,46`; `example/test/example_tools_test.dart:2-3`; `example/web/index.html:7-9`.
- Source: repository files, inspected 2026-09-10.

### Documentation, runtime labels, and generated metadata

- Claim: Update the active README identity and both logger names; preserve historical wiki references because they record prior artifacts and decisions.
- Evidence: `README.md:1-5`; `lib/src/webmcp_scope.dart:30-33`; `lib/src/transport/transport_web.dart:36-38`; `wiki/work/0005-pubdev-release-readiness/13-name-selection.md:35-41`.
- Source: repository files, inspected 2026-09-10.
- Claim: Dependency resolution must regenerate ignored root and example package configs and the tracked example lock entry; generated example build output must be rebuilt rather than hand-edited if produced during verification.
- Evidence: `.dart_tool/package_config.json:364-369`; `example/.dart_tool/package_config.json:166-176`; `example/pubspec.lock:211-217`; `.gitignore:31-34`.
- Source: generated metadata and ignore rules, inspected 2026-09-10.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| New-only barrel | Rename the manifest, barrel, and every active consumer to `webmcp_flutter` | Existing unpublished checkouts must resolve dependencies again | Chosen: one canonical API entry point matches the accepted name and current unpublished status. |
| Compatibility alias | Keep `lib/webmcp_pilot.dart` exporting the new barrel | Maintains two public entry points and requires permanent compatibility policy/tests | Rejected: no published consumer contract requires the legacy name. |

## Constraints discovered

- Scope is rename-only: keep version `0.1.0`, MIT license text, exported API, dependencies, platform support, and runtime behavior unchanged.
- The accepted root name is `webmcp_flutter`, barrel is `lib/webmcp_flutter.dart`, example is `webmcp_flutter_example`, and logger/display labels must match the new identity (`wiki/work/0005-pubdev-release-readiness/13-name-selection.md:7-9,37-41`).
- Historical wiki artifacts must remain unchanged and auditable (`wiki/work/0005-pubdev-release-readiness/13-name-selection.md:3-5,39`).

## Unresolved

- [UNRESOLVED: Whether `webmcp_flutter` remains available at publication time and whether the publishing Google Account has the required rights; both are release gates outside this rename-only work item.]

## Sources

- Repository source, manifests, tests, generated metadata, and ignore rules — consulted 2026-09-10.
- `wiki/work/0005-pubdev-release-readiness/13-name-selection.md` — consulted 2026-09-10.

Correction: `example/pubspec.lock` is ignored, not tracked (`git ls-files --error-unmatch example/pubspec.lock` reported no tracked match; `git check-ignore -v` identified `.gitignore:35`). The earlier phrase “tracked example lock entry” is superseded; dependency resolution regenerates this ignored lockfile alongside the ignored package configs.
