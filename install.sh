#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR ..."

# --- Claude Code ---
mkdir -p ~/.claude/skills/search-everything ~/.gmail-mcp

# Symlink settings.json, skills, and CLAUDE.md
ln -sf "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
ln -sf "$DOTFILES_DIR/claude/skills/search-everything/SKILL.md" ~/.claude/skills/search-everything/SKILL.md
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
echo "  symlinked settings.json, skills, and CLAUDE.md"

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
    echo "    See gmail-mcp/gcp-oauth.keys.json.example for the format."
    echo "    Then start Claude Code — it will open a browser for Gmail OAuth."
fi

# --- Shell (PATH in .zshenv for all zsh invocations, including non-interactive) ---
if ! grep -q "dotfiles/bin" ~/.zshenv 2>/dev/null; then
    echo "" >> ~/.zshenv
    echo "# Dotfiles" >> ~/.zshenv
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.zshenv
    echo "export PATH=\"$DOTFILES_DIR/bin:\$PATH\"" >> ~/.zshenv
    echo "  added PATH entries to ~/.zshenv"
fi

# Source shell aliases
if ! grep -q "shell/aliases.zsh" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Dotfiles aliases" >> ~/.zshrc
    echo "source \"$DOTFILES_DIR/shell/aliases.zsh\"" >> ~/.zshrc
    echo "  added aliases sourcing to ~/.zshrc"
fi

# Add .env loading to .zshrc (only needed interactively)
if ! grep -q "source.*dotfiles/.env" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Dotfiles" >> ~/.zshrc
    echo "[ -f \"$DOTFILES_DIR/.env\" ] && set -a && source \"$DOTFILES_DIR/.env\" && set +a" >> ~/.zshrc
    echo "  added .env loading to ~/.zshrc"
fi

# --- Env ---
if [ ! -f "$DOTFILES_DIR/.env" ]; then
    cp "$DOTFILES_DIR/.env.example" "$DOTFILES_DIR/.env"
    echo ""
    echo "  ACTION NEEDED: Fill in your API keys in $DOTFILES_DIR/.env"
fi

echo ""
echo "Done! Restart your shell and Claude Code to pick up changes."
