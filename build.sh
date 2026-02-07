#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "Validating CUE model..."
cue vet ./...

echo "Exporting graph data..."
cue export -e graph ./... > site/data/graph.json

echo "Exporting analysis..."
cue export -e analysis ./... > site/data/analysis.json

echo "Exporting insights..."
cue export -e insights ./... > site/data/insights.json

echo "Exporting report..."
cue export -e report ./... > site/data/report.json

echo "Exporting entities..."
cue export -e entities ./... > site/data/entities.json

echo "Exporting flows..."
cue export -e flows ./... > site/data/flows.json

echo "Exporting documents..."
cue export -e documents ./... > site/data/documents.json

echo "Running NetworkX analysis..."
if [ -d ".venv" ]; then
  .venv/bin/python3 scripts/analyze.py
  echo "Generating TOON export..."
  .venv/bin/python3 scripts/toon_export.py
  echo "Generating FtM export..."
  .venv/bin/python3 scripts/ftm_export.py
else
  echo "Warning: .venv not found, skipping NetworkX analysis, TOON, and FtM export"
  echo "Run: python3 -m venv .venv && .venv/bin/pip install -r requirements.txt"
fi

# Copy pre-computed enrichment data (not regenerated on every build)
for f in scripts/wikidata_enriched.json scripts/propublica_enriched.json; do
  if [ -f "$f" ]; then
    cp "$f" "site/data/$(basename "$f")"
    echo "Copied $f → site/data/"
  fi
done

echo ""
echo "Build complete. Data files in site/data/"
echo "Serve with: python3 -m http.server -d site 8080"
echo "Then open: http://localhost:8080"
