#!/usr/bin/env python3
"""
Discover entities, documents, and connections from the DugganUSA Epstein API.

Queries the search API for known entities and broad investigative terms,
collects all people/locations/documents mentioned in results, and builds
a discovery report for expanding the CUE model.

API: https://analytics.dugganusa.com/api/v1/search
"""

import json
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
from collections import defaultdict
from pathlib import Path

API_BASE = "https://analytics.dugganusa.com/api/v1/search"
INDEX = "epstein_files"
DELAY = 0.5  # be polite

# ─── Known entities (from current CUE model) ───────────────────

KNOWN_ENTITIES = {
    "epstein", "maxwell", "brunel", "lesley_groff", "leon_black",
    "rothschild_geneva", "wexner", "steve_cohen", "philippe_laffont",
    "josh_harris", "apollo", "peter_thiel", "reid_hoffman",
    "brock_pierce", "adam_back", "bart_stephens", "prince_andrew",
    "david_copperfield", "glenn_dubin", "bill_richardson",
    "george_mitchell", "joichi_ito", "howard_lutnick", "trump",
    "kushner", "bill_clinton", "steve_bannon", "dershowitz",
    "ken_starr", "dechert_llp", "acosta", "bill_barr",
    "geoffrey_berman", "southern_trust", "valar_ventures", "kyara",
    "honeycomb", "blockchain_capital",
}

# ─── Search queries ─────────────────────────────────────────────

# Entity name queries (what the API would find in document text)
ENTITY_QUERIES = [
    # Core network
    '"Jeffrey Epstein"',
    '"Ghislaine Maxwell"',
    '"Jean-Luc Brunel"',
    '"Lesley Groff"',
    '"Sarah Kellen"',
    '"Nadia Marcinkova"',
    # Financial
    '"Leon Black"',
    '"Les Wexner"',
    '"Steve Cohen"',
    '"Philippe Laffont"',
    '"Josh Harris"',
    '"Peter Thiel"',
    '"Reid Hoffman"',
    '"Valar Ventures"',
    '"Southern Trust"',
    # Crypto
    '"Brock Pierce"',
    '"Adam Back"',
    '"Bart Stephens"',
    '"Blockchain Capital"',
    # Political
    '"Bill Clinton"',
    '"Donald Trump"',
    '"Jared Kushner"',
    '"Steve Bannon"',
    '"Howard Lutnick"',
    '"Bill Barr"',
    '"Bill Richardson"',
    # Legal
    '"Alan Dershowitz"',
    '"Ken Starr"',
    '"Dechert LLP"',
    '"Alexander Acosta"',
    '"Geoffrey Berman"',
    # Allegations
    '"Prince Andrew"',
    '"David Copperfield"',
    '"Glenn Dubin"',
    '"George Mitchell"',
    '"Virginia Giuffre"',
    '"Virginia Roberts"',
    # Academia
    '"Joi Ito"',
    '"Joichi Ito"',
    # Shell companies / financial
    '"Honeycomb"',
    '"Kyara"',
    '"Southern Country"',
]

# Broad discovery queries — find entities we don't know about
DISCOVERY_QUERIES = [
    "co-conspirator",
    "unindicted",
    '"non-prosecution agreement"',
    '"NPA immunity"',
    '"flight log"',
    '"flight manifest"',
    "Lolita Express",
    '"wire transfer"',
    '"shell company"',
    '"trust account"',
    '"Deutsche Bank"',
    '"JP Morgan"',
    '"Bear Stearns"',
    '"Dalton School"',
    '"Donald Barr"',
    '"Victoria Secret"',
    '"L Brands"',
    '"MC2 Model"',
    '"Terramar"',
    '"Eva Dubin"',
    '"Michael Milken"',
    '"Cantor Fitzgerald"',
    '"Highbridge Capital"',
    '"Coatue"',
    '"Palantir"',
    '"Blockstream"',
    '"Clinton Foundation"',
    '"Mar-a-Lago"',
    '"Marie Villafana"',
    '"MCC Manhattan"',
    '"Bill Gates"',
    '"Lex Wexner"',
    '"Ehud Barak"',
    '"Woody Allen"',
    '"Leslie Wexner"',
    '"Katie Couric"',
    '"George Stephanopoulos"',
    '"Sergey Brin"',
    '"Larry Summers"',
    '"Stephen Hawking"',
    '"Noam Chomsky"',
    '"Robert Maxwell"',
    '"Jean-Georges"',
    '"Zorro Ranch"',
    '"Little St James"',
    '"71st Street"',
    '"Palm Beach"',
    '"Naomi Campbell"',
    '"Cindy Lopez"',
    '"Courtney Wild"',
    '"Jane Doe"',
    '"John Doe"',
    "recruiter",
    "scheduler",
    '"power of attorney"',
]


def query_api(q, limit=50):
    """Query the DugganUSA search API."""
    params = urllib.parse.urlencode({
        "q": q,
        "indexes": INDEX,
        "limit": limit,
    })
    url = f"{API_BASE}?{params}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "unify-creeps/0.1"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError) as e:
        print(f"  ERROR: {e}", file=sys.stderr)
        return None


def extract_hits(response):
    """Extract hits from API response."""
    if not response or not response.get("success"):
        return []
    return response.get("data", {}).get("hits", [])


def main():
    # Accumulators
    all_people = defaultdict(int)          # person name → mention count
    all_documents = {}                      # doc_id → metadata
    all_locations = defaultdict(int)        # location → mention count
    coappearances = defaultdict(lambda: defaultdict(int))  # person → person → count
    entity_documents = defaultdict(set)     # entity → set of doc_ids
    query_hit_counts = {}                   # query → total hits

    all_queries = ENTITY_QUERIES + DISCOVERY_QUERIES
    total = len(all_queries)

    print(f"Running {total} queries against {INDEX}...\n")

    for i, q in enumerate(all_queries):
        print(f"[{i+1}/{total}] {q}")
        resp = query_api(q)
        if not resp:
            continue

        total_hits = resp.get("data", {}).get("totalHits", 0)
        query_hit_counts[q] = total_hits
        hits = extract_hits(resp)
        print(f"  → {total_hits} total hits, {len(hits)} returned")

        for hit in hits:
            doc_id = hit.get("efta_id") or hit.get("id", "unknown")
            people = hit.get("people", [])
            locations = hit.get("locations", [])

            # Track document
            if doc_id not in all_documents:
                all_documents[doc_id] = {
                    "doc_id": doc_id,
                    "doc_type": hit.get("doc_type", "unknown"),
                    "source": hit.get("source", "unknown"),
                    "dataset": hit.get("dataset", "unknown"),
                    "file_path": hit.get("file_path", ""),
                    "pages": hit.get("pages", 0),
                    "char_count": hit.get("char_count", 0),
                    "content_preview": (hit.get("content_preview") or "")[:200],
                    "people": set(),
                    "locations": set(),
                    "queries_matched": set(),
                }
            doc = all_documents[doc_id]
            doc["queries_matched"].add(q)

            # Track people
            for person in people:
                person = person.strip()
                if person:
                    all_people[person] += 1
                    doc["people"].add(person)

            # Track locations
            for loc in locations:
                loc = loc.strip()
                if loc:
                    all_locations[loc] += 1
                    doc["locations"].add(loc)

            # Track co-appearances (entities in same document)
            clean_people = [p.strip() for p in people if p.strip()]
            for j, p1 in enumerate(clean_people):
                for p2 in clean_people[j+1:]:
                    coappearances[p1][p2] += 1
                    coappearances[p2][p1] += 1

        time.sleep(DELAY)

    # ─── Output ─────────────────────────────────────────────

    output = {
        "meta": {
            "queries_run": total,
            "unique_documents": len(all_documents),
            "unique_people": len(all_people),
            "unique_locations": len(all_locations),
        },
        "query_hit_counts": dict(sorted(
            query_hit_counts.items(), key=lambda x: x[1], reverse=True
        )),
        "people_by_mentions": dict(sorted(
            all_people.items(), key=lambda x: x[1], reverse=True
        )),
        "locations_by_mentions": dict(sorted(
            all_locations.items(), key=lambda x: x[1], reverse=True
        )),
        "coappearances_top": [],
        "documents_sample": [],
    }

    # Top co-appearances (entities frequently in same docs)
    seen_pairs = set()
    for p1, connections in coappearances.items():
        for p2, count in sorted(connections.items(), key=lambda x: x[1], reverse=True):
            pair = tuple(sorted([p1, p2]))
            if pair not in seen_pairs and count >= 2:
                seen_pairs.add(pair)
                output["coappearances_top"].append({
                    "entity_a": pair[0],
                    "entity_b": pair[1],
                    "shared_documents": count,
                })
    output["coappearances_top"].sort(key=lambda x: x["shared_documents"], reverse=True)
    output["coappearances_top"] = output["coappearances_top"][:100]

    # Sample documents (convert sets to lists for JSON)
    for doc_id, doc in list(all_documents.items())[:200]:
        output["documents_sample"].append({
            "doc_id": doc_id,
            "doc_type": doc["doc_type"],
            "source": doc["source"],
            "dataset": doc["dataset"],
            "pages": doc["pages"],
            "char_count": doc["char_count"],
            "people": sorted(doc["people"]),
            "locations": sorted(doc["locations"]),
            "queries_matched": sorted(doc["queries_matched"]),
            "preview": doc["content_preview"],
        })

    out_path = Path(__file__).parent.parent / "discovery.json"
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, default=str)

    print(f"\n{'='*60}")
    print(f"DISCOVERY COMPLETE")
    print(f"{'='*60}")
    print(f"Queries run:        {total}")
    print(f"Unique documents:   {len(all_documents)}")
    print(f"Unique people:      {len(all_people)}")
    print(f"Unique locations:   {len(all_locations)}")
    print(f"Co-appearance pairs: {len(seen_pairs)}")
    print(f"\nTop 20 people by mention count:")
    for name, count in list(output["people_by_mentions"].items())[:20]:
        print(f"  {count:4d}  {name}")
    print(f"\nTop 10 locations:")
    for name, count in list(output["locations_by_mentions"].items())[:10]:
        print(f"  {count:4d}  {name}")
    print(f"\nTop 10 co-appearances:")
    for pair in output["coappearances_top"][:10]:
        print(f"  {pair['shared_documents']:4d}  {pair['entity_a']} ↔ {pair['entity_b']}")
    print(f"\nResults saved to: {out_path}")


if __name__ == "__main__":
    main()
