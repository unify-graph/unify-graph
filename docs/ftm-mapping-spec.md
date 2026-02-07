# FtM Mapping Specification: unify-graph CUE → FollowTheMoney

**Target Format:** JSONL (one entity per line)
**Output File:** `entities.ftm.json`
**Import Command:** `alephclient write-entities --infile entities.ftm.json --foreign-id epstein-network-unify`

## Field Mapping Reference

### CUE Entity → FtM Person/Company

| CUE Field | FtM Field | FtM Property | Notes |
|-----------|-----------|--------------|-------|
| `id` | `id` | — | Use as-is |
| `name` | — | `name` | Array: `[name]` |
| `@type` | `schema` | — | Map via lookup table (see below) |
| `role` | — | `position` (Person) or `notes` | Contextual |
| `cluster` | — | `topics` or `notes` | No direct FtM field; add to notes |
| `mention_count` | — | `notes` | Append to notes |
| `notes` | — | `notes` | Combine with other metadata |
| `first_appearance` | — | `birthDate` (Person) or `incorporationDate` (Company) | If formatted as date |
| `external_ids.wikidata` | — | `wikidataId` | Direct mapping |
| `external_ids.opencorporates` | — | `opencorporatesId` | Direct mapping |
| `connections` | — | — | Generate separate relationship entities |
| `evidence` | — | — | Generate Document entities, reference in `notes` |

### CUE Flow → FtM Payment

| CUE Field | FtM Field | FtM Property | Notes |
|-----------|-----------|--------------|-------|
| `id` | `id` | — | Prefix with `flow-` |
| `source` | — | `payer` | Array: `[source]` |
| `destination` | — | `beneficiary` | Array: `[destination]` |
| `amount` | — | `amount` | Array: `[amount]` |
| `currency` | — | `currency` | Array: `[currency]` (default "USD") |
| `date` | — | `date` | Array: `[date]` |
| `period` | — | `startDate` + `endDate` | Parse period string |
| `flow_type` | — | `purpose` | Map to description |
| `notes` | — | `notes` | Combine with purpose |
| `evidence` | — | — | Reference in `notes` |

### CUE Document → FtM Document

| CUE Field | FtM Field | FtM Property | Notes |
|-----------|-----------|--------------|-------|
| `doc_id` | `id` | — | Use as-is |
| `description` | — | `title` | Primary label |
| `doc_type` | — | `keywords` | Add as keyword |
| `source` | — | `publisher` | If available |
| `date` | — | `date` | Array: `[date]` |
| `summary` | — | `summary` | Direct mapping |
| `bates_range` | — | `notes` | Include in notes |
| `mentions` | — | `entities` | Array of entity IDs |

## Schema Mapping Table

### Entity @type → FtM Schema

```json
{
  "Person": "Person",
  "Organization": "Organization",
  "ShellCompany": "Company",
  "LawFirm": "Company",
  "FinancialInstitution": "Company",
  "HedgeFund": "Company",
  "InvestmentFirm": "Company",
  "ModelingAgency": "Company",
  "Foundation": "Organization",
  "Property": "RealEstate",
  "Aircraft": "Airplane"
}
```

**Priority Logic**: If entity has multiple types, use this priority:
1. `Property` → `RealEstate`
2. `Aircraft` → `Airplane`
3. `Person` → `Person`
4. `Foundation` → `Organization`
5. `ShellCompany`, `LawFirm`, etc. → `Company`
6. Default → `LegalEntity` (if unclear)

### Connection rel_type → FtM Schema

```json
{
  "financial": "Payment",
  "familial": "Family",
  "professional": "UnknownLink",
  "social": "UnknownLink",
  "legal": "UnknownLink",
  "employer": "Directorship",
  "client": "UnknownLink",
  "associate": "UnknownLink",
  "alleged": "UnknownLink"
}
```

**Special Cases**:
- If `rel_type: "financial"` AND amount known → `Payment`
- If `rel_type: "financial"` AND no amount → `Ownership` (if ownership %) or `UnknownLink`
- If `rel_type: "employer"` AND connection_details contains org → `Directorship`

## Conversion Algorithm

### Step 1: Convert Entities

For each entity in `entities`:

```python
def convert_entity(eid, entity, graph_data):
    # Determine FtM schema
    schema = determine_schema(entity["@type"])

    # Base structure
    ftm = {
        "id": eid,
        "schema": schema,
        "datasets": ["epstein-network-unify"],
        "first_seen": datetime.utcnow().isoformat() + "+00:00",
        "last_change": datetime.utcnow().isoformat() + "+00:00",
        "properties": {}
    }

    # Add name
    ftm["properties"]["name"] = [entity["name"]]

    # Add notes (combine multiple sources)
    notes_parts = []
    if "role" in entity:
        notes_parts.append(f"Role: {entity['role']}")
    if "cluster" in entity:
        notes_parts.append(f"Cluster: {entity['cluster']}")
    if "mention_count" in entity:
        notes_parts.append(f"Mentions: {entity['mention_count']}")
    if "notes" in entity:
        notes_parts.append(entity["notes"])

    if notes_parts:
        ftm["properties"]["notes"] = [" | ".join(notes_parts)]

    # Add external IDs
    if "external_ids" in entity:
        if "wikidata" in entity["external_ids"]:
            ftm["properties"]["wikidataId"] = [entity["external_ids"]["wikidata"]]
        if "opencorporates" in entity["external_ids"]:
            ftm["properties"]["opencorporatesId"] = [entity["external_ids"]["opencorporates"]]

    # Schema-specific properties
    if schema == "Person":
        # Add position from types
        positions = []
        for t in ["Politician", "Prosecutor", "FinancialEnabler"]:
            if t in entity["@type"]:
                positions.append(t)
        if positions or "role" in entity:
            ftm["properties"]["position"] = positions + ([entity["role"]] if "role" in entity else [])

    elif schema in ["Company", "Organization"]:
        # Add sector/keywords from types
        if "LawFirm" in entity["@type"]:
            ftm["properties"]["sector"] = ["Legal Services"]
        elif "FinancialInstitution" in entity["@type"]:
            ftm["properties"]["sector"] = ["Financial Services"]
        elif "HedgeFund" in entity["@type"]:
            ftm["properties"]["sector"] = ["Hedge Fund"]

    elif schema == "RealEstate":
        # Use name as address if no structured address
        ftm["properties"]["address"] = [entity["name"]]

    elif schema == "Airplane":
        # Try to extract registration number from name/notes
        if "N-number" in entity.get("notes", ""):
            # Parse registration
            pass

    return ftm
```

### Step 2: Convert Connections

For each connection in entity.connections:

```python
def convert_connection(source_id, target_id, connection_detail, evidence_map):
    # Determine relationship type
    rel_type = connection_detail.get("rel_type", "unknown")
    confidence = connection_detail.get("confidence", "unassessed")

    # Map to FtM schema
    schema = REL_TYPE_MAP.get(rel_type, "UnknownLink")

    # Generate ID
    conn_id = f"conn-{source_id}-{target_id}"

    ftm = {
        "id": conn_id,
        "schema": schema,
        "datasets": ["epstein-network-unify"],
        "first_seen": datetime.utcnow().isoformat() + "+00:00",
        "last_change": datetime.utcnow().isoformat() + "+00:00",
        "properties": {}
    }

    # Schema-specific properties
    if schema == "UnknownLink":
        ftm["properties"]["subject"] = [source_id]
        ftm["properties"]["object"] = [target_id]
        ftm["properties"]["role"] = [rel_type]

    elif schema == "Family":
        ftm["properties"]["person"] = [source_id]
        ftm["properties"]["relative"] = [target_id]
        ftm["properties"]["relationship"] = [rel_type]

    elif schema == "Directorship":
        ftm["properties"]["director"] = [source_id]
        ftm["properties"]["organization"] = [target_id]
        if "role" in connection_detail:
            ftm["properties"]["role"] = [connection_detail["role"]]

    # Add period
    if "period" in connection_detail:
        period = connection_detail["period"]
        # Parse "2000-2015" → startDate: "2000", endDate: "2015"
        if "-" in period:
            start, end = period.split("-")
            ftm["properties"]["startDate"] = [start.strip()]
            ftm["properties"]["endDate"] = [end.strip()]

    # Add notes (include confidence)
    notes_parts = []
    notes_parts.append(f"Confidence: {confidence}")
    if "notes" in connection_detail:
        notes_parts.append(connection_detail["notes"])
    if "evidence" in connection_detail:
        evidence_ids = list(connection_detail["evidence"].keys())
        notes_parts.append(f"Evidence: {', '.join(evidence_ids)}")

    ftm["properties"]["notes"] = [" | ".join(notes_parts)]

    return ftm
```

### Step 3: Convert Flows

For each flow in `flows`:

```python
def convert_flow(flow_id, flow):
    ftm = {
        "id": f"flow-{flow_id}",
        "schema": "Payment",
        "datasets": ["epstein-network-unify"],
        "first_seen": datetime.utcnow().isoformat() + "+00:00",
        "last_change": datetime.utcnow().isoformat() + "+00:00",
        "properties": {
            "payer": [flow["source"]],
            "beneficiary": [flow["destination"]],
            "amount": [flow["amount"]],
            "currency": [flow.get("currency", "USD")]
        }
    }

    # Add date or period
    if "date" in flow:
        ftm["properties"]["date"] = [flow["date"]]
    elif "period" in flow:
        # Use period start as date
        start = flow["period"].split("-")[0].strip()
        ftm["properties"]["date"] = [start]

    # Add purpose
    purpose_parts = []
    if "flow_type" in flow:
        purpose_parts.append(flow["flow_type"])
    if "notes" in flow:
        purpose_parts.append(flow["notes"])

    if purpose_parts:
        ftm["properties"]["purpose"] = [" - ".join(purpose_parts)]

    # Add evidence to notes
    if "evidence" in flow:
        evidence_ids = list(flow["evidence"].keys())
        notes = f"Evidence: {', '.join(evidence_ids)}"
        if "notes" in ftm["properties"]:
            ftm["properties"]["notes"][0] += f" | {notes}"
        else:
            ftm["properties"]["notes"] = [notes]

    return ftm
```

### Step 4: Convert Documents

For each document in `documents`:

```python
def convert_document(doc_id, doc):
    ftm = {
        "id": doc_id,
        "schema": "Document",
        "datasets": ["epstein-network-unify"],
        "first_seen": datetime.utcnow().isoformat() + "+00:00",
        "last_change": datetime.utcnow().isoformat() + "+00:00",
        "properties": {
            "title": [doc["description"]]
        }
    }

    # Add keywords (doc_type)
    if "doc_type" in doc:
        ftm["properties"]["keywords"] = [doc["doc_type"]]

    # Add date
    if "date" in doc:
        ftm["properties"]["date"] = [doc["date"]]

    # Add summary
    if "summary" in doc:
        ftm["properties"]["summary"] = [doc["summary"]]

    # Add publisher
    if "source" in doc:
        ftm["properties"]["publisher"] = [doc["source"]]

    # Add notes (Bates range, etc.)
    notes_parts = []
    if "bates_range" in doc:
        notes_parts.append(f"Bates: {doc['bates_range']}")
    if notes_parts:
        ftm["properties"]["notes"] = [" | ".join(notes_parts)]

    # Add entity references
    if "mentions" in doc:
        entity_ids = list(doc["mentions"].keys())
        ftm["properties"]["entities"] = entity_ids

    return ftm
```

## Output Format

### JSONL Structure

Each line is a complete JSON object:

```jsonl
{"id":"epstein","schema":"Person","datasets":["epstein-network-unify"],"first_seen":"2026-02-07T12:00:00+00:00","last_change":"2026-02-07T12:00:00+00:00","properties":{"name":["Jeffrey Epstein"],"wikidataId":["Q2904131"],"position":["Central node"],"notes":["Role: Central node — convicted sex trafficker | Cluster: core | Mentions: 31363"]}}
{"id":"flow-black_to_epstein","schema":"Payment","datasets":["epstein-network-unify"],"first_seen":"2026-02-07T12:00:00+00:00","last_change":"2026-02-07T12:00:00+00:00","properties":{"payer":["leon_black"],"beneficiary":["epstein"],"amount":["$158M+"],"currency":["USD"],"date":["2000"],"purpose":["payment - $158M+ over ~15 years. For what services?"]}}
{"id":"conn-epstein-maxwell","schema":"UnknownLink","datasets":["epstein-network-unify"],"first_seen":"2026-02-07T12:00:00+00:00","last_change":"2026-02-07T12:00:00+00:00","properties":{"subject":["epstein"],"object":["maxwell"],"role":["professional"],"notes":["Confidence: high | Primary co-conspirator. Convicted of trafficking conspiracy."]}}
```

## Implementation Script

See `scripts/export_ftm.py` for complete implementation.

### Usage

```bash
# Export CUE graph to JSON
cue export -e graph ./... > /tmp/graph.json

# Convert to FtM JSONL
python3 scripts/export_ftm.py /tmp/graph.json entities.ftm.json

# Validate
ftm validate entities.ftm.json

# Import to Aleph
alephclient write-entities \
  --infile entities.ftm.json \
  --foreign-id epstein-network-unify
```

## Validation Checklist

- [ ] All entity IDs are unique
- [ ] All entity references resolve (no dangling IDs)
- [ ] All schema names are valid FtM schemas
- [ ] All property names match schema definitions
- [ ] All property values are arrays of strings
- [ ] Timestamps are ISO 8601 format with timezone
- [ ] Country codes are valid ISO 3166-1 alpha-2
- [ ] Currency codes are valid ISO 4217
- [ ] Dates are valid (YYYY, YYYY-MM, or YYYY-MM-DD)
- [ ] Wikidata IDs start with "Q" followed by digits
- [ ] JSONL format (one entity per line, no pretty-printing)

## Known Limitations

1. **Confidence Scores**: FtM has no native confidence field. We encode in `notes`.
2. **Multi-Type Entities**: FtM requires single schema. We choose most specific type.
3. **Cluster Metadata**: FtM has no cluster concept. We add to `notes` or use `topics`.
4. **Evidence Links**: FtM documents can reference entities, but not vice versa. We add evidence IDs to `notes`.
5. **Mention Counts**: No FtM equivalent. Add to `notes`.
6. **Connection Symmetry**: CUE tracks bidirectional separately; FtM relationships are directional. Create two relationship entities if truly symmetric.

## Future Enhancements

1. **FtM Statements API**: For provenance and confidence metadata
2. **Custom FtM Schema**: Extend with `EpsteinNetworkEntity` schema
3. **Aleph Xref**: Use Aleph's cross-referencing API for entity matching
4. **Entity Reconciliation**: Use FtM matching API to deduplicate entities
5. **Bulk Update**: Implement incremental updates (track last_change)

---

**Next Steps:**
1. Implement `scripts/export_ftm.py` using this specification
2. Test with small subset (10-20 entities)
3. Validate against FtM schema
4. Import to Aleph test instance
5. Verify graph visualization in Aleph
6. Iterate on property mapping based on Aleph results
