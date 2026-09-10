# Negative-check execution evidence

## Scope and method

Executed sequentially in `/private/tmp/webmcp-negative-_wohjh67`, a synthetic committed snapshot of the implementation; source mutations were restored immediately. The main checkout was never mutated by these probes. The snapshot was refreshed with final widget and hygiene fixes before the `Rerun-` checks. AC-031 timing and its delayed-run negative evidence are owned by `04-notes.md`.

The initial AC-017c and AC-041 probes exposed test gaps. The implementation was corrected and both exact mutations were executed again; the rerun evidence supersedes their initial undetected results, which remain recorded below. No acceptance criterion was changed.

Some structural criteria intentionally have a successful shell exit for the defective implementation: their failure is the observed missing stage or successful continuation after a failing test. The detected column evaluates the criterion, not merely the exit code.

## Results

| Probe | Exit | Defect detected / expected positive observed |
|---|---|---|
| AC-009 | 1 | True |
| AC-010 | 1 | True |
| AC-011 | 1 | True |
| AC-012 | 1 | True |
| AC-013 | 1 | True |
| AC-014 | 1 | True |
| AC-015 | 1 | True |
| AC-016 | 1 | True |
| AC-017a | 1 | True |
| AC-017b | 1 | True |
| AC-017c | 0 | False |
| AC-018 | 1 | True |
| AC-019 | 1 | True |
| AC-020 | 1 | True |
| AC-021 | 1 | True |
| AC-034a | 1 | True |
| AC-034b | 1 | True |
| AC-035 | 1 | True |
| AC-036 | 1 | True |
| AC-037 | 1 | True |
| AC-038 | 1 | True |
| AC-039 | 1 | True |
| AC-040 | 1 | True |
| AC-041 | 0 | False |
| AC-042 | 1 | True |
| AC-043 | 1 | True |
| AC-044 | 1 | True |
| AC-045 | 1 | True |
| AC-004 | 1 | True |
| AC-005 | 2 | True |
| AC-006 | 0 | True |
| AC-007-positive | 0 | True |
| AC-007 | 3 | True |
| AC-008 | 2 | True |
| AC-022 | 1 | True |
| AC-023 | 1 | True |
| AC-032 | 1 | True |
| AC-046 | 3 | True |
| AC-002-positive | 1 | True |
| AC-002 | 1 | True |
| AC-003-positive | 1 | True |
| AC-003 | 0 | True |
| AC-001 | 0 | True |
| Rerun-AC-017c | 1 | True |
| Rerun-AC-038 | 1 | True |
| Rerun-AC-039 | 1 | True |
| Rerun-AC-040 | 1 | True |
| Rerun-AC-041 | 1 | True |
| Rerun-AC-042 | 1 | True |
| Rerun-AC-043 | 1 | True |
| Rerun-AC-044 | 1 | True |
| Rerun-AC-045 | 1 | True |

## Command output excerpts

Exact captured output follows. Large outputs are explicitly excerpted; full raw temporary logs remain under `/private/tmp/webmcp-negative-logs`. No omitted output is treated as evidence.

### AC-009

```text
$ flutter test --reporter expanded test/registry_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +0 -1: registers tools and lists them in ascending order [E]
  Expected: ['alpha', 'middle', 'zeta']
    Actual: MappedListIterable<WebMcpTool, String>:[]
     Which: at location [0] is MappedListIterable<WebMcpTool, String>:[] which shorter than expected
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 28:5                        main.<fn>
00:00 +0 -1: registers sources through duplicate validation
00:00 +0 -2: registers sources through duplicate validation [E]
  Expected: an object with length of <2>
    Actual: []
     Which: has length of <0>
[middle output omitted]
     Which: has length of <0>
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 73:5                        main.<fn>
00:00 +0 -4: passes arguments through and awaits the handler
00:00 +0 -5: passes arguments through and awaits the handler [E]
  WebMcpToolNotFoundException: No registered tool has this name. (tool: echo)
  package:webmcp_pilot/src/webmcp.dart 68:7  WebMcp.invokeTool
  test/registry_test.dart 84:34              main.<fn>
00:00 +0 -5: throws for a missing tool without invoking another handler
00:00 +1 -5: unregister is idempotent
00:00 +1 -6: unregister is idempotent [E]
  Expected: true
    Actual: <false>
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 111:5                       main.<fn>
00:00 +1 -6: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: passes arguments through and awaits the handler
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: registers sources through duplicate validation
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: registers tools and lists them in ascending order
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: rejects duplicates without replacing the first handler
  ... and 2 more
exit=1
```

### AC-010

```text
$ flutter test --reporter expanded test/registry_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +1 -1: registers sources through duplicate validation [E]
  Expected: throws <Instance of 'WebMcpDuplicateToolException'>
    Actual: <Closure: () => void>
     Which: returned <null>
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 42:5                        main.<fn>
00:00 +1 -1: rejects duplicates without replacing the first handler
00:00 +2 -1: validates empty, long, and unsupported names
00:00 +3 -1: passes arguments through and awaits the handler
00:00 +4 -1: throws for a missing tool without invoking another handler
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: registers sources through duplicate validation
exit=1
```

### AC-011

```text
$ flutter test --reporter expanded test/registry_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +1 -1: registers sources through duplicate validation [E]
  Expected: throws <Instance of 'WebMcpDuplicateToolException'>
    Actual: <Closure: () => void>
     Which: returned <null>
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 42:5                        main.<fn>
00:00 +1 -1: rejects duplicates without replacing the first handler
00:00 +1 -2: rejects duplicates without replacing the first handler [E]
  Expected: throws <Instance of 'WebMcpDuplicateToolException'> with `toolName`: 'same'
    Actual: <Closure: () => void>
     Which: returned <null>
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 52:5                        main.<fn>
00:00 +1 -2: validates empty, long, and unsupported names
00:00 +2 -2: passes arguments through and awaits the handler
00:00 +3 -2: throws for a missing tool without invoking another handler
00:00 +4 -2: unregister is idempotent
00:00 +5 -2: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: registers sources through duplicate validation
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: rejects duplicates without replacing the first handler
exit=1
```

### AC-012

```text
$ flutter test --reporter expanded test/registry_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +3 -1: validates empty, long, and unsupported names [E]
  Expected: throws <Instance of 'WebMcpInvalidToolNameException'>
    Actual: <Closure: () => void>
     Which: returned <null>
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 67:7                        main.<fn>
00:00 +3 -1: passes arguments through and awaits the handler
00:00 +4 -1: throws for a missing tool without invoking another handler
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: validates empty, long, and unsupported names
exit=1
```

### AC-013

```text
$ flutter test --reporter expanded test/registry_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +4: passes arguments through and awaits the handler
00:00 +4 -1: passes arguments through and awaits the handler [E]
  Expected: <42>
    Actual: <null>
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/registry_test.dart 84:5                        main.<fn>
00:00 +4 -1: throws for a missing tool without invoking another handler
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: passes arguments through and awaits the handler
exit=1
```

### AC-014

```text
$ flutter test --reporter expanded test/registry_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +4: passes arguments through and awaits the handler
00:00 +5: throws for a missing tool without invoking another handler
00:00 +5 -1: throws for a missing tool without invoking another handler [E]
  Expected: throws <Instance of 'WebMcpToolNotFoundException'> with `toolName`: 'missing'
    Actual: <Instance of 'Future<Object?>'>
     Which: emitted <0>
  package:matcher                                    expectLater
  package:flutter_test/src/widget_tester.dart 507:8  expectLater
  test/registry_test.dart 96:11                      main.<fn>
00:00 +5 -1: unregister is idempotent
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: throws for a missing tool without invoking another handler
exit=1
```

### AC-015

```text
$ flutter test --reporter expanded test/registry_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart
00:00 +0: registers tools and lists them in ascending order
00:00 +1: registers sources through duplicate validation
00:00 +2: rejects duplicates without replacing the first handler
00:00 +3: validates empty, long, and unsupported names
00:00 +4: passes arguments through and awaits the handler
00:00 +5: throws for a missing tool without invoking another handler
00:00 +6: unregister is idempotent
00:00 +6 -1: unregister is idempotent [E]
  WebMcpToolNotFoundException: No registered tool has this name. (tool: temporary)
  package:webmcp_pilot/src/webmcp.dart 46:7  WebMcp.unregisterTool
  test/registry_test.dart 113:28             main.<fn>
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: unregister is idempotent
exit=1
```

### AC-016

```text
$ flutter test --reporter expanded test/transport_selection_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart
00:00 +0: selects noop on the Dart VM and resets transport
00:00 +0 -1: selects noop on the Dart VM and resets transport [E]
  Expected: 'fake'
    Actual: 'noop'
     Which: is different.
            Expected: fake
              Actual: noop
                      ^
             Differ at offset 0
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/transport_selection_test.dart 29:5             main.<fn>
00:00 +0 -1: notifies registration and unregistration in order
00:00 +0 -2: notifies registration and unregistration in order [E]
  Expected: ['registered:observed', 'unregistered:observed']
    Actual: []
     Which: at location [0] is [] which shorter than expected
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/transport_selection_test.dart 48:5             main.<fn>
00:00 +0 -2: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart: notifies registration and unregistration in order
  /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
exit=1
```

### AC-017a

```text
$ flutter test --reporter expanded test/webmcp_public_surface_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart
test/webmcp_public_surface_test.dart:45:14: Error: Undefined name 'WebMcpException'.
      expect(WebMcpException, isNotNull);
             ^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:46:14: Error: Undefined name 'WebMcpInvalidToolNameException'.
      expect(WebMcpInvalidToolNameException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:47:14: Error: Undefined name 'WebMcpDuplicateToolException'.
      expect(WebMcpDuplicateToolException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:48:14: Error: Undefined name 'WebMcpToolNotFoundException'.
      expect(WebMcpToolNotFoundException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:49:14: Error: Undefined name 'WebMcpScopeMissingException'.
      expect(WebMcpScopeMissingException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^
00:00 +0 -1: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart [E]
  Failed to load "/private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart":
  Compilation failed for testPath=/private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart: test/webmcp_public_surface_test.dart:45:14: Error: Undefined name 'WebMcpException'.
        expect(WebMcpException, isNotNull);
               ^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:46:14: Error: Undefined name 'WebMcpInvalidToolNameException'.
        expect(WebMcpInvalidToolNameException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:47:14: Error: Undefined name 'WebMcpDuplicateToolException'.
        expect(WebMcpDuplicateToolException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:48:14: Error: Undefined name 'WebMcpToolNotFoundException'.
        expect(WebMcpToolNotFoundException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:49:14: Error: Undefined name 'WebMcpScopeMissingException'.
        expect(WebMcpScopeMissingException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart
exit=1
```

### AC-017b

```text
$ flutter test --reporter expanded test/webmcp_public_surface_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart
test/webmcp_public_surface_test.dart:44:14: Error: Undefined name 'WebMcpAction'.
      expect(WebMcpAction, isNotNull);
             ^^^^^^^^^^^^
00:00 +0 -1: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart [E]
  Failed to load "/private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart":
  Compilation failed for testPath=/private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart: test/webmcp_public_surface_test.dart:44:14: Error: Undefined name 'WebMcpAction'.
        expect(WebMcpAction, isNotNull);
               ^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_public_surface_test.dart
exit=1
```

### AC-017c

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +3: implementation files contain no fixed secret markers
00:00 +4: All tests passed!
exit=0
```

### AC-018

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +0 -1: library and example sources avoid forbidden imports [E]
  Expected: empty
    Actual: ['example/lib/example_tools.dart: import \'dart:html\';']
  example/lib/example_tools.dart: import 'dart:html';
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 37:5                    main.<fn>
00:00 +0 -1: Flutter imports stay inside the widget layer
00:00 +1 -1: public and scope tests preserve their import boundaries
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
exit=1
```

### AC-019

```text
$ flutter test --reporter expanded test/transport_selection_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart
lib/src/transport/transport_web.dart:2:8: Error: Dart library 'dart:js_interop' is not available on this platform.
import 'dart:js_interop';
       ^
Context: The unavailable library 'dart:js_interop' is imported through these packages:
    /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart => package:webmcp_pilot => dart:js_interop
    /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart => package:webmcp_pilot => package:web => dart:js_interop
    ...
Detailed import paths for (some of) the these imports:
    listener.dart => /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport_selector.dart => package:webmcp_pilot/src/transport/transport_web.dart => dart:js_interop
    listener.dart => /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport_selector.dart => package:webmcp_pilot/src/transport/transport_web.dart => package:web/web.dart => package:web/src/dom.dart => package:web/src/dom/accelerometer.dart => dart:js_interop
    listener.dart => /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport_selector.dart => package:webmcp_pilot/src/transport/transport_web.dart => package:web/web.dart => package:web/src/dom.dart => package:web/src/dom/accelerometer.dart => package:web/src/dom/generic_sensor.dart => dart:js_interop
    listener.dart => /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport_selector.dart => package:webmcp_pilot/src/transport/transport_web.dart => package:web/web.dart => package:web/src/dom.dart => package:web/src/dom/accelerometer.dart => package:web/src/dom/generic_sensor.dart => package:web/src/dom/dom.dart => dart:js_interop
    listener.dart => /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart => package:webmcp_pilot/webmcp_pilot.dart => package:webmcp_pilot/src/webmcp.dart => package:webmcp_pilot/src/transport/transport_selector.dart => package:webmcp_pilot/src/transport/transport_web.dart => package:web/web.dart => package:web/src/dom.dart => package:web/src/dom/accelerometer.dart => package:web/src/dom/generic_sensor.dart => package:web/src/dom/dom.dart => package:web/src/dom/css_font_loading.dart => dart:js_interop
[middle output omitted]
      }.jsify();
        ^^^^^
  /Users/ortalcohen/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/helpers/http.dart:245:33: Error: The argument type 'ProgressEvent' can't be assigned to the parameter type 'Object'.
   - 'Object' is from 'dart:core'.
          completer.completeError(e);
                                  ^
  /Users/ortalcohen/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/helpers/http.dart:249:34: Error: The argument type 'void Function(Object, [StackTrace?])' can't be assigned to the parameter type 'void Function(ProgressEvent)?'.
   - 'Object' is from 'dart:core'.
   - 'StackTrace' is from 'dart:core'.
      xhr.onError.listen(completer.completeError);
                                   ^
  /Users/ortalcohen/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/helpers/http.dart:252:46: Error: The getter 'toJS' isn't defined for the type 'String'.
  Try correcting the name to the name of an existing getter, or defining a getter or field named 'toJS'.
        xhr.send(sendData is String ? sendData.toJS : sendData.jsify());
                                               ^^^^
  /Users/ortalcohen/.pub-cache/hosted/pub.dev/web-1.1.1/lib/src/helpers/http.dart:252:62: Error: The method 'jsify' isn't defined for the type 'Object'.
   - 'Object' is from 'dart:core'.
  Try correcting the name to the name of an existing method, or defining a method named 'jsify'.
        xhr.send(sendData is String ? sendData.toJS : sendData.jsify());
                                                               ^^^^^
  .
00:00 +0 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart: loading /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart
exit=1
```

### AC-020

```text
$ flutter test --reporter expanded test/transport_selection_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart
00:00 +0: selects noop on the Dart VM and resets transport
00:00 +1: notifies registration and unregistration in order
00:00 +1 -1: notifies registration and unregistration in order [E]
  Expected: ['registered:observed', 'unregistered:observed']
    Actual: ['registered:observed']
     Which: at location [1] is ['registered:observed'] which shorter than expected
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/transport_selection_test.dart 48:5             main.<fn>
00:00 +1 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/transport_selection_test.dart: notifies registration and unregistration in order
exit=1
```

### AC-021

```text
$ flutter test --reporter expanded test/transport_web_source_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/transport_web_source_test.dart
00:00 +0: web transport retains its detection-only contract
00:00 +0 -1: web transport retains its detection-only contract [E]
  Expected: contains 'web-detection'
    Actual: 'import \'dart:developer\' as developer;\n'
              'import \'dart:js_interop\';\n'
              'import \'dart:js_interop_unsafe\';\n'
              '\n'
              'import \'package:web/web.dart\';\n'
              '\n'
              'import \'../webmcp_tool.dart\';\n'
              'import \'webmcp_transport.dart\';\n'
              '\n'
              '/// Creates the browser feature-detection transport.\n'
[middle output omitted]
              '  String get id => \'wrong-id\';\n'
              '\n'
              '  @override\n'
              '  void onToolRegistered(WebMcpTool tool) {\n'
              '    _write(\'registered ${tool.name}; tools not published\');\n'
              '  }\n'
              '\n'
              '  @override\n'
              '  void onToolUnregistered(String name) {\n'
              '    _write(\'unregistered $name; tools not published\');\n'
              '  }\n'
              '\n'
              '  void _write(String message) {\n'
              '    developer.log(message, name: \'webmcp_pilot\');\n'
              '  }\n'
              '}\n'
              ''
     Which: does not contain 'web-detection'
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/transport_web_source_test.dart 9:5             main.<fn>
00:00 +0 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/transport_web_source_test.dart: web transport retains its detection-only contract
exit=1
```

### AC-034a

```text
$ flutter test --reporter expanded test/webmcp_scope_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +0 -1: adds direct and source tools, then closes [E]
  Expected: empty
    Actual: [Instance of 'WebMcpTool', Instance of 'WebMcpTool']
  package:matcher                   expect
  test/webmcp_scope_test.dart 33:5  main.<fn>
00:00 +0 -1: skips duplicates and never removes another owner
00:00 +1 -1: remove is limited to names owned by the scope
00:00 +2 -1: close is idempotent and closed scopes reject additions
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +4 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: adds direct and source tools, then closes
exit=1
```

### AC-034b

```text
$ flutter test --reporter expanded test/webmcp_scope_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +0 -1: adds direct and source tools, then closes [E]
  Expected: ['direct', 'source']
    Actual: ['direct']
     Which: at location [1] is ['direct'] which shorter than expected
  package:matcher                   expect
  test/webmcp_scope_test.dart 30:5  main.<fn>
00:00 +0 -1: skips duplicates and never removes another owner
00:00 +1 -1: remove is limited to names owned by the scope
00:00 +2 -1: close is idempotent and closed scopes reject additions
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +4 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: adds direct and source tools, then closes
exit=1
```

### AC-035

```text
$ flutter test --reporter expanded test/webmcp_scope_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +1: skips duplicates and never removes another owner
00:00 +1 -1: skips duplicates and never removes another owner [E]
  Expected: empty
    Actual: ['shared']
  package:matcher                   expect
  test/webmcp_scope_test.dart 43:5  main.<fn>
00:00 +1 -1: remove is limited to names owned by the scope
00:00 +2 -1: close is idempotent and closed scopes reject additions
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +3 -2: invalid names propagate without becoming owned or skipped [E]
  Expected: empty
    Actual: ['invalid name']
  package:matcher                   expect
  test/webmcp_scope_test.dart 82:5  main.<fn>
00:00 +3 -2: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
exit=1
```

### AC-036

```text
$ flutter test --reporter expanded test/webmcp_scope_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +1: skips duplicates and never removes another owner
00:00 +2: remove is limited to names owned by the scope
00:00 +3: close is idempotent and closed scopes reject additions
00:00 +3 -1: close is idempotent and closed scopes reject additions [E]
  Expected: throws <Instance of 'StateError'>
    Actual: <Closure: () => bool>
     Which: returned <true>
  package:matcher                   expect
  test/webmcp_scope_test.dart 65:5  main.<fn>
00:00 +3 -1: invalid names propagate without becoming owned or skipped
00:00 +4 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
exit=1
```

### AC-037

```text
$ flutter test --reporter expanded test/webmcp_scope_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart
00:00 +0: adds direct and source tools, then closes
00:00 +1: skips duplicates and never removes another owner
00:00 +2: remove is limited to names owned by the scope
00:00 +3: close is idempotent and closed scopes reject additions
00:00 +4: invalid names propagate without becoming owned or skipped
00:00 +4 -1: invalid names propagate without becoming owned or skipped [E]
  Expected: throws <Instance of 'WebMcpInvalidToolNameException'>
    Actual: <Closure: () => bool>
     Which: returned <false>
  package:matcher                   expect
  test/webmcp_scope_test.dart 78:5  main.<fn>
00:00 +4 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
exit=1
```

### AC-038

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: empty
  Actual: [Instance of 'WebMcpTool']
When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:68:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 68
The test description was:
  screen mixin registers while mounted and closes on dispose
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +0 -1: screen mixin registers while mounted and closes on dispose [E]
  Test failed. See exception logs above.
  The test description was: screen mixin registers while mounted and closes on dispose
00:00 +0 -1: action registers verbatim and unregisters independently
00:00 +1 -1: action returns the identical tappable child
00:00 +2 -1: action forwards invocation to the latest callback
00:00 +3 -1: action without a screen reports the tool and registers nothing
00:00 +4 -1: duplicate actions preserve the first owner
00:00 +5 -1: invalid action names fail loudly
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
exit=1
```

### AC-039

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: 'literal.name'
  Actual: 'prefix.literal.name'
   Which: is different.
          Expected: literal.na ...
            Actual: prefix.lit ...
                    ^
           Differ at offset 0
When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:75:5)
[middle output omitted]
The following WebMcpToolNotFoundException was thrown running a test:
No registered tool has this name. (tool: shared)
When the exception was thrown, this was the stack:
#0      WebMcp.invokeTool (package:webmcp_pilot/src/webmcp.dart:68:7)
#1      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:159:34)
<asynchronous suspension>
#2      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
The test description was:
  duplicate actions preserve the first owner
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +3 -3: duplicate actions preserve the first owner [E]
  Test failed. See exception logs above.
  The test description was: duplicate actions preserve the first owner
00:00 +3 -3: invalid action names fail loudly
00:00 +4 -3: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action forwards invocation to the latest callback
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action registers verbatim and unregisters independently
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: duplicate actions preserve the first owner
exit=1
```

### AC-040

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: same instance as GestureDetector:<GestureDetector(startBehavior: start)>
  Actual: AbsorbPointer:<AbsorbPointer(absorbing: true)>
When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:100:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 100
The test description was:
  action returns the identical tappable child
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +2 -1: action returns the identical tappable child [E]
  Test failed. See exception logs above.
  The test description was: action returns the identical tappable child
00:00 +2 -1: action forwards invocation to the latest callback
00:00 +3 -1: action without a screen reports the tool and registers nothing
00:00 +4 -1: duplicate actions preserve the first owner
00:00 +5 -1: invalid action names fail loudly
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action returns the identical tappable child
exit=1
```

### AC-041

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
00:00 +3: action forwards invocation to the latest callback
00:00 +4: action without a screen reports the tool and registers nothing
00:00 +5: duplicate actions preserve the first owner
00:00 +6: invalid action names fail loudly
00:00 +7: All tests passed!
exit=0
```

### AC-042

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
00:00 +3: action forwards invocation to the latest callback
00:00 +4: action without a screen reports the tool and registers nothing
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: <Instance of 'WebMcpScopeMissingException'>
  Actual: <null>
   Which: is not an instance of 'WebMcpScopeMissingException'
When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:133:7)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 133
The test description was:
  action without a screen reports the tool and registers nothing
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +4 -1: action without a screen reports the tool and registers nothing [E]
  Test failed. See exception logs above.
  The test description was: action without a screen reports the tool and registers nothing
00:00 +4 -1: duplicate actions preserve the first owner
00:00 +5 -1: invalid action names fail loudly
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
exit=1
```

### AC-043

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart
00:00 +0: screen mixin registers while mounted and closes on dispose
00:00 +1: action registers verbatim and unregisters independently
00:00 +2: action returns the identical tappable child
00:00 +3: action forwards invocation to the latest callback
00:00 +4: action without a screen reports the tool and registers nothing
00:00 +5: duplicate actions preserve the first owner
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following WebMcpDuplicateToolException was thrown building _Screen-[<'second'>](state:
_ScreenState#77245):
A tool with this name is already registered. (tool: shared)
The relevant error-causing widget was:
  _Screen-[<'second'>]
  _Screen:file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:149:13
[middle output omitted]
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 161
The test description was:
  duplicate actions preserve the first owner
════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following message was thrown:
Multiple exceptions (3) were detected during the running of the current test, and at least one was
unexpected.
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +5 -1: duplicate actions preserve the first owner [E]
  Test failed. See exception logs above.
  The test description was: duplicate actions preserve the first owner
00:00 +5 -1: invalid action names fail loudly
00:00 +6 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: duplicate actions preserve the first owner
exit=1
```

### AC-044

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +1 -1: Flutter imports stay inside the widget layer [E]
  Expected: empty
    Actual: ['lib/src/webmcp.dart: import \'package:flutter/widgets.dart\';']
  lib/src/webmcp.dart: import 'package:flutter/widgets.dart';
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 50:5                    main.<fn>
00:00 +1 -1: public and scope tests preserve their import boundaries
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
exit=1
```

### AC-045

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +2 -1: public and scope tests preserve their import boundaries [E]
  Expected: not contains 'package:flutter_test/'
    Actual: 'import \'package:flutter_test/flutter_test.dart\';\n'
              'import \'package:test/test.dart\';\n'
              'import \'package:webmcp_pilot/webmcp_pilot.dart\';\n'
              '\n'
              'WebMcpTool _tool(String name, Object? value) => WebMcpTool(\n'
              '  name: name,\n'
              '  description: \'Tool $name\',\n'
              '  handler: (Map<String, Object?> arguments) => value,\n'
[middle output omitted]
              '      throwsA(isA<StateError>()),\n'
              '    );\n'
              '    expect(WebMcp.instance.tools, isEmpty);\n'
              '  });\n'
              '\n'
              '  test(\'invalid names propagate without becoming owned or skipped\', () {\n'
              '    final WebMcpScope scope = WebMcpScope(scopeName: \'invalid\');\n'
              '    expect(\n'
              '      () => scope.addTool(_tool(\'invalid name\', null)),\n'
              '      throwsA(isA<WebMcpInvalidToolNameException>()),\n'
              '    );\n'
              '    expect(scope.ownedNames, isEmpty);\n'
              '    expect(scope.skippedNames, isEmpty);\n'
              '    expect(WebMcp.instance.tools, isEmpty);\n'
              '  });\n'
              '}\n'
              ''
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 60:5                    main.<fn>
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
exit=1
```

### AC-004

```text
$ dart format --output=none --set-exit-if-changed lib test example/lib example/test
Changed lib/src/webmcp.dart
Formatted 23 files (1 changed) in 0.03 seconds.
exit=1
negative detected=True
```

### AC-005

```text
$ dart analyze --fatal-infos --fatal-warnings
Analyzing webmcp-negative-_wohjh67...
warning - example/lib/main.dart:6:9 - The value of the local variable 'unusedLocal' isn't used. Try removing the variable or using it. - unused_local_variable
   info - lib/src/webmcp.dart:79:8 - Missing documentation for a public member. Try adding documentation for the member. - public_member_api_docs
2 issues found.
exit=2
negative detected=True
```

### AC-006

```text
$ flutter pub get
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
Upgrading analysis_options.yaml to exclude build and platform directories.
exit=0
negative detected=True
```

### AC-007-positive

```text
$ dart analyze --fatal-infos --fatal-warnings
Analyzing webmcp-negative-_wohjh67...
No issues found!
exit=0
negative detected=True
```

### AC-007

```text
$ dart analyze --fatal-infos --fatal-warnings
Analyzing webmcp-negative-_wohjh67...
  error - example/build/negative_probe.dart:1:16 - The function 'unknownName' isn't defined. Try importing the library that defines 'unknownName', correcting the name to the name of an existing function, or defining a function named 'unknownName'. - undefined_function
1 issue found.
exit=3
negative detected=True
```

### AC-008

```text
$ dart analyze --fatal-infos --fatal-warnings
Analyzing webmcp-negative-_wohjh67...
warning - example/pubspec.yaml:12:5 - Publishable packages can't have 'path' dependencies. Try adding a 'publish_to: none' entry to mark the package as not for publishing or remove the path dependency. - invalid_dependency
1 issue found.
exit=2
negative detected=True
```

### AC-022

```text
$ flutter test --reporter expanded test/example_tools_test.dart
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +0 -1: registers two imperative tools and increments the counter [E]
  Expected: ['example.counter.increment', 'example.counter.read']
    Actual: MappedListIterable<WebMcpTool, String>:[
              'example.counter.changed',
              'example.counter.increment'
            ]
     Which: at location [0] is 'example.counter.changed' instead of 'example.counter.increment'
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/example_tools_test.dart 12:5                   main.<fn>
00:00 +0 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/example/test/example_tools_test.dart: registers two imperative tools and increments the counter
exit=1
negative detected=True
```

### AC-023

```text
$ flutter build web
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
This project is not configured for the web.
To configure this project for the web, run flutter create . --platforms web
exit=1
negative detected=True
```

### AC-032

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +2: public and scope tests preserve their import boundaries
00:00 +3: implementation files contain no fixed secret markers
00:00 +3 -1: implementation files contain no fixed secret markers [E]
  Expected: empty
    Actual: ['.github/workflows/checks.yml: # AKIA0000000000000000']
  .github/workflows/checks.yml: # AKIA0000000000000000
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 106:5                   main.<fn>
00:00 +3 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
exit=1
negative detected=True
```

### AC-046

```text
$ dart analyze --fatal-infos --fatal-warnings
Analyzing webmcp-negative-_wohjh67...
  error - example/lib/main.dart:3:8 - Target of URI doesn't exist: 'example_screen.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - example/lib/main.dart:16:36 - Invalid constant value. - invalid_constant
  error - example/lib/main.dart:16:36 - The method 'ExampleScreen' isn't defined for the type 'WebMcpPilotExample'. Try correcting the name to the name of an existing method, or defining a method named 'ExampleScreen'. - undefined_method
3 issues found.
exit=3
negative detected=True
```

### AC-002-positive

```text
$ env PATH=/usr/bin:/bin bash tools/check.sh
Preflight failed: missing required binary: flutter
exit=1
negative detected=True
```

### AC-002

```text
$ env PATH=/usr/bin:/bin bash tools/check.sh
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
tools/check.sh: line 16: flutter: command not found
Stage 2 failed: dependencies
exit=1
negative detected=True
```

### AC-003-positive

```text
$ bash tools/check.sh
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
[middle output omitted]
00:00 +7 -1: /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +8 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +10 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +11 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +12 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +13 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +14 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +15 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +16 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +17 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +18 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +19 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +20 -1: /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +21 -1: /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +22 -1: /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +23 -1: /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +24 -1: /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +25 -1: /private/tmp/webmcp-negative-_wohjh67/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +26 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/registry_test.dart: registers sources through duplicate validation
Stage 5 failed: tests
exit=1
negative detected=True
```

### AC-003

```text
$ bash tools/check.sh
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
[middle output omitted]
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             17.8s
✓ Built build/web
Stage 6 passed: build
exit=0
negative detected=True
```

### AC-001

```text
$ bash tools/check.sh
Preflight: flutter and dart found
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
[middle output omitted]
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             17.5s
✓ Built build/web
Stage 6 passed: build
exit=0
negative detected=True
```

### Rerun-AC-017c

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
              '        \'ok\',\n'
              '      );\n'
              '      expect(registry.transportId, \'public\');\n'
              '      expect(registry.unregisterTool(\'public.tool\'), isTrue);\n'
              '\n'
              '      expect(WebMcpScope, isNotNull);\n'
              '      expect(WebMcpScreen, isNotNull);\n'
              '      expect(WebMcpAction, isNotNull);\n'
              '      expect(WebMcpException, isNotNull);\n'
              '      expect(WebMcpInvalidToolNameException, isNotNull);\n'
              '      expect(WebMcpDuplicateToolException, isNotNull);\n'
              '      expect(WebMcpToolNotFoundException, isNotNull);\n'
              '      expect(WebMcpScopeMissingException, isNotNull);\n'
              '    },\n'
              '  );\n'
              '}\n'
              ''
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 60:5                    main.<fn>
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
exit=1
```

### Rerun-AC-038

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 72
The test description was:
  screen mixin registers while mounted and closes on dispose
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +0 -1: screen mixin registers while mounted and closes on dispose [E]
  Test failed. See exception logs above.
  The test description was: screen mixin registers while mounted and closes on dispose
00:00 +0 -1: action registers verbatim and unregisters independently
00:00 +1 -1: action returns the identical tappable child
00:00 +2 -1: action forwards invocation to the latest callback
00:00 +3 -1: action keeps its mounted descriptor identity until replacement
00:00 +4 -1: action copies its input schema
00:00 +5 -1: action without a screen reports the tool and registers nothing
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
exit=1
```

### Rerun-AC-039

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
No registered tool has this name. (tool: shared)
When the exception was thrown, this was the stack:
#0      WebMcp.invokeTool (package:webmcp_pilot/src/webmcp.dart:68:7)
#1      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:205:34)
<asynchronous suspension>
#2      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
The test description was:
  duplicate actions preserve the first owner
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +4 -4: duplicate actions preserve the first owner [E]
  Test failed. See exception logs above.
  The test description was: duplicate actions preserve the first owner
00:00 +4 -4: invalid action names fail loudly
00:00 +5 -4: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action forwards invocation to the latest callback
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action registers verbatim and unregisters independently
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: duplicate actions preserve the first owner
exit=1
```

### Rerun-AC-040

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 104
The test description was:
  action returns the identical tappable child
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +2 -1: action returns the identical tappable child [E]
  Test failed. See exception logs above.
  The test description was: action returns the identical tappable child
00:00 +2 -1: action forwards invocation to the latest callback
00:00 +3 -1: action keeps its mounted descriptor identity until replacement
00:00 +4 -1: action copies its input schema
00:00 +5 -1: action without a screen reports the tool and registers nothing
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action returns the identical tappable child
exit=1
```

### Rerun-AC-041

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
#4      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:122:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 122
The test description was:
  action forwards invocation to the latest callback
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +3 -1: action forwards invocation to the latest callback [E]
  Test failed. See exception logs above.
  The test description was: action forwards invocation to the latest callback
00:00 +3 -1: action keeps its mounted descriptor identity until replacement
00:00 +4 -1: action copies its input schema
00:00 +5 -1: action without a screen reports the tool and registers nothing
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action forwards invocation to the latest callback
exit=1
```

### Rerun-AC-042

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
  Actual: <null>
   Which: is not an instance of 'WebMcpScopeMissingException'
When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart:179:7)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 179
The test description was:
  action without a screen reports the tool and registers nothing
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +6 -1: action without a screen reports the tool and registers nothing [E]
  Test failed. See exception logs above.
  The test description was: action without a screen reports the tool and registers nothing
00:00 +6 -1: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
exit=1
```

### Rerun-AC-043

```text
$ flutter test --reporter expanded test/widget_layer_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)
This was caught by the test expectation on the following line:
  file:///private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart line 207
The test description was:
  duplicate actions preserve the first owner
════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following message was thrown:
Multiple exceptions (3) were detected during the running of the current test, and at least one was
unexpected.
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +7 -1: duplicate actions preserve the first owner [E]
  Test failed. See exception logs above.
  The test description was: duplicate actions preserve the first owner
00:00 +7 -1: invalid action names fail loudly
00:00 +8 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/widget_layer_test.dart: duplicate actions preserve the first owner
exit=1
```

### Rerun-AC-044

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
00:00 +0: loading /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart
00:00 +0: library and example sources avoid forbidden imports
00:00 +1: Flutter imports stay inside the widget layer
00:00 +1 -1: Flutter imports stay inside the widget layer [E]
  Expected: empty
    Actual: ['lib/src/webmcp.dart: import \'package:flutter/widgets.dart\';']
  lib/src/webmcp.dart: import 'package:flutter/widgets.dart';
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 50:5                    main.<fn>
00:00 +1 -1: public and scope tests preserve their import boundaries
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
exit=1
```

### Rerun-AC-045

```text
$ flutter test --reporter expanded test/repo_hygiene_test.dart
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
[middle output omitted]
              '      throwsA(isA<StateError>()),\n'
              '    );\n'
              '    expect(WebMcp.instance.tools, isEmpty);\n'
              '  });\n'
              '\n'
              '  test(\'invalid names propagate without becoming owned or skipped\', () {\n'
              '    final WebMcpScope scope = WebMcpScope(scopeName: \'invalid\');\n'
              '    expect(\n'
              '      () => scope.addTool(_tool(\'invalid name\', null)),\n'
              '      throwsA(isA<WebMcpInvalidToolNameException>()),\n'
              '    );\n'
              '    expect(scope.ownedNames, isEmpty);\n'
              '    expect(scope.skippedNames, isEmpty);\n'
              '    expect(WebMcp.instance.tools, isEmpty);\n'
              '  });\n'
              '}\n'
              ''
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 61:5                    main.<fn>
00:00 +2 -1: implementation files contain no fixed secret markers
00:00 +3 -1: Some tests failed.
Failing tests:
  /private/tmp/webmcp-negative-_wohjh67/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
exit=1
```

### AC-024

```text
$ ['python3', '-c', "from pathlib import Path; import re; s=Path('.github/workflows/checks.yml').read_text(); assert re.findall(r'^  ([a-z]+):$',s.split('jobs:')[1],re.M)==['wiki','package']; assert not re.search(r'^\\s+needs:',s,re.M); print('exactly two independent jobs')"]
Positive exit=0
exactly two independent jobs
Negative exit=1
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from pathlib import Path; import re; s=Path('.github/workflows/checks.yml').read_text(); assert re.findall(r'^  ([a-z]+):$',s.split('jobs:')[1],re.M)==['wiki','package']; assert not re.search(r'^\s+needs:',s,re.M); print('exactly two independent jobs')
                                                                                                                                                                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError
```

### AC-025

```text
$ ['python3', '-c', "from pathlib import Path; import re; s=Path('AGENTS.md').read_text().split('## Checks')[1]; w=Path('.github/workflows/checks.yml').read_text(); assert 'bash tools/check.sh' in s and w.count('run: bash tools/check.sh')==1; print('full-suite commands match')"]
Positive exit=0
full-suite commands match
Negative exit=1
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from pathlib import Path; import re; s=Path('AGENTS.md').read_text().split('## Checks')[1]; w=Path('.github/workflows/checks.yml').read_text(); assert 'bash tools/check.sh' in s and w.count('run: bash tools/check.sh')==1; print('full-suite commands match')
                                                                                                                                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError
```

### AC-026

```text
$ ['python3', '-c', "from pathlib import Path; import re; s=Path('.github/workflows/checks.yml').read_text(); assert len(re.findall(r'(?<![\\w.])\\d+\\.\\d+\\.\\d+(?![\\w.])',s))==1; print('single Flutter version literal')"]
Positive exit=0
single Flutter version literal
Negative exit=1
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from pathlib import Path; import re; s=Path('.github/workflows/checks.yml').read_text(); assert len(re.findall(r'(?<![\w.])\d+\.\d+\.\d+(?![\w.])',s))==1; print('single Flutter version literal')
                                                                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError
```

### AC-027

```text
$ ['python3', '-c', "from pathlib import Path; import re; s=Path('README.md').read_text(); old=Path('original-readme.tmp').read_text(); assert s.startswith('# webmcp_pilot'); assert s.endswith(old); print('original README retained byte for byte')"]
Positive exit=0
original README retained byte for byte
Negative exit=1
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from pathlib import Path; import re; s=Path('README.md').read_text(); old=Path('original-readme.tmp').read_text(); assert s.startswith('# webmcp_pilot'); assert s.endswith(old); print('original README retained byte for byte')
                                                                                                                                                                     ~~~~~~~~~~^^^^^
AssertionError
```

### AC-028

```text
$ rename CHANGELOG.md CHANGES.md; python3 existence assertion
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from pathlib import Path; assert Path('CHANGELOG.md').exists()
                                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~^^
AssertionError
exit=1
```

### AC-029

```text
$ ['python3', '-c', "from pathlib import Path; import re; s=Path('pubspec.yaml').read_text().split('platforms:')[1]; assert re.findall(r'^  (\\w+):',s,re.M)==['web']; print('web is the only platform')"]
Positive exit=0
web is the only platform
Negative exit=1
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from pathlib import Path; import re; s=Path('pubspec.yaml').read_text().split('platforms:')[1]; assert re.findall(r'^  (\w+):',s,re.M)==['web']; print('web is the only platform')
                                                                                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError
```

### AC-030

```text
$ ['python3', '-c', "from pathlib import Path; import re; s=Path('AGENTS.md').read_text(); assert '## Checks' in s; assert len(s.splitlines())<200; print('Checks section present; under 200 lines')"]
Positive exit=0
Checks section present; under 200 lines
Negative exit=1
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from pathlib import Path; import re; s=Path('AGENTS.md').read_text(); assert '## Checks' in s; assert len(s.splitlines())<200; print('Checks section present; under 200 lines')
                                                                                 ^^^^^^^^^^^^^^^^
AssertionError
```

### AC-033

```text
$ ['python3', '-c', "import subprocess; p=subprocess.run(['git','check-ignore','-v','example/build/web/x.dart'],capture_output=True,text=True); print(p.stdout); assert p.returncode==0"]
Positive exit=0
.gitignore:33:/example/build/	example/build/web/x.dart
Negative exit=1
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    import subprocess; p=subprocess.run(['git','check-ignore','-v','example/build/web/x.dart'],capture_output=True,text=True); print(p.stdout); assert p.returncode==0
                                                                                                                                                       ^^^^^^^^^^^^^^^
AssertionError
```

## Mutation details

The probes follow the frozen negative cases. AC-042 replaces the missing-scope throw with an early return: the expected exception is absent and its test fails. AC-045 adds the forbidden Flutter test import; the boundary scan fails before any widget-pumping addition is necessary. AC-043 rethrows duplicate registration instead of absorbing it; the duplicate-screen test fails. AC-038 removes the scope-close call from disposal, leaving the same leaked registration as deleting the disposal override. These minimal mutations exercise the stated defect rather than changing an acceptance criterion.
