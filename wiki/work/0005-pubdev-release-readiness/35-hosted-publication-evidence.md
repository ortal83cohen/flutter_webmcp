# Hosted publication evidence

## Result and scope

The ordinary interactive publisher uploaded webmcp_flutter 0.1.0 successfully after matching its actual22-file inventory against27 and confirming the existing user-authorized release. The account had been selected through official pub login. Personal account identity and credentials are omitted. The exact hosted archive now matches all22 approved paths, sizes and SHA-256 values. A fresh consumer resolves exact hosted0.1.0 using a new isolated dependency cache and builds the unchanged README sample for web.

The initial presentation check observed package/example/changelog HTTP200 with expected content, while the web badge was pending analysis and versioned API documentation returned404. These server processing gates are not yet claimed complete in this initial evidence; subsequent independent hosted review records their final state.

## Interactive upload output

Working directory: `/private/tmp/webmcp-release-010-run/payload`

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish`

Terminal control backspaces are rendered into their final displayed text below.

```text
Resolving dependencies... 
Downloading packages... 
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
├── CHANGELOG.md (<1 KB)
├── LICENSE (1 KB)
├── README.md (3 KB)
├── example
│   ├── analysis_options.yaml (<1 KB)
│   ├── lib
│   │   ├── example_screen.dart (2 KB)
│   │   ├── example_tools.dart (<1 KB)
│   │   └── main.dart (<1 KB)
│   ├── pubspec.yaml (<1 KB)
│   └── web
│       └── index.html (<1 KB)
├── lib
│   ├── src
│   │   ├── transport
│   │   │   ├── transport_noop.dart (<1 KB)
│   │   │   ├── transport_selector.dart (<1 KB)
│   │   │   ├── transport_web.dart (1 KB)
│   │   │   └── webmcp_transport.dart (<1 KB)
│   │   ├── webmcp.dart (2 KB)
│   │   ├── webmcp_exceptions.dart (1 KB)
│   │   ├── webmcp_scope.dart (2 KB)
│   │   ├── webmcp_tool.dart (<1 KB)
│   │   ├── webmcp_tool_source.dart (<1 KB)
│   │   └── widgets
│   │       ├── webmcp_action.dart (2 KB)
│   │       └── webmcp_screen.dart (1 KB)
│   └── webmcp_flutter.dart (<1 KB)
└── pubspec.yaml (<1 KB)

Total compressed archive size: 7 KB.
Validating package... 
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml

Publishing is forever; packages cannot be unpublished.
Policy details are available at https://pub.dev/policy


Package has 1 warning.. Do you want to publish webmcp_flutter 0.1.0 to https://pub.dev (y/N)? y
Uploading... 
Message from server: Successfully uploaded https://pub.dev/packages/webmcp_flutter version 0.1.0, it may take up-to 10 minutes before the new version is available.


Exit: 0
```

## Postpublication commands and full outputs

### upload-final-name

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/name_check.py"]`

```text
Checked UTC: 2026-09-10T13:55:43.489984+00:00
https://pub.dev/api/packages/webmcp_flutter HTTP 404
https://pub.dev/api/packages/webmcp_flutter/versions/0.1.0 HTTP 404

Exit: 0
```

### hosted-archive

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/hosted_verify.py", "archive"]`

```text
Hosted exact version API: https://pub.dev/api/packages/webmcp_flutter/versions/0.1.0 HTTP 200; version 0.1.0
Hosted archive SHA-256 matches registry: f4996fb8012bd50c075e9d21dc74206cbad24d6a5c1517d0647d6bdda707af83
Hosted archive exactly matches all 22 approved paths, sizes and SHA-256 values.

Exit: 0
```

### hosted-consumer-create

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/hosted_verify.py", "create"]`

```text
Created fresh hosted-only consumer with exact version 0.1.0 and README sample.

Exit: 0
```

### hosted-build

Working directory: `/private/tmp/webmcp-release-010-run/hosted-consumer`

Command arguments: `["env", "PUB_CACHE=/private/tmp/webmcp-release-010-run/hosted-cache", "flutter", "build", "web"]`

```text
Resolving dependencies...
Downloading packages...
+ characters 1.4.1
+ collection 1.19.1
+ flutter 0.0.0 from sdk flutter
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ sky_engine 0.0.0 from sdk flutter
+ vector_math 2.4.2
+ web 1.1.1
+ webmcp_flutter 0.1.0
Changed 9 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             19.6s
✓ Built build/web

Exit: 0
```

### hosted-provenance

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/hosted_verify.py", "provenance"]`

```text
Hosted consumer package provenance: /private/tmp/webmcp-release-010-run/hosted-cache/hosted/pub.dev/webmcp_flutter-0.1.0
Exact hosted 0.1.0 resolved from fresh isolated pub cache; web build index exists.

Exit: 0
```

### hosted-presentation-01

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/presentation.py"]`

```text
Web platform badge links: []
package https://pub.dev/packages/webmcp_flutter/versions/0.1.0 HTTP 200 missing expected content: ['web platform link']
example https://pub.dev/packages/webmcp_flutter/versions/0.1.0/example HTTP 200 missing expected content: []
changelog https://pub.dev/packages/webmcp_flutter/versions/0.1.0/changelog HTTP 200 missing expected content: []
documentation https://pub.dev/documentation/webmcp_flutter/0.1.0/ HTTP 404

Exit: 1
```

## Reproduction helpers

### hosted_verify.py

```python
from pathlib import Path
import urllib.request,urllib.parse,json,hashlib,tarfile,io,sys
run=Path('/private/tmp/webmcp-release-010-run')
mode=sys.argv[1]
if mode=='archive':
    url='https://pub.dev/api/packages/webmcp_flutter/versions/0.1.0'
    with urllib.request.urlopen(url) as response:data=json.load(response)
    assert data['version']=='0.1.0' and data['pubspec']['name']=='webmcp_flutter'
    print('Hosted exact version API:',url,'HTTP 200; version 0.1.0')
    archive=urllib.request.urlopen(data['archive_url']).read()
    sha=hashlib.sha256(archive).hexdigest()
    assert sha==data['archive_sha256']
    expected=json.loads((run/'payload-inventory.json').read_text())
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
    (dst/'pubspec.yaml').write_text('name: hosted_release_consumer\npublish_to: none\nenvironment:\n  sdk: ^3.13.0\ndependencies:\n  flutter:\n    sdk: flutter\n  webmcp_flutter: 0.1.0\nflutter:\n  uses-material-design: true\n')
    print('Created fresh hosted-only consumer with exact version 0.1.0 and README sample.')
elif mode=='provenance':
    cfg=run/'hosted-consumer/.dart_tool/package_config.json'
    obj=json.loads(cfg.read_text());pkg=next(p for p in obj['packages'] if p['name']=='webmcp_flutter')
    resolved=Path(urllib.parse.unquote(urllib.parse.urlparse(urllib.parse.urljoin(cfg.as_uri(),pkg['rootUri'])).path)).resolve()
    expected=(run/'hosted-cache/hosted/pub.dev/webmcp_flutter-0.1.0').resolve()
    assert resolved==expected,(resolved,expected)
    assert (run/'hosted-consumer/build/web/index.html').is_file()
    print('Hosted consumer package provenance:',resolved)
    print('Exact hosted 0.1.0 resolved from fresh isolated pub cache; web build index exists.')
```

### presentation.py

```python
from pathlib import Path
from html.parser import HTMLParser
import urllib.request,urllib.error,re,json
class Text(HTMLParser):
    def __init__(self):super().__init__();self.parts=[];self.links=[]
    def handle_data(self,d):self.parts.append(d)
    def handle_starttag(self,tag,attrs):
        if tag=='a':
            for k,v in attrs:
                if k=='href':self.links.append(v)
root=Path('/private/tmp/webmcp-release-010-run');results=[]
cases=[('package','https://pub.dev/packages/webmcp_flutter/versions/0.1.0',['webmcp_flutter','0.1.0','Minimal Flutter example','Current contract']),('example','https://pub.dev/packages/webmcp_flutter/versions/0.1.0/example',['WebMcpPilotExample','void main']),('changelog','https://pub.dev/packages/webmcp_flutter/versions/0.1.0/changelog',['0.1.0 - 2026-09-10','local WebMCP tool registry']),('documentation','https://pub.dev/documentation/webmcp_flutter/0.1.0/',['webmcp_flutter','0.1.0'])]
failed=False
for label,url,required in cases:
    try:
        with urllib.request.urlopen(url) as response:raw=response.read().decode();status=response.status
        parser=Text();parser.feed(raw);text=re.sub(r'\s+',' ',' '.join(parser.parts))
        missing=[s for s in required if s not in text]
        if label=='package':
            web_links=[x for x in parser.links if 'platform:web' in x or 'platform%3Aweb' in x]
            if not web_links:missing.append('web platform link')
            print('Web platform badge links:',web_links)
        if label=='documentation':
            api=[x for x in parser.links if 'webmcp_flutter' in x and ('library' in x or 'WebMcp' in x)]
            if not api:missing.append('API library link')
            print('API documentation links:',api[:5])
        print(label,url,'HTTP',status,'missing expected content:',missing)
        (root/(label+'-hosted.html')).write_text(raw)
        results.append({'label':label,'url':url,'status':status,'missing':missing})
        failed=failed or bool(missing)
    except urllib.error.HTTPError as e:
        print(label,url,'HTTP',e.code);results.append({'label':label,'url':url,'status':e.code});failed=True
(root/'presentation-results.json').write_text(json.dumps(results,indent=2)+'\n')
raise SystemExit(1 if failed else 0)
```

