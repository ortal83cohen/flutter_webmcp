---
id: work-0008-research-review-01
title: Automatic page agent research review round 01
status: active
owner: research-validator
last_verified: 2026-09-10
applies_to: ["wiki/work/0008-automatic-page-agent/00-research.md"]
summary: Blind research validation with independent primary-source checks and two non-blocking findings.
---

# Research review — round 01

- Work item: 0008-automatic-page-agent
- Reviewed artifact: wiki/work/0008-automatic-page-agent/00-research.md
- Reviewer: research_validator
- Date: 2026-09-10

## Verdict

**PASS**

The research supports a contingent design, identifies realistic alternatives and material coverage/privacy/lifecycle limitations, and gates empirical unknowns rather than presenting future acceptance criteria as completed behavior; two non-blocking precision/metadata findings remain.

## Verification performed

Reviewed only the research artifact, criteria, rubric, report template, and cited primary sources. No intermediate research reports or author rationale were read. No implementation or runtime acceptance test was claimed.

Executed `cat pubspec.yaml lib/src/widgets/webmcp_screen.dart lib/src/webmcp_tool_source.dart`. Relevant exact output excerpts:

```text
name: webmcp_flutter
version: 0.1.1
  sdk: ^3.13.0
  flutter: ">=3.47.0"
  analyzer: ^13.3.0
  void initState() {
    super.initState();
    _mcpScope = WebMcpScope(scopeName: runtimeType.toString());
    registerWebMcpTools();
  }
abstract interface class WebMcpToolSource {
  /// Returns the tools currently declared by this source.
  List<WebMcpTool> getWebMcpTools();
}
```

Executed `command -v flutter && flutter --version`; the version command was unavailable under the current sandbox:

```text
/Users/ortalcohen/flutter/bin/flutter
/Users/ortalcohen/flutter/bin/internal/update_engine_version.sh: line 64: /Users/ortalcohen/flutter/bin/cache/engine.stamp: Operation not permitted
```

Used read-only cached metadata instead; this establishes the installed checkout metadata, not runtime verification. Executed:

```python
from pathlib import Path
import json
p=Path('/Users/ortalcohen/flutter/bin/cache/flutter.version.json')
if p.exists():
 d=json.loads(p.read_text()); print('installed Flutter cache:', {k:d.get(k) for k in ['frameworkVersion','frameworkRevision','dartSdkVersion']})
for p in ['wiki/work/0008-automatic-page-agent/00-research.md','wiki/work/0008-automatic-page-agent/02-criteria.md']:
 t=Path(p).read_text(); print(p+': frontmatter='+str(t.startswith('---\n')))
```

Output:

```text
installed Flutter cache: {'frameworkVersion': '3.38.4', 'frameworkRevision': '66dd93f9a27ffe2a9bfc8297506ce066ff51265f', 'dartSdkVersion': '3.10.3'}
wiki/work/0008-automatic-page-agent/00-research.md: frontmatter=False
wiki/work/0008-automatic-page-agent/02-criteria.md: frontmatter=False
```

Independently opened official Flutter API documentation for SemanticsData, SemanticsNode, ensureSemantics, performAction and CustomPainter.semanticsBuilder; the Dart build_runner guide; the KickNext README; and the current WebMCP draft using `web.run(open=[...])`. Relevant exact returned excerpts:

```text
SemanticsData:
Summary information about a SemanticsNode object.
Annotations
@immutable

WebMCP dictionary excerpts:
object inputSchema;
AbortSignal signal;

KickNext compatibility excerpt:
The package is tested against the WebMCP Draft Community Group Report dated 26 August 2026.
```

The [WebMCP dictionary](https://webmachinelearning.github.io/webmcp/#modelcontexttool) distinguishes required tool fields from optional schema and registration options. The draft also confirms the September 9 date, additional consequential annotation, secure context, same-origin policy default, and separate browser-agent retrieval. [Flutter semantics documentation](https://api.flutter.dev/flutter/semantics/SemanticsData-class.html) supports the candidate runtime data surface; it does not establish the proposed wrapper's isolation. [KickNext README](https://github.com/KickNext/flutter_webmcp#compatibility) confirms manual tool construction and its older draft target.

Independently fetched and inspected the published archive with the following Python command body. The initial sandbox fetch failed with `urllib.error.URLError: <urlopen error [Errno 8] nodename nor servname provided, or not known>`; the same read-only command succeeded with network access:

```python
import urllib.request, tarfile, io
url='https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz'
data=urllib.request.urlopen(url,timeout=20).read()
t=tarfile.open(fileobj=io.BytesIO(data),mode='r:gz')
src={m.name:t.extractfile(m).read().decode() for m in t.getmembers() if m.isfile() and m.name.startswith('lib/') and m.name.endswith('.dart')}
print('archive:',url)
print('Dart library files:',len(src))
for term in ['registerTool','getTools','executeTool','toolchange','SemanticsNode','readOnlyHint','untrustedContentHint','consequentialHint']:
 print(term+': '+', '.join(p for p,s in src.items() if term in s))
```

Output:

```text
archive: https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz
Dart library files: 15
registerTool: lib/src/webmcp.dart, lib/src/platform/platform_web.dart
getTools: 
executeTool: 
toolchange: 
SemanticsNode: 
readOnlyHint: lib/src/platform/platform_web.dart
untrustedContentHint: lib/src/platform/platform_web.dart
consequentialHint: 
```

This search supports the named API absence and annotation comparison; it is not a competitor runtime test.

## Per-criterion results

Not an implementation review. AC-001 through AC-018 describe future implementation acceptance. Research adequacy was assessed against their relevant evidence needs: platform/version proof gates (AC-001–002), runtime scope and partial coverage (AC-003–009), publisher ownership and safe transport (AC-010–011), optional generation/lifecycle (AC-012–013), and eventual browser, diagnostics, cleanup, measurement, and documentation evidence (AC-014–018). No runtime criterion is marked passed and no runtime negative case was exercised. The research's explicit unresolved gates are consistent with planning-only scope.

## Findings

### F-001 — Required registration fields are overstated

- Severity: NIT
- Location: `wiki/work/0008-automatic-page-agent/00-research.md:61`
- Criterion affected: none; relevant to AC-002
- Observation: The phrase “registration requires” includes JSON Schema input and signal-based unregistration. The cited current draft declares inputSchema and the registration signal without the required modifier. These are available capabilities, while this package can independently require their use.
- Why it matters: The sentence conflates browser requirements with proposed bridge policy. It does not invalidate a bridge that always supplies a schema and uses cancellation-backed ownership, and the explicit compatibility spike remains in place.

### F-002 — Research artifact lacks wiki metadata

- Severity: NIT
- Location: `wiki/work/0008-automatic-page-agent/00-research.md:1`
- Criterion affected: none
- Observation: The artifact begins with its heading and has no wiki frontmatter, contrary to the repository's stated artifact rule. The same metadata omission is present at `02-criteria.md:1`.
- Why it matters: Metadata-based document routing and verification cannot read ownership/status/verification fields from these artifacts. This is a document convention issue, not a defect in the technical approach.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research |
| F-002 | document |

No blockers were identified. Finding disposition belongs to the main agent.
