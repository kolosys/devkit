#!/usr/bin/env bash
# Validates Kolosys DevKit plugin structure and cross-references.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

red()   { printf '\033[0;31m%s\033[0m\n' "$1"; }
green() { printf '\033[0;32m%s\033[0m\n' "$1"; }
warn()  { printf '\033[0;33mWARN: %s\033[0m\n' "$1"; }
fail()  { red "FAIL: $1"; ERRORS=$((ERRORS + 1)); }
pass()  { green "PASS: $1"; }

echo "=== Kolosys DevKit Validator ==="
echo "Root: $PLUGIN_ROOT"
echo ""

# Check plugin.json exists
if [[ -f "$PLUGIN_ROOT/.cursor-plugin/plugin.json" ]]; then
  pass "plugin.json exists"
else
  fail "plugin.json not found at .cursor-plugin/plugin.json"
fi

# Check all agent files have name and description in frontmatter
echo ""
echo "--- Agents ---"
for f in "$PLUGIN_ROOT"/agents/*.md; do
  name=$(basename "$f" .md)
  if ! head -20 "$f" | grep -q '^name:'; then
    fail "Agent '$name' missing 'name:' in frontmatter"
  elif ! head -20 "$f" | grep -q '^description:'; then
    fail "Agent '$name' missing 'description:' in frontmatter"
  else
    pass "Agent '$name' has name + description"
  fi

  # Check agent references at least one skill
  if ! grep -qi 'skill' "$f"; then
    warn "Agent '$name' does not reference any skill"
  fi
done

# Check all skill files have name and description in frontmatter
echo ""
echo "--- Skills ---"
for f in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  skill_dir=$(basename "$(dirname "$f")")
  if ! head -20 "$f" | grep -q '^name:'; then
    fail "Skill '$skill_dir' missing 'name:' in frontmatter"
  elif ! head -20 "$f" | grep -q '^description:'; then
    fail "Skill '$skill_dir' missing 'description:' in frontmatter"
  else
    pass "Skill '$skill_dir' has name + description"
  fi
done

# Check all rule files have description in frontmatter
echo ""
echo "--- Rules ---"
for f in "$PLUGIN_ROOT"/rules/*.mdc; do
  name=$(basename "$f" .mdc)
  if ! head -10 "$f" | grep -q '^description:'; then
    fail "Rule '$name' missing 'description:' in frontmatter"
  else
    pass "Rule '$name' has description"
  fi
done

# Check all command files have name and description in frontmatter
echo ""
echo "--- Commands ---"
if [[ -d "$PLUGIN_ROOT/commands" ]]; then
  for f in "$PLUGIN_ROOT"/commands/*.md; do
    name=$(basename "$f" .md)
    if ! head -10 "$f" | grep -q '^name:'; then
      fail "Command '$name' missing 'name:' in frontmatter"
    elif ! head -10 "$f" | grep -q '^description:'; then
      fail "Command '$name' missing 'description:' in frontmatter"
    else
      pass "Command '$name' has name + description"
    fi
  done
else
  warn "No commands/ directory found"
fi

# Check hook scripts are executable
echo ""
echo "--- Hooks ---"
for f in "$PLUGIN_ROOT"/hooks/*.sh; do
  name=$(basename "$f")
  if [[ -x "$f" ]]; then
    pass "Hook '$name' is executable"
  else
    fail "Hook '$name' is NOT executable"
  fi
done

# Check hooks.json exists and is valid JSON
if [[ -f "$PLUGIN_ROOT/hooks/hooks.json" ]]; then
  if jq empty "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null; then
    pass "hooks.json is valid JSON"
  else
    fail "hooks.json is invalid JSON"
  fi
else
  fail "hooks.json not found"
fi

# Check for stale cross-references to deleted files
echo ""
echo "--- Cross-reference checks ---"

# Collect known skill names
known_skills=""
for d in "$PLUGIN_ROOT"/skills/*/; do
  known_skills="$known_skills $(basename "$d")"
done

# Collect known agent names
known_agents=""
for f in "$PLUGIN_ROOT"/agents/*.md; do
  known_agents="$known_agents $(basename "$f" .md)"
done

# Check for references to old deleted rule files
old_rules="nextjs-16-architecture.mdc nextjs-16-file-conventions.mdc nextjs-16.mdc server-actions-preferred.mdc tailwind.mdc component-reuse.mdc"
stale_found=false
for old in $old_rules; do
  matches=$(grep -rl "$old" "$PLUGIN_ROOT"/{agents,skills,rules,hooks,commands} 2>/dev/null || true)
  if [[ -n "$matches" ]]; then
    fail "Stale reference to deleted rule '$old' in: $matches"
    stale_found=true
  fi
done
if ! $stale_found; then
  pass "No stale references to deleted rule files"
fi

# Validate agent → skill references
agent_skill_ok=true
for f in "$PLUGIN_ROOT"/agents/*.md; do
  agent_name=$(basename "$f" .md)
  while IFS= read -r skill_ref; do
    skill_ref=$(echo "$skill_ref" | xargs)
    if [[ -z "$skill_ref" ]]; then continue; fi
    if ! echo "$known_skills" | grep -qw "$skill_ref"; then
      fail "Agent '$agent_name' references unknown skill '$skill_ref'"
      agent_skill_ok=false
    fi
  done < <(grep -oP '`\K[a-z][-a-z]*(?=`)' "$f" | while read -r ref; do
    for known in $known_skills; do
      if [[ "$ref" == "$known" ]]; then echo "$ref"; fi
    done
  done | sort -u)
done
if $agent_skill_ok; then
  pass "All agent skill references are valid"
fi

# Validate skill → agent references
skill_agent_ok=true
for f in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  skill_name=$(basename "$(dirname "$f")")
  in_paired=false
  while IFS= read -r line; do
    if echo "$line" | grep -q '## Paired Agents'; then
      in_paired=true
      continue
    fi
    if $in_paired && echo "$line" | grep -qP '^## '; then
      break
    fi
    if $in_paired; then
      agent_ref=$(echo "$line" | grep -oP '`\K[a-z][-a-z]*(?=`)' | head -1 || true)
      if [[ -n "$agent_ref" ]] && ! echo "$known_agents" | grep -qw "$agent_ref"; then
        fail "Skill '$skill_name' references unknown agent '$agent_ref'"
        skill_agent_ok=false
      fi
    fi
  done < "$f"
done
if $skill_agent_ok; then
  pass "All skill agent references are valid"
fi

# Check no file exceeds 500 lines
echo ""
echo "--- File size checks ---"
oversized=false
while IFS= read -r f; do
  [[ -f "$f" ]] || continue
  lines=$(wc -l < "$f")
  if [[ "$lines" -gt 500 ]]; then
    fail "$(basename "$f") has $lines lines (max 500)"
    oversized=true
  fi
done < <(find "$PLUGIN_ROOT" \( -path "*/agents/*" -o -path "*/skills/*" -o -path "*/rules/*" -o -path "*/commands/*" -o -path "*/hooks/*" \) \( -name "*.md" -o -name "*.mdc" -o -name "*.sh" -o -name "*.json" -o -name "*.ts" \) 2>/dev/null)
if ! $oversized; then
  pass "All files under 500 lines"
fi

# Summary
echo ""
echo "=== Summary ==="
if [[ "$ERRORS" -eq 0 ]]; then
  green "All checks passed!"
else
  red "$ERRORS error(s) found"
fi
exit "$ERRORS"
