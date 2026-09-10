# Implementation review — round 01

- Work item: 0006-rename-webmcp-flutter
- Reviewed artifact: `/private/tmp/webmcp-rename-implementation.diff`, isolated against supplied pre-rename snapshot; repository HEAD `dccbad724308ce93f75fb95580282b18292ad0df`.
- Reviewer: independent rename_impl_review agent
- Date: 2026-09-10

## Verdict

**PASS**

All four criteria are met, with independently run full verification, baseline preservation checks, and a negative case for each criterion.

## Verification performed

The first sandboxed suite attempt stopped at SDK cache permissions before dependency resolution. The same suite completed with approved SDK cache access; this was an environment retry, without a source change. The build emitted a non-fatal font-family notice; web build completed. No live browser behavior or publication was tested.

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH bash tools/check.sh`

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
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
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Stage 2 passed: dependencies
Formatted 23 files (0 changed) in 0.03 seconds.
Stage 3 passed: format
Analyzing flutter_webmcp...
No issues found!
Stage 4 passed: analysis
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
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: unregister is idempotent
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:01 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:01 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:01 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:01 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:01 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction ignores exports, comments, strings, and conditional values
00:01 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for initial newlines in triple strings
00:01 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for encoded import URIs
00:01 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction preserves raw ordinary literal content
00:01 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:01 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction classifies only the fixed forbidden import families
00:01 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every fixed header and the bare AWS prefix
00:01 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every assignment spelling and separator
00:01 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures does not infer markers outside the exhaustive set
00:01 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:01 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:01 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:02 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:02 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:02 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:02 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:02 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:02 +39: All tests passed!
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             21.3s
✓ Built build/web
Stage 6 passed: build

Exit: 0
```

Command: `python3 tools/lint_wiki.py`

```text
lint_wiki: clean (0 warning(s)).

Exit: 0
```

Command: `python3 /private/tmp/webmcp-review-probes.py`

```text
COMMAND: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart analyze /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_barrel.dart
Analyzing old_barrel.dart...

  error - old_barrel.dart:1:8 - Target of URI doesn't exist: 'package:webmcp_flutter/webmcp_pilot.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist

1 issue found.
 
EXIT: 3
COMMAND: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart analyze /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart
Analyzing old_example.dart...

  error - old_example.dart:3:8 - Target of URI doesn't exist: 'package:webmcp_pilot_example/example_tools.dart'. Try creating the file referenced by the URI, or try using a URI for a file that does exist. - uri_does_not_exist
  error - old_example.dart:9:11 - Undefined class 'ExampleCounter'. Try changing the name to the name of an existing class, or creating a class with the name 'ExampleCounter'. - undefined_class
  error - old_example.dart:9:36 - The function 'ExampleCounter' isn't defined. Try importing the library that defines 'ExampleCounter', correcting the name to the name of an existing function, or defining a function named 'ExampleCounter'. - undefined_function
  error - old_example.dart:10:5 - The function 'registerExampleTools' isn't defined. Try importing the library that defines 'registerExampleTools', correcting the name to the name of an existing function, or defining a function named 'registerExampleTools'. - undefined_function

4 issues found.
 
EXIT: 3
Active absence scan: PASS
Injected old label rejected: PASS
Manifest invariant and changed-version rejection: PASS
Barrel exports preserved and old barrel absent: PASS
All baseline files preserved modulo identity replacements; historical work byte-identical: PASS
Git index preserved: PASS

Exit: 0
```

Command: `cd example && PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH flutter test --no-pub /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart`

```text
00:00 +0: loading /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart
Error: Couldn't resolve the package 'webmcp_pilot_example' in 'package:webmcp_pilot_example/example_tools.dart'.
/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:3:8: Error: Not found: 'package:webmcp_pilot_example/example_tools.dart'
import 'package:webmcp_pilot_example/example_tools.dart';
       ^
/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:9:11: Error: 'ExampleCounter' isn't a type.
    final ExampleCounter counter = ExampleCounter();
          ^^^^^^^^^^^^^^
/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:9:36: Error: Method not found: 'ExampleCounter'.
    final ExampleCounter counter = ExampleCounter();
                                   ^^^^^^^^^^^^^^
/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:10:5: Error: Method not found: 'registerExampleTools'.
    registerExampleTools(counter);
    ^^^^^^^^^^^^^^^^^^^^
00:00 +0 -1: loading /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart [E]
  Failed to load "/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart":
  Compilation failed for testPath=/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart: Error: Couldn't resolve the package 'webmcp_pilot_example' in 'package:webmcp_pilot_example/example_tools.dart'.
  /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:3:8: Error: Not found: 'package:webmcp_pilot_example/example_tools.dart'
  import 'package:webmcp_pilot_example/example_tools.dart';
         ^
  /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:9:11: Error: 'ExampleCounter' isn't a type.
      final ExampleCounter counter = ExampleCounter();
            ^^^^^^^^^^^^^^
  /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:9:36: Error: Method not found: 'ExampleCounter'.
      final ExampleCounter counter = ExampleCounter();
                                     ^^^^^^^^^^^^^^
  /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart:10:5: Error: Method not found: 'registerExampleTools'.
      registerExampleTools(counter);
      ^^^^^^^^^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart: loading /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/rename-review-jod5k95h/old_example.dart

Exit: 1
```

Probe implementation (disposable files only; source unchanged):

```python
from pathlib import Path
import json, subprocess, tempfile, urllib.parse
r=Path.cwd(); b=Path('/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/webmcp-rename-baseline-dwu_5ap6')
t=Path(tempfile.mkdtemp(prefix='rename-review-')); (t/'.dart_tool').mkdir()
c=json.loads((r/'example/.dart_tool/package_config.json').read_text())
for p in c['packages']: p['rootUri']=urllib.parse.urljoin((r/'example/.dart_tool/package_config.json').as_uri(),p['rootUri'])
(t/'.dart_tool/package_config.json').write_text(json.dumps(c))
for name,text in [('old_barrel',"import 'package:webmcp_flutter/webmcp_pilot.dart';\nvoid main() {}\n"),('old_example',(r/'example/test/example_tools_test.dart').read_text().replace('package:webmcp_flutter_example/','package:webmcp_pilot_example/'))]:
 p=t/(name+'.dart'); p.write_text(text)
 cmd=['/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart','analyze',str(p)]
 run=subprocess.run(cmd,text=True,capture_output=True); print('COMMAND:', ' '.join(cmd)); print(run.stdout,run.stderr); print('EXIT:',run.returncode)
 assert run.returncode!=0 and 'uri_does_not_exist' in run.stdout
active=[r/'README.md',r/'pubspec.yaml',r/'example/pubspec.yaml']
for d in ['lib','test','example/lib','example/test','example/web','wiki/product']: active += [p for p in (r/d).rglob('*') if p.is_file()]
def absent(paths): return not any('webmcp_pilot' in p.read_text() or 'WebMCP Pilot' in p.read_text() for p in paths)
assert absent(active); print('Active absence scan: PASS')
p=t/'injected.md'; p.write_text('WebMCP Pilot'); assert not absent(active+[p]); print('Injected old label rejected: PASS')
def invariant(text,old): return text==old.replace('webmcp_pilot','webmcp_flutter')
for f in ['pubspec.yaml','example/pubspec.yaml']: assert invariant((r/f).read_text(),(b/f).read_text())
assert not invariant((r/'pubspec.yaml').read_text().replace('version: 0.1.0','version: 0.2.0'),(b/'pubspec.yaml').read_text()); print('Manifest invariant and changed-version rejection: PASS')
assert (r/'lib/webmcp_flutter.dart').read_bytes()==(b/'lib/webmcp_pilot.dart').read_bytes(); assert not (r/'lib/webmcp_pilot.dart').exists(); print('Barrel exports preserved and old barrel absent: PASS')
for p in b.rglob('*'):
 if not p.is_file() or 'wiki/work/0006-' in str(p): continue
 rel=p.relative_to(b); dest=r/rel
 if rel.as_posix()=='lib/webmcp_pilot.dart': dest=r/'lib/webmcp_flutter.dart'
 expected=p.read_bytes().replace(b'webmcp_pilot',b'webmcp_flutter').replace(b'WebMCP Pilot',b'WebMCP Flutter') if not rel.as_posix().startswith('wiki/work/') else p.read_bytes()
 assert dest.read_bytes()==expected, str(rel)
print('All baseline files preserved modulo identity replacements; historical work byte-identical: PASS')
assert subprocess.check_output(['git','diff','--cached','--binary'])==Path('/private/tmp/webmcp-rename-index-before.patch').read_bytes(); print('Git index preserved: PASS')
```

Resolved metadata inspected using Python JSON loading and assertions that the new identities exist and old identities do not:

```text
.dart_tool/package_config.json: new identities resolved; old identities absent
example/.dart_tool/package_config.json: new identities resolved; old identities absent
```

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `pubspec.yaml:1`; `lib/webmcp_flutter.dart:1`; identical barrel bytes and 39 root tests passed | yes — old barrel URI rejected with analyzer exit 3 |
| AC-002 | pass | `example/pubspec.yaml:1`; `example/pubspec.yaml:12`; `example/test/example_tools_test.dart:3`; generated package configuration inspected; example test passed | yes — disposable example test with old package import fails compilation, exit 1 |
| AC-003 | pass | `README.md:1`; `lib/src/webmcp_scope.dart:32`; `lib/src/transport/transport_web.dart:37`; `example/lib/example_screen.dart:46`; `example/web/index.html:7`; `test/repo_hygiene_test.dart:262`; `wiki/product/webmcp-contract.md:13` | yes — injected old branding rejected by same active-file absence scan |
| AC-004 | pass | `pubspec.yaml:3`; `LICENSE:1`; byte comparison of baseline files modulo identity substitutions; historical work byte-identical and Git index unchanged; full suite and wiki lint output above | yes — version 0.2.0 injection rejected by manifest baseline invariant |

## Findings

None.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| None | None |
