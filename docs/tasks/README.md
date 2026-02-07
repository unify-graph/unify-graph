# unify-graph Task Plans

Concise task plans for remaining TODO items in unify-graph. Each file follows a standard template: Goal, Approach (numbered steps), Files to Create/Modify, Dependencies, and Effort estimate.

## Task List

### Data Enrichment
- **[001-external-data-enrichment.md](001-external-data-enrichment.md)** — OpenCorporates, LittleSis, OpenSanctions (M)
- **[002-courtlistener-integration.md](002-courtlistener-integration.md)** — CourtListener case IDs and documents (M)
- **[003-dugganusa-bulk-sweep.md](003-dugganusa-bulk-sweep.md)** — Bulk API query for all entities (M)

### Visualization
- **[004-live-dugganusa-search.md](004-live-dugganusa-search.md)** — Real-time search in inspector (M)
- **[005-geographic-map-view.md](005-geographic-map-view.md)** — Property/location map (M)
- **[006-role-scoped-views.md](006-role-scoped-views.md)** — Domain filters (legal/financial/political) (M)
- **[007-evidence-strength-citations.md](007-evidence-strength-citations.md)** — Granular citation scoring (M)
- **[008-temporal-modeling-timeline.md](008-temporal-modeling-timeline.md)** — Timeline view with date ranges (L)

### Schema & Standards
- **[009-skos-cluster-taxonomy.md](009-skos-cluster-taxonomy.md)** — SKOS vocabulary for clusters (S)
- **[011-multi-source-provenance.md](011-multi-source-provenance.md)** — Track data sources per fact (S)

### Companion Tools
- **[010-jupyter-companion-notebook.md](010-jupyter-companion-notebook.md)** — Interactive notebooks for analysis (S)

### Outreach & Community
- **[012-duggan-outreach.md](012-duggan-outreach.md)** — Contact Patrick Duggan (DugganUSA) (S)
- **[013-ckan-publication.md](013-ckan-publication.md)** — Publish on CKAN open data (S)
- **[014-schema-org-submission.md](014-schema-org-submission.md)** — Submit context to Schema.org (S)

## Effort Legend
- **S** = Small (1-2 days)
- **M** = Medium (2-3 days)
- **L** = Large (3-4 days)

## Suggested Sequencing

1. **Foundation layer** (enables others):
   - 012 (Duggan outreach) — unblock 003/004
   - 011 (Provenance) — prepare schema before 001/002/003
   - 007 (Evidence strength) — quick schema addition

2. **Data enrichment** (in parallel):
   - 001, 002, 003 (external data APIs)

3. **Visualization & analysis**:
   - 004 (live search — low effort, high UX value)
   - 005 (geographic map — moderate effort)
   - 006 (role-scoped views — depends on schema changes)
   - 008 (timeline — depends on temporal data from 002/003)
   - 009 (SKOS — can happen anytime)
   - 010 (notebooks — can reference finalized data)

4. **Publication** (final phase):
   - 013, 014 (CKAN, Schema.org — after data/schema mature)
