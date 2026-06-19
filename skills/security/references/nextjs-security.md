---
title: Next.js Security Patterns
description: CSP headers, auth patterns in Server Actions and Route Handlers, env variable exposure rules, cookie security, and rate limiting via proxy.ts for Next.js 16+ sites.
---

# Next.js Security Patterns

## CSP Headers

### Via next.config.ts

```ts
const cspHeader = `
  default-src 'self';
  script-src 'self' 'nonce-{{nonce}}';
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data:;
  font-src 'self';
  connect-src 'self';
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
`

export default {
  async headers() {
    return [{
      source: '/(.*)',
      headers: [{ key: 'Content-Security-Policy', value: cspHeader.replace(/\s+/g, ' ').trim() }],
    }]
  },
}
```

### Via proxy.ts (dynamic nonce)

```ts
import { NextResponse } from 'next/server'
import { randomBytes } from 'crypto'

export function proxyRequest(request: Request) {
  const nonce = randomBytes(16).toString('base64')
  const response = NextResponse.next()
  response.headers.set(
    'Content-Security-Policy',
    `default-src 'self'; script-src 'self' 'nonce-${nonce}'; style-src 'self' 'unsafe-inline';`
  )
  return response
}
```

### CSP Strictness Levels

| Level | script-src | When |
|-------|-----------|------|
| Strict | `'nonce-{n}'` | Production, security-critical |
| Moderate | `'self'` | Standard production |
| Permissive | `'self' 'unsafe-inline'` | Development only |

## Auth in Server Actions

Every Server Action is a public network boundary — always authenticate.

```ts
'use server'

import { getSession } from '@/lib/auth'

export async function updateProfile(input: z.infer<typeof UpdateProfileSchema>) {
  const session = await getSession()
  if (!session) return { ok: false as const, error: 'unauthorized' }

  const parsed = UpdateProfileSchema.safeParse(input)
  if (!parsed.success) return { ok: false as const, error: parsed.error.flatten() }

  // Only now proceed with the mutation
}
```

## Auth in Route Handlers

```ts
// Webhook — verify signature
export async function POST(request: Request) {
  const signature = request.headers.get('x-webhook-signature')
  if (!verifySignature(signature, await request.text())) {
    return Response.json({ error: 'invalid signature' }, { status: 401 })
  }
}

// Public API — verify API key
export async function GET(request: Request) {
  const key = request.headers.get('authorization')?.replace('Bearer ', '')
  if (!key || !await validateApiKey(key)) {
    return Response.json({ error: 'unauthorized' }, { status: 401 })
  }
}
```

## Environment Variable Exposure

| Prefix | Exposed to | Rule |
|--------|-----------|------|
| `NEXT_PUBLIC_*` | Client + Server | Only non-sensitive values (analytics ID, public API URL) |
| No prefix | Server only | All secrets, tokens, connection strings |

Red flags in `NEXT_PUBLIC_*`:
- API keys with write permissions
- Database connection strings
- JWT signing secrets
- Internal service URLs

## Cookie Security

```ts
import { cookies } from 'next/headers'

const cookieStore = await cookies()
cookieStore.set('session', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax',
  maxAge: 60 * 60 * 24 * 7,
  path: '/',
})
```

| Attribute | Minimum | Recommended |
|-----------|---------|-------------|
| HttpOnly | Required for session/auth | Always |
| Secure | Required in production | Always |
| SameSite | Lax | Strict for mutation cookies |
| Path | `/` | Narrowest needed scope |

## Rate Limiting in proxy.ts

```ts
import { NextResponse } from 'next/server'

const rateLimitMap = new Map<string, { count: number; reset: number }>()

export function proxyRequest(request: Request) {
  const ip = request.headers.get('x-forwarded-for') ?? 'unknown'
  const now = Date.now()
  const entry = rateLimitMap.get(ip)

  if (entry && entry.reset > now && entry.count >= 100) {
    return NextResponse.json({ error: 'rate limited' }, { status: 429 })
  }

  if (!entry || entry.reset <= now) {
    rateLimitMap.set(ip, { count: 1, reset: now + 60_000 })
  } else {
    entry.count++
  }

  return NextResponse.next()
}
```

For production, use a distributed store (Redis, Upstash) instead of in-memory maps.
