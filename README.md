# claude-best-practices

Personal cookbook for getting the most out of Claude Code — better output quality, lower token burn, smarter local setup.

---

## Table of Contents

- [What's in here](#whats-in-here)
- [Status Line](#status-line-statusfilesh)
- [Skills (Custom Slash Commands)](#skills-custom-slash-commands)
- [Agents vs Skills](#agents-vs-skills)
- [Plugins & Tools](#plugins--tools)
- [Claude Code vs GitHub Copilot](#claude-code-vs-github-copilot--when-to-use-which)
- [Model Selection Guide](#model-selection-guide)
- [Free Local Models — OpenCode + Ollama](#free-local-models--opencode--ollama)
- [Tips for Low Token Usage](#tips-for-low-token-usage)

---

## What's in here

| File | Purpose |
|------|---------|
| `statusfile.sh` | Status line script — shows cost, context %, model, rate limits, git branch in the Claude Code terminal |
| [`opencode-ollama.md`](opencode-ollama.md) | Free & unlimited local model setup — OpenCode + Ollama, no API keys needed |

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

## Claude Code vs GitHub Copilot — When to Use Which

Both tools have access: pick by task shape, not habit.

| Signal | Use Claude Code | Use GitHub Copilot |
|--------|----------------|--------------------|
| **Scope** | Multi-file change, refactor, feature from scratch | Single file, completing a function, inline suggestion |
| **Context needed** | Needs to understand the whole codebase, architecture, or a long spec | Needs only the open file + a few neighbors |
| **Autonomy** | You want it to plan, run commands, edit, test, and iterate | You want to drive; it assists your keystrokes |
| **Task type** | Debug a complex bug, write a design doc, migrate a library, review a diff, write tests for a module | Autocomplete a method body, generate boilerplate, quick lookup |
| **Output** | Files changed, commands run, verified result | Inline suggestion accepted or dismissed |
| **Cost** | Token-burn per turn (watch context %) | Near-free for inline completions |

**Rule of thumb:**
- Copilot = fast typist in your IDE. Great when you know what to write, just want it faster.
- Claude Code = junior dev who can actually run things. Great when you're not sure *how* to write it, or when the task spans many files.

**When both help:** Use Copilot while writing, then hand the diff to Claude Code for review, test generation, or cleanup.

---

## Model Selection Guide

Claude Code defaults to the configured model. For agentic/coding tasks in Claude Code, `claude-opus-5` or `claude-sonnet-5` are the defaults. Swap via `/model` or set in settings.

| Model | Best for | Avoid when |
|-------|----------|------------|
| **Claude Opus 5** (`claude-opus-5`) | Hard multi-file features, architectural decisions, long autonomous sessions, code review with high precision, complex debugging | Simple lookups, high-volume repetitive tasks — cost adds up |
| **Claude Sonnet 5** (`claude-sonnet-5`) | Daily coding work, test generation, moderate refactors, agentic loops where Opus is overkill — ~60% the cost | The absolute hardest problems; very long-horizon planning |
| **Claude Haiku 4.5** (`claude-haiku-4-5`) | Classification, quick summaries, high-volume batch operations, linting explanations | Anything requiring multi-step reasoning or code synthesis |
| **Claude Fable 5** (`claude-fable-5`) | Hardest reasoning tasks that genuinely need the ceiling (frontier research, complex proof-like design work) | Everyday coding — expensive; also safety classifiers stricter |

### Practical mapping

```
Overnight autonomous coding run   → Opus 5 (or Sonnet 5 if budget matters)
"Explain this function"           → Haiku 4.5
Feature from a 2-page spec        → Sonnet 5
Refactor 20 files consistently    → Opus 5 (needs coherence across scope)
Write tests for a module          → Sonnet 5
Summarize a long PR               → Haiku 4.5
Debug a subtle race condition     → Opus 5 (needs deep reasoning)
Generate boilerplate CRUD         → Sonnet 5
```

### Effort level matters too

Within a model, `effort` controls how deep it thinks. Set via `/effort` or `output_config.effort`:

| Effort | Use |
|--------|-----|
| `low` | Latency-sensitive, simple tasks |
| `medium` | Most interactive coding; good cost/quality balance |
| `high` | Default; solid for complex tasks |
| `xhigh` | Hard agentic/coding problems — default in Claude Code |
| `max` | When correctness matters more than cost |

**Cheapest path for good output:** `claude-sonnet-5` at `high` effort beats `claude-opus-5` at `low` effort on most coding tasks. Match both model and effort to the task.

## Free Local Models — OpenCode + Ollama

Run models locally: no API keys, no cost, no rate limits. Full setup in [`opencode-ollama.md`](opencode-ollama.md).

**Quick start:**

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5-coder:3b   # ~1.9 GB, fast coder
ollama pull deepseek-r1:8b     # ~4.7 GB, reasoning
opencode .                      # switch model with /model inside
```

Configure OpenCode to use Ollama at `http://localhost:11434/v1` — see the full config and model table in [`opencode-ollama.md`](opencode-ollama.md).

---

## Tips for Low Token Usage

- **Use HEADROOM** before feeding logs or large file trees to Claude.
- **Use PONYTAIL** to stop Claude from over-engineering solutions.
- **Use caveman mode** to compress verbose responses.
- **Use graphify** instead of asking Claude to read raw source — graph queries return a scoped subgraph, not the whole codebase.
- **Watch the status line** — context % and CU cost update every turn; start a new session before hitting 80%+ context to avoid degraded output quality.
- **Prefer skills over long prompts** — a well-scoped skill prompt burns far fewer tokens than re-explaining the task each time.
