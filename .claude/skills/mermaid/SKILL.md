---
name: mermaid
description: Generate valid Mermaid diagrams (sequence, flowchart, graph). Enforces strict syntax rules to prevent parse errors before outputting any diagram code.
---

Generate a Mermaid diagram based on the user's request.

## Strict syntax rules — apply ALL of these before outputting

### Forbidden characters in labels and arrow text
Never use these inside any label, note, participant alias, arrow message, or node text:
- `()` — parentheses. Write `foo bar` not `foo()` or `foo(bar)`
- `{}` — curly braces. Write `param` not `{param}`
- `<>` — angle brackets
- `$` — dollar sign. Write `deltaToken param` not `?$deltatoken=value`
- `/` — forward slash. Replace with `-` in URL paths: write `mdiConnector-change-odmType` not `mdiConnector/change/odmType`
- `?` — question mark. Drop query string syntax entirely, describe in plain words instead
- `=` — equals sign in arrow labels. Write `since deltaToken` not `since=deltaToken`
- `—` — em dash (Unicode). Use plain hyphen `-` instead
- `#` — hash inside labels (OK as a comment starter on its own line only)
- `"` inside a label that is already quoted — escape as `&quot;` or rephrase
- `:` inside flowchart node text unless the node text is quoted with `"`
- HTML tags like `<br/>`, `<b>`, `<i>` — not supported in sequence or flowchart labels

### Participant / node names
- Use only letters, digits, underscores, and hyphens: `iEoP_Tasks`, `MDI_Connector`
- The `as` alias in sequence diagrams can contain spaces but still no special chars
- Never use dots in participant IDs: use `commons_npm` not `commons.npm`

### Arrow labels (sequence diagrams)
- Keep them short and plain — use only letters, digits, hyphens, underscores, and spaces
- Method calls: drop the `()`, write `sendEventRequest` not `sendEventRequest()`
- URL paths: replace `/` with `-`, drop `{`, `}`, `$`: write `POST mdiConnector-change-odmType` not `POST /mdiConnector/change/{odmType}`
- Query params: drop `?`, `=`, `$` entirely — write `GET log odmType since deltaToken` not `GET /log/odmType?$since=deltaToken`
- Long labels that wrap to a second line will break the parser — if a label exceeds ~60 characters, shorten it

### Notes
- `Note over A,B: text` — text must be a single line, no special chars, use `-` not `—`
- Never put a Note immediately after an arrow on the same line

### Flowchart / graph
- Node labels with spaces must be quoted: `A["my label"]`
- Subgraph titles must not contain special chars: `subgraph FW_Layer` not `subgraph FW (Layer)`
- Style lines must come after all node/edge definitions

### General
- Always start with the diagram type keyword on its own line: `sequenceDiagram`, `graph TD`, `flowchart LR`
- `autonumber` is valid only in `sequenceDiagram`
- Never use `<br/>` — split into separate notes or shorten the label instead

## Output format

Output only the fenced code block:

```mermaid
<diagram here>
```

No explanation before or after unless the user asked for one.

## Self-check before outputting

Scan every label, alias, arrow message, and note text for the forbidden characters listed above. If any are found, fix them first. Only then output the diagram.
