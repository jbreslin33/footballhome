#!/usr/bin/env python3
"""Backfill leads from all Meta form IDs into the DB."""

import json
import os
import subprocess
import sys
import urllib.request
import urllib.parse

TOKEN = os.environ.get("META_ADS_TOKEN") or (
    open(os.path.join(os.path.dirname(__file__), "../env"))
    .read()
    .splitlines()
)

# Parse from env file if not set in environment
if isinstance(TOKEN, list):
    for line in TOKEN:
        if line.startswith("META_ADS_TOKEN="):
            TOKEN = line.split("=", 1)[1].strip()
            break

API = "https://graph.facebook.com/v21.0"

# All form IDs: 4 new (DOB+gender) + 3 old
FORM_IDS = [
    "1696381158350766",  # womens new
    "1052472267432735",  # mens new
    "1333581472007910",  # brazil new
    "2062202517690808",  # PR new
    "875990184755538",   # womens old
    "1552835789741946",  # brazil old
    "1668570657681917",  # PR old
]


def api_get(path):
    url = f"{API}/{path}"
    with urllib.request.urlopen(url) as r:
        return json.loads(r.read())


def get_all_leads(form_id):
    leads = []
    url = f"{API}/{form_id}/leads?access_token={TOKEN}&limit=100&fields=id,created_time,field_data,ad_id,form_id,page_id"
    while url:
        with urllib.request.urlopen(url) as r:
            data = json.loads(r.read())
        leads.extend(data.get("data", []))
        url = data.get("paging", {}).get("next")
    return leads


def insert_lead(lead, form_id):
    fields = {}
    for f in lead.get("field_data", []):
        fields[f["name"]] = f["values"][0] if f["values"] else None

    name  = fields.get("full_name") or fields.get("name")
    email = fields.get("email") or fields.get("email_address")
    phone = fields.get("phone_number") or fields.get("phone")
    raw   = json.dumps(lead.get("field_data", []))
    lid   = lead["id"]
    fid   = lead.get("form_id") or form_id
    pid   = lead.get("page_id")
    aid   = lead.get("ad_id")

    sql = (
        "INSERT INTO leads (leadgen_id, form_id, page_id, ad_id, name, email, phone, raw_fields, created_at) "
        "VALUES ('{lid}','{fid}',{pid},{aid},{name},{email},{phone},'{raw}','{ts}') "
        "ON CONFLICT (leadgen_id) DO NOTHING;"
    ).format(
        lid=lid,
        fid=fid,
        pid=f"'{pid}'" if pid else "NULL",
        aid=f"'{aid}'" if aid else "NULL",
        name=f"'{name.replace(chr(39), chr(39)*2)}'" if name else "NULL",
        email=f"'{email.replace(chr(39), chr(39)*2)}'" if email else "NULL",
        phone=f"'{phone.replace(chr(39), chr(39)*2)}'" if phone else "NULL",
        raw=raw.replace("'", "''"),
        ts=lead["created_time"],
    )

    result = subprocess.run(
        ["podman", "exec", "footballhome_db", "psql", "-U", "footballhome_user",
         "-d", "footballhome", "-t", "-A", "-c", sql],
        capture_output=True, text=True
    )
    return result.returncode == 0 and "INSERT 0 1" in result.stdout


total_inserted = 0
total_skipped  = 0

for form_id in FORM_IDS:
    print(f"\nFetching form {form_id}...")
    leads = get_all_leads(form_id)
    print(f"  Found {len(leads)} leads")
    for lead in leads:
        inserted = insert_lead(lead, form_id)
        if inserted:
            total_inserted += 1
            name = next((f["values"][0] for f in lead.get("field_data", []) if f["name"] == "full_name"), lead["id"])
            print(f"  ✓ Inserted: {name}")
        else:
            total_skipped += 1

print(f"\n✅ Done — {total_inserted} inserted, {total_skipped} already existed")
