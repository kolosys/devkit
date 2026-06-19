---
title: Server Action Patterns
description: Server Action auth, Zod validation, revalidation strategies, client consumption with useTransition, and discriminated union return types.
---

# Server Action Patterns

## File Convention

Colocate at `src/app/<route>/actions.ts`. Shared actions go to the common parent segment or `src/app/actions.ts` — never `src/lib/`.

```ts
'use server'

import { z } from 'zod'
import { updateTag } from 'next/cache'
import { getSession } from '@/lib/auth'
import { UpdateItemSchema } from './schemas'

export async function updateItem(input: z.infer<typeof UpdateItemSchema>) {
  const session = await getSession()
  if (!session) return { ok: false as const, error: 'unauthorized' }

  const parsed = UpdateItemSchema.safeParse(input)
  if (!parsed.success) return { ok: false as const, error: parsed.error.flatten() }

  const result = await db.items.update(parsed.data)
  updateTag('items')
  return { ok: true as const, data: result }
}
```

## Auth Pattern

Authenticate inside every action — Server Actions are a public network boundary.

```ts
const session = await getSession()
if (!session) return { ok: false as const, error: 'unauthorized' }
```

## Validation

Validate all input with Zod. Define schemas in `schemas.ts`, import into actions.

```ts
import { z } from 'zod'

export const CreatePostSchema = z.object({
  title: z.string().min(1).max(200),
  body: z.string().min(1),
  tags: z.array(z.string()).max(10).optional(),
})
```

## Revalidation Strategies

| Strategy | When | API |
|----------|------|-----|
| Read-your-writes | User sees own mutation immediately | `updateTag('tag')` |
| SWR | Background refresh for other users | `revalidateTag('tag', 'seconds')` |
| Full path | Revalidate entire page | `revalidatePath('/path')` |

Single-argument `revalidateTag` is deprecated — always pass a cache profile as the second argument.

## Client Consumption

Use `useTransition` for pending state — not manual loading booleans.

```tsx
'use client'

import { useTransition } from 'react'
import { updateItem } from './actions'

export function UpdateButton({ id }: { id: string }) {
  const [pending, start] = useTransition()

  return (
    <button
      disabled={pending}
      onClick={() => start(() => updateItem({ id, status: 'active' }))}
    >
      {pending ? 'Saving...' : 'Activate'}
    </button>
  )
}
```

## Return Types

Args and return values must be JSON-serializable. Use discriminated unions for type-safe error handling.

```ts
type ActionResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: string | z.typeToFlattenedError<any> }
```
