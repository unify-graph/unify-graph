#!/usr/bin/env python3
"""Export graph data in TOON (Token Oriented Object Notation) format.

TOON reduces LLM token usage ~55% for tabular data by grouping into
compact CSV-like tables. Output goes to site/data/graph.toon.
"""

import json
import sys
from pathlib import Path

SITE_DATA = Path(__file__).parent.parent / "site" / "data"


def load(name):
    p = SITE_DATA / f"{name}.json"
    if not p.exists():
        print(f"Warning: {p} not found, skipping", file=sys.stderr)
        return None
    with open(p) as f:
        return json.load(f)


def escape(val):
    """Escape commas and pipes in values."""
    s = str(val) if val is not None else ""
    return s.replace(",", ";").replace("|", "/")


def main():
    graph = load("graph")
    networkx = load("networkx")
    if not graph:
        print("Error: graph.json required", file=sys.stderr)
        sys.exit(1)

    # Load wikidata QIDs
    qid_path = Path(__file__).parent / "wikidata_qids.json"
    qids = {}
    if qid_path.exists():
        with open(qid_path) as f:
            qids = json.load(f)

    nx_nodes = networkx.get("nodes", {}) if networkx else {}
    nodes = graph["nodes"]
    links = graph["links"]

    lines = []
    lines.append("# unify-graph TOON export — 132 entities, 398 connections")
    lines.append("# Generated from site/data/{graph,networkx}.json")
    lines.append("")

    # Entity table
    fields = "id,name,cluster,types,out,in,gaps,evidence,mentions,community,betweenness,pagerank,coreness,wikidata"
    lines.append(f"entities[{len(nodes)}]{{{fields}}}:")
    for n in sorted(nodes, key=lambda x: x["id"]):
        nx = nx_nodes.get(n["id"], {})
        vals = [
            escape(n["id"]),
            escape(n["name"]),
            escape(n["cluster"]),
            "|".join(escape(t) for t in n.get("types", [])),
            str(n.get("connection_count", 0)),
            str(n.get("inbound_count", 0)),
            str(n.get("gap_count", 0)),
            "Y" if n.get("has_evidence") else "N",
            str(n.get("mention_count", 0)),
            str(nx.get("community", "")),
            f"{nx.get('betweenness', 0):.4f}" if "betweenness" in nx else "",
            f"{nx.get('pagerank', 0):.4f}" if "pagerank" in nx else "",
            str(nx.get("coreness", "")),
            qids.get(n["id"], ""),
        ]
        lines.append(f"  {','.join(vals)}")

    lines.append("")

    # Connection table
    fields = "source,target,bidir,context"
    lines.append(f"connections[{len(links)}]{{{fields}}}:")
    for link in sorted(links, key=lambda x: (x["source"], x["target"])):
        src = link["source"] if isinstance(link["source"], str) else link["source"].get("id", "")
        tgt = link["target"] if isinstance(link["target"], str) else link["target"].get("id", "")
        vals = [
            escape(src),
            escape(tgt),
            "Y" if link.get("bidirectional") else "N",
            escape(link.get("context", "")),
        ]
        lines.append(f"  {','.join(vals)}")

    lines.append("")

    # Community summary table
    if networkx and "communities" in networkx:
        comms = networkx["communities"]
        fields = "id,size,members"
        lines.append(f"communities[{len(comms)}]{{{fields}}}:")
        for c in sorted(comms, key=lambda x: -x["size"]):
            lines.append(f"  {c['id']},{c['size']},{' '.join(sorted(c['members']))}")
        lines.append("")

    out = SITE_DATA / "graph.toon"
    out.write_text("\n".join(lines))
    print(f"TOON export: {len(nodes)} entities, {len(links)} connections → {out}")
    print(f"Size: {out.stat().st_size:,} bytes vs ~{(SITE_DATA / 'graph.json').stat().st_size:,} bytes (graph.json)")


if __name__ == "__main__":
    main()
