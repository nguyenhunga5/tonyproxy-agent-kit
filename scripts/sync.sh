#!/bin/sh
# Copies shared/SKILL.md into every pack; the only hand-edited guidance is shared/.
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/shared/SKILL.md"

{
  printf '%s\n' '---' 'name: tonyproxy' \
    'description: Use when the user asks about traffic TonyProxy captured — failing calls, slow endpoints, request diffs, cURL repros.' \
    '---' ''
  cat "$src"
} > "$root/claude/skills/tonyproxy/SKILL.md"

{
  printf '%s\n' '---' 'description: TonyProxy captured traffic via MCP' 'alwaysApply: false' 'globs:' '---' ''
  cat "$src"
} > "$root/cursor/rules/tonyproxy.mdc"

agents="$root/codex/AGENTS.md"
tmp="$agents.tmp"
awk -v src="$src" '
  /<!-- tonyproxy-skill:start -->/ { print; while ((getline line < src) > 0) print line; close(src); skip = 1; next }
  /<!-- tonyproxy-skill:end -->/ { skip = 0 }
  !skip { print }
' "$agents" > "$tmp"
mv "$tmp" "$agents"
