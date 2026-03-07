// Knowledge base index — aggregates all KB entries for W3C projections
package kb

import "quicue.ca/kg/aggregate@v0"

_index: aggregate.#KGIndex & {
	project: "unify-graph"

	decisions: _decisions
	insights:  _insights
	rejected:  _rejected
	patterns:  _patterns
}

// W3C projections — export via: cue export . -e provenance.graph
_provenance:  aggregate.#Provenance & {index:   _index}
_annotations: aggregate.#Annotations & {index:  _index}
_catalog: aggregate.#DatasetEntry & {index: _index, context: _project}
