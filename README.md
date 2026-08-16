# claude-best-practices

Personal cookbook for getting the most out of Claude Code — better output quality, lower token burn, smarter local setup.

---

## What's in here

| File | Purpose |
|------|---------|
| `statusfile.sh` | Status line script — shows cost, context %, model, rate limits, git branch in the Claude Code terminal |

---

## Status Line (`statusfile.sh`)

A Claude Code [status line script](https://docs.anthropic.com/en/docs/claude-code/settings#status-line) that renders a 2–3 line HUD at the bottom of every prompt.

**Line 1** — project name · git branch · worktree · context bar · context %  
**Line 2** — cost in CU + EUR · lines added/removed · model · gear backend · effort level  
**Line 3** — Pro/Max rate limits (daily + monthly bars), shown only when available

### Setup

```bash
# In your project's .claude/settings.json or ~/.claude/settings.json
{
  "statusCommand": "/path/to/statusfile.sh"
}
```

### What it tracks

| Field | Notes |
|-------|-------|
| Context % | Color-coded bar: green → yellow → red |
| Cost | Shown in Anthropic CU and EUR (~0.92 USD conversion) |
| Lines changed | `+added` / `-removed` across the session |
| Model | Purple when direct; dimmed when behind a router |
| Effort level | `low / medium / high / xhigh / max` — color-coded |
| Gear backend | Shows real backend model when using [switchable-llm-gear](https://github.com/Phoenixces/switchable-llm-gear) router |
| Rate limits | Daily (5h window) + Monthly (7d window) — Pro/Max only |

---

## Skills (Custom Slash Commands)

Skills live in `~/.claude/skills/` and are invoked as `/skill-name` inside Claude Code.

### Developer Skills

| Skill | What it does |
|-------|-------------|
| `mermaid` | Draw Mermaid diagrams from natural language |
| `drawio` | Generate Draw.io XML diagrams |
| `explainer` | Explain a codebase in a requested format (summary, deep-dive, ADR, etc.) |
| `implementor` | Implement a feature from a spec or design doc |
| `design-doc` | Write a design document for a proposed change |
| `review` | Code review with severity-tagged findings |
| `test` | Generate tests for a given module or function |
| `debugger` | Diagnose bugs — has env-specific modes for K8s, CF, Jenkins pipelines |
| `deployer` | Deploy — includes Red App deployer support |

### Token-saving Skills

#### HEADROOM — shrink the input

Compresses what the agent reads before it hits the LLM: tool outputs, logs, RAG chunks, file contents, conversation history. Same answers, fraction of the tokens.

> Useful when working with large codebases, long CI logs, or deep conversation threads.

#### PONYTAIL — write less code

A "lazy senior dev" mindset. Before writing anything, the agent walks this ladder and stops at the first rung that holds:

1. Does this need to exist? → no: skip (YAGNI)
2. Already in this codebase? → use it
3. Stdlib does it? → use it
4. Native platform feature? → use it
5. Installed dependency? → one line
6. One line? → reuse, don't rewrite
7. Only then: write the minimum that works

---

## Agents vs Skills

| | Skills (`/command`) | Agents (custom subagents) |
|-|---------------------|--------------------------|
| Invocation | Slash command in chat | Spawned by Claude via `Agent` tool |
| Scope | Stateless, single task | Multi-step, can use tools |
| Lives in | `~/.claude/skills/` | `.claude/agents/*.md` |
| Good for | Repeatable workflows | Parallel workloads, delegation |

---

## Plugins & Tools

### graphify

Turns any codebase into a queryable knowledge graph. Detects god nodes, community structure, cross-file relationships.

```bash
graphify query "how does auth work"
graphify path "UserService" "TokenStore"
graphify explain "middleware"
```

### caveman

Compresses Claude's responses — drops filler, articles, hedging. Keeps all technical substance. Saves output tokens.

```
/caveman full    # maximum compression
/caveman lite    # light compression
/caveman ultra   # extreme (fragments only)
```

### claude-mem

Persistent cross-session memory for Claude Code. Claude remembers decisions, patterns, and context across conversations.

```bash
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
npx claude-mem install --runtime worker
npx claude-mem status
```

---

## Tips for Low Token Usage

- **Use HEADROOM** before feeding logs or large file trees to Claude.
- **Use PONYTAIL** to stop Claude from over-engineering solutions.
- **Use caveman mode** to compress verbose responses.
- **Use graphify** instead of asking Claude to read raw source — graph queries return a scoped subgraph, not the whole codebase.
- **Watch the status line** — context % and CU cost update every turn; start a new session before hitting 80%+ context to avoid degraded output quality.
- **Prefer skills over long prompts** — a well-scoped skill prompt burns far fewer tokens than re-explaining the task each time.
