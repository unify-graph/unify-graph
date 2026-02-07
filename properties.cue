// Properties, locations, and aircraft.
// Generated from DugganUSA API discovery (8 entities).
package creeps

entities: {

	east_71st: {
		name: "9 East 71st Street"
		"@type": {Property: true}
		cluster: "core"
		mention_count: 308
		role: "Manhattan townhouse — primary residence"
		connections: {epstein: true, maxwell: true, wexner: true}
		evidence: {"WEXNER-MANSION-DEED": "financial_record"}
		notes: "Largest private residence in Manhattan. Originally Wexner's. Transferred to Epstein's Maple Inc for $0 in 2011."
	}

	zorro_ranch: {
		name: "Zorro Ranch"
		"@type": {Property: true}
		cluster: "core"
		mention_count: 308
		role: "New Mexico ranch — 8,000 acres"
		connections: {epstein: true, bill_gates: true}
		evidence: {"NM-AG-2019-ZORRO": "court_filing"}
		notes: "Near Stanley, NM. Visited by Bill Gates. NM AG investigated."
	}

	el_brillo_way: {
		name: "El Brillo Way"
		"@type": {Property: true}
		cluster: "core"
		mention_count: 294
		role: "Palm Beach mansion — site of initial investigation"
		connections: {epstein: true, alfredo_rodriguez: true, juan_alessi: true}
		evidence: {"PBSO-2005-INVESTIGATION": "court_filing"}
		notes: "358 El Brillo Way. Where Palm Beach PD investigation started 2005."
	}

	little_st_james: {
		name: "Little St. James Island"
		"@type": {Property: true}
		cluster: "core"
		mention_count: 255
		role: "Private Caribbean island — US Virgin Islands"
		connections: {
			epstein: true
			maxwell: true
			howard_lutnick: true
			bill_clinton: true
			prince_andrew: true
		}
		evidence: {
			"USVI-2020-COMPLAINT": true
			"FLIGHT-LOGS-N908JE":  true
		}
		notes: "Also known as 'Pedophile Island.' USVI AG civil suit documented operations."
	}

	mar_a_lago: {
		name: "Mar-a-Lago"
		"@type": {Property: true}
		cluster: "political"
		mention_count: 69
		role: "Trump's Palm Beach club — Epstein was a member"
		connections: {trump: true, epstein: true, maxwell: true}
		evidence: {}
		notes: "Epstein reportedly banned after incident with member's daughter."
	}

	dalton_school: {
		name: "Dalton School"
		"@type": {Organization: true}
		cluster: "core"
		mention_count: 42
		role: "NYC prep school — Epstein taught here 1973-75"
		connections: {epstein: true, donald_barr: true, bill_barr: true}
		evidence: {}
		notes: "Donald Barr (AG Barr's father) hired Epstein despite no degree."
	}

	lolita_express: {
		name: "Lolita Express"
		"@type": {Aircraft: true}
		cluster: "core"
		mention_count: 16
		role: "Epstein's Boeing 727 — flight logs are key evidence"
		connections: {
			epstein: true
			maxwell: true
			bill_clinton: true
			prince_andrew: true
			trump: true
		}
		evidence: {"FLIGHT-LOGS-N908JE": "flight_log"}
		notes: "N908JE. Flight logs document passengers. Entered as court exhibit in Giuffre v. Maxwell."
	}

	mcc_manhattan: {
		name: "Metropolitan Correctional Center"
		"@type": {Property: true}
		cluster: "doj"
		mention_count: 4
		role: "Federal jail where Epstein died August 10, 2019"
		connections: {epstein: true, bill_barr: true}
		evidence: {"MCC-DOJ-2019-DEATH": "documentary"}
		notes: "Cameras malfunctioned. Guards sleeping. Death ruled suicide. DOJ IG investigated."
	}
}
