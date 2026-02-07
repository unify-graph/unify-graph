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
	// PARTIALLY DOCUMENTED (amount or purpose uncertain)
	// ═══════════════════════════════════════════════════════════

	valar_total_investment: {
		source:      "valar_ventures"
		destination: "epstein"
		amount:      "$40M"
		flow_type:   "investment"
		evidence: {}
		notes: "Total Valar investment was $40M. Thiel put in $4.45M. Who provided the other ~$35.55M? Assumption — needs verification."
	}

	wexner_to_epstein: {
		source:      "wexner"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "payment"
		period:      "1987-2007"
		evidence: {}
		notes: "Power of attorney over Wexner's finances. Transferred 9 E 71st St mansion. NYT reported Epstein managed billions. Exact flows undocumented."
	}

	wexner_mansion_transfer: {
		source:      "wexner"
		destination: "east_71st"
		amount:      "$0"
		flow_type:   "transfer"
		date:        "2011"
		evidence: {}
		notes: "Transfer of 9 E 71st Street to Epstein's Maple Inc. Listed as $0 transaction. Originally purchased by Wexner for $13.2M in 1989."
	}

	dubin_epstein_investments: {
		source:      "glenn_dubin"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "investment"
		evidence: {}
		notes: "Highbridge Capital co-founder. Investment relationship with Epstein. Dubin's wife Eva was former Miss Sweden. Amounts undocumented."
	}

	apollo_epstein_advisory: {
		source:      "apollo"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "payment"
		evidence: {}
		notes: "Apollo-affiliated payments to Epstein for financial advisory services. Black's $158M was personal; Apollo corporate fees also reported but not quantified."
	}

	// ═══════════════════════════════════════════════════════════
	// BANKING RELATIONSHIPS — accounts and transfers
	// Entities now defined in financial_institutions.cue.
	// ═══════════════════════════════════════════════════════════

	epstein_deutsche_bank: {
		source:      "epstein"
		destination: "deutsche_bank"
		amount:      "unknown"
		flow_type:   "transfer"
		period:      "2013-2018"
		evidence: {}
		notes: "Deutsche Bank maintained Epstein accounts 2013-2018 despite 2008 conviction. Fined $150M by NYDFS for compliance failures."
	}

	epstein_jp_morgan: {
		source:      "epstein"
		destination: "jp_morgan"
		amount:      "unknown"
		flow_type:   "transfer"
		period:      "1998-2013"
		evidence: {}
		notes: "JP Morgan banking relationship ~15 years. Jes Staley managed the account. $290M settlement with USVI. $75M settlement with Epstein victims."
	}

	epstein_bear_stearns: {
		source:      "bear_stearns"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "payment"
		period:      "1976-1981"
		evidence: {}
		notes: "Epstein employed at Bear Stearns 1976-1981, hired by Alan Greenberg. Left or was fired — accounts vary."
	}

	maxwell_ubs_accounts: {
		source:      "maxwell"
		destination: "ubs"
		amount:      "unknown"
		flow_type:   "transfer"
		evidence: {}
		notes: "Maxwell UBS accounts referenced in financial flows. Swiss banking — amounts unknown."
	}

	maxwell_wells_fargo: {
		source:      "maxwell"
		destination: "wells_fargo"
		amount:      "unknown"
		flow_type:   "transfer"
		evidence: {}
		notes: "Wells Fargo accounts in financial flows. US banking — amounts unknown."
	}

	// ═══════════════════════════════════════════════════════════
	// SETTLEMENTS AND FINES — legal/regulatory money flows
	// ═══════════════════════════════════════════════════════════

	deutsche_bank_fine: {
		source:      "deutsche_bank"
		destination: "epstein"
		amount:      "$150M"
		flow_type:   "settlement"
		date:        "2020-07"
		evidence: {}
		notes: "NYDFS fine for compliance failures. Not paid to Epstein — paid to regulators. Modeled as flow because it quantifies the banking relationship's regulatory impact."
	}

	jp_morgan_usvi_settlement: {
		source:      "jp_morgan"
		destination: "epstein"
		amount:      "$290M"
		flow_type:   "settlement"
		date:        "2023-06"
		evidence: {}
		notes: "Settlement with US Virgin Islands AG. JP Morgan admitted no wrongdoing. Separate $75M settlement with Epstein victims."
	}

	jp_morgan_victim_settlement: {
		source:      "jp_morgan"
		destination: "virginia_giuffre"
		amount:      "$75M"
		flow_type:   "settlement"
		date:        "2023-11"
		evidence: {}
		notes: "Class settlement with Epstein victims represented in Doe v. JP Morgan. Virginia Giuffre used as destination as lead plaintiff representative."
	}

	// ═══════════════════════════════════════════════════════════
	// FACILITATED FLOWS — intermediaries who enabled transactions
	// ═══════════════════════════════════════════════════════════

	staley_jpmorgan_facilitation: {
		source:      "jes_staley"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "payment"
		period:      "2000-2013"
		evidence: {}
		notes: "Staley managed the Epstein banking relationship at JP Morgan Private Bank. Facilitated account access, not personal payments. Visited Epstein on island. Left Barclays 2021 over the relationship."
	}

	josh_harris_epstein: {
		source:      "josh_harris"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "payment"
		evidence: {}
		notes: "Apollo co-founder. Financial relationship with Epstein alongside Leon Black. Harris was considered for WH ambassador before Epstein ties surfaced."
	}

	rothschild_epstein_banking: {
		source:      "rothschild_geneva"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "transfer"
		evidence: {"DB-SDNY-0005122": true}
		notes: "Edmond de Rothschild bank managed Epstein assets in Geneva. Swiss banking relationship documented in Deutsche Bank subpoena production."
	}

	laffont_epstein: {
		source:      "philippe_laffont"
		destination: "epstein"
		amount:      "unknown"
		flow_type:   "investment"
		evidence: {"DB-SDNY-0007748": true}
		notes: "Coatue Management founder. Financial relationship referenced in Deutsche Bank subpoena docs. Zero corpus hits but appears on DugganUSA visualization."
	}

	// ═══════════════════════════════════════════════════════════
	// KNOWN GAPS — FinancialEnabler entities with no flows
	// These are flagged by validate.cue type consistency check.
	// Research needed: michael_milken, mort_zuckerman,
	// andrew_farkas, tom_pritzker
	// ═══════════════════════════════════════════════════════════
}
