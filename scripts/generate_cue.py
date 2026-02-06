#!/usr/bin/env python3
"""
Generate CUE entity files from discovery data + manual categorization.

Outputs:
  entities/people.cue
  entities/organizations.cue
  entities/financial_institutions.cue
  entities/properties.cue
"""

import json
import textwrap
from pathlib import Path

ROOT = Path(__file__).parent.parent

# ─── ENTITY DEFINITIONS ────────────────────────────────────────
# Each entry: (cue_id, display_name, types[], cluster, hit_count, role, connections[], evidence{}, notes)
# Types use the #EntityType enum from vocab.cue

PEOPLE = [
    # ── TIER 1: 100+ hits ──────────────────────────────────────
    ("epstein", "Jeffrey Epstein", ["Person", "CoreNetwork"], "core", 31363,
     "Central node — convicted sex trafficker",
     ["maxwell", "brunel", "lesley_groff", "sarah_kellen", "nadia_marcinkova",
      "leon_black", "wexner", "steve_cohen", "josh_harris", "peter_thiel",
      "reid_hoffman", "prince_andrew", "david_copperfield", "glenn_dubin",
      "bill_richardson", "george_mitchell", "joichi_ito", "howard_lutnick",
      "trump", "kushner", "bill_clinton", "steve_bannon", "dershowitz",
      "ken_starr", "acosta", "bill_barr", "geoffrey_berman", "mark_epstein",
      "bill_gates", "jes_staley", "virginia_giuffre", "elon_musk", "jeff_bezos",
      "harvey_weinstein", "kevin_spacey", "ehud_barak", "woody_allen",
      "naomi_campbell", "sergey_brin", "larry_summers", "stephen_hawking",
      "martin_nowak", "lawrence_krauss", "marvin_minsky", "boris_nikolic",
      "alfredo_rodriguez", "juan_alessi", "janusz_banasiak", "peggy_siegal",
      "southern_trust", "financial_trust", "gratitude_america", "butterfly_trust",
      "couq_foundation", "deutsche_bank", "jp_morgan", "bear_stearns"],
     {"EFTA02731082": True}, None),

    ("maxwell", "Ghislaine Maxwell", ["Person", "CoreNetwork", "Recruiter"], "core", 15306,
     "Convicted co-conspirator — recruitment, grooming",
     ["epstein", "brunel", "lesley_groff", "sarah_kellen", "nadia_marcinkova",
      "prince_andrew", "virginia_giuffre", "bill_clinton", "trump",
      "terramar", "robert_maxwell", "emmy_taylor", "adriana_ross",
      "laura_menninger"],
     {}, "Convicted Dec 2021. Serving 20-year sentence."),

    ("laura_menninger", "Laura Menninger", ["Person", "LegalProtection"], "legal", 1000,
     "Maxwell defense attorney",
     ["maxwell", "sigrid_mccawley", "dershowitz"],
     {}, "1000+ hits. Maxwell trial defense team."),

    ("jes_staley", "Jes Staley", ["Person", "FinancialEnabler"], "banking", 791,
     "Former Barclays CEO — extensive Epstein relationship via JP Morgan",
     ["epstein", "jp_morgan", "barclays", "deutsche_bank"],
     {}, "791 hits. Left Barclays over Epstein ties. Previously at JP Morgan."),

    ("prince_andrew", "Prince Andrew", ["Person", "Allegations"], "allegations", 441,
     "Duke of York — civil settlement with Virginia Giuffre",
     ["epstein", "maxwell", "virginia_giuffre", "sarah_ferguson"],
     {}, "441 hits. Settled civil case. Stripped of titles by King Charles."),

    ("lesley_groff", "Lesley Groff", ["Person", "CoreNetwork", "Scheduler"], "staff", 420,
     "Scheduler — NPA immunity recipient. Arranged Reid Hoffman meetings.",
     ["epstein", "maxwell", "reid_hoffman", "sarah_kellen"],
     {"EFTA02731039": True}, None),

    ("sigrid_mccawley", "Sigrid McCawley", ["Person"], "legal", 363,
     "Victim attorney — Boies Schiller Flexner",
     ["virginia_giuffre", "brad_edwards", "jack_scarola", "laura_menninger"],
     {}, "363 hits. Lead attorney for Virginia Giuffre."),

    ("trump", "Donald Trump", ["Person", "Politician"], "political", 743,
     "Former/current President — 743 mentions in corpus",
     ["epstein", "maxwell", "kushner", "howard_lutnick", "steve_bannon",
      "bill_barr", "acosta", "melania_trump", "dershowitz", "mar_a_lago"],
     {}, "743 mentions. Mar-a-Lago connection. Appointed Acosta as Labor Secretary."),

    ("leon_black", "Leon Black", ["Person", "FinancialEnabler"], "financial", 270,
     "Apollo Global co-founder — $158M+ to Epstein",
     ["epstein", "josh_harris", "apollo", "dechert_llp", "michael_milken"],
     {"DB-SDNY-0002962": True}, None),

    ("brad_edwards", "Brad Edwards", ["Person"], "legal", 255,
     "Victim attorney — represented multiple Epstein accusers",
     ["virginia_giuffre", "sigrid_mccawley", "jack_scarola", "paul_cassell", "acosta"],
     {}, "255 hits. Co-authored 'Relentless Pursuit.'"),

    ("dershowitz", "Alan Dershowitz", ["Person", "LegalProtection", "Allegations"], "legal", 214,
     "Defense attorney — also named in allegations",
     ["epstein", "ken_starr", "virginia_giuffre", "laura_menninger", "trump"],
     {}, "214 hits. Dual role: defense attorney AND accused by Giuffre."),

    ("mark_epstein", "Mark Epstein", ["Person"], "family", 209,
     "Jeffrey Epstein's brother",
     ["epstein", "southern_trust"],
     {}, "209 hits. Real estate connections. Southern Trust involvement."),

    ("acosta", "Alexander Acosta", ["Person", "GovernmentOfficial", "Prosecutor"], "doj", 204,
     "Former US Attorney SDFL — negotiated 2008 NPA",
     ["epstein", "ken_starr", "trump", "marie_villafana", "brad_edwards"],
     {}, "204 hits. NPA deal widely criticized. Resigned as Labor Secretary 2019."),

    ("jack_scarola", "Jack Scarola", ["Person"], "legal", 157,
     "Attorney — represented Epstein victims",
     ["virginia_giuffre", "brad_edwards", "sigrid_mccawley", "paul_cassell"],
     {}, "157 hits."),

    ("bill_clinton", "Bill Clinton", ["Person", "Politician"], "political", 129,
     "Former President — flight logs, foundation connections",
     ["epstein", "maxwell", "trump", "chelsea_clinton", "clinton_foundation",
      "lolita_express"],
     {}, "129 hits. Flight log connections. Photos found in Epstein home."),

    ("geoffrey_berman", "Geoffrey Berman", ["Person", "GovernmentOfficial", "Prosecutor"], "doj", 115,
     "Former US Attorney SDNY — co-conspirators memo",
     ["epstein", "bill_barr", "robert_mueller"],
     {"EFTA02731082": True}, "Barr attempted to fire him during Epstein investigation."),

    # ── TIER 2: 10-99 hits ─────────────────────────────────────
    ("wexner", "Les Wexner", ["Person", "FinancialEnabler"], "financial", 92,
     "L Brands/Victoria's Secret — early Epstein patron",
     ["epstein", "l_brands", "victoria_secret", "southern_trust"],
     {}, "92 hits. Granted Epstein power of attorney."),

    ("harvey_weinstein", "Harvey Weinstein", ["Person", "Allegations"], "allegations", 89,
     "Former film producer — parallel sex trafficking case",
     ["epstein", "maxwell"],
     {}, "89 hits. Separate conviction. Network overlap with Epstein."),

    ("robert_mueller", "Robert Mueller", ["Person", "GovernmentOfficial"], "doj", 85,
     "Former FBI Director / Special Counsel",
     ["epstein", "geoffrey_berman", "james_comey"],
     {}, "85 hits. FBI oversight during relevant periods."),

    ("alfredo_rodriguez", "Alfredo Rodriguez", ["Person"], "staff", 76,
     "Former house manager — stole Epstein's black book",
     ["epstein", "juan_alessi", "janusz_banasiak"],
     {}, "76 hits. Convicted of obstruction for hiding the black book. Died 2015."),

    ("kushner", "Jared Kushner", ["Person", "Politician"], "political", 75,
     "Senior advisor — Kushner Companies",
     ["epstein", "trump", "melania_trump"],
     {}, "75 hits."),

    ("robert_maxwell", "Robert Maxwell", ["Person"], "family", 72,
     "Ghislaine's father — media magnate, died 1991",
     ["maxwell", "epstein"],
     {}, "72 hits. Died under suspicious circumstances 1991. Intelligence connections alleged."),

    ("brunel", "Jean-Luc Brunel", ["Person", "CoreNetwork"], "core", 59,
     "Modeling industry — MC2 Model Management",
     ["epstein", "maxwell", "mc2_agency"],
     {}, "59 hits. Found dead in Paris jail Feb 2022."),

    ("paul_cassell", "Paul Cassell", ["Person"], "legal", 57,
     "Law professor / victim attorney",
     ["brad_edwards", "sigrid_mccawley", "jack_scarola", "virginia_giuffre"],
     {}, "57 hits. University of Utah law professor."),

    ("ken_starr", "Ken Starr", ["Person", "LegalProtection"], "legal", 57,
     "Defense attorney — negotiated 2008 NPA",
     ["epstein", "dershowitz", "acosta"],
     {}, "57 hits. Deceased 2022. Clinton impeachment prosecutor turned Epstein defender."),

    ("janusz_banasiak", "Janusz Banasiak", ["Person"], "staff", 56,
     "Maintenance manager — Epstein properties",
     ["epstein", "alfredo_rodriguez", "juan_alessi"],
     {}, "56 hits. Testified about property operations."),

    ("obama", "Barack Obama", ["Person", "Politician"], "political", 55,
     "Former President",
     ["epstein", "bill_clinton", "trump"],
     {}, "55 hits. Nature of mentions unclear — needs document review."),

    ("josh_harris", "Josh Harris", ["Person", "FinancialEnabler"], "financial", 48,
     "Apollo Global co-founder — WH ambassador consideration",
     ["epstein", "leon_black", "apollo"],
     {}, "48 hits."),

    ("steve_bannon", "Steve Bannon", ["Person", "Politician"], "political", 40,
     "Former WH strategist — text messages on iPhone 7",
     ["epstein", "trump"],
     {"EFTA00027289": True}, "TEXT MESSAGES on iPhone 7."),

    ("bill_richardson", "Bill Richardson", ["Person", "Allegations", "Politician"], "allegations", 39,
     "Former NM Governor — named in depositions",
     ["epstein", "george_mitchell"],
     {}, "39 hits. Deceased 2023."),

    ("marie_villafana", "Marie Villafana", ["Person", "Prosecutor"], "doj", 24,
     "AUSA who worked under Acosta on Epstein case",
     ["acosta", "epstein"],
     {}, "24 hits. Line prosecutor on original case."),

    ("michael_milken", "Michael Milken", ["Person", "FinancialEnabler"], "financial", 26,
     "Junk bond pioneer — Milken network",
     ["epstein", "leon_black"],
     {}, "26 hits. The 'Milken network' referenced in visualization."),

    ("martin_nowak", "Martin Nowak", ["Person"], "academia", 21,
     "Harvard evolutionary biologist — received Epstein funding",
     ["epstein", "harvard_university", "larry_summers"],
     {}, "21 hits. Program for Evolutionary Dynamics."),

    ("kevin_spacey", "Kevin Spacey", ["Person", "Allegations"], "allegations", 18,
     "Actor — photographed at Epstein properties",
     ["epstein", "maxwell", "bill_clinton"],
     {}, "18 hits."),

    ("boris_nikolic", "Boris Nikolic", ["Person"], "tech", 17,
     "Physician / Gates Foundation science advisor",
     ["epstein", "bill_gates"],
     {}, "17 hits. Named in Epstein's will as backup executor."),

    ("david_copperfield", "David Copperfield", ["Person", "Allegations"], "allegations", 17,
     "Illusionist — named in documents",
     ["epstein"],
     {"EFTA00013505": True}, None),

    ("peter_mandelson", "Peter Mandelson", ["Person", "Politician"], "political", 15,
     "Former UK Ambassador to US — resigned over Epstein payment allegations",
     ["epstein", "maxwell", "tony_blair"],
     {}, "15 hits. Resigned from Labour Party after EFTA release."),

    ("bill_gates", "Bill Gates", ["Person"], "tech", 15,
     "Microsoft co-founder — meetings with Epstein documented",
     ["epstein", "boris_nikolic", "melinda_gates", "larry_summers"],
     {}, "15 hits. Met Epstein multiple times. Gates Foundation advisor Boris Nikolic named in will."),

    ("mort_zuckerman", "Mort Zuckerman", ["Person", "FinancialEnabler"], "media", 15,
     "Real estate / media mogul — NY Daily News, US News",
     ["epstein"],
     {}, "15 hits."),

    ("juan_alessi", "Juan Alessi", ["Person"], "staff", 14,
     "Former house manager — testified extensively",
     ["epstein", "maxwell", "alfredo_rodriguez", "janusz_banasiak"],
     {}, "14 hits. Testified about household operations and visitors."),

    ("lawrence_krauss", "Lawrence Krauss", ["Person"], "academia", 14,
     "Physicist — Origins Project, Epstein funding recipient",
     ["epstein", "martin_nowak", "stephen_hawking"],
     {}, "14 hits. Resigned from ASU."),

    ("marvin_minsky", "Marvin Minsky", ["Person"], "academia", 14,
     "MIT AI pioneer — allegations in Virginia Giuffre deposition",
     ["epstein", "virginia_giuffre"],
     {}, "14 hits. Deceased 2016. Named in Giuffre deposition."),

    ("stephen_hawking", "Stephen Hawking", ["Person"], "academia", 13,
     "Physicist — attended Epstein events",
     ["epstein", "lawrence_krauss"],
     {}, "13 hits. Deceased 2018."),

    ("glenn_dubin", "Glenn Dubin", ["Person", "Allegations", "FinancialEnabler"], "allegations", 13,
     "Highbridge Capital — allegations in victim statements",
     ["epstein", "eva_dubin", "highbridge_capital"],
     {}, "13 hits."),

    ("andrew_farkas", "Andrew Farkas", ["Person", "FinancialEnabler"], "financial", 12,
     "Real estate investor — Island Capital Group",
     ["epstein"],
     {}, "12 hits."),

    ("jeff_bezos", "Jeff Bezos", ["Person"], "tech", 11,
     "Amazon founder",
     ["epstein"],
     {}, "11 hits. Nature of mentions unclear."),

    ("melania_trump", "Melania Trump", ["Person"], "political", 11,
     "Former/current First Lady",
     ["trump", "epstein"],
     {}, "11 hits."),

    ("larry_summers", "Larry Summers", ["Person"], "academia", 11,
     "Former Treasury Secretary / Harvard president",
     ["epstein", "bill_gates", "harvard_university", "martin_nowak"],
     {}, "11 hits. Flew on Epstein's plane."),

    ("sergey_brin", "Sergey Brin", ["Person"], "tech", 10,
     "Google co-founder",
     ["epstein"],
     {}, "10 hits."),

    ("naomi_campbell", "Naomi Campbell", ["Person"], "media", 10,
     "Supermodel — social connections",
     ["epstein", "maxwell"],
     {}, "10 hits."),

    ("bill_barr", "William Barr", ["Person", "GovernmentOfficial"], "doj", 10,
     "AG during Epstein death — father hired Epstein at Dalton",
     ["epstein", "trump", "geoffrey_berman", "donald_barr", "dalton_school", "mcc_manhattan"],
     {}, "10 hits. AG when Epstein died in MCC."),

    # ── TIER 3: <10 hits ──────────────────────────────────────
    ("george_mitchell", "George Mitchell", ["Person", "Allegations", "Politician"], "allegations", 9,
     "Former Senate Majority Leader — named in depositions",
     ["epstein", "bill_richardson"], {}, None),

    ("ehud_barak", "Ehud Barak", ["Person", "Politician"], "political", 8,
     "Former Israeli PM — photographed entering Epstein residence",
     ["epstein", "maxwell"], {}, None),

    ("steven_pinker", "Steven Pinker", ["Person"], "academia", 8,
     "Harvard cognitive scientist",
     ["epstein", "harvard_university", "martin_nowak", "lawrence_krauss"], {}, None),

    ("seth_lloyd", "Seth Lloyd", ["Person"], "academia", 8,
     "MIT quantum computing professor — received Epstein funding",
     ["epstein", "marvin_minsky"], {}, None),

    ("george_stephanopoulos", "George Stephanopoulos", ["Person"], "media", 7,
     "ABC News anchor — attended Epstein dinner",
     ["epstein"], {}, None),

    ("woody_allen", "Woody Allen", ["Person", "Allegations"], "allegations", 7,
     "Filmmaker",
     ["epstein"], {}, None),

    ("richard_branson", "Richard Branson", ["Person"], "tech", 7,
     "Virgin Group founder — exchanged emails with Epstein",
     ["epstein"], {}, None),

    ("peggy_siegal", "Peggy Siegal", ["Person"], "media", 7,
     "Hollywood publicist — social connector",
     ["epstein", "maxwell"], {}, None),

    ("james_comey", "James Comey", ["Person", "GovernmentOfficial"], "doj", 7,
     "Former FBI Director",
     ["epstein", "robert_mueller"], {}, None),

    ("steve_cohen", "Steve Cohen", ["Person", "FinancialEnabler"], "hedge_fund", 7,
     "Point72/SAC Capital — $10M to Honeycomb",
     ["epstein", "honeycomb"], {"DB-SDNY-0008151": True}, None),

    ("elon_musk", "Elon Musk", ["Person"], "tech", 6,
     "Tesla/SpaceX founder — mentioned in Epstein communications",
     ["epstein"], {}, "6 hits. Discussed island visits per reporting."),

    ("sarah_ferguson", "Sarah Ferguson", ["Person"], "allegations", 5,
     "Duchess of York — Epstein debt payment",
     ["prince_andrew", "epstein", "maxwell"], {}, None),

    ("tom_pritzker", "Tom Pritzker", ["Person", "FinancialEnabler"], "financial", 5,
     "Hyatt Hotels heir",
     ["epstein"], {}, None),

    ("virginia_giuffre", "Virginia Giuffre", ["Person"], "victim", 5,
     "Key accuser — civil suits against Prince Andrew, Dershowitz",
     ["epstein", "maxwell", "prince_andrew", "dershowitz", "sigrid_mccawley",
      "brad_edwards"], {}, "Also known as Virginia Roberts."),

    ("chelsea_clinton", "Chelsea Clinton", ["Person"], "political", 4,
     "Bill Clinton's daughter",
     ["bill_clinton", "maxwell"], {}, "Maxwell attended Chelsea's 2010 wedding."),

    ("eva_dubin", "Eva Dubin", ["Person"], "allegations", 4,
     "Glenn Dubin's wife — former Miss Sweden",
     ["glenn_dubin", "epstein"], {}, None),

    ("joichi_ito", "Joi Ito", ["Person"], "academia", 4,
     "Former MIT Media Lab director — resigned over Epstein ties",
     ["epstein", "reid_hoffman"], {"DB-SDNY-0003972": True}, None),

    ("casey_wasserman", "Casey Wasserman", ["Person"], "media", 3,
     "2028 LA Olympics committee president",
     ["epstein"], {}, None),

    ("sarah_kellen", "Sarah Kellen", ["Person", "CoreNetwork", "Scheduler"], "staff", 3,
     "Alleged recruiter/scheduler — named co-conspirator",
     ["epstein", "maxwell", "lesley_groff", "nadia_marcinkova"], {}, None),

    ("reid_hoffman", "Reid Hoffman", ["Person"], "paypal_mafia", 2,
     "LinkedIn founder — newsletter email to Epstein April 2014",
     ["epstein", "peter_thiel", "lesley_groff", "joichi_ito"],
     {"EFTA01925403": True}, None),

    ("howard_lutnick", "Howard Lutnick", ["Person", "Politician", "GovernmentOfficial"], "cabinet", 2,
     "Commerce Secretary — Cantor Fitzgerald CEO",
     ["epstein", "trump", "cantor_fitzgerald"],
     {"EFTA00020515": True}, None),

    ("tony_blair", "Tony Blair", ["Person", "Politician"], "political", 2,
     "Former UK PM",
     ["epstein", "peter_mandelson"], {}, None),

    ("brett_ratner", "Brett Ratner", ["Person", "Allegations"], "media", 2,
     "Filmmaker — separate misconduct allegations",
     ["epstein"], {}, None),

    ("nadia_marcinkova", "Nadia Marcinkova", ["Person", "CoreNetwork"], "core", 1,
     "Known associate — pilot, named co-conspirator",
     ["epstein", "maxwell", "sarah_kellen"], {}, None),

    ("katie_couric", "Katie Couric", ["Person"], "media", 1,
     "Journalist — attended Epstein dinner",
     ["epstein"], {}, None),

    ("gordon_brown", "Gordon Brown", ["Person", "Politician"], "political", 1,
     "Former UK PM",
     ["epstein"], {}, None),

    ("kathryn_ruemmler", "Kathryn Ruemmler", ["Person"], "legal", 1,
     "Former White House Counsel — Goldman Sachs general counsel",
     ["epstein", "goldman_sachs", "obama"], {}, None),

    ("adriana_ross", "Adriana Ross", ["Person"], "staff", 1,
     "Epstein associate — named co-conspirator",
     ["epstein", "maxwell"], {}, None),

    ("emmy_taylor", "Emmy Taylor", ["Person"], "staff", 1,
     "Maxwell's personal assistant",
     ["maxwell", "epstein"], {}, None),

    ("leon_botstein", "Leon Botstein", ["Person"], "academia", 1,
     "Bard College president",
     ["epstein"], {}, None),

    ("alberto_gonzales", "Alberto Gonzales", ["Person", "GovernmentOfficial"], "doj", 1,
     "Former AG — preceded Acosta-era prosecution",
     ["epstein", "acosta"], {}, None),

    ("philippe_laffont", "Philippe Laffont", ["Person", "FinancialEnabler"], "hedge_fund", 0,
     "Coatue Management founder",
     ["epstein", "coatue_management"], {"DB-SDNY-0007748": True},
     "ZERO corpus hits but listed on DugganUSA visualization."),

    ("peter_thiel", "Peter Thiel", ["Person", "FinancialEnabler"], "paypal_mafia", 0,
     "Palantir/PayPal — $4.45M+ to Valar Ventures",
     ["epstein", "reid_hoffman", "valar_ventures"],
     {"DB-SDNY-0004924": True},
     "ZERO corpus hits. On visualization but not in DOJ text."),

    ("brock_pierce", "Brock Pierce", ["Person"], "crypto", 0,
     "Crypto entrepreneur",
     ["epstein", "bart_stephens", "blockchain_capital"], {},
     "ZERO corpus hits."),

    ("adam_back", "Adam Back", ["Person"], "crypto", 0,
     "Blockstream CEO",
     ["epstein", "blockstream"], {"DB-SDNY-0000478": True},
     "ZERO corpus hits."),

    ("bart_stephens", "Bart Stephens", ["Person"], "crypto", 0,
     "Blockchain Capital co-founder",
     ["epstein", "brock_pierce", "blockchain_capital"], {},
     "ZERO corpus hits."),

    ("donald_barr", "Donald Barr", ["Person"], "family", 0,
     "William Barr's father — hired Epstein at Dalton School 1973",
     ["bill_barr", "dalton_school", "epstein"], {},
     "ZERO corpus hits. Hired Epstein to teach at Dalton despite no degree."),
]

ORGANIZATIONS = [
    # ── TIER 1 ──
    ("southern_trust", "Southern Trust", ["Organization", "ShellCompany"], "shell", 1000,
     "Shell company — trust vehicle", ["epstein", "mark_epstein", "wexner"], {}, None),
    ("financial_trust", "Financial Trust Company", ["Organization", "ShellCompany"], "shell", 1000,
     "Trust company — financial vehicle", ["epstein"], {}, "1000+ hits."),
    ("gratitude_america", "Gratitude America", ["Organization", "Foundation"], "shell", 219,
     "Epstein-linked foundation", ["epstein"], {}, None),
    ("butterfly_trust", "Butterfly Trust", ["Organization", "ShellCompany"], "shell", 158,
     "Trust vehicle", ["epstein"], {}, None),
    ("couq_foundation", "COUQ Foundation", ["Organization", "Foundation"], "shell", 146,
     "Epstein-linked foundation", ["epstein"], {}, None),
    ("highbridge_capital", "Highbridge Capital", ["Organization", "HedgeFund"], "hedge_fund", 140,
     "Glenn Dubin's hedge fund", ["glenn_dubin", "epstein"], {}, None),
    ("terramar", "Terramar Project", ["Organization", "Foundation"], "core", 111,
     "Maxwell's ocean conservation nonprofit",
     ["maxwell", "epstein"], {}, "Dissolved after Maxwell's arrest."),

    # ── TIER 2 ──
    ("harvard_university", "Harvard University", ["Organization"], "academia", 62,
     "Academic institution — Epstein donations",
     ["larry_summers", "martin_nowak", "steven_pinker", "epstein"], {}, None),
    ("dechert_llp", "Dechert LLP", ["Organization", "LawFirm"], "legal", 45,
     "Law firm — $158M investigation", ["leon_black", "epstein"], {"EFTA02730996": True}, None),
    ("apollo", "Apollo Global Management", ["Organization", "InvestmentFirm"], "financial", 30,
     "Private equity — Black & Harris", ["leon_black", "josh_harris", "epstein"], {}, None),
    ("mc2_agency", "MC2 Model Management", ["Organization", "ModelingAgency"], "core", 26,
     "Brunel's modeling agency", ["brunel", "epstein", "maxwell"], {}, None),
    ("coatue_management", "Coatue Management", ["Organization", "HedgeFund"], "hedge_fund", 20,
     "Laffont's hedge fund", ["philippe_laffont"], {}, None),
    ("victoria_secret", "Victoria's Secret", ["Organization"], "financial", 38,
     "L Brands subsidiary — Wexner connection",
     ["wexner", "l_brands", "epstein"], {}, None),
    ("cantor_fitzgerald", "Cantor Fitzgerald", ["Organization"], "financial", 15,
     "Financial services — Lutnick CEO", ["howard_lutnick"], {}, None),
    ("l_brands", "L Brands", ["Organization"], "financial", 14,
     "Wexner's retail conglomerate", ["wexner", "victoria_secret", "epstein"], {}, None),

    # ── TIER 3 ──
    ("honeycomb", "Honeycomb", ["Organization", "ShellCompany"], "shell", 10,
     "Investment vehicle — Steve Cohen $10M", ["steve_cohen", "epstein"], {}, None),
    ("clinton_foundation", "Clinton Foundation", ["Organization", "Foundation"], "political", 8,
     "Clinton charitable foundation", ["bill_clinton", "chelsea_clinton"], {}, None),
    ("kyara", "Kyara", ["Organization", "ShellCompany"], "shell", 7,
     "Shell company — minimal information", ["epstein"], {}, None),
    ("liquid_funding", "Liquid Funding", ["Organization", "ShellCompany"], "shell", 5,
     "Financial vehicle", ["epstein"], {}, None),
    ("blockchain_capital", "Blockchain Capital", ["Organization", "InvestmentFirm"], "crypto", 3,
     "Crypto VC — Bart Stephens", ["bart_stephens", "brock_pierce", "epstein"], {}, None),
    ("valar_ventures", "Valar Ventures", ["Organization", "ShellCompany", "InvestmentFirm"], "shell", 1,
     "Investment vehicle — $40M, Thiel invested $4.45M+",
     ["peter_thiel", "epstein"], {}, None),
    ("palantir", "Palantir Technologies", ["Organization"], "tech", 1,
     "Peter Thiel's data analytics company", ["peter_thiel"], {}, None),
    ("blockstream", "Blockstream", ["Organization"], "crypto", 4,
     "Bitcoin infrastructure company — Adam Back CEO", ["adam_back"], {}, None),
    ("rothschild_geneva", "Rothschild Geneva", ["Organization", "FinancialInstitution", "FinancialEnabler"], "financial", 0,
     "Geneva banking — Epstein financial relationship",
     ["epstein"], {"DB-SDNY-0005122": True},
     "On visualization but zero direct hits in corpus."),
]

FINANCIAL_INSTITUTIONS = [
    ("deutsche_bank", "Deutsche Bank", ["Organization", "FinancialInstitution"], "banking", 1000,
     "Primary banking relationship — fined $150M over Epstein failures",
     ["epstein", "jes_staley"], {}, "DB-SDNY prefix docs = Deutsche Bank subpoena production."),
    ("jp_morgan", "JP Morgan Chase", ["Organization", "FinancialInstitution"], "banking", 1000,
     "Banking relationship — $290M USVI settlement",
     ["epstein", "jes_staley"], {}, "$290M settlement with US Virgin Islands."),
    ("bank_of_america", "Bank of America", ["Organization", "FinancialInstitution"], "banking", 936,
     "Financial institution — Epstein accounts", ["epstein"], {}, None),
    ("wells_fargo", "Wells Fargo", ["Organization", "FinancialInstitution"], "banking", 808,
     "Financial institution — Epstein/Maxwell accounts", ["epstein", "maxwell"], {}, None),
    ("ubs", "UBS", ["Organization", "FinancialInstitution"], "banking", 672,
     "Swiss bank — Epstein/Maxwell accounts", ["epstein", "maxwell", "rothschild_geneva"], {}, None),
    ("credit_suisse", "Credit Suisse", ["Organization", "FinancialInstitution"], "banking", 634,
     "Swiss bank — Epstein accounts", ["epstein"], {}, None),
    ("citibank", "Citibank", ["Organization", "FinancialInstitution"], "banking", 534,
     "Financial institution", ["epstein"], {}, None),
    ("hsbc", "HSBC", ["Organization", "FinancialInstitution"], "banking", 499,
     "Financial institution", ["epstein"], {}, None),
    ("barclays", "Barclays", ["Organization", "FinancialInstitution"], "banking", 359,
     "UK bank — Jes Staley connection", ["epstein", "jes_staley"], {}, None),
    ("bear_stearns", "Bear Stearns", ["Organization", "FinancialInstitution"], "banking", 211,
     "Epstein's early career employer", ["epstein"], {},
     "Where Epstein started on Wall Street. Collapsed 2008."),
    ("goldman_sachs", "Goldman Sachs", ["Organization", "FinancialInstitution"], "banking", 194,
     "Financial institution", ["epstein", "kathryn_ruemmler"], {}, None),
    ("morgan_stanley", "Morgan Stanley", ["Organization", "FinancialInstitution"], "banking", 164,
     "Financial institution", ["epstein"], {}, None),
]

PROPERTIES = [
    ("east_71st", "9 East 71st Street", ["Property"], "core", 308,
     "Manhattan townhouse — primary residence",
     ["epstein", "maxwell", "wexner"], {},
     "Largest private residence in Manhattan. Originally Wexner's."),
    ("zorro_ranch", "Zorro Ranch", ["Property"], "core", 308,
     "New Mexico ranch — 8,000 acres",
     ["epstein", "bill_gates"], {}, "Near Stanley, NM. Visited by Bill Gates."),
    ("el_brillo_way", "El Brillo Way", ["Property"], "core", 294,
     "Palm Beach mansion — site of initial investigation",
     ["epstein", "alfredo_rodriguez", "juan_alessi"], {},
     "358 El Brillo Way. Where Palm Beach PD investigation started."),
    ("little_st_james", "Little St. James Island", ["Property"], "core", 255,
     "Private Caribbean island — US Virgin Islands",
     ["epstein", "maxwell", "howard_lutnick", "bill_clinton", "prince_andrew"], {},
     "Also known as 'Pedophile Island.'"),
    ("mar_a_lago", "Mar-a-Lago", ["Property"], "political", 69,
     "Trump's Palm Beach club — Epstein was a member",
     ["trump", "epstein", "maxwell"], {},
     "Epstein reportedly banned after incident with member's daughter."),
    ("dalton_school", "Dalton School", ["Organization"], "core", 42,
     "NYC prep school — Epstein taught here 1973-75",
     ["epstein", "donald_barr", "bill_barr"], {},
     "Donald Barr (AG Barr's father) hired Epstein despite no degree."),
    ("lolita_express", "Lolita Express", ["Aircraft"], "core", 16,
     "Epstein's Boeing 727 — flight logs are key evidence",
     ["epstein", "maxwell", "bill_clinton", "prince_andrew", "trump"], {},
     "N908JE. Flight logs document passengers."),
    ("mcc_manhattan", "Metropolitan Correctional Center", ["Property"], "doj", 4,
     "Federal jail where Epstein died August 10, 2019",
     ["epstein", "bill_barr"], {},
     "Cameras malfunctioned. Guards sleeping. Death ruled suicide."),
]


def quote_key(k):
    """Quote CUE keys that aren't valid identifiers (contain hyphens, start with digits, etc.)."""
    if any(c in k for c in "-./+") or k[0:1].isdigit():
        return f'"{k}"'
    return k


def format_struct_set(items):
    """Format a list/dict as CUE struct-as-set: {a: true, b: true}"""
    if not items:
        return "{}"
    if isinstance(items, dict):
        keys = list(items.keys())
    else:
        keys = list(items)
    inner = ", ".join(f"{quote_key(k)}: true" for k in keys)
    if len(inner) > 70:
        lines = "\n".join(f"\t\t\t{quote_key(k)}: true" for k in keys)
        return "{\n" + lines + "\n\t\t}"
    return "{" + inner + "}"


def format_type_set(types):
    """Format @type struct-as-set."""
    inner = ", ".join(f"{t}: true" for t in types)
    return "{" + inner + "}"


def generate_entity(cue_id, name, types, cluster, hits, role, connections, evidence, notes):
    """Generate a single CUE entity block."""
    lines = []
    lines.append(f"\t{cue_id}: {{")
    lines.append(f'\t\tname: "{name}"')
    lines.append(f'\t\t"@type": {format_type_set(types)}')
    lines.append(f'\t\tcluster: "{cluster}"')
    if hits > 0:
        lines.append(f"\t\tmention_count: {hits}")
    if role:
        lines.append(f'\t\trole: "{role}"')
    lines.append(f"\t\tconnections: {format_struct_set(connections)}")
    lines.append(f"\t\tevidence: {format_struct_set(evidence)}")
    if notes:
        # Escape quotes in notes
        safe_notes = notes.replace('"', '\\"')
        lines.append(f'\t\tnotes: "{safe_notes}"')
    lines.append("\t}")
    return "\n".join(lines)


def write_cue_file(filepath, header_comment, entities_data):
    """Write a CUE file with entity definitions."""
    lines = [header_comment, "package creeps", "", "entities: {", ""]

    for i, entity in enumerate(entities_data):
        lines.append(generate_entity(*entity))
        if i < len(entities_data) - 1:
            lines.append("")

    lines.append("}")
    lines.append("")

    with open(filepath, "w") as f:
        f.write("\n".join(lines))
    print(f"  wrote {filepath} ({len(entities_data)} entities)")


def main():
    entities_dir = ROOT / "entities"
    entities_dir.mkdir(exist_ok=True)

    print("Generating CUE entity files...\n")

    write_cue_file(
        entities_dir / "people.cue",
        "// People — all Person entities across all tiers.\n"
        "// Tier 1: 100+ corpus hits. Tier 2: 10-99. Tier 3: <10.\n"
        f"// Generated from DugganUSA API discovery ({len(PEOPLE)} entities).",
        PEOPLE,
    )

    write_cue_file(
        entities_dir / "organizations.cue",
        "// Organizations — companies, shell companies, foundations, law firms.\n"
        f"// Generated from DugganUSA API discovery ({len(ORGANIZATIONS)} entities).",
        ORGANIZATIONS,
    )

    write_cue_file(
        entities_dir / "financial_institutions.cue",
        "// Financial institutions — banks subpoenaed or involved.\n"
        f"// Generated from DugganUSA API discovery ({len(FINANCIAL_INSTITUTIONS)} entities).",
        FINANCIAL_INSTITUTIONS,
    )

    write_cue_file(
        entities_dir / "properties.cue",
        "// Properties, locations, and aircraft.\n"
        f"// Generated from DugganUSA API discovery ({len(PROPERTIES)} entities).",
        PROPERTIES,
    )

    total = len(PEOPLE) + len(ORGANIZATIONS) + len(FINANCIAL_INSTITUTIONS) + len(PROPERTIES)
    print(f"\nTotal: {total} entities across 4 files.")


if __name__ == "__main__":
    main()
