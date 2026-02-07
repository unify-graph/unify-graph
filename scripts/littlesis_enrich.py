#!/usr/bin/env python3
"""LittleSis API enrichment for Person-type entities.

Queries the LittleSis API to retrieve entity relationships and board/donation
information for individuals in the Epstein network.

Usage:
  Local:  .venv/bin/python3 scripts/littlesis_enrich.py
          python3 scripts/littlesis_enrich.py

LittleSis API docs:
  https://littlesis.org/api

No authentication required. Rate-limited to 1.5s between requests.
"""
import difflib
import json
import sys
import time
import urllib.error
import urllib.request
import urllib.parse
from datetime import datetime
from pathlib import Path

API_BASE = "https://littlesis.org/api"
ENTITY_SEARCH = f"{API_BASE}/entities/search"
RELATIONSHIPS = f"{API_BASE}/entities/{{id}}/relationships"

UA = "unify-graph/1.0 (Epstein network research)"

# Rate limit: be respectful
RATE_LIMIT_SECONDS = 1.5


def api_get(url):
    """GET a JSON endpoint, return parsed dict or None on error."""
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        print(f"  ERROR: HTTP {e.code}: {e.reason}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"  ERROR: {e}", file=sys.stderr)
        return None


def search_littlesis(name):
    """Search LittleSis for entities matching name."""
    params = urllib.parse.urlencode({"q": name})
    url = f"{ENTITY_SEARCH}?{params}"
    data = api_get(url)
    if data and "results" in data:
        return data.get("results", [])
    return []


def get_relationships(entity_id):
    """Get relationships for a LittleSis entity ID."""
    url = RELATIONSHIPS.format(id=entity_id)
    data = api_get(url)
    if data and "data" in data:
        return data.get("data", [])
    return []


def name_similarity_ratio(name1, name2):
    """Return similarity ratio (0.0-1.0) between two names using SequenceMatcher."""
    return difflib.SequenceMatcher(None, name1.lower(), name2.lower()).ratio()


def pick_best_match(results, name, threshold=0.85):
    """Pick the best match from search results by name similarity.

    Returns (match_dict, ratio) or (None, 0.0) if no good match found.
    """
    if not results:
        return None, 0.0

    name_lower = name.lower()

    # Exact match gets priority
    for r in results:
        result_name = r.get("name", "")
        if result_name.lower() == name_lower:
            return r, 1.0

    # Score by similarity ratio
    scored = []
    for r in results:
        result_name = r.get("name", "")
        ratio = name_similarity_ratio(name, result_name)
        if ratio >= threshold:
            scored.append((ratio, r))

    if scored:
        scored.sort(key=lambda x: x[0], reverse=True)
        best_ratio, best_result = scored[0]
        return best_result, best_ratio

    return None, 0.0


def extract_notable_relationships(relationships):
    """Extract notable relationships (board seats, donations, etc.)."""
    notable = []
    for rel in relationships:
        rel_type = rel.get("type", "")
        # Include board memberships, donations, and other financial relationships
        if any(keyword in rel_type.lower() for keyword in [
            "board", "donation", "position", "founder", "director",
            "executive", "trustee", "officer", "membership"
        ]):
            notable.append({
                "type": rel_type,
                "target": rel.get("target", {}).get("name", "Unknown"),
                "description": rel.get("description", ""),
                "ls_id": rel.get("target", {}).get("id"),
            })

    return notable


def main():
    # Load entities
    try:
        with open("site/data/entities.json") as f:
            entities = json.load(f)
    except FileNotFoundError:
        print("ERROR: site/data/entities.json not found. Run ./build.sh first.",
              file=sys.stderr)
        sys.exit(1)

    # Filter for Person-type entities only (to stay within rate limits)
    targets = {}
    for key, entity in entities.items():
        types = entity.get("@type", {})
        if "Person" in types:
            targets[key] = entity

    print(f"Querying LittleSis for {len(targets)} Person entities...\n")

    matches = {}
    no_match = []
    errors = []

    for key in sorted(targets.keys()):
        entity = targets[key]
        name = entity["name"]

        sys.stdout.write(f"  {key}: {name} ... ")
        sys.stdout.flush()

        try:
            # Search for entity
            results = search_littlesis(name)
            time.sleep(RATE_LIMIT_SECONDS)

            best_match, ratio = pick_best_match(results, name, threshold=0.85)
            if not best_match:
                no_match.append(key)
                print(f"NO MATCH (best ratio: {ratio:.2f})")
                continue

            ls_id = best_match.get("id")
            ls_name = best_match.get("name", name)
            ls_url = f"https://littlesis.org/person/{ls_id}"

            sys.stdout.write(f"-> {ls_name} (ID {ls_id}, ratio: {ratio:.2f}) ... ")
            sys.stdout.flush()

            # Get relationships
            rels = get_relationships(ls_id)
            time.sleep(RATE_LIMIT_SECONDS)

            # Extract notable relationships
            notable = extract_notable_relationships(rels)

            matches[key] = {
                "name": name,
                "littlesis_id": ls_id,
                "littlesis_url": ls_url,
                "littlesis_name": ls_name,
                "match_ratio": round(ratio, 4),
                "relationship_count": len(rels),
                "notable_relationships": notable[:10],  # Top 10 for readability
            }

            print(f"OK -- {len(rels)} rels, {len(notable)} notable")

        except Exception as e:
            errors.append((key, str(e)))
            print(f"ERROR: {e}")

    # Write results JSON
    output_data = {
        "matches": matches,
        "no_match": no_match,
        "errors": errors,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "entity_count": len(targets),
        "matched_count": len(matches),
        "no_match_count": len(no_match),
        "error_count": len(errors),
    }

    results_path = Path("scripts/littlesis_results.json")
    with open(results_path, "w") as f:
        json.dump(output_data, f, indent=2)

    print(f"\nDone: {len(matches)} matched, {len(no_match)} no match")
    if no_match:
        print(f"No match: {', '.join(no_match[:10])}")
        if len(no_match) > 10:
            print(f"  ... and {len(no_match) - 10} more")
    if errors:
        print(f"\nErrors ({len(errors)}):")
        for key, err in errors[:5]:
            print(f"  {key}: {err}")
        if len(errors) > 5:
            print(f"  ... and {len(errors) - 5} more")

    print(f"\nOutput: {results_path}")

    # Generate CUE overlay
    cue_path = Path("littlesis_ids.cue")
    with open(cue_path, "w") as f:
        f.write("// External identifiers -- LittleSis IDs for entity enrichment.\n")
        f.write("// Auto-generated by scripts/littlesis_enrich.py\n")
        f.write("//\n")
        f.write(f"// Generated: {datetime.utcnow().isoformat()}Z\n")
        f.write(f"// Matched: {len(matches)} entities\n")
        f.write("package creeps\n\n")
        f.write("entities: {\n")
        for key in sorted(matches.keys()):
            ls_id = matches[key]["littlesis_id"]
            f.write(f'\t{key}: external_ids: littlesis: {ls_id}\n')
        f.write("}\n")

    print(f"Output: {cue_path}")

    # Summary table
    if matches:
        hdr = f"{'Entity':<25} {'LS ID':<8} {'LS Name':<30} {'Rels':>6} {'Notable':>8}"
        print(f"\n{hdr}")
        print("-" * 77)
        for key in sorted(matches.keys()):
            m = matches[key]
            ent = key[:24]
            ls_id = m["littlesis_id"]
            ls_name = m["littlesis_name"][:29]
            rels = m["relationship_count"]
            notable = len(m["notable_relationships"])
            print(f"{ent:<25} {ls_id:<8} {ls_name:<30} {rels:>6} {notable:>8}")


if __name__ == "__main__":
    main()
