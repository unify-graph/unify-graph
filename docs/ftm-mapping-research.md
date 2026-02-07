# FollowTheMoney (FtM) Data Model Research

**Research Date:** 2026-02-07
**Purpose:** Map unify-graph CUE entities to FtM format for OCCRP Aleph ingestion

## Overview

FollowTheMoney (FtM) is a data model for financial crime investigations and document forensics developed by OCCRP. It defines a graph data model for anti-money-laundering analysis with entities expressed as JSON objects.

## FtM Entity Structure

### Core Fields

Every FtM entity is a JSON object with these fields:

```json
{
  "id": "unique-entity-identifier",
  "schema": "EntityTypeName",
  "caption": "User-facing label",
  "datasets": ["dataset-name"],
  "referents": ["external-id-1", "external-id-2"],
  "first_seen": "2025-08-22T10:15:20+00:00",
  "last_change": "2025-08-22T10:15:20+00:00",
  "properties": {
    "propertyName": ["value1", "value2"]
  }
}
```

**Key characteristics:**
- `id`: Unique identifier (string)
- `schema`: Entity type name (e.g., "Person", "Company", "Ownership")
- `caption`: Auto-computed user-facing label from properties
- `datasets`: Array of dataset names this entity belongs to
- `referents`: Array of external identifiers for reconciliation
- `first_seen`/`last_change`: ISO 8601 timestamps (UTC)
- `properties`: All properties are **multi-valued arrays of strings**

### File Format

**JSONL (JSON Lines)** — one entity per line, no indentation:

```
{"id":"1","schema":"Person","properties":{"name":["John Doe"]}}
{"id":"2","schema":"Company","properties":{"name":["Acme Corp"]}}
```

File extensions: `.ftm` or `.ijson`

## FtM Schema Types

### Primary Entity Types

#### Person
- **Description**: Individual human being
- **Key Properties**:
  - `name` (array of strings)
  - `alias` (array of strings)
  - `birthDate` (array of date strings, e.g., "1982")
  - `nationality` (array of country codes, e.g., "us", "au")
  - `birthPlace` (text)
  - `deathDate`
  - `gender`
  - `position` (job titles)
  - `email`
  - `phone`
  - `passportNumber`
  - `idNumber`
  - `notes`
  - `wikidataId` (Wikidata QID)

#### Company
- **Description**: For-profit corporation (public or private), including trusts and funds
- **Key Properties**:
  - `name`
  - `alias`
  - `jurisdiction` (country code)
  - `registrationNumber`
  - `incorporationDate`
  - `dissolutionDate`
  - `address`
  - `phone`
  - `email`
  - `sector` (industry)
  - `notes`
  - `wikidataId`
- **Note**: Companies are assets, so they can be owned by other legal entities

#### Organization
- **Description**: Non-profit or state-owned entity that cannot be owned (charities, foundations, SOEs)
- **Key Properties**: Similar to Company but cannot be the `asset` in an Ownership relationship
- **Examples**: Foundations, charities, state-owned enterprises (depending on jurisdiction)

#### LegalEntity
- **Description**: Generic entity when it's unclear if something is a Person or Company
- **Usage**: Use when raw data doesn't specify entity type
- **Note**: Matchable schema for cross-referencing

### Asset Types

#### RealEstate
- **Description**: Property, real estate
- **Key Properties**:
  - `address`
  - `addressEntity` (reference to Address entity)
  - `country`
  - `type` (residential, commercial, etc.)
  - `area`
  - `owner` (reference to LegalEntity)
  - `notes`

#### Airplane
- **Description**: Aircraft, helicopter, or flying vehicle
- **Key Properties**:
  - `registrationNumber`
  - `model`
  - `serialNumber`
  - `buildDate`
  - `owner` (reference to LegalEntity)
  - `operator`
  - `notes`

#### Vessel
- **Description**: Boat or ship
- **Key Properties**:
  - `name`
  - `flag` (country)
  - `imo` (IMO number)
  - `callSign`
  - `type`
  - `owner`
  - `operator`
  - `notes`

#### Asset
- **Description**: Generic asset (parent schema for specific asset types)
- **Note**: Use specific types (RealEstate, Airplane, Vessel) when possible

### Relationship Types (Interval Schemas)

Relationships are **separate entities** with their own IDs and schemas. They reference other entities via properties.

#### Ownership
- **Description**: Ownership relationship between legal entities
- **Key Properties**:
  - `owner` (entity ID of Person/Company/LegalEntity)
  - `asset` (entity ID of Company/Asset)
  - `percentage` (ownership stake as string, e.g., "51%")
  - `startDate`
  - `endDate`
  - `role` (e.g., "shareholder", "beneficial owner")
  - `notes`

#### Payment
- **Description**: Financial transaction
- **Key Properties**:
  - `payer` (entity ID)
  - `beneficiary` (entity ID)
  - `amount` (string with currency symbol or number)
  - `currency` (currency code, e.g., "USD")
  - `date`
  - `purpose` (description)
  - `notes`

#### Directorship
- **Description**: Person serving as director/officer of an organization
- **Key Properties**:
  - `director` (Person entity ID)
  - `organization` (Company/Organization entity ID)
  - `role` (e.g., "CEO", "Board Member")
  - `startDate`
  - `endDate`
  - `notes`

#### Family
- **Description**: Family relationship between two persons
- **Key Properties**:
  - `person` (entity ID)
  - `relative` (entity ID)
  - `relationship` (e.g., "spouse", "child", "sibling")
  - `startDate`
  - `endDate`

#### UnknownLink
- **Description**: Generic link for undefined relationships
- **Key Properties**:
  - `subject` (entity ID)
  - `object` (entity ID)
  - `role` (description of relationship)
  - `startDate`
  - `endDate`
  - `notes`

### Document Type

#### Document
- **Description**: Evidence files, court documents, etc.
- **Key Properties**:
  - `title`
  - `fileName`
  - `fileSize`
  - `mimeType`
  - `date`
  - `author`
  - `publisher`
  - `summary`
  - `keywords`
  - `entities` (references to related entities)

## Key Concepts

### Multi-Valued Properties
All property values are **arrays of strings**, even for single values:
```json
"properties": {
  "name": ["John Doe"],
  "nationality": ["us", "gb"]
}
```

### Entity References
Relationships reference entities by ID in properties:
```json
{
  "id": "ownership-1",
  "schema": "Ownership",
  "properties": {
    "owner": ["person-123"],
    "asset": ["company-456"],
    "percentage": ["51"]
  }
}
```

### Edge Representation
Some schemas (Ownership, Directorship, Payment, Family, UnknownLink) can be represented as **edges** in a graph, with:
- **source**: determined by schema annotation (e.g., `owner` in Ownership)
- **target**: determined by schema annotation (e.g., `asset` in Ownership)

**Important**: Don't assume all Interval-derived entities are edges. Check schema annotations.

### External Identifiers
FtM supports external ID properties for reconciliation:
- `wikidataId`: Wikidata QID (e.g., "Q5284" for Bill Gates)
- `opencorporatesId`
- Other domain-specific identifiers

**Note**: Use `referents` field for tracking external system IDs (not Wikidata QIDs).

## Aleph Ingestion

### Import Method
Use `alephclient` (Python CLI tool):

```bash
alephclient write-entities \
  --infile entities.ftm.json \
  --foreign-id my-dataset-name
```

- `--infile`: Path to JSONL file (`.ftm.json`)
- `--foreign-id`: Dataset identifier (creates collection if doesn't exist)

### Data Processing
1. Entities are validated against FtM schema
2. Properties are normalized (dates, country codes, etc.)
3. Entities are indexed in Aleph for search
4. Graph relationships are computed for visualization

## Mapping Strategy: CUE → FtM

### Entity Type Mapping

| CUE `@type` | FtM Schema | Notes |
|-------------|------------|-------|
| `Person` | `Person` | Direct mapping |
| `Organization` | `Organization` or `Company` | Use `Company` if for-profit/ownable |
| `ShellCompany` | `Company` | Add `notes` indicating shell status |
| `LawFirm` | `Company` | Set `sector` property |
| `FinancialInstitution` | `Company` | Set `sector` property |
| `HedgeFund`, `InvestmentFirm` | `Company` | Set `sector` property |
| `ModelingAgency` | `Company` | Set `sector` property |
| `Foundation` | `Organization` | Non-ownable |
| `Property` | `RealEstate` | Asset type |
| `Aircraft` | `Airplane` | Asset type |

### Role → Schema Mapping

CUE roles (FinancialEnabler, Politician, etc.) should map to:
- Keep primary `@type` → FtM schema
- Add role as `position` or `notes` property
- Create **UnknownLink** entities for role relationships

### Connection Mapping

CUE `connections` (simple struct-as-set) → FtM:
- If connection has `connection_details.rel_type`:
  - `"financial"` → `Payment` (if amount known) or `Ownership`
  - `"professional"` → `UnknownLink` with `role`
  - `"familial"` → `Family`
  - `"legal"` → `UnknownLink` (or `Representation` if lawyer-client)
  - `"employer"` → `Directorship` or `UnknownLink`
- If no details: → `UnknownLink`

### Evidence Mapping

CUE `evidence` (document IDs) → FtM:
- Create `Document` entities for each document
- Reference entity IDs in `Document.properties.entities`
- Store doc metadata (EFTA releases, court filings, etc.)

### Financial Flows

CUE `#Flow` → FtM `Payment`:
```json
{
  "id": "flow-{flow_id}",
  "schema": "Payment",
  "datasets": ["epstein-network"],
  "properties": {
    "payer": ["{source_entity_id}"],
    "beneficiary": ["{destination_entity_id}"],
    "amount": ["{amount}"],
    "currency": ["USD"],
    "date": ["{date}"],
    "purpose": ["{notes}"]
  }
}
```

### Confidence Scores

CUE `connection_details.confidence` → FtM:
- No native confidence property in FtM core schemas
- Options:
  1. Add to `notes` field (e.g., "Confidence: high")
  2. Use custom dataset-level metadata
  3. Implement via FtM Statements API (advanced)

### External IDs

CUE `external_ids.wikidata` → FtM `wikidataId` property:
```json
"properties": {
  "wikidataId": ["Q5284"]
}
```

### Datasets Field

Set consistent dataset identifier:
```json
"datasets": ["epstein-network-unify-graph"]
```

### Timestamps

CUE tracks modeling dates; FtM tracks observation dates:
- `first_seen`: When we first observed this entity (current date if unknown)
- `last_change`: When entity data last changed (current date)

## Implementation Options

### Option 1: CUE Export Expression

Add to `exports.cue`:
```cue
ftm: {
  entities: [
    // Map CUE entities to FtM format
    for _ename, _e in entities {
      id: _ename
      schema: _ftmSchema(_e."@type")
      datasets: ["epstein-network"]
      properties: {
        name: [_e.name]
        // ... map other properties
        if _e.external_ids.wikidata != _|_ {
          wikidataId: [_e.external_ids.wikidata]
        }
      }
    },
    // Map flows to Payment entities
    for _fname, _f in flows {
      id: "flow-\(_fname)"
      schema: "Payment"
      // ...
    }
  ]
}
```

Export: `cue export -e ftm ./... > entities.ftm.json`

**Challenge**: CUE exports as pretty-printed JSON, not JSONL. Need post-processing.

### Option 2: Python Script

`scripts/export_ftm.py`:
```python
import json
import subprocess
from datetime import datetime

# Export CUE graph
graph = json.loads(subprocess.check_output(['cue', 'export', '-e', 'graph', './...']))

def cue_to_ftm_entity(node, flows, documents):
    """Convert CUE node to FtM entity"""
    ftm = {
        "id": node["id"],
        "schema": map_schema(node["types"]),
        "datasets": ["epstein-network"],
        "first_seen": datetime.utcnow().isoformat() + "+00:00",
        "last_change": datetime.utcnow().isoformat() + "+00:00",
        "properties": {
            "name": [node["name"]],
            "notes": [node.get("notes", "")]
        }
    }

    # Add external IDs
    if "wikidata_id" in node:
        ftm["properties"]["wikidataId"] = [node["wikidata_id"]]

    return ftm

def cue_to_ftm_relationship(link, connection_details):
    """Convert CUE connection to FtM relationship"""
    rel_type = connection_details.get("rel_type", "unknown")
    schema = {
        "financial": "Payment",
        "familial": "Family",
        "professional": "UnknownLink"
    }.get(rel_type, "UnknownLink")

    return {
        "id": f"conn-{link['source']}-{link['target']}",
        "schema": schema,
        "datasets": ["epstein-network"],
        "properties": {
            "subject": [link["source"]],
            "object": [link["target"]],
            "role": [connection_details.get("notes", "")]
        }
    }

# Write JSONL
with open("entities.ftm.json", "w") as f:
    for node in graph["nodes"]:
        ftm = cue_to_ftm_entity(node, flows, documents)
        f.write(json.dumps(ftm) + "\n")

    for link in graph["links"]:
        ftm = cue_to_ftm_relationship(link, {})
        f.write(json.dumps(ftm) + "\n")
```

**Advantages**:
- Native JSONL output
- Access to full Python FtM library for validation
- Can use `followthemoney` Python package for schema validation

### Option 3: Use FtM Python Library Directly

```python
from followthemoney import model

# Create Person entity
person = model.make_entity("Person")
person.id = "epstein"
person.add("name", "Jeffrey Epstein")
person.add("nationality", "us")
person.add("birthDate", "1953")
person.add("wikidataId", "Q2904131")

# Write to JSONL
with open("entities.ftm.json", "w") as f:
    f.write(person.to_json() + "\n")
```

## Validation

Use FtM CLI to validate output:
```bash
ftm validate entities.ftm.json
```

Check for:
- Valid schema names
- Valid property names per schema
- Valid property types (dates, countries, etc.)
- Valid entity references

## Next Steps

1. **Schema Mapping**: Create complete CUE type → FtM schema mapping
2. **Property Extraction**: Map CUE entity fields to FtM properties
3. **Relationship Generation**: Convert CUE connections to FtM Interval entities
4. **Flow Conversion**: Map CUE flows to FtM Payment entities
5. **Evidence Integration**: Create FtM Document entities
6. **Validation**: Test with small subset against FtM schema
7. **Aleph Import**: Test ingestion into Aleph instance

## References

- [FollowTheMoney Documentation](https://followthemoney.tech/docs/)
- [FollowTheMoney Schema Explorer](https://followthemoney.tech/explorer/)
- [Aleph FtM Import Guide](https://docs.aleph.occrp.org/developers/how-to/data/import-ftm-data/)
- [OpenSanctions Entity Structure](https://www.opensanctions.org/docs/entities/)
- [OpenSanctions FtM JSON Format](https://www.opensanctions.org/docs/bulk/json/)
- [FollowTheMoney GitHub](https://github.com/opensanctions/followthemoney)
- [Aleph Documentation](https://docs.aleph.occrp.org/developers/explanation/followthemoney/)

---

**Sources:**
- [FollowTheMoney Documentation](https://followthemoney.tech/docs/)
- [Aleph Import FollowTheMoney Data](https://docs.aleph.occrp.org/developers/how-to/data/import-ftm-data/)
- [GitHub - opensanctions/followthemoney](https://github.com/opensanctions/followthemoney)
- [OpenSanctions Entity Structure](https://www.opensanctions.org/docs/entities/)
- [Person Schema - followthemoney](https://followthemoney.tech/explorer/schemata/Person/)
- [Company Schema - followthemoney](https://followthemoney.tech/explorer/schemata/Company/)
- [Organization Schema - followthemoney](https://followthemoney.tech/explorer/schemata/Organization/)
- [Payment Schema - followthemoney](https://followthemoney.tech/explorer/schemata/Payment/)
- [OpenSanctions FtM JSON Format](https://www.opensanctions.org/docs/bulk/json/)
- [Aleph FollowTheMoney Explanation](https://docs.aleph.occrp.org/developers/explanation/followthemoney/)
