# Documentation implementation evidence

## Scope

Task 1.3 updates the consumer README and product contract for the selected
`webmcp_flutter` 0.1.0 release. It adds focused tests for retained semantics
that did not previously have direct contract evidence. The frozen criteria
remain unchanged.

## Implemented contract

The README now provides hosted installation, the public package import, and
exactly one complete Dart `lib/main.dart` example for payload consumer
compilation. It states the Flutter 3.47.0 and Dart 3.13.0 minimums, web-only
scope, and the lack of browser publication and browser-originated invocation.

The product documentation records the existing local registry, sequential
source registration, shallow schema, raw local result and error, widget,
custom transport, reset, and detection-only browser semantics selected in
21-release-decisions.md. It does not expand runtime behavior.

Focused tests assert partial source registration, shared nested schema
values without runtime validation, unchanged local result and exception
objects, direct invocation with a disabled child, registry mutation before a
throwing custom transport notification, and reset without transport
notifications.

## Verification

Command:

`dart format test/registry_test.dart test/widget_layer_test.dart test/transport_selection_test.dart`

Exit status: 0.

```text
Formatted test/registry_test.dart
Formatted 3 files (1 changed) in 0.01 seconds.
```

The unpinned `flutter` executable could not run the focused files because it
resolved to Dart 3.10.3, below the frozen Dart 3.13.0 minimum. This is retained
as environment evidence and is not a test verdict. The parent verification
owner will run the full suite with the pinned Flutter 3.47.0/Dart 3.13.0 SDK.

Command:

`flutter test test/registry_test.dart test/widget_layer_test.dart test/transport_selection_test.dart`

Exit status: 1.

```text
Resolving dependencies...
The current Dart SDK version is 3.10.3.

Because webmcp_flutter requires SDK version ^3.13.0, version solving failed.
Failed to update packages.
```

Command:

`python3 tools/lint_wiki.py`

Exit status: 0.

```text
lint_wiki: clean (0 warning(s)).
```

Command:

`rg -n '^```dart$|^void main\(' README.md`

Exit status: 0.

```text
26:```dart
30:void main() {
```

This proves the README has exactly one Dart fence and that its complete sample
contains `main`. The consumer compilation remains owned by the later payload
verification task.

Command:

`git diff --check -- README.md wiki/product/README.md wiki/product/webmcp-contract.md test/registry_test.dart test/widget_layer_test.dart test/transport_selection_test.dart wiki/work/0005-pubdev-release-readiness/24-docs-implementation.md`

Exit status: 0.

```text
```

## Canonical-suite repair

The parent-owned first canonical pinned suite found that the disabled-child
test used `ElevatedButton` while the file intentionally imports only
`package:flutter/widgets.dart`. The test now uses a `GestureDetector` with a
null tap callback to represent a disabled child without widening its imports.

Command:

`/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart format test/widget_layer_test.dart && /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart analyze --fatal-infos --fatal-warnings test/widget_layer_test.dart`

Exit status: 0.

```text
Formatted test/widget_layer_test.dart
Formatted 1 file (1 changed) in 0.01 seconds.
Analyzing widget_layer_test.dart...
No issues found!
```
