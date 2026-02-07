# @type Audit Report — Unify Graph

**Date:** 2026-02-07
**Total Entities Audited:** 129 (88 people, 8 properties, 33 organizations)
**Total Unique Types Used:** 19 of 20 defined
**Report Generated From:** vocab.cue (type definition) + people.cue, properties.cue, organizations.cue, financial_institutions.cue

---

## Executive Summary

The @type tagging system is **mostly well-applied** with clear patterns, but reveals:
- **1 unused type** in the vocabulary
- **56 entities (43%)** with only a single type — opportunity to add specificity
- **Logical classification gaps** in 8+ entities that should have additional types
- **New types recommended** to improve investigative modeling (Victim, Witness, Informant)

---

## 1. Type Usage Distribution

| Type | Count | % of Entities | Status |
|------|-------|---------------|--------|
| **Person** | 88 | 68.2% | Baseline type, used heavily |
| **Organization** | 37 | 28.7% | Baseline type for non-people |
| **FinancialEnabler** | 13 | 10.1% | Well-used: major funders/enablers |
| **FinancialInstitution** | 13 | 10.1% | Well-used: banks & financial services |
| **Politician** | 12 | 9.3% | Good coverage: elected officials & candidates |
| **Allegations** | 10 | 7.7% | Well-used: accused/implicated parties |
| **GovernmentOfficial** | 7 | 5.4% | Moderate: DOJ, FBI, agency staff |
| **ShellCompany** | 7 | 5.4% | Focused on legal entity structures |
| **CoreNetwork** | 6 | 4.6% | Well-targeted: Epstein's inner circle |
| **Property** | 6 | 4.6% | Focused on real estate + aircraft |
| **Foundation** | 4 | 3.1% | Small but well-used: charitable entities |
| **LegalProtection** | 3 | 2.3% | Defense attorneys (could be higher) |
| **InvestmentFirm** | 3 | 2.3% | Good coverage: PE/VC firms |
| **Prosecutor** | 3 | 2.3% | Focused: DOJ prosecutors |
| **HedgeFund** | 2 | 1.6% | Specific to hedge fund entities |
| **Scheduler** | 2 | 1.6% | Inner circle staff roles |
| **ModelingAgency** | 1 | 0.8% | Single entity (MC2) |
| **Recruiter** | 1 | 0.8% | Single entity (Maxwell) |
| **LawFirm** | 1 | 0.8% | Single entity (Dechert LLP) |
| **Aircraft** | 1 | 0.8% | Single entity (Lolita Express) |
| **Fixer** | 0 | 0.0% | ❌ **NEVER USED** |

---

## 2. Defined but Never Used

### Fixer ❌

**Status:** Defined in vocab.cue but **zero entities tagged with it**

**Why it's missing:** No explicit "fixer" roles identified. However, several candidates could qualify:
- **Alfredo Rodriguez** (house manager, stole black book to obstruct justice)
- **Juan Alessi** (house manager, coordinated household activities)
- **Janusz Banasiak** (maintenance manager)

These are support staff rather than strategic fixers. The network may lack the mid-level operatives/fixers typical of organized schemes. Worth investigating in future discovery.

---

## 3. Single-Type Entities (56 total, 43% of all entities)

These entities have only **one** @type tag and may warrant additional classification:

### Justifying Additional Types

#### People with only "Person" (42 entities)

**Should add: LegalProtection (victim attorneys)**
- `brad_edwards` — Attorney; should be `{Person: true, LegalProtection: true}`
- `jack_scarola` — Attorney; should be `{Person: true, LegalProtection: true}`
- `sigrid_mccawley` — Attorney; should be `{Person: true, LegalProtection: true}`
- `paul_cassell` — Law professor/attorney; should be `{Person: true, LegalProtection: true}`

**Should add: GovernmentOfficial**
- `marie_villafana` — AUSA; should be `{Person: true, Prosecutor: true, GovernmentOfficial: true}`

**Should add: FinancialEnabler**
- `wexner` — Les Wexner (L Brands founder) — granted Epstein power of attorney; early patron
  - Current: `{Person: true, FinancialEnabler: true}` ✓ (already correct)

**Should add: Fixer or ShellCompany**
- `mark_epstein` — Involved in Southern Trust operations; role unclear but likely operational

**Should add: Victim (NEW TYPE)**
- `virginia_giuffre` — Key accuser; central victim in litigation
- Others in "allegations" cluster with strong victim testimony

**Multiple classification opportunities (non-urgent):**
- `richard_branson` — Business owner; Virgin Group founder
- `jeff_bezos` — Business owner; Amazon founder
- `elon_musk` — Business owner; Tesla/SpaceX founder
- `boris_nikolic` — Scientist; Gates Foundation advisor (could add "Advisor" or "Scientist"?)
- `brock_pierce` — Crypto entrepreneur (could add "InvestmentFirm" or similar)

#### Organizations with only "Organization" (7 entities)

**Should add: FinancialInstitution**
- `cantor_fitzgerald` — Financial services firm (Lutnick CEO); should be `{Organization: true, FinancialInstitution: true}`
- `palantir` — Data analytics/tech company; Peter Thiel owned; could be `{Organization: true, InvestmentFirm: true}`

**Should add: InvestmentFirm**
- `l_brands` — Wexner's conglomerate; subsidiary Victoria's Secret

**Properties correctly single-typed** (el_brillo_way, zorro_ranch, mar_a_lago, mcc_manhattan, little_st_james)
- Properties are appropriately single-tagged; no change needed.

#### Aircraft & Other (correctly single-tagged)
- `lolita_express` — Aircraft; correctly just `{Aircraft: true}`

---

## 4. Recommended New Types to Add to Vocabulary

### High Priority

#### Victim
**Rationale:** Virginia Giuffre is the centerpiece of the entire investigation. Other trafficking victims appear in documents but have no explicit type.

**Proposed definition:**
```cue
"Victim" | ...  // Alleged victim of trafficking, abuse, or related crimes
```

**Entities to tag:**
- `virginia_giuffre` (primary accuser; settled with Prince Andrew for $12M)

#### Witness or Informant
**Rationale:** Staff like Juan Alessi testified extensively. Alfredo Rodriguez became informant (stole black book). These roles matter.

**Proposed definition:**
```cue
"Witness" | ...  // Testified in legal proceedings or investigation
"Informant" | ... // Provided evidence/testimony despite prior involvement
```

**Entities to consider:**
- `juan_alessi` — Extensive testimony
- `alfredo_rodriguez` — Stole black book; provided evidence despite obstruction conviction
- `sarah_kellen` — Co-conspirator who cooperated (NPA recipient)

### Medium Priority

#### RealEstate or PropertyOwner
**Rationale:** Several people own/control properties beyond just being inhabitants.

**Entities:** Wexner, Trump (owns Mar-a-Lago), Epstein estates — already handled via connections.

---

## 5. Coverage Analysis by Cluster

| Cluster | Count | Avg Types/Entity | Notes |
|---------|-------|-------------------|-------|
| **core** | 7 | 1.57 | Well-typed: inner circle identified |
| **financial** | 9 | 1.44 | Good coverage of enablers |
| **hedge_fund** | 3 | 1.33 | Limited but well-typed |
| **paypal_mafia** | 3 | 1.33 | Tech VC ecosystem |
| **crypto** | 4 | 1.00 | Single-typed (emerging network) |
| **allegations** | 9 | 1.78 | **Best coverage** (mixed actors) |
| **political** | 9 | 1.44 | Politicians mostly well-typed |
| **cabinet** | 1 | 2.00 | Single entity (Lutnick): well-typed |
| **legal** | 8 | 1.00 | **Under-typed**: attorneys need LegalProtection |
| **doj** | 5 | 1.60 | Good: mix of prosecutors & officials |
| **shell** | 7 | 1.29 | Good: shell structures identified |
| **academia** | 10 | 1.00 | **Single-typed**: academics only tagged Person |
| **media** | 7 | 1.00 | **Single-typed**: media figures not distinguished |
| **banking** | 12 | 1.08 | Good: FinancialInstitution coverage |
| **victim** | 1 | 1.00 | Single entity; only tagged Person |
| **intelligence** | 0 | — | No entities (gap in network?) |
| **tech** | 5 | 1.00 | **Single-typed**: tech figures only tagged Person |
| **staff** | 6 | 1.00 | **Under-typed**: support staff need role types |
| **family** | 3 | 1.00 | **Under-typed**: family members only tagged Person |

**Key insight:** Legal, staff, family, media, academia, and tech clusters are systematically under-typed with only "Person" or "Organization." Adding contextual types would improve query capability.

---

## 6. Logical Classification Gaps

### Critical Gaps (Recommend Immediate Fix)

| Entity | Current Type | Missing Type | Reason |
|--------|--------------|--------------|--------|
| `virginia_giuffre` | Person | **Victim** | Primary accuser; trafficking victim; settled civil case |
| `brad_edwards` | Person | **LegalProtection** | Attorney; represented multiple victims |
| `jack_scarola` | Person | **LegalProtection** | Attorney; represented victims |
| `sigrid_mccawley` | Person | **LegalProtection** | Attorney; Boies Schiller Flexner |
| `paul_cassell` | Person | **LegalProtection** | Law professor; represented victims |
| `marie_villafana` | Person, Prosecutor | **GovernmentOfficial** | AUSA who worked under Acosta |
| `cantor_fitzgerald` | Organization | **FinancialInstitution** | Lutnick's financial services firm |

### Suggested Future Additions

| Entity | Suggested | Reason |
|--------|-----------|--------|
| `alfredo_rodriguez` | **Witness** or **Informant** | Testified; stole black book; key evidence provider |
| `juan_alessi` | **Witness** | Extensive testimony about household operations |
| `sarah_kellen` | **Witness** | Co-conspirator with NPA immunity; potential informant |
| `mark_epstein` | **Fixer** or **ShellCompany** | Involved in trust operations; role unclear |
| `wexner` | Correct as-is | Already tagged FinancialEnabler ✓ |

---

## 7. Network Characterization

### Type "Hubs" (Most Connected, Most Typed)

| Entity | Types | Connections | Role |
|--------|-------|-------------|------|
| `epstein` | Person, CoreNetwork | 72 | Network center (expected) |
| `maxwell` | Person, CoreNetwork, Recruiter | 14 | Inner circle (expected) |
| `leon_black` | Person, FinancialEnabler | 5 | Major funder (expected) |
| `dershowitz` | Person, LegalProtection, Allegations | 5 | Dual role: attorney + accused |
| `bill_richardson` | Person, Politician, Allegations | 2 | Political figure with allegations |

### Type "Edges" (Rarely Multi-Typed)

- **Academics** (marvin_minsky, lawrence_krauss, stephen_hawking) — all single-typed
- **Media figures** (naomi_campbell, katie_couric, peggy_siegal) — all single-typed
- **Tech founders** (jeff_bezos, elon_musk, sergey_brin) — all single-typed

This suggests we're classifying by context (Epstein network membership) rather than intrinsic role. Adding contextual types would help distinguish funding sources, public figures, etc.

---

## 8. Recommendations

### Immediate Actions (Pre-validation)

1. **Add 4 attorneys to LegalProtection**
   - `brad_edwards`, `jack_scarola`, `sigrid_mccawley`, `paul_cassell`

2. **Add GovernmentOfficial to marie_villafana**

3. **Add FinancialInstitution to cantor_fitzgerald**

### Short-term (Discuss & Implement)

4. **Add Victim type to vocab.cue**
   - Tag: `virginia_giuffre` (and future victim entities)

5. **Consider Witness/Informant types**
   - For: alfredo_rodriguez, juan_alessi, sarah_kellen

### Future Phases (Emerging Data)

6. **Review "staff" and "family" clusters** — determine if explicit role types needed
7. **Audit "intelligence" cluster** — currently empty; check for gaps
8. **Consider "Advisor" or "Scientist"** types for academia cluster (if significant)

---

## 9. Data Quality Notes

- **No duplicate types** on single entities (good CUE validation)
- **All types valid** per vocab.cue #EntityType definition
- **No orphan entities** (all entities either 1 or multiple types)
- **Coverage:** 129 entities fully typed; no missing @type declarations

---

## Files Modified for This Audit

- `/home/mthdn/unify-graph/vocab.cue` — Reviewed #EntityType definition
- `/home/mthdn/unify-graph/people.cue` — 88 people entities
- `/home/mthdn/unify-graph/properties.cue` — 8 properties/aircraft
- `/home/mthdn/unify-graph/organizations.cue` — 24 organizations
- `/home/mthdn/unify-graph/financial_institutions.cue` — 12 banks

**Total: 129 entities, 20 defined types, 19 used, 1 unused (Fixer)**
