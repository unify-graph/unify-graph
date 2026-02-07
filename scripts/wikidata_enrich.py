#!/usr/bin/env python3
"""Wikidata SPARQL enrichment for all entities with QIDs.

Queries Wikidata for structured properties (employers, education,
memberships, family, residences, external IDs) for each reconciled entity.

Uses the Wikidata Query Service SPARQL endpoint. Rate limited to ~1 req/sec.

Usage:
  .venv/bin/python3 scripts/wikidata_enrich.py

Output:
  scripts/wikidata_enriched.json  — structured properties per entity
"""
import json
import sys
import time
import urllib.request
import urllib.parse
from pathlib import Path

SPARQL_ENDPOINT = "https://query.wikidata.org/sparql"
UA = "unify-graph/1.0 (https://github.com/unify-graph/unify-graph; entity enrichment)"

# Properties to extract for persons
PERSON_PROPS = {
    "P69":  "educated_at",
    "P108": "employer",
    "P39":  "position_held",
    "P463": "member_of",
    "P451": "partner",
    "P26":  "spouse",
    "P22":  "father",
    "P25":  "mother",
    "P40":  "child",
    "P3373": "sibling",
    "P551": "residence",
    "P27":  "citizenship",
    "P106": "occupation",
    "P1399": "convicted_of",
    "P509": "cause_of_death",
    "P119": "place_of_burial",
    "P569": "date_of_birth",
    "P570": "date_of_death",
    "P742": "pseudonym",
    "P968": "email",
}

# Properties for organizations
ORG_PROPS = {
    "P112": "founded_by",
    "P127": "owned_by",
    "P159": "headquarters",
    "P17":  "country",
    "P571": "inception",
    "P576": "dissolved",
    "P169": "ceo",
    "P749": "parent_org",
    "P355": "subsidiary",
    "P452": "industry",
}

# External identifier properties (for all entity types)
EXT_ID_PROPS = {
    "P214": "viaf",
    "P244": "loc_authority",
    "P227": "gnd",
    "P345": "imdb",
    "P646": "freebase",
    "P535": "find_a_grave",
    "P1566": "geonames",
    "P213": "isni",
}


def sparql_query(query: str) -> list[dict]:
    """Execute a SPARQL query against Wikidata Query Service."""
    params = urllib.parse.urlencode({"query": query})
    url = f"{SPARQL_ENDPOINT}?{params}"
    req = urllib.request.Request(url, headers={
        "User-Agent": UA,
        "Accept": "application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read())
            return data.get("results", {}).get("bindings", [])
    except Exception as e:
        print(f"  SPARQL error: {e}", file=sys.stderr)
        return []


def batch_enrich(qid_map: dict[str, str], batch_size: int = 20) -> dict:
    """Query Wikidata for structured properties in batches of QIDs."""
    all_results = {}
    qid_list = list(qid_map.items())

    for i in range(0, len(qid_list), batch_size):
        batch = qid_list[i:i + batch_size]
        values = " ".join(f"wd:{qid}" for _, qid in batch)
        qid_to_key = {qid: key for key, qid in batch}

        # Combine person and org props
        all_props = {**PERSON_PROPS, **ORG_PROPS, **EXT_ID_PROPS}
        prop_values = " ".join(f"wdt:{p}" for p in all_props.keys())

        query = f"""
        SELECT ?entity ?prop ?val ?valLabel WHERE {{
          VALUES ?entity {{ {values} }}
          VALUES ?prop {{ {prop_values} }}
          ?entity ?prop ?val .
          SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en". }}
        }}
        """

        sys.stdout.write(f"  Batch {i // batch_size + 1}: {len(batch)} entities ... ")
        sys.stdout.flush()

        bindings = sparql_query(query)
        print(f"{len(bindings)} triples")

        # Parse results
        prop_reverse = {}
        for pid, name in all_props.items():
            prop_reverse[f"http://www.wikidata.org/prop/direct/{pid}"] = name

        for b in bindings:
            entity_uri = b["entity"]["value"]
            qid = entity_uri.split("/")[-1]
            key = qid_to_key.get(qid)
            if not key:
                continue

            if key not in all_results:
                all_results[key] = {"qid": qid, "properties": {}}

            prop_uri = b["prop"]["value"]
            prop_name = prop_reverse.get(prop_uri, prop_uri.split("/")[-1])

            val = b.get("valLabel", b["val"])
            val_str = val.get("value", "")

            # For dates, clean up the format
            if val.get("datatype", "").endswith("dateTime"):
                val_str = val_str[:10]  # Just YYYY-MM-DD

            # For URIs, extract QID or keep URL
            if val["type"] == "uri" and "/entity/" in val["value"]:
                val_qid = val["value"].split("/")[-1]
                label = b.get("valLabel", {}).get("value", val_qid)
                val_str = f"{label} ({val_qid})" if label != val_qid else val_qid
            elif val["type"] == "uri":
                val_str = val["value"]

            props = all_results[key]["properties"]
            if prop_name not in props:
                props[prop_name] = []
            if val_str not in props[prop_name]:
                props[prop_name].append(val_str)

        time.sleep(1.5)  # Rate limit

    return all_results


def main():
    # Load QID mapping
    qid_path = Path("scripts/wikidata_qids.json")
    if not qid_path.exists():
        print("ERROR: scripts/wikidata_qids.json not found. Run wikidata_reconcile.py first.")
        sys.exit(1)

    with open(qid_path) as f:
        qid_map = {k: v for k, v in json.load(f).items() if v}

    print(f"Enriching {len(qid_map)} entities from Wikidata SPARQL...\n")

    results = batch_enrich(qid_map)

    # Summary stats
    total_props = sum(len(r["properties"]) for r in results.values())
    total_values = sum(sum(len(v) for v in r["properties"].values()) for r in results.values())

    # Write output
    out_path = Path("scripts/wikidata_enriched.json")
    with open(out_path, "w") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"\nDone: {len(results)} entities enriched")
    print(f"  {total_props} property types, {total_values} total values")
    print(f"  Output: {out_path}")

    # Print interesting findings
    print("\nNotable findings:")
    for key, data in sorted(results.items()):
        props = data["properties"]
        interesting = []
        if "pseudonym" in props:
            interesting.append(f"pseudonym: {', '.join(props['pseudonym'])}")
        if "convicted_of" in props:
            interesting.append(f"convicted: {', '.join(props['convicted_of'])}")
        if "member_of" in props:
            interesting.append(f"member of: {', '.join(props['member_of'])}")
        if interesting:
            print(f"  {key}: {'; '.join(interesting)}")


if __name__ == "__main__":
    main()
