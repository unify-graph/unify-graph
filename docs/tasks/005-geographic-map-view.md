# Task: Geographic Map View

## Goal
Add interactive map visualization showing properties, residences, and headquarters locations of key entities. Surface location-based clustering and multi-site portfolios.

## Approach
1. Extract geographic entities from CUE: Zorro Ranch, Little St James, 71st Street, Paris apartment, offices (NYC, London, Palm Beach)
2. Add lat/lon coordinates to location entities (CUE schema)
3. Create map view using Leaflet or Mapbox (lightweight, similar to existing D3 stack)
4. Implement entity→location edges visualization (entity icon on map, lines to properties)
5. Add location filter panel (property type, access level, evidence status)
6. Wire map clicks to inspector (location detail, connected entities, evidence)
7. Add timeline filter to show property ownership/access over time

## Files to Create/Modify
- `locations.cue` — new file, entity definitions with lat/lon + access_dates
- `site/index.html` — add map view tab (10th view alongside force graph, etc.)
- `site/js/views/map.js` (new) — Leaflet/Mapbox map initialization and interaction
- `site/data/graph.json` — export location entities if not already included
- Build script may need location geocoding helper

## Dependencies
- Locations identified and geocoded (manual or reverse-geocoding service)
- Map library (Leaflet preferred for ease)
- Timeline view optional but improves context (task 007)

## Effort
M (2-3 days: location data collection, map library integration, filtering UI, inspector wiring)
