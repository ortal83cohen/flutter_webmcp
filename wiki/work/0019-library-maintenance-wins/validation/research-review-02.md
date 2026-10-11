# Research review — round 02

- Work item: 0019-library-maintenance-wins
- Reviewed artifact: `wiki/work/0019-library-maintenance-wins/00-research.md` (working tree, 2026-10-11)
- Reviewer: research-validator
- Date: 2026-10-11

## Verdict

**CONDITIONAL**

Every cited source supports the claim it is attached to and no blocker remains, but three IMPORTANT findings from round 01 are still present unchanged, and the new ten-symbol scoping misdescribes its own deferred remainder as unknown.

## Verification performed

- `dart pub publish --dry-run` was run at the repository root. Filtered output:

  ```
  68:├── packages
  96:└── spikes
  146:Total compressed archive size: 144 KB.
  ```

  This confirms the claim at `00-research.md:16`.
- `.pubignore` lines 1-43 were read in full. It has no `/packages/` or `/spikes/` entry.
- `tools/check.sh` lines 1-74 were read. The preflight for `flutter` and `dart` is at lines 7-13. Stage 1 runs `python3 tools/lint_wiki.py` at line 20. Stages 2-6 reference `packages/` and `example`, and no stage references `spikes/`.
- `.github/workflows/publish.yml` was read in full. The tag filter is at lines 12-14. The steps at lines 24-44 contain no check suite. `flutter-actions/setup-flutter@v4` with `3.47.0` is at lines 28-31. `release.yml` runs `bash tools/check.sh` at lines 66-67.
- `wiki/product/release-pipeline.md` lines 18-23 state the tag-push-only rule.
- https://dart.dev/tools/pub/automated-publishing was fetched on 2026-10-11. Line 60 of the fetched text says "Only GitHub Actions triggered by a push of a tag that matches this tag pattern will be allowed to publish your package." Line 133 says "Consider using tag protection rules or GitHub deployment Environments to limit who can publish." Line 217 says "a user with permission to push to your repository cannot circumvent environment protection rules by modifying the workflow file."
- https://dart.dev/tools/pub/publishing#what-files-are-published was fetched on 2026-10-11. It supports the constraint at `00-research.md:95`.
- `example/pubspec.yaml` lines 14-15, 22-23 and 25-27 declare path dependencies into `../packages/`. `README.md` lines 470-471 say "publication availability is not established here". `README.md` lines 14-16 carry the `/issues/new/choose` link. Lines 352-355 carry the retry sentence without the six-field rule.
- `pubspec.yaml` lines 4-5 contain `repository` and `homepage`, and there is no `issue_tracker` key. `lib/webmcp_flutter.dart` lines 1-13 are thirteen unfiltered `export` lines and nothing else. Glob `example/README*` returned 0 files.
- `lib/src/page/page.dart` lines 4-15 export the seven page symbols. `lib/src/webmcp_typed_input.dart` declares the safe-integer minimum at line 4, the maximum at line 7 and `WebMcpInputShape` at line 10. `lib/src/page/webmcp_page_protocol.dart` sets `webMcpPageProtocolVersion = 1` at line 4 and `webMcpMaxSafeInteger = 9007199254740991` at line 7. `test/webmcp_public_surface_test.dart` was read in full. Lines 43-72 contain none of the ten names, and line 22 titles the test "exports the complete public API and seven registry operations".
- `lib/src/page/webmcp_page.dart` lines 1010-1032 contain the range fence, the six-key fingerprint and the cached-receipt branch, as the artifact claims.
- The stream files `research/publish-archive.md`, `research/publish-workflow.md` and `research/tests-and-docs.md` were read in full. The cited line ranges contain the referenced content.

## Per-criterion results

Not applicable. This is a research review.

## Findings

### F-001 — The check-job decision still overstates what it closes

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:53` and `:88`
- Criterion affected: none
- Observation: Line 88 still says the check job "closes a manually pushed tag without changing the pub.dev trigger". A tag-triggered run uses the `publish.yml` of the tagged commit, so the gate covers only tags on commits whose workflow file contains the check job. The official page (fetched text line 217) states that a workflow-file control can be circumvented by modifying the workflow file and that environment protection cannot. The Constraints list at lines 93-100 and the Unresolved list at lines 102-105 still do not record this limit.
- Why it matters: The plan will inherit an unconditional safety claim for a gate that is conditional on the tagged commit's workflow file.

### F-002 — The source-endorsed tag-hardening options are still missing from the options table

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:83-91`
- Criterion affected: none
- Observation: The official automated-publishing page (fetched text lines 133 and 172-219) names tag protection rules and a required GitHub Deployment Environment as the ways to limit who can publish. The table still weighs the workflow-file check only against `workflow_run`. Protected-tag rulesets appear only in the Unresolved item at line 104. Deployment environments appear nowhere in the artifact. The stream `research/publish-workflow.md:76` still holds the ruleset option that the synthesis left out.
- Why it matters: These are the documented mitigations for the exact risk the question names. Without them, the chosen option has no recorded comparison against them.

### F-003 — The README fingerprint gap still has no disposition

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:71`
- Criterion affected: none
- Observation: Line 71 still records that the root README (`README.md:352-355`) does not say all six wire fields must match. The only documentation decision, at lines 75-79, covers `issue_tracker` and the library doc comment. The Unresolved list at lines 102-105 does not mention the README wording. The stream still marks it unresolved at `research/tests-and-docs.md:90`.
- Why it matters: A documentation gap is raised in the body with no decision and no unresolved entry, so the plan has to guess whether it is in scope.

### F-004 — The deferred remainder of the public surface is described as unknown when it is known

- Severity: IMPORTANT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:9`, `:59` and `:105`
- Criterion affected: none
- Observation: The question asks for closing "the known public-API ... test gaps". The artifact now limits the inventory to ten names and defers the rest. The Unresolved item at line 105 frames the remainder as "Which exported names ... are still unreferenced". Those names are enumerable from the unfiltered exports in `lib/webmcp_flutter.dart` lines 2, 4, 6 and 9. The artifact gives no reason for choosing the ten over the rest. It also does not record that `test/webmcp_public_surface_test.dart:22` claims "the complete public API", and that claim stays false after this work item.
- Why it matters: The plan inherits a scope cut with no recorded rationale, and a test title the research knows to be inaccurate goes unmentioned.

### F-005 — The upper-fence test constraint is still stated too strongly

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:98`
- Criterion affected: none
- Observation: The artifact says the upper-bound case "must send an integer above the maximum". An integer-valued double above the maximum is normalised to an int and also reaches the rejection at `lib/src/page/webmcp_page.dart:1010`.
- Why it matters: The integer form still works. The claim is broader than its source.

### F-006 — The fence is still stated as unconditional

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:65`
- Criterion affected: none
- Observation: The `invalidArguments` result is reached only after the earlier guards that end with the unsupported-action check at `lib/src/page/webmcp_page.dart:1007-1009`. The claim does not say so.
- Why it matters: It is minor. Boundary tests must satisfy those earlier guards to reach the fence.

### F-007 — The check-suite constraint still omits the Python requirement

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:96`
- Criterion affected: none
- Observation: `tools/check.sh:20` runs `python3`. `release.yml` provisions Python at lines 56-58, and `publish.yml` has no Python setup step. The constraint lists only Flutter and Dart.
- Why it matters: The check job's runtime prerequisites are incompletely stated.

### F-008 — The issue-tracker decision closes a stream question without a source

- Severity: NIT
- Location: `wiki/work/0019-library-maintenance-wins/00-research.md:77`
- Criterion affected: none
- Observation: The stream left open whether pub.dev renders the `issue_tracker` value without the `/new/choose` suffix (`research/tests-and-docs.md:91`). The artifact states "That is the tracker" and cites only `pubspec.yaml` and `README.md`, and neither addresses how pub.dev handles the field.
- Why it matters: The choice is plausible, but the stream's open question is closed without evidence.

## Recurrence check

- Previous round: `wiki/work/0019-library-maintenance-wins/validation/research-review-01.md`
- Recurring findings: F-001 is materially identical to round 01 F-002. F-002 is materially identical to round 01 F-003. F-003 is materially identical to round 01 F-004. F-005, F-006 and F-007 are materially identical to round 01 F-005, F-006 and F-007. Round 01 F-001 was addressed by rescoping. F-004 in this round is a new finding about that rescoping, not a repeat.
- Oscillating: yes. Six of the eight findings repeat round 01 unchanged at the same locations, which means round 01's IMPORTANT findings were not acted on. Escalation is recommended rather than a third research round.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research |
| F-002 | research |
| F-003 | research |
| F-004 | research |
