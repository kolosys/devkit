---
title: Structural Options Pattern
description: Go functional options with config struct, validation, defaults, and idiomatic constructor patterns for library APIs.
---

# Structural Options Pattern

## Basic Pattern

```go
type config struct {
	timeout  time.Duration
	logger   *slog.Logger
	poolSize int
}

type Option func(*config)

func WithTimeout(d time.Duration) Option {
	return func(c *config) { c.timeout = d }
}

func WithLogger(l *slog.Logger) Option {
	return func(c *config) { c.logger = l }
}

func WithPoolSize(n int) Option {
	return func(c *config) { c.poolSize = n }
}
```

## Constructor

```go
func New(opts ...Option) (*Client, error) {
	cfg := config{
		timeout:  30 * time.Second,
		poolSize: 10,
	}
	for _, o := range opts {
		o(&cfg)
	}
	if cfg.poolSize < 1 {
		return nil, fmt.Errorf("pool size must be >= 1, got %d", cfg.poolSize)
	}
	return &Client{cfg: cfg}, nil
}
```

## Guidelines

- Defaults should produce a working instance — `New()` with no options should be valid.
- Validate in the constructor, not in each option.
- Options are `func(*config)` — not methods on a builder.
- Keep the config struct unexported; only expose `Option` + `With*` functions.
- Group related options (e.g. `WithTLS(cert, key string)` over separate `WithCert` / `WithKey`).

## Anti-patterns

- Builder pattern with method chaining — use functional options instead.
- Exported config struct — leaks implementation, creates backwards-compat burden.
- Options that can conflict silently — validate and return error from constructor.
