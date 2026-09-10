# Plan amendment: use the Dart analyzer for import semantics

## Goal and supersession

Replace the handwritten import tokenizer and string interpreter in test/repo_hygiene_test.dart with the official Dart analyzer parser. [Implementation review 03](validation/impl-review-03.md#f-001--initial-newline-in-a-valid-triple-quoted-import-uri-bypasses-both-source-boundaries) records F-001: a legal triple-quoted import with an initial newline compiles to a forbidden URI while the current detector preserves that newline and misses the boundary. The report confirms the previous Unicode and hexadecimal repairs remain effective. The main agent has recorded this deliberate design correction as a plan-phase re-entry in STATE.yaml.

This amendment supersedes the claim in [amendment 06](06-plan-amendment.md#approach-and-sequence) that a new dependency is unnecessary for the hygiene correction, and its implementation approach insofar as that approach permits handwritten Dart parsing. A direct development dependency on analyzer is now required for import recognition. The complete fixed-secret-marker contract, all scan scopes, diagnostic obligations and exclusions in amendment 06 remain unchanged. The [46 acceptance criteria](02-criteria.md) stay frozen with identical IDs and text. There is no public API, runtime dependency, package data model or browser behavior change. Earlier plans, reviews and evidence remain historical artifacts and are not deleted.

## Verified API basis

The currently resolved local pubspec.lock identifies analyzer 13.3.0 as transitive, while the root pubspec.yaml does not declare it directly. The implementation will declare analyzer with constraint ^13.3.0 under the root package's development dependencies; it must not rely on another development package to provide an undeclared import.

The installed official source at /Users/ortalcohen/.pub-cache/hosted/pub.dev/analyzer-13.3.0/lib/dart/analysis/utilities.dart declares parseString with content, path, featureSet and throwIfDiagnostics parameters. Its documentation states that callers retaining diagnostics must inspect the returned errors. The public library at /Users/ortalcohen/.pub-cache/hosted/pub.dev/analyzer-13.3.0/lib/dart/ast/ast.dart exports ImportDirective, Configuration and StringLiteral. The corresponding definitions in /Users/ortalcohen/.pub-cache/hosted/pub.dev/analyzer-13.3.0/lib/src/dart/ast/ast.dart establish that ImportDirective inherits its uri and configurations, each Configuration has a uri, and StringLiteral.stringValue provides the constant string value or null when unavailable. These source files establish the exact interfaces used by this plan; implementation imports must use the public libraries, not analyzer's internal source path.

## Approach and interfaces

Parse each source file as a Dart compilation unit using parseString. Select actual ImportDirective nodes, then inspect the stringValue of the directive's uri and every conditional configuration's uri. Apply the existing URI predicates to those decoded values, including conditional alternatives independent of the current platform selection. Conditional comparison values, exports, comments and strings in declarations are not import targets. Preserve offending-path and decoded-URI diagnostics.

Remove the custom token representation, tokenization, comment skipping, quote scanning and escape decoding. The analyzer owns Dart string semantics, including initial newlines in triple strings, raw strings and Unicode escapes. Adding another manual special case would retain the demonstrated mismatch between compiler semantics and the policy test. Parsing syntax is sufficient; resolving package libraries and their semantic elements is unnecessary to inspect declared import strings.

Do not silently turn parser diagnostics or an unavailable URI value into an empty successful scan. Surface such a case as a test failure with source-path context. Tests intended to demonstrate valid import behavior must contain syntactically valid Dart units. Invalid-source fixtures may test diagnostic handling but must not be counted as proof that a legal forbidden import is rejected.

The source-import roots remain lib/ and example/lib/, with the existing lib/src/widgets/ exception for Flutter imports and the existing public-surface and scope-test import boundaries. The secret scan remains a full-text, case-insensitive scan of tracked and nonignored new files in lib/, example/lib/, tools/ and .github/ across all extensions. It does not use the Dart parser or acquire new marker spellings.

## Sequence and file ownership

After recording the plan disposition, capture the current root pubspec.yaml and test/repo_hygiene_test.dart for a narrowly scoped rollback. Add the analyzer development dependency to pubspec.yaml and resolve dependencies with the pinned toolchain. Record the resolved analyzer version in the verification evidence; the ignored local lockfile remains subject to the existing repository policy.

Replace import extraction in test/repo_hygiene_test.dart with the public analyzer APIs. Keep classification and path rules intact, remove obsolete manual-parser helpers, and adapt helper-specific tests into meaningful import-policy regressions. Correct fixture ordering where imports currently follow declarations, since a real parser must receive a valid unit for a valid-source assertion. Preserve raw-literal content tests using syntax accepted by the toolchain. Retain the exhaustive secret-marker tests and implementation unchanged.

Add regression coverage for ordinary and raw triple-quoted imports with an initial newline, both quote styles, existing Unicode and hexadecimal spellings, whitespace and nested comments, conditional alternative URIs and conditional comparison strings that are not URIs. Preserve allowed imports, ignored exports and comment/string lookalikes as controls. Invalid-escape fixtures should verify reported parse failure instead of asserting that malformed source represents a successful clean scan.

## Verification methods

Run the focused hygiene test, then the complete root and example test stage, the full check suite and wiki lint. Record commands, actual outputs and exit statuses in a new append-only verification artifact. A positive baseline alone does not establish the boundaries.

In isolated temporary copies, introduce one legal forbidden import at a time into a relevant source file. Cover triple-quoted initial-newline forms including raw triples, fixed and braced Unicode, hexadecimal escapes, raw ordinary literals, intervening comments and conditional imports. Use dart:io and package:flutter/widgets.dart where the installed VM or Flutter compiler supports them so compilation can independently establish that the fixture is genuine Dart. Separate that compilation check from the expected hygiene rejection; parser acceptance alone is not compilation evidence. Demonstrate that each forbidden fixture fails the hygiene test with the path and decoded URI, and that the Flutter widget-directory exception remains allowed. Restore each temporary mutation and re-run the baseline before the next probe.

Check that conditional comparison values and string/comment lookalikes do not trigger the import policy, and that every conditional target is still inspected. Re-run the fixed-marker regressions to establish that replacing import parsing leaves the independent secret contract intact. Record a fresh independent implementation review of the changed artifact against the frozen criteria, retaining earlier review evidence for unchanged behavior where applicable. No check result is claimed by this plan.

## Risks, rollback and exclusions

The analyzer introduces a directly declared development dependency and its version compatibility must remain compatible with the pinned Dart SDK. Dependency resolution and the full suite provide the required evidence. The parser may reveal malformed test fixtures that the handwritten scanner accepted; fix the fixtures to represent the intended legal syntax, and retain explicit invalid-source diagnostics rather than disabling parser checks.

Rollback restores only the captured pre-correction content of pubspec.yaml and test/repo_hygiene_test.dart, preserving unrelated working-tree changes, then resolves dependencies and re-runs checks. Any ignored local dependency metadata is regenerated rather than committed as a new policy change. Record that rollback restores the known F-001 gap and therefore does not complete the task. Preserve this amendment and all validation artifacts; supersede the design in a later artifact if necessary.

This correction excludes analyzer imports in runtime library code, a new secret-detection service, broader scan roots, new acceptance criteria, publishing, remote CI execution without existing authorization and further handwritten Dart language interpretation.
