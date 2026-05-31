#!/usr/bin/env python3
"""Sync LeagueApps payment status into persons.leagueapps_payment_status.

Usage:
  source ./env
  python3 scripts/sync-leagueapps-payment-status.py
  python3 scripts/sync-leagueapps-payment-status.py --dry-run
"""

import argparse
import datetime
import os
import re
import subprocess
import sys
import time

import jwt
import requests


def require_env(name):
    value = os.getenv(name, "").strip()
    if not value:
        print(f"Missing required env var: {name}")
        sys.exit(2)
    return value


def normalize_name(value):
    if not value:
        return ""
    value = value.strip().lower()
    value = re.sub(r"\s+", " ", value)
    return value


def sql_quote(value):
    return "'" + str(value).replace("'", "''") + "'"


def load_key_material(client_id):
    pem_path = f"config/{client_id}.pem"
    p12_path = f"config/{client_id}.p12"

    if not os.path.exists(pem_path):
        if not os.path.exists(p12_path):
            print(f"Missing key files: {pem_path} and {p12_path}")
            sys.exit(2)
        cmd = [
            "openssl",
            "pkcs12",
            "-in",
            p12_path,
            "-nodes",
            "-passin",
            "pass:notasecret",
            "-out",
            pem_path,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Failed to generate PEM from {p12_path}: {result.stderr.strip()}")
            sys.exit(2)
        os.chmod(pem_path, 0o600)

    with open(pem_path, "r", encoding="utf-8") as f:
        return f.read()


def request_access_token(client_id, pem_data):
    now = int(time.time())
    claims = {
        "aud": "https://auth.leagueapps.io/v2/auth/token",
        "iss": client_id,
        "sub": client_id,
        "iat": now,
        "exp": now + 300,
    }
    assertion = jwt.encode(claims, pem_data, algorithm="RS256")

    resp = requests.post(
        "https://auth.leagueapps.io/v2/auth/token",
        data={
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": assertion,
        },
        timeout=20,
    )
    if resp.status_code != 200:
        print(f"Token request failed ({resp.status_code}): {resp.text[:300]}")
        sys.exit(2)
    return resp.json()["access_token"]


def fetch_program_registrations(site_id, program_id, access_token):
    url = f"https://public.leagueapps.io/v2/sites/{site_id}/export/registrations-2"
    params = {
        "last-updated": 0,
        "last-id": 0,
        "program-id": program_id,
    }
    headers = {"Authorization": f"Bearer {access_token}"}
    records = []

    for _ in range(50):
        resp = requests.get(url, headers=headers, params=params, timeout=30)
        if resp.status_code != 200:
            print(f"Export request failed ({resp.status_code}): {resp.text[:300]}")
            sys.exit(2)
        batch = resp.json()
        if not batch:
            break
        records.extend(batch)
        params["last-updated"] = batch[-1].get("lastUpdated", params["last-updated"])
        params["last-id"] = batch[-1].get("id", params["last-id"])

    latest = {}
    for rec in records:
        rid = rec.get("registrationId") or rec.get("id")
        if rid is None:
            continue
        prev = latest.get(rid)
        cur_key = (rec.get("lastUpdated", 0), rec.get("id", 0))
        prev_key = (prev.get("lastUpdated", 0), prev.get("id", 0)) if prev else (-1, -1)
        if prev is None or cur_key >= prev_key:
            latest[rid] = rec

    return [r for r in latest.values() if not r.get("deleted")]


def extract_payment_status(rec):
    for key in [
        "paymentStatus",
        "payment_status",
        "paymentstatus",
        "billingStatus",
        "billing_status",
        "invoiceStatus",
        "invoice_status",
    ]:
        value = rec.get(key)
        if value is not None and str(value).strip():
            return str(value).strip()
    return ""


def _parse_dob_value(value):
    if value is None:
        return ""
    raw = str(value).strip()
    if not raw:
        return ""

    raw = raw.split("T", 1)[0].strip()

    for fmt in ("%Y-%m-%d", "%m/%d/%Y", "%m-%d-%Y", "%Y/%m/%d"):
        try:
            dt = datetime.datetime.strptime(raw, fmt)
            return dt.strftime("%Y-%m-%d")
        except ValueError:
            pass

    # Last-chance normalization for already close values like YYYY-M-D.
    m = re.match(r"^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$", raw)
    if m:
        y, mo, d = m.groups()
        try:
            dt = datetime.date(int(y), int(mo), int(d))
            return dt.strftime("%Y-%m-%d")
        except ValueError:
            return ""
    return ""


def extract_dob(rec):
    for key in [
        "dateOfBirth",
        "date_of_birth",
        "birthDate",
        "birth_date",
        "dob",
    ]:
        dob = _parse_dob_value(rec.get(key))
        if dob:
            return dob
    return ""


def run_psql(sql):
    container = os.getenv("DB_CONTAINER", "footballhome_db")
    db_user = os.getenv("DB_USER", "footballhome_user")
    db_name = os.getenv("DB_NAME", "footballhome")

    cmd = [
        "podman",
        "exec",
        container,
        "psql",
        "-U",
        db_user,
        "-d",
        db_name,
        "-t",
        "-A",
        "-F",
        "|",
        "-v",
        "ON_ERROR_STOP=1",
        "-c",
        sql,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        stderr = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(stderr)
    return result.stdout


def load_person_name_index():
    sql = (
        "SELECT id, LOWER(TRIM(first_name)), LOWER(TRIM(last_name)) "
        "FROM persons"
    )
    raw = run_psql(sql)
    index = {}
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split("|", 2)
        if len(parts) != 3:
            continue
        person_id = int(parts[0])
        first = normalize_name(parts[1])
        last = normalize_name(parts[2])
        if not first or not last:
            continue
        key = (first, last)
        index.setdefault(key, []).append(person_id)
    return index


def load_alias_index(provider="leagueapps"):
    sql = (
        "SELECT LOWER(TRIM(alias_first_name)), LOWER(TRIM(alias_last_name)), person_id "
        "FROM external_person_aliases "
        f"WHERE provider = {sql_quote(provider)}"
    )
    raw = run_psql(sql)
    index = {}
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split("|", 2)
        if len(parts) != 3:
            continue
        first = normalize_name(parts[0])
        last = normalize_name(parts[1])
        if not first or not last:
            continue
        key = (first, last)
        index[key] = int(parts[2])
    return index


def apply_updates(updates):
    if not updates:
        return 0

    values = []
    for person_id, payment_status, dob in updates:
        dob_sql = "NULL"
        if dob:
            dob_sql = sql_quote(dob)
        values.append(f"({person_id}, {sql_quote(payment_status)}, {dob_sql})")

    sql = (
        "WITH incoming(person_id, payment_status, date_of_birth) AS (VALUES "
        + ",".join(values)
        + ") "
        "UPDATE persons p "
        "SET leagueapps_payment_status = incoming.payment_status, "
        "    birth_date = COALESCE(incoming.date_of_birth::date, p.birth_date), "
        "    updated_at = CURRENT_TIMESTAMP "
        "FROM incoming "
        "WHERE p.id = incoming.person_id"
    )
    run_psql(sql)
    return len(updates)


def main():
    parser = argparse.ArgumentParser(description="Sync LeagueApps payment statuses into DB")
    parser.add_argument("--dry-run", action="store_true", help="Do not write DB updates")
    parser.add_argument(
        "--print-unmatched-alias-sql",
        action="store_true",
        help="Print SQL INSERT templates for unmatched LeagueApps names",
    )
    args = parser.parse_args()

    client_id = require_env("LEAGUEAPPS_API_PRIVATE_KEY")
    site_id = int(require_env("LEAGUEAPPS_SITE_ID"))
    program_id = int(require_env("LEAGUEAPPS_MEMBERSHIP_PROGRAM_ID"))

    pem_data = load_key_material(client_id)
    token = request_access_token(client_id, pem_data)
    records = fetch_program_registrations(site_id, program_id, token)

    person_index = load_person_name_index()
    alias_index = load_alias_index(provider="leagueapps")

    latest_by_name = {}
    for rec in records:
        first = normalize_name(rec.get("firstName") or "")
        last = normalize_name(rec.get("lastName") or "")
        if not first or not last:
            continue

        payment_status = extract_payment_status(rec)
        dob = extract_dob(rec)
        if not payment_status and not dob:
            continue

        key = (first, last)
        rec_key = (rec.get("lastUpdated", 0), rec.get("id", 0))
        prev = latest_by_name.get(key)
        if prev is None or rec_key >= prev[0]:
            latest_by_name[key] = (rec_key, payment_status, dob, rec)

    update_candidates = {}
    unmatched = []
    ambiguous = []
    matched_by_alias = 0

    def track_update(person_id, rec_key, payment_status, dob):
        prev = update_candidates.get(person_id)
        if prev is None or rec_key >= prev[0]:
            update_candidates[person_id] = (rec_key, payment_status, dob)

    for key, payload in latest_by_name.items():
        rec_key = payload[0]
        payment_status = payload[1]
        dob = payload[2]
        person_ids = person_index.get(key, [])
        alias_person_id = alias_index.get(key)

        if alias_person_id:
            track_update(alias_person_id, rec_key, payment_status, dob)
            matched_by_alias += 1
            continue

        if len(person_ids) == 1:
            track_update(person_ids[0], rec_key, payment_status, dob)
        elif len(person_ids) == 0:
            unmatched.append((key[0], key[1], payment_status))
        else:
            ambiguous.append((key[0], key[1], payment_status, person_ids))

    updates = [(person_id, payload[1], payload[2]) for person_id, payload in update_candidates.items()]

    print(f"LeagueApps registrations fetched: {len(records)}")
    print(f"Rows with payment status: {len(latest_by_name)}")
    print(f"Unique person matches: {len(updates)}")
    print(f"Matched via aliases: {matched_by_alias}")
    print(f"Ambiguous name matches: {len(ambiguous)}")
    print(f"Unmatched names: {len(unmatched)}")

    if args.dry_run:
        print("DRY RUN: no DB updates applied")
    else:
        updated = apply_updates(updates)
        print(f"DB rows updated: {updated}")

    if ambiguous:
        print("\nAmbiguous examples (first 10):")
        for first, last, status, person_ids in ambiguous[:10]:
            print(f"  {first} {last} -> {status} (person_ids={person_ids})")

    if unmatched:
        print("\nUnmatched examples (first 10):")
        for first, last, status in unmatched[:10]:
            print(f"  {first} {last} -> {status}")

    if args.print_unmatched_alias_sql and unmatched:
        print("\nSQL templates to map unmatched names:")
        for first, last, _status in unmatched:
            print(
                "INSERT INTO external_person_aliases (provider, alias_first_name, alias_last_name, person_id) "
                f"VALUES ('leagueapps', {sql_quote(first)}, {sql_quote(last)}, <person_id>) "
                "ON CONFLICT (provider, alias_first_name, alias_last_name) DO UPDATE "
                "SET person_id = EXCLUDED.person_id, updated_at = NOW();"
            )


if __name__ == "__main__":
    main()
