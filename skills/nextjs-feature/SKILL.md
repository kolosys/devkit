---
name: nextjs-feature
description: Implements Next.js 16+ features following route-as-module architecture, Server Actions, and design-system conventions. Use when building pages, routes, actions, queries, or App Router features.
metadata:
  pathPatterns:
    - "src/app/**/page.tsx"
    - "src/app/**/actions.ts"
    - "src/app/**/queries.ts"
    - "src/app/**/schemas.ts"
    - "src/app/**/layout.tsx"
    - "src/app/**/loading.tsx"
    - "src/app/**/error.tsx"
  importPatterns:
    - "next/cache"
    - "next/image"
    - "next/font"
    - "next/navigation"
  bashPatterns:
    - "\\bnext\\s+build\\b"
    - "\\bnext\\s+dev\\b"
  promptSignals:
    phrases:
      - "next.js feature"
      - "server action"
      - "route module"
      - "app router"
chainTo:
  - pattern: "design-system|@/design-system"
    targetSkill: design-system
    message: "Design system imports detected — loading design-system guidance."
  - pattern: "opengraph-image|sitemap|robots|llms.txt"
    targetSkill: seo-geo
    message: "SEO metadata detected — loading SEO/GEO guidance."
---

# Next.js Feature Development

TRIGGER when: building pages, routes, actions, queries, or any App Router feature in a Next.js 16+ project.
DO NOT TRIGGER when: working on Go code, design-system internals, or pure utility/lib code.

## Before Writing Code

1. Read bundled docs: `node_modules/next/dist/docs/` for installed version.
2. Apply `nextjs.mdc` for structure, routing, caching, and Server Actions (rules win over doc examples on layout).

## Feature Module Template

```
src/app/<route>/
├── page.tsx          # async Server Component
├── actions.ts        # 'use server'
├── queries.ts        # cache()-wrapped loaders
├── schemas.ts        # Zod inputs
├── components/       # route-scoped UI
└── opengraph-image.tsx
```

## Implementation Steps

1. **Data** — `queries.ts` with `cache()` for shared loaders.
2. **Mutations** — `actions.ts` with auth, Zod validation, `updateTag`/`revalidateTag`.
3. **UI** — Server `page.tsx` fetches; client islands in `components/` for interactivity.
4. **Metadata** — `generateMetadata` sharing cached query with page.
5. **Verify** — `next build`, `tsc --noEmit`, verification checklist in `nextjs.mdc`.

## References

- [Server Actions](references/server-actions.md) — auth, validation, revalidation patterns
- [Caching](references/caching.md) — cache profiles, invalidation, component caching

## Code Craft

- Thin `page.tsx` files — data fetch + compose components; no logic soup.
- Infer types from Zod; use `import type`; destructure params early.
- `??` and `?.` over verbose null checks; early returns over deep nesting.
- Comments only for non-obvious cache/auth/serialization decisions.
- No internal `fetch('/api/...')` — import actions/queries directly.

## Decision Matrix

| Caller | Use |
|--------|-----|
| Server Component read | Direct `queries.ts` call |
| Client Component read/mutate | Server Action in `actions.ts` |
| External webhook/API | `app/api/*/route.ts` |

## Paired Agents

- `solutions-engineer` — primary implementor
- `architecture` — structure questions, caching strategy
- `performance-engineer` — page load, bundle, streaming
- `design` — UI components + `design-system` skill
