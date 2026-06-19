---
name: security
description: Guides security audits, auth boundary hardening, input validation, CSP/CORS configuration, secret hygiene, and dependency auditing for Go libraries and Next.js 16+ sites. Use when reviewing security posture, hardening infrastructure, or auditing dependencies.
metadata:
  pathPatterns:
    - "**/auth/**"
    - "**/proxy.ts"
    - "src/app/api/**/route.ts"
    - "**/*.env*"
    - "**/csp*"
    - "**/cors*"
  importPatterns:
    - "next/headers"
    - "bcrypt"
    - "jsonwebtoken"
    - "jose"
  bashPatterns:
    - "\\bnpm\\s+audit\\b"
    - "\\bpnpm\\s+audit\\b"
    - "\\bgovulncheck\\b"
    - "\\bgo\\s+mod\\s+verify\\b"
  promptSignals:
    phrases:
      - "security"
      - "audit"
      - "vulnerability"
      - "csp"
      - "cors"
      - "secret"
      - "dependency audit"
      - "cve"
      - "rate limit"
      - "auth boundary"
chainTo:
  - pattern: "src/app/.*/actions\\.ts|src/app/.*/route\\.ts"
    targetSkill: nextjs-feature
    message: "Route module files detected — loading Next.js feature guidance."
  - pattern: "\\.go$|go\\.mod"
    targetSkill: go-library
    message: "Go files detected — loading Go library guidance."
---

# Security Auditing

TRIGGER when: reviewing auth boundaries, auditing dependencies, hardening CSP/CORS/cookies, scanning for secrets, or validating input sanitization.
DO NOT TRIGGER when: building features, designing UI, writing content, or optimizing performance.

## Audit Checklist

### Auth Boundaries

- [ ] Every Server Action checks auth before processing
- [ ] Every Route Handler validates tokens/signatures
- [ ] proxy.ts handles broad access control; actions handle fine-grained
- [ ] Go handlers have middleware for auth + per-handler for resource access

### Input Validation

- [ ] Zod schemas on all Server Action inputs
- [ ] Route Handler bodies, headers, query params validated
- [ ] Go structs validated before DB operations
- [ ] User-generated content sanitized against XSS

### Secrets

- [ ] No hardcoded API keys or tokens in source
- [ ] `NEXT_PUBLIC_*` vars contain only non-sensitive values
- [ ] `.env` files in `.gitignore`
- [ ] No secrets in log output

### Infrastructure

- [ ] CSP headers configured (nonce-based preferred)
- [ ] CORS restricted to known origins on authenticated endpoints
- [ ] Session cookies: HttpOnly, Secure, SameSite=Lax minimum
- [ ] Rate limiting on auth and AI endpoints
- [ ] HTTPS enforced, no mixed content

### Dependencies

- [ ] `npm audit` / `pnpm audit` shows no critical/high CVEs
- [ ] `govulncheck` clean (Go projects)
- [ ] No copyleft licenses in MIT projects
- [ ] No unmaintained dependencies in critical paths

## References

- [Next.js Security](references/nextjs-security.md) — CSP headers, auth patterns, env exposure, cookies, rate limiting
- [Dependency Audit](references/dependency-audit.md) — npm audit, govulncheck, license scanning, supply-chain risks

## Paired Agents

- `security-audit` — primary agent for security reviews
- `architecture` — auth boundary design, structural security
- `solutions-engineer` — implementing security fixes
- `ai-engineer` — prompt injection, AI endpoint security
