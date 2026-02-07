// Vocabulary for Epstein network analysis.
//
// Adapts quicue.ca's #Resource / #Action / #TypeRegistry patterns
// to investigative network modeling. CUE unification errors on this
// vocabulary become investigative leads: dangling references are
// unknown persons, missing evidence is unverified claims, type
// inconsistencies are logical gaps in the network model.
package creeps

import "list"

// ═══════════════════════════════════════════════════════════════
// CORE TYPES
// ═══════════════════════════════════════════════════════════════

// #Cluster — network cluster assignment.
// From the DugganUSA visualization's cluster groupings.
#Cluster: "core" | "financial" | "hedge_fund" | "paypal_mafia" |
	"crypto" | "allegations" | "political" | "cabinet" |
	"legal" | "doj" | "shell" | "academia" | "media" |
	"banking" | "victim" | "intelligence" | "tech" |
	"staff" | "family" | *"unclassified"

// #EntityType — classification tags for entities (struct-as-set).
// Multiple types per entity: {"Person": true, "FinancialEnabler": true}
#EntityType: "Person" | "Organization" | "ShellCompany" | "LawFirm" |
	"FinancialInstitution" | "GovernmentOfficial" | "Politician" |
	"HedgeFund" | "InvestmentFirm" | "ModelingAgency" |
	"CoreNetwork" | "FinancialEnabler" | "LegalProtection" |
	"Allegations" | "Prosecutor" | "Scheduler" | "Recruiter" |
	"Fixer" | "Aircraft" | "Property" | "Foundation"

// #EvidenceStrength — how well-sourced is a claim?
#EvidenceStrength: "documentary" | "testimonial" | "circumstantial" |
	"financial_record" | "flight_log" | "court_filing" |
	"text_message" | "email" | "photograph" | *"unverified"

// ═══════════════════════════════════════════════════════════════
// ENTITY — the core node type (analogous to quicue.ca #Resource)
// ═══════════════════════════════════════════════════════════════

#Entity: {
	// Identity
	id:   string
	name: string

	// Classification (struct-as-set, like quicue.ca @type)
	"@type": {[#EntityType]: true}

	// Network cluster
	cluster: #Cluster

	// Connections to other entities (struct-as-set).
	// Every key here MUST resolve to a defined entity —
	// unresolvable keys are investigative gaps.
	connections: {[string]: true}

	// Optional: structured connection metadata (confidence, evidence, type).
	// Keys MUST match entries in `connections`.
	connection_details?: {[string]: #ConnectionDetail}

	// Evidence: document IDs supporting this entity's inclusion.
	// Every key MUST resolve to a defined document.
	// Value is `true` (presence only) or an #EvidenceStrength tag.
	evidence: {[string]: true | #EvidenceStrength}

	// Optional: structured metadata
	mention_count?: int & >=0
	role?:          string
	notes?:         string

	// Optional: temporal bounds
	first_appearance?: string // date or year
	last_appearance?:  string

	// Optional: external identifiers for cross-source linking
	external_ids?: {
		wikidata?:       string // e.g., "Q312959"
		opencorporates?: string
		littlesis?:      string
		opensanctions?:  string
		courtlistener?:  string
	}

	// Allow extension for entity-specific fields
	...
}

// ═══════════════════════════════════════════════════════════════
// DOCUMENT — evidence items (EFTA releases, court filings, etc.)
// ═══════════════════════════════════════════════════════════════

#Document: {
	doc_id:      string
	description: string
	doc_type:    "efta_release" | "court_filing" | "financial_record" |
		"deposition" | "fbi_report" | "text_message" | "email" |
		"flight_log" | "photograph" | "investment_record" | *"unknown"

	// Which entities this document mentions (struct-as-set)
	mentions: {[string]: true}

	// Source metadata
	source?:     string // e.g., "DOJ EFTA Release Feb 2026"
	bates_range?: string // Bates number range
	date?:       string

	// Content summary
	summary?: string

	...
}

// ═══════════════════════════════════════════════════════════════
// CONNECTION DETAIL — structured metadata for individual connections
// ═══════════════════════════════════════════════════════════════

#ConnectionDetail: {
	// How well-supported is this connection?
	confidence: "high" | "medium" | "low" | *"unassessed"

	// What kind of relationship?
	rel_type?: "financial" | "social" | "professional" | "familial" |
		"legal" | "alleged" | "employer" | "client" | "associate"

	// Evidence supporting this specific connection
	evidence?: {[string]: true | #EvidenceStrength}

	// When was this connection active?
	period?: string

	notes?: string
	...
}

// ═══════════════════════════════════════════════════════════════
// FINANCIAL FLOW — money movement between entities
// ═══════════════════════════════════════════════════════════════

#Flow: {
	id:          string
	source:      string // entity ID — MUST resolve
	destination: string // entity ID — MUST resolve
	amount:      string // "$158M+", "$4.45M", etc.
	currency:    *"USD" | string

	// Evidence supporting this flow
	evidence: {[string]: true | #EvidenceStrength}

	// Temporal
	date?:   string
	period?: string // "2000-2015", etc.

	// Classification
	flow_type: "investment" | "payment" | "donation" | "transfer" |
		"legal_fee" | "settlement" | *"unknown"

	notes?: string
	...
}

// ═══════════════════════════════════════════════════════════════
// EVENT — timeline entries
// ═══════════════════════════════════════════════════════════════

#Event: {
	id:          string
	date:        string // ISO date, "YYYY", or "YYYY-MM"
	description: string

	// Entities involved (struct-as-set) — MUST resolve
	entities: {[string]: true}

	// Evidence
	evidence: {[string]: true}

	event_type: "arrest" | "indictment" | "trial" | "plea_deal" |
		"death" | "civil_suit" | "investigation" | "political" |
		"financial" | "testimony" | *"other"

	...
}

// ═══════════════════════════════════════════════════════════════
// NETWORK — top-level container (analogous to quicue.ca examples/)
// ═══════════════════════════════════════════════════════════════

#Network: {
	entities:  {[Name=string]: #Entity & {id: Name}}
	documents: {[ID=string]: #Document & {doc_id: ID}}
	flows:     {[ID=string]: #Flow & {id: ID}}
	events:    {[ID=string]: #Event & {id: ID}}
}

// ═══════════════════════════════════════════════════════════════
// UTILITY — helpers
// ═══════════════════════════════════════════════════════════════

// Count struct keys (since len() on structs gives field count)
#CountKeys: {
	_input: {[string]: _}
	count:  len([for k, _ in _input {k}])
}

// Flatten nested lists
#Flatten: {
	_input: [...]
	result: list.FlattenN(_input, 1)
}
