# Code and product quality audit

## Scope and boundary

This is a planning-only audit of the current public library, package metadata, README, tests, example, and continuous integration configuration. It does not evaluate or implement browser tool publication, and it does not run a publish dry-run. The intended release is the detection-first `webmcp_pilot` registry described in `README.md:3-9` and implemented by `lib/src/transport/transport_web.dart:10-38`: it detects `document.modelContext`, reports registry changes, and explicitly does not publish tools to the browser.

The completed 0004 work item records one publishing prerequisite that remains open: a line-by-line capability comparison with KickNext/flutter_webmcp v0.3.0 and intentcall_webmcp (`wiki/work/0004-flutter-webmcp-skeleton/STATE.yaml:10-13`). This audit records that dependency but does not perform the separate comparison.

## Release blockers

### Q-001 — The pub.dev landing page would contain obsolete scaffold claims

`README.md:11-83` switches from the package description to the original agent-workflow scaffold. It says the repository is empty and has no product code (`README.md:13`), instructs readers to bootstrap a product (`README.md:17-21`), and says `wiki/product/` is empty (`README.md:69`) even though the public library and product contract now exist. pub.dev renders the README as the package landing page, so publishing this text would materially misdescribe the product.

Required release work: replace the scaffold content with package-focused installation, a minimal detection-first registry example, widget lifecycle usage, supported platform/toolchain statements, collision and teardown behavior, and an explicit statement that no browser bridge is included. Keep the accurate boundary already stated at `README.md:9`.

### Q-002 — The current working tree has no fresh green full-suite evidence

The required `bash tools/check.sh` run exited 1 at dependency resolution because Flutter attempted to write `/Users/ortalcohen/flutter/bin/cache/engine.stamp`, which is outside the writable workspace. Only wiki lint completed. The script therefore did not reach format, static analysis, root tests, example tests, or the web build (`tools/check.sh:23-40`). Current readiness cannot inherit an earlier result because the working tree contains package and test changes.

Required release work: rerun the same command in an environment where the Flutter SDK cache is writable and require exit 0 before release. CI is configured to run the same script with Flutter 3.47.0 (`.github/workflows/checks.yml:29-49`), but no current remote CI result was inspected in this audit.

Exact command and output:

```text
$ bash tools/check.sh
Preflight: flutter and dart found
warning: wiki/work/0005-pubdev-release-readiness: no 01-plan.md yet.
lint_wiki: clean (1 warning(s)).
Stage 1 passed: wiki lint
/Users/ortalcohen/flutter/bin/internal/update_engine_version.sh: line 64: /Users/ortalcohen/flutter/bin/cache/engine.stamp: Operation not permitted
Stage 2 failed: dependencies
```

Exit code: 1.

### Q-003 — The release prerequisite capability comparison is still pending

The 0004 state explicitly assigns a line-by-line comparison against KickNext/flutter_webmcp v0.3.0 and intentcall_webmcp as a prerequisite for publishing (`wiki/work/0004-flutter-webmcp-skeleton/STATE.yaml:10-13`). Until that work distinguishes supported, deliberately deferred, and accidentally missing behavior, the release scope is not fully justified.

Required release work: complete and cite that comparison before freezing the release plan. Browser publication may remain deferred; any resulting documentation must describe actual detection-first behavior rather than implying parity with packages that publish or invoke browser tools.

### Q-004 — Versioned release notes are not prepared

The manifest declares version 0.1.0 (`pubspec.yaml:1-3`), while `CHANGELOG.md:3-5` still places the initial package under `Unreleased`. A published immutable version should have a matching 0.1.0 section and release date or an explicitly approved date policy.

Required release work: convert the current entry to a 0.1.0 release entry and ensure it describes the detection-only boundary, rather than merely saying “WebMCP registry.”

### Q-005 — Public package provenance is unresolved

The manifest has name, description, version, SDK, dependencies, and a web platform declaration (`pubspec.yaml:1-21`), but no `repository`, `homepage`, `issue_tracker`, or `topics` metadata. The configured Git remote is `https://github.com/ortal83cohen/project-AI-skeleton`, whose name still describes the source scaffold and is not verified as the intended public home of `webmcp_pilot`.

Required release work: decide and verify the canonical public repository and issue tracker, then add only verified URLs. Do not infer the release URL from the current remote. Topics and homepage are useful discovery metadata but may be omitted if repository and issue routing are deliberate.

## Important quality work before release

### Q-006 — Installation and compatibility claims need a single enforceable contract

The README says to use a path dependency and claims Flutter 3.47.0 and web-only support (`README.md:5`). The manifest constrains Dart to `^3.13.0` and declares only the web platform (`pubspec.yaml:5-6`, `pubspec.yaml:20-21`), but it does not declare a Flutter lower bound. CI pins Flutter 3.47.0 (`.github/workflows/checks.yml:39-44`).

Plan work should decide whether 3.47.0 is the actual minimum or only the verified CI version. Encode an actual minimum in package constraints if required, and make the README installation instructions appropriate for a pub.dev package. Any broader compatibility claim remains `[UNVERIFIED]` until tested.

### Q-007 — Browser behavior has build coverage, not runtime coverage

The web transport checks `document.modelContext` and stores the result privately (`lib/src/transport/transport_web.dart:14-24`). Its test only reads the source file and asserts that two strings are present (`test/transport_web_source_test.dart:5-11`). The check suite builds the example for web (`tools/check.sh:38-40`), which proves compilation when it runs, but neither test exercises detection in a browser or verifies observable behavior for present and absent `modelContext`.

For a detection-first release, retain the explicit “tools not published” documentation and add a browser-level detection test or clearly label runtime detection as unverified. Do not treat a source-string assertion or successful web compilation as browser behavior evidence.

### Q-008 — The public API test is useful but shallow

The public-surface test imports only `package:webmcp_pilot/webmcp_pilot.dart` and compiles the exported types and core registry operations (`test/webmcp_public_surface_test.dart:1-51`). This is good evidence that the barrel export at `lib/webmcp_pilot.dart:1-8` exposes the intended API. It does not verify documentation examples, package consumption from a clean external application, or compatibility across supported Flutter versions.

Add at least one README example that is compiled or mirrored by a test, and use the example package as the release smoke consumer after the README is rewritten.

### Q-009 — Several edge semantics are implemented but not documented as public promises

The registry sorts snapshots and makes the returned list unmodifiable (`lib/src/webmcp.dart:52-59`), validates names and rejects duplicates (`lib/src/webmcp.dart:18-33`), and the tests cover those behaviors (`test/registry_test.dart:22-74`). Scope tests cover ownership, duplicate skipping, idempotent close, and invalid additions (`test/webmcp_scope_test.dart:22-85`). Widget tests cover mounted lifetime, unchanged child identity, callback updates, descriptor identity, schema copying, missing scopes, and duplicate ownership (`test/widget_layer_test.dart:65-225`).

The README currently summarizes only a subset at `README.md:7`. Before publishing, document the semantics consumers need to design around: global singleton lifetime, first-registration-wins, scoped duplicate skipping, mounted actions remaining invokable even when their child is disabled, and mounted descriptor identity on widget updates. The fuller internal contract already states several of these at `wiki/product/webmcp-contract.md:15-29`; the public README should carry the consumer-relevant subset.

## Optional hardening

- `WebMcpTool` and `WebMcpAction` copy only the outer input-schema map (`lib/src/webmcp_tool.dart:12-19`; `lib/src/widgets/webmcp_action.dart:13-22`). Nested lists and maps remain mutable. Either document this as shallow immutability or add deep JSON-value validation/copying in a later interface change.
- `registerSource` registers tools sequentially (`lib/src/webmcp.dart:35-40`). If a later descriptor is invalid or duplicates an existing name, earlier descriptors from the same source remain registered. Transactional batch registration is not part of the current contract; document or test the partial-registration behavior if consumers may depend on batch atomicity.
- `reset` clears the registry without sending unregistration callbacks to the previous transport (`lib/src/webmcp.dart:73-77`). This is harmless for the current no-op and logging transports, but it must be reconsidered before a future transport publishes external browser state.
- The CI actions use major-version tags (`.github/workflows/checks.yml:13-16`, `.github/workflows/checks.yml:33-40`). Pinning actions to immutable commit SHAs is optional supply-chain hardening.
- Coverage measurement, a supported-version matrix, and a release workflow are absent. They are useful follow-up work but are not necessary to define a narrow 0.1.0 detection-first package if the single pinned suite is green and publication remains manual.

## Existing strengths

- The actual web implementation and top of the README consistently say that tools are not published (`lib/src/transport/transport_web.dart:10-38`; `README.md:9`).
- The public library has doc comments on exported types and members, and analysis is configured to require public member documentation (`analysis_options.yaml:15-17`). A successful analyzer run is still required because the current full check did not reach that stage.
- Registry, scope, widget lifetime, public surface, transport selection, example logic, import boundaries, and secret-marker hygiene all have focused tests under `test/` and `example/test/`.
- CI uses the repository’s canonical check script rather than duplicating a weaker command sequence (`.github/workflows/checks.yml:48-49`).
- An MIT license is present (`LICENSE:1-20`). The authorized holder spelling should be reviewed as part of final human release metadata review, but this audit found no missing license file.

## Unresolved items

- `[UNRESOLVED]` Exact findings from the required capability comparison with KickNext/flutter_webmcp v0.3.0 and intentcall_webmcp.
- `[UNRESOLVED]` A green current `bash tools/check.sh` result; the only run in this audit exited 1 due to Flutter SDK cache permissions.
- `[UNRESOLVED]` Current remote CI status; workflow configuration was inspected, not a GitHub Actions run.
- `[UNRESOLVED]` The canonical public repository, homepage, and issue-tracker URLs for package metadata.
- `[UNRESOLVED]` The package-name availability and exact contents/warnings of the publish artifact; the separate publish dry-run stream owns this check.
- `[UNRESOLVED]` Live browser detection behavior with and without `document.modelContext`; no browser runtime test was found or run.
- `[UNRESOLVED]` Compatibility outside the single Flutter 3.47.0 version pinned in CI.

## Readiness verdict

Not ready for pub.dev release in the current state. The detection-first registry is coherent and has meaningful focused tests, but publication should wait for a package-focused README, versioned changelog, verified provenance metadata, the required competitor capability comparison, and a fresh full-suite exit 0. Browser bridge implementation is not a condition of this verdict; accurate disclosure of its absence is.
