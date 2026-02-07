# Task: Multi-Source Provenance Tracking

## Goal
Track which external data source (Wikidata, ProPublica, DugganUSA, CourtListener, OpenCorporates, etc.) contributed each fact, enabling source-scoped filtering and quality auditing.

## Approach
1. Add `source` field to `#EvidenceCitation` schema: string enum (Wikidata, ProPublica, DugganUSA, CourtListener, OpenCorporates, LittleSis, OpenSanctions, Manual, etc.)
2. Add `source_url` field for direct link to external record where applicable
3. Audit existing citations: classify by source (many already have source in comment)
4. Classify new citations from tasks 001-003 by source at import time
5. Update entity inspector: show source badge next to each citation/connection
6. Create provenance dashboard: source distribution pie chart, source quality metrics (error rate, update frequency)
7. Export provenance PROV-JSON alongside graph.json for audit trail

## Files to Create/Modify
- `schema.cue` — add `source` and `source_url` fields to EvidenceCitation
- Evidence citation files — populate source field on all citations
- `site/index.html` — source badge in inspector UI
- `site/js/views/provenance-dashboard.js` (new) — source distribution visualization
- `build.sh` — export PROV-JSON alongside JSON exports
- Scripts from tasks 001-003 — ensure source field populated during import

## Dependencies
- All enrichment tasks (001-003) should populate source field
- Schema change is backward compatible

## Effort
S (1-2 days: schema update, citation audit/classification, UI display, PROV export)
