---
id: adr-0005-async-disposal-in-widget-test-bodies
title: "ADR 0005: Dispose async resources in test body try/finally, not in addTearDown"
status: active
owner: unassigned
last_verified: 2026-09-15
applies_to: ["example/test/**"]
summary: Widget tests that dispose WebMcpNativePublisher must await disposal directly in the test body via try/finally, not in addTearDown callbacks, to ensure the await completes.
---

# ADR 0005: Dispose async resources in test body try/finally, not in addTearDown

- Status: active
- Date: 2026-09-15
- Deciders: ortal.cohen@enpal.de

## Context and problem statement

When writing widget tests (`testWidgets`) that create and tear down a `WebMcpNativePublisher` (either directly or indirectly through `ExampleRuntime.dispose()`), how should the async disposal be sequenced to ensure the test completes without hanging?

During the implementation of work item 0014, the test harness required disposal of long-lived objects including a publisher. Initial attempts to place the async disposal call in a `testWidgets` tearDown callback via `addTearDown` resulted in the test hanging indefinitely — the `await publisher.detach()` call never settled.

## Decision drivers

- Test reliability: dispose calls must complete, never hang
- Predictability: the disposal pattern must be reproducible and not brittle
- Consistency: one pattern across all widget tests that own resources needing async disposal

## Considered options

### Option 1: Dispose in `addTearDown` with async callback

Place the async disposal in a callback passed to `addTearDown`:

```dart
testWidgets('example', (tester) async {
  final runtime = ExampleRuntime();
  addTearDown(() async { await runtime.dispose(); });
  // test code
});
```

Result: **Failed.** The `await runtime.dispose()` call, which ultimately calls `WebMcpNativePublisher.detach()`, never settled. The test hung.

### Option 2: Dispose in `addTearDown` wrapped with `tester.runAsync()`

Place the async disposal in `addTearDown` and wrap it with `tester.runAsync()`:

```dart
testWidgets('example', (tester) async {
  final runtime = ExampleRuntime();
  addTearDown(() => tester.runAsync(() async { await runtime.dispose(); }));
  // test code
});
```

Result: **Failed.** Same hang as Option 1. `tester.runAsync()` did not fix the issue.

### Option 3: Dispose in test body via try/finally

Place the async disposal directly in the test body, wrapped in `try/finally`:

```dart
testWidgets('example', (tester) async {
  final runtime = ExampleRuntime();
  try {
    // test code
  } finally {
    await runtime.dispose();
  }
});
```

Result: **Succeeded.** The `await runtime.dispose()` call settled immediately, and the test completed.

## Decision outcome

All widget tests that dispose `ExampleRuntime`, `ExampleRuntimeHarness`, or any resource that requires awaiting `WebMcpNativePublisher.detach()` must call the async disposal directly inside the test body via a `try/finally` block, never in an `addTearDown` callback.

This pattern ensures disposal completes reliably and guarantees test completion.

## Consequences

- Positive: Async resource disposal completes reliably; tests do not hang.
- Positive: The pattern is easy to verify and document in code comments.
- Negative: Tests have slightly more boilerplate than `addTearDown` would provide.
- Negative: Developers must remember to use `try/finally` rather than relying on a standard cleanup mechanism.

## Confirmation

Compliance is verified by:

1. **Code review:** Every test file under `example/test/` that constructs `ExampleRuntime` or `ExampleRuntimeHarness` must contain a `try/finally` block wrapping the test body, with `await runtime.dispose()` or `await harness.dispose()` in the `finally` block.

2. **Test execution:** The full example test suite (`cd example && flutter test`) must pass without hanging or timing out. A violation (removing the `try/finally` and using `addTearDown` instead) would cause the test process to hang indefinitely.

3. **Lint rule candidate:** A future static analyzer rule could flag direct calls to `runtime.dispose()` or `harness.dispose()` without a surrounding `try/finally` in the same function scope.

4. **Doc comment requirement:** Every `dispose()` method on a test harness class (e.g., `ExampleRuntime.dispose()`, `ExampleRuntimeHarness.dispose()`) carries a doc comment explaining this requirement and showing the correct usage pattern.

## Pros and cons of the options

### Dispose in addTearDown (async callback)

- Pros: Standard teardown pattern, minimal test body structure.
- Cons: The await never settles with `WebMcpNativePublisher`; tests hang.

### Dispose with tester.runAsync()

- Pros: Designed to handle async operations in tests.
- Cons: Does not fix the hang; root cause remains unresolved.

### Dispose in test body try/finally

- Pros: Await settles immediately; tests complete reliably; pattern is easy to verify and document.
- Cons: Slightly more boilerplate; developers must remember the pattern.

## More information

- [Work item 0014 STATE.yaml decision D-0014-11](../work/0014-example-feature-coverage/STATE.yaml)
- [ExampleRuntime.dispose() implementation](../work/0014-example-feature-coverage/example-runtime.dart)
- [Example widget test suite](../work/0014-example-feature-coverage/example-runtime-test.dart)
- [WebMcpNativePublisher](../product/webmcp-contract.md) — describes the browser boundary and publisher behavior
