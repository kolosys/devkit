---
name: kolosys:perf-audit
description: Audit Core Web Vitals, bundle size, caching, and database queries. Produces a prioritized fix list.
argument-hint: "[url|route|service] (default: full project)"
---

# Performance Audit

## Preflight

Detect what to audit:

- URL provided → focus on that page's metrics
- Route path → audit that route's server + client code
- Service name → audit Go service performance
- No argument → full project scan

## Plan

### Next.js Audit

1. **Bundle analysis** — `next build` output, identify largest client chunks
2. **Client boundary audit** — find `"use client"` files, measure JS shipped per route
3. **Caching audit** — find uncached `fetch()` calls, missing `"use cache"` on stable reads
4. **Image audit** — `next/image` usage, missing `preload` on LCP images, oversized assets
5. **Font audit** — `next/font` usage, subset coverage, CLS impact
6. **Streaming audit** — slow server fetches without `<Suspense>` wrappers

### Go Audit

1. **Benchmark review** — run existing benchmarks, flag regressions or missing benchmarks on hot paths
2. **Allocation analysis** — `go test -bench=. -benchmem`, flag high-alloc operations
3. **Connection pooling** — check DB client config, context timeouts
4. **N+1 queries** — trace data access patterns in handlers
5. **pprof snapshot** — CPU + heap profiles if service is running

### Database Audit

1. **Slow queries** — `EXPLAIN ANALYZE` on flagged queries
2. **Missing indexes** — check covering indexes for common access patterns
3. **SELECT * usage** — flag and suggest column selection
4. **Pagination** — cursor-based vs OFFSET on large tables

## Execute

Run checks, collect metrics, and build a prioritized findings table.

## Verify

Re-measure after fixes to confirm improvement. No regressions on unrelated metrics.

## Summary

```
## Findings

| Priority | Category | Issue | Impact | Fix |
|----------|----------|-------|--------|-----|
| P0 | Bundle | 340KB client chunk from chart lib | +1.2s LCP | Dynamic import with ssr:false |
| P1 | Cache | 12 uncached fetch() calls | Unnecessary API costs | Add "use cache" + cacheLife |
| P2 | Image | Hero missing preload | Delayed LCP | Add preload to next/image |
```

Prioritize by impact x effort. Include before/after metrics where measured.
