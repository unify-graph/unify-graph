#!/usr/bin/env python3
"""
NetworkX-based graph analysis for unify-graph.

Computes multiple centrality metrics, community detection, and graph statistics
on the node-link JSON format graph. Outputs comprehensive analysis to JSON.
"""

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Tuple

import networkx as nx

# Input/output paths
INPUT_FILE = Path("/home/mthdn/unify-graph/site/data/graph.json")
OUTPUT_FILE = Path("/home/mthdn/unify-graph/site/data/networkx.json")


def load_graph_json(filepath: Path) -> Tuple[List[Dict], List[Dict]]:
    """Load node-link format JSON and return nodes and links."""
    try:
        with open(filepath, "r") as f:
            data = json.load(f)
        return data.get("nodes", []), data.get("links", [])
    except FileNotFoundError:
        print(f"Error: {filepath} not found", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        sys.exit(1)


def build_graphs(
    nodes: List[Dict], links: List[Dict]
) -> Tuple[nx.DiGraph, nx.Graph]:
    """Build both directed and undirected graphs."""
    digraph = nx.DiGraph()
    undirected = nx.Graph()

    # Add nodes with their metadata
    for node in nodes:
        node_id = node.get("id")
        if node_id:
            digraph.add_node(node_id, **node)
            undirected.add_node(node_id, **node)

    # Add edges
    for link in links:
        source = link.get("source")
        target = link.get("target")
        if source and target:
            digraph.add_edge(source, target)
            undirected.add_edge(source, target)

    return digraph, undirected


def compute_betweenness_centrality(G: nx.Graph) -> Dict[str, float]:
    """Compute normalized betweenness centrality."""
    try:
        return nx.betweenness_centrality(G, normalized=True)
    except Exception as e:
        print(f"Warning: Betweenness centrality failed: {e}", file=sys.stderr)
        return {node: 0.0 for node in G.nodes()}


def compute_pagerank(G: nx.DiGraph, max_iter: int = 100) -> Dict[str, float]:
    """Compute PageRank on directed graph."""
    try:
        if len(G) == 0:
            return {}
        return nx.pagerank(G, max_iter=max_iter, tol=1e-6)
    except Exception as e:
        print(f"Warning: PageRank failed: {e}", file=sys.stderr)
        return {node: 1.0 / len(G) for node in G.nodes()} if len(G) > 0 else {}


def compute_eigenvector_centrality(
    G: nx.Graph, max_iter: int = 1000
) -> Dict[str, float]:
    """Compute eigenvector centrality with fallback on convergence failure."""
    try:
        # Try with default iteration limit
        return nx.eigenvector_centrality(G, max_iter=max_iter, tol=1e-6)
    except nx.NetworkXError as e:
        # Fallback: Use degree centrality if eigenvector fails
        print(
            f"Warning: Eigenvector centrality didn't converge, using degree centrality: {e}",
            file=sys.stderr,
        )
        return nx.degree_centrality(G)
    except Exception as e:
        print(f"Warning: Eigenvector centrality failed: {e}", file=sys.stderr)
        return {node: 0.0 for node in G.nodes()}


def compute_degree_centrality(
    digraph: nx.DiGraph, undirected: nx.Graph
) -> Tuple[Dict[str, float], Dict[str, float]]:
    """Compute in-degree and out-degree centrality."""
    try:
        in_degree = nx.in_degree_centrality(digraph)
        out_degree = nx.out_degree_centrality(digraph)
        return in_degree, out_degree
    except Exception as e:
        print(f"Warning: Degree centrality failed: {e}", file=sys.stderr)
        empty = {node: 0.0 for node in undirected.nodes()}
        return empty, empty


def detect_communities(G: nx.Graph) -> List[frozenset]:
    """Detect communities using greedy modularity optimization."""
    try:
        if len(G) == 0:
            return []
        communities = list(nx.algorithms.community.greedy_modularity_communities(G))
        return communities
    except Exception as e:
        print(f"Warning: Community detection failed: {e}", file=sys.stderr)
        return []


def compute_kcore(G: nx.Graph) -> Dict[str, int]:
    """Compute k-core decomposition (coreness values)."""
    try:
        return nx.core_number(G)
    except Exception as e:
        print(f"Warning: K-core decomposition failed: {e}", file=sys.stderr)
        return {node: 0 for node in G.nodes()}


def analyze_connected_components(G: nx.Graph) -> Dict[str, Any]:
    """Analyze connected components."""
    try:
        components = list(nx.connected_components(G))
        num_components = len(components)
        largest_size = max(len(c) for c in components) if components else 0
        return {
            "connected": num_components,
            "largest_size": largest_size,
            "num_components": num_components,
        }
    except Exception as e:
        print(f"Warning: Connected components analysis failed: {e}", file=sys.stderr)
        return {"connected": 0, "largest_size": 0, "num_components": 0}


def get_top_n(scores: Dict[str, float], n: int = 20) -> List[Dict[str, Any]]:
    """Get top N entities by score."""
    sorted_items = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    return [{"entity": entity, "score": round(score, 6)} for entity, score in sorted_items[:n]]


def build_output(
    nodes: List[Dict],
    digraph: nx.DiGraph,
    undirected: nx.Graph,
    betweenness: Dict[str, float],
    pagerank: Dict[str, float],
    eigenvector: Dict[str, float],
    in_degree: Dict[str, float],
    out_degree: Dict[str, float],
    coreness: Dict[str, int],
    communities: List[frozenset],
    components_info: Dict[str, Any],
) -> Dict[str, Any]:
    """Build comprehensive output structure."""
    # Map community membership
    community_map = {}
    for comm_idx, community in enumerate(communities):
        for node_id in community:
            community_map[node_id] = comm_idx

    # Build nodes output with all metrics
    nodes_output = {}
    for node in nodes:
        node_id = node.get("id")
        if node_id:
            nodes_output[node_id] = {
                "betweenness": round(betweenness.get(node_id, 0.0), 6),
                "pagerank": round(pagerank.get(node_id, 0.0), 6),
                "eigenvector": round(eigenvector.get(node_id, 0.0), 6),
                "community": community_map.get(node_id, -1),
                "in_degree_centrality": round(in_degree.get(node_id, 0.0), 6),
                "out_degree_centrality": round(out_degree.get(node_id, 0.0), 6),
                "coreness": coreness.get(node_id, 0),
            }

    # Build communities output
    communities_output = [
        {
            "id": idx,
            "members": sorted(list(community)),
            "size": len(community),
        }
        for idx, community in enumerate(communities)
    ]

    # Build output structure
    output = {
        "meta": {
            "generated": datetime.now(timezone.utc).isoformat(),
            "nodes": len(nodes),
            "edges": undirected.number_of_edges(),
        },
        "nodes": nodes_output,
        "communities": communities_output,
        "components": components_info,
        "top_betweenness": get_top_n(betweenness, 20),
        "top_pagerank": get_top_n(pagerank, 20),
    }

    return output


def main():
    """Main analysis pipeline."""
    print("Loading graph data...", file=sys.stderr)
    nodes, links = load_graph_json(INPUT_FILE)
    print(f"Loaded {len(nodes)} nodes and {len(links)} links", file=sys.stderr)

    print("Building NetworkX graphs...", file=sys.stderr)
    digraph, undirected = build_graphs(nodes, links)
    print(
        f"Directed graph: {digraph.number_of_nodes()} nodes, {digraph.number_of_edges()} edges",
        file=sys.stderr,
    )
    print(
        f"Undirected graph: {undirected.number_of_nodes()} nodes, {undirected.number_of_edges()} edges",
        file=sys.stderr,
    )

    print("Computing centrality metrics...", file=sys.stderr)
    betweenness = compute_betweenness_centrality(undirected)
    pagerank = compute_pagerank(digraph)
    eigenvector = compute_eigenvector_centrality(undirected)
    in_degree, out_degree = compute_degree_centrality(digraph, undirected)

    print("Computing k-core decomposition...", file=sys.stderr)
    coreness = compute_kcore(undirected)

    print("Detecting communities...", file=sys.stderr)
    communities = detect_communities(undirected)
    print(f"Found {len(communities)} communities", file=sys.stderr)

    print("Analyzing connected components...", file=sys.stderr)
    components_info = analyze_connected_components(undirected)
    print(
        f"Connected components: {components_info['connected']}, largest: {components_info['largest_size']} nodes",
        file=sys.stderr,
    )

    print("Building output structure...", file=sys.stderr)
    output = build_output(
        nodes,
        digraph,
        undirected,
        betweenness,
        pagerank,
        eigenvector,
        in_degree,
        out_degree,
        coreness,
        communities,
        components_info,
    )

    print(f"Writing results to {OUTPUT_FILE}...", file=sys.stderr)
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w") as f:
        json.dump(output, f, indent=2)

    # Print summary
    print("\n=== Analysis Summary ===", file=sys.stdout)
    print(f"Nodes: {output['meta']['nodes']}", file=sys.stdout)
    print(f"Edges: {output['meta']['edges']}", file=sys.stdout)
    print(f"Communities detected: {len(output['communities'])}", file=sys.stdout)
    print(f"Connected components: {output['components']['connected']}", file=sys.stdout)
    print(f"Largest component: {output['components']['largest_size']} nodes", file=sys.stdout)
    print(f"\nTop 5 by betweenness centrality:", file=sys.stdout)
    for item in output["top_betweenness"][:5]:
        print(f"  {item['entity']}: {item['score']}", file=sys.stdout)
    print(f"\nTop 5 by PageRank:", file=sys.stdout)
    for item in output["top_pagerank"][:5]:
        print(f"  {item['entity']}: {item['score']}", file=sys.stdout)
    print(f"\nOutput written to: {OUTPUT_FILE}", file=sys.stdout)


if __name__ == "__main__":
    main()
