# Global preferences for canlin

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
