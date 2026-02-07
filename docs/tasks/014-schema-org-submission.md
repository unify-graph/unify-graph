# Task: Schema.org Submission

## Goal
Submit unify-graph JSON-LD context and dataset schema to Schema.org community group for standardization and interoperability feedback. Contribute vocabulary extensions if needed.

## Approach
1. Audit current JSON-LD context (already in exports.cue and index.html) for Schema.org compatibility
2. Map custom unify: predicates to Schema.org where possible (Person, Organization, Place, CreativeWork, etc.)
3. Document non-standard extensions with rationale (e.g., unify:bottleneckScore for network analysis)
4. Create Schema.org issue/proposal on GitHub: outline custom vocabulary, request community feedback
5. Add link to Schema.org issue in project README (encourage citation and discussion)
6. Update JSON-LD context with versioning and issue tracker reference
7. Monitor Schema.org discussions for vocabulary standardization opportunities

## Files to Create/Modify
- `docs/SCHEMA-ORG.md` (new) — mapping of unify: to Schema.org, non-standard extensions, rationale
- `site/context.jsonld` — add version and GitHub issue link in context metadata
- `README.md` — add section on Schema.org interoperability
- GitHub repo: create discussion or link to Schema.org proposal

## Dependencies
- Current JSON-LD context validated and finalized
- Understanding of Schema.org extension process (relatively lightweight)

## Effort
S (1-2 days: audit, issue creation, documentation)
