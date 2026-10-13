---
name: drawio-rules
description: Mandatory rules for generating .drawio files in HLD and LLD. Invoke before generating any .drawio file to ensure correct structure, rendering, and layout.
disable-model-invocation: false
---

# DrawIO Generation Rules

These rules are MANDATORY every time a `.drawio` file is generated. Violating any of these causes the file to fail or render incorrectly in draw.io.

---

## Universal Rules (HLD + LLD)

### 1. File wrapper
Always wrap the entire file with `<mxfile>` and `<diagram>` tags — never use bare `<mxGraphModel>`:
```xml
<mxfile host="65bd71144e">
    <diagram id="unique-id" name="Page-1">
        <mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1654" pageHeight="1169" math="0" shadow="0">
            <root>
                <mxCell id="0"/>
                <mxCell id="1" parent="0"/>
                ...
            </root>
        </mxGraphModel>
    </diagram>
</mxfile>
```

### 2. XML comments
Never use `--` anywhere inside XML comments — the draw.io parser rejects this.
- WRONG: `<!-- ServiceA --calls--> ServiceB -->`
- CORRECT: `<!-- ServiceA to ServiceB: calls -->`

### 3. Child cell parent IDs
All cells inside a container must have `parent="<container_id>"`, never `parent="1"`. If `parent="1"` is used, the cell detaches and floats on the canvas.

### 4. Arrow routing
Always use `edgeStyle=orthogonalEdgeStyle` with explicit `exitX/Y` and `entryX/Y` on every edge to prevent arrows overlapping boxes.

---

## HLD-Specific Rules

### File structure
One multi-page `.drawio` file per location:
- `diagrams/reference/<system>/<system>.drawio` — 3 named pages: `architecture`, `data-flow`, `er-diagram`
- `diagrams/practice/<system>/<system>_practice.drawio` — 3 stub pages (same names), each with a yellow instruction banner only

Never generate separate per-diagram `.drawio` files.

### Component box heights
Every container box height must be tall enough to contain all child cells. Always calculate explicitly — never guess.

### Architecture diagram component styles
- **Service/API**: `rounded=1;whiteSpace=wrap;fillColor=#dae8fc;strokeColor=#6c8ebf;`
- **Database**: `shape=mxgraph.flowchart.database;fillColor=#f8cecc;strokeColor=#b85450;`
- **Cache**: `rounded=1;whiteSpace=wrap;fillColor=#fff2cc;strokeColor=#d6b656;`
- **Queue**: `shape=mxgraph.flowchart.queue;fillColor=#d5e8d4;strokeColor=#82b366;`
- **CDN/LB**: `rhombus;whiteSpace=wrap;fillColor=#e1d5e7;strokeColor=#9673a6;`
- **Client**: `shape=mxgraph.flowchart.actor;`

### ER diagram cardinality
Label every edge with cardinality (`1`, `0..*`, `1..*`, `0..1`) placed near the relevant end using an `edgeLabel` child cell.

### Layout spacing
- Architecture diagram: minimum 160px gap between components, group by layer (client / API / services / data)
- ER diagram: minimum 120px gap between entity boxes
- Data flow: left-to-right layout with minimum 180px horizontal spacing between steps

---

## LLD-Specific Rules

### File structure
One multi-page `.drawio` file per location:
- `diagrams/reference/<problem>/<problem>.drawio` — 4 named pages: `class-diagram`, `sequence-diagram`, `use-case-diagram`, `object-diagram`
- `diagrams/practice/<problem>/<problem>_practice.drawio` — 4 stub pages (same names), each with a yellow instruction banner only

Never generate separate per-diagram `.drawio` files.

### Swimlane (class box) heights
The swimlane container `height` must equal the sum of all child cell heights. Underestimating causes child cells to overflow outside the box.
Formula: `height = startSize(26) + attributes_height + divider_height(8) + methods_height`
Example: 4 attributes at ~17px each = 68px, round up to 74. 3 methods = 56px. Total = 26 + 74 + 8 + 56 = 164.

### Divider line between attributes and methods
Always add a `line` cell as a horizontal divider inside each swimlane:
```xml
<mxCell id="Xd" value="" style="line;strokeColor=#aaaaaa;" parent="<swimlane_id>" vertex="1">
    <mxGeometry y="<startSize + attrs_height>" width="<swimlane_width>" height="8" as="geometry"/>
</mxCell>
```

### Relationship arrows (class diagrams)
Always specify explicit `exitX/Y` and `entryX/Y` on every edge so arrows connect at correct anchor points and route cleanly around boxes:
```xml
style="edgeStyle=orthogonalEdgeStyle;endArrow=diamondThin;endFill=1;
       exitX=0;exitY=0.5;exitDx=0;exitDy=0;
       entryX=1;entryY=0.5;entryDx=0;entryDy=0;"
```

### Sequence diagram lifelines
Lifelines must use explicit `sourcePoint`/`targetPoint` coordinates — not `Array/points`:
```xml
<mxCell id="l1" value="" style="endArrow=none;dashed=1;" edge="1" parent="1">
    <mxGeometry relative="1" as="geometry">
        <mxPoint x="130" y="120" as="sourcePoint"/>
        <mxPoint x="130" y="700" as="targetPoint"/>
    </mxGeometry>
</mxCell>
```

### Sequence diagram messages
Message arrows must use explicit coordinate points — not `source`/`target` references to lifeline cells:
```xml
<mxCell id="m1" value="1: methodCall()" style="endArrow=block;endFill=1;html=1;" edge="1" parent="1">
    <mxGeometry relative="1" as="geometry">
        <mxPoint x="130" y="180" as="sourcePoint"/>
        <mxPoint x="370" y="180" as="targetPoint"/>
    </mxGeometry>
</mxCell>
```
- Synchronous call: `endArrow=block;endFill=1`
- Return message: `endArrow=open;endFill=0;dashed=1`

### Layout spacing
- Class diagram: minimum 140px horizontal gap between swimlanes, minimum 100px vertical gap between rows
- Sequence diagram: minimum 240px horizontal gap between lifelines, minimum 50px vertical gap between messages
