# Research: Competitor API and native WebMCP transport

Verified 2026-09-10.

## Findings

### Package identity and release inspected

- Claim: `flutter_webmcp` is the external competitor published by KickNext. Its latest pub.dev release on 2026-09-10 is 0.3.0, published 2026-09-04. This is distinct from this repository's package, `webmcp_flutter` 0.1.1.
- Evidence: The pub.dev package API names `flutter_webmcp` 0.3.0 and links the KickNext repository; the local `pubspec.yaml` names `webmcp_flutter` 0.1.1.
- Sources: https://pub.dev/api/packages/flutter_webmcp ; `pubspec.yaml:1-3`

### The competitor requires explicit, manual action definitions

- Claim: The competitor does not automatically discover page content or actions. An application author creates each `WebMcpTool` or `WebMcpTypedTool`, supplies its name, description, JSON Schema, decoder where typed input is wanted, and execute callback, then passes stable tool instances to `WebMcpToolScope` or calls `WebMcp.registerTool()` manually.
- Evidence: The published usage example constructs `addTaskTool` in `initState` and supplies it to `WebMcpToolScope`. The 0.3.0 source archive contains tool definitions, a registration API, a Flutter lifecycle scope, and the browser interop adapter; it contains no widget-tree, semantics-tree, DOM, route, or page-content discovery implementation.
- Sources: https://github.com/KickNext/flutter_webmcp#flutter-usage ; https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz

### The competitor is a publisher bridge, not an in-page agent

- Claim: `flutter_webmcp` publishes application-defined tools through `document.modelContext.registerTool`. Its public surface does not expose `getTools()`, `executeTool()`, `toolchange`, page observation, or an agent loop that discovers and invokes other page tools.
- Evidence: The README describes typed bindings and lifecycle helpers for exposing actions. The 0.3.0 browser adapter binds `registerTool`, `AbortController`, and execution callbacks only. By contrast, the WebMCP API defines `getTools()`, `executeTool()`, and `toolchange` as separate consumer-side facilities.
- Sources: https://github.com/KickNext/flutter_webmcp#core-dart-api ; https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz ; https://developer.chrome.com/docs/ai/webmcp/imperative-api

### Native WebMCP is a browser API, not an MCP network transport

- Claim: A native transport for this repository must bridge Dart to the browser-owned `document.modelContext`; WebMCP does not require an MCP server, JSON-RPC session, stdio, SSE, or Streamable HTTP transport. The browser or an in-page agent discovers and invokes tools through browser mechanisms.
- Evidence: The current draft defines `Document.modelContext` and its `registerTool`, `getTools`, and `executeTool` methods. It explicitly says `getTools()` is for in-page JavaScript agents while a browser agent uses a different internal retrieval mechanism.
- Source: https://webmachinelearning.github.io/webmcp/#api

### Minimum publisher-side native bridge requirements

- Claim: The bridge needs a secure browser context with `document.modelContext`; it must register a tool with a unique valid name, non-empty description, JSON Schema input, and execute callback. It must translate invocation input and output across Dart/JavaScript, pass execution cancellation, and unregister through the registration `AbortSignal`. Cross-origin exposure is opt-in through `exposedTo`, and the `tools` Permissions Policy defaults to `self`.
- Evidence: These requirements appear in the current WebIDL and algorithms for `Document`, `ModelContextTool`, `ToolExecuteCallbackOptions`, `ModelContextRegisterToolOptions`, and Permissions Policy integration.
- Sources: https://webmachinelearning.github.io/webmcp/#dom-document-modelcontext ; https://webmachinelearning.github.io/webmcp/#modelcontexttool ; https://webmachinelearning.github.io/webmcp/#modelcontextregistertooloptions ; https://webmachinelearning.github.io/webmcp/#permissions-policy

### A stateful Flutter bridge also needs lifecycle synchronization

- Claim: For this repository, native publication must synchronize tools that already exist when the bridge attaches, later registrations and removals, replacement or duplicate behavior, in-flight registration cancellation, and page/scope teardown. These are integration requirements derived from combining the local registry contract with the browser's per-document registration lifetime; they are not supplied by page discovery.
- Evidence: The local contract makes `WebMcp.instance` the source of truth and defines ownership and collision semantics. The browser API registers tools into a document model context and uses abort signals for registration lifetime. The competitor's `WebMcpToolScope` demonstrates one possible mounted-lifetime reconciliation strategy but does not solve synchronization for this repository's existing registry.
- Sources: `wiki/product/webmcp-contract.md` ; https://developer.chrome.com/docs/ai/webmcp/imperative-api#unregister-tools ; https://github.com/KickNext/flutter_webmcp#flutter-usage

### Automatic page understanding is a separate product layer

- Claim: The current imperative WebMCP API does not provide a method that returns arbitrary page content, the Flutter semantics tree, or hidden application data. It publishes developer-defined tools. Therefore an automatic page agent needs an explicit, opt-in runtime snapshot or query tool whose implementation reads the page representation available to the application; optional domain actions can remain explicitly annotated tools.
- Evidence: The imperative API's publisher object is a structured tool definition. The only browser discovery method returns registered tools, not page content. The declarative API synthesizes tools only from annotated HTML forms with `toolname` and `tooldescription`; it is not general page-content discovery.
- Sources: https://developer.chrome.com/docs/ai/webmcp/imperative-api ; https://developer.chrome.com/docs/ai/webmcp/declarative-api

### Declarative annotations are not a complete Flutter runtime discovery strategy

- Claim: Browser declarative WebMCP applies to standard HTML forms carrying WebMCP attributes. It can complement a Flutter application only where the deployed page actually exposes eligible annotated HTML forms; it does not establish discovery of arbitrary Flutter widgets or application state.
- Evidence: Chrome documents declarative registration as transforming a `<form>` with `toolname` and `tooldescription` into a tool, with form controls becoming parameters. No cited browser source states that arbitrary rendered controls, semantic nodes, hidden state, or lazy data become tools.
- Source: https://developer.chrome.com/docs/ai/webmcp/declarative-api

### Completeness claims must be bounded to materialized, permitted runtime state

- Claim: An opt-in runtime snapshot can promise only the content its chosen source exposes at query time and that policy permits. It cannot promise all hidden, paginated, virtualized, lazy-loaded, server-only, or authorization-gated data without application-specific providers. This is an architectural limitation inferred from the absence of any general page-content operation in WebMCP and from deferred automatic widget discovery in the local product contract.
- Evidence: WebMCP exposes registered tools and annotated forms; the local contract explicitly defers automatic widget discovery. Neither source defines access to unmaterialized application data.
- Sources: https://webmachinelearning.github.io/webmcp/#api ; `wiki/product/webmcp-contract.md`

### The API is still moving and annotations already show version drift

- Claim: Compatibility must be versioned and tested rather than inferred from property presence alone. The competitor says 0.3.0 targets the 26 August 2026 draft and exposes `readOnly` and `untrustedContent`; the 9 September 2026 draft also defines `consequentialHint`. Chrome describes WebMCP as experimental and subject to change.
- Evidence: The competitor README names its tested draft and archive source defines two annotation fields. The current draft's `ToolAnnotations` has three fields. Chrome warns that the API remains under active discussion.
- Sources: https://github.com/KickNext/flutter_webmcp#compatibility ; https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz ; https://webmachinelearning.github.io/webmcp/#dictdef-toolannotations ; https://developer.chrome.com/docs/ai/webmcp/imperative-api#engage-and-share-feedback

## Options

| Option | How it works | Cost | Decision |
|---|---|---|---|
| Competitor-style explicit publication only | Developers define every domain tool and mount or register it manually. | Low discovery complexity; high integration work per action; no generic page-content view. | Keep as the model for optional high-value domain actions, but it does not meet automatic page-content discovery by itself. |
| Opt-in runtime semantic snapshot plus optional domain actions | Publish a bounded read-only tool that queries the currently materialized, permitted page/runtime representation; publish explicitly annotated domain actions alongside it. | Requires snapshot schema, filtering, limits, refresh semantics, privacy rules, and a native browser publisher bridge. | Preferred planning direction because it separates generic page context from deliberate mutations and avoids completeness claims. |
| Browser declarative forms | Add `toolname` and `tooldescription` to actual HTML forms so the browser synthesizes tools. | Small for conventional HTML forms; applicability to Flutter-rendered controls is unverified and it covers form actions rather than general page content. | Complementary only where eligible HTML forms exist. |
| Automatic inference of every action and all page data | Crawl UI/runtime state and infer tools without developer declarations. | High ambiguity, privacy and authorization risk; impossible to substantiate completeness for lazy, hidden, virtualized, or server-only data. | Rejected for this work item. |

## Unresolved

- [UNRESOLVED: Which Flutter runtime representation will be the source of the automatic snapshot: Flutter semantics, an application-owned page model, browser DOM/accessibility output, or a composition of them?]
- [UNRESOLVED: What exact opt-in boundary, redaction policy, size budget, and refresh/version semantics will govern the snapshot?]
- [UNRESOLVED: Whether Flutter Web's active renderer and semantics configuration expose enough stable runtime information for DOM- or accessibility-based discovery across JavaScript and WebAssembly builds.]
- [UNRESOLVED: Which WebMCP draft/browser versions the first native bridge will support, and whether compatibility shims are required for return-value and annotation changes.]
- [UNRESOLVED: Whether the first release needs consumer-side `getTools()`, `executeTool()`, and `toolchange`, or publisher-side registration only.]

## Sources

- pub.dev package metadata for `flutter_webmcp`, consulted 2026-09-10: https://pub.dev/api/packages/flutter_webmcp
- Published `flutter_webmcp` 0.3.0 source archive, consulted 2026-09-10: https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz
- KickNext `flutter_webmcp` repository and README, consulted 2026-09-10: https://github.com/KickNext/flutter_webmcp
- WebMCP Draft Community Group Report dated 2026-09-09, consulted 2026-09-10: https://webmachinelearning.github.io/webmcp/
- Chrome WebMCP Imperative API documentation, last updated 2026-08-20 and consulted 2026-09-10: https://developer.chrome.com/docs/ai/webmcp/imperative-api
- Chrome WebMCP Declarative API documentation, published 2026-05-18 and consulted 2026-09-10: https://developer.chrome.com/docs/ai/webmcp/declarative-api
- Chrome WebMCP tool security documentation, last updated 2026-09-01 and consulted 2026-09-10: https://developer.chrome.com/docs/ai/webmcp/secure-tools
- Local package identity, consulted 2026-09-10: `pubspec.yaml`
- Local product contract, consulted 2026-09-10: `wiki/product/webmcp-contract.md`
