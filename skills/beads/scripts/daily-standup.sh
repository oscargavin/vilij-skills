#!/bin/bash
# Generate a daily standup report from Beads issues

set -e

echo "======================================"
echo "       Daily Beads Standup"
echo "======================================"
echo ""

echo "📊 Overall Statistics"
echo "------------------------------"
bd stats
echo ""

echo "✅ Recently Closed (last 3)"
echo "------------------------------"
bd list --status closed --limit 3 --json | jq -r '.[] | "  [\(.id)] \(.title) (closed: \(.closed_at // "unknown"))"'
echo ""

echo "🔄 In Progress"
echo "------------------------------"
IN_PROGRESS=$(bd list --status in_progress --json)
if [ "$IN_PROGRESS" = "[]" ] || [ -z "$IN_PROGRESS" ]; then
    echo "  No issues in progress"
else
    echo "$IN_PROGRESS" | jq -r '.[] | "  [\(.id)] \(.title) (@\(.assignee // "unassigned"))"'
fi
echo ""

echo "🚀 Ready to Work (top 5)"
echo "------------------------------"
READY=$(bd ready --limit 5 --json)
if [ "$READY" = "[]" ] || [ -z "$READY" ]; then
    echo "  No ready issues"
else
    echo "$READY" | jq -r '.[] | "  [\(.id)] \(.title) (priority: \(.priority))"'
fi
echo ""

echo "🚫 Blocked Issues"
echo "------------------------------"
BLOCKED=$(bd blocked --json 2>/dev/null || echo "[]")
if [ "$BLOCKED" = "[]" ] || [ -z "$BLOCKED" ]; then
    echo "  No blocked issues"
else
    echo "$BLOCKED" | jq -r '.[] | "  [\(.id)] \(.title)"'
fi
echo ""

echo "🔥 Critical Open Issues"
echo "------------------------------"
CRITICAL=$(bd list --priority 0 --status open --json)
if [ "$CRITICAL" = "[]" ] || [ -z "$CRITICAL" ]; then
    echo "  No critical issues"
else
    echo "$CRITICAL" | jq -r '.[] | "  [\(.id)] \(.title)"'
fi
echo ""

echo "======================================"
