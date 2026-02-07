#!/usr/bin/env python3
"""Export unify-graph CUE data to FollowTheMoney JSONL format.

Reads the CUE-exported JSON files (entities.json, flows.json, documents.json)
and produces a JSONL file compatible with OCCRP Aleph.

Usage:
    python3 scripts/ftm_export.py [--outfile site/data/entities.ftm.jsonl]

Import to Aleph:
    alephclient write-entities --infile entities.ftm.jsonl \
        --foreign-id epstein-network-unify
"""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
SITE_DATA = PROJECT_ROOT / "site" / "data"

DATASET_ID = "epstein-network-unify"

# ── Schema mapping: CUE @type → FtM schema ──────────────────────
# Priority order: first match wins
TYPE_PRIORITY: List[tuple] = [
    ("Property", "RealEstate"),
    ("Aircraft", "Airplane"),
    ("Person", "Person"),
    ("Foundation", "Organization"),
    ("ShellCompany", "Company"),
    ("LawFirm", "Company"),
    ("FinancialInstitution", "Company"),
    ("HedgeFund", "Company"),
    ("InvestmentFirm", "Company"),
    ("ModelingAgency", "Company"),
    ("Organization", "Organization"),
]

# ── Connection rel_type → FtM schema ────────────────────────────
REL_SCHEMA_MAP = {
    "familial": "Family",
    "employer": "Directorship",
}
# Everything else → UnknownLink


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _ftm_base(entity_id: str, schema: str) -> Dict[str, Any]:
    """Create the base FtM entity structure."""
    now = _now_iso()
    return {
        "id": entity_id,
        "schema": schema,
        "datasets": [DATASET_ID],
        "first_seen": now,
        "last_change": now,
        "properties": {},
    }


def determine_schema(type_map: Dict[str, bool]) -> str:
    """Map CUE @type struct-as-set to a single FtM schema."""
    for cue_type, ftm_schema in TYPE_PRIORITY:
        if type_map.get(cue_type):
            return ftm_schema
    return "LegalEntity"


def convert_entity(eid: str, entity: Dict[str, Any]) -> Dict[str, Any]:
    """Convert a CUE entity to an FtM entity."""
    schema = determine_schema(entity.get("@type", {}))
    ftm = _ftm_base(eid, schema)
    props = ftm["properties"]

    # Name
    props["name"] = [entity["name"]]

    # Notes — combine metadata
    notes_parts = []
    if entity.get("role"):
        notes_parts.append(f"Role: {entity['role']}")
    if entity.get("cluster"):
        notes_parts.append(f"Cluster: {entity['cluster']}")
    if entity.get("mention_count") is not None:
        notes_parts.append(f"Mentions: {entity['mention_count']}")
    if entity.get("notes"):
        notes_parts.append(entity["notes"])

    # Evidence IDs
    evidence_ids = list(entity.get("evidence", {}).keys())
    if evidence_ids:
        notes_parts.append(f"Evidence: {', '.join(evidence_ids)}")

    if notes_parts:
        props["notes"] = [" | ".join(notes_parts)]

    # External IDs
    ext = entity.get("external_ids", {})
    if ext.get("wikidata"):
        props["wikidataId"] = [ext["wikidata"]]
    if ext.get("opencorporates"):
        props["opencorporatesUrl"] = [ext["opencorporates"]]

    # Schema-specific properties
    if schema == "Person":
        positions = []
        for t in ("Politician", "GovernmentOfficial", "Prosecutor",
                  "FinancialEnabler", "Recruiter", "Fixer", "Scheduler"):
            if entity.get("@type", {}).get(t):
                positions.append(t)
        if entity.get("role"):
            positions.append(entity["role"])
        if positions:
            props["position"] = positions

    elif schema in ("Company", "Organization"):
        atype = entity.get("@type", {})
        if atype.get("LawFirm"):
            props["sector"] = ["Legal Services"]
        elif atype.get("FinancialInstitution"):
            props["sector"] = ["Financial Services"]
        elif atype.get("HedgeFund"):
            props["sector"] = ["Hedge Fund"]
        elif atype.get("InvestmentFirm"):
            props["sector"] = ["Investment Management"]

    elif schema == "RealEstate":
        props["address"] = [entity["name"]]

    elif schema == "Airplane":
        # Extract registration from notes if available
        notes = entity.get("notes", "")
        for token in notes.split():
            if token.startswith("N") and len(token) >= 5 and token[1:].replace(".", "").isalnum():
                props["registrationNumber"] = [token.rstrip(".")]
                break

    return ftm


def convert_connection(
    source_id: str, target_id: str,
    detail: Dict[str, Any] | None,
) -> Dict[str, Any]:
    """Convert a CUE connection to an FtM relationship entity."""
    rel_type = (detail or {}).get("rel_type", "associate")
    confidence = (detail or {}).get("confidence", "unassessed")

    schema = REL_SCHEMA_MAP.get(rel_type, "UnknownLink")
    conn_id = f"conn-{source_id}-{target_id}"
    ftm = _ftm_base(conn_id, schema)
    props = ftm["properties"]

    if schema == "UnknownLink":
        props["subject"] = [source_id]
        props["object"] = [target_id]
        props["role"] = [rel_type]
    elif schema == "Family":
        props["person"] = [source_id]
        props["relative"] = [target_id]
        props["relationship"] = [rel_type]
    elif schema == "Directorship":
        props["director"] = [source_id]
        props["organization"] = [target_id]

    # Period
    period = (detail or {}).get("period", "")
    if period and "-" in period:
        parts = period.split("-", 1)
        props["startDate"] = [parts[0].strip()]
        props["endDate"] = [parts[1].strip()]

    # Notes with confidence
    notes_parts = [f"Confidence: {confidence}"]
    if (detail or {}).get("notes"):
        notes_parts.append(detail["notes"])
    ev = (detail or {}).get("evidence", {})
    if ev:
        notes_parts.append(f"Evidence: {', '.join(ev.keys())}")
    props["notes"] = [" | ".join(notes_parts)]

    return ftm


def convert_flow(flow_id: str, flow: Dict[str, Any]) -> Dict[str, Any]:
    """Convert a CUE financial flow to an FtM Payment entity."""
    ftm = _ftm_base(f"flow-{flow_id}", "Payment")
    props = ftm["properties"]

    props["payer"] = [flow["source"]]
    props["beneficiary"] = [flow["destination"]]
    props["amount"] = [flow["amount"]]
    props["currency"] = [flow.get("currency", "USD")]

    if flow.get("date"):
        props["date"] = [flow["date"]]
    elif flow.get("period"):
        start = flow["period"].split("-")[0].strip()
        props["date"] = [start]

    purpose_parts = []
    if flow.get("flow_type"):
        purpose_parts.append(flow["flow_type"])
    if flow.get("notes"):
        purpose_parts.append(flow["notes"])
    if purpose_parts:
        props["purpose"] = [" — ".join(purpose_parts)]

    evidence_ids = list(flow.get("evidence", {}).keys())
    if evidence_ids:
        props["notes"] = [f"Evidence: {', '.join(evidence_ids)}"]

    return ftm


def convert_document(doc_id: str, doc: Dict[str, Any]) -> Dict[str, Any]:
    """Convert a CUE document to an FtM Document entity."""
    ftm = _ftm_base(doc_id, "Document")
    props = ftm["properties"]

    props["title"] = [doc["description"]]

    if doc.get("doc_type"):
        props["keywords"] = [doc["doc_type"]]
    if doc.get("date"):
        props["date"] = [doc["date"]]
    if doc.get("summary"):
        props["summary"] = [doc["summary"]]
    if doc.get("source"):
        props["publisher"] = [doc["source"]]

    notes_parts = []
    if doc.get("bates_range"):
        notes_parts.append(f"Bates: {doc['bates_range']}")
    mentions = list(doc.get("mentions", {}).keys())
    if mentions:
        notes_parts.append(f"Mentions: {', '.join(mentions)}")
    if notes_parts:
        props["notes"] = [" | ".join(notes_parts)]

    return ftm


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Export CUE graph to FtM JSONL")
    parser.add_argument("--outfile", default=str(SITE_DATA / "entities.ftm.jsonl"),
                        help="Output JSONL file path")
    args = parser.parse_args()

    # Load CUE-exported JSON
    entities_path = SITE_DATA / "entities.json"
    flows_path = SITE_DATA / "flows.json"
    documents_path = SITE_DATA / "documents.json"

    for p in (entities_path, flows_path, documents_path):
        if not p.exists():
            print(f"Error: {p} not found. Run build.sh first.", file=sys.stderr)
            sys.exit(1)

    entities = json.loads(entities_path.read_text())
    flows = json.loads(flows_path.read_text())
    documents = json.loads(documents_path.read_text())

    output: List[Dict[str, Any]] = []
    conn_seen: set = set()

    # Step 1: Convert entities
    for eid, entity in entities.items():
        output.append(convert_entity(eid, entity))

    # Step 2: Convert connections (deduplicate A→B / B→A)
    for eid, entity in entities.items():
        details = entity.get("connection_details", {})
        for target_id in entity.get("connections", {}):
            pair = tuple(sorted([eid, target_id]))
            if pair in conn_seen:
                continue
            conn_seen.add(pair)
            # Use connection_details if available from either side
            detail = details.get(target_id)
            if not detail:
                # Check reverse side
                other = entities.get(target_id, {})
                detail = other.get("connection_details", {}).get(eid)
            output.append(convert_connection(eid, target_id, detail))

    # Step 3: Convert flows
    for fid, flow in flows.items():
        output.append(convert_flow(fid, flow))

    # Step 4: Convert documents
    for did, doc in documents.items():
        output.append(convert_document(did, doc))

    # Write JSONL
    outpath = Path(args.outfile)
    with outpath.open("w") as f:
        for entity in output:
            f.write(json.dumps(entity, separators=(",", ":")) + "\n")

    # Summary
    schemas = {}
    for e in output:
        s = e["schema"]
        schemas[s] = schemas.get(s, 0) + 1

    print(f"FtM export: {len(output)} entities → {outpath}", file=sys.stderr)
    print(f"  Schemas: {dict(sorted(schemas.items()))}", file=sys.stderr)
    print(f"  Size: {outpath.stat().st_size:,} bytes", file=sys.stderr)


if __name__ == "__main__":
    main()
