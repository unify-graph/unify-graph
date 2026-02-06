# Epstein Network — CUE Investigation Model

There are [15+ open-source Epstein network projects](https://github.com/topics/epstein-files) now — from [DugganUSA](https://analytics.dugganusa.com/epstein/)'s 71k-document search engine to [Andrew Walsh](https://github.com/Tsardoz)'s AI-powered OCR pipeline to SomaliScan's 1.5M-node graph. They process documents, extract entities, and build relationship graphs at scales this project can't match.

This project does something CUE is suited for that document processing isn't: **typed data modeling where the schema enforces completeness**. It uses [CUE](https://cuelang.org)'s type system so that constraint violations surface as structured leads:

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

## What the model shows

- **Fragility** — 44 cluster pairs depend on a single bridge entity. The graph looks dense but is actually hub-and-spoke. Example: Virginia Giuffre is the only link between the victim cluster and three others (core, allegations, legal). If her testimony is discredited, those connections disappear from the public record. See the [sole connectors view](https://unify-graph.github.io/unify-graph/) and [structural analysis](https://unify-graph.github.io/unify-graph/) for the full SPOF breakdown.
- **Work queue** — 11.4% of entities have linked evidence. Most were added from structural relationships before evidence was linked. The [evidence gap scatter](https://unify-graph.github.io/unify-graph/) shows where to start: entities like Ghislaine Maxwell (15k+ corpus mentions, zero evidence citations) are the highest-priority targets for document linking.
- **Perspective bias** — most connections are one-way. We modeled "Epstein → Deutsche Bank" from investigation records, but Deutsche Bank doesn't connect back — because the model reflects who investigators connected to whom, not mutual relationships. The graph is the investigation's view, not the network's actual topology.

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

Seven views, all rendering pre-computed JSON:

1. **Force Graph + Entity Inspector** — click any node to see known info, gaps, and investigative leads
2. **Gap Dashboard** — sortable table of all entities with gap category filters
3. **Sole Connectors** — entities that are the only bridge between two cluster worlds
4. **Exposure Cascade** — if entity X cooperates, who's exposed at wave 1 (direct) and wave 2 (second-degree)
5. **Evidence Gap Scatter** — corpus mentions vs. evidence citations; high-mention entities with zero evidence are work prioritization targets
6. **Cluster Chord Diagram** — cross-cluster connection volume with SPOF highlighting
7. **Structural Analysis** — clustering coefficient, power asymmetry, cluster density, bridge redundancy, cascading orphans, cluster affinity

### Reading the graph

- **Node size** = total connection degree
- **Node opacity** = evidence coverage (opaque = has evidence, ghost = unverified)
- **Node ring** = gap severity (red = 3+ gaps, orange = 1-2 gaps)
- **Edge style** = solid (bidirectional) / dashed (one-way claim)

## How this compares

These projects fall into layers. Most do 1–3. This project does layer 4 — it consumes outputs from layers 1–3 and adds typed modeling on top.

| Layer | What it does | Projects |
|-------|-------------|----------|
| **1. Archive** | Collect, OCR, and host raw documents | [FULL_EPSTEIN_INDEX](https://github.com/theelderemo/FULL_EPSTEIN_INDEX), [epstein-docs](https://github.com/epstein-docs/epstein-docs.github.io) |
| **2. Search** | Full-text search + entity tagging over the corpus | [DugganUSA](https://analytics.dugganusa.com/epstein/), [epstein-archive](https://github.com/ErikVeland/epstein-archive), [Epstein Files Project](https://github.com/Tsardoz) |
| **3. Extract → Visualize** | NLP/LLM extracts entities from documents, renders a graph | [phelix001](https://github.com/phelix001/epstein-network), [maxandrews](https://github.com/maxandrews/Epstein-doc-explorer), [SvetimFM](https://github.com/SvetimFM/epstein-files-visualizations), [OWL-DOJ](https://github.com/consigcody94/OWL-DOJ-Epstein-Analysis), [DanHouseman](https://github.com/DanHouseman/epstein-files-analysis) |
| **4. Typed model → Schema enforcement** | CUE type system enforces completeness; constraint violations = structured leads | **unify-graph** |

### Different tool, different job

Most projects in this space start from documents:

```
Documents → OCR → NLP/LLM → Entities → Graph
```

They differ in scale (47 entities to 1.5M nodes), extraction method (regex to Claude AI), and visualization (2D force to 3D cloud). CUE can't compete at document processing — that's not what it's for.

This project starts from a hand-curated model and adds what CUE *is* good at — referential integrity, type constraints, and pre-computed derived metrics:

```
Entities → Typed Schema → Constraint Violations → Structured leads
```

132 entities modeled in CUE. The compiler enforces that every reference resolves, every type is consistent, every constraint is satisfied. When something *doesn't* satisfy the schema, that's not a bug — it's a lead:

- **Dangling reference** → someone mentions a person not yet modeled. Who are they?
- **Empty evidence map** → entity exists in the graph but no document citation. Unverified.
- **FinancialEnabler with no flows** → the type says they moved money but no flow is documented.
- **Sole connector** → one person is the only bridge between two clusters. Discredit them, the connection vanishes.
- **Exposure cascade** → pre-computed BFS: if X cooperates, who's within 2 degrees? High reach is expected in hub-and-spoke networks — the value is identifying who's NOT reachable.

### Detailed comparison

| | DugganUSA | phelix001 | maxandrews | SvetimFM | OWL-DOJ | epstein-archive | FULL_EPSTEIN_INDEX | **unify-graph** |
|---|---|---|---|---|---|---|---|---|
| **Layer** | Search | Extract→Viz | Extract→Viz | Extract→Viz | Extract→Viz | Search | Archive | **Typed model** |
| **Core question** | What's in the docs? | Who connects? | What relationships? | What clusters? | Sufficient for conviction? | What's in the corpus? | Where are the files? | **What's incomplete?** |
| **Docs indexed** | 71k+ | 19,154 | House Oversight | 69k chunks | 14,674 | 51k+ | ~20k pages + DOJ + FBI | Consumes DugganUSA API |
| **Entities** | — | 47 | 15k+ triples | 31 | 30+ | 86k | — | **132 (typed, curated)** |
| **Entity method** | API search results | pdfplumber + regex | Claude AI + dedup | Ollama embeddings | OWL autonomous | NLP pipeline | OCR text | **Human-authored CUE schemas** |
| **Analysis** | Preset visualizations | Co-occurrence | Cluster filtering | Embedding clusters, RAG | Legal framework | Full-text search | — | **Sole connectors, exposure cascades, evidence chains, BFS, clustering coefficient, structural analysis** |
| **Completeness enforcement** | — | — | — | — | — | — | — | **CUE type constraints** |
| **Tech** | Custom backend | Python + vis-network | React + Claude + SQLite | Python + Plotly + Ollama | Vanilla JS + D3 | React + Express + SQLite | CSV + GDrive | **CUE + D3 (static, zero backend)** |

### Complementary, not competing

This project consumes DugganUSA's API (via `scripts/discover.py`) to get corpus mention counts for each entity. Layer 1–3 projects tell you what's *in* the documents. This project adds typed modeling on top — enforcing completeness requirements that surface what's still incomplete. It depends on those layers, not replaces them.

See the [full interactive comparison](https://unify-graph.github.io/unify-graph/compare.html) on the project site.

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
  analysis.cue         BFS reachability, sole connectors, exposure cascades, structural analysis
  people.cue           Person entities
  organizations.cue    Organization entities
  financial_*.cue      Financial institution entities
  properties.cue       Property entities

site/                  Static visualization
  index.html           D3 force graph + inspector + 7 dashboard views
  compare.html         Comparison page vs other Epstein projects
  data/*.json          Pre-computed exports (generated by build.sh)

build.sh               Validate + export pipeline
```

## Contributing

Open data project. The CUE data model uses open structs (`...`) so new fields can be added without schema changes.

To add entities, evidence, or connections: edit the relevant `.cue` file and run `./build.sh`. CUE will tell you if your additions break referential integrity — and that's the point.
