#!/usr/bin/env bash
# Reminds orchestrator context when subagents launch.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo '{ "additional_context": "Kolosys DevKit subagent active. (jq not found — install jq for full hook support)" }'
  exit 0
fi

input=$(cat)
subagent_type=$(echo "$input" | jq -r '.subagent_type // .agent // empty')

context="Kolosys DevKit subagent active."

case "$subagent_type" in
  explore|explore-research)
    context="Read-only exploration. Do not edit files. Hand off to architecture or solutions-engineer for implementation."
    ;;
  orchestrator)
    context="Coordinate specialists. Architecture before implementation, design before UI, content+marketing in parallel after structure settles."
    ;;
  architecture)
    context="Focus on structure and boundaries. Rules win over doc examples for folder layout."
    ;;
  solutions-engineer)
    context="Minimal diff. Performant and readable code — idiomatic shorthand, comments only when necessary. Route-colocated modules. Server Actions over internal APIs."
    ;;
  design)
    context="Design-system primitives only. Max 4 inline Tailwind utilities. Theme tokens in variants.ts."
    ;;
  content)
    context="Clear, direct, technically accurate copy. Verify code examples compile. Pair with marketing for metadata."
    ;;
  marketing)
    context="SEO metadata, sitemaps, robots, llms.txt, social cards. Coordinate with content for prose."
    ;;
  performance-engineer)
    context="Measure first. Caching and bundle boundaries before micro-optimizations. AI cost/latency is a performance domain."
    ;;
  ai-engineer)
    context="AI feature specialist. Provider abstraction, streaming-first, budget guards, mock in tests. Apply ai.mdc rule."
    ;;
  security-audit)
    context="Auth boundaries, input validation, dependency risks, CSP, secrets. Check Server Actions and Route Handlers for auth. Never commit secrets."
    ;;
esac

jq -n --arg ctx "$context" '{ "additional_context": $ctx }'
