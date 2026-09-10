# Consolidated release decisions

## Authority and supersession

The operative plan is 17, criteria 19 and tasks 20. They supersede 01/02/03 and contradictory recommendations in 16 and the earlier Conclusion section of 23; all older artifacts remain preserved. The final Supported narrow waiver diagnostic section of 23 supplies the controlling warning evidence. Planning needs no additional product design round. Implementation authorization, eventual account selection and exact-candidate upload approval remain separate actions.

## Selected release

| Decision | Selected result | Evidence or execution gate |
|---|---|---|
| Package/import | webmcp_flutter; lib/webmcp_flutter.dart | Completed work 0006; no repeat rename |
| Version/channel | Ordinary 0.1.0 | Existing manifest and visibility rationale in 16; recheck name/version immediately before upload |
| Scope | Detection-first local registry, async local calls and explicit Flutter ownership/lifecycle | 08, supported by version-pinned 14/15 |
| SDK/platform | Minimum Flutter 3.47.0 and Dart 3.13.0; web-only; test that exact combination | Add Flutter constraint; capture exact versions and full suite; no broader matrix claimed |
| License | Preserve existing MIT and holder | LICENSE unchanged; confirm redistribution authority at launch |
| Public URLs | Omit optional homepage/repository while configured public remote is empty | Dated unauthenticated observations in 16; do not fabricate destinations |
| Publisher/account | User-selected authorized first-upload account | Confirm privately before upload; no guessed identity or personal account data in wiki |
| Candidate identity | Sorted full relative paths, sizes and SHA-256 of source and payload | Stable content, no mandatory commit; preserve original index/unrelated changes |

## Existing semantic contract

Include local name validation, first-owner duplicate protection, local async invocation, ownership-scoped removal, idempotent scope close and explicit widget actions. Document singleton lifetime, closed-scope restrictions and unchanged-child rendering. A disabled child does not disable or authorize direct tool invocation. Mounted descriptor name/description/schema stay fixed until remount while the callback observes the newest widget callback.

Schemas are shallow copied: nested values remain shared and the descriptor performs no runtime JSON Schema validation. Source registration is sequential: earlier successful items remain if a later item fails. Local handler results and exceptions pass through; no browser-safe result envelope or error filtering is promised. Registry mutations precede custom transport notifications, whose exceptions propagate without rollback. Reset clears local state and replaces transport without unregistering or disposing its predecessor; externally stateful custom transports require caller-managed cleanup. Built-in detection logs do not constitute tool publication.

## Comparison gap dispositions

| Gap/risk class from 14/15 | Disposition |
|---|---|
| Browser registration/invocation/unpublication, attach-time hot synchronization and repeated adapter attachment | Deferred bridge work; no local adapter/parity requirement; external repeated-attach behavior remains unverified |
| Cancellation, pending handles, origin exposure, titles, typed decoders, annotations and advanced support status | Deferred with browser integration |
| Wire validation, result normalization, safe errors and invocation logging/privacy boundaries | Deferred; document unchanged raw local values and errors |
| Dynamic descriptor/enable reconciliation | Deferred; disclose mounted identity and child-enabled distinction |
| Deep immutability and runtime schema validation | Deferred; disclose shallow descriptor semantics |
| Partial registration, notification failure atomicity and reset cleanup | Document existing observed behavior; no transactional rewrite |
| Detection proof | Include real-browser property-presence cases; no native experimental API prerequisite |
| Product differentiation and external evidence limits | Include truthful local capability positioning; no uniqueness or whole-ecosystem claims |

## Consumer payload

Retain lib/**, LICENSE, README.md, CHANGELOG.md, pubspec.yaml, example/lib/**, example/web/**, example/pubspec.yaml and example/analysis_options.yaml, plus assets actually declared/consumed by the example. Exclude root test/**, example/test/** and tools/** together because repository-hygiene tests depend on repository infrastructure. Also exclude wiki/**, root analysis configuration, agent/CI/editor configuration, generated builds/caches, lockfiles and local OS files. Repeat all relevant .gitignore environment/key/secret/generated exclusions in .pubignore, review any environment-example exception explicitly, and inspect every actual dry-run path. A release payload may not acquire private or repository-only material simply because it is tracked.

The original complete source candidate runs the canonical suite with existing Git context. Copy its reviewed content without Git metadata for the first packaging dry-run, preserving .pubignore and comparing content hashes; never alter the original index to remove dirty/stale-tracked warnings. This Git-free packaging copy does not run repository-hygiene tests. The filtered payload runs publishing validation and external consumer/example checks. The installed CLI has no archive-output option: reproduce its selected files byte-for-byte and hash the complete path inventory. Do not call this a downloaded or exported publish archive. Final dry-run, consumer tests and eventual upload use the same immutable payload tree.

## Precise warning policy

The exact accepted diagnostic is: It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml. Evidence in 23 shows an ordinary dry-run with only this warning and no errors exits 65; the identical candidate with the documented --ignore-warnings option retains validation and exits zero with the same diagnostic and file list. Its disposable diagnostic candidate is not a release-ready payload.

For the actual release, retain the ordinary dry-run first. If there are no warnings/errors, require exit zero. If and only if that exact optional-URL warning is the sole warning with zero errors, record its disposition and run dry-run again with --ignore-warnings on unchanged bytes, requiring exit zero and identical inventory/diagnostics. All other warnings or errors block; dependency-update informational notices are retained but are not publication warnings. Never use --skip-validation or --force. After separate approval, an interactive upload may use --ignore-warnings solely for this recorded exception; abort on any unexpected warning/error or changed candidate before confirmation. Server-side refusal remains a failure requiring investigation.

## Planning completion and future launch

Planning completion means consolidated artifacts, pasted wiki-lint/fence evidence, independent review dispositions and updated state. Implementation still must satisfy preupload gates; hosted checks follow authorized upload and cannot circularly block the preupload verdict. The upload gate includes live name/version availability, privately verified account/redistribution authority and explicit approval of exact payload/version/account. No source publication, Git staging, commit or push is required merely to complete this plan.
