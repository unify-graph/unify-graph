// CourtListener case IDs for legal proceedings.
// Auto-generated from CourtListener API v4.
package creeps

documents: {
	brown_v_maxwell: {
		doc_id:      "brown_v_maxwell"
		description: "Brown v. Maxwell; Dershowitz v. Giuffre — unsealed Epstein documents. Foundation for EFTA release."
		doc_type:    "court_filing"
		source:      "CourtListener cluster 4636340"
		mentions: {maxwell: true, dershowitz: true, virginia_giuffre: true, epstein: true}
	}
	giuffre_v_maxwell_sdny: {
		doc_id:      "giuffre_v_maxwell_sdny"
		description: "Giuffre v. Maxwell (15 Civ. 7433 SDNY) — civil case that produced most EFTA documents."
		doc_type:    "court_filing"
		source:      "CourtListener cluster 7322971"
		mentions: {maxwell: true, virginia_giuffre: true, epstein: true, sigrid_mccawley: true}
	}
	giuffre_v_maxwell_unsealing: {
		doc_id:      "giuffre_v_maxwell_unsealing"
		description: "Giuffre v. Maxwell (unsealing order) — released documents to public."
		doc_type:    "court_filing"
		source:      "CourtListener cluster 7331533"
		mentions: {maxwell: true, virginia_giuffre: true, epstein: true}
	}
	us_v_maxwell: {
		doc_id:      "us_v_maxwell"
		description: "United States v. Maxwell — criminal conviction appeal. Affirmed 20-year sentence."
		doc_type:    "court_filing"
		source:      "CourtListener cluster 10119519"
		mentions: {maxwell: true, epstein: true, virginia_giuffre: true}
	}
	doe_v_epstein: {
		doc_id:      "doe_v_epstein"
		description: "Jane Doe No. 5 v. Epstein — early victim civil case challenging NPA deal."
		doc_type:    "court_filing"
		source:      "CourtListener cluster 2299116"
		mentions: {epstein: true, acosta: true, brad_edwards: true}
	}
	edwards_v_epstein: {
		doc_id:      "edwards_v_epstein"
		description: "Bradley J. Edwards v. Jeffrey Epstein — victims' attorney case."
		doc_type:    "court_filing"
		source:      "CourtListener cluster 3154033"
		mentions: {brad_edwards: true, epstein: true}
	}
}

entities: {
	acosta: external_ids: courtlistener: "2299116"
	brad_edwards: external_ids: courtlistener: "2299116"
	dershowitz: external_ids: courtlistener: "4636340"
	epstein: external_ids: courtlistener: "4636340"
	maxwell: external_ids: courtlistener: "4636340"
	sigrid_mccawley: external_ids: courtlistener: "7322971"
	virginia_giuffre: external_ids: courtlistener: "4636340"
}
