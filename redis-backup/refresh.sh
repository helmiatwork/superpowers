#!/bin/bash
# Save current Redis state to repo files (source of truth)
# Run after: updating AI Strategy, Execution Protocol, or any AI doc
# Then: git add + commit + push to persist on GitHub

DIR="$(cd "$(dirname "$0")" && pwd)"

redis-cli GET ai:strategy > "$DIR/ai-strategy.md"
redis-cli GET ai:execution-protocol > "$DIR/ai-execution-protocol.md"
redis-cli GET ai:templates:index > "$DIR/ai-templates-index.md"
redis-cli GET ai:workflow-guide > "$DIR/ai-workflow-guide.md"
cp ~/.config/opencode/oh-my-opencode-slim.json "$DIR/ai-agent-config.json"

echo "✅ Repo files updated:"
for f in "$DIR"/*.md "$DIR"/*.json; do
  echo "  $(basename "$f") ($(wc -c < "$f" | tr -d ' ') bytes)"
done
echo ""
echo "Next: git add redis-backup/ && git commit && git push"
