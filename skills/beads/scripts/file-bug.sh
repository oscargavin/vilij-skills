#!/bin/bash
# Quick script to file a bug with common fields

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 \"Bug title\" [description] [file:line]"
    echo ""
    echo "Examples:"
    echo "  $0 \"Null pointer in auth handler\""
    echo "  $0 \"Memory leak in worker\" \"Goroutines not cleaned up\" \"worker.go:142\""
    exit 1
fi

TITLE="$1"
DESCRIPTION="${2:-Bug found during development}"
LOCATION="${3:-}"

if [ -n "$LOCATION" ]; then
    DESCRIPTION="$DESCRIPTION\n\nLocation: $LOCATION"
fi

echo "Filing bug: $TITLE"

bd create "$TITLE" \
    -d "$DESCRIPTION" \
    -t bug \
    -p 1 \
    -l "bug" \
    --json | jq '{id, title, priority, type, labels}'

echo ""
echo "Bug filed successfully! View with: bd show [id]"
