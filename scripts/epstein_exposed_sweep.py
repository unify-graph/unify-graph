#!/usr/bin/env python3
"""Match unify-graph entities against the Epstein Exposed API.

Paginates https://epsteinexposed.com/api/v1/persons, matches against
the 132 entities in unify-graph (exact then fuzzy), and emits a CUE
overlay file to stdout.

Usage:
  python3 scripts/epstein_exposed_sweep.py             # emit CUE overlay
  python3 scripts/epstein_exposed_sweep.py --dry-run   # preview matches only

API: https://epsteinexposed.com/api/v1/persons
No authentication required. Rate limit: 100 req/min.
"""
import difflib
import json
import pathlib
import subprocess
import sys
import time
import urllib.error
import urllib.request

API_BASE = "https://epsteinexposed.com/api/v1/persons"
UA = "unify-graph/1.0 (Epstein network research)"
PER_PAGE = 100
RATE_DELAY = 0.7  # seconds between paginated requests
FUZZY_THRESHOLD = 0.85


def fetch_page(page):
    """Fetch a single page of persons from the API."""
    url = f"{API_BASE}?page={page}&per_page={PER_PAGE}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=20) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        print(f"  HTTP {e.code}: {e.reason}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"  ERROR fetching page {page}: {e}", file=sys.stderr)
        return None


def fetch_all_persons():
    """Paginate through all persons. Returns list of person dicts."""
    persons = []

    print("Fetching page 1...", file=sys.stderr)
    first = fetch_page(1)
    if first is None:
        print("ERROR: Could not reach Epstein Exposed API. Is it down?",
              file=sys.stderr)
        sys.exit(1)

    if first.get("status") != "ok":
        print(f"ERROR: Unexpected API status: {first.get('status')}",
              file=sys.stderr)
        sys.exit(1)

    persons.extend(first.get("data", []))
    meta = first.get("meta", {})
    total = meta.get("total", 0)
    total_pages = (total + PER_PAGE - 1) // PER_PAGE

    print(f"  {total} persons across {total_pages} pages", file=sys.stderr)

    for page in range(2, total_pages + 1):
        time.sleep(RATE_DELAY)
        print(f"Fetching page {page}/{total_pages}...", file=sys.stderr)
        result = fetch_page(page)
        if result is None:
            print(f"  WARNING: Failed to fetch page {page}, skipping",
                  file=sys.stderr)
            continue
        persons.extend(result.get("data", []))

    print(f"  Fetched {len(persons)} persons total\n", file=sys.stderr)
    return persons


def load_entities():
    """Load entity list from CUE export."""
    try:
        proc = subprocess.run(
            ["cue", "export", "-e", "graph.nodes", "./..."],
            capture_output=True, text=True, timeout=30,
            cwd=str(pathlib.Path(__file__).resolve().parent.parent),
        )
        if proc.returncode != 0:
            print(f"ERROR: cue export failed:\n{proc.stderr}", file=sys.stderr)
            sys.exit(1)
        nodes = json.loads(proc.stdout)
    except FileNotFoundError:
        print("ERROR: 'cue' not found. Is CUE installed?", file=sys.stderr)
        sys.exit(1)
    except subprocess.TimeoutExpired:
        print("ERROR: cue export timed out", file=sys.stderr)
        sys.exit(1)

    entities = {}
    for node in nodes:
        entities[node["id"]] = node["name"]
    return entities


def match_entities(entities, persons):
    """Match entities to API persons. Returns dict of entity_id -> person."""
    # Build lookup: lowercase name -> list of persons
    name_index = {}
    for p in persons:
        key = p.get("name", "").strip().lower()
        if key:
            name_index.setdefault(key, []).append(p)

    matches = {}
    unmatched_ids = set(entities.keys())

    # Pass 1: exact (case-insensitive)
    for eid, ename in entities.items():
        normalized = ename.strip().lower()
        if normalized in name_index:
            matches[eid] = {
                "person": name_index[normalized][0],
                "method": "exact",
                "score": 1.0,
            }
            unmatched_ids.discard(eid)

    # Pass 2: fuzzy on remaining
    person_names = list(name_index.keys())
    for eid in list(unmatched_ids):
        ename = entities[eid].strip().lower()
        best_match = None
        best_score = 0.0

        for pname in person_names:
            score = difflib.SequenceMatcher(None, ename, pname).ratio()
            if score > best_score:
                best_score = score
                best_match = pname

        if best_match and best_score >= FUZZY_THRESHOLD:
            matches[eid] = {
                "person": name_index[best_match][0],
                "method": "fuzzy",
                "score": best_score,
            }
            unmatched_ids.discard(eid)

    return matches, unmatched_ids


def emit_cue(matches):
    """Print CUE overlay to stdout."""
    print("package creeps\n")
    print("entities: {")
    for eid in sorted(matches.keys()):
        m = matches[eid]
        person = m["person"]
        slug = person.get("slug", person.get("id", ""))
        method = m["method"]
        score_note = ""
        if method == "fuzzy":
            score_note = f"  // fuzzy {m['score']:.2f}: \"{person['name']}\""
        print(f'\t{eid}: external_ids: epstein_exposed: "{slug}"{score_note}')
    print("}")


def print_summary(matches, unmatched_ids, entities, persons):
    """Print match summary and top untracked persons to stderr."""
    print(f"\n--- Summary ---", file=sys.stderr)
    print(f"Matched:   {len(matches)}/{len(entities)}", file=sys.stderr)
    print(f"Unmatched: {len(unmatched_ids)}/{len(entities)}", file=sys.stderr)

    exact = sum(1 for m in matches.values() if m["method"] == "exact")
    fuzzy = sum(1 for m in matches.values() if m["method"] == "fuzzy")
    print(f"  Exact:  {exact}", file=sys.stderr)
    print(f"  Fuzzy:  {fuzzy}", file=sys.stderr)

    if unmatched_ids:
        print(f"\nUnmatched entities:", file=sys.stderr)
        for eid in sorted(unmatched_ids):
            print(f"  - {eid} ({entities[eid]})", file=sys.stderr)

    # Top 10 persons in API that we don't track
    matched_slugs = {m["person"].get("slug") for m in matches.values()}
    untracked = [
        p for p in persons
        if p.get("slug") not in matched_slugs
    ]
    # Sort by document + flight count descending
    untracked.sort(
        key=lambda p: (p.get("documentCount", 0) + p.get("flightCount", 0)),
        reverse=True,
    )

    print(f"\nTop 10 API persons NOT in unify-graph:", file=sys.stderr)
    for p in untracked[:10]:
        docs = p.get("documentCount", 0)
        flights = p.get("flightCount", 0)
        cat = p.get("category", "")
        print(f"  {p['name']:<40} docs={docs:<5} flights={flights:<5} ({cat})",
              file=sys.stderr)


def main():
    dry_run = "--dry-run" in sys.argv

    print("Loading entities from CUE...", file=sys.stderr)
    entities = load_entities()
    print(f"  {len(entities)} entities loaded\n", file=sys.stderr)

    persons = fetch_all_persons()
    matches, unmatched_ids = match_entities(entities, persons)

    print_summary(matches, unmatched_ids, entities, persons)

    if dry_run:
        print("\n--- Dry run: matched entities ---", file=sys.stderr)
        for eid in sorted(matches.keys()):
            m = matches[eid]
            p = m["person"]
            docs = p.get("documentCount", 0)
            flights = p.get("flightCount", 0)
            print(f"  {eid:<30} -> {p['name']:<30} [{m['method']} {m['score']:.2f}]"
                  f"  docs={docs} flights={flights}", file=sys.stderr)
        print(f"\n(dry run — no CUE output)", file=sys.stderr)
    else:
        emit_cue(matches)
        print(f"\nCUE overlay written to stdout", file=sys.stderr)


if __name__ == "__main__":
    main()
