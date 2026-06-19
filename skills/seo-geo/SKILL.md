---
name: seo-geo
description: Configures SEO metadata, sitemaps, robots, llms.txt, and GEO discoverability for Next.js public sites. Use when optimizing search visibility, AI crawler policy, or launch metadata.
metadata:
  pathPatterns:
    - "src/app/sitemap.ts"
    - "src/app/robots.ts"
    - "src/app/**/opengraph-image.tsx"
    - "src/app/layout.tsx"
    - "public/llms.txt"
    - "public/llms-full.txt"
  importPatterns:
    - "next/og"
  promptSignals:
    phrases:
      - "seo"
      - "sitemap"
      - "robots.txt"
      - "llms.txt"
      - "og image"
      - "metadata"
      - "geo"
chainTo:
  - pattern: "generateMetadata|metadataBase"
    targetSkill: nextjs-feature
    message: "Next.js metadata API detected — loading route module guidance."
---

# SEO & GEO

TRIGGER when: configuring search metadata, sitemaps, robots policy, AI crawler settings, or social images.
DO NOT TRIGGER when: working on business logic, design-system internals, or Go code.

## Required Files

| File | Purpose |
|------|---------|
| `src/app/layout.tsx` | `metadataBase`, title template, OG defaults |
| `src/app/sitemap.ts` | All indexable URLs |
| `src/app/robots.ts` | Crawler + AI bot policy |
| `public/llms.txt` | GEO discovery allowlist |
| `src/app/<route>/opengraph-image.tsx` | Per-route social images |

## Root Metadata

```tsx
export const metadata: Metadata = {
  metadataBase: new URL('https://example.com'),
  title: { default: 'Project', template: '%s | Project' },
  description: '...',
  openGraph: { type: 'website', siteName: 'Project' },
  robots: { index: true, follow: true },
}
```

## AI Crawler Policy

Explicitly decide for each in `robots.ts`:

`GPTBot`, `Google-Extended`, `CCBot`, `ClaudeBot`, `PerplexityBot`, `Bytespider`

## llms.txt Template

```txt
# https://example.com/llms.txt
> One-line project description.

## Docs
- [Overview](https://example.com/docs)

## Policies
- Allow: citation with link
```

## Checklist

- [ ] `metadataBase` set
- [ ] Unique title + description per page
- [ ] Sitemap includes all public routes
- [ ] `llms.txt` synced with sitemap
- [ ] OG images <= 8MB (build fails otherwise)
- [ ] `proxy.ts` matcher excludes metadata routes

## Paired Agents

- `marketing` — primary agent for SEO/GEO strategy
- `content` — prose and long-form copy via `public-content` skill
- `design` — visual OG templates and social images
