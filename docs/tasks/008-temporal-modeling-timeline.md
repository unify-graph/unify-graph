# Task: Temporal Modeling & Timeline View

## Goal
Add date ranges and event timestamps to connections and entities. Create interactive timeline view showing relationship evolution and key events over time.

## Approach
1. Add `date_start`, `date_end` fields to `#Connection` schema (support ranges and uncertain dates)
2. Add `founded_date`, `deceased_date` fields to `#Entity` where applicable
3. Audit existing connections for date information in evidence citations (extract dates from documents)
4. Create timeline view: horizontal scroll with entities positioned by entry date, connections drawn with time ranges
5. Implement date range filter: select year range to show only active connections in window
6. Add event markers for key dates (arrests, deposition, bankruptcy, death, trial)
7. Integrate with geographic map view: animate properties coming online/offline over time

## Files to Create/Modify
- `schema.cue` — add temporal fields (date_start, date_end, date_confidence)
- Connection and entity files — populate date information from evidence
- `site/index.html` — add timeline view tab (11th view)
- `site/js/views/timeline.js` (new) — SVG timeline with D3 time scale
- `site/css/timeline.css` (new) — timeline styling
- `build.sh` — ensure dates exported correctly

## Dependencies
- Evidence citations contain extractable dates (many do, some require manual entry)
- Task 002 (CourtListener) adds docket dates for events
- Task 005 (Geographic map) benefits from property date ranges

## Effort
L (3-4 days: schema updates, date extraction from documents, timeline viz, interaction handlers)
