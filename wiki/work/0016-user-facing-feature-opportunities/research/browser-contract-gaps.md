# Research: Browser contract gaps for a Flutter application author

## Question

Which capabilities does the official WebMCP `modelContext` browser contract define that `webmcp_flutter` does not currently give a Flutter application author, and which of those capabilities would change what that author can ship?

## Answer

The current community-group draft and Chrome's documented API both attach `modelContext` to `Document`, not `Navigator`. The native publisher already registers same-origin tools with a name, description, input schema, three safety hints, and a registration abort signal. It does not give the author the execution `AbortSignal`, a display `title`, the `debugging` hint, an `exposedTo` origin list, `getTools` / `executeTool`, or `toolactivated` / `toolcancel`. The execution signal is the gap that changes what the author can safely ship: the publisher owns `execute` and drops the signal, so the author cannot stop their own in-flight work when the browser cancels a call. Library-initiated termination of that work stays a deliberate omission in the product contract, which is a constraint, not a recommendation to add it.

## Findings

### The contract is `document.modelContext`, and the publisher already uses that object

- Claim: The WebML Community Group draft status is `CG-DRAFT`, and its URL is `https://webmachinelearning.github.io/webmcp`. `Document` has a `modelContext` attribute. `ModelContext` extends `EventTarget` and defines `registerTool`, `getTools`, `executeTool`, `ontoolchange`, `ontoolactivated`, and `ontoolcancel`. The draft source contains no `navigator` attribute for this API.
- Evidence: Bikeshed metadata sets `Status: CG-DRAFT` and `URL: https://webmachinelearning.github.io/webmcp`. The IDL is `partial interface Document { [SecureContext, SameObject] readonly attribute ModelContext modelContext; }` and the `ModelContext` interface lists those three methods and three event-handler attributes. A search of that source for `navigator` returns no matches.
- Source: https://github.com/webmachinelearning/webmcp/blob/main/index.bs (lines 1–20, 585–625), consulted 2026-09-25. Official Chrome pages link to that repository from https://developer.chrome.com/docs/ai/webmcp (last updated 2026-08-07) and https://developer.chrome.com/docs/ai/webmcp/imperative-api (last updated 2026-09-21).

- Claim: Chrome's imperative documentation registers, lists, executes, and listens on `document.modelContext`, not `navigator.modelContext`.
- Evidence: The documented calls are `document.modelContext.registerTool`, `document.modelContext.getTools`, `document.modelContext.executeTool`, and `document.modelContext.addEventListener("toolchange", ...)`.
- Source: https://developer.chrome.com/docs/ai/webmcp/imperative-api, last updated 2026-09-21, consulted 2026-09-25.

- Claim: The native publisher reads `document.modelContext` and calls `registerTool`. It passes `name`, `description`, `inputSchema`, `execute`, annotations `readOnlyHint`, `untrustedContentHint`, and `consequentialHint`, plus `{ signal }` from an `AbortController`.
- Evidence: `BrowserWebMcpNativeBoundary` looks up `document.modelContext` and builds that registration object.
- Source: `lib/src/transport/native_publisher_boundary_web.dart` lines 21–34 and 53–76.

### Two interpretations of cancellation disagree, and only one is a product constraint

- Claim: The draft invokes `execute` with the input object and a `ToolExecuteCallbackOptions` whose required `signal` is a new `AbortController` signal. Cancelling a pending execution aborts that signal and fires `toolcancel`. Aborting the registration signal unregisters the tool; those abort steps do not abort the execution controller.
- Evidence: `ToolExecuteCallback` is `Promise<any> (object inputObject, ToolExecuteCallbackOptions options)` and `ToolExecuteCallbackOptions` requires `AbortSignal signal`. Imperative execute steps create the controller, store it, and invoke `execute` with that signal. Cancel-pending-execution signals that controller and fires `toolcancel`. Registration abort steps call unregister and reject the registration promise.
- Source: https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 250–296, 495–512, 732–743, 1101–1171, consulted 2026-09-25.

- Claim: Chrome documents the same callback shape: `execute` receives `{ signal }` as its second argument, and the page is told to pass that signal into long-running work such as `fetch`. As of Chrome 153, unregistering with the registration signal does not cancel in-flight executions. `debugging` is documented as available from Chrome 156.
- Evidence: The imperative page shows `execute: async ({ url, priority }, { signal }) => { const response = await fetch(url, { priority, signal }); ... }` and states the Chrome 153 unregister behavior and the Chrome 156 `debugging` hint.
- Source: https://developer.chrome.com/docs/ai/webmcp/imperative-api, last updated 2026-09-21, consulted 2026-09-25.

- Claim: The publisher's browser callback accepts only the input value, then calls the Dart handler with `cancelledBeforeDispatch: false`. The publisher never reads a second callback argument.
- Evidence: The JS `execute` function is `(JSAny? input) { return _executeSafely(input, invoke).toJS; }`, and `_executeSafely` passes `const WebMcpNativeInvocationContext(cancelledBeforeDispatch: false)`.
- Source: `lib/src/transport/native_publisher_boundary_web.dart` lines 54–56 and 87–96.

- Claim: The product contract, verified 2026-09-15, says Chrome 152 page conformance does not supply an invocation signal after callback start, so admitted work may continue and the library does not terminate or replay it. "In-flight callback termination" is listed under Deliberate omissions. That listing is a constraint, not a recommendation to add termination.
- Evidence: The Browser boundary and Deliberate omissions sections say this.
- Source: `wiki/product/webmcp-contract.md` lines 128–132 and 146–153.

- Claim: Interpretation A: the draft and the 2026-09-21 Chrome page define an execution signal the author can use, and the publisher drops it, so an author who publishes through `WebMcpNativePublisher` cannot cancel their own handler work. Interpretation B: the product contract treats post-start cancellation as absent in the Chrome 152 evidence it recorded, and forbids the library from terminating admitted work. The two texts disagree about whether a signal exists after the callback starts. They do not disagree that the library itself must not kill the handler: the omission names termination, and the draft's registration abort path also leaves the execution signal alone.
- Evidence: Sources in the four claims above. The contract's `last_verified` is 2026-09-15, before the imperative page's 2026-09-21 update.
- Source: `wiki/product/webmcp-contract.md` line 4; https://developer.chrome.com/docs/ai/webmcp/imperative-api, last updated 2026-09-21.

### Other defined capabilities the publisher does not give the author

- Claim: `ModelContextTool` has an optional `title` (`USVString`) used as the user-agent label, and `ToolAnnotations` includes `debugging` defaulting to false. `registerTool` options include `exposedTo`, a list of trustworthy origins that may see and call the tool. `getTools` accepts `fromOrigins` and is specified for in-page JavaScript agents; the draft says the browser's own agent uses a different internal mechanism. `executeTool` accepts an optional execution `AbortSignal` and returns a string. `toolactivated` and `toolcancel` carry `toolName`.
- Evidence: IDL and prose for `ModelContextTool`, `ToolAnnotations`, `ModelContextRegisterToolOptions`, `ModelContextGetToolOptions`, `ModelContextExecuteToolOptions`, `getTools` domintro, and the `ToolActivatedEvent` / `ToolCancelEvent` interfaces.
- Source: https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 616–652, 1083–1226, 1327–1375, consulted 2026-09-25. Chrome restates `title` on the `getTools` result, `debugging`, `exposedTo`, `fromOrigins`, `executeTool`, and `toolchange` at https://developer.chrome.com/docs/ai/webmcp/imperative-api, last updated 2026-09-21.

- Claim: The publisher registration object does not set `title`, `debugging`, or `exposedTo`. No `getTools`, `executeTool`, `toolactivated`, or `toolcancel` use appears in the native publisher boundary.
- Evidence: The registration map contains only `name`, `description`, `inputSchema`, the three hints above, and `execute`. A repository search of `lib/src/transport/native_publisher_boundary_web.dart` for `debugging` and `title` finds neither. `getTools` and `executeTool` are absent from that file.
- Source: `lib/src/transport/native_publisher_boundary_web.dart` lines 57–72.

- Claim: Missing `title` changes the label a user agent shows for every published tool. Missing `debugging` changes whether an author can mark a tool as developer-only so end-user agents can filter it; Chrome dates that hint to Chrome 156. Missing `exposedTo` changes whether a cross-origin document can be allowed to see and execute the tool. Missing `getTools` / `executeTool` changes whether the Flutter app can host an in-page agent; it does not, by the draft's own split, change how the browser agent discovers tools the publisher already registered. Missing `toolactivated` / `toolcancel` changes whether Flutter UI can react when an agent starts or cancels a tool. The product contract says `toolchange` is not application-state delivery, which matches the draft using `toolchange` for tool-list changes, so that event is not a separate state API the library is withholding.
- Evidence: Draft field prose and the `getTools` note that the browser agent uses a different mechanism. Contract sentence on `toolchange`.
- Source: https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 640–646 and 1115–1160; `wiki/product/webmcp-contract.md` line 132; https://developer.chrome.com/docs/ai/webmcp/imperative-api, last updated 2026-09-21.

### Declarative forms and permissions policy are defined, and they do not by themselves change the publisher's job

- Claim: Chrome's declarative API turns an HTML `<form>` into a tool with `toolname`, `tooldescription`, optional `toolparamdescription` and `toolautosubmit`, `SubmitEvent.agentInvoked`, `SubmitEvent.respondWith`, window `toolactivated` / `toolcancel` events, and CSS `:tool-form-active` / `:tool-submit-active`. The community-group draft's declarative section is a TODO and points at the explainer.
- Evidence: Chrome declarative page documents those attributes and events. The draft heading "Declarative WebMCP" says the section is entirely a TODO.
- Source: https://developer.chrome.com/docs/ai/webmcp/declarative-api, last updated 2026-05-18, consulted 2026-09-25. https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 1282–1284, consulted 2026-09-25.

- Claim: The `tools` permissions policy defaults to `self`. Chrome disables registration in cross-origin iframes unless the iframe has `allow="tools"`. A site can send `Permissions-Policy: tools=()`. The publisher does not set that policy. A top-level Flutter page is already inside the default allowlist; the host page, not this package, sets `allow` on an iframe.
- Evidence: Draft permissions-policy section and security guidance. Chrome imperative "Cross-origin iframes" section.
- Source: https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 1393–1397 and 1886–1887; https://developer.chrome.com/docs/ai/webmcp/imperative-api, last updated 2026-09-21; https://developer.chrome.com/docs/ai/webmcp, last updated 2026-08-07.

- Claim: `outputSchema` is an open question in the repository README, not a dictionary member in the draft IDL fetched on 2026-09-25. It is not a capability the current contract defines.
- Evidence: README "Open Questions" lists "Output schema" as support still being determined, linking issue 9. `ModelContextTool` in the draft has `inputSchema` and no `outputSchema`.
- Source: https://github.com/webmachinelearning/webmcp/blob/main/README.md "Open Questions", consulted 2026-09-25; https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 1083–1092.

### What already matches, so it is not a ship-changing gap

- Claim: The publisher already supplies the registration abort signal, which is how the draft and Chrome unregister a tool. The product contract says the publisher cleans registrations it created through registration abort signals. Positive observation waits are a deliberate omission. The draft's page-facing observation path for tools is `getTools` plus `toolchange`; a separate positive-wait method is not in the `ModelContext` IDL. The omission is a constraint, not a recommendation to add a wait API.
- Evidence: Publisher options object and `abort()`. Contract browser-boundary and omissions text. `ModelContext` IDL methods.
- Source: `lib/src/transport/native_publisher_boundary_web.dart` lines 71–84 and 110–120; `wiki/product/webmcp-contract.md` lines 121–124 and 146–153; https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 616–624.

## Options considered

Highest-value gap: the execution `AbortSignal` on `execute`. Compared responses are expose it through the publisher, leave it to the author, or keep it omitted. Library-initiated termination is not one of the viable responses; the product contract lists it under Deliberate omissions, which is a constraint.

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Expose the execution signal to the author | The publisher forwards `ToolExecuteCallbackOptions.signal` into the application handler and leaves the handler running until the author returns. The author chooses whether to abort their own request. The library still does not terminate the callback. | Authors who publish through the native publisher must handle one more argument. Behavior depends on the browser actually aborting that signal, which the contract says Chrome 152 did not do. | Chosen. The draft and the 2026-09-21 Chrome page define the signal, and the publisher currently drops it, so the author cannot make a long-running tool cancellable. This is author-controlled cancellation, which is a different act from the omitted library termination. |
| Leave the signal to the author | The author writes their own `document.modelContext` registration beside the publisher and reads `{ signal }` there. | Two registrations for one tool, or the author must stop using the publisher. The publisher's one-argument `execute` wrapper cannot be patched from application code. | Rejected. While `WebMcpNativePublisher` owns `execute`, the author cannot see the signal. |
| Keep the signal omitted | The publisher continues to call handlers with `cancelledBeforeDispatch: false` and no abort signal. | Long-running tools cannot stop work when the user or agent cancels. Matches the Chrome 152 note in the contract. | Rejected. That note is evidence about Chrome 152, dated before the 2026-09-21 Chrome page. Keeping the omission permanently hides a capability the current draft defines. The deliberate omission still forbids the library from killing the handler itself. |

## Constraints discovered

- WebMCP is an experimental browser surface and may change. Property detection is not proof that the native API works. Source: `wiki/product/webmcp-contract.md` lines 117–119.
- The draft gates the API on a secure context and on the `tools` permissions policy, default `self`. Cross-origin iframes need `allow="tools"` from the embedding page, and cross-origin visibility also needs `exposedTo` plus `fromOrigins`. Source: https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 597–598 and 1393–1397; https://developer.chrome.com/docs/ai/webmcp/imperative-api, last updated 2026-09-21.
- `document.domain` / `Origin-Agent-Cluster: ?0` disables the API in Chrome's documentation. Source: https://developer.chrome.com/docs/ai/webmcp, last updated 2026-08-07.
- In-flight callback termination, positive observation waits, and non-web product support are deliberate omissions. Those are constraints. Source: `wiki/product/webmcp-contract.md` lines 146–153.
- The publisher bounds JSON depth, encoded size, registration count, and outstanding executions, and it returns an allowlisted failure object rather than a thrown exception. Those limits are library behavior, not draft IDL. Source: `lib/src/transport/webmcp_native_publisher.dart` lines 10–25 and 309–365.
- Chrome's origin-trial post says the trial starts in Chrome 149 and that the API shape can still change. Source: https://developer.chrome.com/blog/ai-webmcp-origin-trial, published 2026-06-09, consulted 2026-09-25.
- The declarative section of the community-group draft is still a TODO, while Chrome's declarative page is a separate, earlier document (last updated 2026-05-18). Source: https://github.com/webmachinelearning/webmcp/blob/main/index.bs lines 1282–1284; https://developer.chrome.com/docs/ai/webmcp/declarative-api.

## Unresolved

- [UNRESOLVED: does a current Chrome build abort `ToolExecuteCallbackOptions.signal` after the Dart/JS callback has started, or does the Chrome 152 result in the product contract still describe shipping Chrome?]
- [UNRESOLVED: does omitting the `debugging` member differ from sending `debugging: false` in Chrome 156, and do end-user agents actually filter tools when it is true?]
- [UNRESOLVED: which user-agent surface shows `ModelContextTool.title` today, and is an empty omitted title visible to a Flutter author's users?]
- [UNRESOLVED: will the community-group draft's unfinished declarative section match Chrome's form attributes, or will those attributes stay a Chrome-only surface a Flutter widget tree cannot represent?]

## Sources

- https://developer.chrome.com/docs/ai/webmcp — consulted 2026-09-25; page last updated 2026-08-07.
- https://developer.chrome.com/blog/ai-webmcp-origin-trial — consulted 2026-09-25; published 2026-06-09.
- https://developer.chrome.com/docs/ai/webmcp/imperative-api — consulted 2026-09-25; page last updated 2026-09-21. Linked from the overview page.
- https://developer.chrome.com/docs/ai/webmcp/declarative-api — consulted 2026-09-25; page last updated 2026-05-18. Linked from the overview page.
- https://github.com/webmachinelearning/webmcp/blob/main/index.bs — WebML Community Group draft source, consulted 2026-09-25. Linked from the Chrome overview and imperative pages.
- https://github.com/webmachinelearning/webmcp/blob/main/README.md — consulted 2026-09-25. Same repository.
- https://webmachinelearning.github.io/webmcp — draft URL recorded in the Bikeshed metadata; the text cited above is the `index.bs` source, not a separate rendered copy.
- `wiki/product/webmcp-contract.md` — read 2026-09-25; document `last_verified` 2026-09-15.
- `lib/src/transport/native_publisher_boundary_web.dart` — read 2026-09-25.
- `lib/src/transport/webmcp_native_publisher.dart` — read 2026-09-25.
