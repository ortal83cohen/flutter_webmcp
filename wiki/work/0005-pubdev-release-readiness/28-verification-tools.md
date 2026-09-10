# Reproducible verification helpers

These disposable verification helpers were executed from `/private/tmp/webmcp-release-010-run`. They are preserved here for reproduction; they do not ship in the payload. Run commands and results are recorded in 31.

## run.py

```python
import os, subprocess, sys, pathlib, json
root=pathlib.Path('/private/tmp/webmcp-release-010-run')
label,cwd,*cmd=sys.argv[1:]
env=os.environ.copy()
env['PATH']='/Users/ortalcohen/fvm/versions/3.47.0/bin:'+env['PATH']
env['CI']='true'
p=subprocess.run(cmd,cwd=cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
(root/(label+'.log')).write_text(p.stdout)
(root/(label+'.json')).write_text(json.dumps({'cmd':cmd,'cwd':cwd,'exit':p.returncode}))
print(p.stdout[-6000:])
print('Exit:',p.returncode)
sys.exit(p.returncode)
```

## payload.py

```python
from pathlib import Path
import hashlib,json,shutil,re,sys
repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp')
run=Path('/private/tmp/webmcp-release-010-run')
def inv(root):
    rows=[]
    for p in sorted(root.rglob('*')):
        rel=p.relative_to(root)
        if any(x in {'.git','.dart_tool','build','__pycache__'} for x in rel.parts):continue
        if p.is_symlink():raise RuntimeError('Symlink rejected: '+str(rel))
        if p.is_file():rows.append({'path':str(rel),'size':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
    return rows
def paths(log):
    result=[]; stack=[];started=False
    for line in Path(log).read_text().splitlines():
        if line.startswith('Publishing webmcp_flutter 0.1.0 '):started=True;continue
        if not started:continue
        if line.startswith('Total compressed archive size:'):break
        m=re.match(r'^((?:│   |    )*)[├└]── (.+)$',line)
        if not m:continue
        depth=len(m[1])//4
        text=m[2];f=re.match(r'^(.*) \([^()]+\)$',text)
        stack=stack[:depth]
        if f:result.append('/'.join(stack+[f[1]]))
        else:stack.append(text)
    if not result or len(set(result))!=len(result):raise RuntimeError('Missing or ambiguous inventory')
    return sorted(result)
if sys.argv[1]=='copy':
    rows=inv(repo)
    (run/'source-inventory.json').write_text(json.dumps(rows,indent=2)+'\n')
    dst=run/'packaging-source';dst.mkdir()
    for row in rows:
        p=dst/row['path'];p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(repo/row['path'],p)
    assert inv(dst)==rows
    print('Complete source snapshot and Git-free copy:',len(rows),'files; identical paths, sizes and SHA-256')
elif sys.argv[1]=='payload':
    listing=paths(run/'source-dry.log')
    dst=run/'payload';dst.mkdir()
    rows=[]
    for name in listing:
        if not (name in ['LICENSE','README.md','CHANGELOG.md','pubspec.yaml','example/pubspec.yaml','example/analysis_options.yaml'] or name.startswith(('lib/','example/lib/','example/web/'))):raise RuntimeError('Unexpected payload path: '+name)
        p=run/'packaging-source'/name
        assert p.is_file() and not p.is_symlink()
        out=dst/name;out.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,out)
    rows=inv(dst)
    source={r['path']:r for r in json.loads((run/'source-inventory.json').read_text())}
    assert all(source[r['path']]==r for r in rows)
    (run/'payload-inventory.json').write_text(json.dumps(rows,indent=2)+'\n')
    print('Payload reproduced from actual dry-run listing:',len(rows),'files; all paths, sizes and SHA-256 match source')
    print('Inventory SHA-256:',hashlib.sha256((run/'payload-inventory.json').read_bytes()).hexdigest())
elif sys.argv[1]=='verify':
    rows=json.loads((run/'payload-inventory.json').read_text())
    # Ignore only generated resolution/build files, which pub excludes by default.
    actual=[r for r in inv(run/'payload') if not r['path'].endswith('pubspec.lock')]
    assert actual==rows,(actual,rows)
    assert paths(run/'payload-dry.log')==[r['path'] for r in rows]
    assert paths(run/'source-dry.log')==paths(run/'source-waived.log')==paths(run/'payload-dry.log')==paths(run/'payload-waived.log')
    for r in rows:
        p=repo/r['path'];assert p.stat().st_size==r['size'] and hashlib.sha256(p.read_bytes()).hexdigest()==r['sha256']
    print('PASS: source/payload paths, sizes and SHA-256 unchanged; all four dry-run inventories identical')
```

## consumer.py

```python
from pathlib import Path
import re,json,sys,shutil,urllib.parse
run=Path('/private/tmp/webmcp-release-010-run')
mode=sys.argv[1]
if mode in ('create','negative'):
    name='consumer' if mode=='create' else 'negative-consumer'
    payload=run/'payload'
    if mode=='negative':
        payload=run/'negative-payload'
        shutil.copytree(run/'payload',payload,ignore=shutil.ignore_patterns('.dart_tool','build','pubspec.lock'))
        (payload/'lib/webmcp_flutter.dart').unlink()
    dst=run/name;dst.mkdir();(dst/'lib').mkdir();(dst/'web').mkdir()
    sample=re.findall(r'```dart\s*\n(.*?)```',(run/'payload/README.md').read_text(),re.S)
    executable=[s for s in sample if re.search(r'void main\(',s)]
    assert len(executable)==1,'Need exactly one complete README Dart sample'
    (dst/'lib/main.dart').write_text(executable[0])
    (dst/'pubspec.yaml').write_text('name: release_consumer\npublish_to: none\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n  webmcp_flutter:\n    path: '+str(payload)+'\nflutter:\n  uses-material-design: true\n')
    (dst/'web/index.html').write_text('<!DOCTYPE html><html><head><base href="$FLUTTER_BASE_HREF"><meta charset="utf-8"><title>Release consumer</title></head><body><script src="flutter_bootstrap.js" async></script></body></html>\n')
    print('Created fresh',name,'with README sample and only payload dependency:',payload)
elif mode=='provenance':
    for name in ('consumer','payload/example'):
        cfg=run/name/'.dart_tool/package_config.json'
        obj=json.loads(cfg.read_text())
        pkg=next(x for x in obj['packages'] if x['name']=='webmcp_flutter')
        resolved=Path(urllib.parse.unquote(urllib.parse.urlparse(urllib.parse.urljoin(cfg.as_uri(),pkg['rootUri'])).path)).resolve()
        assert resolved==(run/'payload').resolve(),resolved
        assert '/Users/ortalcohen/Documents/GitHub/flutter_webmcp' not in cfg.read_text()
        print(name+': webmcp_flutter resolves ONLY to '+str(resolved))
        print('web build index:',(run/name/'build/web/index.html').is_file())
        assert (run/name/'build/web/index.html').is_file()
```

## check_diagnostics.py

```python
from pathlib import Path
import json,sys
root=Path('/private/tmp/webmcp-release-010-run')
warning='* It\'s strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml'
for label in sys.argv[1:]:
    out=(root/(label+'.log')).read_text();meta=json.loads((root/(label+'.json')).read_text())
    issues=[l for l in out.splitlines() if l.startswith('* ')]
    assert issues==[warning],issues
    assert 'Package has 1 warning.' in out and 'Package validation found the following potential issue:' in out
    assert meta['exit']==(0 if 'waived' in label else 65),meta
    assert 'error' not in out.lower(),out
    print(label+': exact optional-URL warning only, zero errors; expected exit '+str(meta['exit']))
```

## name_check.py

```python
import urllib.request,urllib.error,datetime
print('Checked UTC:',datetime.datetime.now(datetime.timezone.utc).isoformat())
for url in ('https://pub.dev/api/packages/webmcp_flutter','https://pub.dev/api/packages/webmcp_flutter/versions/0.1.0'):
    try:
        with urllib.request.urlopen(url) as response:print(url,'HTTP',response.status)
    except urllib.error.HTTPError as e:
        print(url,'HTTP',e.code)
```

