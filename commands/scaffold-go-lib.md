---
name: kolosys:scaffold-go-lib
description: Generate a Go library skeleton with module, docs, options pattern, sentinel errors, tests, and benchmarks.
argument-hint: module-path (e.g. "github.com/kolosys/photon")
---

# Scaffold Go Library

## Preflight

1. Confirm Go is available (`go version`).
2. Verify the target directory is empty or doesn't exist.
3. Extract package name from the last segment of the module path.

## Plan

Generate a library skeleton following `go-standards.mdc`:

```
<pkg>/
├── go.mod
├── doc.go                # package-level godoc
├── <pkg>.go              # core types + constructor
├── options.go            # structural options pattern
├── errors.go             # sentinel errors
├── <pkg>_test.go         # table-driven tests (package <pkg>_test)
├── benchmark_test.go     # benchmarks for hot paths
└── internal/             # private implementation
```

## Execute

For each file:

- **`go.mod`** — module declaration with current Go version.
- **`doc.go`** — package comment with one-line description and usage example.
- **`<pkg>.go`** — primary exported type with constructor accepting `...Option`. Includes `context.Context` first param on blocking methods. `sync.RWMutex` for concurrent access. `sync.Once` for idempotent `Close()`.
- **`options.go`** — `Option` type with `func(cfg *config)` signature. 2-3 starter options (`WithTimeout`, `WithLogger`).
- **`errors.go`** — sentinel errors using `errors.New`. Error wrapping with `fmt.Errorf("op: %w", err)`.
- **`<pkg>_test.go`** — table-driven test with subtests, `t.Parallel()`, context cancellation test.
- **`benchmark_test.go`** — benchmark for constructor and primary operation.
- **`internal/`** — empty directory with placeholder.

## Verify

- [ ] `go build ./...` succeeds
- [ ] `go test -race ./...` passes
- [ ] `go vet ./...` clean
- [ ] All exported symbols have godoc
- [ ] Options pattern is functional (not builder)
- [ ] Context-first on blocking APIs

## Summary

Report created files, package name, and suggest next steps (implement core logic, add CI, write examples).
