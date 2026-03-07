// Failed approaches — institutional wisdom about what not to do
package kb

import "quicue.ca/kg/core@v0"

_rejected: {
	r001: core.#Rejected & {
		id:          "REJ-001"
		approach:    "Ingest all 23K entities from Epstein Document Archive"
		date:        "2026-03-07"
		reason:      "Would dilute evidence quality, overwhelm D3 visualization, and produce a noisy graph where most entities have no connections or evidence. The graph's value is curation, not comprehensiveness."
		alternative: "Match our 132 entities against external registries. Flag high-value untracked entities (100+ doc mentions) for manual review and selective addition."
	}

	r002: core.#Rejected & {
		id:          "REJ-002"
		approach:    "Import apercue.ca as a CUE dependency of the main model"
		date:        "2026-03-07"
		reason:      "unify-graph's #Entity/#Network schema works and is battle-tested. Forcing it into apercue's #Graph/#Resource pattern would require rewriting all 132 entities, 482 connections, and 11 D3 views for no functional gain."
		alternative: "Vendor quicue.ca/kg into .kb/ only. Main model (package creeps) stays self-contained. PROV-O projection reads from .kb/, not from main model."
	}

	r003: core.#Rejected & {
		id:          "REJ-003"
		approach:    "Use Hydra for enrichment pipeline API description"
		date:        "2026-03-07"
		reason:      "Hydra describes navigable API surfaces (endpoints, operations, affordances). The enrichment pipeline consumes external APIs, it doesn't serve them. #CollectionProtocol already documents the sweep procedures."
		alternative: "Use ext.#CollectionProtocol for each sweep script. Hydra becomes relevant later if exposing unify-graph provenance data as a linked data API via api.quicue.ca."
	}
}
