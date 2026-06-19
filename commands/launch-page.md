---
name: kolosys:launch-page
description: Orchestrate a complete public page launch — architecture, design, content, SEO metadata, and verification.
argument-hint: page-description (e.g. "pricing page for ion library")
---

# Launch Page

## Preflight

1. Confirm Next.js project with `src/app/` structure.
2. Identify target route path from the description.
3. Check if the route already exists.

## Plan

Coordinate specialists in dependency order:

1. **architecture** — determine route placement, data needs, caching strategy
2. **design** — component selection, layout, theme tokens, glass-morphism where appropriate
3. **solutions-engineer** — implement page, actions, queries, components
4. **content** — write copy, headings, CTAs, alt text
5. **marketing** — SEO metadata, OG image, sitemap entry, structured data, `llms.txt` update

## Execute

### Step 1: Architecture

- Place route at `src/app/<path>/`
- Define data sources (static, dynamic, cached)
- Identify shared components vs route-scoped
- Set caching profile (`"use cache"` + `cacheLife`)

### Step 2: Design

- Select primitives from `@/design-system`
- Define any new variants needed in `variants.ts`
- Ensure dark/light theme coverage
- Confirm responsive breakpoints

### Step 3: Implementation

- Scaffold route module (page, queries, schemas, components)
- Wire data loaders with `cache()`
- Build UI with design-system imports
- Add `loading.tsx` and `error.tsx`

### Step 4: Content

- Write page copy (title, description, body, CTAs)
- Alt text for images
- Suggested `title` and `description` metadata

### Step 5: SEO & Launch

- `generateMetadata` with unique title/description
- `opengraph-image.tsx` for social sharing
- Update `sitemap.ts` if not auto-discovered
- Update `llms.txt` if page is a key entry point
- Structured data (JSON-LD) if applicable

## Verify

- [ ] `next build` succeeds
- [ ] Page renders in both themes
- [ ] Metadata resolves to correct OG/canonical URLs
- [ ] Lighthouse performance score > 90
- [ ] No forbidden patterns from `nextjs.mdc`
- [ ] Content is accurate and code examples tested

## Summary

Deliverables checklist with files created/modified, metadata configured, and any remaining tasks (e.g. deploy preview, social image review).
