// unify-graph knowledge base manifest
//
// Declares this repo's knowledge topology: which semantic graphs
// it maintains, what types they contain, and which W3C vocabularies
// they map to. The directory structure IS the ontology.
package kb

import "quicue.ca/kg/ext@v0"

_project: ext.#Context & {
	"@id":       "https://github.com/unify-graph/unify-graph"
	name:        "unify-graph"
	description: "PROV-O-tracked investigation network model — 132 entities, W3C provenance lineage"
	module:      "unify.creeps"
	repo:        "https://github.com/unify-graph/unify-graph"
	license:     "MIT"
	status:      "active"
	cue_version: "v0.15.4"
	uses: [
		{"@id": "https://quicue.ca/pattern/struct-as-set"},
		{"@id": "https://quicue.ca/pattern/compile-time-binding"},
	]
	knows: [
		{"@id": "https://quicue.ca/concept/cue-unification"},
		{"@id": "https://quicue.ca/concept/json-ld"},
		{"@id": "https://quicue.ca/concept/dependency-graph"},
	]
}

kb: ext.#KnowledgeBase & {
	context: _project
	graphs: {
		decisions:   ext.#DecisionsGraph
		patterns:    ext.#PatternsGraph
		insights:    ext.#InsightsGraph
		rejected:    ext.#RejectedGraph
		derivations: ext.#DerivationsGraph
	}
}
