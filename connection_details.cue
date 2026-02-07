// Connection enrichment: LittleSis cross-reference + DugganUSA co-occurrence.
// LittleSis: 50 pairs (31 validated, 19 new). Co-occurrence: 23 new pairs.
package creeps

entities: {
	adriana_ross: {
		connection_details: {
			epstein: {confidence: "medium", rel_type: "professional", notes: "LittleSis (position)"}
		}
	}
	bill_clinton: {
		connections: {harvey_weinstein: true, wexner: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "Friend . LittleSis (social)", period: "2002-2005"}
			harvey_weinstein: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $2,000. LittleSis (donation)", period: "1995-1997"}
			maxwell: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
		}
	}
	bill_gates: {
		connections: {steven_pinker: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
		}
	}
	brad_edwards: {
		connections: {epstein: true}
	}
	brock_pierce: {
		connections: {maxwell: true}
	}
	brunel: {
		connections: {lolita_express: true, sigrid_mccawley: true}
		connection_details: {
			maxwell: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
		}
	}
	casey_wasserman: {
		connections: {maxwell: true}
		connection_details: {
			maxwell: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
		}
	}
	chelsea_clinton: {
		connections: {epstein: true}
		connection_details: {
			maxwell: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
		}
	}
	dalton_school: {
		connections: {wexner: true}
	}
	dershowitz: {
		connections: {lolita_express: true, obama: true, paul_cassell: true, sarah_kellen: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
			obama: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $1,000. LittleSis (donation)", period: "2004-2004"}
			paul_cassell: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
			trump: {confidence: "medium", rel_type: "financial", notes: "Attorney. LittleSis (transaction)", period: "2020"}
			virginia_giuffre: {confidence: "low", rel_type: "associate", notes: "abuser. LittleSis (generic)"}
		}
	}
	donald_barr: {
		connections: {trump: true}
	}
	ehud_barak: {
		connections: {peter_thiel: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "professional", notes: "LittleSis (professional)"}
			peter_thiel: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
		}
	}
	elon_musk: {
		connections: {jeff_bezos: true, maxwell: true, peter_thiel: true, trump: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			jeff_bezos: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			maxwell: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			peter_thiel: {confidence: "low", rel_type: "social", notes: "Frenemies. LittleSis (social)"}
			trump: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
		}
	}
	epstein: {
		connections: {brad_edwards: true, chelsea_clinton: true, jack_scarola: true, paul_cassell: true, sigrid_mccawley: true}
		connection_details: {
			adriana_ross: {confidence: "medium", rel_type: "professional", notes: "LittleSis (position)"}
			bill_clinton: {confidence: "low", rel_type: "social", notes: "Friend . LittleSis (social)", period: "2002-2005"}
			bill_gates: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			dershowitz: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
			ehud_barak: {confidence: "low", rel_type: "professional", notes: "LittleSis (professional)"}
			elon_musk: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			glenn_dubin: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			jeff_bezos: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			jes_staley: {confidence: "low", rel_type: "professional", notes: "LittleSis (professional)"}
			juan_alessi: {confidence: "medium", rel_type: "professional", notes: "houseman. LittleSis (position)"}
			larry_summers: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			lawrence_krauss: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
			leon_black: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
			maxwell: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)", period: "1991"}
			mort_zuckerman: {confidence: "low", rel_type: "social", notes: "host. LittleSis (social)"}
			peter_thiel: {confidence: "low", rel_type: "social", notes: "LittleSis (social)", period: "2014-2016"}
			richard_branson: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			sarah_ferguson: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			steve_bannon: {confidence: "low", rel_type: "social", notes: "close friend . LittleSis (social)"}
			trump: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
			wexner: {confidence: "medium", rel_type: "financial", notes: "real estate seller. $20,000,000. LittleSis (transaction)", period: "1998-2000"}
		}
	}
	glenn_dubin: {
		connections: {obama: true, virginia_giuffre: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			obama: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $29,600. LittleSis (donation)", period: "2008-2008"}
			virginia_giuffre: {confidence: "low", rel_type: "associate", notes: "accuser. LittleSis (generic)"}
		}
	}
	harvard_university: {
		connections: {wexner: true}
	}
	harvey_weinstein: {
		connections: {bill_clinton: true, obama: true, trump: true}
		connection_details: {
			bill_clinton: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $2,000. LittleSis (donation)", period: "1995-1997"}
			obama: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $5,000. LittleSis (donation)", period: "2011-2012"}
		}
	}
	jack_scarola: {
		connections: {epstein: true, maxwell: true}
	}
	james_comey: {
		connections: {trump: true}
		connection_details: {
			trump: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
		}
	}
	jeff_bezos: {
		connections: {elon_musk: true, trump: true}
		connection_details: {
			elon_musk: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			trump: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
		}
	}
	jes_staley: {
		connections: {obama: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "professional", notes: "LittleSis (professional)"}
			obama: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $2,300. LittleSis (donation)", period: "2007-2007"}
		}
	}
	juan_alessi: {
		connections: {wexner: true}
		connection_details: {
			epstein: {confidence: "medium", rel_type: "professional", notes: "houseman. LittleSis (position)"}
		}
	}
	larry_summers: {
		connections: {maxwell: true, obama: true}
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			obama: {confidence: "medium", rel_type: "professional", notes: "Led Obama response to Great Recession. LittleSis (position)"}
		}
	}
	laura_menninger: {
		connection_details: {
			maxwell: {confidence: "low", rel_type: "professional", notes: "attorney. LittleSis (professional)"}
		}
	}
	lawrence_krauss: {
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
		}
	}
	leon_black: {
		connections: {maxwell: true}
	}
	lolita_express: {
		connections: {brunel: true, dershowitz: true}
	}
	maxwell: {
		connections: {brock_pierce: true, casey_wasserman: true, elon_musk: true, jack_scarola: true, larry_summers: true, leon_black: true, melania_trump: true, sigrid_mccawley: true, steven_pinker: true}
	}
	melania_trump: {
		connections: {maxwell: true}
		connection_details: {
			maxwell: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
		}
	}
	mort_zuckerman: {
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "host. LittleSis (social)"}
		}
	}
	obama: {
		connections: {dershowitz: true, glenn_dubin: true, harvey_weinstein: true, jes_staley: true, larry_summers: true, tom_pritzker: true}
		connection_details: {
			dershowitz: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $1,000. LittleSis (donation)", period: "2004-2004"}
			glenn_dubin: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $29,600. LittleSis (donation)", period: "2008-2008"}
			harvey_weinstein: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $5,000. LittleSis (donation)", period: "2011-2012"}
			jes_staley: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $2,300. LittleSis (donation)", period: "2007-2007"}
			larry_summers: {confidence: "medium", rel_type: "professional", notes: "Led Obama response to Great Recession. LittleSis (position)"}
			tom_pritzker: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $3,550. LittleSis (donation)", period: "1999-2007"}
		}
	}
	paul_cassell: {
		connections: {dershowitz: true, epstein: true}
		connection_details: {
			dershowitz: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
		}
	}
	peter_thiel: {
		connections: {ehud_barak: true, elon_musk: true}
		connection_details: {
			ehud_barak: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
			elon_musk: {confidence: "low", rel_type: "social", notes: "Frenemies. LittleSis (social)"}
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)", period: "2014-2016"}
		}
	}
	richard_branson: {
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
		}
	}
	robert_maxwell: {
		connection_details: {
			maxwell: {confidence: "low", rel_type: "familial", notes: "daughter. LittleSis (family)"}
		}
	}
	sarah_ferguson: {
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
		}
	}
	sarah_kellen: {
		connections: {dershowitz: true, wexner: true}
	}
	sigrid_mccawley: {
		connections: {brunel: true, epstein: true, maxwell: true, wexner: true}
		connection_details: {
			maxwell: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
		}
	}
	steve_bannon: {
		connection_details: {
			epstein: {confidence: "low", rel_type: "social", notes: "close friend . LittleSis (social)"}
			trump: {confidence: "medium", rel_type: "professional", notes: "Senior Counselor and Chief Strategist. LittleSis (position)"}
		}
	}
	steven_pinker: {
		connections: {bill_gates: true, maxwell: true}
	}
	tom_pritzker: {
		connections: {obama: true}
		connection_details: {
			obama: {confidence: "medium", rel_type: "financial", notes: "Campaign Contribution. $3,550. LittleSis (donation)", period: "1999-2007"}
		}
	}
	trump: {
		connections: {donald_barr: true, elon_musk: true, harvey_weinstein: true, james_comey: true, jeff_bezos: true}
		connection_details: {
			dershowitz: {confidence: "medium", rel_type: "financial", notes: "Attorney. LittleSis (transaction)", period: "2020"}
			elon_musk: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			epstein: {confidence: "low", rel_type: "social", notes: "friend. LittleSis (social)"}
			james_comey: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
			jeff_bezos: {confidence: "low", rel_type: "associate", notes: "LittleSis (generic)"}
			maxwell: {confidence: "low", rel_type: "social", notes: "LittleSis (social)"}
			steve_bannon: {confidence: "medium", rel_type: "professional", notes: "Senior Counselor and Chief Strategist. LittleSis (position)"}
		}
	}
	virginia_giuffre: {
		connections: {glenn_dubin: true}
	}
	wexner: {
		connections: {bill_clinton: true, dalton_school: true, harvard_university: true, juan_alessi: true, sarah_kellen: true, sigrid_mccawley: true}
		connection_details: {
			epstein: {confidence: "medium", rel_type: "financial", notes: "real estate seller. $20,000,000. LittleSis (transaction)", period: "1998-2000"}
		}
	}
}
