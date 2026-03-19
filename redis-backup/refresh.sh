#!/bin/bash
# Refresh local backup files from Redis
# Run this after updating AI Strategy or Execution Protocol in Outline
DIR="$(cd "$(dirname "$0")" && pwd)"

redis-cli GET ai:strategy > "$DIR/ai-strategy.md"
redis-cli GET ai:execution-protocol > "$DIR/ai-execution-protocol.md"
redis-cli GET ai:templates:index > "$DIR/ai-templates-index.md"
redis-cli GET ai:workflow-guide > "$DIR/ai-workflow-guide.md"
cp ~/.config/opencode/oh-my-opencode-slim.json "$DIR/ai-agent-config.json"

echo "✅ Backup refreshed:"
ls -la "$DIR"/*.md "$DIR"/*.json
