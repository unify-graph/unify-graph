// Organizations — companies, shell companies, foundations, law firms.
// Generated from DugganUSA API discovery (24 entities).
package creeps

entities: {

	southern_trust: {
		name: "Southern Trust"
		"@type": {Organization: true, ShellCompany: true}
		cluster: "shell"
		mention_count: 1000
		role: "Shell company — trust vehicle"
		connections: {epstein: true, mark_epstein: true, wexner: true}
		evidence: {}
	}

	financial_trust: {
		name: "Financial Trust Company"
		"@type": {Organization: true, ShellCompany: true}
		cluster: "shell"
		mention_count: 1000
		role: "Trust company — financial vehicle"
		connections: {epstein: true}
		evidence: {}
		notes: "1000+ hits."
	}

	gratitude_america: {
		name: "Gratitude America"
		"@type": {Organization: true, Foundation: true}
		cluster: "shell"
		mention_count: 219
		role: "Epstein-linked foundation"
		connections: {epstein: true}
		evidence: {}
	}

	butterfly_trust: {
		name: "Butterfly Trust"
		"@type": {Organization: true, ShellCompany: true}
		cluster: "shell"
		mention_count: 158
		role: "Trust vehicle"
		connections: {epstein: true}
		evidence: {}
	}

	couq_foundation: {
		name: "COUQ Foundation"
		"@type": {Organization: true, Foundation: true}
		cluster: "shell"
		mention_count: 146
		role: "Epstein-linked foundation"
		connections: {epstein: true}
		evidence: {}
	}

	highbridge_capital: {
		name: "Highbridge Capital"
		"@type": {Organization: true, HedgeFund: true}
		cluster: "hedge_fund"
		mention_count: 140
		role: "Glenn Dubin's hedge fund"
		connections: {glenn_dubin: true, epstein: true}
		evidence: {}
	}

	terramar: {
		name: "Terramar Project"
		"@type": {Organization: true, Foundation: true}
		cluster: "core"
		mention_count: 111
		role: "Maxwell's ocean conservation nonprofit"
		connections: {maxwell: true, epstein: true}
		evidence: {}
		notes: "Dissolved after Maxwell's arrest."
	}

	harvard_university: {
		name: "Harvard University"
		"@type": {Organization: true}
		cluster: "academia"
		mention_count: 62
		role: "Academic institution — Epstein donations"
		connections: {
			larry_summers: true
			martin_nowak: true
			steven_pinker: true
			epstein: true
		}
		evidence: {}
	}

	dechert_llp: {
		name: "Dechert LLP"
		"@type": {Organization: true, LawFirm: true}
		cluster: "legal"
		mention_count: 45
		role: "Law firm — $158M investigation"
		connections: {leon_black: true, epstein: true}
		evidence: {EFTA02730996: "court_filing"}
	}

	apollo: {
		name: "Apollo Global Management"
		"@type": {Organization: true, InvestmentFirm: true}
		cluster: "financial"
		mention_count: 30
		role: "Private equity — Black & Harris"
		connections: {leon_black: true, josh_harris: true, epstein: true}
		evidence: {}
	}

	mc2_agency: {
		name: "MC2 Model Management"
		"@type": {Organization: true, ModelingAgency: true}
		cluster: "core"
		mention_count: 26
		role: "Brunel's modeling agency"
		connections: {brunel: true, epstein: true, maxwell: true}
		evidence: {}
	}

	coatue_management: {
		name: "Coatue Management"
		"@type": {Organization: true, HedgeFund: true}
		cluster: "hedge_fund"
		mention_count: 20
		role: "Laffont's hedge fund"
		connections: {philippe_laffont: true}
		evidence: {}
	}

	victoria_secret: {
		name: "Victoria's Secret"
		"@type": {Organization: true}
		cluster: "financial"
		mention_count: 38
		role: "L Brands subsidiary — Wexner connection"
		connections: {wexner: true, l_brands: true, epstein: true}
		evidence: {}
	}

	cantor_fitzgerald: {
		name: "Cantor Fitzgerald"
		"@type": {Organization: true, FinancialInstitution: true}
		cluster: "financial"
		mention_count: 15
		role: "Financial services — Lutnick CEO"
		connections: {howard_lutnick: true}
		evidence: {}
	}

	l_brands: {
		name: "L Brands"
		"@type": {Organization: true}
		cluster: "financial"
		mention_count: 14
		role: "Wexner's retail conglomerate"
		connections: {wexner: true, victoria_secret: true, epstein: true}
		evidence: {}
	}

	honeycomb: {
		name: "Honeycomb"
		"@type": {Organization: true, ShellCompany: true}
		cluster: "shell"
		mention_count: 10
		role: "Investment vehicle — Steve Cohen $10M"
		connections: {steve_cohen: true, epstein: true}
		evidence: {}
	}

	clinton_foundation: {
		name: "Clinton Foundation"
		"@type": {Organization: true, Foundation: true}
		cluster: "political"
		mention_count: 8
		role: "Clinton charitable foundation"
		connections: {bill_clinton: true, chelsea_clinton: true}
		evidence: {}
	}

	kyara: {
		name: "Kyara"
		"@type": {Organization: true, ShellCompany: true}
		cluster: "shell"
		mention_count: 7
		role: "Shell company — minimal information"
		connections: {epstein: true}
		evidence: {}
	}

	liquid_funding: {
		name: "Liquid Funding"
		"@type": {Organization: true, ShellCompany: true}
		cluster: "shell"
		mention_count: 5
		role: "Financial vehicle"
		connections: {epstein: true}
		evidence: {}
	}

	blockchain_capital: {
		name: "Blockchain Capital"
		"@type": {Organization: true, InvestmentFirm: true}
		cluster: "crypto"
		mention_count: 3
		role: "Crypto VC — Bart Stephens"
		connections: {bart_stephens: true, brock_pierce: true, epstein: true}
		evidence: {}
	}

	valar_ventures: {
		name: "Valar Ventures"
		"@type": {Organization: true, ShellCompany: true, InvestmentFirm: true}
		cluster: "shell"
		mention_count: 1
		role: "Investment vehicle — $40M, Thiel invested $4.45M+"
		connections: {peter_thiel: true, epstein: true}
		evidence: {}
	}

	palantir: {
		name: "Palantir Technologies"
		"@type": {Organization: true}
		cluster: "tech"
		mention_count: 1
		role: "Peter Thiel's data analytics company"
		connections: {peter_thiel: true}
		evidence: {}
	}

	blockstream: {
		name: "Blockstream"
		"@type": {Organization: true}
		cluster: "crypto"
		mention_count: 4
		role: "Bitcoin infrastructure company — Adam Back CEO"
		connections: {adam_back: true}
		evidence: {}
	}

	rothschild_geneva: {
		name: "Rothschild Geneva"
		"@type": {Organization: true, FinancialInstitution: true, FinancialEnabler: true}
		cluster: "financial"
		role: "Geneva banking — Epstein financial relationship"
		connections: {epstein: true}
		evidence: {"DB-SDNY-0005122": "financial_record"}
		notes: "On visualization but zero direct hits in corpus."
	}
}
