#!/usr/bin/env python3
"""ProPublica Nonprofit Explorer enrichment for foundation entities.

Queries the ProPublica Nonprofit Explorer API to retrieve 990 filing
data (EIN, revenue, assets, filings history) for foundations in the
entity graph.

Usage:
  Local:  .venv/bin/python3 scripts/propublica_enrich.py
          python3 scripts/propublica_enrich.py

ProPublica API docs:
  https://projects.propublica.org/nonprofits/api

No authentication required. Be polite (0.5s between requests).
"""
import json
import sys
import time
import urllib.error
import urllib.request
import urllib.parse

SEARCH_API = "https://projects.propublica.org/nonprofits/api/v2/search.json"
ORG_API = "https://projects.propublica.org/nonprofits/api/v2/organizations/{ein}.json"

UA = "unify-graph/1.0 (https://github.com/unify-graph/unify-graph; nonprofit enrichment)"

# Known EINs for Epstein-connected nonprofits (bypasses search ambiguity)
KNOWN_EINS = {
    "clinton_foundation": "311580204",   # Bill Hillary & Chelsea Clinton Foundation
    "gratitude_america": "660789697",    # Gratitude America Ltd (Epstein, St Thomas VI)
    "wexner_foundation": "237320631",    # Wexner Foundation (Columbus OH)
}

# Extra nonprofits to search that may not be Foundation-typed in the graph
EXTRA_SEARCHES = {
    "wexner_foundation": "Wexner Foundation",
    "jeffrey_epstein_vi_foundation": "Jeffrey Epstein VI Foundation",
    "terramar": "Terramar Project",
    "couq_foundation": "COUQ Foundation",
}

# Generic org-type words that should not count toward name matching
STOP_WORDS = {
    "foundation", "inc", "incorporated", "ltd", "limited", "corp",
    "corporation", "trust", "fund", "the", "of", "and", "for",
    "project", "institute", "organization", "association", "society",
}


def api_get(url):
    """GET a JSON endpoint, return parsed dict or None on error."""
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            # ProPublica returns 404 for empty search results
            return None
        print(f"  ERROR: HTTP {e.code}: {e.reason}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"  ERROR: {e}", file=sys.stderr)
        return None


def search_nonprofit(name):
    """Search ProPublica for nonprofits matching name."""
    params = urllib.parse.urlencode({"q": name})
    url = f"{SEARCH_API}?{params}"
    data = api_get(url)
    if data and "organizations" in data:
        return data["organizations"]
    return []


def get_org_detail(ein):
    """Get detailed 990 filing data for an EIN."""
    url = ORG_API.format(ein=ein)
    data = api_get(url)
    if data and "organization" in data:
        org = data["organization"]
        filings = data.get("filings_with_data", [])
        return {
            "ein": org.get("ein"),
            "name": org.get("name"),
            "city": org.get("city"),
            "state": org.get("state"),
            "ntee_code": org.get("ntee_code"),
            "total_revenue": org.get("income_amount"),
            "total_assets": org.get("asset_amount"),
            "filings": [
                {
                    "tax_period": f.get("tax_prd_yr"),
                    "revenue": f.get("totrevenue"),
                    "assets": f.get("totassetsend"),
                    "expenses": f.get("totfuncexpns"),
                }
                for f in filings
            ],
        }
    return None


def name_similarity(search_name, result_name):
    """Score how well a search name matches a result name.

    Returns (total_score, substantive_matches) where substantive_matches
    counts non-stop-word matches. This prevents "COUQ Foundation" from
    matching "De La Cour Family Foundation" on just "Foundation".
    """
    a = set(w.lower() for w in search_name.split())
    b = set(w.lower() for w in result_name.split())
    if not a or not b:
        return 0.0, 0

    common = a & b
    substantive = common - STOP_WORDS
    score = len(common) / len(a)
    return score, len(substantive)


def pick_best(results, name):
    """Pick the best match from search results by name similarity."""
    if not results:
        return None
    name_lower = name.lower()

    # Exact name match
    for r in results:
        if r.get("name", "").lower() == name_lower:
            return r

    # Score by word overlap; require at least one substantive word match
    scored = []
    for r in results:
        rname = r.get("name", "")
        score, substantive = name_similarity(name, rname)
        if score >= 0.5 and substantive >= 1:
            scored.append((score, substantive, r))

    if scored:
        scored.sort(key=lambda x: (x[0], x[1]), reverse=True)
        return scored[0][2]

    # No good match found
    return None


def main():
    # Load entities to find Foundation types
    try:
        with open("site/data/entities.json") as f:
            entities = json.load(f)
    except FileNotFoundError:
        print("ERROR: site/data/entities.json not found. Run ./build.sh first.",
              file=sys.stderr)
        sys.exit(1)

    # Collect foundations from entity data
    targets = {}
    for key, entity in entities.items():
        types = entity.get("@type", {})
        if "Foundation" in types:
            targets[key] = entity["name"]

    # Merge extra searches (may overlap, that is fine)
    for key, name in EXTRA_SEARCHES.items():
        if key not in targets:
            targets[key] = name

    print(f"Enriching {len(targets)} foundations via ProPublica Nonprofit Explorer...\n")

    results = {}
    not_found = []

    for key, name in sorted(targets.items()):
        sys.stdout.write(f"  {key}: {name} ... ")
        sys.stdout.flush()

        # If we have a known EIN, go straight to detail
        if key in KNOWN_EINS:
            ein = KNOWN_EINS[key]
            sys.stdout.write(f"(known EIN {ein}) ")
            sys.stdout.flush()
            detail = get_org_detail(ein)
            time.sleep(0.5)
            if detail:
                results[key] = detail
                rev = detail.get("total_revenue")
                rev_str = f"${rev:,.0f}" if rev else "N/A"
                print(f"OK -- revenue: {rev_str}")
            else:
                not_found.append(key)
                print("DETAIL FAILED")
            continue

        # Otherwise search first
        hits = search_nonprofit(name)
        time.sleep(0.5)

        best = pick_best(hits, name)
        if not best:
            not_found.append(key)
            print("NOT FOUND")
            continue

        ein = str(best.get("ein", ""))
        org_name = best.get("name", "")
        sys.stdout.write(f"-> {org_name} (EIN {ein}) ... ")
        sys.stdout.flush()

        # Get detailed filing data
        detail = get_org_detail(ein)
        time.sleep(0.5)

        if detail:
            results[key] = detail
            rev = detail.get("total_revenue")
            rev_str = f"${rev:,.0f}" if rev else "N/A"
            n_filings = len(detail.get("filings", []))
            print(f"OK -- revenue: {rev_str}, {n_filings} filings")
        else:
            not_found.append(key)
            print("DETAIL FAILED")

    # Write output
    outpath = "scripts/propublica_enriched.json"
    with open(outpath, "w") as f:
        json.dump(results, f, indent=2)

    print(f"\nDone: {len(results)} enriched, {len(not_found)} not found")
    if not_found:
        print(f"Not found: {', '.join(not_found)}")
    print(f"\nOutput: {outpath}")

    # Summary table
    if results:
        hdr = f"{'Entity':<35} {'EIN':<12} {'Revenue':>15} {'Assets':>15} {'Filings':>8}"
        print(f"\n{hdr}")
        print("-" * 87)
        for key in sorted(results.keys()):
            r = results[key]
            rname = r.get("name", key)[:34]
            ein = str(r.get("ein", "N/A"))
            rev = r.get("total_revenue")
            assets = r.get("total_assets")
            rev_s = f"${rev:>13,.0f}" if rev else "          N/A"
            asset_s = f"${assets:>13,.0f}" if assets else "          N/A"
            n_fil = len(r.get("filings", []))
            print(f"{rname:<35} {ein:<12} {rev_s} {asset_s} {n_fil:>8}")


if __name__ == "__main__":
    main()
