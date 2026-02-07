# Task: SKOS Vocabulary for Cluster Taxonomy

## Goal
Create SKOS (Simple Knowledge Organization System) vocabulary defining manual clusters and algorithmic communities as interoperable concept schemes.

## Approach
1. Define SKOS ConceptScheme for manual clusters (19 total: C0-C18, each with label, definition, broader/narrower relations)
2. Define SKOS ConceptScheme for algorithmic communities (12 detected by NetworkX, map to manual clusters where overlap exists)
3. Create RDF/SKOS export (RDF/XML or Turtle format) representing both hierarchies
4. Add semantic relationships: `skos:closeMatch` between manual/algorithmic equivalents, `skos:broader`/`skos:narrower` for family hierarchies
5. Publish SKOS namespace under project domain (or GitHub Pages subpath)
6. Update JSON-LD exports to include SKOS concept URIs
7. Add SKOS validation in CI pipeline (QVST or similar RDF validator)

## Files to Create/Modify
- `cluster-taxonomy.skos.rdf` (new) — SKOS RDF/XML export of both cluster schemes
- `scripts/skos_export.py` (new) — generate SKOS from CUE cluster definitions
- `site/skos/` (new) — host SKOS namespace and web resolvable URIs
- `build.sh` — add SKOS export step
- `.gitlab-ci.yml` / `.github/workflows/` — add SKOS validation step
- Project README — document SKOS availability and mapping methodology

## Dependencies
- CUE cluster definitions (already exist)
- NetworkX community data (already generated)
- SKOS knowledge (relatively standard RDF vocabulary)

## Effort
S (1-2 days: SKOS schema creation, export script, publication setup)
