# Capability comparison and release scope decision

This artifact closes the comparison prerequisite carried from work item 0004. It combines the two independently sourced, version-pinned comparisons rather than copying third-party implementation.

## Sources and coverage

- [KickNext comparison](14-kicknext-comparison.md): published flutter_webmcp 0.3.0, archive SHA-256 and matching GitHub tag, local/external file-and-line capability matrix.
- [IntentCall comparison](15-intentcall-comparison.md): published intentcall_webmcp 0.6.0, archive SHA-256 and local/external file-and-line capability matrix.
- Current local contract: lib/src/webmcp.dart, lib/src/webmcp_scope.dart, lib/src/webmcp_tool.dart, lib/src/widgets and lib/src/transport; renamed public barrel lib/webmcp_flutter.dart. Paths are relative to repository root.

## Disposition of every gap class

| Capability or risk | Decision for webmcp_flutter 0.1.0 | Execution requirement |
|---|---|---|
| Local register/unregister, direct async invocation, ownership scopes, explicit widget actions | Included | Preserve existing behavior and public import tests. |
| Browser detection | Included as property-presence detection only | Exercise the actual transport in browser fixtures with the marker present and absent; no native interoperability claim. |
| Native browser registration/execution, origin exposure, annotations, cancellation, wire result/error envelopes, advanced support status | Deferred together to a future browser integration work item | README must explicitly state browser agents cannot discover/invoke tools through this release. No parity claim. |
| Runtime JSON Schema validation and deep copying | Deferred | Document shallow schema copying and that a schema descriptor does not validate local arguments or establish wire validity. |
| Dynamic descriptor/enable-state reconciliation | Deferred | Document the mounted descriptor identity and latest-callback behavior; enabled state of a child is not authorization for the tool. |
| Partial source registration | Document existing contract | Earlier registrations remain when a later descriptor fails; no transactional promise. Add focused contract evidence only if missing. |
| Reset and custom transport notification failure | Document existing contract | Reset clears local state without disposing/unregistering the prior transport. Notification failures propagate after local mutation, with no automatic rollback. Custom externally stateful transports require caller-managed cleanup and are not validated browser integrations. |
| Product positioning | Local registry and Flutter lifecycle convenience | Do not claim these features are unique, since KickNext also has a widget scope and IntentCall has adapter cleanup. |

The terms bug and uncertain in the source reports identify risk candidates, not independently established violations of the existing product contract. The main-agent disposition above closes the design question by documenting observed semantics rather than expanding runtime behavior. Universal claims in the streams that built-in transports cannot throw are not adopted: only their inspected straight-line behavior is known. Browser detection is source-supported today; runtime proof is a future release acceptance gate, not a passed check.

## Release choice and remaining boundaries

Keep the accepted name webmcp_flutter and current version 0.1.0 as the first ordinary release after all release gates pass. This is a narrow public contract, not a claim of full WebMCP implementation. The earlier tentative prerelease recommendation is superseded. A named version and documented contract make the implementation plan actionable; final upload still requires an authorized account and explicit approval of the exact candidate.

No comparison gap requires additional design research before preparing this scoped release. All deferred features have explicit exclusions above. A later decision to add any of them returns to a separate research/plan/validation cycle.

## Standards check

The current WebMCP draft places modelContext on Document in section 4.1. The local entry-point choice therefore agrees with the current draft; this does not prove browser support or tool interoperability. Source: https://webmachinelearning.github.io/webmcp/#dom-document-modelcontext, accessed 2026-09-10.
