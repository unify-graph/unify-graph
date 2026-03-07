// Validated discoveries from investigation data
package kb

import "quicue.ca/kg/core@v0"

_insights: {
	i001: core.#Insight & {
		id:        "INSIGHT-001"
		statement: "Nobody in the Epstein files ecosystem uses W3C provenance standards"
		evidence: [
			"rhowardstone project uses SHA hashes and convergence across DOJ + archive.org + torrent downloads",
			"DOJ Epstein Library provides no provenance metadata beyond EFTA IDs",
			"Community projects (epsteininvestigation.org, epsteinexposed.com) build ad-hoc entity registries with no derivation chains",
			"Courts are starting to require provenance for OSINT evidence but no standard tooling exists",
		]
		method:     "cross_reference"
		confidence: "high"
		discovered: "2026-03-07"
		implication: "unify-graph's PROV-O provenance layer is genuinely novel in this space. Every fact traceable to source, method, and timestamp via W3C standards."
	}

	i002: core.#Insight & {
		id:        "INSIGHT-002"
		statement: "DOJ silently removed 48K Epstein files then partially re-posted under congressional pressure"
		evidence: [
			"DOJ removed 47,635 files from publicly available database (Salon, 2026-03-04)",
			"Links to offline files return 'page not found' on justice.gov",
			"House Oversight subpoenaed AG Bondi on 2026-03-04 over missing files",
			"DOJ re-posted some files including previously withheld FBI reports about Trump allegations (NPR, 2026-03-05)",
		]
		method:     "observation"
		confidence: "high"
		discovered: "2026-03-07"
		implication: "Provenance tracking is not just academic — it is defensive. prov:wasInvalidatedBy can document removals. External source mirrors (archive.org, community projects) provide resilience."
	}

	i003: core.#Insight & {
		id:        "INSIGHT-003"
		statement: "Three free structured-data APIs now exist for Epstein files — none existed before Nov 2025"
		evidence: [
			"Epstein Document Archive: 207K docs, 23K entities, 3K flights, free API at epsteininvestigation.org/api/v1",
			"Epstein Exposed: 2.1M docs, 1,480 persons, 1,700 flights, free API at epsteinexposed.com/api-docs",
			"rhowardstone/Epstein-research-data: 524 entities, 2,096 connections, public domain CSV on GitHub",
		]
		method:     "cross_reference"
		confidence: "high"
		discovered: "2026-03-07"
		implication: "Cross-referencing our 132 entities against these registries will yield external IDs, flight counts, document counts, and connection lists without manual research."
	}
}
