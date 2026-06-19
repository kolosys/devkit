---
name: kolosys:scaffold-route
description: Generate a complete Next.js 16+ route module with page, actions, queries, schemas, components, loading, and error files.
argument-hint: route-path (e.g. "dashboard/settings")
---

# Scaffold Next.js Route

## Preflight

1. Confirm the project has `next` in `package.json`.
2. Verify `src/app/` exists.
3. Check the target path doesn't already exist.

## Plan

Generate a route-as-feature-module at `src/app/<route>/` following `nextjs.mdc`:

```
src/app/<route>/
├── page.tsx              # async Server Component
├── actions.ts            # 'use server' — auth + Zod-validated mutations
├── queries.ts            # cache()-wrapped server-only loaders
├── schemas.ts            # Zod input schemas with inferred types
├── components/           # route-scoped client islands
│   └── .gitkeep
├── loading.tsx           # Suspense fallback
└── error.tsx             # Client Component error boundary
```

## Execute

For each file:

- **`page.tsx`** — async Server Component that imports from `queries.ts`, composes components, exports `generateMetadata` sharing the cached query.
- **`actions.ts`** — `"use server"` at top; stub action with auth check, Zod validation, and `updateTag` revalidation.
- **`queries.ts`** — `cache()`-wrapped loader function returning typed data.
- **`schemas.ts`** — Zod schema with `z.infer<>` type export.
- **`components/`** — empty directory with `.gitkeep`.
- **`loading.tsx`** — minimal skeleton/spinner Server Component.
- **`error.tsx`** — `"use client"` error boundary with `unstable_retry`.

## Verify

- [ ] `tsc --noEmit` passes
- [ ] `next build` succeeds
- [ ] No forbidden patterns from `nextjs.mdc`
- [ ] Route is colocated — all files in one directory
- [ ] No `fetch('/api/...')` — uses direct query/action imports

## Summary

Report created files and suggest next steps (add real data loader, wire UI components, add `opengraph-image.tsx`).
