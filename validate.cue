// Validation patterns — adapted from quicue.ca patterns/validation.cue
// and patterns/graph.cue.
//
// These patterns surface investigative gaps as structured data.
// Run: cue export -e report ./...
//
// Every validation accumulates issues into lists — soft validation
// that reports ALL gaps rather than stopping at the first error.
package creeps

import "list"

// ═══════════════════════════════════════════════════════════════
// ENTITY NAME REGISTRY
// Build the set of all defined entity IDs for reference checking.
// ═══════════════════════════════════════════════════════════════

_entityNames: {for name, _ in entities {(name): true}}
_documentIDs: {for id, _ in documents {(id): true}}

// ═══════════════════════════════════════════════════════════════
// 1. DANGLING CONNECTIONS
// Entity A lists entity B in connections, but B is not defined.
// These are the primary investigative leads.
// ═══════════════════════════════════════════════════════════════

_danglingConnectionsNested: [
	for ename, e in entities {
		[for conn, _ in e.connections if _entityNames[conn] == _|_ {
			entity:    ename
			dangling:  conn
			entity_name: e.name
			message:   "'" + e.name + "' (" + ename + ") references undefined entity '" + conn + "'"
		}]
	},
]
_danglingConnections: list.FlattenN(_danglingConnectionsNested, 1)

// Unique set of undefined entities (deduplicated)
_undefinedEntities: {for item in _danglingConnections {(item.dangling): true}}
_undefinedEntityList: [for name, _ in _undefinedEntities {name}]

// ═══════════════════════════════════════════════════════════════
// 2. MISSING EVIDENCE
// Entities with no evidence citations at all.
// ═══════════════════════════════════════════════════════════════

_missingEvidence: [
	for ename, e in entities
	if len([for k, _ in e.evidence {k}]) == 0 {
		entity:      ename
		entity_name: e.name
		cluster:     e.cluster
		message:     "'" + e.name + "' has no evidence citations — claims are unverified"
	},
]

// ═══════════════════════════════════════════════════════════════
// 3. DANGLING EVIDENCE REFERENCES
// Entity cites a document ID not in the document registry.
// ═══════════════════════════════════════════════════════════════

_danglingEvidenceNested: [
	for ename, e in entities {
		[for doc, _ in e.evidence if _documentIDs[doc] == _|_ {
			entity:    ename
			doc_id:    doc
			message:   "'" + e.name + "' cites unknown document '" + doc + "'"
		}]
	},
]
_danglingEvidence: list.FlattenN(_danglingEvidenceNested, 1)

// ═══════════════════════════════════════════════════════════════
// 4. DANGLING FLOW REFERENCES
// Financial flows referencing undefined entities.
// ═══════════════════════════════════════════════════════════════

_danglingFlowSources: [
	for fname, f in flows
	if _entityNames[f.source] == _|_ {
		flow:    fname
		entity:  f.source
		role:    "source"
		message: "Flow '" + fname + "' source '" + f.source + "' is not a defined entity"
	},
]

_danglingFlowDests: [
	for fname, f in flows
	if _entityNames[f.destination] == _|_ {
		flow:    fname
		entity:  f.destination
		role:    "destination"
		message: "Flow '" + fname + "' destination '" + f.destination + "' is not a defined entity"
	},
]

_danglingFlowRefs: list.Concat([_danglingFlowSources, _danglingFlowDests])

// ═══════════════════════════════════════════════════════════════
// 5. DANGLING DOCUMENT MENTIONS
// Documents mention entities that aren't defined.
// ═══════════════════════════════════════════════════════════════

_danglingDocMentionsNested: [
	for docid, doc in documents {
		[for mention, _ in doc.mentions if _entityNames[mention] == _|_ {
			doc_id:  docid
			entity:  mention
			message: "Document '" + docid + "' mentions undefined entity '" + mention + "'"
		}]
	},
]
_danglingDocMentions: list.FlattenN(_danglingDocMentionsNested, 1)

// ═══════════════════════════════════════════════════════════════
// 6. ORPHAN ENTITIES
// Entities that nobody else connects to (zero inbound connections).
// ═══════════════════════════════════════════════════════════════

_hasInbound: {
	for _, e in entities {
		for conn, _ in e.connections if _entityNames[conn] != _|_ {
			(conn): true
		}
	}
}

_orphanEntities: [
	for ename, e in entities
	if _hasInbound[ename] == _|_ {
		entity:      ename
		entity_name: e.name
		cluster:     e.cluster
		message:     "'" + e.name + "' has no inbound connections — isolated node"
	},
]

// ═══════════════════════════════════════════════════════════════
// 7. UNIDIRECTIONAL CONNECTIONS
// A connects to B, but B doesn't connect back to A.
// Not necessarily wrong — but worth flagging.
// ═══════════════════════════════════════════════════════════════

_unidirectionalNested: [
	for ename, e in entities {
		[for conn, _ in e.connections
			if _entityNames[conn] != _|_
			if entities[conn].connections[ename] == _|_ {
			from:    ename
			to:      conn
			message: "'" + e.name + "' → '" + entities[conn].name + "' is one-way (no reciprocal connection)"
		}]
	},
]
_unidirectional: list.FlattenN(_unidirectionalNested, 1)

// ═══════════════════════════════════════════════════════════════
// 8. TYPE CONSISTENCY
// FinancialEnabler entities should have financial flows.
// LegalProtection entities should have legal connections.
// ═══════════════════════════════════════════════════════════════

// Entities tagged FinancialEnabler but with no flows
_financialEnablerIDs: {
	for ename, e in entities
	if e["@type"]["FinancialEnabler"] != _|_ {(ename): true}
}

_flowParticipants: {
	for _, f in flows {
		if _entityNames[f.source] != _|_ {(f.source): true}
		if _entityNames[f.destination] != _|_ {(f.destination): true}
	}
}

_financialWithoutFlows: [
	for ename, _ in _financialEnablerIDs
	if _flowParticipants[ename] == _|_ {
		entity:      ename
		entity_name: entities[ename].name
		message:     "'" + entities[ename].name + "' tagged FinancialEnabler but has no documented financial flows"
	},
]

// ═══════════════════════════════════════════════════════════════
// 9. CLUSTER ISOLATION
// Entities in a cluster with no connections to other cluster members.
// ═══════════════════════════════════════════════════════════════

_clusterMembers: {
	for ename, e in entities {
		(e.cluster): (ename): true
	}
}

// Build per-entity cluster connection count
_clusterConnCounts: {
	for ename, e in entities {
		(ename): len([
			for conn, _ in e.connections
			if _entityNames[conn] != _|_
			if entities[conn].cluster == e.cluster {conn},
		])
	}
}

_clusterIsolated: [
	for ename, e in entities
	if _clusterConnCounts[ename] == 0
	if len([for m, _ in _clusterMembers[e.cluster] {m}]) > 1 {
		entity:      ename
		entity_name: e.name
		cluster:     e.cluster
		message:     "'" + e.name + "' is in cluster '" + e.cluster + "' but has no connections to other members"
	},
]

// ═══════════════════════════════════════════════════════════════
// 10. FLOW EVIDENCE GAPS
// Financial flows with no evidence citations.
// ═══════════════════════════════════════════════════════════════

_flowsWithoutEvidence: [
	for fname, f in flows
	if len([for k, _ in f.evidence {k}]) == 0 {
		flow:    fname
		source:  f.source
		dest:    f.destination
		amount:  f.amount
		message: "Flow '" + fname + "' (" + f.source + " → " + f.destination + ", " + f.amount + ") has no evidence"
	},
]

// ═══════════════════════════════════════════════════════════════
// COVERAGE METRICS
// ═══════════════════════════════════════════════════════════════

_totalEntities:      len([for k, _ in entities {k}])
_entitiesWithEvidence: len([for _, e in entities if len([for k, _ in e.evidence {k}]) > 0 {1}])
_totalFlows:         len([for k, _ in flows {k}])
_flowsWithEvidence:  len([for _, f in flows if len([for k, _ in f.evidence {k}]) > 0 {1}])
_totalDocuments:     len([for k, _ in documents {k}])

// Per-cluster entity counts
_clusterCounts: {
	for cname, members in _clusterMembers {
		(cname): len([for m, _ in members {m}])
	}
}

// ═══════════════════════════════════════════════════════════════
// REPORT — the main export expression
// cue export -e report ./...
// ═══════════════════════════════════════════════════════════════

report: {
	summary: {
		total_entities:            _totalEntities
		entities_with_evidence:    _entitiesWithEvidence
		evidence_coverage_pct:     _entitiesWithEvidence * 100 / _totalEntities
		total_documents:           _totalDocuments
		total_flows:               _totalFlows
		flows_with_evidence:       _flowsWithEvidence
		undefined_entities_count:  len(_undefinedEntityList)
		dangling_connections:      len(_danglingConnections)
		orphan_entities:           len(_orphanEntities)
		unidirectional_connections: len(_unidirectional)
	}

	// ── INVESTIGATIVE LEADS ──

	dangling_connections: {
		description: "Entities referenced in connections but never defined — WHO ARE THESE PEOPLE?"
		count:       len(_danglingConnections)
		undefined_entities: _undefinedEntityList
		details: _danglingConnections
	}

	missing_evidence: {
		description: "Entities with zero evidence citations — claims are unverified"
		count:       len(_missingEvidence)
		details:     _missingEvidence
	}

	dangling_evidence: {
		description: "Entity evidence fields reference document IDs not in the registry"
		count:       len(_danglingEvidence)
		details:     _danglingEvidence
	}

	dangling_flow_refs: {
		description: "Financial flows reference entities that don't exist"
		count:       len(_danglingFlowRefs)
		details:     _danglingFlowRefs
	}

	dangling_doc_mentions: {
		description: "Documents mention entities not in the entity registry"
		count:       len(_danglingDocMentions)
		details:     _danglingDocMentions
	}

	orphan_entities: {
		description: "Entities with no inbound connections — nobody points to them"
		count:       len(_orphanEntities)
		details:     _orphanEntities
	}

	unidirectional: {
		description: "One-way connections — A→B but B does not list A"
		count:       len(_unidirectional)
		details:     _unidirectional
	}

	type_inconsistencies: {
		description: "Entities whose @type claims are unsupported by data"
		financial_enablers_without_flows: {
			count:   len(_financialWithoutFlows)
			details: _financialWithoutFlows
		}
	}

	cluster_isolation: {
		description: "Entities in a cluster but not connected to any cluster peer"
		count:       len(_clusterIsolated)
		details:     _clusterIsolated
	}

	flow_evidence_gaps: {
		description: "Financial flows with no evidence citations"
		count:       len(_flowsWithoutEvidence)
		details:     _flowsWithoutEvidence
	}

	// ── COVERAGE ──

	coverage: {
		entities: {
			total:          _totalEntities
			with_evidence:  _entitiesWithEvidence
			without_evidence: _totalEntities - _entitiesWithEvidence
			percentage:     _entitiesWithEvidence * 100 / _totalEntities
		}
		flows: {
			total:         _totalFlows
			with_evidence: _flowsWithEvidence
			percentage:    _flowsWithEvidence * 100 / _totalFlows
		}
		clusters: _clusterCounts
	}
}
