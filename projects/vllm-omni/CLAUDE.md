# Working on vllm-omni

## Check vLLM upstream first

When designing something in vllm-omni, **first grep / read vLLM upstream for a similar implementation** before committing to a direction. vllm-omni mirrors vLLM's abstractions on purpose (`AttentionBackend` / `AttentionImpl` / `ForwardContext` / `OmniDiffusionConfig` are all named after vLLM counterparts), so reusing an upstream design choice is usually cheaper than inventing one.

Common entry points:
- Repo clone: `/root/vllm-omni-workspace/vllm`, or locate via `pip show vllm`
- Fetch by API: `gh api repos/vllm-project/vllm/contents/<path>`, or `gh pr view <num> --repo vllm-project/vllm`

**Do not** invert this: do not sketch an abstraction in vllm-omni from memory and then ask whether to consult vLLM.

## Git remotes

| Remote | Points to |
|---|---|
| `origin` | `vllm-project/vllm-omni` (upstream) |
| `gcl` | `gcanlin/vllm-omni` (the user's fork) |

PR target: `vllm-project/vllm-omni`. Push branches to `gcl`. See the global Git workflow section in `~/.claude/CLAUDE.md` for the commit / push / `gh pr create` template.
