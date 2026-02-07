# Task: CourtListener Case Integration

## Goal
Add case IDs and case documents from CourtListener API to legal entities and proceedings, enriching evidence citations with court records.

## Approach
1. Query CourtListener API for entities with legal involvement (SDNY, state courts, USVI AG)
2. Match case numbers in existing evidence citations to CourtListener case_id
3. Fetch case metadata (parties, dates, opinion URLs) and store as external_ids
4. Create `evidence_citations.cue` overlay with case documents and briefs
5. Add CourtListener document links to evidence inspector
6. Surface case milestones in timeline view (docket dates)

## Files to Create/Modify
- `scripts/courtlistener_lookup.py` — API wrapper for case search
- `external_ids.cue` — add `courtlistener_case_id`, `courtlistener_docket_id` fields
- New evidence citations linking to case documents
- `site/index.html` — case document links in evidence detail panel

## Dependencies
- CourtListener API key (free public access)
- Existing evidence citations must contain parseable case numbers
- Timeline view must support temporal evidence (task 007)

## Effort
M (2-3 days: API integration, case matching, evidence linking)
