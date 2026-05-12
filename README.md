# canlin-claude

Personal Claude Code configuration: a global `CLAUDE.md`, project-specific overrides, and reusable skills, kept in one repo and synced across machines via symlinks.

## What lives here

```
canlin-claude/
├── CLAUDE.md                       # global memory, loaded for every project
├── skills/
│   └── pr-review-analysis/         # global skill: review + principle-analysis doc
│       └── SKILL.md
├── projects/
│   └── vllm-omni/
│       └── CLAUDE.md               # project-specific overrides for vllm-omni
└── install.sh                      # symlinks the repo into ~/.claude/
```

- **`CLAUDE.md`** — cross-project preferences: communication style, "don't" list, clean-diff expectations, PR back-compat rules, review mode behavior.
- **`skills/<name>/SKILL.md`** — Claude Code skills. Auto-discovered when symlinked into `~/.claude/skills/`.
- **`projects/<repo>/CLAUDE.md`** — project-scoped memory (e.g. remote convention, commit-tag style, upstream lookup rules). Drop in alongside the project repo by symlink or by copy.

## How Claude Code picks these up

Claude Code reads memory and skills from these standard paths:

| File | Path | Scope |
|---|---|---|
| User-global memory | `~/.claude/CLAUDE.md` | Loaded in every session |
| Project memory | `<project>/CLAUDE.md` | Loaded when cwd is inside that project |
| User-global skill | `~/.claude/skills/<name>/SKILL.md` | Available in every session |
| Project skill | `<project>/.claude/skills/<name>/SKILL.md` | Available only in that project |

The strategy in this repo: keep cross-project content global, keep project-specific content next to (or symlinked into) the project itself.

## Bootstrap a new machine

```bash
git clone https://github.com/gcanlin/canlin-claude.git ~/canlin-claude
cd ~/canlin-claude
./install.sh
```

`install.sh` symlinks:

- `~/.claude/CLAUDE.md` → `~/canlin-claude/CLAUDE.md`
- `~/.claude/skills/<name>/` → `~/canlin-claude/skills/<name>/` (one per skill)

Symlinks point back to the working tree, so `git pull` updates take effect immediately — no re-install needed.

## Wiring a project-specific CLAUDE.md

Option A — copy and commit into the project (useful when collaborators should see it too):

```bash
cp ~/canlin-claude/projects/vllm-omni/CLAUDE.md /path/to/vllm-omni/CLAUDE.md
# review, then commit inside the vllm-omni repo
```

Option B — symlink only (keeps it personal, single source of truth):

```bash
ln -sfn ~/canlin-claude/projects/vllm-omni/CLAUDE.md /path/to/vllm-omni/CLAUDE.md
# add CLAUDE.md to the project's .git/info/exclude so it isn't accidentally committed
```

## Keeping machines in sync

After editing on machine A:

```bash
cd ~/canlin-claude
git add -A
git commit -m "Update CLAUDE.md / skills"
git push
```

On machine B:

```bash
cd ~/canlin-claude && git pull
```

Symlinks resolve to the updated files immediately. No additional Claude Code reload step is needed for the next session.

Optional: auto-pull on shell startup so you forget less:

```bash
# ~/.zshrc or ~/.bashrc
(cd ~/canlin-claude && git pull --ff-only --quiet 2>/dev/null) &
```

## Sanity check

After install:

```bash
readlink ~/.claude/CLAUDE.md
# → /home/<user>/canlin-claude/CLAUDE.md

ls -la ~/.claude/skills/
# → pr-review-analysis -> /home/<user>/canlin-claude/skills/pr-review-analysis/
```

In a Claude Code session, asking "What does CLAUDE.md tell you?" should surface the global preferences; `/pr-review-analysis` should appear in the skill list.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter (`name`, `description`).
2. Optionally add a `references/` subfolder for longer-form material.
3. Run `./install.sh` again on each machine to pick up the new directory (or just `ln -sfn` it manually).
4. Commit and push.

## Adding a new project's CLAUDE.md

1. Create `projects/<repo-name>/CLAUDE.md`.
2. Either commit it into that project's repo (Option A above) or symlink (Option B).
