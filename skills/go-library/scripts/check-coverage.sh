#!/usr/bin/env bash
# Checks Go test coverage against a threshold (default: 90%).
set -euo pipefail

THRESHOLD="${1:-90}"

go test -coverprofile=coverage.out ./...
COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | tr -d '%')

echo "Coverage: ${COVERAGE}% (threshold: ${THRESHOLD}%)"

if awk "BEGIN {exit !(${COVERAGE} < ${THRESHOLD})}"; then
  echo "FAIL: Coverage ${COVERAGE}% is below ${THRESHOLD}% threshold"
  exit 1
fi

echo "PASS: Coverage meets threshold"
rm -f coverage.out
