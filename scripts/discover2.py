#!/usr/bin/env python3
"""
Second discovery pass — query for all names found in public reporting
about the EFTA release that weren't in the original 38.
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
DELAY = 0.4

# Names from public reporting NOT yet queried (or queried with 0 results)
NEW_QUERIES = [
    # Tech billionaires
    '"Elon Musk"',
    '"Bill Gates"',
    '"Jeff Bezos"',
    '"Eric Schmidt"',
    '"Sergey Brin"',  # re-check
    # Entertainment / Media
    '"Richard Branson"',
    '"Steven Tisch"',
    '"Steve Tisch"',
    '"Casey Wasserman"',
    '"Brett Ratner"',
    '"Woody Allen"',
    '"Mick Jagger"',
    '"Naomi Campbell"',
    '"Oprah Winfrey"',
    '"Renee Zellweger"',
    '"Harvey Weinstein"',
    '"Kevin Spacey"',
    # Politicians / Government
    '"Barack Obama"',
    '"Jerome Powell"',
    '"Gordon Brown"',
    '"Peter Mandelson"',
    '"Tony Blair"',
    '"Miroslav Lajcak"',
    '"Ehud Barak"',
    '"Ariel Sharon"',
    # Legal / Prosecution
    '"Kathryn Ruemmler"',
    '"Marie Villafana"',  # re-check with more context
    '"Jack Scarola"',
    '"Brad Edwards"',
    '"Paul Cassell"',
    '"Sigrid McCawley"',
    '"Laura Menninger"',
    # Staff / Inner Circle
    '"Juan Alessi"',
    '"Boris Nikolic"',
    '"Peggy Siegal"',
    '"Adriana Ross"',
    '"Haley Robson"',
    '"Cimberly Espinosa"',
    '"Janusz Banasiak"',
    '"Alfredo Rodriguez"',
    '"Emmy Taylor"',
    # Victims / Accusers (by reporting name only)
    '"Courtney Wild"',
    '"Michelle Licata"',
    # Family / Associates
    '"Sarah Ferguson"',
    '"Melinda Gates"',
    '"Talulah Riley"',
    '"Chelsea Clinton"',
    '"Melania Trump"',
    '"Mark Epstein"',
    '"Robert Maxwell"',  # re-check
    '"Mila Antonova"',
    # Financial / Corporate
    '"Goldman Sachs"',
    '"Bear Stearns"',
    '"Citibank"',
    '"Wells Fargo"',
    '"UBS"',
    '"Credit Suisse"',
    '"Barclays"',
    '"HSBC"',
    '"Morgan Stanley"',
    '"Bank of America"',
    '"Gratitude America"',
    '"Financial Trust"',
    '"COUQ Foundation"',
    '"Butterfly Trust"',
    '"Liquid Funding"',
    # Properties
    '"Zorro Ranch"',  # re-check
    '"Little St James"',  # re-check
    '"71st Street"',  # re-check
    '"East 71st"',
    '"New Mexico ranch"',
    '"El Brillo Way"',
    # Science / Academia
    '"Harvard University"',
    '"MIT Media Lab"',
    '"Stephen Hawking"',  # re-check
    '"Larry Summers"',  # re-check
    '"Martin Nowak"',
    '"Steven Pinker"',
    '"Lawrence Krauss"',
    '"Marvin Minsky"',
    '"Seth Lloyd"',
    '"Dershowitz"',
    # Models / Modeling
    '"Jean-Luc Brunel"',  # re-check
    '"MC2"',
    '"Nadia Marcinkova"',  # re-check
    '"Sarah Kellen"',  # re-check
    # Other investigations
    '"Les Wexner"',
    '"Jes Staley"',
    '"Leon Botstein"',
    '"Tom Pritzker"',
    '"Mort Zuckerman"',
    '"Leslie Groff"',
    '"Andrew Farkas"',
    '"Glenn Dubin"',  # re-check
    '"Eva Dubin"',  # re-check
    # Political donors / fixers
    '"Lynn Forester"',
    '"Lynn de Rothschild"',
    # Intelligence connections
    '"Robert Mueller"',
    '"James Comey"',
    '"Alexander Acosta"',  # re-check
    '"R. Alexander Acosta"',
    '"Alberto Gonzales"',
]


def query_api(q, limit=50):
    params = urllib.parse.urlencode({"q": q, "indexes": INDEX, "limit": limit})
    url = f"{API_BASE}?{params}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "unify-creeps/0.1"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError) as e:
        print(f"  ERROR: {e}", file=sys.stderr)
        return None


def main():
    all_people = defaultdict(int)
    all_documents = {}
    all_locations = defaultdict(int)
    coappearances = defaultdict(lambda: defaultdict(int))
    query_hits = {}

    total = len(NEW_QUERIES)
    print(f"Running {total} second-pass queries...\n")

    for i, q in enumerate(NEW_QUERIES):
        print(f"[{i+1}/{total}] {q}")
        resp = query_api(q)
        if not resp:
            continue

        total_hits = resp.get("data", {}).get("totalHits", 0)
        hits = resp.get("data", {}).get("hits", [])
        query_hits[q] = total_hits
        print(f"  → {total_hits} total hits, {len(hits)} returned")

        for hit in hits:
            doc_id = hit.get("efta_id") or hit.get("id", "unknown")
            people = hit.get("people", [])
            locations = hit.get("locations", [])

            if doc_id not in all_documents:
                all_documents[doc_id] = {
                    "doc_id": doc_id,
                    "doc_type": hit.get("doc_type", "unknown"),
                    "source": hit.get("source", "unknown"),
                    "dataset": hit.get("dataset", "unknown"),
                    "file_path": hit.get("file_path", ""),
                    "pages": hit.get("pages", 0),
                    "char_count": hit.get("char_count", 0),
                    "content_preview": (hit.get("content_preview") or "")[:300],
                    "people": set(),
                    "locations": set(),
                    "queries_matched": set(),
                }
            doc = all_documents[doc_id]
            doc["queries_matched"].add(q)

            for person in people:
                p = person.strip()
                if p:
                    all_people[p] += 1
                    doc["people"].add(p)

            for loc in locations:
                loc = loc.strip()
                if loc:
                    all_locations[loc] += 1
                    doc["locations"].add(loc)

            clean_people = [p.strip() for p in people if p.strip()]
            for j, p1 in enumerate(clean_people):
                for p2 in clean_people[j+1:]:
                    coappearances[p1][p2] += 1
                    coappearances[p2][p1] += 1

        time.sleep(DELAY)

    # ─── Merge with first pass ────────────────────────────────

    first_pass_path = Path(__file__).parent.parent / "discovery.json"
    if first_pass_path.exists():
        with open(first_pass_path) as f:
            first = json.load(f)
        # Merge people
        for name, count in first.get("people_by_mentions", {}).items():
            all_people[name] += count
        # Merge locations
        for name, count in first.get("locations_by_mentions", {}).items():
            all_locations[name] += count
        # Merge query hits
        for q, count in first.get("query_hit_counts", {}).items():
            if q not in query_hits:
                query_hits[q] = count
        print("\nMerged with first-pass discovery data.")

    # ─── Output ───────────────────────────────────────────────

    output = {
        "meta": {
            "total_queries": len(query_hits),
            "unique_documents": len(all_documents),
            "unique_people": len(all_people),
            "unique_locations": len(all_locations),
        },
        "query_hit_counts": dict(sorted(
            query_hits.items(), key=lambda x: x[1], reverse=True
        )),
        "people_by_mentions": dict(sorted(
            all_people.items(), key=lambda x: x[1], reverse=True
        )),
        "locations_by_mentions": dict(sorted(
            all_locations.items(), key=lambda x: x[1], reverse=True
        )),
        "coappearances_top": [],
        "zero_hit_queries": sorted([q for q, c in query_hits.items() if c == 0]),
        "documents": [],
    }

    # Co-appearances
    seen_pairs = set()
    for p1, conns in coappearances.items():
        for p2, count in sorted(conns.items(), key=lambda x: x[1], reverse=True):
            pair = tuple(sorted([p1, p2]))
            if pair not in seen_pairs and count >= 2:
                seen_pairs.add(pair)
                output["coappearances_top"].append({
                    "a": pair[0], "b": pair[1], "count": count,
                })
    output["coappearances_top"].sort(key=lambda x: x["count"], reverse=True)
    output["coappearances_top"] = output["coappearances_top"][:200]

    # Documents
    for doc_id, doc in list(all_documents.items()):
        output["documents"].append({
            "doc_id": doc_id,
            "doc_type": doc["doc_type"],
            "source": doc["source"],
            "dataset": doc["dataset"],
            "pages": doc["pages"],
            "char_count": doc["char_count"],
            "people": sorted(doc["people"]),
            "locations": sorted(doc["locations"]),
            "queries": sorted(doc["queries_matched"]),
            "preview": doc["content_preview"],
        })

    out_path = Path(__file__).parent.parent / "discovery2.json"
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2, default=str)

    print(f"\n{'='*60}")
    print(f"SECOND PASS COMPLETE")
    print(f"{'='*60}")
    print(f"Total queries:      {len(query_hits)}")
    print(f"Unique documents:   {len(all_documents)}")
    print(f"Unique people (API-tagged): {len(all_people)}")
    print(f"Unique locations:   {len(all_locations)}")

    print(f"\nAll queries by hit count:")
    for q, count in output["query_hit_counts"].items():
        marker = " ★" if count >= 100 else ""
        print(f"  {count:5d}  {q}{marker}")

    print(f"\nZero-hit queries (NOT in corpus):")
    for q in output["zero_hit_queries"]:
        print(f"  {q}")

    print(f"\nResults saved to: {out_path}")


if __name__ == "__main__":
    main()
