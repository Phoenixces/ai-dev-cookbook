# Claude Code — Best Practices

Tips, tools, and setup for getting the most out of Claude Code.

---

## Table of Contents

- [Status Line](#status-line-statusfilesh)
- [Skills (Custom Slash Commands)](#skills-custom-slash-commands)
- [Agents vs Skills](#agents-vs-skills)
- [Plugins & Tools](#plugins--tools)
- [Token Compression Tools](#token-compression-tools)
- [Cmux — Multi-Agent Terminal](#cmux)
- [Agentic Coding Tools — When to Use Which](#agentic-coding-tools--when-to-use-which)
- [Model Selection Guide](#model-selection-guide)
- [Tips for Low Token Usage](#tips-for-low-token-usage)

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

Skills live in `~/.claude/skills/` (global) or `.claude/skills/` (project). Invoked as `/skill-name` inside Claude Code. Register each in the relevant `CLAUDE.md`.

**Installed (global `~/.claude/skills/`):**

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `graphify` | `/graphify` | Build queryable knowledge graph from codebase, docs, PDFs, images |
| `mermaid` | `/mermaid` | Generate valid Mermaid diagrams from natural language |

**Installed (project `.claude/skills/`):**

| Skill | Invoke | What it does |
|-------|--------|-------------|
| `design-doc` | `/design-doc` | Multi-phase architect dialogue → generates tight design doc |
| `drawio-rules` | `/drawio-rules` | Mandatory rules for generating correct `.drawio` files (HLD + LLD) |
| `playwright-cli` | `/playwright-cli` | Browser automation via `playwright-cli` CLI |
| `review` | `/review` | Code review — critical / suggestions / style, language-agnostic |
| `dependency` | `/dependency` | Analyze dependency tree, conflicts, version mismatches (Maven/npm/pip) |

**Add a skill:**
```bash
mkdir -p ~/.claude/skills/<name>
# drop SKILL.md inside, then register:
echo '- **<name>** (`~/.claude/skills/<name>/SKILL.md`) - <desc>. Trigger: `/<name>`
When the user types `/<name>`, invoke the Skill tool with `skill: "<name>"` before doing anything else.' >> ~/.claude/CLAUDE.md
```

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

Turns any codebase into a queryable knowledge graph.

**Install:**
```bash
pip install graphifyy && graphify install
```

Register in `~/.claude/CLAUDE.md`:
```
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
```

**Querying (inside Claude Code or terminal):**
```bash
graphify query "how does auth work"       # scoped subgraph — prefer over reading raw source
graphify path "UserService" "TokenStore"  # relationship between two nodes
graphify explain "middleware"             # focused concept deep-dive
```

**Building & updating:**
```bash
/graphify .                   # analyze current directory
/graphify . --mode deep       # aggressive edge extraction
/graphify . --update          # incremental — reprocess only changed files
/graphify . --watch           # auto-sync on file changes (background)
/graphify . --wiki            # generate agent-navigable wiki/index.md
/graphify add [url]           # fetch and integrate a paper, tweet, or URL
graphify update .             # keep graph current after code changes (AST-only, no API cost)
graphify hook install         # auto-rebuild graph on every git commit
```

**Output files** (written to `graphify-out/`):

| File | Description |
|------|-------------|
| `graph.html` | Interactive browser visualization |
| `graph.json` | Persistent graph for cross-session queries |
| `GRAPH_REPORT.md` | Human-readable architecture summary |
| `wiki/index.md` | Agent-navigable wiki (with `--wiki`) |

**Supported input:** `.py .ts .js .go .rs .java .c .cpp .rb .cs .kt .scala .php` · `.md .txt .rst` · `.pdf` · `.png .jpg .webp .gif`

**Navigation rule:** use `graphify query` first for codebase questions — returns a scoped subgraph, far cheaper than reading raw source. Fall back to `GRAPH_REPORT.md` only for broad architecture review.

### caveman

Compresses Claude's responses — drops filler, articles, hedging. Keeps all technical substance. Saves output tokens.

```
/caveman full    # maximum compression (default)
/caveman lite    # light compression
/caveman ultra   # extreme (fragments only)
stop caveman     # revert to normal
```

**Install:** `/plugin marketplace add caveman@caveman`

### claude-mem

Persistent cross-session memory for Claude Code. Claude remembers decisions, patterns, and context across conversations.

```bash
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
npx claude-mem install --runtime worker
npx claude-mem status
```

### swift-lsp

LSP server for Swift — enables go-to-definition, hover docs, find references inside Claude Code.

**Install:** `/plugin marketplace add claude-plugins-official/swift-lsp`

---

## Token Compression Tools

### RTK (Rust Token Killer)

Lightweight shell output filter. Intercepts Bash commands and compresses output (git log, ls, npm noise) before it reaches the LLM. No proxy, no credentials, local-only.

**Install:**
```bash
brew install rtk
RTK_TELEMETRY_DISABLED=1 rtk init -g   # registers global Claude Code PreToolUse hook
# restart Claude Code
```

**Verify:**
```bash
rtk git log --oneline -50   # should show compressed summary
cat ~/.claude/settings.json | grep -A5 rtk
```

**Optional config** (`~/.config/rtk/config.toml`):
```toml
[hooks]
exclude_commands = ["curl", "playwright"]   # pass through unchanged

[tee]
enabled = true
mode = "failures"   # save unfiltered output when command fails
```

**Scope:** Bash tool calls only. Claude Code built-ins (Read, Grep, Glob) are not affected.

---

### Headroom

Local context-compression proxy that sits between Claude Code and the LLM. Compresses tool outputs, logs, RAG chunks, code, and conversation history. Bigger savings than RTK but more setup and a critical trade-off.

**Install:**
```bash
brew install uv
uv tool install --python 3.13 "headroom-ai[all]"
echo 'alias hclaude="headroom wrap claude"' >> ~/.zshrc
```

**Launch:**
```bash
headroom wrap claude --1m           # preserve 1M context window (always add this)
headroom wrap claude --1m --memory  # + cross-session memory
headroom dashboard                  # live token savings view (separate terminal)
headroom doctor --port 8787         # verify routing
```

**When to use:**

| Savings | Workload |
|---------|---------|
| 50–95% | CI/build log triage, code search over large result sets, GitHub issue triage, JSON-heavy tool outputs, RAG retrieval |
| 15–50% | Standard coding sessions with large file reads, multi-session project work |
| < 20% | Short focused tasks, pure conversation |

**When NOT to use — the cache trap:**

Headroom compresses content before each request, which changes the prompt and **breaks prompt caching**. If you have a large stable system context (instruction files, memory, tool schemas), normally billed at ~10% via cache hits, Headroom can turn that into 100% full-price billing on every request.

Rule of thumb: if your always-loaded context exceeds ~50k tokens (especially with claude-mem loading memory files), Headroom will likely **increase** your costs, not reduce them.

**RTK vs Headroom:**

| | RTK | Headroom |
|---|---|---|
| Compresses | Shell output only | Shell + JSON + logs + code + history |
| Prompt cache | Unaffected | Breaks it |
| Overhead | Near-zero | Spawns tokensave (CPU-heavy on first run) |
| Best for | Always-on, low overhead | CI log triage, 50k+ token JSON blobs |
| Note | — | Headroom includes RTK internally |

> **Practical recommendation:** Install RTK always. Use Headroom only for specific log-heavy investigation sessions, not as your default launcher — especially if you have heavy claude-mem context.

---

### Cmux

macOS terminal built for managing multiple AI coding agents simultaneously. Vertical tabs with context sidebars, notification rings that glow when an agent is waiting for input.

**Install:** via [cmux.com](https://cmux.com) or your package manager.

**Disable telemetry before first launch** (`~/.config/cmux/cmux.json`):
```json
{
  "app": {
    "sendAnonymousTelemetry": false
  }
}
```

**Key shortcuts:**

| Action | Shortcut |
|--------|---------|
| New tab | `Cmd + T` |
| Split horizontal | `Cmd + D` |
| Split vertical | `Cmd + Shift + D` |
| Jump to next waiting agent | `Cmd + Shift + U` |
| Navigate panes | `Cmd + Option + Arrow` |

**Multi-agent workflow:**
```
Tab 1 — proxy / always running
Tab 2 — Claude Code   ~/projects/backend
Tab 3 — Codex CLI     ~/projects/frontend
Tab 4 — any agent     ~/projects/other
```

Notification rings make it immediately visible which agents need attention without tab-scanning.

---

## Agentic Coding Tools — When to Use Which

All are coding agents. Pick by task shape and preferred interface.

| Signal | Claude Code | Codex CLI | Zoo Code | GitHub Copilot | Goose |
|--------|-------------|-----------|----------|----------------|-------|
| **Interface** | Terminal / IDE extension | Terminal | VS Code sidebar | IDE inline + terminal | Desktop app + terminal |
| **Model** | Claude (Anthropic) | GPT (OpenAI) | Any (LiteLLM) | GPT-4o / Claude | Any (LiteLLM) |
| **Autonomy** | High — plans, edits, runs, iterates | High — executes tasks end-to-end | High — agentic in IDE | Low — assists your keystrokes | High — general-purpose |
| **Best scope** | Multi-file changes, deep codebase work, agentic loops | Task execution, scripting, one-shot commands | IDE-native agentic coding, model flexibility | Single-file autocomplete, boilerplate | Non-code tasks, browser/GUI, research |
| **Context** | Full codebase via tools | File + command execution | Full codebase (IDE context) | Open file + neighbors | Whatever you give it |
| **Cost model** | Token-burn per turn | Token-burn per turn | Token-burn per turn | Near-free for inline | Token-burn per turn |
| **Skills / hooks** | Rich (skills, agents, hooks, MCP) | Minimal | MCP servers | Extensions | Extensions (MCP) |
| **Install** | `npm install -g @anthropic-ai/claude-code` | `npm install -g @openai/codex` | VS Code Marketplace → "Zoo Code" | VS Code Marketplace | block.github.io/goose |

**Rules of thumb:**
- **Claude Code** — default for multi-file, architectural, or deep codebase work in terminal
- **Zoo Code** — when you want an agentic assistant embedded in VS Code UI, with model flexibility (GPT/Claude/Mistral). Use its modes to constrain behaviour: Architect for planning, Code for implementation, Debug for troubleshooting, Ask for read-only exploration, Orchestrator to delegate across modes.
- **Codex CLI** — good second agent in Cmux when you want GPT models alongside Claude Code
- **GitHub Copilot** — keep open in IDE for inline autocomplete; hand complex diffs to Claude Code
- **Goose** — general desktop AI for non-coding tasks (browser, docs, research)

**Multi-agent workflow with Cmux:**
```
Tab 1 — proxy (always running)
Tab 2 — Claude Code  (complex feature work)
Tab 3 — Codex CLI    (parallel task / GPT perspective)
Tab 4 — Goose        (research, browser, docs)
```
> Zoo Code runs in VS Code — doesn't need a Cmux tab.

### Zoo Code Modes

Zoo Code has 5 built-in modes, each with different tool access and persona:

| Mode | Tools | Use when |
|------|-------|---------|
| **Code** | read + edit + command + MCP (full) | Writing, implementing, refactoring — default workhorse |
| **Architect** | read + MCP + markdown edit only | System design, planning, writing specs — no code edits |
| **Debug** | read + edit + command + MCP (full) | Systematic troubleshooting — methodical: reflect → narrow → log → verify → fix |
| **Ask** | read + MCP only (no edits) | Learning, exploring codebase — read-only, safe for investigation |
| **Orchestrator** | `new_task` only (delegates to other modes) | Multi-step projects — breaks work into subtasks, hands each to the right mode |

Each mode remembers its last-used model across sessions. Switch via the mode picker in the Zoo Code sidebar.

---

## Model Selection Guide

### Claude Models

Claude Code defaults to the configured model. Swap via `/model` or set in settings.

| Model | Best for | Avoid when |
|-------|----------|------------|
| **Claude Opus 5** (`claude-opus-5`) | Hard multi-file features, architectural decisions, long autonomous sessions, complex debugging | Simple lookups, high-volume repetitive tasks — cost adds up |
| **Claude Sonnet 5** (`claude-sonnet-5`) | Daily coding work, test generation, moderate refactors, agentic loops — ~60% cost of Opus | Absolute hardest problems, very long-horizon planning |
| **Claude Haiku 4.5** (`claude-haiku-4-5`) | Classification, quick summaries, high-volume batch ops, linting explanations | Multi-step reasoning, code synthesis |
| **Claude Fable 5** (`claude-fable-5`) | Hardest reasoning tasks, frontier research, complex proof-like design | Everyday coding — expensive; safety classifiers stricter |

**Practical mapping:**
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

### OpenAI Models

Used via Codex CLI, Zoo Code, or any LiteLLM-routed tool.

| Model | ID | Cost tier | Best for |
|-------|----|-----------|---------|
| **GPT-6 Astra** | `gpt-6-astra` | $$$ ($10/$50 per MTok) | Hardest tasks — most capable, 1M context, reasoning + computer use |
| **GPT-6.1 Sol** | `gpt-6.1-sol` | $$ ($2/$10 per MTok) | Balanced intelligence + cost, daily complex work |
| **GPT-6 Luna** | `gpt-6-luna` | $ ($0.1/$0.5 per MTok) | High-volume, focused, repetitive tasks |
| **GPT-5.6 Sol** | `gpt-5.6-sol` | $$ | Complex open-ended work needing analysis and judgment |
| **GPT-5.6 Terra** | `gpt-5.6-terra` | $ | Everyday work, strong reasoning at lower cost |
| **GPT-5.6 Luna** | `gpt-5.6-luna` | $ | Fast, high-volume extraction / classification / transformation |

> GPT-5.6 models support the `/responses` API required by Codex CLI. GPT-4o and gpt-5-mini do not.

**Practical mapping:**
```
Complex multi-step coding task    → GPT-6.1 Sol or GPT-5.6 Sol
Everyday coding / refactor        → GPT-6.1 Sol or GPT-5.6 Terra
Bulk extraction / classification  → GPT-6 Luna or GPT-5.6 Luna
Maximum capability, no cost limit → GPT-6 Astra
Codex CLI default (proxy-routed)  → GPT-5.6 Terra
```

### Effort level (Claude only)

Within a Claude model, `effort` controls reasoning depth. Set via `/effort`:

| Effort | Use |
|--------|-----|
| `low` | Latency-sensitive, simple tasks |
| `medium` | Most interactive coding; good cost/quality balance |
| `high` | Default; solid for complex tasks |
| `xhigh` | Hard agentic/coding problems — default in Claude Code |
| `max` | When correctness matters more than cost |

**Cheapest path for good output:** `claude-sonnet-5` at `high` effort beats `claude-opus-5` at `low` effort on most coding tasks.

---

## Tips for Low Token Usage

- **Use RTK** — always-on shell output compression, zero overhead. Install once, forget it.
- **Use Headroom** for CI log triage or large JSON blobs — but **not** as default if you have heavy claude-mem context (cache-breaking cost).
- **Use caveman mode** to compress verbose responses.
- **Use graphify** instead of asking Claude to read raw source — `graphify query` returns a scoped subgraph, not the whole codebase.
- **Watch the status line** — context % and cost update every turn; start a new session before hitting 80%+ context.
- **Prefer skills over long prompts** — a well-scoped skill prompt burns far fewer tokens than re-explaining the task each time.
