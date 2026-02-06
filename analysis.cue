// Network analysis patterns for investigation graph.
//
// Adapted from infrastructure dependency analysis to social/investigative
// network analysis. Key differences from infrastructure graphs:
//   - Connections are bidirectional (social ties, not directed dependencies)
//   - Cycles exist (A→B→C→A is normal in social networks)
//   - "Failure" means "cooperation/exposure" not "system down"
//   - "Blast radius" becomes "exposure radius"
//
// Export:
//   cue export -e analysis ./...
package creeps

// ═══════════════════════════════════════════════════════════════
// ADJACENCY MATRIX (undirected)
// Pre-compute bidirectional neighbor sets for all entities.
// If A→B exists in connections, both A↔B are neighbors.
// ═══════════════════════════════════════════════════════════════

_adjacency: {
	for _ename, _e in entities
	for _conn, _ in _e.connections
	if _entityNames[_conn] != _|_ {
		(_ename): (_conn): true
		(_conn): (_ename): true
	}
}

// ═══════════════════════════════════════════════════════════════
// HOP DISTANCE — BFS from key entities
// How many connection hops from Epstein/Maxwell to each entity?
// Entities unreachable within 5 hops are truly peripheral.
// ═══════════════════════════════════════════════════════════════

// BFS from Epstein
_epstein_seen0: {epstein: true}
_epstein_wave1: {
	for _w, _ in _epstein_seen0
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _epstein_seen0[_n] == _|_ {
		(_n): true
	}
}
_epstein_seen1: {_epstein_seen0, _epstein_wave1}
_epstein_wave2: {
	for _w, _ in _epstein_wave1
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _epstein_seen1[_n] == _|_ {
		(_n): true
	}
}
_epstein_seen2: {_epstein_seen1, _epstein_wave2}
_epstein_wave3: {
	for _w, _ in _epstein_wave2
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _epstein_seen2[_n] == _|_ {
		(_n): true
	}
}
_epstein_seen3: {_epstein_seen2, _epstein_wave3}
_epstein_wave4: {
	for _w, _ in _epstein_wave3
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _epstein_seen3[_n] == _|_ {
		(_n): true
	}
}
_epstein_seen4: {_epstein_seen3, _epstein_wave4}

// Assign hop distance per entity
_hopFromEpstein: {
	for _ename, _ in entities {
		if _epstein_seen0[_ename] != _|_ {
			(_ename): 0
		}
		if _epstein_seen0[_ename] == _|_
		if _epstein_wave1[_ename] != _|_ {
			(_ename): 1
		}
		if _epstein_seen1[_ename] == _|_
		if _epstein_wave2[_ename] != _|_ {
			(_ename): 2
		}
		if _epstein_seen2[_ename] == _|_
		if _epstein_wave3[_ename] != _|_ {
			(_ename): 3
		}
		if _epstein_seen3[_ename] == _|_
		if _epstein_wave4[_ename] != _|_ {
			(_ename): 4
		}
		if _epstein_seen4[_ename] == _|_ {
			(_ename): -1 // unreachable within 4 hops
		}
	}
}

// ═══════════════════════════════════════════════════════════════
// SOLE CONNECTORS — entities that are the ONLY bridge between
// two clusters. Removing them disconnects those worlds.
// Investigation analog of Single Points of Failure.
// ═══════════════════════════════════════════════════════════════

// For each directed cluster pair, which entities bridge them?
_clusterPairBridges: {
	for _ename, _e in entities
	for _conn, _ in _e.connections
	if _entityNames[_conn] != _|_
	if _e.cluster != entities[_conn].cluster {
		"\(_e.cluster)|\(entities[_conn].cluster)": (_ename): true
	}
}

// Sole connectors: cluster pairs with exactly one bridging entity
_soleConnectorPairs: [
	for _pair, _members in _clusterPairBridges
	if len([for _m, _ in _members {_m}]) == 1 {
		pair:    _pair
		entity:  [for _m, _ in _members {_m}][0]
		name:    entities[[for _m, _ in _members {_m}][0]].name
		from:    entities[[for _m, _ in _members {_m}][0]].cluster
	},
]

// Group sole connector pairs by entity to show who is critical
_soleConnectorByEntity: {
	for _item in _soleConnectorPairs {
		(_item.entity): pairs: (_item.pair): true
	}
}

// ═══════════════════════════════════════════════════════════════
// EXPOSURE CASCADE — if entity X cooperates/flips, who is
// directly exposed through their connections?
//
// Wave 0: the cooperator
// Wave 1: direct connections (can be named in testimony)
// Wave 2: connections of wave 1 (second-degree exposure)
// Wave 3: third-degree exposure
//
// Pre-computed for key entities.
// ═══════════════════════════════════════════════════════════════

// Maxwell exposure cascade
_maxwell_w0: {maxwell: true}
_maxwell_w1: {
	for _w, _ in _maxwell_w0
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _maxwell_w0[_n] == _|_ {(_n): true}
}
_maxwell_s1: {_maxwell_w0, _maxwell_w1}
_maxwell_w2: {
	for _w, _ in _maxwell_w1
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _maxwell_s1[_n] == _|_ {(_n): true}
}

// Jes Staley exposure cascade (banking→core bridge)
_staley_w0: {jes_staley: true}
_staley_w1: {
	for _w, _ in _staley_w0
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _staley_w0[_n] == _|_ {(_n): true}
}
_staley_s1: {_staley_w0, _staley_w1}
_staley_w2: {
	for _w, _ in _staley_w1
	if _adjacency[_w] != _|_
	for _n, _ in _adjacency[_w]
	if _staley_s1[_n] == _|_ {(_n): true}
}

// ═══════════════════════════════════════════════════════════════
// EVIDENCE INTEGRITY — if a document is discredited, which
// entities lose their evidence base?
// ═══════════════════════════════════════════════════════════════

// Map: document → entities that cite it as evidence
_docDependents: {
	for _ename, _e in entities
	for _doc, _ in _e.evidence {
		(_doc): (_ename): true
	}
}

// ═══════════════════════════════════════════════════════════════
// ANALYSIS EXPORT
// cue export -e analysis ./...
// ═══════════════════════════════════════════════════════════════

analysis: {
	// Hop distance from Epstein — how close is each entity?
	hop_distance: {
		from_epstein: {
			wave_0: [for _n, _ in _epstein_seen0 {_n}]
			wave_1: [for _n, _ in _epstein_wave1 {_n}]
			wave_2: [for _n, _ in _epstein_wave2 {_n}]
			wave_3: [for _n, _ in _epstein_wave3 {_n}]
			wave_4: [for _n, _ in _epstein_wave4 {_n}]
			unreachable: [
				for _ename, _ in entities
				if _epstein_seen4[_ename] == _|_ {_ename},
			]
			reachability: {
				hop_0: len([for _n, _ in _epstein_seen0 {_n}])
				hop_1: len([for _n, _ in _epstein_wave1 {_n}])
				hop_2: len([for _n, _ in _epstein_wave2 {_n}])
				hop_3: len([for _n, _ in _epstein_wave3 {_n}])
				hop_4: len([for _n, _ in _epstein_wave4 {_n}])
				unreachable: len([
					for _ename, _ in entities
					if _epstein_seen4[_ename] == _|_ {_ename},
				])
				total_reachable: len([
					for _ename, _ in entities
					if _epstein_seen4[_ename] != _|_ {_ename},
				])
			}
		}
	}

	// Sole connectors — critical bridge entities
	sole_connectors: {
		description: "Entities that are the ONLY bridge between two cluster worlds. Removing them disconnects those communities."
		pairs: _soleConnectorPairs
		count: len(_soleConnectorPairs)

		// Which entities are sole connectors and for how many pairs?
		by_entity: [
			for _ename, _data in _soleConnectorByEntity {
				entity: _ename
				name:   entities[_ename].name
				cluster: entities[_ename].cluster
				sole_bridge_pairs: [for _p, _ in _data.pairs {_p}]
				pair_count: len([for _p, _ in _data.pairs {_p}])
			},
		]
	}

	// Exposure cascades — pre-computed key scenarios
	exposure_cascades: {
		maxwell: {
			target:   "maxwell"
			wave_0:   [for _n, _ in _maxwell_w0 {_n}]
			wave_1:   [for _n, _ in _maxwell_w1 {_n}]
			wave_2:   [for _n, _ in _maxwell_w2 {_n}]
			total_exposed: len([for _n, _ in _maxwell_w1 {_n}]) + len([for _n, _ in _maxwell_w2 {_n}])
		}
		jes_staley: {
			target:   "jes_staley"
			wave_0:   [for _n, _ in _staley_w0 {_n}]
			wave_1:   [for _n, _ in _staley_w1 {_n}]
			wave_2:   [for _n, _ in _staley_w2 {_n}]
			total_exposed: len([for _n, _ in _staley_w1 {_n}]) + len([for _n, _ in _staley_w2 {_n}])
		}
	}

	// Evidence integrity — which entities depend on each document?
	evidence_chains: {
		for _doc, _deps in _docDependents {
			(_doc): {
				dependent_entities: [for _e, _ in _deps {_e}]
				count: len([for _e, _ in _deps {_e}])
			}
		}
	}
}
