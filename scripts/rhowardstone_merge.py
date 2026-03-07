#!/usr/bin/env python3
"""Match unify-graph entities against rhowardstone/Epstein-research-data.

Downloads the persons_registry.json from the GitHub repo (~1,500 identified
individuals), matches against our 132 entities, and emits a CUE overlay with
rhowardstone slug IDs.

Usage:
  python3 scripts/rhowardstone_merge.py             # emit CUE to stdout
  python3 scripts/rhowardstone_merge.py --dry-run    # preview matches only
"""
import difflib
import json
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

REGISTRY_URL = (
    "https://raw.githubusercontent.com/rhowardstone/"
    "Epstein-research-data/main/persons_registry.json"
)
UA = "unify-graph/1.0 (Epstein network research)"


def fetch_registry():
    """Download persons_registry.json from GitHub, return parsed list."""
    try:
        req = urllib.request.Request(REGISTRY_URL, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        print(f"ERROR: HTTP {e.code} fetching {REGISTRY_URL}: {e.reason}",
              file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"ERROR: Cannot reach GitHub: {e.reason}", file=sys.stderr)
        print("Check your internet connection or try again later.",
              file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Unexpected error fetching registry: {e}",
              file=sys.stderr)
        sys.exit(1)


def load_local_entities():
    """Run cue export to get our entity list, return list of node dicts."""
    try:
        result = subprocess.run(
            ["cue", "export", "-e", "graph.nodes", "./..."],
            capture_output=True, text=True, timeout=30,
            cwd=str(Path(__file__).resolve().parent.parent),
        )
        if result.returncode != 0:
            print(f"ERROR: cue export failed:\n{result.stderr}",
                  file=sys.stderr)
            sys.exit(1)
        return json.loads(result.stdout)
    except FileNotFoundError:
        print("ERROR: 'cue' command not found. Install CUE first.",
              file=sys.stderr)
        sys.exit(1)
    except subprocess.TimeoutExpired:
        print("ERROR: cue export timed out after 30s.", file=sys.stderr)
        sys.exit(1)


def normalize(name):
    """Lowercase, strip whitespace for comparison."""
    return " ".join(name.lower().split())


def match_entities(local_nodes, registry):
    """Match local entities against registry entries.

    Returns:
        matches: list of (entity_id, entity_name, slug, registry_name, method)
        unmatched_local: list of (entity_id, entity_name)
        unmatched_registry: list of registry entries not matched
    """
    # Build lookup tables from registry
    reg_by_norm = {}        # normalized name -> registry entry
    reg_by_alias = {}       # normalized alias -> registry entry
    for entry in registry:
        name = entry.get("name", "")
        slug = entry.get("slug", "")
        if not name or not slug:
            continue
        # Skip redacted entries like "(b) (6)"
        if name.startswith("(") and ")" in name:
            continue

        norm = normalize(name)
        reg_by_norm[norm] = entry

        for alias in entry.get("aliases", []) or []:
            alias_norm = normalize(alias)
            if alias_norm:
                reg_by_alias[alias_norm] = entry

    # All registry names for fuzzy matching
    reg_names = list(reg_by_norm.keys())

    matches = []
    unmatched_local = []
    matched_slugs = set()

    for node in local_nodes:
        entity_id = node["id"]
        entity_name = node["name"]
        norm_name = normalize(entity_name)

        # Pass 1: exact name match
        if norm_name in reg_by_norm:
            entry = reg_by_norm[norm_name]
            matches.append((entity_id, entity_name, entry["slug"],
                            entry["name"], "exact"))
            matched_slugs.add(entry["slug"])
            continue

        # Pass 2: alias match
        if norm_name in reg_by_alias:
            entry = reg_by_alias[norm_name]
            matches.append((entity_id, entity_name, entry["slug"],
                            entry["name"], "alias"))
            matched_slugs.add(entry["slug"])
            continue

        # Pass 3: fuzzy match against all registry names
        best_matches = difflib.get_close_matches(
            norm_name, reg_names, n=1, cutoff=0.85)
        if best_matches:
            best = best_matches[0]
            entry = reg_by_norm[best]
            ratio = difflib.SequenceMatcher(
                None, norm_name, best).ratio()
            matches.append((entity_id, entity_name, entry["slug"],
                            entry["name"], f"fuzzy({ratio:.2f})"))
            matched_slugs.add(entry["slug"])
            continue

        unmatched_local.append((entity_id, entity_name))

    # Find unmatched registry entries (for discovery)
    unmatched_registry = [
        e for e in registry
        if e.get("slug") and e["slug"] not in matched_slugs
        and not (e.get("name", "").startswith("(") and ")" in e.get("name", ""))
    ]

    return matches, unmatched_local, unmatched_registry


def emit_cue(matches):
    """Print CUE overlay to stdout."""
    print("package creeps")
    print()
    print("entities: {")
    for entity_id, entity_name, slug, reg_name, method in sorted(matches):
        comment = ""
        if method != "exact":
            comment = f"  // {method}: \"{reg_name}\""
        print(f'\t{entity_id}: external_ids: rhowardstone: "{slug}"{comment}')
    print("}")


def print_summary(matches, unmatched_local, unmatched_registry, local_nodes):
    """Print match summary and high-value untracked entities to stderr."""
    total = len(local_nodes)
    matched = len(matches)
    unmatched = len(unmatched_local)

    print(f"\n--- rhowardstone merge summary ---", file=sys.stderr)
    print(f"Local entities:    {total}", file=sys.stderr)
    print(f"Registry entries:  {len(unmatched_registry) + matched} "
          f"(excluding redacted)", file=sys.stderr)
    print(f"Matched:           {matched}/{total} "
          f"({matched * 100 // total}%)", file=sys.stderr)
    print(f"Unmatched local:   {unmatched}", file=sys.stderr)

    if unmatched_local:
        print(f"\nUnmatched local entities:", file=sys.stderr)
        for eid, ename in sorted(unmatched_local):
            print(f"  {eid:<35} {ename}", file=sys.stderr)

    # Match methods breakdown
    methods = {}
    for _, _, _, _, method in matches:
        bucket = method.split("(")[0]
        methods[bucket] = methods.get(bucket, 0) + 1
    print(f"\nMatch methods:", file=sys.stderr)
    for method, count in sorted(methods.items()):
        print(f"  {method:<10} {count}", file=sys.stderr)

    # Top 10 high-connection registry entities we DON'T track
    # Score by metadata mentions if available
    scored = []
    for entry in unmatched_registry:
        name = entry.get("name", "")
        slug = entry.get("slug", "")
        cat = entry.get("category", "")
        sources = entry.get("sources", []) or []
        meta = entry.get("metadata", {}) or {}
        mentions = meta.get("ds10_mentions", 0) if isinstance(meta, dict) else 0

        # Score: number of sources + mention count
        score = len(sources) + (mentions or 0)
        if entry.get("description") or entry.get("involvement"):
            score += 2
        scored.append((score, name, slug, cat, len(sources)))

    scored.sort(reverse=True)
    print(f"\nTop 10 high-signal entities we DON'T track:", file=sys.stderr)
    for score, name, slug, cat, nsrc in scored[:10]:
        print(f"  score={score:<3} {name:<35} cat={cat:<15} "
              f"sources={nsrc}", file=sys.stderr)


def main():
    dry_run = "--dry-run" in sys.argv

    print("Fetching persons registry from GitHub...", file=sys.stderr)
    registry = fetch_registry()
    print(f"  Downloaded {len(registry)} registry entries.", file=sys.stderr)

    print("Loading local entities from CUE...", file=sys.stderr)
    local_nodes = load_local_entities()
    print(f"  Loaded {len(local_nodes)} local entities.", file=sys.stderr)

    print("Matching...", file=sys.stderr)
    matches, unmatched_local, unmatched_registry = match_entities(
        local_nodes, registry)

    print_summary(matches, unmatched_local, unmatched_registry, local_nodes)

    if dry_run:
        print(f"\n--dry-run: showing {len(matches)} matches "
              f"(no CUE output)", file=sys.stderr)
        for eid, ename, slug, rname, method in sorted(matches):
            print(f"  {eid:<35} -> {slug:<35} ({method})",
                  file=sys.stderr)
    else:
        print(f"\nEmitting CUE overlay to stdout...", file=sys.stderr)
        emit_cue(matches)


if __name__ == "__main__":
    main()
