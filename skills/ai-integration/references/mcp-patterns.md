---
title: MCP Patterns
description: Building and consuming MCP servers and tools with StreamableHTTPClientTransport and AI SDK integration.
---

# MCP Patterns

## Building an MCP Server (TypeScript)

```ts
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js'
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js'
import { z } from 'zod'

const server = new McpServer({
  name: 'my-tools',
  version: '1.0.0',
})

server.tool(
  'search-docs',
  { query: z.string(), limit: z.number().optional().default(5) },
  async ({ query, limit }) => {
    const results = await searchDocuments(query, limit)
    return {
      content: [{ type: 'text', text: JSON.stringify(results) }],
    }
  }
)

server.resource('config', 'config://app', async () => ({
  contents: [{ uri: 'config://app', text: JSON.stringify(appConfig), mimeType: 'application/json' }],
}))
```

## Building an MCP Server (Go)

```go
import "github.com/mark3labs/mcp-go/server"

s := server.NewMCPServer("my-tools", "1.0.0")

s.AddTool(
    mcp.NewTool("search-docs",
        mcp.WithDescription("Search the documentation"),
        mcp.WithString("query", mcp.Required(), mcp.Description("Search query")),
        mcp.WithNumber("limit", mcp.Description("Max results")),
    ),
    func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
        query := req.Params.Arguments["query"].(string)
        results, err := searchDocs(ctx, query)
        if err != nil {
            return nil, fmt.Errorf("search: %w", err)
        }
        return mcp.NewToolResultText(results), nil
    },
)
```

## Consuming MCP Tools from AI SDK

```ts
import { StreamableHTTPClientTransport } from '@modelcontextprotocol/sdk/client/streamableHttp.js'
import { experimental_createMCPClient as createMCPClient } from 'ai'

const mcpClient = await createMCPClient({
  transport: new StreamableHTTPClientTransport(
    new URL('http://localhost:3001/mcp'),
  ),
})

const tools = await mcpClient.tools()

const { text } = await generateText({
  model: 'anthropic/claude-sonnet-4.6',
  tools,
  prompt: 'Search the docs for authentication setup',
  stopWhen: stepCountIs(5),
})

await mcpClient.close()
```

## Transport Options

| Transport | When |
|-----------|------|
| `StreamableHTTPServerTransport` | HTTP-based server, most common |
| `StdioServerTransport` | CLI tools, local development |
| `SSEServerTransport` | Legacy, prefer StreamableHTTP |

## MCP Server Deployment

- Deploy as a standalone service or embed in an existing API.
- Add auth middleware for production (API key, JWT, OIDC).
- Health check endpoint alongside MCP endpoint.
- Rate limit tool calls to prevent abuse.

## Best Practices

- Keep tools focused — one tool per action, clear input schemas.
- Return structured JSON in tool results for downstream parsing.
- Include error details in tool results (don't throw — return error content).
- Version your MCP server to avoid breaking client integrations.
- Test tools independently before exposing via MCP.
