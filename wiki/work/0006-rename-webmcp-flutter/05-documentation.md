# Documentation evidence

Documentation scope was verified on 2026-09-10 against the accepted mechanical rename to `webmcp_flutter`. The active README and product contract use the new package identity, while the historical work records remain available and unchanged.

## Active documentation evidence

The active package README identifies `webmcp_flutter` in its title and package description. The active product contract identifies the same package and retains the detection-only WebMCP boundary. The old package identities are absent from the active README and product documentation.

```text
$ rg -n -i 'webmcp_pilot|flutter_webmcp' README.md wiki/product || true
(no output)
exit 0

$ rg -n 'webmcp_flutter|WebMCP Flutter' README.md wiki/product
README.md:1:# webmcp_flutter
README.md:3:`webmcp_flutter` is a detection-first WebMCP tool registry and optional widget lifecycle layer for Flutter web applications.
README.md:5:Add `webmcp_flutter` to a Flutter package with a path dependency while this package is under development. The package currently targets Flutter 3.47.0 and web only.
wiki/product/webmcp-contract.md:13:`webmcp_flutter` now contains an explicit Dart-side registry for Flutter Web actions that may later be exposed as WebMCP tools. Its browser integration is detection-only: it checks for the current WebMCP document entry point and records that tools are not published. This package therefore does not claim working browser behavior.
exit 0
```

## Historical preservation

The historical work records in `wiki/work/0001-*` through `wiki/work/0004-*` were compared with the supplied pre-rename snapshot. The only differences reported beneath `wiki/work` are the pre-existing/new work-item directories `0005-pubdev-release-readiness` and `0006-rename-webmcp-flutter`; no historical file under `0001` through `0004` was changed by this rename.

```text
$ diff -qr /var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/webmcp-rename-baseline-dwu_5ap6/wiki/work wiki/work | head -40
Only in wiki/work: 0005-pubdev-release-readiness
Only in wiki/work: 0006-rename-webmcp-flutter
exit 0
```

The naming decision is recorded in [0005 name selection](../0005-pubdev-release-readiness/13-name-selection.md); no new ADR is needed for this user-selected mechanical rename. The wiki router remains unchanged because work-item documents are discovered through the work directory convention.

## Documentation validation

```text
$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).
exit 0
```

This artifact covers AC-003's active product-documentation portion and AC-004's historical-documentation portion. Overall work-item closure still awaits the independent implementation verdict.
