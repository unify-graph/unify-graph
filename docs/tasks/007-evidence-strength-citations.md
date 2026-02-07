# Task: Evidence Strength on Individual Citations

## Goal
Add granular strength/confidence scoring to individual evidence citations (not just entity-level summary). Enable filtering/sorting by citation quality.

## Approach
1. Add `strength: "primary" | "secondary" | "tertiary"` field to `#EvidenceCitation` schema
2. Define strength levels: primary (direct mention/authorship), secondary (party/subject), tertiary (page number only)
3. Classify existing 150+ citations by strength (audit sample of 20, extrapolate patterns)
4. Add optional `context` field: quoted excerpt or page range supporting strength classification
5. Implement citation sort/filter in evidence inspector panel (show primary first, hide tertiary by default)
6. Update evidence dependency map visualization to color-code by strength (thickness = strength)
7. Export statistics: count by strength, distribution heatmap

## Files to Create/Modify
- `schema.cue` — add `strength` and `context` fields to EvidenceCitation
- Evidence citation files — classify and update existing citations
- `site/index.html` — sort/filter controls in evidence panel
- `site/js/views/evidence-map.js` — update arc/edge thickness based on strength
- `site/data/statistics.json` — add strength distribution stats

## Dependencies
- Evidence citations exist and are accessible in CUE (already done)
- Initial strength classification can be heuristic (improved iteratively)

## Effort
M (1-2 days: schema update, citation audit/classification, UI controls, viz update)
