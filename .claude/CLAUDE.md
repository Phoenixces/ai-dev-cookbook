# ai-dev-cookbook

Reference cookbook for Claude Code setup, skills, plugins, and token-optimization tools.

## Skills

- **graphify** (`.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

- **mermaid** (`.claude/skills/mermaid/SKILL.md`) - generate valid Mermaid diagrams. Trigger: `/mermaid`
When the user types `/mermaid`, invoke the Skill tool with `skill: "mermaid"` before doing anything else.

- **design-doc** (`.claude/skills/design-doc/SKILL.md`) - multi-phase design document generator. Trigger: `/design-doc`
When the user types `/design-doc`, invoke the Skill tool with `skill: "design-doc"` before doing anything else.

- **drawio-rules** (`.claude/skills/drawio-rules/SKILL.md`) - mandatory rules for generating .drawio files. Trigger: `/drawio-rules`
When the user types `/drawio-rules`, invoke the Skill tool with `skill: "drawio-rules"` before doing anything else.

- **playwright-cli** (`.claude/skills/playwright-cli/SKILL.md`) - browser automation via playwright-cli. Trigger: `/playwright-cli`
When the user types `/playwright-cli`, invoke the Skill tool with `skill: "playwright-cli"` before doing anything else.

- **review** (`.claude/skills/review/SKILL.md`) - code review with severity-tagged findings. Trigger: `/review`
When the user types `/review`, invoke the Skill tool with `skill: "review"` before doing anything else.

- **dependency** (`.claude/skills/dependency/SKILL.md`) - analyze dependency tree, conflicts, version mismatches. Trigger: `/dependency`
When the user types `/dependency`, invoke the Skill tool with `skill: "dependency"` before doing anything else.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
