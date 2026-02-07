# Task: Jupyter Notebook Companion

## Goal
Create interactive Jupyter notebooks for data exploration, analysis reproduction, and investigative workflows using NetworkX graph data and CUE entities.

## Approach
1. Create `notebooks/exploration.ipynb`: load graph.json, demonstrate NetworkX metrics (betweenness, PageRank, communities)
2. Create `notebooks/investigation-workflow.ipynb`: entity lookup, multi-hop path finding, bottleneck analysis
3. Create `notebooks/evidence-analysis.ipynb`: citation strength distribution, source cross-tabulation, temporal trends
4. Add data loading utilities: `notebooks/lib/unify_graph.py` — helper functions for loading/querying CUE entities and connections
5. Generate HTML exports of notebooks for project documentation site
6. Add notebook setup instructions: requirements, data location, kernel setup

## Files to Create/Modify
- `notebooks/` (new directory) — three starter notebooks
- `notebooks/lib/unify_graph.py` (new) — utility functions
- `notebooks/requirements.txt` — jupyter, matplotlib, networkx, pandas dependencies
- `site/notebooks/` — generated HTML exports linked from main site
- README.md — add link to notebooks section

## Dependencies
- graph.json, networkx.json, external_ids.json must be accessible (in site/data/)
- Jupyter environment setup (separate from build.sh)

## Effort
S (1-2 days: notebook creation, utility library, HTML export setup)
