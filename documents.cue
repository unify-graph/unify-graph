// Document registry — evidence items cited in the visualization.
//
// Every entity's `evidence` field references document IDs.
// Documents listed here are "known" — any entity referencing
// an unlisted document ID creates a gap in the validation report.
//
// Source: EFTA/DB-SDNY numbers from DugganUSA visualization page.
package creeps

documents: {

	// ═══════════════════════════════════════════════════════════
	// EFTA RELEASES (DOJ EFTA Feb 2026)
	// ═══════════════════════════════════════════════════════════

	"EFTA00027289": {
		description: "Steve Bannon text messages on iPhone 7"
		doc_type:    "text_message"
		mentions: {
			steve_bannon: true
			epstein:      true
		}
		source: "DOJ EFTA Release Feb 2026"
		notes:  "What was discussed in these text messages?"
	}

	"EFTA01925403": {
		description: "Reid Hoffman newsletter email to Epstein"
		doc_type:    "email"
		mentions: {
			reid_hoffman: true
			epstein:      true
		}
		source: "DOJ EFTA Release Feb 2026"
		date:   "2014-04"
		notes:  "April 2014 newsletter email. What was the context?"
	}

	"EFTA00020515": {
		description: "Howard Lutnick document"
		doc_type:    "efta_release"
		mentions: {
			howard_lutnick: true
			epstein:        true
		}
		source: "DOJ EFTA Release Feb 2026"
		notes:  "Current Commerce Secretary. What does this document contain?"
	}

	"EFTA00013505": {
		description: "David Copperfield document"
		doc_type:    "efta_release"
		mentions: {
			david_copperfield: true
			epstein:           true
		}
		source: "DOJ EFTA Release Feb 2026"
	}

	"EFTA02731039": {
		description: "Lesley Groff — scheduler role and NPA immunity"
		doc_type:    "court_filing"
		mentions: {
			lesley_groff: true
			epstein:      true
			reid_hoffman: true
		}
		source: "DOJ EFTA Release Feb 2026"
		notes:  "Documents Groff arranging meetings. NPA immunity details."
	}

	"EFTA02731082": {
		description: "Geoffrey Berman co-conspirators memo"
		doc_type:    "court_filing"
		mentions: {
			geoffrey_berman: true
			epstein:         true
		}
		source: "DOJ EFTA Release Feb 2026"
		notes:  "Co-conspirators memo — which co-conspirators were named?"
	}

	"EFTA02730996": {
		description: "Dechert LLP — Leon Black $158M investigation"
		doc_type:    "financial_record"
		mentions: {
			dechert_llp: true
			leon_black:  true
			epstein:     true
		}
		source: "DOJ EFTA Release Feb 2026"
		notes:  "$158M investigation report. What were the findings?"
	}

	// ═══════════════════════════════════════════════════════════
	// DB-SDNY (Deutsche Bank SDNY Production)
	// ═══════════════════════════════════════════════════════════

	"DB-SDNY-0002962": {
		description: "Leon Black financial records"
		doc_type:    "financial_record"
		mentions: {
			leon_black: true
			epstein:    true
		}
		source: "Deutsche Bank SDNY Production"
		notes:  "$158M+ investigation. DB-SDNY prefix = Deutsche Bank subpoena."
	}

	"DB-SDNY-0005122": {
		description: "Rothschild Geneva banking records"
		doc_type:    "financial_record"
		mentions: {
			rothschild_geneva: true
			epstein:           true
		}
		source: "Deutsche Bank SDNY Production"
	}

	"DB-SDNY-0004924": {
		description: "Peter Thiel / Valar Ventures investment records"
		doc_type:    "investment_record"
		mentions: {
			peter_thiel:    true
			valar_ventures: true
			epstein:        true
		}
		source: "Deutsche Bank SDNY Production"
		notes:  "$4.45M+ investment. Through what intermediary?"
	}

	"DB-SDNY-0008151": {
		description: "Steve Cohen / Honeycomb investment"
		doc_type:    "investment_record"
		mentions: {
			steve_cohen: true
			honeycomb:   true
			epstein:     true
		}
		source: "Deutsche Bank SDNY Production"
		notes:  "$10M investment."
	}

	"DB-SDNY-0007748": {
		description: "Philippe Laffont records"
		doc_type:    "financial_record"
		mentions: {
			philippe_laffont: true
			epstein:          true
		}
		source: "Deutsche Bank SDNY Production"
	}

	"DB-SDNY-0000478": {
		description: "Adam Back records"
		doc_type:    "financial_record"
		mentions: {
			adam_back: true
			epstein:   true
		}
		source: "Deutsche Bank SDNY Production"
		notes:  "Blockstream CEO. What financial relationship?"
	}

	"DB-SDNY-0003972": {
		description: "Joichi Ito records"
		doc_type:    "financial_record"
		mentions: {
			joichi_ito: true
			epstein:    true
		}
		source: "Deutsche Bank SDNY Production"
		notes:  "MIT Media Lab director. What were the financial flows?"
	}

	// ═══════════════════════════════════════════════════════════
	// PROPERTY AND LOCATION EVIDENCE
	// ═══════════════════════════════════════════════════════════

	"PBSO-2005-INVESTIGATION": {
		description: "Palm Beach Sheriff's Office investigation report — El Brillo Way"
		doc_type:    "court_filing"
		mentions: {
			epstein:         true
			el_brillo_way:   true
			alfredo_rodriguez: true
			juan_alessi:     true
		}
		source: "Palm Beach County SO"
		date:   "2005"
		notes:  "Initial investigation triggered by parent's complaint. Led to search warrant for 358 El Brillo Way."
	}

	"USVI-2020-COMPLAINT": {
		description: "USVI AG complaint — Little St. James Island operations"
		doc_type:    "court_filing"
		mentions: {
			epstein:          true
			little_st_james:  true
			maxwell:          true
		}
		source: "USVI Attorney General"
		date:   "2020-01"
		notes:  "AG Denise George civil suit. Documented construction of compounds, trafficking on the island, destruction of evidence."
	}

	"FLIGHT-LOGS-N908JE": {
		description: "Flight logs for N908JE (Boeing 727 'Lolita Express')"
		doc_type:    "flight_log"
		mentions: {
			lolita_express: true
			epstein:        true
			maxwell:        true
			bill_clinton:   true
			prince_andrew:  true
		}
		source: "Court exhibits — Giuffre v. Maxwell"
		notes:  "Partial flight logs. Document passenger lists for hundreds of flights. Key evidence for establishing who visited which properties."
	}

	"MCC-DOJ-2019-DEATH": {
		description: "DOJ Inspector General report on Epstein death at MCC"
		doc_type:    "court_filing"
		mentions: {
			epstein:       true
			mcc_manhattan: true
			bill_barr:     true
		}
		source: "DOJ Office of Inspector General"
		date:   "2019-08"
		notes:  "Camera malfunction, sleeping guards, removed from suicide watch. Two guards criminally charged."
	}

	"NM-AG-2019-ZORRO": {
		description: "New Mexico AG investigation into Zorro Ranch operations"
		doc_type:    "court_filing"
		mentions: {
			epstein:     true
			zorro_ranch: true
		}
		source: "New Mexico Attorney General"
		date:   "2019"
		notes:  "State-level investigation. Ranch was 8,000 acres near Stanley, NM."
	}

	"WEXNER-MANSION-DEED": {
		description: "Property transfer — 9 East 71st Street deed records"
		doc_type:    "financial_record"
		mentions: {
			east_71st: true
			wexner:    true
			epstein:   true
		}
		source: "NYC Department of Finance property records"
		date:   "2011"
		notes:  "Transfer to Maple Inc (Epstein entity). Listed as $0 transaction. Originally purchased by Wexner for $13.2M in 1989."
	}
}
