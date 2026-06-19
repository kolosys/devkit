---
name: ai-integration
description: Guides AI feature development across AI SDK, raw LLM APIs, RAG, MCP, and Go-side AI. Covers architecture, implementation, agent building, eval/testing, and cost optimization. Use when building any AI-powered feature.
metadata:
  pathPatterns:
    - "lib/ai/**"
    - "lib/agents/**"
    - "lib/tools/**"
    - "lib/embeddings/**"
    - "src/lib/ai/**"
    - "src/lib/agents/**"
    - "src/lib/tools/**"
    - "src/app/api/chat/**"
    - "internal/ai/**"
    - "**/mcp/**"
  importPatterns:
    - "ai"
    - "@ai-sdk/*"
    - "openai"
    - "@anthropic-ai/sdk"
    - "@google/generative-ai"
  bashPatterns:
    - "\\bnpm\\s+(install|i|add)\\s+[^\\n]*\\bai\\b"
    - "\\bpnpm\\s+(install|i|add)\\s+[^\\n]*\\bai\\b"
    - "\\bgo\\s+get\\s+.*openai"
  promptSignals:
    phrases:
      - "ai feature"
      - "llm"
      - "chatbot"
      - "rag"
      - "embeddings"
      - "tool calling"
      - "mcp server"
      - "agent"
      - "generate text"
      - "stream text"
chainTo:
  - pattern: "src/app/.*/page\\.tsx|actions\\.ts"
    targetSkill: nextjs-feature
    message: "Route module files detected — loading Next.js feature guidance."
  - pattern: "\\.go$|go\\.mod"
    targetSkill: go-library
    message: "Go files detected — loading Go library guidance."
---

# AI Integration

TRIGGER when: building AI-powered features — chat UIs, text generation, tool calling, agents, RAG pipelines, MCP servers/clients, embeddings, or Go-side LLM integration.
DO NOT TRIGGER when: working on pure UI components, content writing, SEO, or non-AI business logic.

## AI Pattern Selection

```
What does the AI feature need?
├─ Generate or transform text
│  ├─ One-shot (no conversation) → generateText / streamText
│  ├─ Structured output → generateText with Output.object() + Zod schema
│  └─ Chat conversation → useChat hook + Server Action or Route Handler
├─ Call external tools / APIs
│  ├─ Single tool call → generateText with tools parameter
│  ├─ Multi-step reasoning → ToolLoopAgent with stopWhen: stepCountIs(N)
│  └─ MCP server integration → @ai-sdk/mcp StreamableHTTPClientTransport
├─ RAG (retrieval-augmented generation)
│  ├─ Embed documents → embedMany with embedding model
│  ├─ Query similar → vector store (pgvector, Pinecone)
│  └─ Generate with context → generateText with retrieved chunks
├─ Multi-agent system
│  ├─ Shared state → parent agent delegates via tools
│  └─ Independent → separate agent instances with own tool sets
└─ Go-side AI
   ├─ LLM calls → provider interface with context + cancellation
   ├─ Embeddings → batch embed with connection pooling
   └─ Streaming → iter.Seq2 or channel-based response streaming
```

## Provider Selection

```
Which model?
├─ Speed + low cost → smaller/faster models (flash, haiku, mini)
├─ Maximum quality → flagship models (opus, gpt-5, pro)
├─ Code generation → code-optimized models
├─ Embeddings → text-embedding models (choose dimensions for storage budget)
└─ Production reliability → use gateway with fallback ordering
```

## References

- [AI SDK Patterns](references/ai-sdk-patterns.md) — generateText, streamText, useChat, agents, structured output
- [Raw LLM APIs](references/raw-llm-apis.md) — direct OpenAI/Anthropic/Google SDK usage in TS and Go
- [RAG Pipelines](references/rag-pipelines.md) — embeddings, chunking, vector stores, retrieval
- [MCP Patterns](references/mcp-patterns.md) — building and consuming MCP servers/tools
- [Go AI](references/go-ai.md) — LLM calls from Go, embedding pipelines, context-aware inference
- [Eval & Testing](references/eval-testing.md) — testing AI features, eval harnesses, mocking
- [Cost Optimization](references/cost-optimization.md) — model routing, caching, budgets, monitoring

## Paired Agents

- `ai-engineer` — primary agent for AI architecture and implementation
- `solutions-engineer` — non-AI parts of the feature
- `performance-engineer` — AI cost/latency optimization
- `architecture` — where AI code fits in the system
