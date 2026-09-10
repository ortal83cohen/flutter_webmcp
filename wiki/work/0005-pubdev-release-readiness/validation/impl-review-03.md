# Implementation review — round 03

- Work item: 0005-pubdev-release-readiness
- Reviewed artifact: frozen `19-criteria-consolidated.md`; normative `21-release-decisions.md` and `23-warning-policy-evidence.md` as corrected by `34-final-publication-controls.md`; published webmcp_flutter 0.1.0 and `35-hosted-publication-evidence.md`.
- Reviewer: independent hosted_release_review agent
- Date: 2026-09-10
- Approved inventory SHA-256: `d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e`.
- Independently downloaded hosted archive SHA-256: `f4996fb8012bd50c075e9d21dc74206cbad24d6a5c1517d0647d6bdda707af83`.

## Verdict

**FAIL — hosted presentation remains incomplete.**

The release is published and its exact archive, installation and independent hosted web build pass. AC-010 remains unmet only for the absent web platform badge and unavailable versioned API documentation: the final observation at 14:06:35 UTC still reports pending analysis and documentation HTTP 404, over ten minutes after publication. This is an observed external processing limitation; no source regression or permanent analysis failure is demonstrated. The cumulative release gate is therefore not complete.

## Verification performed

This is a cumulative release assessment. Earlier independent command outputs in `validation/impl-review-01.md` and the exact publisher inventory work in `validation/impl-review-02.md` remain evidence for unchanged prepublication behavior. They are not represented as commands rerun in this round. Independent comparison confirms 35 runtime, test, tool, manifest and consumer-documentation files still match source inventory 26, and every hosted file matches the approved 22-file payload inventory 27. This round freshly checks hosted identity, recorded launch chronology, package presentation and two hosted-cache provenance paths, and independently builds an additional fresh hosted consumer. The canonical source suite and Chrome tests are preserved from round 01, not rerun on unchanged code.

Review inputs were criteria, normative artifacts, independent prior verdicts and raw execution evidence. The reviewer did not upload, retract, edit source or payload, touch Git state, read credentials, or reconstruct private account identity. Authentication and authority remain evidenced by the recorded private launch context in 34:24. This review neither invents a new approval nor broadens the recorded user execution request and completed login. The first read-only HTTP attempt in the sandbox failed with `urllib.error.URLError: <urlopen error [Errno 8] nodename nor servname provided, or not known>` (exit 1); the identical public-network check succeeded after scoped network access. The web browsing frontend separately reported that the fresh public URLs were unavailable through its safe-open path. Those access failures are not package test results.

### Exact SDK

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart --version`.

```text
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"
```

Command: `cat /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/flutter.version.json`.

```text
{
  "frameworkVersion": "3.47.0",
  "channel": "[user-branch]",
  "repositoryUrl": "https://github.com/flutter/flutter.git",
  "frameworkRevision": "4cf24164269a5ebf0c16a028a00727d0e77bbb05",
  "frameworkCommitDate": "2026-08-11 11:53:49 -0700",
  "engineRevision": "5f77625673248ee5846fbcaf5d3e1a3878386fd7",
  "engineCommitDate": "2026-08-11 16:38:36.000Z",
  "engineContentHash": "59d54a2b2896a6bbf356c94b7fac7b9e235bdacd",
  "engineBuildDate": "2026-08-11 19:18:15.653",
  "dartSdkVersion": "3.13.0",
  "devToolsVersion": "2.60.0",
  "flutterVersion": "3.47.0"
}
```

The combined SDK read command exited 0. This is the same Flutter 3.47.0/Dart 3.13.0 target used by the fresh build. No wider matrix is claimed.

### Hosted archive and existing hosted consumer

Command: `python3 /private/tmp/webmcp-hosted-review-03/verify.py`.

```text
UTC 2026-09-10T13:59:30.265362+00:00
Inventory SHA256 d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e
Version 0.1.0 published 2026-09-10T13:55:52.089288Z
PASS API archive SHA256 f4996fb8012bd50c075e9d21dc74206cbad24d6a5c1517d0647d6bdda707af83
PASS all 22 hosted path, size and hash entries equal approved inventory and current source
Consumer package entry {"name": "webmcp_flutter", "rootUri": "file:///private/tmp/webmcp-release-010-run/hosted-cache/hosted/pub.dev/webmcp_flutter-0.1.0", "packageUri": "lib/", "languageVersion": "3.13"}
PASS hosted consumer cache all 22 bytes match live archive; no repository fallback

    dependency: "direct main"
    description:
      name: webmcp_flutter
      sha256: f4996fb8012bd50c075e9d21dc74206cbad24d6a5c1517d0647d6bdda707af83
      url: "https://pub.dev"
    source: hosted
    version: "0.1.0"
sdks:
  dart: ">=3.13.0 <4.0.0"
  flutter: ">=3.47.0"

package 200 bytes 21343
example 200 bytes 17112
changelog 200 bytes 17190
docs 404
EXPECTED REJECTION altered hosted bytes fail approved identity
EXPECTED REJECTION repository fallback fails hosted provenance
EXPECTED REJECTION nonexistent hosted version HTTP 404
Exit: 0
```

### Recorded launch inventory and chronology

Command: `python3 /private/tmp/webmcp-hosted-review-03/launch.py`.

```text
PASS recorded ordinary interactive publisher lists exactly 22 approved paths, only allowlisted warning, confirmation y and server upload success
PASS recorded immediate preupload version 404 at 13:55:43 UTC precedes independently verified registry publication timestamp 13:55:52 UTC
EXPECTED STOP current hosted version exists; no second upload attempted
Authorization/account/authority evidence is recorded private launch context at artifact 34:24; reviewer did not access credentials or independently reconstruct user intent
Exit: 0
```

### Fresh independent hosted web build

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH PUB_CACHE=/private/tmp/webmcp-hosted-review-03/cache CI=true flutter build web`.

Working directory: `/private/tmp/webmcp-hosted-review-03/consumer`, created fresh with only the manifest, exact README sample and web index; cache directory did not pre-exist.

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
Compiling lib/main.dart for the Web...                             20.1s
✓ Built build/web
Exit: 0
```

### Source continuity and independent cache provenance

Command: `python3 /private/tmp/webmcp-hosted-review-03/continuity.py`.

```text
PASS 35 source/runtime/test/tool/manifest/documentation files match prepublication source inventory
PASS independent fresh consumer exact README sample builds; hosted 0.1.0 resolves from second isolated cache with all 22 approved hashes
Root URI: file:///private/tmp/webmcp-hosted-review-03/cache/hosted/pub.dev/webmcp_flutter-0.1.0
Git index SHA256 12452fe74ef4443bb65c9c81eec6813e15540c1515dd4817e12bab65bf44aa56
Exit: 0
```

The build retains the SDK font diagnostic, dependency update notice and Wasm suggestion verbatim. They did not prevent the web build; no Wasm runtime test is claimed. A later continuity invocation again matched all 35 source files and all 22 cache hashes. Its index observation was `60ea3ffa33ca3cab8fded89969d1c26c346ec4b1310a35d29f01bbd5889b7f41`, different from the earlier printed value. The reviewer executed no Git mutation; the actor responsible for this concurrent external index change is not established by this review. Global index stability across other actors is not claimed.

### Public presentation, final bounded observation

Command: `python3 /private/tmp/webmcp-hosted-review-03/presentation.py`.

The checker fetched the exact-version package, Example, Changelog and API documentation URLs over HTTPS, parsed visible text and links, required the expected example/changelog content, a web-platform link and a public-library documentation link. Earlier observations at 13:59:30, 14:01:01, 14:01:52, 14:03:35 and 14:05:11 UTC had the same pending badge/documentation results. The final observation is:

```text
UTC 2026-09-10T14:06:35.137620+00:00
Web badge links [] pending analysis True
package HTTP 200 missing ['web badge']
example HTTP 200 missing []
changelog HTTP 200 missing []
docs HTTP 404
Exit: 1
```

The package page renders the expected README including the explicit no-browser-publication limitation, Example renders `WebMcpPilotExample` and `ExampleScreen`, and Changelog renders the dated 0.1.0 release and detection-only wording. The hosted documentation failure was not replaced by local documentation proof. No poll follows this final verdict.
## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | PASS — earlier independently validated pre-freeze comparison retained | `validation/impl-review-01.md:899`; `21-release-decisions.md:28` | Prior stripped-source-hash rejection and disposition inspection preserved; no new comparison test claimed. |
| AC-002 | PASS — recorded launch prerequisites and immutable version identity | `34-final-publication-controls.md:24`; `35-hosted-publication-evidence.md:80`; launch chronology and live API output above | Prior fabricated-URL negative preserved. Preupload recorded HTTP 404 precedes independently verified publication; current version exists and a second upload was not attempted. Private authority is recorded launch evidence, not a newly inferred legal determination. |
| AC-003 | PASS — unchanged metadata and hosted bytes | `validation/impl-review-01.md:901`; `27-payload-inventory.json:1`; independent archive output above | Prior wrong-name/version/SDK checks retained; changed hosted bytes rejected independently. |
| AC-004 | PASS — published README and fresh exact sample build | `README.md:3`; `README.md:27`; independent consumer build/provenance above | Prior missing-barrel fresh-consumer failure preserved; fresh provenance rejects repository fallback. Hosted README retains detection-only limits. |
| AC-005 | PASS — retained contract and unchanged tested runtime | `validation/impl-review-01.md:903`; `README.md:75`; continuity output above | Prior actual invalid/duplicate/missing tool, shallow-schema, partial-registration, throwing-notification and reset negatives retained. No new semantic suite claimed. |
| AC-006 | PASS — earlier actual Chrome proof retained for identical transport | `validation/impl-review-01.md:178`; `validation/impl-review-01.md:904`; continuity output above | Prior real marker-absent/marker-present/restoration assertions preserved; no fresh Chrome execution claimed. |
| AC-007 | PASS — earlier complete six-stage suite and explicit browser test retained | `validation/impl-review-01.md:34`; `validation/impl-review-01.md:151`; `validation/impl-review-01.md:905` | Prior failed sandbox stage and successful complete rerun are both preserved; 35 files independently match source inventory. Fresh hosted web build also exits 0 on the exact selected SDK. |
| AC-008 | PASS — exact actual published inventory | `validation/impl-review-02.md:256`; `27-payload-inventory.json:1`; live archive and recorded final publisher checks above | Prior actual publisher exclusions and warning/error negatives retained. Fresh changed-byte rejection; archive has exactly 22 approved files with no repository material. |
| AC-009 | PASS — earlier payload consumer/example proof plus two hosted provenance checks and fresh independent build | `validation/impl-review-01.md:383`; `validation/impl-review-01.md:483`; `validation/impl-review-01.md:501`; fresh build/provenance above | Earlier removed-barrel failure retained. Fresh nonexistent hosted version returns 404; repository fallback predicate rejects local root; independent cache contains all 22 exact hosted hashes. |
| AC-010 | FAIL — launch/identity and three content pages PASS; web badge/API documentation still pending | `34-final-publication-controls.md:14`; `35-hosted-publication-evidence.md:7`; final presentation evidence above | Previous invalid upload flag rejection preserved with separate plan-review-03 correction. Final actual publisher matches approved identity. Actual missing badge and HTTP 404 are correctly detected as a failing hosted gate. |
| AC-011 | PASS — preservation and recovery proof retained | `validation/impl-review-01.md:909`; `33-publication-result.md:26`; unchanged inventory and index output above | Earlier exclusion/secret-fixture/history negatives retained. Reviewer changed only this report and disposable temporary artifacts; concurrent external index change is disclosed above without actor attribution. No overwrite/retraction attempted. |

Paths beginning with an artifact number or `validation/` resolve under `wiki/work/0005-pubdev-release-readiness/`. Source paths are repository-relative. Recorded upload success is launch evidence; it does not substitute for source tests or successful hosted presentation.

## Findings

### F-001 — Required hosted presentation is still pending

- Severity: BLOCKER
- Location: `wiki/work/0005-pubdev-release-readiness/35-hosted-publication-evidence.md:7`; live exact-version presentation observed at 14:06:35 UTC.
- Criterion affected: AC-010.
- Observation: [The package page](https://pub.dev/packages/webmcp_flutter/versions/0.1.0) still reports pending analysis with no web platform badge, and [versioned API documentation](https://pub.dev/documentation/webmcp_flutter/0.1.0/) returns HTTP 404. Archive, README, Example, Changelog and hosted builds pass their checks.
- Why it matters: Required postpublication presentation cannot be recorded as complete. This evidence establishes external processing still pending, not a package source defect or a permanent service failure.

## Recurrence check

- Previous round: `validation/impl-review-02.md`.
- Previous F-001: unsupported interactive upload flag. A separate plan review (`validation/plan-review-03.md`) validated the superseding ordinary interactive command; recorded successful upload independently matches that command's actual file selection and accepted warning. The previous defect is not recurring.
- Recurring findings: none.
- Oscillating: no.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | Verify — external hosted processing/presentation gate; no source or plan defect demonstrated. |

