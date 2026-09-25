# Acceptance criteria: Feature opportunities for application authors using webmcp_flutter

## Frozen

- Frozen at: 2026-09-25
- Frozen by: orchestrator

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | When a tool has a call handler and the browser execute callback receives a second argument whose signal property is present, the system shall pass that signal's aborted state to the call handler and shall invoke the call handler once. | A fake boundary invokes execute with a signal that is not aborted. The test asserts the call handler observed aborted as false and that the one-argument handler was not called. | The same callback with no second argument invokes the call handler once with a null execution signal. |
| AC-002 | When the adapted execution signal reports aborted after the call handler has started and before the call handler returns, the system shall leave that invocation unfinished until the call handler returns, and shall not invoke the call handler again. | The test starts a call handler that waits on a completer, flips the fake signal to aborted, and asserts the publisher future is still pending and the handler invocation count is one. Completing the completer then finishes the future. | Setting cancelledBeforeDispatch before dispatch does not enter the call handler, and the returned agent object has error code cancelled. |
| AC-003 | When a tool has only the one-argument handler, the system shall invoke that handler with the argument map on local invoke and on browser execute. | A registry test and a publisher test register a one-argument handler and assert it received the argument map. | Constructing a tool with both the one-argument handler and a call handler throws ArgumentError and leaves the registry unchanged. |
| AC-004 | When a tool title is null, the system shall omit the title member from the browser registration object. When a tool title is a non-empty string, the system shall set the title member to that string. | The fake boundary records the registration object for one tool with a null title and one tool with a title. The test asserts absence, then equality with the author string. | A rebuild of WebMcpAction after the first mount does not change the title already published for that mounted action. |
| AC-005 | When debugging is null, the system shall omit the debugging member from the annotations object. When debugging is true, the system shall send true. When debugging is false, the system shall send false. | Three registrations are captured. The test asserts the member is absent, then true, then false. | The test does not inspect an agent tool list and does not treat a missing member as a sent false. |
| AC-006 | When exposedTo is null, the system shall omit the exposedTo member. When exposedTo is a list of strings, including an empty list, the system shall send that list. | The fake boundary records a null list, an empty list, and a two-origin list. The test asserts omission, an empty array, and the two author strings in order. | Mutating the list the author passed after construction does not change the list on the stored tool. |
| AC-007 | When the browser reports toolactivated with a tool name, the system shall deliver one started activity whose tool name equals that event, and shall not invoke a tool handler because of that event. | A fake event is dispatched after attach. The listener records one started event with the event's tool name, and the handler invocation count stays zero. | After detach, a later toolactivated event is not delivered to that listener. |
| AC-008 | When the browser reports toolcancel with a tool name while a call handler is still running, the system shall deliver one cancelled activity with that tool name, and shall leave the running call handler unfinished until the call handler returns. | The test overlaps an in-flight call handler with a fake toolcancel. The listener observed the name, the invocation count stays one, and the publisher future stays pending until the handler returns. | A toolcancel event does not make a later local invokeTool skip the handler. |
| AC-009 | When a manual tool was built with a declared input field list and the arguments contain an unknown key, a missing required key, a double for an integer field, or an integer outside the inclusive range from -9007199254740991 through 9007199254740991, the system shall throw WebMcpInvalidArgumentsException and shall not call the author callback. | Four local invokeTool cases, one per bad input, assert the exception type and a zero callback count. | A declared string field whose value is that string calls the author callback once with a map that contains the decoded string and no undeclared key. |
| AC-010 | When registerTool is called with a free-form inputSchema map, the system shall store a shallow copy of that map and shall still invoke the handler when the arguments do not satisfy the map. | The test registers a schema that requires a key, invokes with an empty argument map, and asserts the handler ran and the stored schema no longer shares the caller's outer map. | A nested object inside the schema remains shared with the object the caller originally placed in the map. |
| AC-011 | When a browser invocation's handler throws WebMcpToolException whose code is 1 to 64 ASCII letters, digits, underscores, hyphens, or periods, and whose details are absent or within the publisher's existing depth and encoded-size limits, the system shall return a JSON object with ok false and error code and retryable equal to that exception, and shall include details only when the exception carried details. | The publisher test throws one exception with details and one without, and compares the encoded code, retryable flag, and details object. | A thrown StateError returns the handlerFailed object and does not include the StateError message. A WebMcpToolException whose details exceed the encoded-size limit returns handlerFailed and does not include those details. |
| AC-012 | When invokeTool is called on a tool whose handler throws WebMcpToolException, the system shall complete the local future with that exception and shall not return the browser failure JSON. | A registry test expects the same exception instance type and code. | The same tool, invoked through the publisher, returns the JSON object from AC-011 instead of throwing that exception to the publisher's caller. |
| AC-013 | When a log hook is installed, the system shall call it with kind and tool name for registration, unregistration, local invocation, a failed invocation, and a native activity event, and the record shall not carry arguments, results, or schemas. | The test installs a hook, performs each action, and asserts the kind and tool name on each record and that the record's string form does not contain the argument value. | A hook that throws on registration still leaves the tool registered and invocable. |
| AC-014 | When code runs on a non-web host, registerTool and invokeTool shall complete for a valid tool, NoopWebMcpNativeBoundary.registerTool shall return a registration, abort on that registration shall be callable twice, and WebMcpNativePublisher.attach shall complete with zero published tools and reason browserUnavailable. | The VM test suite performs those calls and asserts the handler result, a zero published count, and the reason code. | Calling abort on the no-op registration does not unregister the local tool. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-015 | When the publisher encodes a handler failure or the log hook records an event, the system shall omit argument values, result values, input schemas, exception messages, and stack traces from both outputs. | The publisher test and the logger test use a distinctive argument string and a distinctive exception message and assert neither string appears in the encoded failure or the log record. | A WebMcpToolException that carries that distinctive string only inside a details value which passes the size limit does include that details value in the agent error object and still omits it from the log record. |
| AC-016 | When a page source wrapper dispatches a tool that has only a call handler, the system shall invoke that call handler once with a null execution signal. | A page-dispatch test registers a call-handler-only tool through the page source wrapper and asserts one invocation and a null signal. | The same wrapper, given a tool that has only the one-argument handler, invokes that handler once and does not require a call handler. |
| AC-017 | When a WebMcpAction is given only onCall, the mounted tool shall have a call handler and no one-argument handler. When it is given only onInvoke, the mounted tool shall have a one-argument handler and no call handler. | A widget test mounts each form and reads the registered tool's callbacks. | Constructing a WebMcpAction with both onInvoke and onCall throws ArgumentError and registers no tool. |

## Explicitly not required

The library terminating a running handler, replaying a handler, or treating an aborted execution signal as skipped dispatch.

A test or a document claiming that a current Chrome build aborts the execution signal after the callback starts.

A claim that a user agent shows title, that omitting debugging differs from false, or that an agent filters debugging.

Runtime JSON Schema validation of a free-form inputSchema map.

Generated route wrapping, generalized service proxies, positive observation waits, transactional registration, automatic transport cleanup, and multiple-Flutter-view support.

Declarative HTML forms, getTools, executeTool, fromOrigins, permissions policy, outputSchema, and a Wasm automatic-page lifecycle change.

Publishing this package or the annotation and generator packages, and any claim about who produced the score-window downloads.

Authorization checks inside handlers. Those remain the author's.

A change to the first-mount rule for WebMcpAction descriptors beyond storing the new optional fields from the first mount.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|
