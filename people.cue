// People — all Person entities across all tiers.
// Tier 1: 100+ corpus hits. Tier 2: 10-99. Tier 3: <10.
// Generated from DugganUSA API discovery (88 entities).
package creeps

entities: {

	epstein: {
		name: "Jeffrey Epstein"
		"@type": {Person: true, CoreNetwork: true}
		cluster: "core"
		mention_count: 31363
		role: "Central node — convicted sex trafficker"
		connections: {
			maxwell: true
			brunel: true
			lesley_groff: true
			sarah_kellen: true
			nadia_marcinkova: true
			leon_black: true
			wexner: true
			steve_cohen: true
			josh_harris: true
			peter_thiel: true
			reid_hoffman: true
			prince_andrew: true
			david_copperfield: true
			glenn_dubin: true
			bill_richardson: true
			george_mitchell: true
			joichi_ito: true
			howard_lutnick: true
			trump: true
			kushner: true
			bill_clinton: true
			steve_bannon: true
			dershowitz: true
			ken_starr: true
			acosta: true
			bill_barr: true
			geoffrey_berman: true
			mark_epstein: true
			bill_gates: true
			jes_staley: true
			virginia_giuffre: true
			elon_musk: true
			jeff_bezos: true
			harvey_weinstein: true
			kevin_spacey: true
			ehud_barak: true
			woody_allen: true
			naomi_campbell: true
			sergey_brin: true
			larry_summers: true
			stephen_hawking: true
			martin_nowak: true
			lawrence_krauss: true
			marvin_minsky: true
			boris_nikolic: true
			alfredo_rodriguez: true
			juan_alessi: true
			janusz_banasiak: true
			peggy_siegal: true
			southern_trust: true
			financial_trust: true
			gratitude_america: true
			butterfly_trust: true
			couq_foundation: true
			deutsche_bank: true
			jp_morgan: true
			bear_stearns: true
		}
		evidence: {EFTA02731082: true}
	}

	maxwell: {
		name: "Ghislaine Maxwell"
		"@type": {Person: true, CoreNetwork: true, Recruiter: true}
		cluster: "core"
		mention_count: 15306
		role: "Convicted co-conspirator — recruitment, grooming"
		connections: {
			epstein: true
			brunel: true
			lesley_groff: true
			sarah_kellen: true
			nadia_marcinkova: true
			prince_andrew: true
			virginia_giuffre: true
			bill_clinton: true
			trump: true
			terramar: true
			robert_maxwell: true
			emmy_taylor: true
			adriana_ross: true
			laura_menninger: true
		}
		evidence: {}
		notes: "Convicted Dec 2021. Serving 20-year sentence."
	}

	laura_menninger: {
		name: "Laura Menninger"
		"@type": {Person: true, LegalProtection: true}
		cluster: "legal"
		mention_count: 1000
		role: "Maxwell defense attorney"
		connections: {maxwell: true, sigrid_mccawley: true, dershowitz: true}
		evidence: {}
		notes: "1000+ hits. Maxwell trial defense team."
	}

	jes_staley: {
		name: "Jes Staley"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "banking"
		mention_count: 791
		role: "Former Barclays CEO — extensive Epstein relationship via JP Morgan"
		connections: {epstein: true, jp_morgan: true, barclays: true, deutsche_bank: true}
		evidence: {}
		notes: "791 hits. Left Barclays over Epstein ties. Previously at JP Morgan."
	}

	prince_andrew: {
		name: "Prince Andrew"
		"@type": {Person: true, Allegations: true}
		cluster: "allegations"
		mention_count: 441
		role: "Duke of York — civil settlement with Virginia Giuffre"
		connections: {
			epstein: true
			maxwell: true
			virginia_giuffre: true
			sarah_ferguson: true
		}
		evidence: {}
		notes: "441 hits. Settled civil case. Stripped of titles by King Charles."
	}

	lesley_groff: {
		name: "Lesley Groff"
		"@type": {Person: true, CoreNetwork: true, Scheduler: true}
		cluster: "staff"
		mention_count: 420
		role: "Scheduler — NPA immunity recipient. Arranged Reid Hoffman meetings."
		connections: {epstein: true, maxwell: true, reid_hoffman: true, sarah_kellen: true}
		evidence: {EFTA02731039: true}
	}

	sigrid_mccawley: {
		name: "Sigrid McCawley"
		"@type": {Person: true}
		cluster: "legal"
		mention_count: 363
		role: "Victim attorney — Boies Schiller Flexner"
		connections: {
			virginia_giuffre: true
			brad_edwards: true
			jack_scarola: true
			laura_menninger: true
		}
		evidence: {}
		notes: "363 hits. Lead attorney for Virginia Giuffre."
	}

	trump: {
		name: "Donald Trump"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 743
		role: "Former/current President — 743 mentions in corpus"
		connections: {
			epstein: true
			maxwell: true
			kushner: true
			howard_lutnick: true
			steve_bannon: true
			bill_barr: true
			acosta: true
			melania_trump: true
			dershowitz: true
			mar_a_lago: true
		}
		evidence: {}
		notes: "743 mentions. Mar-a-Lago connection. Appointed Acosta as Labor Secretary."
	}

	leon_black: {
		name: "Leon Black"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "financial"
		mention_count: 270
		role: "Apollo Global co-founder — $158M+ to Epstein"
		connections: {
			epstein: true
			josh_harris: true
			apollo: true
			dechert_llp: true
			michael_milken: true
		}
		evidence: {"DB-SDNY-0002962": true}
	}

	brad_edwards: {
		name: "Brad Edwards"
		"@type": {Person: true}
		cluster: "legal"
		mention_count: 255
		role: "Victim attorney — represented multiple Epstein accusers"
		connections: {
			virginia_giuffre: true
			sigrid_mccawley: true
			jack_scarola: true
			paul_cassell: true
			acosta: true
		}
		evidence: {}
		notes: "255 hits. Co-authored 'Relentless Pursuit.'"
	}

	dershowitz: {
		name: "Alan Dershowitz"
		"@type": {Person: true, LegalProtection: true, Allegations: true}
		cluster: "legal"
		mention_count: 214
		role: "Defense attorney — also named in allegations"
		connections: {
			epstein: true
			ken_starr: true
			virginia_giuffre: true
			laura_menninger: true
			trump: true
		}
		evidence: {}
		notes: "214 hits. Dual role: defense attorney AND accused by Giuffre."
	}

	mark_epstein: {
		name: "Mark Epstein"
		"@type": {Person: true}
		cluster: "family"
		mention_count: 209
		role: "Jeffrey Epstein's brother"
		connections: {epstein: true, southern_trust: true}
		evidence: {}
		notes: "209 hits. Real estate connections. Southern Trust involvement."
	}

	acosta: {
		name: "Alexander Acosta"
		"@type": {Person: true, GovernmentOfficial: true, Prosecutor: true}
		cluster: "doj"
		mention_count: 204
		role: "Former US Attorney SDFL — negotiated 2008 NPA"
		connections: {
			epstein: true
			ken_starr: true
			trump: true
			marie_villafana: true
			brad_edwards: true
		}
		evidence: {}
		notes: "204 hits. NPA deal widely criticized. Resigned as Labor Secretary 2019."
	}

	jack_scarola: {
		name: "Jack Scarola"
		"@type": {Person: true}
		cluster: "legal"
		mention_count: 157
		role: "Attorney — represented Epstein victims"
		connections: {
			virginia_giuffre: true
			brad_edwards: true
			sigrid_mccawley: true
			paul_cassell: true
		}
		evidence: {}
		notes: "157 hits."
	}

	bill_clinton: {
		name: "Bill Clinton"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 129
		role: "Former President — flight logs, foundation connections"
		connections: {
			epstein: true
			maxwell: true
			trump: true
			chelsea_clinton: true
			clinton_foundation: true
			lolita_express: true
		}
		evidence: {}
		notes: "129 hits. Flight log connections. Photos found in Epstein home."
	}

	geoffrey_berman: {
		name: "Geoffrey Berman"
		"@type": {Person: true, GovernmentOfficial: true, Prosecutor: true}
		cluster: "doj"
		mention_count: 115
		role: "Former US Attorney SDNY — co-conspirators memo"
		connections: {epstein: true, bill_barr: true, robert_mueller: true}
		evidence: {EFTA02731082: true}
		notes: "Barr attempted to fire him during Epstein investigation."
	}

	wexner: {
		name: "Les Wexner"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "financial"
		mention_count: 92
		role: "L Brands/Victoria's Secret — early Epstein patron"
		connections: {
			epstein: true
			l_brands: true
			victoria_secret: true
			southern_trust: true
		}
		evidence: {}
		notes: "92 hits. Granted Epstein power of attorney."
	}

	harvey_weinstein: {
		name: "Harvey Weinstein"
		"@type": {Person: true, Allegations: true}
		cluster: "allegations"
		mention_count: 89
		role: "Former film producer — parallel sex trafficking case"
		connections: {epstein: true, maxwell: true}
		evidence: {}
		notes: "89 hits. Separate conviction. Network overlap with Epstein."
	}

	robert_mueller: {
		name: "Robert Mueller"
		"@type": {Person: true, GovernmentOfficial: true}
		cluster: "doj"
		mention_count: 85
		role: "Former FBI Director / Special Counsel"
		connections: {epstein: true, geoffrey_berman: true, james_comey: true}
		evidence: {}
		notes: "85 hits. FBI oversight during relevant periods."
	}

	alfredo_rodriguez: {
		name: "Alfredo Rodriguez"
		"@type": {Person: true}
		cluster: "staff"
		mention_count: 76
		role: "Former house manager — stole Epstein's black book"
		connections: {epstein: true, juan_alessi: true, janusz_banasiak: true}
		evidence: {}
		notes: "76 hits. Convicted of obstruction for hiding the black book. Died 2015."
	}

	kushner: {
		name: "Jared Kushner"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 75
		role: "Senior advisor — Kushner Companies"
		connections: {epstein: true, trump: true, melania_trump: true}
		evidence: {}
		notes: "75 hits."
	}

	robert_maxwell: {
		name: "Robert Maxwell"
		"@type": {Person: true}
		cluster: "family"
		mention_count: 72
		role: "Ghislaine's father — media magnate, died 1991"
		connections: {maxwell: true, epstein: true}
		evidence: {}
		notes: "72 hits. Died under suspicious circumstances 1991. Intelligence connections alleged."
	}

	brunel: {
		name: "Jean-Luc Brunel"
		"@type": {Person: true, CoreNetwork: true}
		cluster: "core"
		mention_count: 59
		role: "Modeling industry — MC2 Model Management"
		connections: {epstein: true, maxwell: true, mc2_agency: true}
		evidence: {}
		notes: "59 hits. Found dead in Paris jail Feb 2022."
	}

	paul_cassell: {
		name: "Paul Cassell"
		"@type": {Person: true}
		cluster: "legal"
		mention_count: 57
		role: "Law professor / victim attorney"
		connections: {
			brad_edwards: true
			sigrid_mccawley: true
			jack_scarola: true
			virginia_giuffre: true
		}
		evidence: {}
		notes: "57 hits. University of Utah law professor."
	}

	ken_starr: {
		name: "Ken Starr"
		"@type": {Person: true, LegalProtection: true}
		cluster: "legal"
		mention_count: 57
		role: "Defense attorney — negotiated 2008 NPA"
		connections: {epstein: true, dershowitz: true, acosta: true}
		evidence: {}
		notes: "57 hits. Deceased 2022. Clinton impeachment prosecutor turned Epstein defender."
	}

	janusz_banasiak: {
		name: "Janusz Banasiak"
		"@type": {Person: true}
		cluster: "staff"
		mention_count: 56
		role: "Maintenance manager — Epstein properties"
		connections: {epstein: true, alfredo_rodriguez: true, juan_alessi: true}
		evidence: {}
		notes: "56 hits. Testified about property operations."
	}

	obama: {
		name: "Barack Obama"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 55
		role: "Former President"
		connections: {epstein: true, bill_clinton: true, trump: true}
		evidence: {}
		notes: "55 hits. Nature of mentions unclear — needs document review."
	}

	josh_harris: {
		name: "Josh Harris"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "financial"
		mention_count: 48
		role: "Apollo Global co-founder — WH ambassador consideration"
		connections: {epstein: true, leon_black: true, apollo: true}
		evidence: {}
		notes: "48 hits."
	}

	steve_bannon: {
		name: "Steve Bannon"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 40
		role: "Former WH strategist — text messages on iPhone 7"
		connections: {epstein: true, trump: true}
		evidence: {EFTA00027289: true}
		notes: "TEXT MESSAGES on iPhone 7."
	}

	bill_richardson: {
		name: "Bill Richardson"
		"@type": {Person: true, Allegations: true, Politician: true}
		cluster: "allegations"
		mention_count: 39
		role: "Former NM Governor — named in depositions"
		connections: {epstein: true, george_mitchell: true}
		evidence: {}
		notes: "39 hits. Deceased 2023."
	}

	marie_villafana: {
		name: "Marie Villafana"
		"@type": {Person: true, Prosecutor: true}
		cluster: "doj"
		mention_count: 24
		role: "AUSA who worked under Acosta on Epstein case"
		connections: {acosta: true, epstein: true}
		evidence: {}
		notes: "24 hits. Line prosecutor on original case."
	}

	michael_milken: {
		name: "Michael Milken"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "financial"
		mention_count: 26
		role: "Junk bond pioneer — Milken network"
		connections: {epstein: true, leon_black: true}
		evidence: {}
		notes: "26 hits. The 'Milken network' referenced in visualization."
	}

	martin_nowak: {
		name: "Martin Nowak"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 21
		role: "Harvard evolutionary biologist — received Epstein funding"
		connections: {epstein: true, harvard_university: true, larry_summers: true}
		evidence: {}
		notes: "21 hits. Program for Evolutionary Dynamics."
	}

	kevin_spacey: {
		name: "Kevin Spacey"
		"@type": {Person: true, Allegations: true}
		cluster: "allegations"
		mention_count: 18
		role: "Actor — photographed at Epstein properties"
		connections: {epstein: true, maxwell: true, bill_clinton: true}
		evidence: {}
		notes: "18 hits."
	}

	boris_nikolic: {
		name: "Boris Nikolic"
		"@type": {Person: true}
		cluster: "tech"
		mention_count: 17
		role: "Physician / Gates Foundation science advisor"
		connections: {epstein: true, bill_gates: true}
		evidence: {}
		notes: "17 hits. Named in Epstein's will as backup executor."
	}

	david_copperfield: {
		name: "David Copperfield"
		"@type": {Person: true, Allegations: true}
		cluster: "allegations"
		mention_count: 17
		role: "Illusionist — named in documents"
		connections: {epstein: true}
		evidence: {EFTA00013505: true}
	}

	peter_mandelson: {
		name: "Peter Mandelson"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 15
		role: "Former UK Ambassador to US — resigned over Epstein payment allegations"
		connections: {epstein: true, maxwell: true, tony_blair: true}
		evidence: {}
		notes: "15 hits. Resigned from Labour Party after EFTA release."
	}

	bill_gates: {
		name: "Bill Gates"
		"@type": {Person: true}
		cluster: "tech"
		mention_count: 15
		role: "Microsoft co-founder — meetings with Epstein documented"
		connections: {
			epstein: true
			boris_nikolic: true
			larry_summers: true
		}
		evidence: {}
		notes: "15 hits. Met Epstein multiple times. Gates Foundation advisor Boris Nikolic named in will."
	}

	mort_zuckerman: {
		name: "Mort Zuckerman"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "media"
		mention_count: 15
		role: "Real estate / media mogul — NY Daily News, US News"
		connections: {epstein: true}
		evidence: {}
		notes: "15 hits."
	}

	juan_alessi: {
		name: "Juan Alessi"
		"@type": {Person: true}
		cluster: "staff"
		mention_count: 14
		role: "Former house manager — testified extensively"
		connections: {
			epstein: true
			maxwell: true
			alfredo_rodriguez: true
			janusz_banasiak: true
		}
		evidence: {}
		notes: "14 hits. Testified about household operations and visitors."
	}

	lawrence_krauss: {
		name: "Lawrence Krauss"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 14
		role: "Physicist — Origins Project, Epstein funding recipient"
		connections: {epstein: true, martin_nowak: true, stephen_hawking: true}
		evidence: {}
		notes: "14 hits. Resigned from ASU."
	}

	marvin_minsky: {
		name: "Marvin Minsky"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 14
		role: "MIT AI pioneer — allegations in Virginia Giuffre deposition"
		connections: {epstein: true, virginia_giuffre: true}
		evidence: {}
		notes: "14 hits. Deceased 2016. Named in Giuffre deposition."
	}

	stephen_hawking: {
		name: "Stephen Hawking"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 13
		role: "Physicist — attended Epstein events"
		connections: {epstein: true, lawrence_krauss: true}
		evidence: {}
		notes: "13 hits. Deceased 2018."
	}

	glenn_dubin: {
		name: "Glenn Dubin"
		"@type": {Person: true, Allegations: true, FinancialEnabler: true}
		cluster: "allegations"
		mention_count: 13
		role: "Highbridge Capital — allegations in victim statements"
		connections: {epstein: true, eva_dubin: true, highbridge_capital: true}
		evidence: {}
		notes: "13 hits."
	}

	andrew_farkas: {
		name: "Andrew Farkas"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "financial"
		mention_count: 12
		role: "Real estate investor — Island Capital Group"
		connections: {epstein: true}
		evidence: {}
		notes: "12 hits."
	}

	jeff_bezos: {
		name: "Jeff Bezos"
		"@type": {Person: true}
		cluster: "tech"
		mention_count: 11
		role: "Amazon founder"
		connections: {epstein: true}
		evidence: {}
		notes: "11 hits. Nature of mentions unclear."
	}

	melania_trump: {
		name: "Melania Trump"
		"@type": {Person: true}
		cluster: "political"
		mention_count: 11
		role: "Former/current First Lady"
		connections: {trump: true, epstein: true}
		evidence: {}
		notes: "11 hits."
	}

	larry_summers: {
		name: "Larry Summers"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 11
		role: "Former Treasury Secretary / Harvard president"
		connections: {
			epstein: true
			bill_gates: true
			harvard_university: true
			martin_nowak: true
		}
		evidence: {}
		notes: "11 hits. Flew on Epstein's plane."
	}

	sergey_brin: {
		name: "Sergey Brin"
		"@type": {Person: true}
		cluster: "tech"
		mention_count: 10
		role: "Google co-founder"
		connections: {epstein: true}
		evidence: {}
		notes: "10 hits."
	}

	naomi_campbell: {
		name: "Naomi Campbell"
		"@type": {Person: true}
		cluster: "media"
		mention_count: 10
		role: "Supermodel — social connections"
		connections: {epstein: true, maxwell: true}
		evidence: {}
		notes: "10 hits."
	}

	bill_barr: {
		name: "William Barr"
		"@type": {Person: true, GovernmentOfficial: true}
		cluster: "doj"
		mention_count: 10
		role: "AG during Epstein death — father hired Epstein at Dalton"
		connections: {
			epstein: true
			trump: true
			geoffrey_berman: true
			donald_barr: true
			dalton_school: true
			mcc_manhattan: true
		}
		evidence: {}
		notes: "10 hits. AG when Epstein died in MCC."
	}

	george_mitchell: {
		name: "George Mitchell"
		"@type": {Person: true, Allegations: true, Politician: true}
		cluster: "allegations"
		mention_count: 9
		role: "Former Senate Majority Leader — named in depositions"
		connections: {epstein: true, bill_richardson: true}
		evidence: {}
	}

	ehud_barak: {
		name: "Ehud Barak"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 8
		role: "Former Israeli PM — photographed entering Epstein residence"
		connections: {epstein: true, maxwell: true}
		evidence: {}
	}

	steven_pinker: {
		name: "Steven Pinker"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 8
		role: "Harvard cognitive scientist"
		connections: {
			epstein: true
			harvard_university: true
			martin_nowak: true
			lawrence_krauss: true
		}
		evidence: {}
	}

	seth_lloyd: {
		name: "Seth Lloyd"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 8
		role: "MIT quantum computing professor — received Epstein funding"
		connections: {epstein: true, marvin_minsky: true}
		evidence: {}
	}

	george_stephanopoulos: {
		name: "George Stephanopoulos"
		"@type": {Person: true}
		cluster: "media"
		mention_count: 7
		role: "ABC News anchor — attended Epstein dinner"
		connections: {epstein: true}
		evidence: {}
	}

	woody_allen: {
		name: "Woody Allen"
		"@type": {Person: true, Allegations: true}
		cluster: "allegations"
		mention_count: 7
		role: "Filmmaker"
		connections: {epstein: true}
		evidence: {}
	}

	richard_branson: {
		name: "Richard Branson"
		"@type": {Person: true}
		cluster: "tech"
		mention_count: 7
		role: "Virgin Group founder — exchanged emails with Epstein"
		connections: {epstein: true}
		evidence: {}
	}

	peggy_siegal: {
		name: "Peggy Siegal"
		"@type": {Person: true}
		cluster: "media"
		mention_count: 7
		role: "Hollywood publicist — social connector"
		connections: {epstein: true, maxwell: true}
		evidence: {}
	}

	james_comey: {
		name: "James Comey"
		"@type": {Person: true, GovernmentOfficial: true}
		cluster: "doj"
		mention_count: 7
		role: "Former FBI Director"
		connections: {epstein: true, robert_mueller: true}
		evidence: {}
	}

	steve_cohen: {
		name: "Steve Cohen"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "hedge_fund"
		mention_count: 7
		role: "Point72/SAC Capital — $10M to Honeycomb"
		connections: {epstein: true, honeycomb: true}
		evidence: {"DB-SDNY-0008151": true}
	}

	elon_musk: {
		name: "Elon Musk"
		"@type": {Person: true}
		cluster: "tech"
		mention_count: 6
		role: "Tesla/SpaceX founder — mentioned in Epstein communications"
		connections: {epstein: true}
		evidence: {}
		notes: "6 hits. Discussed island visits per reporting."
	}

	sarah_ferguson: {
		name: "Sarah Ferguson"
		"@type": {Person: true}
		cluster: "allegations"
		mention_count: 5
		role: "Duchess of York — Epstein debt payment"
		connections: {prince_andrew: true, epstein: true, maxwell: true}
		evidence: {}
	}

	tom_pritzker: {
		name: "Tom Pritzker"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "financial"
		mention_count: 5
		role: "Hyatt Hotels heir"
		connections: {epstein: true}
		evidence: {}
	}

	virginia_giuffre: {
		name: "Virginia Giuffre"
		"@type": {Person: true}
		cluster: "victim"
		mention_count: 5
		role: "Key accuser — civil suits against Prince Andrew, Dershowitz"
		connections: {
			epstein: true
			maxwell: true
			prince_andrew: true
			dershowitz: true
			sigrid_mccawley: true
			brad_edwards: true
		}
		evidence: {}
		notes: "Also known as Virginia Roberts."
	}

	chelsea_clinton: {
		name: "Chelsea Clinton"
		"@type": {Person: true}
		cluster: "political"
		mention_count: 4
		role: "Bill Clinton's daughter"
		connections: {bill_clinton: true, maxwell: true}
		evidence: {}
		notes: "Maxwell attended Chelsea's 2010 wedding."
	}

	eva_dubin: {
		name: "Eva Dubin"
		"@type": {Person: true}
		cluster: "allegations"
		mention_count: 4
		role: "Glenn Dubin's wife — former Miss Sweden"
		connections: {glenn_dubin: true, epstein: true}
		evidence: {}
	}

	joichi_ito: {
		name: "Joi Ito"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 4
		role: "Former MIT Media Lab director — resigned over Epstein ties"
		connections: {epstein: true, reid_hoffman: true}
		evidence: {"DB-SDNY-0003972": true}
	}

	casey_wasserman: {
		name: "Casey Wasserman"
		"@type": {Person: true}
		cluster: "media"
		mention_count: 3
		role: "2028 LA Olympics committee president"
		connections: {epstein: true}
		evidence: {}
	}

	sarah_kellen: {
		name: "Sarah Kellen"
		"@type": {Person: true, CoreNetwork: true, Scheduler: true}
		cluster: "staff"
		mention_count: 3
		role: "Alleged recruiter/scheduler — named co-conspirator"
		connections: {
			epstein: true
			maxwell: true
			lesley_groff: true
			nadia_marcinkova: true
		}
		evidence: {}
	}

	reid_hoffman: {
		name: "Reid Hoffman"
		"@type": {Person: true}
		cluster: "paypal_mafia"
		mention_count: 2
		role: "LinkedIn founder — newsletter email to Epstein April 2014"
		connections: {epstein: true, peter_thiel: true, lesley_groff: true, joichi_ito: true}
		evidence: {EFTA01925403: true}
	}

	howard_lutnick: {
		name: "Howard Lutnick"
		"@type": {Person: true, Politician: true, GovernmentOfficial: true}
		cluster: "cabinet"
		mention_count: 2
		role: "Commerce Secretary — Cantor Fitzgerald CEO"
		connections: {epstein: true, trump: true, cantor_fitzgerald: true}
		evidence: {EFTA00020515: true}
	}

	tony_blair: {
		name: "Tony Blair"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 2
		role: "Former UK PM"
		connections: {epstein: true, peter_mandelson: true}
		evidence: {}
	}

	brett_ratner: {
		name: "Brett Ratner"
		"@type": {Person: true, Allegations: true}
		cluster: "media"
		mention_count: 2
		role: "Filmmaker — separate misconduct allegations"
		connections: {epstein: true}
		evidence: {}
	}

	nadia_marcinkova: {
		name: "Nadia Marcinkova"
		"@type": {Person: true, CoreNetwork: true}
		cluster: "core"
		mention_count: 1
		role: "Known associate — pilot, named co-conspirator"
		connections: {epstein: true, maxwell: true, sarah_kellen: true}
		evidence: {}
	}

	katie_couric: {
		name: "Katie Couric"
		"@type": {Person: true}
		cluster: "media"
		mention_count: 1
		role: "Journalist — attended Epstein dinner"
		connections: {epstein: true}
		evidence: {}
	}

	gordon_brown: {
		name: "Gordon Brown"
		"@type": {Person: true, Politician: true}
		cluster: "political"
		mention_count: 1
		role: "Former UK PM"
		connections: {epstein: true}
		evidence: {}
	}

	kathryn_ruemmler: {
		name: "Kathryn Ruemmler"
		"@type": {Person: true}
		cluster: "legal"
		mention_count: 1
		role: "Former White House Counsel — Goldman Sachs general counsel"
		connections: {epstein: true, goldman_sachs: true, obama: true}
		evidence: {}
	}

	adriana_ross: {
		name: "Adriana Ross"
		"@type": {Person: true}
		cluster: "staff"
		mention_count: 1
		role: "Epstein associate — named co-conspirator"
		connections: {epstein: true, maxwell: true}
		evidence: {}
	}

	emmy_taylor: {
		name: "Emmy Taylor"
		"@type": {Person: true}
		cluster: "staff"
		mention_count: 1
		role: "Maxwell's personal assistant"
		connections: {maxwell: true, epstein: true}
		evidence: {}
	}

	leon_botstein: {
		name: "Leon Botstein"
		"@type": {Person: true}
		cluster: "academia"
		mention_count: 1
		role: "Bard College president"
		connections: {epstein: true}
		evidence: {}
	}

	alberto_gonzales: {
		name: "Alberto Gonzales"
		"@type": {Person: true, GovernmentOfficial: true}
		cluster: "doj"
		mention_count: 1
		role: "Former AG — preceded Acosta-era prosecution"
		connections: {epstein: true, acosta: true}
		evidence: {}
	}

	philippe_laffont: {
		name: "Philippe Laffont"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "hedge_fund"
		role: "Coatue Management founder"
		connections: {epstein: true, coatue_management: true}
		evidence: {"DB-SDNY-0007748": true}
		notes: "ZERO corpus hits but listed on DugganUSA visualization."
	}

	peter_thiel: {
		name: "Peter Thiel"
		"@type": {Person: true, FinancialEnabler: true}
		cluster: "paypal_mafia"
		role: "Palantir/PayPal — $4.45M+ to Valar Ventures"
		connections: {epstein: true, reid_hoffman: true, valar_ventures: true}
		evidence: {"DB-SDNY-0004924": true}
		notes: "ZERO corpus hits. On visualization but not in DOJ text."
	}

	brock_pierce: {
		name: "Brock Pierce"
		"@type": {Person: true}
		cluster: "crypto"
		role: "Crypto entrepreneur"
		connections: {epstein: true, bart_stephens: true, blockchain_capital: true}
		evidence: {}
		notes: "ZERO corpus hits."
	}

	adam_back: {
		name: "Adam Back"
		"@type": {Person: true}
		cluster: "crypto"
		role: "Blockstream CEO"
		connections: {epstein: true, blockstream: true}
		evidence: {"DB-SDNY-0000478": true}
		notes: "ZERO corpus hits."
	}

	bart_stephens: {
		name: "Bart Stephens"
		"@type": {Person: true}
		cluster: "crypto"
		role: "Blockchain Capital co-founder"
		connections: {epstein: true, brock_pierce: true, blockchain_capital: true}
		evidence: {}
		notes: "ZERO corpus hits."
	}

	donald_barr: {
		name: "Donald Barr"
		"@type": {Person: true}
		cluster: "family"
		role: "William Barr's father — hired Epstein at Dalton School 1973"
		connections: {bill_barr: true, dalton_school: true, epstein: true}
		evidence: {}
		notes: "ZERO corpus hits. Hired Epstein to teach at Dalton despite no degree."
	}
}
