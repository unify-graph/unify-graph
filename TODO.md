# unify-graph TODO

Prioritized roadmap. Top sections are highest impact / lowest effort.

---

## P0 — Quick wins (data quality) ✓

- [x] Fill remaining 21 Wikidata QIDs → 115/132 reconciled, 17 confirmed no entry
- [x] Review `@type` tags for sufficiency → 15 fixes across entities and orgs
- [x] Add `#EvidenceStrength` to individual evidence citations → schema + 18 annotations
- [x] Reconcile DugganUSA discovery results → `scripts/reconcile_discovery.py` ready

## P1 — External ID enrichment

- [ ] Query OpenCorporates for corporate entities (J. Epstein & Co, Southern Trust, etc.)
- [ ] Query LittleSis for relationship cross-referencing
- [ ] Cross-reference against OpenSanctions dataset
- [ ] Add CourtListener case IDs for legal entities / proceedings
- [ ] Query CourtListener API for case documents

## P2 — Visualization — new views

- [ ] Evidence dependency Sankey: if a document is discredited, who loses their evidence base?
- [ ] Geographic map: properties (Zorro Ranch, Little St James, 71st Street, Paris apartment)
- [ ] Live DugganUSA API search from inspector panel (query on entity select)

## P3 — Schema & export

- [ ] Role-scoped views (legal, financial, political — filtered graph exports)
- [ ] Temporal modeling — add date ranges to connections for timeline view
- [ ] SKOS vocabulary for cluster taxonomy (ConceptScheme for manual clusters + algorithmic communities)
- [ ] FollowTheMoney (FtM) schema alignment — OCCRP/Aleph interoperability

## P4 — Outreach & publishing

- [ ] Publish dataset on CKAN or similar open data platform
- [ ] Submit JSON-LD context to Schema.org community group for review
- [ ] Contact Patrick Duggan (DugganUSA) — introduce project, discuss API collaboration

## P5 — Longer term

- [ ] Multi-source provenance tracking — which API/source contributed each fact
- [ ] Jupyter notebook companion (interactive analysis using NetworkX data)

---

## Completed

- [x] CUE model: 132 entities, 398 connections, 19 clusters
- [x] Force graph + entity inspector
- [x] Gap dashboard with category filters
- [x] Sole connectors table
- [x] Exposure cascade cards
- [x] Evidence gap scatter plot (mention count vs evidence)
- [x] Cluster chord diagram (SPOF highlighting)
- [x] Structural analysis tab (clustering coefficient, power asymmetry, density, cascading orphans)
- [x] Bottleneck ranking sub-tab (composite score)
- [x] Radial BFS visualization (concentric ring layout from Epstein)
- [x] Multi-wave cascade failure analysis in CUE (wave 0/1/2)
- [x] Network resilience aggregates in CUE
- [x] JSON-LD `@context` (context.jsonld + exports.cue integration)
- [x] Google Dataset Search metadata (JSON-LD in index.html)
- [x] `external_ids` field added to `#Entity` schema
- [x] Wikidata QIDs for 111/132 entities (`external_ids.cue` overlay)
- [x] Wikidata reconciliation script + CI job
- [x] Wikidata SPARQL enrichment script
- [x] ProPublica 990 enrichment, surfaced in inspector
- [x] NetworkX analysis script (betweenness, PageRank, eigenvector, communities, k-core)
- [x] NetworkX wired into `build.sh` + CI pipeline
- [x] NetworkX data integrated into entity inspector
- [x] Force graph color mode toggle (clusters / communities / bottleneck heatmap)
- [x] Community vs cluster disagreement counter in legend
- [x] TOON compact export (25KB vs 198KB)
- [x] DugganUSA API discovery scripts (discover.py, discover2.py)
- [x] compare.html — project comparison page
- [x] Dual deployment: GitLab Pages + GitHub Pages
- [x] README honest framing (CUE strengths, not uniqueness claims)
- [x] `requirements.txt` for Python deps
- [x] Wikidata QIDs 115/132 (4 new: brad_edwards, dechert_llp, east_71st, rothschild_geneva)
- [x] @type review: 15 fixes (LegalProtection, Recruiter, GovernmentOfficial, Allegations, CoreNetwork)
- [x] EvidenceStrength per-citation: schema change + 18 typed annotations
- [x] DugganUSA reconciliation script (`scripts/reconcile_discovery.py`)
