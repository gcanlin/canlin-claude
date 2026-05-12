---
name: pr-review-analysis
description: When the user asks to review a PR ("review this PR", "thoughts on PR #N", or pastes a GitHub PR URL), produce both (1) a tiered review of bugs/design/nits and (2) a separate markdown "principle analysis" file that explains the PR's cause-and-effect so the user can learn from it. Use for any PR against vllm-project/vllm-omni or upstream vllm-project/vllm.
---

# PR Review with Principle Analysis

## When to invoke

User says one of:
- "review this PR" / "review PR #N" / "看一下 PR #N"
- "thoughts on this PR" / "这个 PR 有什么建议"
- "analyze this PR" / "帮我分析这个 PR"
- Pastes a GitHub PR URL and asks for opinion or advice

## Two deliverables (both required)

### 1. Inline review reply

Posted directly in chat. Group findings by severity, **most critical first**:

| Section | Content |
|---|---|
| **Must-fix bugs** | Real runtime / logic errors. Reference `file.py:line`, describe trigger conditions. |
| **Design concerns** | Not bugs, but architecture direction has a better alternative. Write `problem + suggested approach + trade-off`. |
| **Tests** | Missing coverage, edge cases. |
| **Polish / nits** | Naming, comments, style, readability. |

Every finding cites a specific `[file.py:line](path#Lline)` markdown link. Reviewer principles:

- Run commands to verify (`gh pr view`, `gh pr diff`, optionally `gh pr checkout`). Do not rely on memory.
- Compare against upstream vLLM for prior art (see `CLAUDE.md` → "Check vLLM upstream first").
- Distinguish "real production break" from "hypothetical break". WIP PRs often attract reviewer concerns about backwards compatibility that no real user is actually exposed to.

### 2. Principle analysis markdown file

Write to `docs/reviews/<pr-number>-<kebab-name>.md` (create the directory if missing).

**Goal**: the user is not only deciding whether to merge — they want to **learn** from the PR. Cover *why* it's needed → *how* it works → *what trade-offs were made* → *what general lesson transfers*.

## Principle analysis template

```markdown
# PR #<N>: <title>

- **Repo**: <upstream/repo>#<N>
- **Author**: <login>
- **Status**: WIP / Open / Merged
- **Scope**: <one-line scope>

## 1. What problem it solves

<User-facing pain: what broke or was awkward, who is affected, the trigger
scenario. If possible, include a "before / after" snippet showing the
old failure mode or workaround.>

## 2. Core design

<3–5 bullet points decomposing the key concept-level changes. Do **not**
narrate the diff file-by-file — organize by ideas. Example:>

- **Concept A introduced via X**: previously expressed via Y; reason for switching is …
- **Data flow**: A → B → C path, key metadata fields carried along
- **Fallback / safety**: how the unsupported / error path degrades

## 3. Key code snippets (curated)

<Pick 1–3 short snippets that best convey the design intent. Add 1–2 lines
of commentary each. Do not paste the whole diff.>

```python
# vllm_omni/.../foo.py
def bar(...):
    # Inline comment explaining why this shape was chosen.
```

## 4. Design trade-offs

<List the choices the author faced, what they picked, and the cost. Examples:>

- **State on AttentionMetadata vs ForwardContext**: author chose the former;
  benefit is per-call visibility; cost is plumbing in every pipeline.
- **Lazy resolve vs eager init**: chose lazy because `forward_context` is
  unavailable during model load; cost is two `_resolved` flag fields.

## 5. Risks and traps

<What future contributors will trip over if this lands as-is.>

- Implicit coupling: …
- Compatibility: …
- Performance blind spot: …

## 6. Transferable principles

<This is the section the user most wants. Abstract the concrete design
into general takeaways.>

- **Structural info vs dynamic info**: `role` is constructor-time, so it
  belongs in `__init__`; `step_idx` is per-call, so it belongs in metadata
  or `ForwardContext`.
- **"Two sources of truth" anti-pattern**: a classmethod `supports_X()` and
  a class-level dict carrying the same info will inevitably drift.
- **WIP PRs have no compatibility obligation**: …

## 7. Related PRs / upstream references

- vLLM upstream #<N>: <the vLLM-side mirror of the design pattern>
- Prior #<N>: <evolution chain>
```

## Recommended workflow

```bash
# 1. Pull PR metadata
gh pr view <N> --repo vllm-project/vllm-omni \
  --json title,body,state,author,additions,deletions,changedFiles,headRefName

# 2. Read the full diff (paginate if it is large)
gh pr diff <N> --repo vllm-project/vllm-omni

# 3. Skim reviewer comments to surface useful concerns
gh api repos/vllm-project/vllm-omni/pulls/<N>/comments \
  --jq '.[] | {user: .user.login, path: .path, line: .line, body: .body}'

# 4. Cross-link upstream: grep the PR description for `Close #X` / `Refs #X`

# 5. Check out locally if you need to grep the working tree
gh pr checkout <N> --repo vllm-project/vllm-omni
```

## Style rules

- Principle analysis is **not a changelog**. Avoid line-by-line narration like
  "adds X field at file.py:42".
- Principle analysis has **an opinion**. If a design choice is questionable,
  state the reason and the better direction.
- Do not pad sections. If a section has nothing to say, delete or merge it.
- The doc is read by someone catching up six months later — avoid time-relative
  words like "recently" or "now".
- Do not re-explain context the user already has (no "what is diffusion / attention").
