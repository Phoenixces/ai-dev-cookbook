# claude-best-practices

## Developer skills: Input, Tasks, Output
- mermaid draw skill
- drawio draw skill
- codebase explainer skill in desired format
- Implementor skill
- design doc skill
- review skill
- test skill
- debugger skill
  - Env specific:
    - K8S
    - CF
    - jenkins pipeline
- deployer skill
  - red app deployer
 
## Open source skills
1. **HEADROOM **(shrink the input)
  - Headroom compresses everything your Al agent reads - tool outputs, logs, RAG chunks, files, and conversation history reaches the LLM. Same answers, fraction of the tokens. 
2. **PONYTAIL** (write less code)
  - A Claude Code skill: a "lazy senior dev" mindset, Ships the least code that actually solves it.
    <br>How it works: Before writing code, the agent stops at the first rung that holds:
      1. Does this need to exist? → no: skip it (YAGNI)
      2. Already in this codebase?
        → use it
      3. Stdlib does it?
        → use it
      4. Native platform feature?
        → use it
      5. Installed dependency?
        → one line
      6. One line?
        → reuse it, don't rewrite
      7. Only then: the minimum that works

 
## Agents vs skills

## Plugins and Tools
- graphify
- caveman 
- claude-mem (persistent memory for claude code)
  - /plugin marketplace add thedotmack/claude-mem
  - /plugin install claude-mem
  - npx claude-mem install --runtime worker
  - npx claude-mem status


