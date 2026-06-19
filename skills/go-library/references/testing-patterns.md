---
title: Testing Patterns
description: Table-driven tests, parallel subtests, context cancellation testing, benchmarks with benchstat, and fuzzing patterns for Go libraries.
---

# Testing Patterns

## Table-Driven Tests

```go
func TestParse(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		want    Result
		wantErr bool
	}{
		{name: "valid input", input: "hello", want: Result{Value: "hello"}},
		{name: "empty input", input: "", wantErr: true},
		{name: "special chars", input: "a&b", want: Result{Value: "a&b"}},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			got, err := Parse(tt.input)
			if (err != nil) != tt.wantErr {
				t.Fatalf("Parse(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
			}
			if !tt.wantErr && got != tt.want {
				t.Errorf("Parse(%q) = %v, want %v", tt.input, got, tt.want)
			}
		})
	}
}
```

## Context Cancellation Test

```go
func TestClientTimeout(t *testing.T) {
	t.Parallel()
	ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond)
	defer cancel()

	c, _ := New(WithTimeout(time.Hour))
	err := c.Do(ctx, "operation")
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Errorf("expected DeadlineExceeded, got %v", err)
	}
}
```

## Benchmarks

```go
func BenchmarkProcess(b *testing.B) {
	c, _ := New()
	ctx := context.Background()
	input := makeTestInput()

	b.ResetTimer()
	b.ReportAllocs()
	for b.Loop() {
		_ = c.Process(ctx, input)
	}
}
```

Run with: `go test -bench=. -benchmem -count=5 ./...`

Interpret:
- `0 allocs/op` in hot paths is the target.
- Compare runs with `benchstat` for statistical confidence.

## Fuzzing

```go
func FuzzParse(f *testing.F) {
	f.Add("hello")
	f.Add("")
	f.Add("special!@#")

	f.Fuzz(func(t *testing.T, input string) {
		_, err := Parse(input)
		if err != nil {
			return
		}
	})
}
```

Run with: `go test -fuzz=FuzzParse -fuzztime=30s`

## Test Organization

- Use `package pkg_test` for black-box tests (tests in same directory, different package).
- Use `t.Parallel()` on every test and subtest unless shared mutable state exists.
- Always run with `-race` flag.
- Mock external dependencies with interfaces, not concrete types.
