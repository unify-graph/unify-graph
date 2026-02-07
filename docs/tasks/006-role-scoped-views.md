# Task: Role-Scoped Views (Legal, Financial, Political)

## Goal
Create filtered graph exports and views that isolate specific domains: legal proceedings, financial flows, political connections. Enable domain-specific analysis.

## Approach
1. Add `domain` field to `#Connection` and `#Entity` schemas (legal, financial, political, personal, organizational)
2. Classify all 398 connections into domains based on relationship type
3. Create export filters: `cue export -e legal_graph`, `cue export -e financial_graph`, etc.
4. Implement domain toggle in force graph UI (switch between full graph / filtered views)
5. Create summary cards for each domain (entity/connection counts, key bottlenecks)
6. Wire inspector to show only same-domain connections when domain filter active
7. Export separate GEXF/GraphML per domain for domain-specific analysis tools

## Files to Create/Modify
- `schema.cue` — add `domain` field to Connection and optionally Entity
- `*.cue` entity files — classify existing connections (bulk edit)
- `exports.cue` — new export definitions for legal_graph, financial_graph, political_graph
- `build.sh` — export domain-scoped JSON/GEXF/GraphML files
- `site/index.html` — domain toggle UI in force graph legend
- `site/js/views/force-graph.js` — filter logic on domain change

## Dependencies
- All connections classified by domain (manual review required)
- Schema changes committed first (backward compatible)

## Effort
M (2-3 days: schema updates, connection classification, export logic, UI wiring)
