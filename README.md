# Dotfiles

Portable Claude Code configurations (MCP servers, skills, settings) and shell customizations.

## Quick Start

```bash
git clone git@github.com:amydeng/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
# Fill in your API keys in .env
# Restart your shell and Claude Code
```

## What Gets Installed

| Config | Location | Method |
|---|---|---|
| Claude settings + MCP servers | `~/.claude/settings.json` | Symlink |
| `/search-everything` skill | `~/.claude/skills/search-everything.md` | Symlink |
| Global CLAUDE.md conventions | `~/.claude/CLAUDE.md` | Symlink |
| `grok-search-mcp` on PATH | `dotfiles/bin/` added to `$PATH` | `.zshrc` line |
| Shell aliases (`cc`, ...) | `dotfiles/shell/aliases.sh` sourced | `.zshrc` line |
| Env vars (API keys) | `dotfiles/.env` sourced | `.zshrc` line |

## Setup Guides

### Grok (X/Twitter Search)

1. Get an API key from [x.ai console](https://console.x.ai/)
2. Add it to `.env`:
   ```
   XAI_API_KEY=xai-your-actual-key
   ```
3. Restart Claude Code. The server reads the key directly from `.env`.

### Gmail MCP

1. Create an OAuth 2.0 Client ID in [Google Cloud Console](https://console.cloud.google.com/apis/credentials):
   - Application type: **Desktop app**
   - Enable the **Gmail API** for your project
2. Download the OAuth client JSON and save it as `~/.gmail-mcp/gcp-oauth.keys.json` (see `gcp-oauth.keys.json.example` in the repo root for the expected structure)
3. Start Claude Code — it will open a browser window to complete the Gmail OAuth flow on first use.

### Skills

**`/search-everything`** — Searches both the web (via `WebSearch`) and X/Twitter (via `mcp__grok__search_x`) in parallel, then synthesizes results into a unified summary grouped by theme.

To add a new skill, create a `.md` file in `claude/skills/` and add a symlink line to `install.sh`.

### Shell Aliases

| Alias | Command |
|---|---|
| `cc` | `claude --dangerously-skip-permissions` |

To add more aliases, edit `shell/aliases.sh` — changes propagate via `git pull` without re-running `install.sh`.

## Updating

Edit files in this repo, commit, and push. On other machines:

```bash
cd ~/dotfiles
git pull
# Settings/skills/CLAUDE.md update instantly via symlinks
# Re-run ./install.sh only if install.sh itself changed
```
