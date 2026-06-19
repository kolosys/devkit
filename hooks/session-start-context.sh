#!/usr/bin/env bash
# Detects project stack and injects contextual guidance at session start.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo '{ "additional_context": "Kolosys DevKit active. (jq not found — install jq for full hook support)" }'
  exit 0
fi

input=$(cat)

has_go=false
has_next=false
has_design_system=false
is_greenfield=true

if [[ -f "go.mod" ]]; then
  has_go=true
  is_greenfield=false
fi

if [[ -f "package.json" ]] && grep -q '"next"' package.json 2>/dev/null; then
  has_next=true
  is_greenfield=false
fi

if [[ -d "src/design-system" ]]; then
  has_design_system=true
fi

# Build context message based on detected stack
ctx="Kolosys DevKit active."

if $is_greenfield; then
  ctx="$ctx Greenfield project detected. Try \`kolosys:scaffold-route\` or \`kolosys:scaffold-go-lib\` to get started."
else
  if $has_go; then
    ctx="$ctx Go project detected (go.mod). Rules: go-standards.mdc. Skills: go-library. Agents: solutions-engineer, architecture, performance-engineer."
  fi
  if $has_next; then
    ctx="$ctx Next.js project detected. Rules: nextjs.mdc, typescript-standards.mdc. Skills: nextjs-feature, seo-geo. Agents: solutions-engineer, design, content, marketing."
    if $has_design_system; then
      ctx="$ctx Design system found (src/design-system/). Rule: design-system.mdc. Skill: design-system."
    fi
  fi
fi

if $has_next; then
  ctx="$ctx Read node_modules/next/dist/docs/ for Next.js API details. Structure rules override doc file paths."
fi
ctx="$ctx Delegate multi-domain work to orchestrator agent."
ctx="$ctx Commands: kolosys:scaffold-route, kolosys:scaffold-go-lib, kolosys:scaffold-ai-feature, kolosys:verify, kolosys:launch-page, kolosys:perf-audit."

jq -n --arg ctx "$ctx" '{ "additional_context": $ctx }'
