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

# Input/output paths (relative to repo root via script location)
_SITE_DATA = Path(__file__).resolve().parent.parent / "site" / "data"
INPUT_FILE = _SITE_DATA / "graph.json"
OUTPUT_FILE = _SITE_DATA / "networkx.json"


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


def compute_structural_signatures(
    digraph: nx.DiGraph, undirected: nx.Graph, communities: List[frozenset],
    betweenness: Dict[str, float], coreness: Dict[str, int],
) -> Dict[str, Any]:
    """
    Compute criminology-informed structural signatures.

    Compares the network's topology against known patterns from
    trafficking, money laundering, intelligence, corruption, and
    coercive control networks. Each metric includes the raw value
    and a brief interpretation.

    References:
      - Graph and Network Theory for Criminal Networks (2103.02504)
      - The geometry of suspicious money laundering (EPJ Data Sci 2022)
      - Criminal organizations exhibit hysteresis (Sci Rep 2024)
      - Not all madams have a central role (Trends Org Crime 2013)
      - The Topology of Dark Networks (CACM)
    """
    from scipy import stats

    result: Dict[str, Any] = {}
    n_nodes = undirected.number_of_nodes()
    n_edges = undirected.number_of_edges()
    if n_nodes < 3:
        return {"error": "Graph too small for structural analysis"}

    # ── 1. Degree distribution ──────────────────────────────────
    degrees = [d for _, d in undirected.degree()]
    result["degree_distribution"] = {
        "mean": round(sum(degrees) / len(degrees), 2),
        "max": max(degrees),
        "min": min(degrees),
        "skewness": round(float(stats.skew(degrees)), 4),
        "interpretation": (
            "right-skewed (hub-dominated)"
            if stats.skew(degrees) > 1.5
            else "moderately skewed"
            if stats.skew(degrees) > 0.5
            else "symmetric"
        ),
    }

    # ── 2. Assortativity ────────────────────────────────────────
    assort = nx.degree_assortativity_coefficient(undirected)
    result["assortativity"] = {
        "coefficient": round(assort, 4),
        "interpretation": (
            "disassortative (hubs connect to low-degree nodes — "
            "patron-client / command structure)"
            if assort < -0.1
            else "neutral"
            if assort < 0.1
            else "assortative (hubs connect to hubs — peer network)"
        ),
        "matches": (
            ["money_laundering", "patronage", "trafficking"]
            if assort < -0.1
            else ["social_network"]
            if assort > 0.1
            else []
        ),
    }

    # ── 3. Transitivity / triadic closure ───────────────────────
    transitivity = nx.transitivity(undirected)
    avg_clustering = nx.average_clustering(undirected)
    result["transitivity"] = {
        "global": round(transitivity, 4),
        "avg_clustering": round(avg_clustering, 4),
        "interpretation": (
            "low triadic closure (strategic compartmentalization)"
            if transitivity < 0.15
            else "moderate"
            if transitivity < 0.35
            else "high (trust-based / insecure operations)"
        ),
        "matches": (
            ["corruption", "intelligence", "compartmentalized"]
            if transitivity < 0.15
            else ["trafficking", "fast_operations"]
            if transitivity > 0.35
            else []
        ),
    }

    # ── 4. Small-world test ─────────────────────────────────────
    if nx.is_connected(undirected):
        avg_path = nx.average_shortest_path_length(undirected)
        # Compare to random graph
        p = 2 * n_edges / (n_nodes * (n_nodes - 1))
        C_rand = p  # expected clustering for Erdos-Renyi
        import math
        L_rand = math.log(n_nodes) / math.log(max(1, n_nodes * p)) if p > 0 else float('inf')
        sigma = (avg_clustering / max(C_rand, 0.001)) / (avg_path / max(L_rand, 0.001))
        result["small_world"] = {
            "avg_path_length": round(avg_path, 4),
            "sigma": round(sigma, 4),
            "is_small_world": sigma > 1.0,
            "interpretation": (
                "small-world (high clustering + short paths — "
                "consistent with covert/dark networks)"
                if sigma > 1.0
                else "not small-world"
            ),
        }
    else:
        result["small_world"] = {"error": "graph not connected"}

    # ── 5. Network centralization ───────────────────────────────
    max_degree = max(degrees)
    total_degree = sum(degrees)
    centralization = max_degree / total_degree if total_degree > 0 else 0
    # Freeman centralization
    degree_centrality = nx.degree_centrality(undirected)
    max_dc = max(degree_centrality.values())
    freeman = sum(max_dc - v for v in degree_centrality.values()) / ((n_nodes - 1) * (n_nodes - 2) / (n_nodes - 1)) if n_nodes > 2 else 0
    result["centralization"] = {
        "degree_share": round(centralization, 4),
        "freeman": round(freeman, 4),
        "interpretation": (
            "extreme centralization (cult / coercive control pattern)"
            if centralization > 0.5
            else "high centralization (star topology)"
            if centralization > 0.3
            else "moderate"
            if centralization > 0.15
            else "decentralized"
        ),
        "matches": (
            ["cult", "blackmail", "coercive_control"]
            if centralization > 0.5
            else ["hub_and_spoke"]
            if centralization > 0.3
            else []
        ),
    }

    # ── 6. Broker detection (betweenness/degree ratio) ──────────
    degree_dict = dict(undirected.degree())
    broker_ratio = {}
    for node in undirected.nodes():
        d = degree_dict[node]
        b = betweenness.get(node, 0)
        broker_ratio[node] = round(b / max(d, 1) * n_nodes, 4)
    top_brokers = sorted(broker_ratio.items(), key=lambda x: x[1], reverse=True)[:10]
    result["broker_detection"] = {
        "description": "Betweenness/degree ratio — high ratio = strategic positioning with minimal exposure",
        "top_brokers": [
            {"entity": e, "ratio": r, "betweenness": round(betweenness.get(e, 0), 6), "degree": degree_dict[e]}
            for e, r in top_brokers
        ],
    }

    # ── 7. Core-periphery analysis ──────────────────────────────
    max_core = max(coreness.values()) if coreness else 0
    core_nodes = [n for n, k in coreness.items() if k == max_core]
    periphery_nodes = [n for n, k in coreness.items() if k < max_core]
    core_subgraph = undirected.subgraph(core_nodes)
    core_density = nx.density(core_subgraph) if len(core_nodes) > 1 else 0
    periphery_subgraph = undirected.subgraph(periphery_nodes)
    periphery_density = nx.density(periphery_subgraph) if len(periphery_nodes) > 1 else 0
    result["core_periphery"] = {
        "max_k_core": max_core,
        "core_size": len(core_nodes),
        "periphery_size": len(periphery_nodes),
        "core_density": round(core_density, 4),
        "periphery_density": round(periphery_density, 4),
        "core_members": sorted(core_nodes),
        "interpretation": (
            "strong core-periphery (dense core, sparse periphery — "
            "corruption / elite capture pattern)"
            if core_density > 0.5 and periphery_density < 0.1
            else "moderate core-periphery"
            if core_density > 0.3
            else "weak core-periphery"
        ),
    }

    # ── 8. Triad census (directed graph) ────────────────────────
    triad_census = nx.triadic_census(digraph)
    # Compare to notable types
    result["triad_census"] = {
        "003": triad_census.get("003", 0),  # empty
        "012": triad_census.get("012", 0),  # single edge
        "021D": triad_census.get("021D", 0),  # brokerage/mediation
        "030C": triad_census.get("030C", 0),  # hierarchical control
        "030T": triad_census.get("030T", 0),  # transitive
        "111U": triad_census.get("111U", 0),  # mixed
        "300": triad_census.get("300", 0),  # complete
        "interpretation": (
            "021D (brokerage) and 030C (hierarchy) are indicators of "
            "compartmentalized dark networks when overrepresented vs null model"
        ),
    }

    # ── 9. Community modularity ─────────────────────────────────
    if communities:
        community_map = {}
        for idx, comm in enumerate(communities):
            for node in comm:
                community_map[node] = idx
        partition = community_map
        modularity = nx.algorithms.community.modularity(undirected, communities)
        comm_sizes = sorted([len(c) for c in communities], reverse=True)
        result["modularity"] = {
            "value": round(modularity, 4),
            "num_communities": len(communities),
            "sizes": comm_sizes,
            "interpretation": (
                "high modularity (>0.4 — compartmentalized cells, "
                "consistent with intelligence / covert operations)"
                if modularity > 0.4
                else "moderate modularity"
                if modularity > 0.25
                else "low modularity (densely connected)"
            ),
            "matches": (
                ["intelligence", "terrorism", "compartmentalized"]
                if modularity > 0.4
                else []
            ),
        }
    else:
        result["modularity"] = {"error": "no communities detected"}

    # ── 10. Reciprocity (directed) ──────────────────────────────
    recip = nx.reciprocity(digraph)
    result["reciprocity"] = {
        "value": round(recip, 4),
        "interpretation": (
            "high reciprocity (trust-based co-offending pattern)"
            if recip > 0.5
            else "moderate"
            if recip > 0.25
            else "low reciprocity (hierarchical / one-way commands)"
        ),
    }

    # ── 11. Composite pattern matching (gradient scoring) ───────
    # Continuous gradient functions instead of binary thresholds.
    # Each returns 0.0-1.0 based on how far the metric is into
    # the "matching" range, not just whether it crosses a line.
    def _grad(val, lo, hi, invert=False):
        """Linear gradient: 0 at lo, 1 at hi. Clamp [0,1]. invert flips."""
        if hi == lo:
            return 1.0 if val >= hi else 0.0
        score = max(0.0, min(1.0, (val - lo) / (hi - lo)))
        return (1.0 - score) if invert else score

    # Corrected reciprocity: CUE stores bidirectional edges (A→B and B→A),
    # which inflates directed reciprocity to ~1.0.  Use the undirected
    # density ratio as a more meaningful symmetry proxy.
    n_directed_edges = digraph.number_of_edges()
    n_undirected_edges = undirected.number_of_edges()
    # If every directed edge has a reverse, ratio ≈ 0.5
    edge_symmetry = n_undirected_edges / max(n_directed_edges, 1)
    # True asymmetry: fraction of connections that are NOT reciprocated
    true_asymmetry = 1.0 - edge_symmetry  # 0 = fully symmetric, ~0.5 = fully asymmetric

    skewness = float(stats.skew(degrees))
    modularity = result.get("modularity", {}).get("value", 0)
    sw_sigma = result.get("small_world", {}).get("sigma", 1.0)
    triad_021d = result.get("triad_census", {}).get("021D", 0)
    triad_total = max(1, sum(result.get("triad_census", {}).get(k, 0)
                             for k in ("021D", "030C", "030T", "111U", "300")))

    patterns = {}

    # ── Trafficking ─────────────────────────────────────────────
    # Disassortative hub-spoke, strong brokers, low triadic closure,
    # high centralization. Ref: "Not all madams" (Trends Org Crime 2013)
    patterns["trafficking"] = round(min(1.0,
        0.25 * _grad(assort, 0.0, -0.4) +                  # disassortative
        0.25 * _grad(centralization, 0.15, 0.5) +           # centralized
        0.20 * _grad(max(r for _, r in top_brokers[:3]), 0.3, 1.5) +  # strong brokers
        0.15 * _grad(transitivity, 0.3, 0.05, invert=True) +  # low closure
        0.15 * _grad(skewness, 1.0, 8.0)                   # heavy-tailed degree
    ), 2)

    # ── Money laundering ────────────────────────────────────────
    # Dense core / sparse periphery, disassortative, layered structure,
    # heavy-tailed degree. Ref: "Geometry of suspicious money laundering"
    # (EPJ Data Sci 2022)
    cp_ratio = core_density / max(periphery_density, 0.001)
    patterns["money_laundering"] = round(min(1.0,
        0.25 * _grad(cp_ratio, 5, 50) +                    # core/periphery density ratio
        0.20 * _grad(assort, 0.0, -0.3) +                  # disassortative
        0.20 * _grad(skewness, 1.5, 10.0) +                # heavy-tailed
        0.20 * _grad(transitivity, 0.3, 0.05, invert=True) +  # compartmentalized
        0.15 * _grad(modularity, 0.2, 0.5)                 # modular cells
    ), 2)

    # ── Intelligence / covert ───────────────────────────────────
    # Small-world shortcuts, high modularity (compartmentalized cells),
    # low triadic closure, brokerage triads overrepresented.
    # Ref: "Topology of Dark Networks" (CACM)
    patterns["intelligence_covert"] = round(min(1.0,
        0.25 * _grad(sw_sigma, 1.0, 20.0) +                # small-world
        0.25 * _grad(modularity, 0.25, 0.5) +              # compartmentalized
        0.20 * _grad(transitivity, 0.25, 0.05, invert=True) +  # low closure
        0.15 * _grad(triad_021d / triad_total, 0.01, 0.15) +  # brokerage triads
        0.15 * _grad(true_asymmetry, 0.1, 0.4)             # hierarchical command
    ), 2)

    # ── Corruption / patronage ──────────────────────────────────
    # Dense inner circle, disassortative patron-client links,
    # moderate centralization, gatekeeper structure.
    # Ref: "Criminal organizations exhibit hysteresis" (Sci Rep 2024)
    patterns["corruption_patronage"] = round(min(1.0,
        0.25 * _grad(core_density, 0.2, 0.6) +             # dense inner circle
        0.25 * _grad(assort, 0.0, -0.3) +                  # patron-client
        0.20 * _grad(freeman, 0.2, 0.8) +                  # gatekeeper centralization
        0.15 * _grad(transitivity, 0.3, 0.1, invert=True) + # selective trust
        0.15 * _grad(len(core_nodes) / max(n_nodes, 1), 0.02, 0.15)  # small elite
    ), 2)

    # ── Coercive control ────────────────────────────────────────
    # Extreme centralization, very disassortative (one node dominates),
    # hierarchical command (low reciprocity), cult-like star topology.
    patterns["coercive_control"] = round(min(1.0,
        0.30 * _grad(freeman, 0.4, 0.95) +                 # extreme centralization
        0.25 * _grad(assort, -0.1, -0.5) +                 # extreme disassortativity
        0.25 * _grad(centralization, 0.3, 0.6) +           # degree monopoly
        0.20 * _grad(true_asymmetry, 0.1, 0.4)             # one-way commands
    ), 2)

    # ── Sexual exploitation network ─────────────────────────────
    # Central recruiter/controller, victim nodes with low degree,
    # extreme degree skew, very few triads among victims.
    # Ref: "Not all madams have a central role" + trafficking literature
    low_degree_fraction = sum(1 for d in degrees if d <= 2) / max(n_nodes, 1)
    patterns["sexual_exploitation"] = round(min(1.0,
        0.25 * _grad(freeman, 0.5, 0.95) +                 # central controller
        0.25 * _grad(low_degree_fraction, 0.3, 0.7) +      # many low-degree victims
        0.25 * _grad(skewness, 3.0, 12.0) +                # extreme degree skew
        0.25 * _grad(transitivity, 0.2, 0.03, invert=True)  # victims don't know each other
    ), 2)

    # ── Ponzi / financial fraud ─────────────────────────────────
    # Star topology (extreme centralization), disassortative,
    # very low clustering (no victim-to-victim links), high degree skew.
    patterns["ponzi_fraud"] = round(min(1.0,
        0.30 * _grad(centralization, 0.3, 0.6) +           # star topology
        0.25 * _grad(skewness, 2.0, 10.0) +                # extreme hub
        0.25 * _grad(transitivity, 0.15, 0.02, invert=True) + # no closure
        0.20 * _grad(assort, 0.0, -0.3)                    # hub→leaf only
    ), 2)

    # ── Organized crime (hierarchical) ──────────────────────────
    # Moderate centralization (not single hub), modular cells,
    # strong core-periphery, triad hierarchy (030C overrepresented).
    patterns["organized_crime"] = round(min(1.0,
        0.20 * _grad(modularity, 0.3, 0.55) +              # cell structure
        0.20 * _grad(core_density, 0.3, 0.6) +             # strong inner circle
        0.20 * _grad(freeman, 0.3, 0.7) +                  # hierarchy
        0.20 * _grad(assort, 0.0, -0.3) +                  # rank structure
        0.20 * _grad(sw_sigma, 2.0, 15.0)                  # efficient communication
    ), 2)

    # ── Regulatory capture ──────────────────────────────────────
    # Moderate centralization, revolving door (cross-community edges),
    # disassortative, moderate modularity.
    patterns["regulatory_capture"] = round(min(1.0,
        0.25 * _grad(freeman, 0.15, 0.5) +                 # moderate centralization
        0.25 * _grad(assort, 0.0, -0.25) +                 # cross-rank ties
        0.25 * _grad(modularity, 0.2, 0.45) +              # semi-modular
        0.25 * _grad(core_density, 0.2, 0.5)               # inner circle access
    ), 2)

    # ── Pure social network (control baseline) ──────────────────
    # Assortative, high clustering, moderate reciprocity, low centralization.
    patterns["social_network"] = round(min(1.0,
        0.30 * _grad(assort, -0.05, 0.3) +                 # homophily
        0.30 * _grad(transitivity, 0.1, 0.4) +             # triadic closure
        0.20 * _grad(centralization, 0.3, 0.05, invert=True) +  # decentralized
        0.20 * _grad(modularity, 0.15, 0.4)                # community structure
    ), 2)

    result["pattern_match"] = {
        "scores": patterns,
        "best_match": max(patterns, key=lambda k: patterns[k]),
        "best_score": max(patterns.values()),
        "edge_symmetry": round(edge_symmetry, 4),
        "true_asymmetry": round(true_asymmetry, 4),
        "interpretation": (
            "Composite scores (0-1) using continuous gradients against academic "
            "criminology literature. Higher = stronger structural resemblance. "
            "Metrics are scaled proportionally, not binary thresholds."
        ),
    }

    return result


def export_graph_formats(undirected: nx.Graph) -> None:
    """Export GEXF and GraphML for interoperability with Gephi, Cytoscape, etc."""
    # Create a clean copy with only scalar node attributes
    # (GEXF/GraphML don't support dicts or lists)
    clean = nx.Graph()
    scalar_types = (str, int, float, bool)
    for node, data in undirected.nodes(data=True):
        attrs = {k: v for k, v in data.items() if isinstance(v, scalar_types)}
        clean.add_node(node, **attrs)
    for u, v, data in undirected.edges(data=True):
        attrs = {k: v for k, v in data.items() if isinstance(v, scalar_types)}
        clean.add_edge(u, v, **attrs)

    gexf_path = _SITE_DATA / "graph.gexf"
    graphml_path = _SITE_DATA / "graph.graphml"
    try:
        nx.write_gexf(clean, str(gexf_path))
        print(f"GEXF export: {gexf_path}", file=sys.stderr)
    except Exception as e:
        print(f"Warning: GEXF export failed: {e}", file=sys.stderr)
    try:
        nx.write_graphml(clean, str(graphml_path))
        print(f"GraphML export: {graphml_path}", file=sys.stderr)
    except Exception as e:
        print(f"Warning: GraphML export failed: {e}", file=sys.stderr)


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

    print("Computing structural signatures...", file=sys.stderr)
    signatures = compute_structural_signatures(
        digraph, undirected, communities, betweenness, coreness,
    )
    best = signatures.get("pattern_match", {})
    print(
        f"Best pattern match: {best.get('best_match', '?')} "
        f"({best.get('best_score', 0):.0%} fit)",
        file=sys.stderr,
    )

    print("Exporting graph interchange formats...", file=sys.stderr)
    export_graph_formats(undirected)

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
    output["structural_signatures"] = signatures

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
