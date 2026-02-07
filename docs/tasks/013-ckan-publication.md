# Task: Publish Dataset on CKAN

## Goal
Publish unify-graph dataset on CKAN (Comprehensive Knowledge Archive Network) or similar open data platform to increase discoverability and enable federated data pipelines.

## Approach
1. Prepare dataset exports: graph.json, graph.toon, external_ids.json, analysis_export.json, FtM JSONL
2. Create CKAN dataset record with metadata: title, description, tags (Epstein, network-analysis, open-data), frequency (monthly), license (CC-BY-4.0 or similar)
3. Upload files to CKAN or link via GitHub Releases
4. Add dataset DOI (via Zenodo or DataCite if CKAN doesn't provide)
5. Update project README with CKAN/Zenodo citation info and badge
6. Add CKAN harvest metadata to project site (enable automatic indexing)
7. Monitor CKAN for citations and downstream usage

## Files to Create/Modify
- `docs/PUBLICATION.md` (new) — CKAN dataset metadata and access instructions
- `README.md` — add CKAN/DOI badge and citation section
- `.github/workflows/ckan-publish.yml` (new) — auto-publish on release (optional)
- Project LICENSE file — ensure CC-BY-4.0 or equivalent chosen

## Dependencies
- CKAN instance selected (data.world, European Data Portal, national open data portals, etc.)
- Dataset exports finalized (already building)
- License chosen (recommend CC-BY-4.0)

## Effort
S (1-2 days: metadata creation, upload, documentation, citation setup)
