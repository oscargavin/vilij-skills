#!/usr/bin/env bash
# Check if beads (bd) installation is up to date

set -e

GITHUB_REPO="steveyegge/beads"
MINIMUM_VERSION="v0.20.1"  # First version with hash-based IDs

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if bd is installed
if ! command -v bd &> /dev/null; then
    echo -e "${RED}Error: bd command not found${NC}"
    echo "Please install beads first:"
    echo "  curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash"
    exit 1
fi

# Get installed version
INSTALLED_VERSION=$(bd version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [ -z "$INSTALLED_VERSION" ]; then
    echo -e "${RED}Error: Could not determine installed bd version${NC}"
    echo "Run: bd version"
    exit 1
fi

echo "Installed version: $INSTALLED_VERSION"

# Fetch latest release from GitHub
echo "Checking for latest release..."
LATEST_VERSION=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${YELLOW}Warning: Could not fetch latest version from GitHub${NC}"
    echo "Please check manually at: https://github.com/$GITHUB_REPO/releases"
    exit 0
fi

echo "Latest version:    $LATEST_VERSION"
echo

# Compare versions (simple string comparison works for semver)
if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
    echo -e "${GREEN}✓ You are running the latest version!${NC}"
    exit 0
fi

# Version comparison helper
version_lt() {
    [ "$1" != "$2" ] && [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ]
}

if version_lt "$INSTALLED_VERSION" "$LATEST_VERSION"; then
    echo -e "${YELLOW}⚠ A newer version is available${NC}"
    echo
    echo "Release notes: https://github.com/$GITHUB_REPO/releases/tag/$LATEST_VERSION"
    echo
    echo "To upgrade:"
    echo "  curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash"
    echo

    # Check if version supports hash-based IDs
    if version_lt "$INSTALLED_VERSION" "$MINIMUM_VERSION"; then
        echo -e "${RED}⚠ IMPORTANT: Your version uses old sequential IDs (bd-1, bd-2)${NC}"
        echo "New versions use hash-based IDs (bd-a1b2, bd-f14c) to prevent conflicts."
        echo
        echo "After upgrading, run migration:"
        echo "  bd migrate --inspect  # Preview changes"
        echo "  bd migrate            # Perform migration"
        echo
    fi
else
    echo -e "${GREEN}✓ You are running a newer or custom version${NC}"
fi
