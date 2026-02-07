// Cluster taxonomy — structured metadata for manual cluster assignments.
// Follows SKOS (Simple Knowledge Organization System) concepts:
//   skos:ConceptScheme, skos:prefLabel, skos:definition, skos:broader
//
// This enables:
//  - Richer legend labels and descriptions in the visualization
//  - Hierarchical grouping (broader/narrower) for domain filtering
//  - Future RDF/SKOS export for linked data interoperability
package creeps

#ClusterDef: {
	label:       string
	definition:  string
	domain:      "legal" | "financial" | "political" | "core" | "social" | "institutional"
	broader?:    #Cluster
	entity_types: [...string] // typical @type tags in this cluster
}

cluster_taxonomy: {[#Cluster]: #ClusterDef} & {
	core: {
		label:       "Core Network"
		definition:  "Epstein's inner circle — direct participants in trafficking operation"
		domain:      "core"
		entity_types: ["CoreNetwork", "Recruiter", "Scheduler", "Property", "Aircraft"]
	}
	financial: {
		label:       "Financial Network"
		definition:  "Investment firms, fund managers, and financial enablers"
		domain:      "financial"
		entity_types: ["FinancialEnabler", "InvestmentFirm"]
	}
	hedge_fund: {
		label:       "Hedge Funds"
		definition:  "Hedge fund managers and their funds"
		domain:      "financial"
		broader:     "financial"
		entity_types: ["HedgeFund"]
	}
	paypal_mafia: {
		label:       "PayPal Mafia"
		definition:  "Tech investors from PayPal ecosystem — Thiel, Hoffman"
		domain:      "financial"
		broader:     "financial"
		entity_types: ["FinancialEnabler"]
	}
	crypto: {
		label:       "Crypto Network"
		definition:  "Cryptocurrency and blockchain entrepreneurs"
		domain:      "financial"
		broader:     "financial"
		entity_types: ["InvestmentFirm"]
	}
	banking: {
		label:       "Banking"
		definition:  "Banks and financial institutions managing Epstein accounts"
		domain:      "financial"
		broader:     "financial"
		entity_types: ["FinancialInstitution"]
	}
	shell: {
		label:       "Shell Companies"
		definition:  "Trusts, foundations, and opaque corporate structures"
		domain:      "financial"
		broader:     "financial"
		entity_types: ["ShellCompany", "Foundation"]
	}
	political: {
		label:       "Political Figures"
		definition:  "Elected officials and political operatives"
		domain:      "political"
		entity_types: ["Politician"]
	}
	cabinet: {
		label:       "Cabinet / Senior Officials"
		definition:  "Cabinet-level or senior government appointments"
		domain:      "political"
		broader:     "political"
		entity_types: ["GovernmentOfficial", "Politician"]
	}
	legal: {
		label:       "Legal"
		definition:  "Attorneys representing victims, defendants, or involved parties"
		domain:      "legal"
		entity_types: ["LegalProtection"]
	}
	doj: {
		label:       "DOJ / Prosecution"
		definition:  "Department of Justice officials, prosecutors, and investigators"
		domain:      "legal"
		broader:     "legal"
		entity_types: ["Prosecutor", "GovernmentOfficial"]
	}
	allegations: {
		label:       "Allegations"
		definition:  "Individuals with public allegations or legal claims against them"
		domain:      "legal"
		entity_types: ["Allegations"]
	}
	victim: {
		label:       "Victims"
		definition:  "Identified victims and accusers"
		domain:      "core"
		entity_types: ["Victim"]
	}
	staff: {
		label:       "Staff"
		definition:  "Household employees, assistants, and operational support"
		domain:      "core"
		broader:     "core"
		entity_types: ["Witness", "Informant"]
	}
	family: {
		label:       "Family"
		definition:  "Family members of key network figures"
		domain:      "social"
		entity_types: ["Person"]
	}
	academia: {
		label:       "Academia"
		definition:  "Scientists, professors, and academic institutions receiving Epstein funding"
		domain:      "institutional"
		entity_types: ["Organization", "Person"]
	}
	media: {
		label:       "Media & Public Figures"
		definition:  "Journalists, celebrities, and public personalities"
		domain:      "social"
		entity_types: ["Person"]
	}
	tech: {
		label:       "Tech"
		definition:  "Technology company founders and executives"
		domain:      "financial"
		entity_types: ["Person"]
	}
	intelligence: {
		label:       "Intelligence"
		definition:  "Intelligence community connections (sparse — investigative gap)"
		domain:      "political"
		entity_types: ["GovernmentOfficial"]
	}
	unclassified: {
		label:       "Unclassified"
		definition:  "Entities not yet assigned to a cluster"
		domain:      "social"
		entity_types: []
	}
}
