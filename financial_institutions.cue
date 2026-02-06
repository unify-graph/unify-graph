// Financial institutions — banks subpoenaed or involved.
// Generated from DugganUSA API discovery (12 entities).
package creeps

entities: {

	deutsche_bank: {
		name: "Deutsche Bank"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 1000
		role: "Primary banking relationship — fined $150M over Epstein failures"
		connections: {epstein: true, jes_staley: true}
		evidence: {}
		notes: "DB-SDNY prefix docs = Deutsche Bank subpoena production."
	}

	jp_morgan: {
		name: "JP Morgan Chase"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 1000
		role: "Banking relationship — $290M USVI settlement"
		connections: {epstein: true, jes_staley: true}
		evidence: {}
		notes: "$290M settlement with US Virgin Islands."
	}

	bank_of_america: {
		name: "Bank of America"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 936
		role: "Financial institution — Epstein accounts"
		connections: {epstein: true}
		evidence: {}
	}

	wells_fargo: {
		name: "Wells Fargo"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 808
		role: "Financial institution — Epstein/Maxwell accounts"
		connections: {epstein: true, maxwell: true}
		evidence: {}
	}

	ubs: {
		name: "UBS"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 672
		role: "Swiss bank — Epstein/Maxwell accounts"
		connections: {epstein: true, maxwell: true, rothschild_geneva: true}
		evidence: {}
	}

	credit_suisse: {
		name: "Credit Suisse"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 634
		role: "Swiss bank — Epstein accounts"
		connections: {epstein: true}
		evidence: {}
	}

	citibank: {
		name: "Citibank"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 534
		role: "Financial institution"
		connections: {epstein: true}
		evidence: {}
	}

	hsbc: {
		name: "HSBC"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 499
		role: "Financial institution"
		connections: {epstein: true}
		evidence: {}
	}

	barclays: {
		name: "Barclays"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 359
		role: "UK bank — Jes Staley connection"
		connections: {epstein: true, jes_staley: true}
		evidence: {}
	}

	bear_stearns: {
		name: "Bear Stearns"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 211
		role: "Epstein's early career employer"
		connections: {epstein: true}
		evidence: {}
		notes: "Where Epstein started on Wall Street. Collapsed 2008."
	}

	goldman_sachs: {
		name: "Goldman Sachs"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 194
		role: "Financial institution"
		connections: {epstein: true, kathryn_ruemmler: true}
		evidence: {}
	}

	morgan_stanley: {
		name: "Morgan Stanley"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "banking"
		mention_count: 164
		role: "Financial institution"
		connections: {epstein: true}
		evidence: {}
	}
}
