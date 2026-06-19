---
name: go-library
description: Guides creation and maintenance of high-performance Go open source libraries with minimal dependencies. Use when building Go packages, APIs, tests, benchmarks, or reviewing Go library code.
metadata:
  pathPatterns:
    - "**/*.go"
    - "**/go.mod"
    - "**/go.sum"
  bashPatterns:
    - "\\bgo\\s+(build|test|vet|run)\\b"
    - "\\bgolangci-lint\\b"
  promptSignals:
    phrases:
      - "go library"
      - "go package"
      - "options pattern"
      - "context.Context"
      - "sentinel error"
---

# Go Library Development

TRIGGER when: building Go packages, writing tests/benchmarks, reviewing Go library code, or designing Go APIs.
DO NOT TRIGGER when: working on Next.js routes, design-system components, or content/marketing.

## Quick Start

1. Read `go-standards.mdc` rule — all code must comply.
2. Define the public surface minimally (small interfaces, options pattern).
3. Implement with `internal/` for private code.
4. Write table-driven tests in `package_test` with `-race`.
5. Add benchmarks for hot paths.
6. Verify: `go test -race ./...`, `go vet ./...`, coverage threshold.

## References

- [Options Pattern](references/options-pattern.md) — structural options with validation
- [Testing Patterns](references/testing-patterns.md) — table-driven tests, benchmarks, fuzzing

## Package Checklist

- [ ] `context.Context` on all blocking operations
- [ ] Sentinel errors defined and documented
- [ ] Structural options for configuration
- [ ] `sync.RWMutex` / atomics where concurrent
- [ ] `sync.Once` for close
- [ ] Godoc on all exported symbols
- [ ] Examples in `examples/` if API is non-trivial

## API Review Questions

- Can a consumer misuse this API without an error?
- Is the zero value useful or explicitly invalid?
- Are interfaces ≤3 methods?
- Does every goroutine respect context cancellation?
- Is the code concise without being cryptic?

## Paired Agents

- `solutions-engineer` — primary implementor
- `architecture` — package layout, interface boundaries
- `performance-engineer` — benchmarks, pprof, allocation analysis
- `explore-research` — prior art, library comparisons
