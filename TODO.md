# unify-graph TODO

## Build & Pipeline

- [x] Add `scripts/analyze.py` to `build.sh` (run after CUE export, before serve)
- [x] Add `requirements.txt` (networkx, numpy, scipy)
- [x] Add CI step for NetworkX analysis (Python + venv in `.gitlab-ci.yml`)
- [x] Integrate NetworkX output (`site/data/networkx.json`) into site visualizations
- [x] Validate JSON-LD context — fixed undeclared `unify:` prefix, disambiguated FinancialService type collision

## Data Enrichment — External IDs

`external_ids.cue` overlay has 114/132 Wikidata QIDs. 18 entities confirmed no valid Wikidata entry.

- [x] Wikidata QIDs for 111 entities (auto-reconciled + manually disambiguated)
- [x] Reconciliation script (`scripts/wikidata_reconcile.py`) + CI job (`wikidata-reconcile`)
- [x] Fill remaining 21 entities → 3 new matches (dechert_llp, east_71st, rothschild_geneva), 18 confirmed no QID
- [ ] Query OpenCorporates for corporate entities (J. Epstein & Co, Southern Trust, etc.)
- [x] Cross-reference against OpenSanctions dataset — self-hosted yente (civic), 64/132 matched (73 raw - 9 false positives removed). Notable: Liquid Funding in ICIJ Offshore Leaks.
- [x] Query LittleSis for relationship cross-referencing (81/88 matched, CUE overlay generated)
- [x] Add CourtListener case IDs for legal entities / proceedings — 6 case documents, 7 entity IDs

## Data Enrichment — API Integrations

- [x] Query ProPublica Nonprofit Explorer — 4 foundations enriched (Clinton Foundation, Gratitude America, Terramar, Wexner Foundation)
- [x] Query CourtListener API — 6 case documents, 7 entity IDs (Brown v. Maxwell, Giuffre v. Maxwell, US v. Maxwell, etc.)
- [x] Bulk DugganUSA API sweep — 69 entities swept, 65 with new/increased hits, mention_counts updated in CUE
- [x] Reconcile DugganUSA results → CUE evidence citations (177 new citations across 68 entities, evidence coverage 21→79/132)

## Visualization — New Views

- [x] Radial BFS from Epstein: concentric rings showing hop distance, evidence status
- [x] Evidence dependency map: bipartite document↔entity view with blast radius highlighting
- [x] Geographic map: 8 locations with basemap, connections, tooltips (10th view)

## Visualization — Enhancements

- [x] Surface NetworkX metrics in entity inspector (betweenness, PageRank, community, k-core)
- [x] Compare algorithmic communities (12) vs manual clusters (19) — highlight disagreements
- [x] Add community detection overlay to force graph (toggle between manual clusters / algorithmic)
- [x] Color-code bottleneck scores in force graph (heatmap gradient)
- [x] Live DugganUSA API search from inspector panel (CORS enabled, cached, top 10 results)

## Schema & Export

- [x] TOON compact export (`scripts/toon_export.py` → `site/data/graph.toon`, 87% smaller than graph.json)
- [x] Role-scoped views (legal, financial, political — domain filter in force graph)
- [x] Review cluster assignments against NetworkX communities — 73/132 mismatches documented, C0 is mega-community of 45 entities spanning 11 clusters
- [x] Review `@type` tags — audit complete, added Victim/Witness/Informant, fixed 9 entities
- [x] Add `#EvidenceStrength` to individual evidence citations — 15 entities annotated
- [x] Add Google Dataset Search metadata (`<script type="application/ld+json">` in index.html)

## Outreach & Community

- [ ] Contact Patrick Duggan (DugganUSA) — introduce project, discuss API collaboration
- [ ] Publish dataset on CKAN or similar open data platform
- [ ] Submit JSON-LD context to Schema.org community group for review

## Longer Term

- [x] Add SKOS vocabulary for cluster taxonomy (cluster_taxonomy.cue — 20 clusters with hierarchy + domains)
- [x] FollowTheMoney (FtM) schema alignment — OCCRP/Aleph interoperability
- [x] Jupyter notebook companion (exploration.ipynb: centrality, communities, paths, gaps)
- [x] Temporal modeling — 21 entities dated, 18 events, timeline view (11th view)
- [x] Multi-source provenance tracking — #DataSource enum + sources field on #Entity

---

## Completed

- [x] CUE model: 132 entities, 398 connections, 19 clusters
- [x] Force graph + entity inspector
- [x] Gap dashboard with category filters
- [x] Sole connectors table
- [x] Exposure cascade cards
- [x] Evidence gap scatter plot (mention count vs evidence)
- [x] Cluster chord diagram (SPOF highlighting)
- [x] Bottleneck ranking sub-tab (composite score)
- [x] Multi-wave cascade failure analysis in CUE (wave 0/1/2)
- [x] Network resilience aggregates in CUE
- [x] JSON-LD `@context` (context.jsonld + exports.cue integration)
- [x] `external_ids` field added to `#Entity` schema
- [x] Wikidata QIDs for 114/132 entities (`external_ids.cue` overlay) — 18 confirmed no valid QID
- [x] Wikidata reconciliation script + CI job
- [x] NetworkX analysis script (betweenness, PageRank, eigenvector, communities, k-core)
- [x] NetworkX wired into `build.sh` + CI pipeline
- [x] `requirements.txt` for Python deps
- [x] DugganUSA API discovery scripts (discover.py, discover2.py)
- [x] README honest framing (CUE strengths, not uniqueness claims)
- [x] compare.html consistency fixes
- [x] Dual deployment: GitLab Pages + GitHub Pages
- [x] NetworkX data integrated into entity inspector (betweenness, PageRank, eigenvector, k-core, community)
- [x] Force graph color mode toggle (clusters / algorithmic communities / bottleneck heatmap)
- [x] Community vs cluster disagreement counter in legend
- [x] Google Dataset Search metadata (JSON-LD in index.html)
- [x] NetworkX output integrated into site visualizations
- [x] TOON export script + build integration (25KB vs 198KB graph.json)
- [x] JSON-LD validation — prefix fix, type collision fix
- [x] Cluster vs community comparison (73/132 mismatches, C0=45 entities across 11 clusters)
- [x] Doc polish pass — README, compare.html, design doc, about panel all updated for accuracy
- [x] Wikidata QID clickable links in entity inspector
- [x] Radial BFS visualization (8 views total, concentric ring layout from Epstein)
- [x] Financial flows expanded 8 → 20 (Wexner, Dubin, Apollo, Staley, Harris, Rothschild, Laffont, settlements)
- [x] Site polish: canonical URLs, favicon, WCAG contrast, aria-label, robots.txt, sitemap.xml
- [x] ProPublica 990 enrichment (4 foundations: Clinton, Gratitude America, Terramar, Wexner)
- [x] Property evidence citations (6 documents: PBSO, USVI AG, flight logs, MCC death, NM AG, Wexner deed)
- [x] Connection confidence scoring (#ConnectionDetail schema + applied to 4 key entities)
- [x] Top investigative leads callout in gap dashboard (algorithmic: high mentions + zero evidence)
- [x] Connection details (confidence, rel_type, notes) surfaced in inspector
- [x] Evidence dependency map (9th view — bipartite document↔entity with blast radius highlighting)
- [x] Structural signatures analysis (criminology pattern matching — 11 metrics, 6 network type scores)
- [x] GEXF + GraphML exports for Gephi/Cytoscape interoperability
- [x] FtM JSONL export (424 entities: Person, Company, Organization, RealEstate, Airplane, Payment, Document, Family, UnknownLink)
- [x] Signatures sub-tab in Structural view (pattern bars, network metrics, broker table, core members)
- [x] OpenSanctions reconciliation — self-hosted yente (podman pod + ES 8.14.3), civic dataset (4.1M entities), 64/132 matched
- [x] CourtListener integration — 6 case documents (Brown v. Maxwell, Giuffre v. Maxwell, US v. Maxwell, Doe v. Epstein, Edwards v. Epstein), 7 entity IDs
