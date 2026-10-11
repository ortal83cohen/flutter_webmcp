# Research review — round 01

- Work item: 0019-library-maintenance-wins
- Reviewed artifact: `wiki/work/0019-library-maintenance-wins/00-research.md` (working tree, 2026-10-11)
- Reviewer: research-validator
- Date: 2026-10-11

## Verdict

**CONDITIONAL**

The archive, workflow, requestId and documentation findings check out against their sources, but the headline public-surface count is contradicted by the exported library. The plan would close a gap smaller than the real one. That blocker does not invalidate the chosen approach, so it must close before the plan relies on the count.

## Verification performed

This reviewer had read, search and web tools only. It did not run `dart pub publish --dry-run`, so the 144 KB archive size and the dry-run file listing at `00-research.md:17-19` rest on the stream file `research/publish-archive.md:13-17`. The directory facts behind that claim were checked independently, as follows.

- `.pubignore` lines 1-43 were read in full. It has no `/packages/` or `/spikes/` entry. A search of `.gitignore` for `spikes|packages` returned no matches. Glob on `packages/*` and `spikes/*` returned 63 tracked files, including Python tools, PNG icons and test files.
- A search of `lib/` for `packages/|spikes/` returned no matches.
- `tools/check.sh` lines 1-74 were read. Stages 2-6 reference `packages/` and `example`, and no stage references `spikes/`.
- `example/pubspec.yaml` lines 14-15, 22-23 and 25-27 declare path dependencies into `../packages/`. Line 3 is `publish_to: none`.
- `README.md` lines 14-16 contain the `/issues/new/choose` link. Lines 352-355 contain the retry sentence without the six-field rule. Lines 470-471 say publication availability of the companion packages is not established.
- `pubspec.yaml` lines 4-5 contain `repository` and `homepage`, and there is no `issue_tracker` key. `lib/webmcp_flutter.dart` lines 1-13 contain only export statements. Glob `example/README*` returned 0 files.
- `.github/workflows/publish.yml` was read in full. The tag filter is at lines 12-14. The steps at lines 24-44 are checkout, setup, `pub get`, setup-dart, setup, dry run and `publish --force`, with no check suite. Flutter `3.47.0` with `flutter-actions/setup-flutter@v4` is at lines 28-31. `release.yml` runs `bash tools/check.sh` at lines 66-67.
- `wiki/product/release-pipeline.md` lines 18-23 state the tag-push-only rule. https://dart.dev/tools/pub/automated-publishing, fetched 2026-10-11, confirms it: "Only GitHub Actions triggered by a push of a tag that matches this tag pattern will be allowed to publish your package."
- https://dart.dev/tools/pub/publishing#what-files-are-published, fetched 2026-10-11, supports the claim at `00-research.md:95`. It says that hidden files and `.pubignore` or `.gitignore` entries are excluded, and that a directory's `.pubignore` overrules its `.gitignore`.
- `lib/src/page/page.dart` lines 4-15 export the seven page symbols. `lib/src/webmcp_typed_input.dart` declares the safe-integer minimum at line 4, the maximum at line 7 and `WebMcpInputShape` at line 10. `lib/src/page/webmcp_page_protocol.dart` sets the protocol version to 1 at line 4 and `webMcpMaxSafeInteger` to `9007199254740991` at line 7. None of the ten names occur in `test/webmcp_public_surface_test.dart`, which was read in full.
- `lib/src/page/webmcp_page.dart` lines 1010-1032 contain the fence and the six-field fingerprint, as claimed. `_normalizeInteger` is at lines 703-712.
- A search of `test/` for `requestId|webMcpMaxSafeInteger|duplicateRequest` found requestId values 2, 2, 1 and 3 in the lines 102-170 test, `1.0` at line 230, and otherwise only `requestId: 1`. No test uses 0, the maximum, the maximum plus one, or the same id with a different action.
- A declaration search across `lib/src` excluding `page/` was cross-checked against the unfiltered `export` lines in `lib/webmcp_flutter.dart`. The result is in F-001.

## Per-criterion results

Not applicable. This is a research review.

## Findings

### F-001 — The count of untested exported symbols is wrong, and the real gap is larger than ten

- Severity: BLOCKER
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:9` and `:59`
- Criterion affected: none
- Observation: The artifact says the surface test "misses ten exported symbols" and lists only page and typed-input names. `lib/webmcp_flutter.dart` lines 2, 4 and 6 export `native_publisher_boundary.dart`, `webmcp_native_publisher.dart` and `webmcp.dart` with no `show` filter. These public declarations from those files are also absent from `test/webmcp_public_surface_test.dart`:
  - `WebMcpToolCallHandler` (`lib/src/webmcp_tool.dart:12`)
  - `WebMcpRegistryResetObserver`, `WebMcpLogKind` and `webMcpRecordLog` (`lib/src/webmcp.dart:44`, `:50`, `:98`)
  - the five `webMcpNativeMax*` constants, `webMcpNativeOperationRetention`, `webMcpNativeClock` and `WebMcpToolActivitySubscription` (`lib/src/transport/webmcp_native_publisher.dart:12-30`, `:515`)
  - `WebMcpNativeReasonCode`, `WebMcpNativeInvocationContext`, `WebMcpNativeToolActivityKind`, `webMcpNativeRegistrationObject`, `WebMcpNativeInvocationHandler`, `WebMcpNativeRegistration`, `WebMcpNativeBoundary`, `WebMcpNativeBoundaryException`, `createWebMcpNativeBoundary` and `webMcpNativeBoundaryFactory` (`lib/src/transport/native_publisher_boundary.dart:5`, `:35`, `:50`, `:71`, `:89`, `:95`, `:101`, `:124`, `:133`, `:137`)

  That makes at least 22 more. The test title at `test/webmcp_public_surface_test.dart:22` claims "the complete public API". The artifact neither scopes its claim to a named subset nor lists these names as excluded or unresolved.
- Why it matters: A plan built on "ten symbols" would leave most of the untested public surface in place while the test continues to claim completeness. That is the gap the research question asks to close.

### F-002 — The check-job decision overstates what it closes

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:53` and `:88`
- Criterion affected: none
- Observation: The artifact says the check job "closes a manually pushed tag without changing the pub.dev trigger". A tag-triggered run uses the workflow file of the tagged commit. The gate therefore holds only for tags on commits whose `publish.yml` contains the check job. A tag on a commit with an older or edited `publish.yml` still publishes. The official page https://dart.dev/tools/pub/automated-publishing (lines 180-217 of the fetched text) contrasts this with environment protection, which "cannot be circumvented by modifying the workflow file". The artifact does not record this limit as a constraint or as an unresolved item.
- Why it matters: Without that limit stated, the plan's safety claim about manually pushed tags reads as complete when it is conditional.

### F-003 — The officially documented tag-hardening options are missing from the options table

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:83-91`
- Criterion affected: none
- Observation: The official automated-publishing page names two mechanisms for limiting who can trigger a publish. The first is tag protection rules. The second is a GitHub Deployment Environment that pub.dev requires through "Require GitHub Actions environment". Neither appears in the options table. Protected-tag rulesets appear only as the unresolved item at line 104. Environments appear nowhere. The stream `research/publish-workflow.md:76` considered rulesets as Option C, and the synthesis dropped it from the table.
- Why it matters: These are the source-endorsed alternatives for the exact risk named in the question. Leaving them out makes the workflow-file choice look like the only option weighed against `workflow_run`.

### F-004 — The README fingerprint gap has no recorded disposition

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:71`
- Criterion affected: none
- Observation: The documentation-gap finding says the root README does not state the six-field match rule (`README.md:352-355`). No decision covers it. The decision at line 77 covers only `issue_tracker` and the library doc comment, and the unresolved list at lines 102-104 omits it. The source stream marked the wording as unresolved (`research/tests-and-docs.md:90`).
- Why it matters: The question asks for missing documentation. A gap raised in the body with no decision and no unresolved entry leaves the plan to guess whether it is in scope.

### F-005 — The upper-fence test constraint is stated too strongly

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:98`
- Criterion affected: none
- Observation: The artifact says the upper-bound rejection case "must send an integer above the maximum". `_normalizeInteger` (`lib/src/page/webmcp_page.dart:703-712`) converts any finite integer-valued double to an int. A double such as 9007199254740992.0 becomes an int above the maximum and is rejected at line 1010. Only a double that equals the maximum is accepted.
- Why it matters: The integer form still works, so the plan is not harmed. The claim is broader than its source.

### F-006 — The fence is stated as unconditional when earlier guards run first

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:65`
- Criterion affected: none
- Observation: The `invalidArguments` result for an out-of-range `requestId` is reached only after the scope, eligibility, stale-snapshot and unsupported-action checks pass (`lib/src/page/webmcp_page.dart:976-1009`). The claim reads as if the fence applies unconditionally.
- Why it matters: It is minor, but boundary tests must use a fresh snapshot and a supported action to reach the fence.

### F-007 — The check-suite constraint omits the Python requirement

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:96`
- Criterion affected: none
- Observation: The artifact says `tools/check.sh` needs Flutter and Dart. Stage 1 also runs `python3 tools/lint_wiki.py` (`tools/check.sh:20`). `release.yml` provisions Python 3.12 at lines 56-58, and `publish.yml` has no Python setup step. `tools/lint_wiki.py` imports only standard-library modules (lines 17-23). Whether `ubuntu-latest` ships `python3` was not verified by this reviewer.
- Why it matters: The check job's runtime prerequisites are incompletely stated.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research |
| F-002 | research |
| F-003 | research |
| F-004 | research |
