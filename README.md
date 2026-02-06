# Epstein Network — CUE Investigation Model

Every other Epstein network project asks **"what do we know?"** — indexing documents, extracting names, rendering who-knows-whom graphs. There are [15+ of them](https://github.com/topics/epstein-files) now, from DugganUSA's 71k-document search engine to SomaliScan's 1.5M-node graph.

This project asks **"what don't we know?"**

It uses [CUE](https://cuelang.org)'s type system as an investigative tool, where schema violations surface actionable leads:

- **Dangling references** = unknown persons of interest
- **Missing evidence fields** = unverified claims that need document citations
- **Type inconsistencies** = logical gaps (e.g. `FinancialEnabler` entities with no documented financial flows)
- **Cluster isolation** = entities disconnected from their own community

The result: 132 entities modeled in depth, where the data model itself tells you what to investigate next.

## Why CUE?

CUE is a configuration language with types, constraints, and unification — designed for infrastructure-as-code, not journalism. That's what makes it interesting here.

Most network analyses start with raw data and compute metrics at query time or in the browser. This project defines a **typed schema** for entities, connections, evidence, and financial flows, then lets CUE's compiler do the analysis:

- `cue vet` catches referential integrity errors — if you reference a connection that doesn't exist, it fails. That failure is a lead.
- `cue export` unifies all data and pre-computes every metric (gap counts, bridge analysis, BFS hop distance, exposure cascades) into static JSON. The browser does zero computation.
- Adding an entity means satisfying the schema — you must declare a cluster, connection set, and evidence map. Empty evidence maps are valid but flagged.

```
*.cue files  →  cue vet  →  cue export  →  JSON  →  static D3 site
```

**132 curated entities vs. 1.5M extracted nodes** is a deliberate tradeoff. NLP extraction gives breadth — name co-occurrence across thousands of documents. Typed modeling gives depth — every connection is directional, every evidence citation resolves to a document ID, every gap is classified and ranked. Both are useful. This is the depth side.

## What it found

- **11.4% evidence coverage** — 15 of 132 entities have linked evidence. 117 are structurally modeled but unverified.
- **35 entities with 100+ corpus mentions but zero evidence** — the banking sector dominates: Deutsche Bank, JP Morgan, Bank of America all have 1000+ mentions in the DOJ corpus, zero evidence citations.
- **44 sole connector pairs** — cluster pairs that depend on a single entity as their only bridge. Virginia Giuffre is the sole bridge between the victim cluster and three other worlds. Remove her testimony, those connections vanish.
- **100% reachable within 2 hops** — every entity in the model is reachable from Epstein in 2 or fewer steps. Small world.
- **Maxwell cascade: 127/132** — if Maxwell cooperated, 127 of 132 entities would be within 2 degrees of exposure.

## Graph analysis: infrastructure patterns adapted

The analysis layer adapts patterns from infrastructure dependency analysis (fan-in, cascade failure, SPOF detection) to investigative network modeling:

| Infrastructure Pattern | Investigation Adaptation |
|----------------------|--------------------------|
| Transitive dependency closure (DAG) | BFS hop distance (cycle-safe, 4 waves) |
| Blast radius: what breaks if X goes down | Exposure cascade: who's at risk if X cooperates |
| Single points of failure | Sole connectors: only bridge between cluster pairs |
| Health/degradation propagation | Evidence integrity: if a document is discredited, which entities lose their evidence base |

Key difference: infrastructure graphs are directed acyclic (`depends_on`). Social networks are bidirectional and cyclic. Solved by pre-computing an undirected adjacency matrix and using BFS waves instead of transitive closure.

## Visualization

Four views, all rendering pre-computed JSON:

1. **Force Graph + Entity Inspector** — click any node to see known info, gaps, and investigative leads
2. **Gap Dashboard** — sortable table of all entities with gap category filters
3. **Sole Connectors** — entities that are the only bridge between two cluster worlds
4. **Exposure Cascade** — if entity X cooperates, who's exposed at wave 1 (direct) and wave 2 (second-degree)

### Reading the graph

- **Node size** = total connection degree
- **Node opacity** = evidence coverage (opaque = has evidence, ghost = unverified)
- **Node ring** = gap severity (red = 3+ gaps, orange = 1-2 gaps)
- **Edge style** = solid (bidirectional) / dashed (one-way claim)

## Build & run

Requires [CUE](https://cuelang.org/docs/install/).

```bash
./build.sh                              # validate + export
python3 -m http.server -d site 8080     # serve locally
```

## Data pipeline

| Export | Contents |
|--------|----------|
| `graph` | D3-ready node-link format with gap flags, bridge analysis, reciprocity |
| `insights` | Top bridges, research priorities, multi-flag entities, cluster connectivity |
| `analysis` | Hop distance (BFS), sole connectors, exposure cascades, evidence chains |
| `report` | Gap analysis — dangling connections, missing evidence, orphans, type inconsistencies |
| `entities` / `flows` / `documents` | Raw data |

## Data sources

- DOJ EFTA Release documents (OCR corpus, 71k+ documents)
- [DugganUSA](https://analytics.dugganusa.com/epstein/) Epstein Files search API
- Public court filings and reporting

## Structure

```
*.cue                  CUE source of truth
  vocab.cue            Schemas (#Entity, #Document, #Flow, #Event)
  validate.cue         10 validation checks, report export
  exports.cue          Graph/insights exports with CUE unification
  analysis.cue         BFS reachability, sole connectors, exposure cascades
  people.cue           Person entities
  organizations.cue    Organization entities
  financial_*.cue      Financial institution entities
  properties.cue       Property entities

site/                  Static visualization
  index.html           D3 force graph + inspector + dashboards
  data/*.json          Pre-computed exports (generated by build.sh)

build.sh               Validate + export pipeline
```

## Contributing

Open data project. The CUE data model uses open structs (`...`) so new fields can be added without schema changes.

To add entities, evidence, or connections: edit the relevant `.cue` file and run `./build.sh`. CUE will tell you if your additions break referential integrity — and that's the point.
