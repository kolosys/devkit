#!/usr/bin/env bash
# Guards destructive shell commands via PreToolUse on Bash.
# Matcher in hooks.json limits this to the Bash tool; the script checks command content.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo '{ "decision": "block", "reason": "Destructive command detected but jq is not installed — please review manually." }'
  exit 0
fi

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // .command // empty')

if [[ -z "$command" ]]; then
  exit 0
fi

if echo "$command" | grep -qE 'git push.*--force|git push.*-f\b|git reset --hard|rm -rf /|rm -rf \*|drop database|DROP TABLE'; then
  cat <<EOF
{
  "decision": "block",
  "reason": "Kolosys DevKit flagged a destructive command: ${command}"
}
EOF
  exit 0
fi
