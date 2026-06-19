---
title: Raw LLM API Patterns
description: Direct OpenAI, Anthropic, and Google SDK usage patterns in TypeScript and Go when AI SDK abstraction is not used.
---

# Raw LLM API Patterns

Use direct provider SDKs when you need provider-specific features not available through AI SDK, or when working in Go.

## When to Use Direct vs. Abstracted

| Scenario | Use |
|----------|-----|
| Standard text/chat generation | AI SDK (abstracted) |
| Structured output, tool calling | AI SDK (abstracted) |
| Provider-specific features (computer use, fine-tuned endpoints) | Direct SDK |
| Go services | Direct SDK with provider interface |
| Self-hosted models (Ollama, vLLM) | Direct SDK or HTTP client |

## TypeScript — OpenAI

```ts
import OpenAI from 'openai'

const client = new OpenAI() // reads OPENAI_API_KEY from env

const completion = await client.chat.completions.create({
  model: 'gpt-5.4',
  messages: [{ role: 'user', content: 'Hello' }],
  max_completion_tokens: 1024,
})
```

## TypeScript — Anthropic

```ts
import Anthropic from '@anthropic-ai/sdk'

const client = new Anthropic() // reads ANTHROPIC_API_KEY from env

const message = await client.messages.create({
  model: 'claude-sonnet-4-6-20260514',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello' }],
})
```

## Go — OpenAI

```go
import "github.com/openai/openai-go"

client := openai.NewClient()

resp, err := client.Chat.Completions.New(ctx, openai.ChatCompletionNewParams{
    Model: "gpt-5.4",
    Messages: []openai.ChatCompletionMessageParamUnion{
        openai.UserMessage("Hello"),
    },
    MaxCompletionTokens: openai.Int(1024),
})
if err != nil {
    return fmt.Errorf("generate: %w", err)
}
```

## Go — Provider Interface

Wrap provider-specific code behind an interface for testability and swappability:

```go
type GenerateRequest struct {
    Model       string
    Messages    []Message
    MaxTokens   int
    Temperature float64
}

type GenerateResponse struct {
    Content    string
    TokensUsed Usage
}

type LLMProvider interface {
    Generate(ctx context.Context, req GenerateRequest) (GenerateResponse, error)
}
```

## Streaming (Go)

```go
stream, err := client.Chat.Completions.NewStreaming(ctx, params)
if err != nil {
    return fmt.Errorf("stream: %w", err)
}
defer stream.Close()

for chunk, err := range stream {
    if err != nil {
        return fmt.Errorf("read chunk: %w", err)
    }
    if len(chunk.Choices) > 0 && chunk.Choices[0].Delta.Content != "" {
        fmt.Fprint(w, chunk.Choices[0].Delta.Content)
    }
}
```

## Error Handling

All direct SDK calls should:
1. Set context timeout: `ctx, cancel := context.WithTimeout(ctx, 30*time.Second)`
2. Check for rate limit errors (HTTP 429) and retry with backoff
3. Wrap errors with operation context
4. Log token usage for cost tracking (never log prompt content in production)
