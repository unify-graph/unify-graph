#!/usr/bin/env python3
"""Batch OpenSanctions reconciliation for all entities.

Queries the OpenSanctions Yente matching API for each entity name (and
optionally Wikidata ID) and outputs results with matched sanctions entries.

Usage:
  Local:  .venv/bin/python3 scripts/opensanctions_reconcile.py
  CI:     triggered manually via CI pipeline

Output:
  scripts/opensanctions_results.json  (detailed match results)
  opensanctions_ids.cue              (CUE overlay with external_ids.opensanctions)

Note: Only matches with score >= 0.7 are included. Rate-limited to 1 req/sec.
"""
import json
import sys
import time
import urllib.request
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

API = "https://api.opensanctions.org/match/default"
UA = "unify-graph/1.0 (https://github.com/unify-graph/unify-graph; entity reconciliation)"
MIN_SCORE = 0.7

# Paths relative to repo root
REPO_ROOT = Path(__file__).resolve().parent.parent
SITE_DATA = REPO_ROOT / "site" / "data"
ENTITIES_FILE = SITE_DATA / "entities.json"
RESULTS_FILE = REPO_ROOT / "scripts" / "opensanctions_results.json"
CUE_OVERLAY = REPO_ROOT / "opensanctions_ids.cue"


def determine_schema(entity: Dict[str, Any]) -> str:
    """Determine OpenSanctions schema based on entity @type.

    Returns 'Person', 'Organization', or 'Company'.
    """
    entity_type = entity.get("@type", {})
    if not isinstance(entity_type, dict):
        return "Person"  # Default

    # Check for organization/company types
    if "Organization" in entity_type or "Company" in entity_type:
        return "Organization"
    if "ShellCompany" in entity_type:
        return "Organization"
    if "Trust" in entity_type or "Fund" in entity_type:
        return "Organization"

    # Default to Person
    return "Person"


def query_opensanctions(
    entity_id: str,
    name: str,
    wikidata_qid: Optional[str] = None,
    schema: str = "Person"
) -> Optional[Dict[str, Any]]:
    """Query OpenSanctions Yente matching API.

    Tries matching by name and optionally by wikidataId.
    Returns the best match dict if score >= MIN_SCORE, else None.
    """
    # Build query
    query: Dict[str, Any] = {
        "schema": schema,
        "properties": {"name": [name]},
    }

    if wikidata_qid:
        query["properties"]["wikidataId"] = [wikidata_qid]

    payload = json.dumps({"queries": {"q1": query}}).encode("utf-8")

    try:
        req = urllib.request.Request(
            API,
            data=payload,
            headers={
                "User-Agent": UA,
                "Content-Type": "application/json",
            },
            method="POST"
        )

        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read())

        # Extract match results
        results = data.get("results", {}).get("q1", {}).get("results", [])
        if results:
            match = results[0]
            score = match.get("score", 0.0)

            if score >= MIN_SCORE:
                return {
                    "entity_id": entity_id,
                    "name": name,
                    "opensanctions_id": match.get("id"),
                    "datasets": match.get("datasets", []),
                    "score": score,
                    "caption": match.get("caption", ""),
                    "schema": match.get("schema", schema),
                }

        return None

    except Exception as e:
        print(f"  ERROR querying OpenSanctions for {entity_id}: {e}", file=sys.stderr)
        return None


def main():
    # Load entities
    try:
        with open(ENTITIES_FILE) as f:
            entities = json.load(f)
    except FileNotFoundError:
        print(f"Error: {ENTITIES_FILE} not found", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing entities JSON: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"Reconciling {len(entities)} entities against OpenSanctions...\n", file=sys.stderr)

    matches: Dict[str, Dict[str, Any]] = {}
    no_match: List[str] = []

    for entity_id in sorted(entities.keys()):
        entity = entities[entity_id]
        name = entity["name"]

        # Determine schema and extract Wikidata QID if available
        schema = determine_schema(entity)
        external_ids = entity.get("external_ids", {})
        wikidata_qid = external_ids.get("wikidata")

        sys.stdout.write(f"  {entity_id}: {name} ({schema}) ... ")
        sys.stdout.flush()

        # Query API
        result = query_opensanctions(entity_id, name, wikidata_qid, schema)
        time.sleep(1)  # Rate limit: 1 req/sec

        if result:
            matches[entity_id] = result
            print(f"MATCH {result['opensanctions_id']} (score: {result['score']:.2f})", file=sys.stderr)
        else:
            no_match.append(entity_id)
            print("no match", file=sys.stderr)

    # Write results JSON
    timestamp = datetime.now(timezone.utc).isoformat()
    results_data = {
        "matches": matches,
        "no_match": no_match,
        "timestamp": timestamp,
    }

    with open(RESULTS_FILE, "w") as f:
        json.dump(results_data, f, indent=2)

    # Write CUE overlay
    with open(CUE_OVERLAY, "w") as f:
        f.write("// External identifiers — OpenSanctions IDs for entity reconciliation.\n")
        f.write("// Auto-generated by scripts/opensanctions_reconcile.py\n")
        f.write("// Reviewed and disambiguated manually. Run reconcile script to refresh.\n")
        f.write("//\n")
        f.write(f"// {len(matches)} entities matched, {len(no_match)} with no match\n")
        f.write("package creeps\n\n")
        f.write("entities: {\n")

        for entity_id in sorted(matches.keys()):
            os_id = matches[entity_id]["opensanctions_id"]
            f.write(f'\t{entity_id}: external_ids: opensanctions: "{os_id}"\n')

        f.write("}\n")

    # Print summary
    print(f"\nDone: {len(matches)} matched, {len(no_match)} no match", file=sys.stderr)
    print(f"\nOutput:", file=sys.stderr)
    print(f"  {RESULTS_FILE} (detailed match results)", file=sys.stderr)
    print(f"  {CUE_OVERLAY} (CUE overlay)", file=sys.stderr)


if __name__ == "__main__":
    main()
