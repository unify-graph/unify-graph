// Architecture decisions for the unify-graph investigation model
package kb

import "quicue.ca/kg/core@v0"

_decisions: {
	d001: core.#Decision & {
		id:        "ADR-001"
		title:     "PROV-O provenance backbone for enrichment pipeline"
		status:    "accepted"
		date:      "2026-03-07"
		context:   "The Epstein Files Transparency Act (Nov 2025) triggered 3.5M pages of DOJ releases. Multiple community structured-data projects emerged. Nobody tracks provenance with W3C standards — only SHA hashes and ad-hoc notes."
		decision:  "Every entity, connection, and evidence citation carries PROV-O derivation metadata. Each source is a prov:Agent, each sweep a prov:Activity, each datum a prov:Entity with prov:wasDerivedFrom."
		rationale: "Provenance is defensive (answers 'where did this come from?' when DOJ removes 48K files) and differentiating (only Epstein dataset with W3C-standard lineage). The quicue.ca/kg framework already provides #SourceFile, #CollectionProtocol, #PipelineRun, #Derivation — no new types needed."
		consequences: [
			"Every enrichment script must emit provenance metadata alongside CUE overlays",
			"New .kb/ knowledge base tracks decisions, insights, derivations, and source registry",
			"#DataSource enum in vocab.cue expands to cover new sources",
			"PROV-O projection becomes a new export target: cue export .kb/ -e provenance",
		]
		appliesTo: [{"@id": "https://github.com/unify-graph/unify-graph"}]
	}

	d002: core.#Decision & {
		id:        "ADR-002"
		title:     "Curated graph — enrich 132, do not ingest 23K"
		status:    "accepted"
		date:      "2026-03-07"
		context:   "Epstein Document Archive has 23K entities, Epstein Exposed has 1,480 persons. unify-graph has 132 curated entities with deep connection metadata, evidence citations, and cluster assignments."
		decision:  "Match our 132 entities against external registries by name + external IDs. Store matched external IDs. Pull enrichment for matches only. Flag high-value untracked entities (100+ doc mentions) for manual review."
		rationale: "The graph's value is curation and structure, not comprehensiveness. Ingesting 23K entities would dilute evidence quality and overwhelm the D3 visualization. External IDs provide lookup handles without bloating the model."
		consequences: [
			"Entity count stays ~140-150 (existing 132 + a few new high-value additions)",
			"external_ids field grows: epstein_archive, epstein_exposed, rhowardstone",
			"Deduplication is CUE unification — conflicts surface as validation errors",
		]
		appliesTo: [{"@id": "https://github.com/unify-graph/unify-graph"}]
	}

	d003: core.#Decision & {
		id:        "ADR-003"
		title:     "Flat .kb style with vendored quicue.ca/kg"
		status:    "accepted"
		date:      "2026-03-07"
		context:   "unify-graph is a standalone CUE project (module: unify.creeps). The .kb convention has two styles: multi-graph (subdirectories, each a separate package) and flat (all in root .kb/, one package)."
		decision:  "Use flat style (like grdn) with quicue.ca/kg vendored into .kb/cue.mod/pkg/. Do not add quicue.ca/kg as a dependency of the main unify.creeps module."
		rationale: "The .kb/ is a separate CUE module — it has its own cue.mod/ and validates independently. This avoids coupling the investigation model to the kg framework while still getting typed knowledge base entries."
		consequences: [
			".kb/ is a separate CUE package (package kb), validated independently from ./...",
			"kg types vendored — updates require manual copy from quicue.ca/.kb/cue.mod/pkg/",
			"Main CUE model (package creeps) and .kb (package kb) do not cross-reference",
		]
		appliesTo: [{"@id": "https://github.com/unify-graph/unify-graph"}]
	}
}
