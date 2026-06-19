---
title: Cost Optimization
description: Model routing by task complexity, embedding caching, token budget enforcement, gateway cost attribution, and usage monitoring.
---

# Cost Optimization

## Model Routing

Use cheaper models for simple tasks, expensive models for complex generation:

```
Incoming request
├─ Classification/routing → cheap model (haiku, flash, mini)
├─ Simple extraction → cheap model
├─ Complex generation → flagship model (sonnet, gpt-5.4)
├─ Code generation → code-optimized model
└─ Embeddings → embedding model (text-embedding-3-small for budget, large for precision)
```

### Implementation

```ts
function selectModel(task: 'classify' | 'extract' | 'generate' | 'code'): string {
  switch (task) {
    case 'classify': return 'anthropic/claude-haiku-4.5'
    case 'extract': return 'openai/gpt-5.2'
    case 'generate': return 'anthropic/claude-sonnet-4.6'
    case 'code': return 'openai/gpt-5.3-codex'
  }
}
```

## Caching Strategies

### Deterministic Queries

Cache responses for identical prompts on static/factual queries:

```ts
'use cache'
import { cacheLife } from 'next/cache'

export async function classifyIntent(text: string) {
  cacheLife('hours')
  const { output } = await generateText({
    model: 'anthropic/claude-haiku-4.5',
    output: Output.choice({ options: ['question', 'complaint', 'feedback'] as const }),
    prompt: text,
  })
  return output
}
```

### Embedding Cache

```ts
const embeddingCache = new Map<string, number[]>()

async function getEmbedding(text: string): Promise<number[]> {
  const key = createHash('sha256').update(text).digest('hex')
  if (embeddingCache.has(key)) return embeddingCache.get(key)!
  const { embedding } = await embed({ model: embeddingModel, value: text })
  embeddingCache.set(key, embedding)
  return embedding
}
```

### Do NOT Cache

- Conversational messages (context-dependent)
- User-specific generations
- Anything requiring real-time data

## Token Budgets

### Pre-flight Estimation

```ts
function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4)
}

async function generateWithBudget(prompt: string, maxInputTokens: number) {
  const estimated = estimateTokens(prompt)
  if (estimated > maxInputTokens) {
    throw new Error(`Input too large: ~${estimated} tokens exceeds ${maxInputTokens} limit`)
  }
  return generateText({ model: 'openai/gpt-5.4', prompt, maxOutputTokens: 1024 })
}
```

### Go Budget Guard

```go
func (s *Service) Generate(ctx context.Context, prompt string, budget int) (string, error) {
    estimated := len(prompt) / 4
    if estimated > budget {
        return "", fmt.Errorf("prompt too large: ~%d tokens exceeds %d budget", estimated, budget)
    }
    return s.provider.Generate(ctx, GenerateRequest{
        Model:     "gpt-5.4",
        Messages:  []Message{{Role: "user", Content: prompt}},
        MaxTokens: 1024,
    })
}
```

## Per-User Rate Limiting

```ts
const userTokens = new Map<string, { count: number; resetAt: number }>()
const DAILY_LIMIT = 100_000

function checkUserBudget(userId: string, estimatedTokens: number): boolean {
  const now = Date.now()
  const entry = userTokens.get(userId)
  if (!entry || entry.resetAt < now) {
    userTokens.set(userId, { count: estimatedTokens, resetAt: now + 86_400_000 })
    return true
  }
  if (entry.count + estimatedTokens > DAILY_LIMIT) return false
  entry.count += estimatedTokens
  return true
}
```

## Monitoring

Track and alert on:

| Metric | Alert threshold |
|--------|----------------|
| Daily token spend | > budget * 0.8 |
| Per-request token count | > expected * 2 |
| Error rate | > 5% |
| P95 latency | > acceptable SLA |
| Cache hit rate | < 50% (for cacheable queries) |

## Cost Reduction Checklist

- [ ] Cheap model for classification/routing, expensive for generation
- [ ] `maxOutputTokens` set on every call
- [ ] Embeddings cached by content hash
- [ ] Static/deterministic queries cached
- [ ] Per-user daily token limits enforced
- [ ] Token usage tracked per feature with tags
- [ ] Prompt length optimized (no redundant context)
- [ ] Batch operations where possible (embedMany over individual embed calls)
