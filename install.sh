#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR ..."

# --- Claude Code ---
mkdir -p ~/.claude/skills/search-everything ~/.gmail-mcp

# Symlink settings.json, skills, CLAUDE.md, and plugins
ln -sf "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
ln -sf "$DOTFILES_DIR/claude/skills/search-everything/SKILL.md" ~/.claude/skills/search-everything/SKILL.md
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
rm -rf ~/.claude/plugins
ln -sf "$DOTFILES_DIR/claude/plugins" ~/.claude/plugins
echo "  symlinked settings.json, skills, CLAUDE.md, and plugins"

# Install plugin marketplaces (cloned into plugins/marketplaces/)
claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null && echo "  added claude-plugins-official marketplace" || echo "  claude-plugins-official marketplace already installed"
claude plugin marketplace add obra/superpowers-marketplace 2>/dev/null && echo "  added superpowers-marketplace" || echo "  superpowers-marketplace already installed"

# --- MCP Servers (registered via claude mcp, stored in ~/.claude.json) ---
chmod +x "$DOTFILES_DIR/bin/grok-search-mcp"
mkdir -p ~/.local/bin
ln -sf "$DOTFILES_DIR/bin/grok-search-mcp" ~/.local/bin/grok-search-mcp

# Register grok MCP server (user scope = available in all projects)
claude mcp add-json -s user grok "$(cat <<'MCPEOF'
{
  "type": "stdio",
  "command": "${HOME}/.local/bin/grok-search-mcp"
}
MCPEOF
)" 2>/dev/null && echo "  registered grok MCP server" || echo "  grok MCP server already registered"

# Register gmail MCP server (user scope)
claude mcp add-json -s user gmail "$(cat <<'MCPEOF'
{
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@gongrzhe/server-gmail-autoauth-mcp"]
}
MCPEOF
)" 2>/dev/null && echo "  registered gmail MCP server" || echo "  gmail MCP server already registered"

if [ ! -f ~/.gmail-mcp/gcp-oauth.keys.json ]; then
    echo ""
    echo "  ACTION NEEDED: Gmail MCP"
    echo "    Copy your gcp-oauth.keys.json to ~/.gmail-mcp/"
    echo "    See gcp-oauth.keys.json.example in the dotfiles repo for the format."
    echo "    Then start Claude Code — it will open a browser for Gmail OAuth."
fi

# --- Shell setup (supports both zsh and bash) ---
setup_shell_rc() {
    local rc_file="$1"
    local env_file="$2"  # .zshenv for zsh, .bashrc for bash (bash has no separate env file)
    local shell_name="$2"

    # PATH entries
    if ! grep -q "dotfiles/bin" "$env_file" 2>/dev/null; then
        echo "" >> "$env_file"
        echo "# Dotfiles" >> "$env_file"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$env_file"
        echo "export PATH=\"$DOTFILES_DIR/bin:\$PATH\"" >> "$env_file"
        echo "  added PATH entries to $env_file"
    fi

    # Shell aliases
    if ! grep -q "shell/aliases.sh" "$rc_file" 2>/dev/null; then
        echo "" >> "$rc_file"
        echo "# Dotfiles aliases" >> "$rc_file"
        echo "source \"$DOTFILES_DIR/shell/aliases.sh\"" >> "$rc_file"
        echo "  added aliases sourcing to $rc_file"
    fi

    # .env loading
    if ! grep -q "source.*dotfiles/.env" "$rc_file" 2>/dev/null; then
        echo "" >> "$rc_file"
        echo "# Dotfiles" >> "$rc_file"
        echo "[ -f \"$DOTFILES_DIR/.env\" ] && set -a && source \"$DOTFILES_DIR/.env\" && set +a" >> "$rc_file"
        echo "  added .env loading to $rc_file"
    fi
}

# Configure zsh
setup_shell_rc ~/.zshrc ~/.zshenv

# Configure bash (PATH, aliases, and .env all go in .bashrc)
setup_shell_rc ~/.bashrc ~/.bashrc

# --- Env ---
if [ ! -f "$DOTFILES_DIR/.env" ]; then
    cp "$DOTFILES_DIR/.env.example" "$DOTFILES_DIR/.env"
    echo ""
    echo "  ACTION NEEDED: Fill in your API keys in $DOTFILES_DIR/.env"
fi

echo ""
echo "Done! Restart your shell and Claude Code to pick up changes."
