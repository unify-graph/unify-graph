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

Table of entities that are the only bridge between two cluster worlds. Ranked by pair count. Epstein bridges 6 pairs, Trump 3, Giuffre 3.

### 4. Exposure Cascade View

Pre-computed scenarios: if entity X cooperates, wave 1 (direct testimony exposure) and wave 2 (second-degree) counts. Maxwell cascade: 127/132 entities within 2 hops.

## Key Findings (from CUE analysis)

### Network Structure
- 132 entities, 398 links (292 bidirectional, 106 unidirectional)
- 100% reachable from Epstein within 2 hops (small world)
- Epstein: degree 177 (57 out, 120 in), bridges all 16 non-core clusters

### Sole Connectors (investigation critical)
- 44 cluster pairs depend on a single entity
- Kathryn Ruemmler: sole legal↔banking bridge
- Donald Barr: sole family↔doj bridge
- Virginia Giuffre: sole victim↔core, victim↔allegations, victim↔legal bridge

### Research Priority Stack
- 35 entities with 100+ corpus mentions but zero evidence
- Banking sector dominates: Deutsche Bank, JP Morgan, Bank of America all 1000+ mentions, zero evidence linked
- Maxwell: 15,306 corpus mentions, zero evidence citations

### Evidence Coverage
- 11.4% (15/132 entities have evidence)
- 20 entities in 3+ gap categories simultaneously
- 3 entities in all 4 categories (Mort Zuckerman, Andrew Farkas, Tom Pritzker)

## Data Model Review

Per brainstorming decision: review suitability of data model regularly. Check:
- Are cluster assignments still appropriate as entities are researched?
- Are `@type` tags meaningful or should new types be added?
- Is the `#Entity` schema open enough for entity-specific fields?
- Should `#EvidenceStrength` be applied to individual evidence citations?

## Future Work

- JSON-LD `@context` for semantic web interoperability
- Jupyter notebook for NetworkX analysis (betweenness centrality, community detection)
- Live DugganUSA API integration (search directly from inspector)
- Timeline view (events with temporal ordering)
- TOON compact export for token-efficient LLM context
- Role-scoped views (legal, financial, political)
