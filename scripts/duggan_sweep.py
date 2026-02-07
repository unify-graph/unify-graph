#!/usr/bin/env python3
"""Bulk DugganUSA API sweep for low-mention entities.

Queries the DugganUSA Epstein Files API for entities with few or no mentions,
recording hit counts and top result snippets for evidence reconciliation.

Usage:
  python3 scripts/duggan_sweep.py [--threshold N]

API: https://analytics.dugganusa.com/api/v1/search
No authentication required.
"""
import json
import sys
import time
import urllib.error
import urllib.request
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path

API_URL = "https://analytics.dugganusa.com/api/v1/search"
UA = "unify-graph/1.0 (Epstein network research; contact@dugganusa.com)"
RATE_LIMIT = 1.0  # seconds between requests

# Entities with mention_count <= this are swept
DEFAULT_THRESHOLD = 20


def api_search(query, max_results=10):
    """Search DugganUSA API, return parsed response or None."""
    params = urllib.parse.urlencode({
        "q": query,
        "indexes": "epstein_files",
        "limit": str(max_results),
    })
    url = f"{API_URL}?{params}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        print(f"  HTTP {e.code}: {e.reason}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"  ERROR: {e}", file=sys.stderr)
        return None


def extract_hits(response):
    """Extract hit count and top results from API response.

    DugganUSA response shape:
      {success: bool, data: {query, totalHits: int, hits: [{content_preview, source, dataset, efta_id, ...}]}}
    """
    if not response or not isinstance(response, dict):
        return 0, []

    data = response.get("data", {})
    if not isinstance(data, dict):
        return 0, []

    total = data.get("totalHits", 0)
    raw_hits = data.get("hits", [])

    hits = []
    for r in raw_hits[:10]:
        hits.append({
            "efta_id": r.get("efta_id", ""),
            "snippet": (r.get("content_preview", "") or r.get("content", ""))[:300],
            "source": r.get("source", ""),
            "dataset": r.get("dataset", ""),
            "doc_type": r.get("doc_type", ""),
            "people": r.get("people", []),
            "file_path": r.get("file_path", ""),
        })

    return total, hits


def main():
    threshold = DEFAULT_THRESHOLD
    if "--threshold" in sys.argv:
        idx = sys.argv.index("--threshold")
        if idx + 1 < len(sys.argv):
            threshold = int(sys.argv[idx + 1])

    # Load entities
    try:
        with open("site/data/entities.json") as f:
            entities = json.load(f)
    except FileNotFoundError:
        print("ERROR: site/data/entities.json not found. Run ./build.sh first.",
              file=sys.stderr)
        sys.exit(1)

    # Filter to low-mention entities
    targets = {}
    for key, ent in entities.items():
        mentions = ent.get("mention_count", 0)
        if mentions <= threshold:
            targets[key] = ent

    print(f"DugganUSA sweep: {len(targets)} entities with mention_count <= {threshold}\n")

    results = {}
    errors = []
    new_hits = 0

    for key in sorted(targets.keys()):
        ent = targets[key]
        name = ent["name"]
        old_mentions = ent.get("mention_count", 0)

        sys.stdout.write(f"  {key:<30} {name:<30} (was {old_mentions}) ... ")
        sys.stdout.flush()

        resp = api_search(name)
        time.sleep(RATE_LIMIT)

        if resp is None:
            errors.append(key)
            print("ERROR")
            continue

        total, hits = extract_hits(resp)

        results[key] = {
            "name": name,
            "old_mentions": old_mentions,
            "new_total": total,
            "delta": total - old_mentions if total > old_mentions else 0,
            "top_results": hits[:5],
            "raw_response_keys": list(resp.keys()) if isinstance(resp, dict) else type(resp).__name__,
        }

        marker = " NEW!" if total > old_mentions else ""
        if total > 0:
            new_hits += 1
        print(f"{total} hits{marker}")

    # Write results
    output = {
        "timestamp": datetime.now(tz=timezone.utc).isoformat(),
        "threshold": threshold,
        "entities_swept": len(targets),
        "entities_with_hits": new_hits,
        "errors": errors,
        "results": results,
    }

    out_path = Path("scripts/duggan_sweep_results.json")
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    print(f"\nDone: {len(targets)} swept, {new_hits} with hits, {len(errors)} errors")
    print(f"Output: {out_path}")

    # Summary of entities with significant new hits
    upgrades = [(k, v) for k, v in results.items() if v["new_total"] > v["old_mentions"]]
    if upgrades:
        upgrades.sort(key=lambda x: x[1]["new_total"], reverse=True)
        print(f"\nEntities with new/increased hits ({len(upgrades)}):")
        for key, data in upgrades[:20]:
            print(f"  {key:<30} {data['old_mentions']:>5} -> {data['new_total']:>5}  (+{data['delta']})")
            for hit in data["top_results"][:2]:
                title = hit.get("title", "")[:60]
                if title:
                    print(f"    > {title}")


if __name__ == "__main__":
    main()
