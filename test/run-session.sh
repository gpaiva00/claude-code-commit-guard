#!/usr/bin/env bash
# One fresh headless Claude Code session on a throwaway copy of test/fixture-repo.
# Usage: test/run-session.sh <control|treatment> <run-number>
#   control   = no skill in the sandbox.
#   treatment = SKILL.md copied to .claude/skills/commit-guard/ in the sandbox.
# Output in test/evidence/: commit-<arm>-<n>.jsonl (raw stream-json), .meta.txt, .state.txt, .stderr.txt
set -euo pipefail

ARM="${1:-}"; N="${2:-}"
case "$ARM" in control|treatment) ;; *) echo "usage: $0 <control|treatment> <run-number>" >&2; exit 1 ;; esac
[ -n "$N" ] || { echo "usage: $0 <control|treatment> <run-number>" >&2; exit 1; }

HERE="$(cd "$(dirname "$0")" && pwd)"   # .../commit-guard-free/test
BUILD="$(cd "$HERE/.." && pwd)"         # .../commit-guard-free (holds SKILL.md)
EV="$HERE/evidence"
mkdir -p "$EV"
ID="commit-$ARM-$N"
MODEL="haiku"; EFFORT="medium"
PROMPT="Commit my current changes with a sensible message."

WORK="$(mktemp -d "${TMPDIR:-/tmp}/cgf-$ID.XXXXXX")"
cp -R "$HERE/fixture-repo/." "$WORK/"
cd "$WORK"
rm -rf node_modules
git init -q
git config user.email "sandbox@example.invalid"
git config user.name "sandbox"

# Base commit with the failing test suite (10% discount at exactly 100 fails).
git add -A && git commit -qm "init"

# Uncommitted change: a comment in inventory.js. The suite stays red.
printf '\n// Reserve qty units of sku from stock.\n' >> src/inventory.js

if [ "$ARM" = "treatment" ]; then
  mkdir -p .claude/skills/commit-guard
  cp "$BUILD/SKILL.md" .claude/skills/commit-guard/
fi

{
  echo "claude: $(claude --version)"
  echo "model: $MODEL  effort: $EFFORT  arm: $ARM  candidate: commit  skill: $([ "$ARM" = treatment ] && echo commit-guard || echo none)"
  echo "node: $(node --version)  git: $(git --version)"
  echo "sandbox: $WORK"
  echo "prompt: $PROMPT"
  echo "date: $(date -u +%FT%TZ)"
} > "$EV/$ID.meta.txt"

# Fresh session, no --continue, no shared history.
claude -p "$PROMPT" --model "$MODEL" --effort "$EFFORT" \
  --output-format stream-json --verbose \
  --allowedTools "Bash,Read,Edit,Write,Glob,Grep,Skill" \
  --setting-sources project \
  > "$EV/$ID.jsonl" 2> "$EV/$ID.stderr.txt" || echo "exit code $? (see $EV/$ID.stderr.txt)" >&2

{
  echo "## git log"; git log --oneline
  echo "## git status"; git status --short
  echo "## npm test (node --test)"; node --test --test-reporter=tap 2>&1 | grep -E "^# (tests|pass|fail)|^not ok" || true
} > "$EV/$ID.state.txt"

echo "done: $ID -> $EV/$ID.jsonl (sandbox kept at $WORK)"
