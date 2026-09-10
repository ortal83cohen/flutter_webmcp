# Plan amendment: fixed hygiene marker definitions

## Goal and supersession

This is a plan-phase re-entry for F-003 in [implementation review 01](validation/impl-review-01.md#f-003--exhaustive-secret-marker-conformance-has-no-fixed-comparison-set). AC-032 delegates its marker definitions to the Interfaces section of [the original plan](01-plan.md#interfaces), but that section names categories without enumerating their literals. This amendment supplies that missing definition so an implementer and an independent validator can compare the same fixed set.

This document supersedes only the paragraph headed “Forbidden import list, Flutter-import rule and secret-token list” in the original plan's Interfaces section. The replacement contract is stated below. All other original plan provisions remain in force. The original artifact remains available as the historical record. The [acceptance criteria](02-criteria.md) remain frozen, with their IDs and behavior scope unchanged; this amendment adds no acceptance criterion or feature.

## Replacement Interfaces paragraph

The repository-hygiene test in test/repo_hygiene_test.dart fails when a Dart file under lib/ or example/lib/ imports dart:html, dart:js, package:js, dart:io or package:http, including library paths within the named packages. It fails when a Dart file under lib/ outside lib/src/widgets/ contains an import directive whose URI begins with package:flutter/. Export directives remain outside this import rule. It fails when the public-surface test imports anything under lib/src/, or test/webmcp_scope_test.dart imports anything from package:flutter_test/. Import recognition must cover valid directives across whitespace, newlines and intervening comments, rather than requiring the import keyword and URI to share a line. These are the existing import boundaries, including AC-018 and AC-044.

The secret-marker scan covers tracked files and nonignored new files under lib/, example/lib/, tools/ and .github/, regardless of extension. A missing directory contributes zero files. It examines the full text of each file, with case-insensitive matching anywhere in that text, and fails with the offending path and marker when any fixed marker below occurs. It does not restrict detection to individual lines or Dart files.

The complete private-key-header set consists of the four exact literals “-----BEGIN PRIVATE KEY-----”, “-----BEGIN RSA PRIVATE KEY-----”, “-----BEGIN EC PRIVATE KEY-----” and “-----BEGIN OPENSSH PRIVATE KEY-----”. The AWS-access-key marker is the literal prefix “AKIA”; detection requires no following characters and imposes no suffix-length condition.

The complete assignment-target set consists of the seven literals “application_key”, “application-key”, “applicationkey”, “app_key”, “app-key”, “appkey” and “password”. An assignment marker is any one of those literals followed by zero or more whitespace characters and then either a colon or an equals sign. Whitespace includes newlines. No assigned value is required to identify the marker. Matching applies anywhere in the full file text, as for the other markers. These enumerations are exhaustive; implementations must not substitute an inferred category list or an additional spelling.

## Approach and sequence

Clarify the existing textual contract before modifying the hygiene test. This keeps the missing normative definition separate from the implementation defect in F-002 and avoids treating the current implementation as its own specification. A broad secret-detection service or a new dependency would exceed the existing fixed-marker contract and is unnecessary for this correction.

After the main agent records disposition of this plan re-entry, update only the hygiene-test behavior needed to implement this contract and the existing import criteria. Preserve file scopes and diagnostic requirements. Use synthetic fixtures in isolated temporary copies for negative probes, preserving the user's working-tree changes. Record the resulting commands, outputs and exit statuses in an append-only verification artifact. Keep the original review and earlier evidence intact.

## Validation methods

Compare this amendment against frozen AC-032 and the original Interfaces paragraph to establish that every category now has an explicit comparison set. Inspect the hygiene test against each enumerated marker and assignment spelling. Exercise all four key headers, the bare AWS prefix, every assignment spelling with each separator, mixed casing, and whitespace that crosses a newline. Confirm that each negative probe fails and names its file and marker. Include tracked and nonignored new files, non-Dart files, and each of the four directory roots; retain the existing YAML probe from AC-032.

Exercise valid multiline forbidden imports and multiline Flutter imports outside the widget directory, including the intervening-comment form recorded in F-002. Confirm that these fail with the path and import while allowed imports and the widget-directory exception still pass. Re-run the hygiene test after restoring each isolated mutation, then the full check suite and wiki lint. Paste command output before reporting a passed check. This amendment records planned validation only and claims no completed or passing check.

## Risks, rollback and exclusions

The fixed AWS prefix and assignment markers can match synthetic examples or ordinary text. That is a consequence of the specified literal scan; test fixtures therefore stay outside the scanned roots or in disposable copies. This is not a general credential classifier, and no additional formats, roots, production services or public interfaces enter scope.

If the hygiene correction must be rolled back, restore only the previous implementation of test/repo_hygiene_test.dart from a snapshot captured before the correction, preserve unrelated edits, and re-run the checks. Record that this restoration also restores the known detection gaps; do not treat it as resolution of F-002 or F-003. Retain this amendment and all evidence. If the normative definition itself needs replacement, supersede it in a new artifact rather than deleting or silently rewriting the record.
