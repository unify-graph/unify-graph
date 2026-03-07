// Reusable investigation patterns
package kb

import "quicue.ca/kg/core@v0"

_patterns: {
	p001: core.#Pattern & {
		name:     "CUE overlay enrichment"
		category: "data-integration"
		problem:  "External data sources provide entity metadata that needs to merge into the CUE model without modifying source files."
		solution: "Each enrichment source emits a separate .cue overlay file (e.g., littlesis_ids.cue, opensanctions_ids.cue) that unifies with entities defined in people.cue/organizations.cue. CUE's unification surfaces conflicts as validation errors."
		context:  "Already proven with 7 overlay files: external_ids.cue, littlesis_ids.cue, duggan_evidence.cue, temporal.cue, opensanctions_ids.cue, courtlistener_ids.cue, connection_details.cue."
		used_in: {"unify-graph": true}
	}

	p002: core.#Pattern & {
		name:     "Bulk CSV over per-record API"
		category: "data-integration"
		problem:  "External APIs have rate limits (100 req/min). Fetching 132+ entities one-by-one is slow and fragile."
		solution: "Download bulk CSV exports when available (Epstein Archive, rhowardstone). Match locally. Reserve API calls for targeted lookups and delta updates."
		context:  "Both epsteininvestigation.org and rhowardstone offer CSV bulk downloads. Epstein Exposed requires pagination but has no auth."
		used_in: {"unify-graph": true}
	}
}
