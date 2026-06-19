---
name: kolosys:audit-security
description: Run a security audit — auth boundaries, input validation, secret scanning, CSP/CORS review, and dependency analysis.
argument-hint: "[scope] (default: full project)"
---

# Security Audit

## Preflight

Detect what to audit:

- Route path provided → focus on that route's actions, handlers, components
- Service name → audit Go service security
- No argument → full project scan

Detect stack:

- `package.json` with `next` → Next.js security checks
- `go.mod` → Go security checks
- Both → run all checks

## Plan

### Auth Boundary Sweep

1. Find all Server Actions (`'use server'` files) — verify each has auth check
2. Find all Route Handlers (`route.ts` files) — verify auth/signature validation
3. Find `proxy.ts` — review access control scope
4. Go: find all HTTP handlers — verify middleware + per-handler auth

### Input Validation Check

1. Server Actions — verify Zod `safeParse` before processing
2. Route Handlers — verify body/header/query validation
3. Go handlers — verify struct validation before DB operations
4. Search for `dangerouslySetInnerHTML` — flag and verify sanitization

### Secret Scan

1. Grep for patterns: API key formats, `sk-`, `ghp_`, `Bearer`, hardcoded tokens
2. Audit `NEXT_PUBLIC_*` env vars for sensitive values
3. Check `.env` files are in `.gitignore`
4. Search for secrets in log statements

### Infrastructure Review

1. CSP headers — check `next.config.ts` and `proxy.ts`
2. CORS configuration — verify origin restrictions on authenticated endpoints
3. Cookie settings — verify HttpOnly, Secure, SameSite on session cookies
4. Rate limiting — check auth and AI endpoints

### Dependency Audit

1. Run `npm audit` or `pnpm audit` (Next.js)
2. Run `govulncheck ./...` (Go, if available)
3. Check for copyleft licenses in MIT project
4. Flag unmaintained dependencies (optional: `npm outdated`)

## Execute

Run each check category. Collect findings with severity levels:

- **Critical** — auth bypass, secret exposure, injection vector
- **High** — missing auth on action, XSS, critical CVE
- **Medium** — permissive CSP, missing rate limit, moderate CVE
- **Low** — best-practice improvement, informational

## Verify

- [ ] Every Server Action has auth check
- [ ] Every Route Handler validates callers
- [ ] No hardcoded secrets in source
- [ ] CSP headers present and reasonably strict
- [ ] No critical/high CVEs in dependencies
- [ ] Session cookies have security attributes

## Summary

```
## Security Audit Results

| # | Severity | Category | Location | Finding | Fix |
|---|----------|----------|----------|---------|-----|
| 1 | Critical | Auth | src/app/cart/actions.ts | Missing auth check on updateCart | Add getSession() guard |
| 2 | High | Secret | .env.local | NEXT_PUBLIC_DB_URL exposes DB host | Remove NEXT_PUBLIC_ prefix |
| 3 | Medium | Infra | next.config.ts | No CSP headers configured | Add CSP via headers() |

### Dependency Report
- npm audit: 0 critical, 1 high, 3 moderate
- Licenses: all permissive (MIT, Apache-2.0)
```

Prioritize fixes by severity. Include specific code changes for each finding.
