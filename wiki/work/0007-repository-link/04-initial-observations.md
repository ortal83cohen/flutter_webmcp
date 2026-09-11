# Initial public metadata observations

Command: `python3 /private/tmp/webmcp-release-011-run/metadata_probe.py`

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

## Checkout baseline

No source files were changed by this task before this observation. Existing dirty wiki work is preserved.

Command: `git status --short`

```text
A  wiki/work/0005-pubdev-release-readiness/36-publication-outcome.md
M  wiki/work/0005-pubdev-release-readiness/STATE.yaml
A  wiki/work/0005-pubdev-release-readiness/validation/impl-review-03.md
A  wiki/work/0007-repository-link/STATE.yaml
Exit: 0
```

Initial Git index diff SHA-256: 1def7a4be5b4141344948c9fc900914273860ca984f5233253f77b2398977e17

## Probe source

```python
import urllib.request,json
for url in ['https://api.github.com/repos/ortal83cohen/flutter_webmcp','https://raw.githubusercontent.com/ortal83cohen/flutter_webmcp/main/pubspec.yaml','https://pub.dev/api/packages/webmcp_flutter','https://pub.dev/api/packages/webmcp_flutter/versions/0.1.1']:
 try:
  with urllib.request.urlopen(url) as r:raw=r.read();print(url,'HTTP',r.status)
  if 'raw.githubusercontent' in url:
   s=raw.decode();assert 'name: webmcp_flutter' in s;print('Public repository root manifest declares name: webmcp_flutter')
  else:
   d=json.loads(raw)
   if 'full_name' in d:print('Public repository:',d['full_name'],'private:',d['private'],'branch:',d['default_branch']);assert d['private'] is False
   if 'latest' in d:print('Latest version:',d['latest']['version'],'repository:',d['latest']['pubspec'].get('repository'))
 except urllib.error.HTTPError as e:print(url,'HTTP',e.code)
```
