# Global preferences for canlin

## Git workflow

Standard flow once code is finalized (only after the user explicitly says "OK" / "commit now" — never proactively):

```bash
git checkout -b <branch-name>
git commit -sm "[<Tag>] <Subject>"   # -s sign-off; Subject capitalized
git push <fork-remote> <branch-name>
gh pr create --repo <upstream-owner>/<upstream-repo> \
    --title "[<Tag>] <Subject>" \
    --body "$(cat <<'EOF'
...
EOF
)"
```

Remote naming convention across forks: `origin` points at the upstream repo, a personal short-name remote (e.g. `gcl`) points at the user's fork. Each project's `CLAUDE.md` declares the exact mapping.

Commit / PR title tag convention:
- `[BugFix]` — bug fix
- `[Feature]`, `[Refactor]`, `[Doc]`, `[Test]` — as needed
- Nested domains use bracket stacking, each segment capitalized: `[Diffusion][Attention]`, `[Engine][Scheduler]`

Subject is space-separated from the tag and **must** start with a capital letter. Example: `[BugFix] Fix attention_backend AttributeError in diffusers adapter`.

Before drafting a commit message, run `git log --oneline -20` to match the project's existing style (some projects prefer Conventional Commits, others stick to the bracket-tag form).

## On backwards-compatibility code

A WIP PR (title tagged `[WIP]`, or not yet merged) does **not** need backwards-compat shims for "old callers" — the PR is itself the origin of the rename / new field, so there are no real "old" callers on `main`.

If a reviewer asks for compat, decide based on:
- **Are real production users affected?** CLI flags / env vars / YAML entry points unchanged → only developers constructing the dataclass directly are affected → no shim.
- **Does the old API name actually exist on `main` today?** No → no shim.

Write that judgment as one line in the PR description; it is faster than going back and forth in review comments.

## Clean changes, no leftover tails

Strong preference for "clean" diffs. Concrete expectations:

- Delete unused methods / fields / parameters. Do not keep an "escape hatch" for hypothetical future use.
- Imports at file top. **No** function-local `import` (unless required to break a cycle).
- Renamed a field → update every call site; no aliases.
- Docs (user guide / RFC / skill references) move in lockstep with code.

If unsure whether something is dead code, grep the whole repo + tests before deleting. Do not delete on instinct.

## Python virtualenv convention

Python projects always have a workspace-level virtualenv. **Before running any Python command, look for `.venv/` or `venv/` at or above the project root** and use that interpreter — never the system one.

- Run scripts as `.venv/bin/python script.py` (or `venv/bin/python ...`) rather than activating, so commands stay reproducible in tool output.
- Install with `.venv/bin/pip install <pkg>` — never `pip install` against system Python.
- Run tests with `.venv/bin/pytest` / `.venv/bin/python -m pytest`.
- If neither `.venv/` nor `venv/` exists, **ask before creating one**; the user may have a non-standard interpreter location (conda, uv, system pyenv).
- Check Python version with `.venv/bin/python -V` when behavior depends on it; do not assume `python3` resolves to the project's version.

## Communication style

- Reply in Chinese when the prompt is Chinese; otherwise default to English.
- Be terse. Lead with the conclusion.
- For technical recommendations: state the recommended option + one-line trade-off, then expand.
- Mark **recommended** explicitly; do not be wishy-washy.
- Do not list five options and ask the user to pick — pick one, justify it, leave the user to agree or push back.
- A revert from the user is feedback. Understand why (usually over-engineering or hurting review-friendliness) before redoing.

## Review mode: write a principle analysis

When the user says "review this PR" / "review 这个 PR" / "thoughts on this PR" / "这个 PR 有什么建议", **in addition to the inline review**, produce a `docs/reviews/<pr-number>-<short-name>.md` (or a user-specified path) that explains the PR's cause and effect so the user can learn from it.

See the `pr-review-analysis` skill for the template.

## Do not

- Do not commit / push / open PRs proactively — always wait for an explicit instruction like "commit it now".
- Do not `--amend` a public commit; the standard move is a new commit on top.
- Do not `--no-verify` to skip pre-commit hooks unless the user explicitly says to.
- Do not `git add *` / `git add -A` — stage files by name to avoid sweeping in stray working-tree files.
- Do not edit code just to silence an IDE diagnostic — many diagnostics are stale; verify the actual file state first.
