# Working on vllm-omni

## Check vLLM upstream first

When designing something in vllm-omni, **first grep / read vLLM upstream for a similar implementation** before committing to a direction. vllm-omni mirrors vLLM's abstractions on purpose (`AttentionBackend` / `AttentionImpl` / `ForwardContext` / `OmniDiffusionConfig` are all named after vLLM counterparts), so reusing an upstream design choice is usually cheaper than inventing one.

Common entry points:
- Repo clone: `/root/vllm-omni-workspace/vllm`, or locate via `pip show vllm`
- Fetch by API: `gh api repos/vllm-project/vllm/contents/<path>`, or `gh pr view <num> --repo vllm-project/vllm`

**Do not** invert this: do not sketch an abstraction in vllm-omni from memory and then ask whether to consult vLLM.

## Git workflow

Remote convention:

| Remote | Points to |
|---|---|
| `origin` | `vllm-project/vllm-omni` (upstream) |
| `gcl` | The user's fork (`gcanlin/vllm-omni`) |

Standard flow once code is finalized (only after the user explicitly says "OK" / "commit now"):

```bash
git checkout -b <branch-name>
git commit -sm "[<Tag>] <Subject>"   # -s sign-off; Subject capitalized
git push gcl <branch-name>
gh pr create --repo vllm-project/vllm-omni --title "[<Tag>] <Subject>" --body "$(cat <<'EOF'
...
EOF
)"
```

Commit / PR title tag convention (check `git log --oneline -20` for the most recent style):
- `[BugFix]` — bug fix
- `[Diffusion][Attention]` — nested domains, each segment capitalized
- `[Feature]`, `[Refactor]`, `[Doc]`, `[Test]` — as needed

The subject is space-separated from the tag and **must** start with a capital letter. Example: `[BugFix] Fix attention_backend AttributeError in diffusers adapter`.
