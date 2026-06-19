---
title: Go AI Patterns
description: LLM provider interfaces, context-aware inference, batch embedding pipelines, and streaming response patterns in Go.
---

# Go AI Patterns

## Provider Interface

Define a clean provider abstraction for testability:

```go
type Message struct {
    Role    string
    Content string
}

type GenerateRequest struct {
    Model       string
    Messages    []Message
    MaxTokens   int
    Temperature float64
    Tools       []ToolDef
}

type GenerateResponse struct {
    Content    string
    ToolCalls  []ToolCall
    Usage      Usage
}

type Usage struct {
    InputTokens  int
    OutputTokens int
}

type LLMProvider interface {
    Generate(ctx context.Context, req GenerateRequest) (GenerateResponse, error)
    Stream(ctx context.Context, req GenerateRequest) (iter.Seq2[Chunk, error])
}
```

## Context-Aware Inference

Always respect context cancellation in AI calls:

```go
func (s *Service) Summarize(ctx context.Context, doc string) (string, error) {
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()

    resp, err := s.provider.Generate(ctx, GenerateRequest{
        Model:     "gpt-5.4",
        Messages:  []Message{{Role: "user", Content: "Summarize: " + doc}},
        MaxTokens: 512,
    })
    if err != nil {
        return "", fmt.Errorf("summarize: %w", err)
    }
    return resp.Content, nil
}
```

## Streaming Responses

```go
func (s *Service) StreamAnswer(ctx context.Context, w io.Writer, question string) error {
    chunks, err := s.provider.Stream(ctx, GenerateRequest{
        Model:    "anthropic/claude-sonnet-4.6",
        Messages: []Message{{Role: "user", Content: question}},
    })

    for chunk, err := range chunks {
        if err != nil {
            return fmt.Errorf("stream chunk: %w", err)
        }
        fmt.Fprint(w, chunk.Text)
    }
    return nil
}
```

## Embedding Pipeline

```go
type EmbeddingService struct {
    client *openai.Client
    model  string
    dim    int
}

func NewEmbeddingService(opts ...EmbeddingOption) *EmbeddingService {
    cfg := embeddingConfig{
        model: "text-embedding-3-small",
        dim:   1536,
    }
    for _, o := range opts {
        o(&cfg)
    }
    return &EmbeddingService{
        client: openai.NewClient(),
        model:  cfg.model,
        dim:    cfg.dim,
    }
}

func (s *EmbeddingService) Embed(ctx context.Context, text string) ([]float32, error) {
    resp, err := s.client.Embeddings.New(ctx, openai.EmbeddingNewParams{
        Model: s.model,
        Input: openai.EmbeddingNewParamsInputUnion(
            openai.EmbeddingNewParamsInputArrayOfStrings([]string{text}),
        ),
    })
    if err != nil {
        return nil, fmt.Errorf("embed: %w", err)
    }
    return resp.Data[0].Embedding, nil
}
```

## Connection Pooling for High-Throughput

```go
type AIPool struct {
    provider LLMProvider
    sem      chan struct{}
}

func NewAIPool(provider LLMProvider, concurrency int) *AIPool {
    return &AIPool{
        provider: provider,
        sem:      make(chan struct{}, concurrency),
    }
}

func (p *AIPool) Generate(ctx context.Context, req GenerateRequest) (GenerateResponse, error) {
    select {
    case p.sem <- struct{}{}:
        defer func() { <-p.sem }()
    case <-ctx.Done():
        return GenerateResponse{}, ctx.Err()
    }
    return p.provider.Generate(ctx, req)
}
```

## Structured Output with Validation

```go
type ExtractedEntity struct {
    Name     string   `json:"name" validate:"required"`
    Category string   `json:"category" validate:"oneof=person org location"`
    Tags     []string `json:"tags"`
}

func (s *Service) Extract(ctx context.Context, text string) ([]ExtractedEntity, error) {
    resp, err := s.provider.Generate(ctx, GenerateRequest{
        Model: "gpt-5.4",
        Messages: []Message{{
            Role:    "user",
            Content: "Extract entities as JSON array: " + text,
        }},
        MaxTokens: 1024,
    })
    if err != nil {
        return nil, fmt.Errorf("extract: %w", err)
    }

    var entities []ExtractedEntity
    if err := json.Unmarshal([]byte(resp.Content), &entities); err != nil {
        return nil, fmt.Errorf("parse entities: %w", err)
    }
    return entities, nil
}
```

## Testing

Mock the provider interface in tests:

```go
type mockProvider struct {
    response GenerateResponse
    err      error
}

func (m *mockProvider) Generate(ctx context.Context, req GenerateRequest) (GenerateResponse, error) {
    return m.response, m.err
}

func TestSummarize(t *testing.T) {
    svc := NewService(&mockProvider{
        response: GenerateResponse{Content: "Summary of document."},
    })
    got, err := svc.Summarize(context.Background(), "long document text...")
    if err != nil {
        t.Fatal(err)
    }
    if got != "Summary of document." {
        t.Errorf("got %q, want summary", got)
    }
}
```
