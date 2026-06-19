---
title: Eval & Testing AI Features
description: Mocking LLM providers, snapshot testing prompts, building eval harnesses, and benchmarking AI feature quality and latency.
---

# Eval & Testing AI Features

## Unit Testing with Mocks

Never call real LLM APIs in CI. Mock at the provider boundary.

### TypeScript

```ts
import { vi } from 'vitest'

vi.mock('ai', async () => {
  const actual = await vi.importActual('ai')
  return {
    ...actual,
    generateText: vi.fn().mockResolvedValue({
      text: 'Mocked response',
      usage: { promptTokens: 10, completionTokens: 5 },
    }),
  }
})

test('summarize action returns text', async () => {
  const result = await summarize({ content: 'test input' })
  expect(result.ok).toBe(true)
  expect(result.data).toBe('Mocked response')
})
```

### Go

```go
func TestHandler(t *testing.T) {
    provider := &mockProvider{
        response: GenerateResponse{
            Content: "Test response",
            Usage:   Usage{InputTokens: 10, OutputTokens: 5},
        },
    }
    handler := NewHandler(provider)
    // test handler with mock provider
}
```

## Snapshot Testing Prompts

Catch unintended prompt changes that could alter model behavior:

```ts
test('system prompt matches snapshot', () => {
  const prompt = buildSystemPrompt({ context: 'test', role: 'assistant' })
  expect(prompt).toMatchSnapshot()
})
```

Update snapshots intentionally when prompt engineering changes are made.

## Eval Harness

For quality-critical AI features, build an evaluation pipeline:

```ts
interface EvalCase {
  input: string
  expectedOutput?: string
  criteria: EvalCriteria[]
}

interface EvalCriteria {
  name: string
  check: (output: string) => boolean | Promise<boolean>
}

async function runEval(cases: EvalCase[]): Promise<EvalReport> {
  const results = await Promise.all(
    cases.map(async (c) => {
      const { text, usage } = await generateText({
        model: 'anthropic/claude-sonnet-4.6',
        prompt: c.input,
      })
      const criteriaResults = await Promise.all(
        c.criteria.map(async (cr) => ({
          name: cr.name,
          passed: await cr.check(text),
        }))
      )
      return { input: c.input, output: text, usage, criteria: criteriaResults }
    })
  )
  return { results, passRate: calculatePassRate(results) }
}
```

## Common Eval Criteria

| Criteria | Check |
|----------|-------|
| Contains keyword | `output.includes('expected term')` |
| Valid JSON | `JSON.parse(output)` doesn't throw |
| Under token budget | `usage.completionTokens < maxTokens` |
| No hallucination | Output references only provided context |
| Matches regex | Pattern match for structured outputs |
| Sentiment correct | Classification matches expected label |

## Cost & Latency Benchmarks

Track per-feature AI costs over time:

```ts
interface AIMetrics {
  feature: string
  model: string
  inputTokens: number
  outputTokens: number
  latencyMs: number
  timestamp: Date
}

function trackAICall(feature: string, result: GenerateTextResult): AIMetrics {
  return {
    feature,
    model: result.model,
    inputTokens: result.usage.promptTokens,
    outputTokens: result.usage.completionTokens,
    latencyMs: result.latencyMs,
    timestamp: new Date(),
  }
}
```

## CI Integration

- Run prompt snapshot tests in CI — fail on unexpected changes.
- Run eval harness on schedule (not every PR) — AI outputs are non-deterministic.
- Mock all LLM calls in standard test suites.
- Track eval pass rates over time to catch model regression after provider updates.

## Testing Error Paths

Always test these scenarios:

- Provider returns 429 (rate limited) → verify retry/backoff
- Provider returns 503 (unavailable) → verify fallback/graceful degradation
- Malformed response (bad JSON) → verify parsing error handling
- Budget exceeded → verify budget guard rejects the call
- Context cancelled → verify clean shutdown without leaked goroutines
