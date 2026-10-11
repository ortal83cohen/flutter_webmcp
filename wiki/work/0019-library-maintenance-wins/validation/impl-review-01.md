# Impl review — round 01

- Work item: 0019-library-maintenance-wins
- Reviewed artifact: working tree of `/Users/ortalcohen/Documents/GitHub/flutter_webmcp` against commit `bf6d4795e0f339043487c4f007f1365573adf762` (HEAD), including untracked `example/README.md`. Changed files: `.github/workflows/publish.yml`, `.pubignore`, `lib/webmcp_flutter.dart`, `pubspec.yaml`, `test/page/webmcp_page_test.dart`, `test/webmcp_public_surface_test.dart`, `example/README.md`.
- Reviewer: impl-validator
- Date: 2026-10-11

## Verdict

**PASS**

All 23 criteria pass on checks I ran myself. Every criterion's negative case was exercised: on the base commit, on a scratch copy, or by mutating a scratch worktree with the change applied. Each negative case failed as required. The only finding is a non-blocking wording nit.

## Verification performed

All scratch mutations ran in disposable git worktrees under `/tmp` (`/tmp/wm_base` at the base commit; `/tmp/wm_scratch` at the base commit with `git diff bf6d479` applied and `example/README.md` copied). Both worktrees were removed afterwards. The reviewed working tree was never edited, apart from the authorised lockfile restore described under AC-020.

### AC-001 / AC-002: publish dry run, archive tree parsed by indentation

The dry run was captured for the working tree (`/tmp/dryrun_head.txt`) and for the base worktree (`/tmp/dryrun_base.txt`). A Python parser read the lines prefixed by box-drawing characters, rebuilt the parent chain from indentation, and tested names and parent-and-name tuples:

```
/tmp/dryrun_head.txt entries= 54
  packages present: False | spikes present: False
   README.md True
   CHANGELOG.md True
   LICENSE True
   lib/webmcp_flutter.dart True
   example/lib/main.dart True
   example/README.md True
/tmp/dryrun_base.txt entries= 127
  packages present: True | spikes present: True
   README.md True
   CHANGELOG.md True
   LICENSE True
   lib/webmcp_flutter.dart True
   example/lib/main.dart True
   example/README.md False
```

Excerpt of the working-tree archive listing:

```
├── CHANGELOG.md (2 KB)
├── LICENSE (1 KB)
├── README.md (32 KB)
├── example
│   ├── README.md (<1 KB)
...
│   └── webmcp_flutter.dart (<1 KB)
└── pubspec.yaml (<1 KB)

Total compressed archive size: 61 KB.
```

The base listing contains `├── packages` and `└── spikes` (total 144 KB).

Observation, not a finding: the working-tree dry run exited with code 65. Its only warning was `2 checked-in files are modified in git` (`lib/webmcp_flutter.dart`, `pubspec.yaml`), which is caused by the change being uncommitted. AC-001 and AC-002 constrain the archive tree, not the exit code. The base dry run reported `Package has 0 warnings.`

### AC-003: `.pubignore` changes only add lines

```
== AC-003 removed lines (expect none):
(none)
46:/packages/
47:/spikes/
== AC-003 negative: scratch with /test/ removed
< /test/
NEG: removed line detected -> fail
2:/test/
```

### AC-004, AC-005, AC-006, NF-001, NF-002: workflow parsed as YAML

PyYAML is not installed, so I wrote a Ruby script using Ruby's built-in `YAML` (`/tmp/wf.rb`). It loads the working-tree and base `publish.yml` files and asserts the following:

- The `check` job exists, and one of its steps runs exactly `bash tools/check.sh`.
- A `flutter-actions/setup-flutter@v4` step with `stable` and `3.47.0` comes before the script step.
- An `actions/setup-python@v5` step with `3.12` comes before the script step.
- `publish.needs` contains `check`.
- The `on` block and the `publish` job's `steps`, `permissions`, `runs-on` and `name` equal the base values.
- The `check` job's permissions equal `{contents: read}`, and only `publish` holds `id-token`.
- The `check` job contains no `secrets.` reference.

Scratch negatives:

- `neg_needs`: the `needs` line is removed.
- `neg_ver`: the check job uses Flutter `3.46.0`.
- `neg_order`: the setup-flutter step is moved after the script step.
- `neg_tag`: the tag pattern drops the `v` prefix.
- `neg_idtoken`: `id-token: write` is added to the check job.
- `neg_secret`: an env entry with `${{ secrets.FOO }}` is added to the check job.

```
publish.yml: ALL ASSERTIONS PASS
neg_needs.yml: FAIL AC-004 publish.needs lacks check
neg_ver.yml: FAIL AC-005 flutter setup missing/wrong
neg_order.yml: FAIL AC-005 order
neg_tag.yml: FAIL AC-006 on differs
neg_idtoken.yml: FAIL NF-001 check perms {"contents"=>"read", "id-token"=>"write"}; NF-001 id-token outside publish
neg_secret.yml: FAIL NF-002 secret in check
```

NF-002 text search of the check job block (lines 17 to 33) in the real file, then in the scratch copy:

```
--- NF-002 grep in check block:
0
18:          T: ${{ secrets.FOO }}
```

### AC-007 / AC-018: byte identity

```
== AC-007
[empty above = identical]
neg diff exit=1 (1=non-empty)
== AC-018
       0
Files - and /tmp/r.md differ
```

`git diff --stat bf6d479 -- .github/workflows/release.yml tools/check.sh` printed nothing. `git diff bf6d479 -- README.md | wc -c` printed 0. The negatives used a scratch `release.yml` with one appended blank line and a scratch `README.md` with one appended sentence; both produced non-empty diffs.

### AC-014: pubspec

```
+issue_tracker: https://github.com/ortal83cohen/flutter_webmcp/issues
6:issue_tracker: https://github.com/ortal83cohen/flutter_webmcp/issues
3:version: 0.1.11
version: 0.1.11
neg exact compare: False
```

The `+issue_tracker` line is the only `+` or `-` content line in `git diff bf6d479 -- pubspec.yaml`. The version is `0.1.11` at both revisions. Comparing the `/issues/new/choose` value exactly against the required string returns `False`.

### AC-008 / AC-009 / AC-010 to AC-013: tests on the real tree

```
$ flutter test test/webmcp_public_surface_test.dart test/page/webmcp_page_test.dart
...
00:01 +27: All tests passed!
WebMcpEvidenceKind: 1
WebMcpPageErrorCode: 5
WebMcpBindingViewProvider: 1
WebMcpViewBinding: 1
WebMcpViewProvider: 1
WebMcpInputShape: 1
webMcpPageProtocolVersion: 1
webMcpMaxSafeInteger: 1
webMcpSafeIntegerMinimum: 1
webMcpSafeIntegerMaximum: 1
```

The counts are word-boundary `grep -c` hits in `test/webmcp_public_surface_test.dart`.

### Mutation negatives in the scratch worktree with the change applied

The new test was run alone with `--plain-name 'requestId zero, above maximum, duplicate action, and maximum boundary'`. Each mutation targets the act guard at `lib/src/page/webmcp_page.dart:1010` or the fingerprint check at `lib/src/page/webmcp_page.dart:1027-1028`:

```
### BASELINE new test in scratch
00:00 +1: All tests passed!
### M1 remove lower bound
1010:    if (requestId > webMcpMaxSafeInteger) {
Expected: 'invalidArguments'
  Actual: 'duplicateRequest'
00:00 +0 -1: Some tests failed.
### M2 remove upper bound
1010:    if (requestId < 1) {
Expected: 'invalidArguments'
  Actual: <null>
00:00 +0 -1: Some tests failed.
### M3 upper bound >= (accepted boundary off by one)
Expected: true
  Actual: <null>
00:00 +0 -1: Some tests failed.
### M4 drop fingerprint comparison
0
Expected: 'duplicateRequest'
  Actual: <null>
00:00 +0 -1: Some tests failed.
### AC-012 negative: existing exact-repeat test still passes on real code
00:00 +1: All tests passed!
```

M2 shows that the Dart integer `webMcpMaxSafeInteger + 1` gets past integer normalisation and is stopped only by the upper-bound comparison, because removing that comparison let it dispatch. M3 shows that the accepted boundary is exactly the maximum.

The surface-test and analyzer mutations:

```
### M5 remove WebMcpViewBinding from show list
15:    show WebMcpBindingViewProvider, WebMcpViewProvider;
test/webmcp_public_surface_test.dart:78:14: Error: Undefined name 'WebMcpViewBinding'.
00:00 +0 -1: Some tests failed.
### M6 expected protocol version 2
83:      expect(webMcpPageProtocolVersion, equals(2));
  Expected: <2>
    Actual: <1>
00:00 +0 -1: Some tests failed.
### AC-015 analyzer real tree
Analyzing flutter_webmcp...
No issues found!
### M7 remove library directive
   info - webmcp_flutter.dart:1:1 - Dangling library doc comment. Add a 'library' directive after the library comment. - dangling_library_doc_comments
1 issue found.
### NF-003 real tree
Formatted 62 files (0 changed) in 0.19 seconds.
exit=0
### M8 extra space in edited test
Changed test/page/webmcp_page_test.dart
Formatted 62 files (1 changed) in 0.20 seconds.
exit=1
```

### AC-015 / AC-016 / AC-017: text reads

```
## AC-015 terms in doc comment
\[WebMcp\]: 1
WebMcpPage: 1
WebMcpNativePublisher: 1
experimental: 1
README: 1
library;
## AC-017
example/README.md:10:packages `webmcp_flutter_annotations` and `webmcp_flutter_generator` through
example/README.md:12:repository; the companion packages are not presented as published on pub.dev.
neg:
1:Install webmcp_flutter_generator from pub.dev.
## AC-016 base glob
0
```

`lib/webmcp_flutter.dart` contains neither companion-package name. I read every sentence in `example/README.md` that names a companion package (lines 9 to 12). None of them claims publication on pub.dev.

### AC-019: full suite

```
$ bash tools/check.sh
exit=0
3:Stage 1 passed: wiki lint
74:Stage 2 passed: dependencies
76:Stage 3 passed: format
85:Stage 4 passed: analysis
335:Stage 5 passed: tests
346:Stage 6 passed: build
402:Stage 7 passed: version bump test
417:Stage 8 passed: occupied pub.dev versions test
PASS: latest-only
PASS: mixed-prerelease
PASS: no-network-no-git
All tests passed
Stage 8 passed: occupied pub.dev versions test
```

### AC-020: protected paths

`check.sh` rewrote the two generator lockfiles. I confirmed the rewrite was only the path version, then restored both files with `git checkout` as the review brief permits:

```
-    version: "0.1.10"
+    version: "0.1.11"
-    version: "0.1.10"
+    version: "0.1.11"
== AC-020 after restore:
[empty above = identical, no untracked]
== AC-020 negative
 lib/src/webmcp.dart | 1 +
 1 file changed, 1 insertion(+)
```

### Leftover and test-gaming scan

```
== leftovers in diff
none
```

The diff was grepped for added `TODO`, `FIXME`, `print(`, `debugPrint` and `skip:`; there were no matches. The diff adds no mocks, skipped tests or widened assertions. The pre-existing exact-repeat assertion at `test/page/webmcp_page_test.dart:155` is unchanged. Every new constant assertion uses `equals` or `containsAll`. The new type-name references use `isNotNull`, which AC-008 permits because it requires only a reference plus compilation; M5 shows that the reference is load-bearing. The diff adds no product code under `lib/src/`, so it introduces no uncovered code path.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `.pubignore:46-47`; working-tree dry run has no `packages` or `spikes` entries | yes: base dry run lists both |
| AC-002 | pass | `example/README.md:1`; working-tree dry run tree has all six parent-and-name pairs | yes: base has no `example/README.md` entry |
| AC-003 | pass | `.pubignore:44-47` (added only); base `/test/` at `.pubignore:2` retained | yes: scratch with `/test/` removed detected |
| AC-004 | pass | `.github/workflows/publish.yml:17-32`, `:37` | yes: `neg_needs` fails |
| AC-005 | pass | `.github/workflows/publish.yml:24-32` | yes: `neg_ver` and `neg_order` fail |
| AC-006 | pass | `.github/workflows/publish.yml:11-14`, `:34-62` | yes: `neg_tag` fails |
| AC-007 | pass | `.github/workflows/release.yml`, `tools/check.sh`: empty diff | yes: appended blank line gives a non-empty diff |
| AC-008 | pass | `test/webmcp_public_surface_test.dart:75-86`; 27 tests passed | yes: M5 compile failure at `:78:14` |
| AC-009 | pass | `test/webmcp_public_surface_test.dart:83-95` | yes: M6 fails with Expected <2>, Actual <1> |
| AC-010 | pass | `test/page/webmcp_page_test.dart:192-202` | yes: M1 (lower bound removed) fails |
| AC-011 | pass | `test/page/webmcp_page_test.dart:204-218` (int literal `webMcpMaxSafeInteger + 1`) | yes: M2 (upper bound removed) fails |
| AC-012 | pass | `test/page/webmcp_page_test.dart:220-240` | yes: M4 fails; exact-repeat test at `:139-155` still returns the cached receipt |
| AC-013 | pass | `test/page/webmcp_page_test.dart:242-254` | yes: M3 (`>=`) fails; AC-011 shows max+1 is rejected |
| AC-014 | pass | `pubspec.yaml:6`; version `pubspec.yaml:3` unchanged | yes: `/issues/new/choose` exact compare is False |
| AC-015 | pass | `lib/webmcp_flutter.dart:1-8`; analyzer: No issues found | yes: M7 dangling library doc comment |
| AC-016 | pass | `example/README.md:9-12` (checkout and path-dependency reason), `:16-28` (steps) | yes: base has no `example/README.md` |
| AC-017 | pass | `example/README.md:9-12`; `lib/webmcp_flutter.dart` has no companion names | yes: scratch sentence matched by the search |
| AC-018 | pass | `README.md`: empty diff | yes: scratch sentence gives a non-empty diff |
| AC-019 | pass | `tools/check.sh` exit 0, `Stage 8 passed` | yes: the script's failure path was not triggered; criterion met by observed output |
| AC-020 | pass | `lib/src/`, `packages/`, `spikes/`: empty diff after the authorised lockfile restore | yes: touching `lib/src/webmcp.dart` in scratch gives a non-empty diff |
| NF-001 | pass | `.github/workflows/publish.yml:20-21`, `:38-40` | yes: `neg_idtoken` fails |
| NF-002 | pass | `.github/workflows/publish.yml:17-32`: 0 `secrets.` matches | yes: `neg_secret` matched |
| NF-003 | pass | `dart format` exit 0, 0 changed | yes: M8 exit 1 |

Pass: 23. Fail: 0.

## Findings

### F-001 — Example README describes its own framing instead of stating the fact

- Severity: NIT
- Location: `example/README.md:12`
- Criterion affected: none (AC-017 is satisfied)
- Observation: The sentence "the companion packages are not presented as published on pub.dev" describes how the document presents the packages. It does not state their publication status.
- Why it matters: A reader may still be unsure whether the companion packages exist on pub.dev. This does not affect any criterion.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 (NIT, non-blocking) | implement (optional; no blocker) |
