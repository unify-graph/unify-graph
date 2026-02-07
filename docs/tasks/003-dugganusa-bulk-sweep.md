# Task: DugganUSA Bulk Sweep & Reconciliation

## Goal
Systematically query all 132 entities against DugganUSA API to discover missing evidence and relationships, then reconcile results into CUE.

## Approach
1. Batch query DugganUSA for entities not yet in evidence_citations (50+ entities with zero mentions)
2. Fetch full document metadata and entity mention context
3. Classify new mentions: primary evidence vs peripheral (author, subject line, page mention)
4. Create JSON reconciliation report (new entities, new connections, confidence scores)
5. Manually review high-confidence new connections and primary evidence
6. Commit approved citations to CUE (new evidence_citations entries, optionally new entities)
7. Wire live DugganUSA search into inspector (task 005)

## Files to Create/Modify
- `scripts/dugganusa_bulk_sweep.py` — iterate all entities, fetch full metadata, classify mentions
- `site/data/dugganusa_reconciliation.json` — generated report (new citations, confidence scores)
- `evidence_citations.cue` — add approved new citations with source="DugganUSA"
- Document reconciliation decisions in comments/PR description

## Dependencies
- DugganUSA API access + rate limiting strategy
- Contact Patrick Duggan (task 008) to discuss bulk sweep scope
- Existing 132 entities defined in CUE

## Effort
M (2-3 days: API iteration, reconciliation logic, manual review, CUE updates)
