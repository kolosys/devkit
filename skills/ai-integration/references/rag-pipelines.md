---
title: RAG Pipeline Patterns
description: Document chunking, embedding generation, vector store integration, similarity search, and retrieval-augmented generation workflows.
---

# RAG Pipeline Patterns

## Architecture

```
Ingest: Documents → Chunk → Embed → Vector Store
Query:  User Input → Embed → Vector Search → Rerank (optional) → Context + Prompt → Generate
```

## Chunking Strategies

| Strategy | When | Size |
|----------|------|------|
| Fixed-size | General purpose | 512-1024 tokens |
| Paragraph/section | Structured docs | Natural boundaries |
| Recursive | Mixed content | Split on headers, then paragraphs, then sentences |
| Sliding window | Dense technical content | 512 tokens, 128 overlap |

Keep chunks small enough for precise retrieval but large enough for coherent context.

## Embedding Generation (AI SDK)

```ts
import { embedMany, embed } from 'ai'

// Batch embed for ingestion
const { embeddings } = await embedMany({
  model: embeddingModel,
  values: chunks.map(c => c.text),
})

// Single embed for query
const { embedding } = await embed({
  model: embeddingModel,
  value: userQuery,
})
```

## Embedding Generation (Go)

```go
func (s *EmbeddingService) EmbedBatch(ctx context.Context, texts []string) ([][]float32, error) {
    resp, err := s.client.Embeddings.New(ctx, openai.EmbeddingNewParams{
        Model: "text-embedding-3-small",
        Input: openai.EmbeddingNewParamsInputUnion(
            openai.EmbeddingNewParamsInputArrayOfStrings(texts),
        ),
    })
    if err != nil {
        return nil, fmt.Errorf("embed batch: %w", err)
    }
    embeddings := make([][]float32, len(resp.Data))
    for i, d := range resp.Data {
        embeddings[i] = d.Embedding
    }
    return embeddings, nil
}
```

## Vector Store — pgvector

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content TEXT NOT NULL,
  embedding vector(1536),
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

```ts
// Query similar documents
const results = await db.query(`
  SELECT id, content, metadata,
         1 - (embedding <=> $1::vector) as similarity
  FROM documents
  ORDER BY embedding <=> $1::vector
  LIMIT $2
`, [queryEmbedding, limit])
```

## RAG Generation

```ts
import { generateText } from 'ai'

const context = retrievedChunks.map(c => c.content).join('\n\n')

const { text } = await generateText({
  model: 'anthropic/claude-sonnet-4.6',
  system: `Answer based on the provided context. If the context doesn't contain the answer, say so.`,
  prompt: `Context:\n${context}\n\nQuestion: ${userQuery}`,
  maxOutputTokens: 1024,
})
```

## Hybrid Search

Combine vector similarity with keyword search for better recall:

```sql
SELECT id, content,
       (0.7 * (1 - (embedding <=> $1::vector))) +
       (0.3 * ts_rank(to_tsvector('english', content), plainto_tsquery('english', $2))) as score
FROM documents
WHERE to_tsvector('english', content) @@ plainto_tsquery('english', $2)
   OR (embedding <=> $1::vector) < 0.5
ORDER BY score DESC
LIMIT $3
```

## Cache Embeddings

- Cache embedding results for identical inputs — embeddings are deterministic.
- Use content hash as cache key.
- Set TTL if source documents change frequently.
- In Next.js, use `"use cache"` on embedding functions for static content.
