---
name: kolosys:scaffold-ai-feature
description: Generate an AI feature scaffold — chat UI, tool-calling agent, RAG pipeline, or background agent with tests and provider config.
argument-hint: feature-type (chat | agent | rag | mcp-server)
---

# Scaffold AI Feature

## Preflight

1. Detect stack: Next.js (`package.json` with `next`) and/or Go (`go.mod`).
2. Check if `ai` package is installed (Next.js). If not, install it.
3. Determine feature type from argument.

## Plan

### Chat UI

```
lib/ai/provider.ts              # Provider config
lib/agents/<name>-agent.ts      # ToolLoopAgent definition + type export
lib/tools/                      # Tool definitions (if any)
src/app/<route>/actions.ts      # Server Action wrapping agent
src/app/<route>/components/
  chat.tsx                      # 'use client' with useChat
src/app/<route>/page.tsx        # Server Component rendering chat
```

### Tool-Calling Agent

```
lib/ai/provider.ts              # Provider config
lib/agents/<name>-agent.ts      # ToolLoopAgent with tools
lib/tools/<tool>-tool.ts        # Tool definitions with inputSchema
src/app/api/<name>/route.ts     # Route Handler (if external) or
src/app/<route>/actions.ts      # Server Action (if internal)
```

### RAG Pipeline

```
lib/ai/provider.ts              # Provider + embedding config
lib/embeddings/
  ingest.ts                     # Document chunking + embedding
  search.ts                     # Vector similarity search
src/app/<route>/actions.ts      # Server Action for RAG queries
src/app/<route>/page.tsx        # Search/chat UI
```

### MCP Server

```
lib/mcp/
  server.ts                     # MCP server definition
  tools/<tool>.ts               # Tool implementations
src/app/api/mcp/route.ts        # HTTP transport endpoint
```

## Execute

For each file:

- **Provider config** — model selection, gateway setup or direct provider.
- **Agent/tool definitions** — typed with Zod schemas, exported types for UI.
- **Server Action** — auth check, input validation, AI call with error handling and budget guard.
- **UI component** — `useChat` with `DefaultChatTransport`, status handling, part rendering.
- **Tests** — mock provider, test action with mocked LLM response, snapshot prompt.

## Verify

- [ ] `tsc --noEmit` passes
- [ ] `next build` succeeds (or `go build ./...`)
- [ ] Tests pass with mocked LLM
- [ ] `maxOutputTokens` set on all AI calls
- [ ] No API keys in source code
- [ ] Auth check in Server Actions / Route Handlers
- [ ] Error handling for rate limits and provider failures

## Summary

Report created files, installed packages, and suggest next steps (add tools, configure gateway, build eval harness).
