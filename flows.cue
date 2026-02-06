// Financial flows — documented money movement.
//
// Every flow.source and flow.destination MUST resolve to a
// defined entity. Missing resolution = financial gap.
//
// Source: DugganUSA Sankey diagram + entity descriptions.
package creeps

flows: {

	// ═══════════════════════════════════════════════════════════
	// DOCUMENTED FLOWS (from visualization Sankey diagram)
	// ═══════════════════════════════════════════════════════════

	black_to_epstein: {
		source:      "leon_black"
		destination: "epstein"
		amount:      "$158M+"
		flow_type:   "payment"
		period:      "2000-2015"
		evidence: {
			"DB-SDNY-0002962": true
			"EFTA02730996":    true
		}
		notes: "$158M+ over ~15 years. For what services? Tax advice? Financial management? Something else?"
	}

	thiel_to_valar: {
		source:      "peter_thiel"
		destination: "valar_ventures"
		amount:      "$4.45M+"
		flow_type:   "investment"
		evidence: {
			"DB-SDNY-0004924": true
		}
		notes: "Thiel's investment into Valar. Was Epstein a co-investor or intermediary?"
	}

	cohen_to_honeycomb: {
		source:      "steve_cohen"
		destination: "honeycomb"
		amount:      "$10M"
		flow_type:   "investment"
		evidence: {
			"DB-SDNY-0008151": true
		}
		notes: "What was Honeycomb's purpose? Where did the $10M go next?"
	}

	// ═══════════════════════════════════════════════════════════
	// PARTIALLY DOCUMENTED (gaps in source or destination)
	// ═══════════════════════════════════════════════════════════

	valar_total_investment: {
		source:      "valar_ventures"
		destination: "epstein" // Assumption — needs verification
		amount:      "$40M"
		flow_type:   "investment"
		evidence: {}
		notes: "Total Valar investment was $40M. Thiel put in $4.45M. Who provided the other ~$35.55M?"
	}

	// ═══════════════════════════════════════════════════════════
	// KNOWN GAPS — flows referenced but not fully documented
	// These use DANGLING entity references to trigger validation.
	// ═══════════════════════════════════════════════════════════

	maxwell_ubs_accounts: {
		source:      "maxwell"
		destination: "ubs" // ── DANGLING: ubs not defined as entity
		amount:      "unknown"
		flow_type:   "transfer"
		evidence: {}
		notes: "Maxwell UBS/USAA accounts referenced in Sankey diagram. Amounts unknown."
	}

	maxwell_wells_fargo: {
		source:      "maxwell"
		destination: "wells_fargo" // ── DANGLING
		amount:      "unknown"
		flow_type:   "transfer"
		evidence: {}
		notes: "Wells Fargo accounts in financial flows visualization."
	}

	epstein_deutsche_bank: {
		source:      "epstein"
		destination: "deutsche_bank" // ── DANGLING
		amount:      "unknown"
		flow_type:   "transfer"
		evidence: {}
		notes: "Deutsche Bank relationship — subject of major investigation and fine."
	}

	epstein_jp_morgan: {
		source:      "epstein"
		destination: "jp_morgan" // ── DANGLING
		amount:      "unknown"
		flow_type:   "transfer"
		evidence: {}
		notes: "JP Morgan relationship — $290M settlement with USVI. Not documented in entity registry."
	}
}
