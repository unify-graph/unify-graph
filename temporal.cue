// Temporal data — first/last appearance dates for entities.
// CUE unification merges these into the main entity definitions.
// Dates are ISO strings: "YYYY", "YYYY-MM", or "YYYY-MM-DD".
package creeps

entities: {
	// ── Core Network ─────────────────────────────────────────
	epstein: {
		first_appearance: "1973"    // hired at Dalton School
		last_appearance:  "2019-08-10" // death at MCC
	}
	maxwell: {
		first_appearance: "1991"    // met Epstein after father's death
		last_appearance:  "2021-12-29" // convicted
	}
	brunel: {
		first_appearance: "1997"    // MC2 founded
		last_appearance:  "2022-02-19" // died in French prison
	}
	sarah_kellen: {
		first_appearance: "2002"    // began working for Epstein
		last_appearance:  "2008"    // NPA deal
	}
	lesley_groff: {
		first_appearance: "1991"
		last_appearance:  "2019"
	}
	nadia_marcinkova: {
		first_appearance: "2002"
		last_appearance:  "2008"    // NPA deal
	}

	// ── Victims & Accusers ──────────────────────────────────
	virginia_giuffre: {
		first_appearance: "2000"    // recruited at Mar-a-Lago age 16
		last_appearance:  "2022-02" // settled with Prince Andrew
	}

	// ── Financial Enablers ──────────────────────────────────
	wexner: {
		first_appearance: "1985"    // met Epstein
		last_appearance:  "2019"    // cut ties after arrest
	}
	leon_black: {
		first_appearance: "1996"    // began financial relationship
		last_appearance:  "2021"    // Dechert LLP investigation, resigned Apollo
	}
	glenn_dubin: {
		first_appearance: "1994"
		last_appearance:  "2019"
	}
	jes_staley: {
		first_appearance: "2000"
		last_appearance:  "2021"    // forced out of Barclays
	}

	// ── Political Figures ───────────────────────────────────
	bill_clinton: {
		first_appearance: "2002"    // flight log entries
		last_appearance:  "2006"
	}
	prince_andrew: {
		first_appearance: "1999"    // introduced by Maxwell
		last_appearance:  "2022-02" // settled with Giuffre
	}
	trump: {
		first_appearance: "1987"    // social circles in Palm Beach
		last_appearance:  "2004"    // reportedly banned Epstein from Mar-a-Lago
	}
	acosta: {
		first_appearance: "2007"    // NPA negotiations
		last_appearance:  "2019-07" // resigned as Labor Secretary
	}

	// ── Legal ───────────────────────────────────────────────
	dershowitz: {
		first_appearance: "1997"    // legal representation
		last_appearance:  "2019"
	}
	brad_edwards: {
		first_appearance: "2008"    // CVRA suit
		last_appearance:  "2020"    // published Relentless Pursuit
	}

	// ── Staff ───────────────────────────────────────────────
	alfredo_rodriguez: {
		first_appearance: "2004"    // house manager
		last_appearance:  "2015"    // died
	}
	juan_alessi: {
		first_appearance: "1990"    // began employment
		last_appearance:  "2002"    // left employment
	}

	// ── DOJ / Prosecution ───────────────────────────────────
	bill_barr: {
		first_appearance: "2019-02" // AG confirmation
		last_appearance:  "2020-12" // resigned
	}
	geoffrey_berman: {
		first_appearance: "2019-07" // SDNY indictment
		last_appearance:  "2020-06" // fired
	}
}

// ── Key Events ──────────────────────────────────────────────
events: {
	dalton_teaching: {
		id:          "dalton_teaching"
		date:        "1973"
		description: "Epstein hired to teach at Dalton School (no college degree)"
		entities: {epstein: true, dalton_school: true, donald_barr: true}
		evidence: {}
		event_type: "other"
	}
	bear_stearns_hire: {
		id:          "bear_stearns_hire"
		date:        "1976"
		description: "Epstein joins Bear Stearns as options trader"
		entities: {epstein: true, bear_stearns: true}
		evidence: {}
		event_type: "financial"
	}
	wexner_meeting: {
		id:          "wexner_meeting"
		date:        "1985"
		description: "Epstein meets Les Wexner — begins financial management"
		entities: {epstein: true, wexner: true}
		evidence: {}
		event_type: "financial"
	}
	mansion_transfer: {
		id:          "mansion_transfer"
		date:        "2011"
		description: "71st Street mansion transferred to Epstein's Maple Inc for $0"
		entities: {epstein: true, wexner: true, east_71st: true}
		evidence: {"WEXNER-MANSION-DEED": true}
		event_type: "financial"
	}
	palm_beach_investigation: {
		id:          "palm_beach_investigation"
		date:        "2005-03"
		description: "Palm Beach PD begins investigation after parent's complaint"
		entities: {epstein: true, el_brillo_way: true}
		evidence: {"PBSO-2005-INVESTIGATION": true}
		event_type: "investigation"
	}
	npa_deal: {
		id:          "npa_deal"
		date:        "2008-06"
		description: "Non-Prosecution Agreement — Acosta grants immunity to co-conspirators"
		entities: {epstein: true, acosta: true, sarah_kellen: true, nadia_marcinkova: true}
		evidence: {}
		event_type: "plea_deal"
	}
	florida_plea: {
		id:          "florida_plea"
		date:        "2008-06-30"
		description: "Epstein pleads guilty to state prostitution charges — 13 months"
		entities: {epstein: true}
		evidence: {}
		event_type: "plea_deal"
	}
	miami_herald_expose: {
		id:          "miami_herald_expose"
		date:        "2018-11"
		description: "Julie K. Brown publishes 'Perversion of Justice' in Miami Herald"
		entities: {epstein: true, acosta: true}
		evidence: {}
		event_type: "investigation"
	}
	sdny_arrest: {
		id:          "sdny_arrest"
		date:        "2019-07-06"
		description: "Epstein arrested at Teterboro Airport by FBI — SDNY indictment"
		entities: {epstein: true, geoffrey_berman: true}
		evidence: {}
		event_type: "arrest"
	}
	acosta_resignation: {
		id:          "acosta_resignation"
		date:        "2019-07-12"
		description: "Alexander Acosta resigns as Labor Secretary"
		entities: {acosta: true}
		evidence: {}
		event_type: "political"
	}
	epstein_death: {
		id:          "epstein_death"
		date:        "2019-08-10"
		description: "Epstein found dead in MCC Manhattan cell — ruled suicide"
		entities: {epstein: true, mcc_manhattan: true, bill_barr: true}
		evidence: {"MCC-DOJ-2019-DEATH": true}
		event_type: "death"
	}
	maxwell_arrest: {
		id:          "maxwell_arrest"
		date:        "2020-07-02"
		description: "Maxwell arrested in Bradford, NH by FBI"
		entities: {maxwell: true}
		evidence: {}
		event_type: "arrest"
	}
	maxwell_conviction: {
		id:          "maxwell_conviction"
		date:        "2021-12-29"
		description: "Maxwell convicted on 5 of 6 counts including sex trafficking"
		entities: {maxwell: true, virginia_giuffre: true}
		evidence: {}
		event_type: "trial"
	}
	andrew_settlement: {
		id:          "andrew_settlement"
		date:        "2022-02-15"
		description: "Prince Andrew settles civil suit with Giuffre — reported $12M"
		entities: {prince_andrew: true, virginia_giuffre: true}
		evidence: {}
		event_type: "civil_suit"
	}
	maxwell_sentence: {
		id:          "maxwell_sentence"
		date:        "2022-06-28"
		description: "Maxwell sentenced to 20 years in federal prison"
		entities: {maxwell: true}
		evidence: {}
		event_type: "trial"
	}
	brunel_death: {
		id:          "brunel_death"
		date:        "2022-02-19"
		description: "Jean-Luc Brunel found dead in Paris prison cell — ruled suicide"
		entities: {brunel: true}
		evidence: {}
		event_type: "death"
	}
	usvi_lawsuit: {
		id:          "usvi_lawsuit"
		date:        "2020-01"
		description: "USVI AG files civil suit against Epstein estate"
		entities: {epstein: true, little_st_james: true}
		evidence: {"USVI-2020-COMPLAINT": true}
		event_type: "civil_suit"
	}
	efta_release: {
		id:          "efta_release"
		date:        "2026-01"
		description: "DOJ releases Epstein-related documents under EFTA"
		entities: {epstein: true, maxwell: true}
		evidence: {}
		event_type: "investigation"
	}
}
