// Source registry — external data sources for entity enrichment
package kb

import "quicue.ca/kg/ext@v0"

_sources: {
	src001: ext.#SourceFile & {
		id:          "SRC-001"
		file:        "https://www.justice.gov/epstein/doj-disclosures"
		format:      "json"
		origin:      "doj-efta"
		description: "DOJ Epstein Library — 3.5M pages across Data Sets 1-12, released under EFTA Transparency Act"
		extracted_at: "2026-01-30"
	}

	src002: ext.#SourceFile & {
		id:          "SRC-002"
		file:        "https://www.epsteininvestigation.org/api/download/entities"
		format:      "csv"
		origin:      "epstein-archive"
		description: "Epstein Document Archive — 207K docs, 23K entities, 3K flights. Free API, no auth."
	}

	src003: ext.#SourceFile & {
		id:          "SRC-003"
		file:        "https://epsteinexposed.com/api-docs"
		format:      "json"
		origin:      "epstein-exposed"
		description: "Epstein Exposed — 2.1M docs, 1,480 persons, 1,700 flights. Free API, no auth."
	}

	src004: ext.#SourceFile & {
		id:          "SRC-004"
		file:        "https://github.com/rhowardstone/Epstein-research-data"
		format:      "csv"
		origin:      "rhowardstone"
		description: "Structured forensic analysis of 218GB DOJ release — 524 entities, 2,096 connections, public domain v3.0"
	}

	src005: ext.#SourceFile & {
		id:          "SRC-005"
		file:        "https://oversight.house.gov/release/oversight-committee-releases-epstein-records-provided-by-the-department-of-justice/"
		format:      "json"
		origin:      "house-oversight"
		description: "House Oversight Committee — 33K pages from DOJ + 20K from Epstein Estate"
	}

	src006: ext.#SourceFile & {
		id:          "SRC-006"
		file:        "grand-jury-transcripts"
		format:      "json"
		origin:      "court-records"
		description: "Grand jury transcripts unsealed from 3 courts: SDNY 2019, Maxwell 2020, FL 2005/2007"
	}

	src007: ext.#SourceFile & {
		id:          "SRC-007"
		file:        "duggan-evidence"
		format:      "json"
		origin:      "dugganusa"
		description: "DugganUSA EFTA API — 335 citations across 132 entities. Already integrated."
	}

	src008: ext.#SourceFile & {
		id:          "SRC-008"
		file:        "opensanctions-yente"
		format:      "json"
		origin:      "opensanctions"
		description: "OpenSanctions via self-hosted yente — 64/132 matched. Needs re-sweep post-Transparency Act."
	}

	src009: ext.#SourceFile & {
		id:          "SRC-009"
		file:        "littlesis-api"
		format:      "json"
		origin:      "littlesis"
		description: "LittleSis power network DB — 81/88 people matched. Needs re-sweep."
	}

	src010: ext.#SourceFile & {
		id:          "SRC-010"
		file:        "wikidata-sparql"
		format:      "json"
		origin:      "wikidata"
		description: "Wikidata QIDs — 114/132 matched. Needs re-sweep for new QIDs post-Transparency Act."
	}

	src011: ext.#SourceFile & {
		id:          "SRC-011"
		file:        "courtlistener-api"
		format:      "json"
		origin:      "courtlistener"
		description: "CourtListener — 6 cases, 7 entity IDs. Needs re-sweep for new filings (habeas, grand jury unsealing)."
	}
}
