# Research review — round 02

- Work item: 0005-pubdev-release-readiness
- Reviewed artifact: 08-capability-comparison.md, 14-kicknext-comparison.md, 15-intentcall-comparison.md, 16-release-preflight.md, 18-preflight-output.md and 23-warning-policy-evidence.md; planning portions of 19-criteria-consolidated.md, with dispositions in 21-release-decisions.md
- Reviewer: independent final research reviewer
- Date: 2026-09-10

## Verdict

**PASS**

The pinned implementation comparisons support the scoped planning decision, and the final explicit dispositions resolve earlier tentative claims without treating diagnostics as release readiness.

## Verification performed

Independently ran `python3 tools/lint_wiki.py`, exit 0:

```text
lint_wiki: clean (0 warning(s)).
```

Independently ran `shasum -a 256 /private/tmp/intentcall_webmcp-0.6.0.tar.gz /private/tmp/flutter-webmcp-compare.nd6ZQO/flutter_webmcp-0.3.0.tar.gz`, exit 0:

```text
62bd22cdfbb9b46c08d8a90b47ccae2f47e314a5abf78acdfc7a92279436bdc2  /private/tmp/intentcall_webmcp-0.6.0.tar.gz
e4e7b513c84a6a51267605bd2cbc5f3df4a7e33307a77618b927f443448f22c6  /private/tmp/flutter-webmcp-compare.nd6ZQO/flutter_webmcp-0.3.0.tar.gz
```

Public metadata verification command, rerun with read-only network escalation after sandbox DNS failure:

```python
import urllib.request,json
for name,version in [('flutter_webmcp','0.3.0'),('intentcall_webmcp','0.6.0')]:
 d=json.load(urllib.request.urlopen('https://pub.dev/api/packages/'+name,timeout=20))
 v=next(v for v in d['versions'] if v['version']==version)
 print(name,version,v['archive_sha256'])
```

Executed through `python3 -`, exit 0:

```text
flutter_webmcp 0.3.0 e4e7b513c84a6a51267605bd2cbc5f3df4a7e33307a77618b927f443448f22c6
intentcall_webmcp 0.6.0 62bd22cdfbb9b46c08d8a90b47ccae2f47e314a5abf78acdfc7a92279436bdc2
```

Read the pinned archive implementations and compared archive member bytes against the extracted source/test/manifests with Python tarfile and pathlib assertions. Inspected local registry, scopes, mounted action and browser transport. These support the distinction between KickNext browser registration/reconciliation, IntentCall injected adapter callbacks, and local detection-only behavior. Comparison scope does not imply external dependency or live-host validation.

Independently ran `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart pub publish --help`, exit 0:

```text
Publish the current package to pub.dev.

Usage: dart pub publish [options]
-h, --help               Print this usage information.
-n, --dry-run            Validate but do not publish the package.
-f, --force              Publish without confirmation if there are no errors.
    --skip-validation    Publish without validation and resolution (this will
                         ignore errors).
-C, --directory=<dir>    Run this in the directory <dir>.
    --ignore-warnings    Do not treat warnings as fatal.

Run "dart help" to see global options.
See https://dart.dev/tools/pub/cmd/pub-lish for detailed documentation.
```

The wrapper-path attempt first encountered sandbox cache-write denial; the direct installed SDK command above resolved help inspection without modifying source. The CLI confirms the waiver option and absence of an archive-output option. The paired dry-run outputs in 23 remain diagnostic evidence; this review did not rerun publishing validation or the full suite and does not independently certify either release gate.

Independently opened the official [WebMCP draft](https://webmachinelearning.github.io/webmcp/#dom-document-modelcontext) and [Dart publishing guidance](https://dart.dev/tools/pub/publishing) on 2026-09-10. They support the Document entry point and separation between publishing guidance and project readiness gates.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 planning portion | pass | 08-capability-comparison.md:15; 08-capability-comparison.md:24; version/digest pins in 14 and 15; 21-release-decisions.md:28 | Review checked unsupported uniqueness, no-throw and whole-ecosystem inferences against explicit exclusions; no runtime gate exercised |
| AC-002 planning portion | pass | 21-release-decisions.md:9; 21-release-decisions.md:52; 23-warning-policy-evidence.md:111 | Review checked URL omission against the final sole-warning waiver, and account/name/authority checks remain future gates |

## Findings

None. Earlier universal no-throw wording and changing URL recommendations are expressly superseded by the final dispositions; they are not operative claims.

## Recurrence check

- Previous round: validation/research-review-01.md
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| None | Not applicable |
