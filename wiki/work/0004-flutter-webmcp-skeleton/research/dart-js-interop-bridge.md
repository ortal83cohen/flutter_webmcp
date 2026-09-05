# Research: Bridging Dart to an experimental, not-yet-in-IDL browser API (`navigator.modelContext`)

## Question

How should a Flutter Web package technically bridge Dart to an experimental, not-yet-in-web-IDL browser API like `navigator.modelContext` (Chrome's WebMCP), specifically:

1. Which `package:web` / `dart:js_interop` JS-interop pattern is the current recommended way to call into a `window`/`navigator` property that has no generated typed binding yet (extension types vs `@JS()` vs raw `JSObject` vs dynamic property access)?
2. How should the package feature-detect support so it no-ops cleanly on browsers/versions without the API, without throwing?
3. How should a Dart-side tool parameter definition (name + type + description, a JSON-schema-like shape) be serialized to the object shape the JS API expects?

## Answer

Declare an `extension` (not a new `extension type`) on `package:web`'s existing `Navigator` extension type that adds one or more `external` members (e.g. `external JSObject? get modelContext;`) — this is the sanctioned Dart-3.3+ mechanism for augmenting a sealed static-interop type with a property the generator hasn't caught up to yet, and it keeps everything statically typed with zero JS-string keys. Feature-detection must not rely on that `external` getter alone (an `external` getter on a missing JS property returns `undefined`/`null` safely, it does not throw), but the robust, IDE-agnostic-of-typos check is `navigator.hasProperty('modelContext'.toJS)` from `dart:js_interop_unsafe`, gated additionally by a UA/engine check if stricter Chrome-version gating is required. Tool parameter schemas (name/type/description/nested shape) should be built as plain `JSObject` object literals via `external factory` constructors on a small extension type (or, for deeply dynamic/nested schemas, via `jsify()` on a `Map<String, Object?>`), never via string-keyed `dart:js_interop_unsafe` `setProperty` calls, to keep the schema-construction path statically checked and `pana`-clean.

## Findings

### `dart:js_interop` extension types are the current, non-deprecated foundation; `dart:html`/`dart:js`/`package:js` are legacy

- Claim: `package:web` is "based on `dart:js_interop`" and is the SDK's replacement for `dart:html`; `dart:js_interop` with extension types (available since Dart 3.3) is the current recommended interop mechanism, superseding `@staticInterop`/`package:js` for new code.
- Evidence: "package:web is based on dart:js_interop, so by default, it's supported on dart2wasm." "Static interop is now supported with extension types in Dart 3.3 ... you should prefer using dart:js_interop with extension types instead of @staticInterop." "@staticInterop does nothing on extension types since extension types by definition can only use static dispatch."
- Source: https://dart.dev/interop/js-interop/package-web (consulted 2026-09-04); https://dart.dev/interop/js-interop/past-js-interop (consulted 2026-09-04)

### Extension types wrapping `JSObject` are the base pattern for declaring an interface over an untyped JS value

- Claim: The canonical way to give a typed Dart shape to an arbitrary JS object (including one returned by `window`/`navigator` with no generated binding) is `extension type Foo(JSObject _) implements JSObject { external ...; }`. There is no runtime verification that the underlying object actually matches — it is a compile-time-only contract.
- Evidence: "extension type InteropType(JSObject _) implements JSObject {}" is the documented pattern; "there's no runtime guarantee that `Window` is actually a JS `Window`," it only lets you declare interop members for the object's properties/methods.
- Source: https://dart.dev/interop/js-interop/js-types (consulted 2026-09-04); https://dart.dev/interop/js-interop/usage (consulted 2026-09-04)

### `extension` (not `extension type`) blocks can add `external` members to an *existing* extension type such as `package:web`'s `Navigator`/`Window`

- Claim: Because `Navigator` and `Window` from `package:web` are themselves extension types over `JSObject`, the correct way to add a not-yet-generated property (`modelContext`) without redeclaring the whole type is a plain `extension` block on the existing type, containing `external` getters/methods. Dart supports `external` static-extension members precisely to let user code "amend outdated DOM native APIs" ahead of the generator.
- Evidence: "Dart supports static extension methods that are also external, which allows support for several JS-interop patterns and provides flexibility to amend outdated DOM native APIs." Practical shape: `extension NavigatorModelContext on Navigator { external JSObject? get modelContext; }`.
- Source: https://dart.dev/interop/js-interop/usage (consulted 2026-09-04, via search summary); corroborated by GitHub issue discussion `js-interop: support external static extension methods` — https://github.com/dart-lang/sdk/issues/44057 (consulted 2026-09-04). [UNVERIFIED: exact wording of the extension-on-existing-type example was not directly quoted from the live usage page; the WebFetch tool returned a paraphrase, not the literal source markdown, for this specific claim]
- The alternative, `@JS()` top-level external getters, is documented only for binding brand-new globals (e.g. `@JS() external JSObject get document;`), not for adding a member to an already-declared extension type; using it for `navigator.modelContext` would require redeclaring a duplicate `Navigator`-shaped type rather than extending the one from `package:web`, which is more code and risks incompatibility if `package:web`'s `Navigator` gains the real property later.
- Source: https://dart.dev/interop/js-interop/start (consulted 2026-09-04)

### `JSObject` itself is opaque; typed extension members are preferred over dynamic string-keyed access in the main code path

- Claim: `JSObject` "is opaque and doesn't provide type safety or auto-completion." Dynamic property access (`obj['key']`, `getProperty`, `setProperty`, `callMethod`) lives in `dart:js_interop_unsafe` and is explicitly documented as a fallback, not the default.
- Evidence: "dart:js_interop_unsafe provides utility methods to manipulate JavaScript objects dynamically, and is typically meant to be used when the names of properties or methods are not known statically... Usage of this library can be unsafe, as safe usage of these methods cannot necessarily be verified statically. You should prefer using statically analyzable values like constants or literals for property or method names, and should use this library cautiously and only when the same effect cannot be achieved with static interop." "Avoid using dart:js_interop_unsafe if possible."
- Source: https://api.flutter.dev/flutter/dart-js_interop_unsafe/ (consulted 2026-09-04); https://dart.dev/interop/js-interop/start (consulted 2026-09-04, via search summary)

### Feature detection: `hasProperty`/`has` from `dart:js_interop_unsafe`, applied to the `Navigator`/`window` object, is the documented non-throwing existence check

- Claim: `JSObject` gains `hasProperty(JSAny property) → JSBoolean` and a Dart-convenience wrapper `has(String property) → bool` through `JSObjectUnsafeUtilExtension` (part of `dart:js_interop_unsafe`). These do not throw when the property is absent; they return `false`/`JSBoolean(false)`. Calling an `external` getter for a property that does not exist on the underlying JS object also does not throw — it evaluates to JS `undefined`, which crosses to Dart as `null` for a nullable-typed getter.
- Evidence: `has` — "Checks if a property exists (Dart wrapper for hasProperty)"; `hasProperty` — "Determines whether a property key is present"; `getProperty`/`operator[]` return `R` / `JSAny?` without throwing on absence.
- Source: https://api.dart.dev/dart-js_interop_unsafe/JSObjectUnsafeUtilExtension.html (consulted 2026-09-04)
- Practical feature-detection composite for this package: check `web.window.navigator.has('modelContext')` (or the extension getter returning non-null) before calling any WebMCP method, so browsers without the flag/API (non-Chrome, or Chrome versions before the flag-gated rollout) simply see the check fail and the package no-ops. [UNVERIFIED: whether `navigator.modelContext` is exposed as `undefined` vs. simply absent from the prototype chain in current Chrome builds — this affects whether `has()`/`hasProperty()` (own+prototype property presence) or an `external` nullable getter equality-to-null check is the more reliable test; this is WebMCP-API-shape detail out of this research stream's boundary]
- Platform/engine gating beyond property presence (e.g. distinguishing an origin-trial flag state) is out of scope here; if needed it would use `package:web`'s existing `Navigator.userAgent`/`userAgentData` bindings, which are already-typed IDL members, not a new interop pattern.

### Serializing a Dart tool-parameter schema (name + type + description, nested) to the JS shape

- Claim: Two supported, non-deprecated conversion paths exist. (a) A small extension type with an `external factory` constructor taking named parameters builds a genuine JS object literal at the call site — recommended when the schema shape is small/fixed and known at compile time. (b) `jsify()` (from `dart:js_interop`, `Object?.jsify()` on a `Map<String, Object?>`/`List<Object?>` built from Dart data) performs a generic, recursive Dart-to-JS conversion — recommended when the schema is data-driven/deeply nested (arbitrary nested JSON-schema `properties`/`items`), at the cost of extra runtime type-checking.
- Evidence: "For creating simple JS objects with property initialization, use constructors with only named parameters... A call to `Options(a: 0, b: 1)` results in creating the JS object `{a: 0, b: 1}`." "Use `jsify()` for dynamic conversion or specific conversion functions when you know the type... Prefer using the specific conversion when you know the type of the JS value, as the extra type-checking might be expensive."
- Source: https://dart.dev/interop/js-interop/usage (consulted 2026-09-04); https://dart.dev/interop/js-interop/js-types (consulted 2026-09-04, "Passing arbitrary Dart values into JS is not allowed" — Dart values must go through `jsify()`/an interop type/primitive conversion, never be passed raw)
- Constraint: whichever path is used, string-keyed `dart:js_interop_unsafe.setProperty` calls to build the schema object should be avoided as the primary path per the same "avoid `dart:js_interop_unsafe` if possible" guidance above — it is a fallback for genuinely dynamic key names, not the default schema-building mechanism.
- [UNVERIFIED: the exact JSON-Schema-like object shape (`{type, description, properties, required, ...}`) that Chrome's WebMCP tool-registration API expects is out of this stream's boundary — covered by the WebMCP-API-shape research branch. This finding only establishes the Dart→JS *serialization mechanism*, not the target field names.]

### `package:web` current version and SDK constraint (for `pana`/pubspec correctness)

- Claim: `package:web` latest stable release is `1.1.1` (requires Dart SDK `^3.4.0`), published by the `dart.dev`-verified publisher, BSD-3-Clause. `1.1.1` deprecated `Node.text` (use `Node.textContent`) and bracket-notation `Storage` extensions — i.e. even `package:web` itself is mid-migration on some members, so a package built on top of it should avoid depending on anything already flagged deprecated in `package:web`'s own changelog.
- Evidence: GitHub releases list `v1.1.1`, `v1.1.0`, `v1.0.0`, `v0.5.1` for `dart-lang/web`; pub.dev lists `web` version `1.1.1`, "minimum Dart SDK requirement of 3.4."
- Source: https://github.com/dart-lang/web/releases (consulted 2026-09-04); https://pub.dev/packages/web (consulted 2026-09-04); https://pub.dev/packages/web/changelog (consulted 2026-09-04)
- [UNVERIFIED: exact publish year of `1.1.1` — pub.dev/GitHub UI returned relative/partial dates ("18 months ago", "February 26") without an unambiguous year in the fetched summaries; treat as "current latest as of 2026-09-04" and re-verify at implementation time with `dart pub outdated` or `pub.dev/packages/web` directly]

### `pana`/pub.dev implications

- Claim: `pana` (pub.dev's scoring tool) flags usage of SDK libraries marked `@Deprecated` and platform-declaration mismatches; using `dart:html`, `dart:js`, or `package:js` in a package's own source would be flagged as using a deprecated/legacy interop surface, whereas `dart:js_interop` + `package:web` is the currently sanctioned, non-deprecated surface.
- Evidence: `dart.dev`'s own migration guidance frames `dart:html`/`dart:js`/`package:js` as the path being migrated *away from*, and `package:web`/`dart:js_interop` as the replacement, which is consistent with why pub.dev scoring penalizes the legacy libraries. [UNVERIFIED: the specific pana rule/scoring line item that penalizes `dart:html`/`dart:js` was not located in a primary pana source document during this research pass — this claim is inferred from the deprecation status of those SDK libraries plus general pana behavior of flagging deprecated API usage, not confirmed against pana's own rule source]
- Source: https://dart.dev/interop/js-interop/package-web (consulted 2026-09-04)
- Separately, this package must declare `platforms: web` (or restrict via `flutter: platforms:` if a Flutter package) in `pubspec.yaml` since `dart:js_interop`/`package:web` are web-only; omitting or mis-declaring platform support is itself a `pana` scoring deduction. [UNVERIFIED: exact pana point deduction value for missing/incorrect platform declaration — pana scoring rubric was not fetched in this pass, out of this research question's strict scope but flagged for the plan phase]

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| `extension` block adding `external` members onto `package:web`'s existing `Navigator`/`Window` extension type | `extension NavigatorModelContext on Navigator { external JSObject? get modelContext; }`, called as `web.window.navigator.modelContext` | Low: a few lines, statically typed, zero string keys in the hot path, automatically stays compatible if `package:web` later adds the real binding (same shape) | **Chosen.** Matches the documented Dart 3.3+ pattern for "amending outdated DOM native APIs" ahead of the generator; keeps `pana`-visible surface entirely within `dart:js_interop`/`package:web`. |
| New standalone `extension type` re-declaring a `Navigator`-shaped wrapper over `JSObject`, independent of `package:web`'s `Navigator` | `extension type MyNavigator(JSObject _) implements JSObject { external JSObject? get modelContext; }`, obtained via `MyNavigator(web.window.navigator as JSObject)` (or an unsafe cast) | Medium: works, but duplicates/casts away `package:web`'s existing typed `Navigator`, loses access to its already-typed members without re-declaring them too, and needs an explicit cast at every call site | Rejected: strictly more code and a weaker type-safety story than extending the existing type in place; only useful if `package:web`'s `Navigator` were unavailable, which it is not. |
| Top-level `@JS()` external getter (`@JS('navigator.modelContext') external JSObject? get _modelContext;`) | Global-namespace binding independent of any existing type | Low code, but bypasses `package:web`'s `Navigator` object entirely and is documented primarily for binding brand-new top-level globals (`document`, `window`), not nested members of an existing bound object | Rejected as primary path: less idiomatic for a property *of* an already-typed object; also historically the `package:js`-era pattern being migrated away from, though the `@JS()`-annotated-getter form itself is still valid under `dart:js_interop`. Kept as a documented fallback only. |
| `dart:js_interop_unsafe` dynamic access (`navigator['modelContext']`, `getProperty`/`callMethod`) as the primary calling mechanism | String-keyed reflection-style access, no compile-time binding at all | Low upfront code, but no static checking, explicitly discouraged by dart.dev ("avoid ... if possible"), and less legible for review/`pana` maintainability signals | Rejected as primary mechanism; retained only for the feature-detection `has()`/`hasProperty()` check, which is the one place dart.dev's own docs recommend it. |
| Serialize tool-parameter schema via `extension type ... external factory` object-literal constructor | Compile-time-fixed named-parameter constructor producing a JS object literal | Low cost for fixed/known shape; brittle if the schema needs arbitrary nested `properties` maps of variable shape | **Chosen for the fixed top-level shape** (name/type/description) — statically checked, `pana`-friendly. |
| Serialize tool-parameter schema via `jsify()` on a `Map<String, Object?>` | Generic recursive Dart→JS conversion, handles arbitrary nesting | Slightly higher runtime cost (extra type-checking per dart.dev), less compile-time shape safety | **Chosen as the mechanism for the variable/nested part** (arbitrary nested JSON-schema `properties`), combined with the fixed-shape factory constructor for the outer envelope. |

## Constraints discovered

- `dart:js_interop`/`package:web` are web-only SDK surfaces; a package using them must declare Flutter/Dart platform support accordingly, or `pana` will penalize the platform-declaration score. [UNVERIFIED: exact pana rule text — see Findings]
- `package:web` requires Dart SDK `^3.4.0` at minimum (current release `1.1.1`); the package's `pubspec.yaml` SDK constraint must be at least that to use extension-type interop syntax at all (extension types themselves require Dart 3.3+, but `package:web`'s own floor is 3.4). Source: https://pub.dev/packages/web (consulted 2026-09-04).
- `external` getters on absent JS properties resolve to `null`/`undefined` rather than throwing, which is what makes the extension-based feature detection safe by construction — but this must still be paired with an explicit `has()`/`hasProperty()` or null-check before *calling* any method on the (possibly-null) returned object, since calling a method on a null/undefined JS reference does throw.
- On WebAssembly (`dart2wasm`) compilation targets, "all JS interop types share a single underlying runtime representation," so ordinary Dart `is`/`as` checks on JS-interop values are unreliable; `isA<T>()`/`typeofEquals()`/`instanceOfString()` must be used instead if any runtime type discrimination of JS values is needed (relevant if this package ever needs to type-check a WebMCP callback argument coming back from JS). Source: https://dart.dev/interop/js-interop/js-types (consulted 2026-09-04).
- `dart:js_interop_unsafe` usage is explicitly discouraged by the official docs beyond narrow, justified cases (feature detection here); overuse is a code-review/maintainability red flag even if it doesn't directly fail `pana`.
- The exact WebMCP tool-registration function name/argument shape and the exact Chrome version/flag gating `navigator.modelContext` sits behind are out of this research stream's boundary (covered elsewhere); this document only establishes the Dart-interop mechanism, not the target API contract.

## Unresolved

- [UNRESOLVED: Whether `navigator.hasProperty('modelContext'.toJS)` (own+prototype property presence check) or a plain null-check on an `external` nullable getter is the more reliable feature-detection signal for Chrome's actual current implementation of `navigator.modelContext` (e.g., whether the property is polyfilled as `undefined` vs. genuinely absent from the prototype, and whether it differs across the flag-gated origin-trial rollout) — this depends on the live WebMCP API shape, out of this stream's boundary.]
- [UNRESOLVED: The exact pana scoring rule(s) that penalize deprecated `dart:html`/`dart:js` usage and missing/incorrect platform declarations — not confirmed against pana's own source or scoring documentation in this pass.]
- [UNRESOLVED: The precise publish date/year of `package:web` `1.1.1` — pub.dev/GitHub UI summaries returned relative or partial dates without an unambiguous year; should be re-verified at implementation time (e.g., via `dart pub outdated` or a direct pub.dev page read) before pinning a version in `pubspec.yaml`.]
- [UNRESOLVED: Whether `dart-lang/web`'s own repository (or its issue tracker) has an open issue/PR already proposing to add `modelContext` to the generated `Navigator` type — if one exists, this package's `extension`-based workaround should be written so it can be removed cleanly once upstream lands it. Not checked in this pass; checking `github.com/dart-lang/web/issues` for "modelContext"/"WebMCP" is a reasonable follow-up.]

## Sources

- https://dart.dev/interop/js-interop/package-web (consulted 2026-09-04)
- https://dart.dev/interop/js-interop/js-types (consulted 2026-09-04)
- https://dart.dev/interop/js-interop/usage (consulted 2026-09-04)
- https://dart.dev/interop/js-interop/start (consulted 2026-09-04)
- https://dart.dev/interop/js-interop/past-js-interop (consulted 2026-09-04)
- https://api.flutter.dev/flutter/dart-js_interop_unsafe/ (consulted 2026-09-04)
- https://api.dart.dev/dart-js_interop_unsafe/JSObjectUnsafeUtilExtension.html (consulted 2026-09-04)
- https://api.dart.dev/dart-js_interop/JSObject-extension-type.html (consulted 2026-09-04)
- https://pub.dev/packages/web (consulted 2026-09-04)
- https://pub.dev/packages/web/changelog (consulted 2026-09-04)
- https://github.com/dart-lang/web/releases (consulted 2026-09-04)
- https://github.com/dart-lang/sdk/issues/44057 ("js-interop: support external static extension methods") (consulted 2026-09-04)
