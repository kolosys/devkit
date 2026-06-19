#!/usr/bin/env bash
# Guards destructive shell commands.
# NOTE: hooks.json `matcher` pre-filters — this script only runs on matched commands.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo '{ "permission": "ask", "user_message": "Destructive command detected but jq is not installed — please review manually." }'
  exit 0
fi

input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')

if [[ -z "$command" ]]; then
  echo '{ "permission": "allow" }'
  exit 0
fi

cat <<EOF
{
  "permission": "ask",
  "user_message": "This command is potentially destructive. Please review before continuing.",
  "agent_message": "Kolosys DevKit hook flagged a destructive shell command: ${command}"
}
EOF
