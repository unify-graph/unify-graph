// Collection protocols — how each external source is swept
package kb

import "quicue.ca/kg/ext@v0"

_protocols: {
	proto001: ext.#CollectionProtocol & {
		id:          "PROTO-001"
		name:        "Epstein Archive CSV bulk download"
		system:      "epsteininvestigation.org"
		method:      "api_pull"
		schedule:    "on_demand"
		description: "Download entity CSV from /api/download/entities. Match against 132 entities by name + external IDs. Emit epstein_archive_ids.cue overlay."
		authority:   3
		format:      "csv"
		endpoint:    "https://www.epsteininvestigation.org/api/download/entities"
	}

	proto002: ext.#CollectionProtocol & {
		id:          "PROTO-002"
		name:        "Epstein Exposed API pagination"
		system:      "epsteinexposed.com"
		method:      "api_pull"
		schedule:    "on_demand"
		description: "Paginate /api/v1/persons endpoint. Match against 132 entities. Emit epstein_exposed_ids.cue overlay. Rate limit: 100 req/min."
		authority:   3
		format:      "json"
		endpoint:    "https://epsteinexposed.com/api/v1/persons"
	}

	proto003: ext.#CollectionProtocol & {
		id:          "PROTO-003"
		name:        "rhowardstone GitHub CSV download"
		system:      "github.com/rhowardstone/Epstein-research-data"
		method:      "api_pull"
		schedule:    "on_demand"
		description: "Download entity registry CSV from GitHub release. Match against 132 entities. Emit rhowardstone_ids.cue overlay."
		authority:   3
		format:      "csv"
	}

	proto004: ext.#CollectionProtocol & {
		id:          "PROTO-004"
		name:        "OpenSanctions yente reconciliation"
		system:      "yente (self-hosted)"
		method:      "api_pull"
		schedule:    "on_demand"
		description: "Query self-hosted yente at localhost:8000 with entity names. Match results. Update opensanctions_ids.cue. Existing script: scripts/opensanctions_reconcile.py."
		authority:   2
		format:      "json"
		endpoint:    "http://localhost:8000/match"
		known_gaps: ["Name matching returns false positives from unrelated databases (Polish wanted lists, Brazilian PEPs)"]
	}

	proto005: ext.#CollectionProtocol & {
		id:          "PROTO-005"
		name:        "Wikidata SPARQL refresh"
		system:      "wikidata.org"
		method:      "api_pull"
		schedule:    "on_demand"
		description: "SPARQL query for QIDs by entity name. Must set User-Agent header per Wikidata policy. Update external_ids.cue."
		authority:   1
		format:      "json"
		endpoint:    "https://query.wikidata.org/sparql"
	}

	proto006: ext.#CollectionProtocol & {
		id:          "PROTO-006"
		name:        "CourtListener case search"
		system:      "courtlistener.com"
		method:      "api_pull"
		schedule:    "on_demand"
		description: "Search for new filings (habeas, grand jury unsealing orders). Token auth required (env var). Update courtlistener_ids.cue."
		authority:   1
		format:      "json"
		endpoint:    "https://www.courtlistener.com/api/rest/v4/"
	}

	proto007: ext.#CollectionProtocol & {
		id:          "PROTO-007"
		name:        "LittleSis API re-sweep"
		system:      "littlesis.org"
		method:      "api_pull"
		schedule:    "on_demand"
		description: "Query LittleSis API for entity matches. Response shape: {data: [{attributes: {name, id}}]}. Update littlesis_ids.cue."
		authority:   2
		format:      "json"
		endpoint:    "https://littlesis.org/api/entities/search"
	}
}
