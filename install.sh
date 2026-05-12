#!/usr/bin/env bash
#
# Install canlin-claude into the local Claude Code config dir via symlinks.
#
# After running:
#   - $HOME/.claude/CLAUDE.md       → this repo's CLAUDE.md (global memory)
#   - $HOME/.claude/skills/<name>/  → each skill in this repo
#
# Symlinks point back to the repo working tree, so `git pull` updates take
# effect immediately. To revert, just remove the symlinks.

set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")" && pwd)}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

mkdir -p "$CLAUDE_DIR/skills"

link_file() {
    local src="$1"
    local dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "WARN: $dst exists and is not a symlink — backing up to ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sfn "$src" "$dst"
    echo "linked $dst → $src"
}

# Global CLAUDE.md
link_file "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Global skills (one directory per skill)
if [[ -d "$REPO_DIR/skills" ]]; then
    for skill_dir in "$REPO_DIR/skills"/*/; do
        [[ -d "$skill_dir" ]] || continue
        skill_name=$(basename "$skill_dir")
        link_file "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
    done
fi

echo
echo "Done. Verify with:"
echo "  readlink $CLAUDE_DIR/CLAUDE.md"
echo "  ls -la $CLAUDE_DIR/skills/"
