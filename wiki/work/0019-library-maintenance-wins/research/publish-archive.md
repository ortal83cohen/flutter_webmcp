# Research: What does the published webmcp_flutter archive include, and is excluding packages/ and spikes/ safe?

## Question

What files does `dart pub publish --dry-run` include in the webmcp_flutter archive today, which paths does `.pubignore` already exclude, and is it safe for consumers, examples, and repository checks to add `/packages/` and `/spikes/` to `.pubignore`?

## Answer

The archive currently includes `packages/` and `spikes/` because neither directory is listed in `.pubignore`. Both are dead weight for consumers: no file under `lib/` imports from either directory. Excluding `/spikes/` is unconditionally safe. Excluding `/packages/` is safe for consumers and CI but breaks the runability of the bundled `example/` because `example/pubspec.yaml` references both sibling packages via relative path dependencies; that breakage already exists for any consumer who downloads the archive from pub.dev without the workspace structure.

## Findings

### Archive contents confirmed by dry-run

- Claim: `dart pub publish --dry-run` shows `packages/` and `spikes/` in the archive at total compressed size 144 KB.
- Evidence: Command output lists `packages/webmcp_flutter_annotations/`, `packages/webmcp_flutter_generator/` (with its tests and example), `spikes/native-publisher/` (with Python tools and 18 KB JS fixture), and `spikes/page-semantics/` (with 12 test files and a 20 KB integration test).
- Source: `dart pub publish --dry-run` run at repository root `/Users/ortalcohen/Documents/GitHub/flutter_webmcp` (verified 2026-10-11).

### What .pubignore currently excludes

- Claim: `.pubignore` excludes `/test/`, `/tools/`, `/wiki/`, `/example/test/`, `/analysis_options.yaml`, agent/CI/editor config directories, credentials, generated build output, and Python/OS caches. It does not exclude `/packages/` or `/spikes/`.
- Evidence: Full file content read.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/.pubignore` lines 1–43.

### lib/ does not import packages/ or spikes/

- Claim: No Dart file under `lib/` imports anything from `packages/` or `spikes/`.
- Evidence: `rg 'packages/|spikes/'` across `lib/**/*.dart` returns zero matches.
- Source: Grep run on `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib` (verified 2026-10-11).

### check.sh does not test spikes/

- Claim: The CI check script runs tests in `packages/webmcp_flutter_generator` but includes no step for any directory under `spikes/`.
- Evidence: `tools/check.sh` stages 2–6 reference `packages/webmcp_flutter_annotations`, `packages/webmcp_flutter_generator`, `packages/webmcp_flutter_generator/example`, and `example`; no stage references `spikes/`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/tools/check.sh` lines 25–67.

### example/pubspec.yaml uses path dependencies into packages/

- Claim: `example/pubspec.yaml` declares `webmcp_flutter_annotations` and `webmcp_flutter_generator` as path dependencies pointing at `../packages/webmcp_flutter_annotations` and `../packages/webmcp_flutter_generator`. If `packages/` is excluded from the archive, these paths will be unresolvable for anyone who tries to run `pub get` inside the published example.
- Evidence: `example/pubspec.yaml` lines 14–27.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/pubspec.yaml`.

### packages/ are independent packages, not part of the library surface

- Claim: `packages/webmcp_flutter_annotations` and `packages/webmcp_flutter_generator` each have their own `pubspec.yaml` and are separate pub packages, not imported or re-exported by the root library.
- Evidence: Both have `name:` fields different from `webmcp_flutter`; neither is listed as a dependency in the root `pubspec.yaml`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/packages/webmcp_flutter_annotations/pubspec.yaml`; `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/packages/webmcp_flutter_generator/pubspec.yaml`; `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/pubspec.yaml`.

### pub.dev publish rules confirmed

- Claim: `dart pub publish` includes all non-hidden files not listed in `.pubignore` or `.gitignore`. A `.pubignore` file in the root overrides `.gitignore` in that directory.
- Evidence: Official documentation states "The published package includes all files under the package root directory, with the following exceptions: Any hidden files or directories…Files and directories listed to be ignored in a `.pubignore` or `.gitignore` file."
- Source: https://dart.dev/tools/pub/publishing#what-files-are-published (fetched 2026-10-11).

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Add `/packages/` and `/spikes/` to `.pubignore` | Two lines in `.pubignore`; CI still runs packages/ tests from the workspace | Breaks runability of bundled example/ path deps; no consumer impact since lib/ is untouched | Chosen — consumers gain nothing from packages/ or spikes/ in the archive; example path-dep breakage is a pre-existing condition for any out-of-workspace user |
| Keep current state (publish packages/ and spikes/) | No change required | Archive bloat (~60–80 KB compressed for non-library content); misleading package scope; Python scripts and PNG icons shipped to consumers | Rejected — no consumer value, wastes archive budget, confuses pub.dev scoring |
| Exclude `/spikes/` only | One line in `.pubignore` | Still ships packages/ source and tests | Rejected — packages/ also has no consumer value; half-measure |
| Replace example path deps with published package refs before excluding packages/ | Update example/pubspec.yaml to use `webmcp_flutter_annotations: ^0.1.0` etc. | Requires packages to be published on pub.dev first; introduces coordination complexity | Out of scope for this research; recorded as a constraint |

## Constraints discovered

1. `example/pubspec.yaml` uses `path: ../packages/webmcp_flutter_annotations` and `path: ../packages/webmcp_flutter_generator`. Excluding `packages/` from the archive without updating these references leaves the example's `pubspec.yaml` with broken paths for any consumer attempting to run it from the pub.dev download. The example is still valid for visual reference on pub.dev.

2. `tools/check.sh` runs `packages/webmcp_flutter_generator` tests from the repository workspace, not from the published archive. Excluding `packages/` from the archive does not break CI.

3. The current archive is 144 KB compressed. The official pub.dev recommendation is under 100 MB; the size is not a hard constraint today, but shipping third-party package sources and PNG icon assets is unnecessary.

4. Dart publish rules treat `.pubignore` as overriding `.gitignore` at the root level. Any path listed with a leading `/` is anchored to the package root, consistent with gitignore glob syntax.

## Unresolved

- [UNRESOLVED: Would excluding `/packages/` from the archive require updating example/pubspec.yaml to use published (non-path) dependency versions of webmcp_flutter_annotations and webmcp_flutter_generator before the change ships? This is a sequencing question for the plan phase, not a research question.]

## Sources

| Source | URL / Path | Date |
|---|---|---|
| dart pub publish docs | https://dart.dev/tools/pub/publishing#what-files-are-published | 2026-10-11 |
| .pubignore | `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/.pubignore` | 2026-10-11 |
| root pubspec.yaml | `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/pubspec.yaml` | 2026-10-11 |
| example/pubspec.yaml | `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/pubspec.yaml` | 2026-10-11 |
| packages/webmcp_flutter_annotations/pubspec.yaml | `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/packages/webmcp_flutter_annotations/pubspec.yaml` | 2026-10-11 |
| packages/webmcp_flutter_generator/pubspec.yaml | `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/packages/webmcp_flutter_generator/pubspec.yaml` | 2026-10-11 |
| tools/check.sh | `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/tools/check.sh` | 2026-10-11 |
| dart pub publish --dry-run output | Executed at repository root | 2026-10-11 |
