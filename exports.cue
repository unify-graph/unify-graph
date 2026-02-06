// Computed exports for visualization and analysis.
// CUE unification lazily resolves all derived metrics — the site
// receives pre-computed data, no joins needed in JS.
//
// Export:
//   cue export -e graph ./...     → D3-ready node-link format
//   cue export -e insights ./...  → derived analytical findings
package creeps

import "list"

// ═══════════════════════════════════════════════════════════════
// COMPUTATION LAYER (hidden fields, lazily resolved)
// References _entityNames, _hasInbound, _clusterConnCounts,
// _clusterMembers, _financialEnablerIDs, _flowParticipants
// from validate.cue — same package, shared scope.
// ═══════════════════════════════════════════════════════════════

// ── INBOUND CONNECTIONS ──────────────────────────────────────
// Inverts the outbound connection graph: who connects TO each entity

_inboundFrom: {
	for _ename, _e in entities
	for _conn, _ in _e.connections
	if _entityNames[_conn] != _|_ {
		(_conn): (_ename): true
	}
}

_inboundCounts: {
	for _ename, _ in entities {
		if _hasInbound[_ename] != _|_ {
			(_ename): len([for _k, _ in _inboundFrom[_ename] {_k}])
		}
		if _hasInbound[_ename] == _|_ {
			(_ename): 0
		}
	}
}

// ── MENTION COUNTS (normalize optional field) ─────────────────

_mentionCounts: {
	for _ename, _e in entities {
		if _e.mention_count != _|_ {
			(_ename): _e.mention_count
		}
		if _e.mention_count == _|_ {
			(_ename): 0
		}
	}
}

// ── CROSS-CLUSTER BRIDGES ─────────────────────────────────────
// For each entity, which foreign clusters do their connections reach?

_bridgeClusterSets: {
	for _ename, _e in entities {
		(_ename): {
			for _conn, _ in _e.connections
			if _entityNames[_conn] != _|_
			if entities[_conn].cluster != _e.cluster {
				(entities[_conn].cluster): true
			}
		}
	}
}

_bridgeCounts: {
	for _ename, _ in entities {
		(_ename): len([for _c, _ in _bridgeClusterSets[_ename] {_c}])
	}
}

// ── PER-ENTITY GAP CATEGORIES ─────────────────────────────────
// Which gap types does each entity fall into? Produces a list like
// ["missing_evidence", "orphan", "cluster_isolated"]

_gapCategories: {
	for _ename, _e in entities {
		(_ename): list.Concat([
			[for _x in ["missing_evidence"]
				if len([for _k, _ in _e.evidence {_k}]) == 0 {_x}],
			[for _x in ["orphan"]
				if _hasInbound[_ename] == _|_ {_x}],
			[for _x in ["cluster_isolated"]
				if _clusterConnCounts[_ename] == 0
				if len([for _m, _ in _clusterMembers[_e.cluster] {_m}]) > 1 {_x}],
			[for _x in ["type_inconsistent"]
				if _financialEnablerIDs[_ename] != _|_
				if _flowParticipants[_ename] == _|_ {_x}],
		])
	}
}

// ── CONNECTION QUALITY ────────────────────────────────────────

_totalValidConns: {
	for _ename, _e in entities {
		(_ename): len([for _k, _ in _e.connections if _entityNames[_k] != _|_ {_k}])
	}
}

_bidirConns: {
	for _ename, _e in entities {
		(_ename): len([
			for _conn, _ in _e.connections
			if _entityNames[_conn] != _|_
			if entities[_conn].connections[_ename] != _|_ {_conn},
		])
	}
}

_reciprocity: {
	for _ename, _ in entities {
		if _totalValidConns[_ename] > 0 {
			(_ename): _bidirConns[_ename] * 100 / _totalValidConns[_ename]
		}
		if _totalValidConns[_ename] == 0 {
			(_ename): 0
		}
	}
}

_unidirOutCount: {
	for _ename, _e in entities {
		(_ename): len([
			for _conn, _ in _e.connections
			if _entityNames[_conn] != _|_
			if entities[_conn].connections[_ename] == _|_ {_conn},
		])
	}
}

// ═══════════════════════════════════════════════════════════════
// GRAPH — D3-ready node-link format
// cue export -e graph ./...
// ═══════════════════════════════════════════════════════════════

graph: {
	"@context": "data/context.jsonld"
	nodes: [
		for _ename, _e in entities {
			id:               _ename
			name:             _e.name
			cluster:          _e.cluster
			types:            [for _t, _ in _e."@type" {_t}]
			evidence_count:   len([for _k, _ in _e.evidence {_k}])
			connection_count: len([for _k, _ in _e.connections {_k}])
			inbound_count:    _inboundCounts[_ename]
			mention_count:    _mentionCounts[_ename]
			// Gap analysis
			has_evidence:        len([for _k, _ in _e.evidence {_k}]) > 0
			is_orphan:           _hasInbound[_ename] == _|_
			is_cluster_isolated: _clusterConnCounts[_ename] == 0
			gap_categories:      _gapCategories[_ename]
			gap_count:           len(_gapCategories[_ename])
			// Connection quality
			unidirectional_out: _unidirOutCount[_ename]
			reciprocity_pct:    _reciprocity[_ename]
			// Bridge analysis
			bridge_count:    _bridgeCounts[_ename]
			bridge_clusters: [for _c, _ in _bridgeClusterSets[_ename] {_c}]
			// Structural metrics
			clustering_coeff:    _clusteringCoeff[_ename]
			power_asymmetry:     _powerAsymmetry[_ename]
			cluster_affinity:    _clusterAffinity[_ename]
			evidence_fragility:  len([for _k, _ in _e.evidence {_k}]) == 1
			bottleneck_score:    _bottleneckScore[_ename]
			cascade_impact:      _cascadeImpact[_ename]
			// Optional metadata (CUE unification includes only if present)
			if _e.role != _|_ {
				role: _e.role
			}
			if _e.notes != _|_ {
				notes: _e.notes
			}
		},
	]
	links: [
		for _ename, _e in entities
		for _conn, _ in _e.connections
		if _entityNames[_conn] != _|_ {
			source:        _ename
			target:        _conn
			bidirectional: entities[_conn].connections[_ename] != _|_
		},
	]
}

// ═══════════════════════════════════════════════════════════════
// INSIGHTS — derived analytical findings
// cue export -e insights ./...
// ═══════════════════════════════════════════════════════════════

insights: {
	// Entities bridging 3+ foreign clusters — the real connectors
	top_bridges: [
		for _ename, _ in entities
		if _bridgeCounts[_ename] >= 3 {
			entity:       _ename
			name:         entities[_ename].name
			home_cluster: entities[_ename].cluster
			bridges_to:   [for _c, _ in _bridgeClusterSets[_ename] {_c}]
			bridge_count: _bridgeCounts[_ename]
		},
	]

	// High corpus presence but zero evidence — biggest research gaps
	research_priorities: [
		for _ename, _e in entities
		if _mentionCounts[_ename] >= 100
		if len([for _k, _ in _e.evidence {_k}]) == 0 {
			entity:        _ename
			name:          _e.name
			mention_count: _mentionCounts[_ename]
			cluster:       _e.cluster
			gap_count:     len(_gapCategories[_ename])
		},
	]

	// Multi-flag entities — in 3+ gap categories simultaneously
	most_problematic: [
		for _ename, _ in entities
		if len(_gapCategories[_ename]) >= 3 {
			entity:    _ename
			name:      entities[_ename].name
			cluster:   entities[_ename].cluster
			gaps:      _gapCategories[_ename]
			gap_count: len(_gapCategories[_ename])
		},
	]

	// Cluster-to-cluster adjacency: which clusters connect to which?
	cluster_connectivity: {
		for _c1, _members in _clusterMembers {
			(_c1): {
				for _ename, _ in _members
				for _conn, _ in entities[_ename].connections
				if _entityNames[_conn] != _|_
				if entities[_conn].cluster != _c1 {
					(entities[_conn].cluster): true
				}
			}
		}
	}

	// Financial flows indexed by entity (for inspector lookups)
	flows_by_entity: {
		for _fname, _f in flows {
			(_f.source): (_fname): {
				role:      "source"
				other:     _f.destination
				amount:    _f.amount
				flow_type: _f.flow_type
			}
			(_f.destination): (_fname): {
				role:      "destination"
				other:     _f.source
				amount:    _f.amount
				flow_type: _f.flow_type
			}
		}
	}

	// Documents indexed by mentioned entity (for inspector lookups)
	docs_mentioning: {
		for _docid, _doc in documents
		for _mention, _ in _doc.mentions {
			(_mention): (_docid): true
		}
	}
}
