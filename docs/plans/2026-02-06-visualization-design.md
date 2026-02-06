# Epstein Network Visualization — Design Document

## Purpose

Dual-purpose tool:
1. **Investigation engine** — CUE's type system surfaces gaps as structured data (dangling refs = unknown persons, missing evidence = unverified claims, type inconsistencies = logical gaps)
2. **Published dataset** — open data project, exportable as JSON/JSON-LD

## Architecture

### Data Pipeline

CUE is the single source of truth. All visualization data is pre-computed at export time via CUE unification — no joins or computation in JavaScript.

```
*.cue files → cue export → JSON → static site
```

Export expressions:
- `graph` — D3-ready node-link format with per-node gap flags, bridge analysis, reciprocity
- `insights` — top bridges, research priorities, multi-flag entities, cluster connectivity, flows/docs by entity
- `analysis` — hop distance (BFS), sole connectors, exposure cascades, evidence integrity chains
- `report` — gap analysis (dangling connections, missing evidence, orphans, unidirectional, type inconsistencies, cluster isolation, flow evidence gaps)
- `entities` / `flows` / `documents` — raw data

Build: `./build.sh` runs `cue vet` then exports all JSON to `site/data/`.

### Graph Analysis (adapted from quicue.ca patterns)

Standalone adaptations — no dependency on source project:

| Pattern | Infrastructure Origin | Investigation Adaptation |
|---------|----------------------|--------------------------|
| `_ancestors` (rogpeppe fixpoint) | Transitive dependency closure (DAG) | BFS hop distance (cycle-safe, 4 waves) |
| `#BlastRadius` | What breaks if X goes down | Exposure cascade: who's at risk if X cooperates |
| `#SinglePointsOfFailure` | No-redundancy nodes | Sole connectors: only bridge between cluster pairs |
| `#HealthStatus` | Degradation propagation | Evidence integrity: if doc discredited, which entities lose evidence |
| `#VizData` | D3 export format | `graph` export with enriched node metrics |

Key adaptation: infrastructure uses directed DAGs (`depends_on`). Social networks are bidirectional and cyclic. Solved by pre-computing undirected adjacency matrix and using BFS waves instead of transitive closure.

## Visualization Views

### 1. Force Graph + Entity Inspector

- **Node size** = total degree (outbound + inbound connections)
- **Node color** = cluster
- **Node opacity** = evidence coverage (opaque = has evidence, ghost = unverified)
- **Node ring** = gap severity (red = 3+ gaps, orange = 1-2 gaps)
- **Edge style** = solid (bidirectional) / dashed (unidirectional)
- **Click node** → inspector panel with Known / Missing / Leads sections

### 2. Gap Dashboard

Sortable table of all entities with gap category filters. Columns: name, cluster, corpus mentions, degree, gap count, bridge count, reciprocity%, gap types. Click row → switches to graph and selects node.

### 3. Sole Connectors View

Table of entities that are the only bridge between two cluster worlds. Ranked by pair count. These are the fragility points — remove any one and the public record connecting those two worlds disappears.

### 4. Exposure Cascade View

Pre-computed scenarios: if entity X cooperates, wave 1 (direct testimony exposure) and wave 2 (second-degree) counts. High reach numbers are expected in hub-and-spoke networks — the value is identifying which entities are NOT reachable and where cascade paths are fragile (single bridge dependency).

## Current Model State (from CUE analysis)

### Network Structure
- 132 entities, 398 links (292 bidirectional, 106 unidirectional)
- Hub-and-spoke topology centered on Epstein — high reachability is a mathematical consequence of this structure, not an investigative finding
- Almost all connections are one-way, reflecting the investigation's perspective (who was connected to whom), not mutual relationships

### Sole Connectors (genuine structural finding)
- 44 cluster pairs depend on a single bridge entity — discredit that person and the connection between those worlds disappears from the public record
- This is non-obvious: the graph looks dense but is actually fragile
- Examples: Kathryn Ruemmler (legal↔banking), Donald Barr (family↔doj), Virginia Giuffre (victim↔core, victim↔allegations, victim↔legal)

### Evidence Coverage (model completeness, not a finding)
- 11.4% of entities have linked evidence — most were added from structural relationships before evidence was linked
- The gap is the work queue, not a discovery about the network
- The scatter plot shows where to prioritize: high corpus mentions with zero evidence are the best candidates for evidence linking

## Data Model Review

Per brainstorming decision: review suitability of data model regularly. Check:
- Are cluster assignments still appropriate as entities are researched?
- Are `@type` tags meaningful or should new types be added?
- Is the `#Entity` schema open enough for entity-specific fields?
- Should `#EvidenceStrength` be applied to individual evidence citations?

### 5. Evidence Gap Scatter (NEW — pitch visualization)

**Purpose:** Show the gap between DugganUSA corpus presence and documented evidence. High-mention entities with zero evidence are the best candidates for evidence linking — the corpus already found them, so they're the natural next step in the work queue.

**Encoding:**
- X: corpus mention count (symlog scale, 0–31k)
- Y: evidence citation count (linear, jittered at y=0 for visibility)
- Dot size: total connection degree (sqrt scale)
- Dot color: cluster, opacity: evidence status
- Red dashed line at y=0.4 separates DOCUMENTED / UNDOCUMENTED zones
- Labels on high-mention zero-evidence entities (work prioritization targets)
- Click → jump to graph view

**Data:** `graph.json` nodes (mention_count, evidence_count, connection_count, inbound_count, cluster, has_evidence, gap_count)

### 6. Cluster Chord Diagram (NEW — infra-language visualization)

**Purpose:** Network segmentation map. Thick chords = healthy multi-path connectivity. Thin orange dashed chords = SPOFs (sole connector pairs).

**Encoding:**
- Arcs: cluster color, sized by cross-cluster connection volume
- Ribbons: source cluster color at 25% opacity (normal), orange 60% + dashed stroke (SPOF)
- Hover reveals: cluster pair, connection count, SPOF status + bridge entity name
- Labels: cluster name along arc

**Data:** `graph.json` links (compute cluster-pair matrix), `analysis.json` sole_connectors (pairs/by_entity)

## Rejected Alternatives

- **Sankey (financial flows):** DugganUSA already has one. Redundant.
- **Timeline:** Would need temporal data not yet modeled.
- **Treemap (gaps by cluster):** Less immediately legible than scatter.
- **Radial BFS tree:** Interesting but doesn't speak to "what's missing" thesis directly.
- **Adjacency matrix heatmap:** Too abstract for pitch; chord is more striking.

## Future Work

- Radial BFS from Epstein: concentric rings showing hop distance, evidence status
- Evidence dependency Sankey: if a document is discredited, who loses their evidence base
- Geographic map: properties are modeled (Zorro Ranch, Little St James, 71st Street)
- JSON-LD `@context` for semantic web interoperability
- Jupyter notebook for NetworkX analysis (betweenness centrality, community detection)
- Live DugganUSA API integration (search directly from inspector)
- TOON compact export for token-efficient LLM context
- Role-scoped views (legal, financial, political)
