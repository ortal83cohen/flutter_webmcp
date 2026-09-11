# README feature guide

## Change and qualification

Expanded README.md with a consumer feature map, manual tools and scopes,
screen lifecycle, page read/act examples, policies, observation and receipts,
resource limits, generation setup, publication diagnostics, custom transports,
observers, and runnable-example links. Corrected the stale Wasm navigation note
using the existing 0008 implementation evidence without claiming completed
native-agent verification.

1. One requested file: README.md; this record and state are workflow metadata.
2. No dependency changes: dependency examples are documentation only.
3. No public interface, route, or schema changes.
4. No data model, migration, or stored data changes.
5. No security or privacy implementation changes; existing policies are described.

## Sources and verification

Checked public exports and implementations under lib/src, the annotation and
generator packages, and the existing consumer fixture. Existing unrelated dirty
files were preserved. A documentation-only change does not add a runtime test.
Validated local Markdown destinations and balanced fences; examples were reviewed
against source signatures but were not independently compiled or browser-tested.

```text
README validation: 8 local links resolve; fenced blocks are balanced.
```

## Full check output

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH bash tools/check.sh`

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 71: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.stamp.tmp.76980: Operation not permitted
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 78: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.realm: Operation not permitted
Stage 2 failed: dependencies
```

The full suite is blocked at SDK-cache writes. Later stages remain [UNVERIFIED].
The workflow remains in verify; the documentation edit is present, but the full
quick-route completion gate is not claimed.
