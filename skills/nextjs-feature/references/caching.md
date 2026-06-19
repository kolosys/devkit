---
title: Caching Patterns
description: Next.js 16+ caching hierarchy, cache profiles, invalidation strategies, and component caching with "use cache" directive.
---

# Caching Patterns

## Cache Hierarchy

1. **`"use cache"` + `cacheLife`** — preferred v16 approach. File, component, or function scoped. Requires `cacheComponents: true` in `next.config.ts`.
2. **`fetch` options** — `cache: 'force-cache'`, `next: { revalidate, tags }`, `cache: 'no-store'`.
3. **React `cache()`** — request-scoped memoization for DB/ORM calls. Deduplicates calls within a single request.

## cache() for Shared Loaders

Share a loader between `page.tsx` and `generateMetadata` so the query runs once:

```ts
// queries.ts
import { cache } from 'react'
import { db } from '@/lib/db'

export const getPost = cache(async (slug: string) => {
  return db.posts.findUnique({ where: { slug } })
})
```

```tsx
// page.tsx
import { getPost } from './queries'

export async function generateMetadata({ params }: Props) {
  const { slug } = await params
  const post = await getPost(slug)
  return { title: post?.title }
}

export default async function Page({ params }: Props) {
  const { slug } = await params
  const post = await getPost(slug)
  // ...
}
```

## "use cache" Component Caching

```tsx
'use cache'

import { cacheLife } from 'next/cache'

export async function StableContent() {
  cacheLife('hours')
  const data = await fetchStableData()
  return <div>{data.content}</div>
}
```

Profiles: `seconds` | `minutes` | `hours` | `days` | `weeks` | `max`

## Invalidation

| Method | Use case |
|--------|----------|
| `updateTag('tag')` | Read-your-writes in Server Actions |
| `revalidateTag('tag', 'seconds')` | SWR-style background refresh |
| `revalidatePath('/path')` | Full page revalidation |
| `refresh()` | Client-side uncached data refetch |

## Anti-patterns

- Double-caching: wrapping `cache()` around an already-cached `fetch()`.
- Mixing `revalidate` segment config with `"use cache"` on the same data.
- Missing cache directives after Next 14 -> 16 upgrade (silent API cost regression).
- Forgetting to invalidate after mutations.
