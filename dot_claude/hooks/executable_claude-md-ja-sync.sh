#!/usr/bin/env bash
# PostToolUse hook: when Claude edits CLAUDE.md, remind it to sync the Japanese translation.
set -euo pipefail

input="$(cat)"
file_path="$(jq -r '.tool_input.file_path // empty' <<<"$input")"

# Fast path: ignore every file not named CLAUDE.md before calling chezmoi.
case "$file_path" in
  */CLAUDE.md) ;;
  *) exit 0 ;;
esac

source_dir="$(chezmoi source-path 2>/dev/null || echo "$HOME/.local/share/chezmoi")"
case "$file_path" in
  "$HOME/.claude/CLAUDE.md" | "$source_dir/dot_claude/CLAUDE.md") ;;
  *) exit 0 ;;
esac

context="CLAUDE.md was modified (${file_path}). Before finishing, update the Japanese translation ~/.claude/CLAUDE.ja.md so it matches the English version section by section, then sync both files with the chezmoi source (chezmoi re-add ~/.claude/CLAUDE.md ~/.claude/CLAUDE.ja.md, or chezmoi apply if the source was edited)."

jq -n --arg ctx "$context" \
  '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
