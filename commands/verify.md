---
name: kolosys:verify
description: Run full verification checklist across Go and Next.js — tests, build, types, lint, and architecture rule checks.
argument-hint: "[go|next|all] (default: auto-detect)"
---

# Verify Project

## Preflight

Detect the project stack:

- `go.mod` present → Go checks
- `package.json` with `next` dep → Next.js checks
- Both → run all checks
- Argument overrides auto-detection

## Plan

Run checks in dependency order — type errors block further checks.

### Go Checks

1. `go vet ./...`
2. `go build ./...`
3. `go test -race ./...`
4. Coverage: `go test -coverprofile=coverage.out ./...` — flag if below 90%
5. Lint: `golangci-lint run` (if available)

### Next.js Checks

1. `tsc --noEmit`
2. `next build`
3. Lint: `next lint` or `eslint .`
4. Architecture audit:
   - No `.tsx` files under `src/lib/`
   - No `src/features/`, `src/components/`, `src/styles/` directories
   - No `middleware.ts` (should be `proxy.ts`)
   - No `fetch('/api/...')` in components calling own API routes
   - Every `@slot` has `default.tsx`
   - `metadataBase` set in root layout

## Execute

Run each check sequentially. Stop on first hard failure (build/type errors). Collect warnings and audit findings for final report.

## Verify

The verification IS the task — no meta-verification needed.

## Summary

Report results as a checklist:

```
## Results
- [x] go vet — clean
- [x] go build — ok
- [x] go test -race — 47 passed, 0 failed
- [x] coverage — 94.2% (threshold: 90%)
- [ ] architecture — 1 issue: found .tsx in src/lib/utils/
```

Flag blockers vs warnings. Suggest fixes for any failures.
