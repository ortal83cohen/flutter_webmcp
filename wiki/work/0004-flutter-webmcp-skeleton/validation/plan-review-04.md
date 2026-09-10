---
id: work-0004-plan-review-04
title: Analyzer import parser plan review, round 04
status: active
owner: unassigned
last_verified: 2026-09-10
applies_to: ["wiki/work/0004-flutter-webmcp-skeleton/09-parser-plan-amendment.md"]
summary: Bounded independent review of replacing handwritten import parsing with analyzer AST APIs.
---

# Plan review — round 04

- Work item: 0004-flutter-webmcp-skeleton
- Reviewed artifact: 09-parser-plan-amendment.md and the retained normative contract in 06-plan-amendment.md, against frozen 02-criteria.md.
- Reviewer: Codex parser plan validator
- Date: 2026-09-10

## Verdict

**PASS**

The bounded replacement plan preserves the import and secret criteria, specifies available public parser interfaces, and defines diagnostics, negative verification and rollback without changing runtime or public interfaces. This is a plan verdict, not an implementation verdict.

## Verification performed

Independently inspected the frozen criteria, both amendments, the validation rubric/template and required repository conventions. STATE.yaml was read for work-item phase metadata as required by the repository router; its author assessments were not used as verification evidence. The previous plan report was consulted only for recurrence. No implementation source or author verification notes were reviewed.

| Review boundary | Assessment and evidence |
|---|---|
| AC-018 forbidden imports | Amendment 09 lines 17–23 retains real import directives, decoded primary and conditional target URIs, both source roots and path/import diagnostics; amendment 06 line 11 retains the exhaustive URI predicates. |
| AC-044 Flutter boundary | Amendment 09 lines 23, 29 and 37 retains the lib/ scope, widgets exception and prohibited/allowed verification. |
| Public-surface and AC-045 test boundaries | Amendment 09 line 23 retains both existing test-file boundaries; amendment 06 line 11 defines them. |
| AC-032 secrets | Amendment 09 lines 7, 23, 29 and 39 leaves the independent full-text implementation, fixed marker set, roots, file classes and regressions intact. Amendment 06 lines 13–17 remains normative. |
| Parser correctness obligations | Amendment 09 lines 17–21 distinguishes conditional target URIs from comparison values, excludes exports/lookalikes, and fails with path context for diagnostics or unavailable values. |
| Interface and dependency scope | Amendment 09 lines 11, 27 and 47 specifies a direct development dependency, public analyzer imports in test code and no runtime analyzer imports. |
| Verification sufficiency | Amendment 09 lines 31–39 specifies regression controls, legal escaped/raw/triple fixtures, independent compilation evidence, expected policy rejection, restoration checks and the full suite. These remain implementation obligations. |
| Rollback and evidence preservation | Amendment 09 lines 27 and 45 confines rollback to captured files, regenerates ignored metadata, preserves unrelated edits and explicitly retains the known gap and historical artifacts. |

API inspection used the locally installed official analyzer 13.3.0 sources cited in the plan. The following independently executed commands produced these excerpts; omitted lines are unrelated implementation details.

```text
$ rg -n -A35 'ParseStringResult parseString' /Users/ortalcohen/.pub-cache/hosted/pub.dev/analyzer-13.3.0/lib/dart/analysis/utilities.dart
77:ParseStringResult parseString({
78-  required String content,
79-  FeatureSet? featureSet,
80-  String? path,
81-  bool throwIfDiagnostics = true,
82-}) {
83-  featureSet ??= FeatureSet.latestLanguageVersion();
...
111-  if (throwIfDiagnostics && result.errors.isNotEmpty) {

$ rg -n 'ImportDirective|Configuration|StringLiteral' /Users/ortalcohen/.pub-cache/hosted/pub.dev/analyzer-13.3.0/lib/dart/ast/ast.dart
85:        Configuration,
157:        ImportDirective,
233:        SimpleStringLiteral,
234:        SingleStringLiteral,
238:        StringLiteral,

$ rg -n -A35 '^abstract final class (Configuration|ImportDirective|StringLiteral|NamespaceDirective)' /Users/ortalcohen/.pub-cache/hosted/pub.dev/analyzer-13.3.0/lib/src/dart/ast/ast.dart
6433:abstract final class Configuration implements AstNode {
...
6456-  StringLiteral get uri;
...
6460-  StringLiteral? get value;
...
18396:abstract final class ImportDirective implements NamespaceDirective {
...

$ rg -n -A23 'class NamespaceDirective|class StringLiteral|class UriBasedDirective' /Users/ortalcohen/.pub-cache/hosted/pub.dev/analyzer-13.3.0/lib/src/dart/ast/ast.dart
23430:sealed class NamespaceDirective implements UriBasedDirective {
...
23436-  NodeList<Configuration> get configurations;
...
30903:sealed class StringLiteral implements Literal {
30904-  /// The value of the string literal, or `null` if the string isn't a constant
30905-  /// string without any string interpolation.
30906-  String? get stringValue;
...
34028:sealed class UriBasedDirective implements Directive {
34029-  /// The URI referenced by this directive.
34030-  StringLiteral get uri;
...
```

These source declarations support the planned API shape and null handling. Reading utilities.dart lines 61–76 also confirms that callers retaining diagnostics must inspect result.errors. Local pubspec.lock lists analyzer 13.3.0 as transitive; root pubspec.yaml has no analyzer declaration and requires Dart ^3.13.0, while analyzer's own manifest requires ^3.11.0. This source/manifest inspection does not claim a completed dependency-resolution run or compiler proof of the planned fixtures.

Pre-write wiki lint was executed independently:

```text
$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).
```

Exit status: 0.

Post-write wiki lint was also executed independently after creating this report:

```text
$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).
```

Exit status: 0. Lint validates repository document conventions; it does not validate the unimplemented parser replacement.

## Findings

None within this bounded plan amendment. No criterion violation or invalid API assumption was found. Historical implementation repairs are not declared verified by this report.

## Recurrence check

- Previous round: validation/plan-review-03.md, which reported no findings on amendment 06.
- Recurring findings: none in this plan round.
- Oscillating: no opposing or repeated plan finding is present in this comparison. This does not reassess implementation-round recurrence.

## Routing

No findings require defect-class routing. The main agent owns the phase transition and disposition. Planned implementation verification remains outstanding.
