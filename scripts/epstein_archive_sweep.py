#!/usr/bin/env python3
"""Epstein Document Archive entity reconciliation.

Downloads the entity CSV from epsteininvestigation.org and matches against
the 132 entities in unify-graph, emitting a CUE overlay file with archive IDs.

Usage:
  python3 scripts/epstein_archive_sweep.py             # emit CUE to stdout
  python3 scripts/epstein_archive_sweep.py --dry-run    # preview matches only

Source: https://www.epsteininvestigation.org/api/download/entities
"""
import csv
import difflib
import io
import json
import subprocess
import sys
import urllib.error
import urllib.request

ARCHIVE_URL = "https://www.epsteininvestigation.org/api/download/entities"
UA = "unify-graph/1.0 (Epstein network research)"
FUZZY_THRESHOLD = 0.85


def load_graph_nodes():
    """Load entity list from CUE export."""
    try:
        result = subprocess.run(
            ["cue", "export", "-e", "graph.nodes", "./..."],
            capture_output=True, text=True, check=True,
            cwd="/home/mthdn/unify-graph",
        )
        nodes = json.loads(result.stdout)
        return {n["id"]: n["name"] for n in nodes}
    except subprocess.CalledProcessError as e:
        print(f"ERROR: cue export failed: {e.stderr.strip()}", file=sys.stderr)
        sys.exit(1)
    except (json.JSONDecodeError, KeyError) as e:
        print(f"ERROR: failed to parse CUE output: {e}", file=sys.stderr)
        sys.exit(1)


def download_archive_csv():
    """Download entity CSV from Epstein Document Archive."""
    try:
        req = urllib.request.Request(ARCHIVE_URL, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=30) as resp:
            raw = resp.read().decode("utf-8", errors="replace")
            return raw
    except urllib.error.HTTPError as e:
        print(f"ERROR: Archive API returned HTTP {e.code}: {e.reason}",
              file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"ERROR: Cannot reach archive API: {e.reason}", file=sys.stderr)
        print("  The site may be down. Try again later.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Download failed: {e}", file=sys.stderr)
        sys.exit(1)


def parse_archive_csv(raw_csv):
    """Parse archive CSV into list of dicts.

    Expected columns vary, but we look for an ID column and a name column.
    Returns list of {id, name, doc_count (if available), ...}.
    """
    reader = csv.DictReader(io.StringIO(raw_csv))
    rows = []
    for row in reader:
        # Normalize field names to lowercase
        norm = {k.strip().lower(): v.strip() for k, v in row.items() if k}
        entry = {}

        # Find ID field
        for key in ("id", "entity_id", "entityid"):
            if key in norm:
                entry["id"] = norm[key]
                break
        if "id" not in entry:
            # Fall back to first column
            first_key = list(row.keys())[0].strip().lower() if row else None
            if first_key:
                entry["id"] = row[list(row.keys())[0]].strip()

        # Find name field
        for key in ("name", "entity_name", "entityname", "full_name"):
            if key in norm:
                entry["name"] = norm[key]
                break
        if "name" not in entry:
            # If no name column found, skip
            continue

        # Find document count if available
        for key in ("doc_count", "document_count", "documents", "count", "docs"):
            if key in norm:
                try:
                    entry["doc_count"] = int(norm[key])
                except (ValueError, TypeError):
                    entry["doc_count"] = 0
                break

        if entry.get("name"):
            rows.append(entry)

    return rows


def match_entities(graph_nodes, archive_entries):
    """Match graph entities against archive entries.

    Returns:
      matches: dict of {entity_id: {archive_id, archive_name, method, score}}
      unmatched_graph: list of (entity_id, name) with no match
      unmatched_archive: list of archive entries with no match
    """
    # Build lookup: lowercase name -> archive entry
    archive_by_name = {}
    for entry in archive_entries:
        key = entry["name"].lower().strip()
        archive_by_name[key] = entry

    archive_names_lower = list(archive_by_name.keys())

    matches = {}
    matched_archive_names = set()

    # Pass 1: exact match (case-insensitive)
    for eid, name in sorted(graph_nodes.items()):
        name_lower = name.lower().strip()
        if name_lower in archive_by_name:
            ae = archive_by_name[name_lower]
            matches[eid] = {
                "archive_id": ae.get("id", ""),
                "archive_name": ae["name"],
                "method": "exact",
                "score": 1.0,
                "doc_count": ae.get("doc_count"),
            }
            matched_archive_names.add(name_lower)

    # Pass 2: fuzzy match for remaining
    remaining = {eid: name for eid, name in graph_nodes.items()
                 if eid not in matches}
    remaining_archive = [n for n in archive_names_lower
                         if n not in matched_archive_names]

    for eid, name in sorted(remaining.items()):
        name_lower = name.lower().strip()
        best = difflib.get_close_matches(
            name_lower, remaining_archive, n=1, cutoff=FUZZY_THRESHOLD
        )
        if best:
            match_name = best[0]
            ae = archive_by_name[match_name]
            score = difflib.SequenceMatcher(
                None, name_lower, match_name
            ).ratio()
            matches[eid] = {
                "archive_id": ae.get("id", ""),
                "archive_name": ae["name"],
                "method": "fuzzy",
                "score": round(score, 3),
                "doc_count": ae.get("doc_count"),
            }
            matched_archive_names.add(match_name)
            remaining_archive.remove(match_name)

    unmatched_graph = [(eid, graph_nodes[eid]) for eid in sorted(graph_nodes)
                       if eid not in matches]
    unmatched_archive = [e for e in archive_entries
                         if e["name"].lower().strip() not in matched_archive_names]

    return matches, unmatched_graph, unmatched_archive


def emit_cue(matches):
    """Print CUE overlay to stdout."""
    print("// Epstein Document Archive entity IDs.")
    print("// Source: https://www.epsteininvestigation.org/api/download/entities")
    print("// Auto-generated by scripts/epstein_archive_sweep.py")
    print("package creeps")
    print()
    print("entities: {")
    for eid in sorted(matches.keys()):
        m = matches[eid]
        aid = m["archive_id"]
        if not aid:
            continue
        method_note = ""
        if m["method"] == "fuzzy":
            method_note = f'  // fuzzy {m["score"]:.0%} -> {m["archive_name"]}'
        print(f'\t{eid}: external_ids: epstein_archive: "{aid}"{method_note}')
    print("}")


def print_summary(matches, unmatched_graph, unmatched_archive):
    """Print reconciliation summary to stderr."""
    exact = sum(1 for m in matches.values() if m["method"] == "exact")
    fuzzy = sum(1 for m in matches.values() if m["method"] == "fuzzy")

    print(f"\n--- Epstein Archive Reconciliation ---", file=sys.stderr)
    print(f"Matched:   {len(matches)} ({exact} exact, {fuzzy} fuzzy)",
          file=sys.stderr)
    print(f"Unmatched: {len(unmatched_graph)} graph entities",
          file=sys.stderr)
    print(f"Archive entities not in graph: {len(unmatched_archive)}",
          file=sys.stderr)

    if unmatched_graph:
        # Sort by name; if we have doc_count data from archive near-misses,
        # show that too
        print(f"\nUnmatched graph entities ({len(unmatched_graph)}):",
              file=sys.stderr)
        for eid, name in unmatched_graph[:10]:
            print(f"  {eid:<30} {name}", file=sys.stderr)
        if len(unmatched_graph) > 10:
            print(f"  ... and {len(unmatched_graph) - 10} more",
                  file=sys.stderr)

    # Top archive entities by doc_count not matched to graph
    archive_with_docs = [e for e in unmatched_archive
                         if e.get("doc_count", 0) > 0]
    if archive_with_docs:
        archive_with_docs.sort(key=lambda x: x.get("doc_count", 0),
                               reverse=True)
        print(f"\nTop unmatched archive entities by document count:",
              file=sys.stderr)
        for e in archive_with_docs[:10]:
            print(f"  {e['name']:<40} {e.get('doc_count', '?'):>6} docs",
                  file=sys.stderr)

    if matches:
        print(f"\nFuzzy matches (review for accuracy):", file=sys.stderr)
        for eid in sorted(matches):
            m = matches[eid]
            if m["method"] == "fuzzy":
                print(f"  {eid:<30} -> {m['archive_name']:<30} "
                      f"({m['score']:.0%})", file=sys.stderr)


def main():
    dry_run = "--dry-run" in sys.argv

    # Step 1: load graph entities
    print("Loading graph entities from CUE...", file=sys.stderr)
    graph_nodes = load_graph_nodes()
    print(f"  {len(graph_nodes)} entities loaded", file=sys.stderr)

    # Step 2: download archive CSV
    print("Downloading archive entity CSV...", file=sys.stderr)
    raw_csv = download_archive_csv()
    archive_entries = parse_archive_csv(raw_csv)
    print(f"  {len(archive_entries)} archive entities parsed", file=sys.stderr)

    if not archive_entries:
        print("ERROR: No entities parsed from CSV. Format may have changed.",
              file=sys.stderr)
        print("First 500 chars of response:", file=sys.stderr)
        print(raw_csv[:500], file=sys.stderr)
        sys.exit(1)

    # Step 3: match
    print("Matching entities...", file=sys.stderr)
    matches, unmatched_graph, unmatched_archive = match_entities(
        graph_nodes, archive_entries
    )

    # Step 4: summary (always to stderr)
    print_summary(matches, unmatched_graph, unmatched_archive)

    # Step 5: emit CUE (unless dry run)
    if dry_run:
        print("\n--dry-run: skipping CUE output", file=sys.stderr)
    else:
        emit_cue(matches)


if __name__ == "__main__":
    main()
