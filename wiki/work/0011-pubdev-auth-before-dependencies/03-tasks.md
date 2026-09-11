# Tasks: Prevent pub.dev OIDC auth from breaking dependency resolution

1. [x] Research the observed authorization failure and documented OIDC workflow. Satisfies AC-001, AC-002, AC-003, AC-004.
2. [x] Implement the dependency-before-auth ordering in `.github/workflows/publish.yml`. Satisfies AC-001, AC-002, AC-003, AC-004.
3. [x] Run local validation and record the external GitHub Actions verification boundary. Satisfies AC-001, AC-002, AC-003, AC-004.
