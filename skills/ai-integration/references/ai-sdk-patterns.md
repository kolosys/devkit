---
title: AI SDK Patterns (v6)
description: generateText, streamText, useChat, ToolLoopAgent, structured output with Output.object(), and chat transport patterns for AI SDK v6.
---

# AI SDK Patterns (v6)

## Text Generation

```ts
import { generateText } from 'ai'

const { text } = await generateText({
  model: 'anthropic/claude-sonnet-4.6',
  prompt: 'Summarize this document',
  maxOutputTokens: 1024,
})
```

## Streaming

```ts
import { streamText } from 'ai'

const result = streamText({
  model: 'openai/gpt-5.4',
  prompt: userInput,
})

return result.toUIMessageStreamResponse()
```

## Structured Output

```ts
import { generateText, Output } from 'ai'
import { z } from 'zod'

const result = await generateText({
  model: 'anthropic/claude-sonnet-4.6',
  output: Output.object({
    schema: z.object({
      title: z.string(),
      tags: z.array(z.string()),
      sentiment: z.enum(['positive', 'negative', 'neutral']),
    }),
  }),
  prompt: 'Analyze this article...',
})

const data = result.output
```

## useChat (Client)

```tsx
'use client'

import { useChat } from '@ai-sdk/react'
import { DefaultChatTransport } from 'ai'
import { useState } from 'react'

export function Chat() {
  const [input, setInput] = useState('')
  const { messages, sendMessage, status } = useChat({
    transport: new DefaultChatTransport({ api: '/api/chat' }),
  })

  return (
    <div>
      {messages.map(msg => (
        <div key={msg.id}>
          {msg.parts.map((part, i) => {
            if (part.type === 'text') return <p key={i}>{part.text}</p>
            return null
          })}
        </div>
      ))}
      <form onSubmit={e => { e.preventDefault(); sendMessage({ text: input }); setInput('') }}>
        <input value={input} onChange={e => setInput(e.target.value)} />
        <button disabled={status === 'streaming'}>Send</button>
      </form>
    </div>
  )
}
```

## Tool Definition

```ts
import { tool } from 'ai'
import { z } from 'zod'

export const searchTool = tool({
  description: 'Search the knowledge base',
  inputSchema: z.object({
    query: z.string().describe('Search query'),
    limit: z.number().optional().default(5),
  }),
  execute: async ({ query, limit }) => {
    const results = await db.search(query, limit)
    return { results }
  },
})
```

## Agent (ToolLoopAgent)

```ts
import { ToolLoopAgent, InferAgentUIMessage, stepCountIs } from 'ai'
import { searchTool } from '../tools/search-tool'

export const researchAgent = new ToolLoopAgent({
  model: 'anthropic/claude-sonnet-4.6',
  instructions: 'You are a research assistant. Search for information and synthesize answers.',
  tools: { search: searchTool },
  stopWhen: stepCountIs(10),
})

export type ResearchAgentMessage = InferAgentUIMessage<typeof researchAgent>
```

## Consuming Agent in Route Handler

```ts
import { createAgentUIStreamResponse } from 'ai'
import { researchAgent } from '@/lib/agents/research-agent'

export async function POST(req: Request) {
  const { uiMessages } = await req.json()
  return createAgentUIStreamResponse({
    agent: researchAgent,
    uiMessages,
  })
}
```

## Key v6 Migration Notes

| v5 | v6 |
|----|-----|
| `generateObject()` | `generateText({ output: Output.object({ schema }) })` |
| `streamObject()` | `streamText({ output: Output.object({ schema }) })` |
| `maxSteps` | `stopWhen: stepCountIs(N)` |
| `parameters` (tool) | `inputSchema` |
| `CoreMessage` | `ModelMessage` |
| `handleSubmit` | `sendMessage({ text })` |
| `toDataStreamResponse` | `toUIMessageStreamResponse` |
| `message.content` | `message.parts` |
| `tool-invocation` | `tool-<toolName>` |
| `isLoading` | `status === "streaming"` |
