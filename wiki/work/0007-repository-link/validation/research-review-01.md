# Research review — round 01

- Work item: 0007-repository-link
- Reviewed artifact: wiki/work/0007-repository-link/00-research.md
- Reviewer: independent research validator
- Date: 2026-09-10

## Verdict

**PASS**

The designated repository field and immutable-version constraint support the narrow 0.1.1 approach. The alternatives are relevant, historical claims have retained evidence, and the artifact explicitly leaves publication and rendered-link verification as execution gates. This verdict covers research, not fulfillment of the release acceptance criteria.

## Verification performed

Read the supplied research, criteria, initial observations, rubric and templates. Independently opened https://dart.dev/tools/pub/pubspec using the web tool: the Version section requires a new version for subsequent changes; Homepage and Repository distinguish their intended URLs and describe their displayed links. These official statements support the selected mechanism and rejection of modifying 0.1.0 in place.

Command: `python3 /private/tmp/webmcp-release-011-run/metadata_probe.py`

The initial sandbox attempt exited 1 with `urllib.error.URLError: <urlopen error [Errno 8] nodename nor servname provided, or not known>`. The same read-only command with network permission returned:

```text
https://api.github.com/repos/ortal83cohen/flutter_webmcp HTTP 200
Public repository: ortal83cohen/flutter_webmcp private: False branch: main
https://raw.githubusercontent.com/ortal83cohen/flutter_webmcp/main/pubspec.yaml HTTP 200
Public repository root manifest declares name: webmcp_flutter
https://pub.dev/api/packages/webmcp_flutter HTTP 200
Latest version: 0.1.0 repository: None
https://pub.dev/api/packages/webmcp_flutter/versions/0.1.1 HTTP 404
Exit: 0
```

The probe source is retained in 04-initial-observations.md. These observations are time-specific and do not establish later availability.

Command:

```sh
python3 - <<'PY'
from pathlib import Path
import json
p=Path('pubspec.yaml').read_text()
assert 'name: webmcp_flutter\n' in p and 'version: 0.1.0\n' in p
assert not any(x.startswith('repository:') for x in p.splitlines())
print('Local baseline: webmcp_flutter 0.1.0; repository field absent')
a=json.loads(Path('wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json').read_text())
assert len(a)==22
print('Approved inventory entries: 22')
s=Path('wiki/work/0005-pubdev-release-readiness/34-final-publication-controls.md').read_text()
assert '`--ignore-warnings` can only be used with `--dry-run`.' in s
assert 'All 22 included path/size/SHA-256 entries unchanged in payload and source.' in s
print('Prior controls retain flag rejection and final inventory output')
s=Path('wiki/work/0005-pubdev-release-readiness/35-hosted-publication-evidence.md').read_text()
assert 'Hosted archive exactly matches all 22 approved paths, sizes and SHA-256 values.' in s
print('Prior hosted evidence retains exact 22-file archive output')
s=Path('wiki/work/0005-pubdev-release-readiness/STATE.yaml').read_text()
assert 'published_archive_and_hosted_build_verified_presentation_pending' in s
print('Prior STATE retains pending presentation boundary')
PY
```

```text
Local baseline: webmcp_flutter 0.1.0; repository field absent
Approved inventory entries: 22
Prior controls retain flag rejection and final inventory output
Prior hosted evidence retains exact 22-file archive output
Prior STATE retains pending presentation boundary
Exit: 0
```

This confirms the cited historical record, not a new archive audit or suite run. No full suite was repeated.

## Findings

None.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

No blocker to route.
