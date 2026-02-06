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
// STRUCTURAL ANALYSIS — derived from pure graph topology
// All computed as side effects of CUE unification over _adjacency.
// ═══════════════════════════════════════════════════════════════

// ── CLUSTERING COEFFICIENT ──────────────────────────────────
// For each entity: what fraction of neighbor pairs are also
// connected to each other? High = tightly-knit neighborhood.
// Low = structural hole (entity bridges otherwise disconnected
// groups — the Burt structural holes insight).

_neighborConnectedPairs: {
	for _e, _ in entities {
		if _adjacency[_e] != _|_ {
			(_e): len([
				for _a, _ in _adjacency[_e]
				for _b, _ in _adjacency[_e]
				if (_a < _b)
				if _adjacency[_a] != _|_
				if _adjacency[_a][_b] != _|_ {1},
			])
		}
		if _adjacency[_e] == _|_ {
			(_e): 0
		}
	}
}

_neighborTotalPairs: {
	for _e, _ in entities {
		if _adjacency[_e] != _|_ {
			(_e): len([
				for _a, _ in _adjacency[_e]
				for _b, _ in _adjacency[_e]
				if (_a < _b) {1},
			])
		}
		if _adjacency[_e] == _|_ {
			(_e): 0
		}
	}
}

_clusteringCoeff: {
	for _e, _ in entities {
		if _neighborTotalPairs[_e] > 0 {
			(_e): _neighborConnectedPairs[_e] * 100 / _neighborTotalPairs[_e]
		}
		if _neighborTotalPairs[_e] == 0 {
			(_e): 0
		}
	}
}

// ── POWER ASYMMETRY ─────────────────────────────────────────
// (inbound - outbound) / total, scaled -100..+100.
// +100 = pure authority (everyone connects TO you)
// -100 = pure claimer (you connect to everyone, nobody reciprocates)

_powerAsymmetry: {
	for _e, _ in entities {
		if (_totalValidConns[_e] + _inboundCounts[_e]) > 0 {
			(_e): (_inboundCounts[_e] - _totalValidConns[_e]) * 100 / (_totalValidConns[_e] + _inboundCounts[_e])
		}
		if (_totalValidConns[_e] + _inboundCounts[_e]) == 0 {
			(_e): 0
		}
	}
}

// ── CLUSTER AFFINITY ────────────────────────────────────────
// % of connections within declared cluster. Low affinity +
// high connections to another cluster = possible misclassification.

_clusterAffinity: {
	for _e, _ in entities {
		if _totalValidConns[_e] > 0 {
			(_e): _clusterConnCounts[_e] * 100 / _totalValidConns[_e]
		}
		if _totalValidConns[_e] == 0 {
			(_e): 0
		}
	}
}

// ── INTERNAL CLUSTER DENSITY ────────────────────────────────
// For each cluster: actual internal edges / possible edges.
// Low density = entities share a label but don't interact.

_clusterInternalEdges: {
	for _c, _members in _clusterMembers {
		(_c): len([
			for _a, _ in _members
			for _b, _ in _members
			if (_a < _b)
			if _adjacency[_a] != _|_
			if _adjacency[_a][_b] != _|_ {1},
		])
	}
}

_clusterMemberCount: {
	for _c, _members in _clusterMembers {
		(_c): len([for _m, _ in _members {_m}])
	}
}

// ── CLUSTER PAIR BRIDGE COUNTS ──────────────────────────────
// Extends sole connectors: how many entities bridge each pair?
// 1 = SPOF, 2 = fragile, 3+ = healthy redundancy.

_clusterPairBridgeCounts: {
	for _pair, _members in _clusterPairBridges {
		(_pair): {
			count: len([for _m, _ in _members {_m}])
			entities: [for _m, _ in _members {_m}]
		}
	}
}

// ── CASCADING ORPHANIZATION ─────────────────────────────────
// If entity X is removed, which entities lose ALL inbound?
// Those entities' only lifeline into the graph was through X.

_orphansIfRemoved: {
	for _target, _ in entities {
		(_target): [
			for _other, _ in entities
			if _other != _target
			if _inboundFrom[_other] != _|_
			if _inboundFrom[_other][_target] != _|_
			if len([for _src, _ in _inboundFrom[_other] {_src}]) == 1 {_other},
		]
	}
}

// ── MULTI-WAVE CASCADE FAILURE ────────────────────────────────
// Extends cascading orphanization: after wave 1 orphans are also
// gone, who NOW loses all inbound? Adapted from quicue.ca
// #CascadeAnalysis (resilience.cue) — domino failure simulation.
//
// Wave 0: entity X removed
// Wave 1: entities whose only inbound was X (immediate orphans)
// Wave 2: entities whose remaining inbound were all wave 1 orphans

// Set of all removed entities after wave 1 (target + wave 1 orphans)
_removedAfterWave1: {
	for _target, _ in entities {
		(_target): {
			(_target): true
			for _o in _orphansIfRemoved[_target] {
				(_o): true
			}
		}
	}
}

// Wave 2: among survivors, who now has zero inbound?
_wave2Orphans: {
	for _target, _ in entities {
		(_target): [
			for _other, _ in entities
			if _removedAfterWave1[_target][_other] == _|_
			if _inboundFrom[_other] != _|_
			if len([
				for _src, _ in _inboundFrom[_other]
				if _removedAfterWave1[_target][_src] == _|_ {_src},
			]) == 0 {_other},
		]
	}
}

// Total cascade impact: wave 1 + wave 2 orphans
_cascadeImpact: {
	for _target, _ in entities {
		(_target): len(_orphansIfRemoved[_target]) + len(_wave2Orphans[_target])
	}
}

// ── BOTTLENECK RANKING ────────────────────────────────────────
// Composite criticality score per entity. Adapted from quicue.ca
// #BottleneckAnalysis (resilience.cue) — fan-in ranking + tiers.
//
// Score = inbound connections + (sole bridge pairs × 3) + (cascade impact × 2)
// Weights: sole bridges are severe (disconnects entire cluster pairs),
// cascade impact matters but inbound is the base signal.

_soleConnPairCount: {
	for _ename, _ in entities {
		if _soleConnectorByEntity[_ename] != _|_ {
			(_ename): len([for _p, _ in _soleConnectorByEntity[_ename].pairs {_p}])
		}
		if _soleConnectorByEntity[_ename] == _|_ {
			(_ename): 0
		}
	}
}

_bottleneckScore: {
	for _ename, _ in entities {
		(_ename): _inboundCounts[_ename] + (_soleConnPairCount[_ename] * 3) + (_cascadeImpact[_ename] * 2)
	}
}

// ── NETWORK RESILIENCE ────────────────────────────────────────
// Aggregate fragility metrics. Adapted from quicue.ca
// #ResilienceScore (resilience.cue) — composite score 0-100.
//
// Penalties for: high SPOF count, concentrated bottlenecks,
// high max cascade impact.

_totalEntities:       len([for _e, _ in entities {_e}])
_spofPairs:           len(_soleConnectorPairs)
_totalClusterPairs:   len([for _p, _ in _clusterPairBridgeCounts {_p}])
_entitiesWithCascade: len([for _e, _ in entities if _cascadeImpact[_e] > 0 {_e}])

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

	// Structural analysis — pure topology derivations
	structural: {
		// Per-cluster internal edge density
		cluster_density: {
			for _c, _ in _clusterMembers {
				(_c): {
					members:        _clusterMemberCount[_c]
					internal_edges: _clusterInternalEdges[_c]
					possible_edges: _clusterMemberCount[_c] * (_clusterMemberCount[_c] - 1) / 2
					if (_clusterMemberCount[_c] * (_clusterMemberCount[_c] - 1) / 2) > 0 {
						density_pct: _clusterInternalEdges[_c] * 100 / (_clusterMemberCount[_c] * (_clusterMemberCount[_c] - 1) / 2)
					}
					if (_clusterMemberCount[_c] * (_clusterMemberCount[_c] - 1) / 2) == 0 {
						density_pct: 0
					}
				}
			}
		}

		// Cluster pair bridge counts (extends sole connectors)
		cluster_pair_bridges: {
			for _pair, _data in _clusterPairBridgeCounts {
				(_pair): {
					bridge_count:    _data.count
					bridge_entities: _data.entities
					is_spof:         _data.count == 1
					is_fragile:      _data.count == 2
				}
			}
		}

		// Cascading orphans — entities that become orphans if a key entity is removed
		cascading_orphans: [
			for _target, _ in entities
			if len(_orphansIfRemoved[_target]) > 0 {
				entity:        _target
				name:          entities[_target].name
				cluster:       entities[_target].cluster
				would_orphan:  _orphansIfRemoved[_target]
				orphan_count:  len(_orphansIfRemoved[_target])
			},
		]

		// Low-affinity entities — cluster assignment may not match behavior
		low_affinity: [
			for _e, _ in entities
			if _totalValidConns[_e] >= 3
			if _clusterAffinity[_e] < 30 {
				entity:           _e
				name:             entities[_e].name
				declared_cluster: entities[_e].cluster
				affinity_pct:     _clusterAffinity[_e]
				in_cluster:       _clusterConnCounts[_e]
				total_conns:      _totalValidConns[_e]
			},
		]

		// Bottleneck ranking — entities ranked by composite criticality
		// Score = inbound + (sole bridge pairs × 3) + (cascade impact × 2)
		bottleneck: [
			for _e, _ in entities
			if _bottleneckScore[_e] > 0 {
				entity:           _e
				name:             entities[_e].name
				cluster:          entities[_e].cluster
				score:            _bottleneckScore[_e]
				inbound:          _inboundCounts[_e]
				sole_bridge:      _soleConnPairCount[_e]
				cascade_wave1:    len(_orphansIfRemoved[_e])
				cascade_wave2:    len(_wave2Orphans[_e])
				cascade_total:    _cascadeImpact[_e]
			},
		]

		// Network resilience summary
		resilience: {
			total_entities:       _totalEntities
			spof_pairs:           _spofPairs
			total_cluster_pairs:  _totalClusterPairs
			spof_pct:             _spofPairs * 100 / _totalClusterPairs
			entities_with_cascade: _entitiesWithCascade
		}
	}
}
