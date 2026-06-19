---
title: Dependency Audit Workflows
description: npm audit, govulncheck, license compliance scanning, and supply-chain risk assessment workflows for Go and Node.js projects.
---

# Dependency Audit Workflows

## Node.js / npm

### Quick Audit

```bash
npm audit
# or
pnpm audit
```

### Fix Automatically

```bash
npm audit fix
# For breaking changes (major version bumps):
npm audit fix --force  # review changes carefully
```

### Audit Report Interpretation

| Severity | Action |
|----------|--------|
| Critical | Fix immediately — actively exploited or trivially exploitable |
| High | Fix before next deploy — exploitable with some effort |
| Moderate | Fix in current sprint — requires specific conditions |
| Low | Track — minimal real-world risk |

### Deep Dependency Check

```bash
# Check which packages depend on a vulnerable package
npm ls <vulnerable-package>

# Check for outdated packages
npm outdated
```

## Go

### Module Verification

```bash
# Verify module checksums against go.sum
go mod verify

# Check for known vulnerabilities
govulncheck ./...

# Tidy unused dependencies
go mod tidy
```

### govulncheck Output

```
Vulnerability #1: GO-2024-XXXX
  Description: ...
  Found in: example.com/pkg@v1.2.3
  Fixed in: example.com/pkg@v1.2.4
  Affected: function Foo in package bar
```

- `Fixed in` available → upgrade immediately
- No fix available → evaluate workaround or replace dependency

## License Compliance

### Permissive (safe for open source)

- MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, Unlicense

### Copyleft (requires review)

- GPL-2.0, GPL-3.0 → may require releasing your code under GPL
- LGPL → acceptable for dynamic linking, not static
- AGPL → triggers on network use (SaaS) — avoid in most cases

### No License

- Treat as "all rights reserved" — do not use in production

### Scanning Tools

```bash
# Node.js
npx license-checker --summary
npx license-checker --failOn "GPL-2.0;GPL-3.0;AGPL-3.0"

# Go
go-licenses check ./...
```

## Supply Chain Risk Assessment

### Red Flags

| Signal | Risk | Action |
|--------|------|--------|
| Package name similar to popular package | Typosquatting | Verify official registry entry |
| No commits in >1 year | Unmaintained | Evaluate alternatives |
| Single maintainer, high download count | Bus factor risk | Monitor for ownership transfers |
| Install scripts (`preinstall`, `postinstall`) | Arbitrary code execution | Audit the scripts |
| Excessive transitive dependencies | Large attack surface | Prefer minimal-dep alternatives |
| Recently published with high version number | Possible hijack | Check publish history |

### Mitigation

- Pin exact versions in lockfiles (`package-lock.json`, `go.sum`)
- Review diffs on dependency updates before merging
- Use `npm pack --dry-run` to inspect what a package ships
- Enable npm provenance / Sigstore verification when available
- Prefer dependencies with multiple maintainers and active security policies

## Audit Cadence

| Event | Action |
|-------|--------|
| Every PR | `npm audit` / `govulncheck` in CI |
| Weekly | Review `npm outdated` / `go list -m -u all` |
| Before launch | Full audit: CVEs + licenses + supply chain review |
| After incident | Re-audit affected dependency tree |
