# Task: Live DugganUSA Search in Inspector

## Goal
Add interactive DugganUSA API search panel to entity inspector, enabling real-time discovery of documents mentioning the selected entity.

## Approach
1. Create API gateway endpoint (or direct browser fetch if CORS-enabled) for DugganUSA search
2. Add search input + results table to entity inspector (right panel)
3. Fetch documents on entity select, display title/date/relevance
4. Add document detail modal with full text + highlighting
5. Implement "Add to Evidence" button to populate draft evidence_citations entries
6. Cache results in-memory to avoid rate limiting

## Files to Create/Modify
- `site/index.html` — add DugganUSA search panel to inspector UI
- `site/js/main.js` — search handler, cache logic, modal handler
- `site/js/api-gateway.js` (new) — optional API proxy if needed for CORS
- `site/data/networkx.json` — no changes needed

## Dependencies
- DugganUSA API accessible (authenticate via token in inspector, or proxy backend)
- CORS policy allows browser fetch (or proxy backend required)
- Task 003 (DugganUSA bulk sweep) should be complete for context

## Effort
M (2-3 days: UI wiring, API integration, caching, modal implementation)
