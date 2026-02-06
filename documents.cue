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
}
