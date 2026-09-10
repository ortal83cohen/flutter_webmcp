# Verification helper sources

These helpers are disposable verification infrastructure and are excluded from publication. Exact executions and outputs are in07 and subsequent publication evidence.

## run.py

```python
import os, subprocess, sys, pathlib, json
root=pathlib.Path('/private/tmp/webmcp-release-011-run')
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

## metadata_probe.py

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

## source_checks.py

```python
from pathlib import Path
import json,subprocess,hashlib,copy
repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp');base=json.loads((repo/'wiki/work/0007-repository-link/05-baseline.json').read_text())
def parse(s):
 p=subprocess.run(['ruby','-ryaml','-rjson','-e','puts JSON.generate(YAML.safe_load(STDIN.read))'],input=s,text=True,capture_output=True,check=True)
 return json.loads(p.stdout)
expected=parse(base['pubspec']);expected.update(version='0.1.1',repository='https://github.com/ortal83cohen/flutter_webmcp')
def metadata(d):assert d==expected,'Manifest differs beyond exact authorized metadata'
actual=parse((repo/'pubspec.yaml').read_text());metadata(actual)
old=base['changelog'];expected_changelog=old.replace('# Changelog\n\n','# Changelog\n\n## 0.1.1 - 2026-09-10\n\n- Add the public GitHub repository link to package metadata.\n\n',1)
assert (repo/'CHANGELOG.md').read_text()==expected_changelog
print('PASS: parsed manifest changes only version and exact repository; changelog adds only the metadata release.')
for label,change in [('missing repository',lambda d:d.pop('repository')),('wrong repository',lambda d:d.update(repository='https://example.invalid/repository')),('wrong version',lambda d:d.update(version='0.1.0')),('changed dependency',lambda d:d['dependencies'].update(web='^2.0.0'))]:
 d=copy.deepcopy(actual);change(d)
 try:metadata(d)
 except AssertionError:print('Expected rejection:',label)
 else:raise AssertionError('Negative was not rejected: '+label)
for name,sha in base['source_hashes'].items():
 if name in ('pubspec.yaml','CHANGELOG.md'):continue
 assert hashlib.sha256((repo/name).read_bytes()).hexdigest()==sha,name
assert hashlib.sha256((repo/'wiki/work/0005-pubdev-release-readiness/STATE.yaml').read_bytes()).hexdigest()==base['prior_state_sha256']
index=hashlib.sha256(subprocess.check_output(['git','ls-files','--stage','-z'],cwd=repo)).hexdigest()
print('PASS: all unrelated source/config bytes and prior0005 STATE unchanged.')
print('Index entries equal baseline:',index==base['index_entries_sha256'])
print('Current index entries SHA-256:',index)
```

## candidate.py

```python
from pathlib import Path
import json,hashlib,shutil,sys,re
repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp');run=Path('/private/tmp/webmcp-release-011-run');payload=run/'payload'
prior=json.loads((repo/'wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json').read_text())
url='https://github.com/ortal83cohen/flutter_webmcp'
def row(p,name):return {'path':name,'size':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
if sys.argv[1]=='create':
    payload.mkdir();rows=[]
    for old in prior:
        name=old['path'];src=repo/name
        assert not src.is_symlink() and src.is_file()
        current=row(src,name)
        if name not in ('pubspec.yaml','CHANGELOG.md'):assert current==old,('Unexpected source delta',name)
        dst=payload/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst);rows.append(current)
    shutil.copyfile(repo/'.pubignore',payload/'.pubignore')
    manifest=(payload/'pubspec.yaml').read_text();assert 'version: 0.1.1\n' in manifest and 'repository: '+url+'\n' in manifest
    assert '## 0.1.1' in (payload/'CHANGELOG.md').read_text()
    (run/'inventory.json').write_text(json.dumps(rows,indent=2)+'\n')
    print('Candidate22 files:20 unchanged from published0.1.0; only pubspec.yaml and CHANGELOG.md differ.')
    print('Excluded .pubignore copied unchanged from reviewed source.')
    print('Inventory SHA-256:',hashlib.sha256((run/'inventory.json').read_bytes()).hexdigest())
elif sys.argv[1]=='check':
    expected=json.loads((run/'inventory.json').read_text())
    for label in sys.argv[2:]:
        files=[];stack=[];started=False;out=(run/(label+'.log')).read_text()
        for line in out.splitlines():
            if line.startswith('Publishing webmcp_flutter 0.1.1 '):started=True;continue
            if not started:continue
            if line.startswith('Total compressed archive size:'):break
            m=re.match(r'^((?:│   |    )*)[├└]── (.+)$',line)
            if not m:continue
            stack=stack[:len(m[1])//4];f=re.match(r'^(.*) \([^()]+\)$',m[2])
            if f:files.append('/'.join(stack+[f[1]]))
            else:stack.append(m[2])
        assert len(files)==len(set(files)) and sorted(files)==[r['path'] for r in expected]
        assert 'Package has 0 warnings.' in out, 'Require zero actual publication warnings'
        print(label+': actual CLI inventory matches22 reviewed files; zero warnings.')
    for r in expected:
        assert row(payload/r['path'],r['path'])==r and row(repo/r['path'],r['path'])==r
    assert (payload/'.pubignore').read_bytes()==(repo/'.pubignore').read_bytes()
    print('All approved source and payload paths, sizes and SHA-256 unchanged.')
```

## consumer.py

```python
from pathlib import Path
import re,json,sys,shutil,urllib.parse
run=Path('/private/tmp/webmcp-release-011-run')
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

## gates.py

```python
from pathlib import Path
import json,copy,hashlib,sys,urllib.request,urllib.parse
ROOT=Path('/private/tmp/webmcp-release-011-run');URL='https://github.com/ortal83cohen/flutter_webmcp'
def inventory(actual,expected):assert actual==expected,'Inventory mismatch'
def run_result(code,artifact,actual_root,expected_root):assert code==0 and artifact and actual_root==expected_root,'Failed build/status/provenance'
def api(d):assert d['version']=='0.1.1' and d['pubspec']['repository']==URL,'Wrong hosted identity/metadata'
def archive(content,sha):assert hashlib.sha256(content).hexdigest()==sha,'Archive checksum mismatch'
def anchor(links):assert URL in links or URL+'/' in links,'Exact public repository anchor absent'
def preserve(actual,expected):assert actual==expected,'Unauthorized state/source/index change'
def closure(statuses):assert all(s=='PASS' for s in statuses),'Pending criterion prevents closure'
def reject(label,fn):
 try:fn()
 except (AssertionError,KeyError):print('Expected rejection:',label)
 else:raise AssertionError('Negative case unexpectedly accepted: '+label)
if __name__=='__main__':
 rows=json.loads((ROOT/'inventory.json').read_text());inventory(rows,rows)
 extra=copy.deepcopy(rows)+[{'path':'example/build/unexpected','size':1,'sha256':'invalid'}]
 reject('extra generated file',lambda:inventory(extra,rows));reject('missing approved file',lambda:inventory(rows[:-1],rows))
 changed=copy.deepcopy(rows);changed[0]['sha256']='changed';reject('altered included content',lambda:inventory(changed,rows))
 def diagnostic(s):assert 'Package has 0 warnings.' in s and 'Package has 1 warning.' not in s
 diagnostic((ROOT/'final-dry.log').read_text());reject('unexpected package warning',lambda:diagnostic('Package has 1 warning.'))
 build=json.loads((ROOT/'consumer-build.json').read_text());cfg=ROOT/'consumer/.dart_tool/package_config.json'
 pkg=next(p for p in json.loads(cfg.read_text())['packages'] if p['name']=='webmcp_flutter')
 resolved=Path(urllib.parse.unquote(urllib.parse.urlparse(urllib.parse.urljoin(cfg.as_uri(),pkg['rootUri'])).path)).resolve()
 expected=(ROOT/'payload').resolve();run_result(build['exit'],(ROOT/'consumer/build/web/index.html').is_file(),resolved,expected)
 reject('nonzero status',lambda:run_result(1,True,expected,expected));reject('missing artifact',lambda:run_result(0,False,expected,expected));reject('wrong provenance/version',lambda:run_result(0,True,'local-or-wrong-version',expected))
 reject('wrong hosted version',lambda:api({'version':'0.1.0','pubspec':{'repository':URL}}));reject('missing hosted repository',lambda:api({'version':'0.1.1','pubspec':{}}))
 reject('altered archive bytes',lambda:archive(b'changed',hashlib.sha256(b'approved').hexdigest()));reject('absent repo anchor',lambda:anchor([]));reject('wrong repo anchor',lambda:anchor(['https://example.invalid/repository']))
 for label in ['source','index','prior STATE']:reject('unauthorized '+label+' change',lambda:preserve('changed','baseline'))
 reject('pending criterion closure',lambda:closure(['PASS','PENDING']))
 print('PASS: actual local selection/build gates and all synthetic negative boundary checks.')
```

## hosted_verify.py

```python
from pathlib import Path
import urllib.request,urllib.parse,json,hashlib,tarfile,io,sys
from gates import api
run=Path('/private/tmp/webmcp-release-011-run')
mode=sys.argv[1]
if mode=='archive':
    url='https://pub.dev/api/packages/webmcp_flutter/versions/0.1.1'
    with urllib.request.urlopen(url) as response:data=json.load(response)
    api(data)
    assert data['version']=='0.1.1' and data['pubspec']['name']=='webmcp_flutter'
    print('Hosted exact version API:',url,'HTTP 200; version 0.1.1')
    archive=urllib.request.urlopen(data['archive_url']).read()
    sha=hashlib.sha256(archive).hexdigest()
    assert sha==data['archive_sha256']
    expected=json.loads((run/'inventory.json').read_text())
    actual=[]
    with tarfile.open(fileobj=io.BytesIO(archive),mode='r:gz') as tf:
        for member in tf.getmembers():
            if member.isdir():continue
            assert member.isfile(),'Unsupported hosted archive entry'
            name=member.name.removeprefix('./')
            assert not name.startswith('/') and '..' not in Path(name).parts
            content=tf.extractfile(member).read()
            actual.append({'path':name,'size':len(content),'sha256':hashlib.sha256(content).hexdigest()})
    assert sorted(actual,key=lambda r:r['path'])==expected
    print('Hosted archive SHA-256 matches registry:',sha)
    print('Hosted archive exactly matches all 22 approved paths, sizes and SHA-256 values.')
    (run/'hosted-version.json').write_text(json.dumps(data,indent=2)+'\n')
elif mode=='create':
    dst=run/'hosted-consumer';dst.mkdir();(dst/'lib').mkdir();(dst/'web').mkdir()
    (dst/'lib/main.dart').write_bytes((run/'consumer/lib/main.dart').read_bytes())
    (dst/'web/index.html').write_bytes((run/'consumer/web/index.html').read_bytes())
    (dst/'pubspec.yaml').write_text('name: hosted_release_consumer\npublish_to: none\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n  webmcp_flutter: 0.1.1\nflutter:\n  uses-material-design: true\n')
    print('Created fresh hosted-only consumer with exact version 0.1.1 and README sample.')
elif mode=='provenance':
    cfg=run/'hosted-consumer/.dart_tool/package_config.json'
    obj=json.loads(cfg.read_text());pkg=next(p for p in obj['packages'] if p['name']=='webmcp_flutter')
    resolved=Path(urllib.parse.unquote(urllib.parse.urlparse(urllib.parse.urljoin(cfg.as_uri(),pkg['rootUri'])).path)).resolve()
    expected=(run/'hosted-cache/hosted/pub.dev/webmcp_flutter-0.1.1').resolve()
    assert resolved==expected,(resolved,expected)
    assert (run/'hosted-consumer/build/web/index.html').is_file()
    print('Hosted consumer package provenance:',resolved)
    print('Exact hosted 0.1.1 resolved from fresh isolated pub cache; web build index exists.')
```

## link_check.py

```python
import urllib.request,json
from html.parser import HTMLParser
from gates import anchor,api
class Links(HTMLParser):
 def __init__(self):super().__init__();self.urls=[]
 def handle_starttag(self,t,a):
  if t=='a':self.urls.extend(v for k,v in a if k=='href')
url='https://pub.dev/api/packages/webmcp_flutter/versions/0.1.1'
with urllib.request.urlopen(url) as r:d=json.load(r);print(url,'HTTP',r.status)
api(d);print('Hosted exact version repository:',d['pubspec']['repository'])
for url in ['https://pub.dev/packages/webmcp_flutter/versions/0.1.1','https://pub.dev/packages/webmcp_flutter']:
 with urllib.request.urlopen(url) as r:raw=r.read().decode();print(url,'HTTP',r.status)
 p=Links();p.feed(raw);anchor(p.urls)
 print('Repository anchors:',[u for u in p.urls if u.rstrip('/')=='https://github.com/ortal83cohen/flutter_webmcp'])
print('PASS: requested public repository link appears on exact version and default package pages.')
```

