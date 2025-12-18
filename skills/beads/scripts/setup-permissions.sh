#!/bin/bash
# Setup Claude Code permissions for Beads commands
# This script creates or updates .claude/settings.local.json with bd command permissions

set -e

SETTINGS_FILE=".claude/settings.local.json"

# Create .claude directory if it doesn't exist
mkdir -p .claude

# Check if settings file exists
if [ -f "$SETTINGS_FILE" ]; then
    echo "Found existing $SETTINGS_FILE"

    # Read existing settings
    EXISTING=$(cat "$SETTINGS_FILE")

    # Check if permissions already exist
    if echo "$EXISTING" | grep -q '"permissions"'; then
        echo "Permissions section already exists."

        # Check if bd permissions are already there
        if echo "$EXISTING" | grep -q 'Bash(bd :' && echo "$EXISTING" | grep -q 'SlashCommand(/beads:'; then
            echo "✓ Beads permissions already configured!"
            exit 0
        fi

        echo "Adding Beads permissions to existing permissions..."

        # Use jq if available for proper JSON merging
        if command -v jq &> /dev/null; then
            NEW_PERMS='["Bash(bd :*)","SlashCommand(/beads:*)"]'
            jq --argjson perms "$NEW_PERMS" '.permissions.allow += $perms | .permissions.allow |= unique' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
            mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            echo "✓ Permissions updated successfully using jq!"
        else
            echo "⚠️  jq not found. Please manually add these permissions to $SETTINGS_FILE:"
            echo '"Bash(bd :*)"'
            echo '"SlashCommand(/beads:*)"'
            exit 1
        fi
    else
        echo "No permissions section found. Adding Beads permissions..."

        if command -v jq &> /dev/null; then
            NEW_PERMS='{"permissions":{"allow":["Bash(bd :*)","SlashCommand(/beads:*)"]}}'
            jq --argjson perms "$NEW_PERMS" '. + $perms' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
            mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
            echo "✓ Permissions added successfully!"
        else
            echo "⚠️  jq not found. Please manually add permissions section to $SETTINGS_FILE"
            exit 1
        fi
    fi
else
    echo "Creating new $SETTINGS_FILE with Beads permissions..."
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(bd :*)",
      "SlashCommand(/beads:*)"
    ]
  }
}
EOF
    echo "✓ Settings file created with Beads permissions!"
fi

echo ""
echo "Beads permissions configured successfully!"
echo ""
echo "You can now use Beads commands in Claude Code:"
echo "  /beads:ready        - See ready work"
echo "  /beads:create-issue - Create a new issue"
echo "  /beads:status       - View project status"
echo ""
