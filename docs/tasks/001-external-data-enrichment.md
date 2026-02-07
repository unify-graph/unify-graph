# Task: External Data Enrichment (OpenCorporates, LittleSis, OpenSanctions)

## Goal
Enrich corporate entities and relationships with validated external datasets. Increase cross-source verification coverage from 114/132 Wikidata QIDs to multi-source external IDs.

## Approach
1. Identify corporate entities in CUE that lack OpenCorporates IDs (J. Epstein & Co, Southern Trust, etc.)
2. Query OpenCorporates API, collect company_ids, store in `external_ids.cue` overlay
3. Query LittleSis for relationship cross-referencing (bulk entity lookup by name)
4. Cross-check against OpenSanctions dataset (sanctions/PEPs match potential entities)
5. Create reconciliation summary (matches/mismatches/new relationships found)
6. Wire results into entity inspector (OpenCorporates link, LittleSis relationships, sanction flags)

## Files to Create/Modify
- `scripts/opencorporates_lookup.py` — batch entity lookup
- `scripts/littlesis_lookup.py` — relationship cross-reference
- `scripts/opensanctions_match.py` — sanctions/PEP matching
- `external_ids.cue` — add `opencorporates_id`, `littlesis_id`, `sanction_flag` fields
- `site/index.html` — display external links in inspector

## Dependencies
- OpenCorporates API access (public, rate-limited)
- LittleSis API key (free tier available)
- OpenSanctions dataset (CSV/JSON export, public)
- `external_ids.cue` schema supports new ID types

## Effort
M (3-4 days: API integration, reconciliation logic, inspector wiring)
