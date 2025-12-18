#!/bin/bash
# Initialize Beads in a project and create starter issues

set -e

echo "Initializing Beads in project..."
bd init

echo ""
echo "Would you like to create starter issues? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Creating documentation issue..."
    bd create "Update project documentation" \
        -t task \
        -p 2 \
        -l "docs" \
        --json

    echo "Creating setup issue..."
    bd create "Setup development environment" \
        -t task \
        -p 1 \
        -l "setup" \
        --json

    echo ""
    echo "Starter issues created! Check them with: bd list"
fi

echo ""
echo "Beads initialized successfully!"
echo "Next steps:"
echo "  - View ready work: bd ready"
echo "  - Create an issue: bd create \"Task title\""
echo "  - Check the quickstart: bd quickstart"
