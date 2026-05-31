#!/usr/bin/env python3

import json
import os
import sys
import time
from collections import Counter

import jwt
import requests


def require_env(name):
    value = os.getenv(name, "").strip()
    if not value:
        print(f"Missing required env var: {name}")
        sys.exit(2)
    return value


def load_key_material(client_id):
    pem_path = f"config/{client_id}.pem"
    p12_path = f"config/{client_id}.p12"

    if not os.path.exists(pem_path):
        if not os.path.exists(p12_path):
            print(f"Missing key files: {pem_path} and {p12_path}")
            sys.exit(2)
        # Same default LeagueApps password documented in their sample.
        cmd = (
            f"openssl pkcs12 -in {p12_path} -nodes -passin pass:notasecret -out {pem_path}"
        )
        rc = os.system(cmd)
        if rc != 0:
            print(f"Failed to generate PEM from {p12_path}")
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


def main():
    client_id = require_env("LEAGUEAPPS_API_PRIVATE_KEY")
    site_id = int(require_env("LEAGUEAPPS_SITE_ID"))
    program_id = int(require_env("LEAGUEAPPS_MEMBERSHIP_PROGRAM_ID"))

    pem_data = load_key_material(client_id)
    token = request_access_token(client_id, pem_data)
    records = fetch_program_registrations(site_id, program_id, token)

    statuses = Counter((r.get("registrationStatus") or "").strip() for r in records)
    print(
        f"Program {program_id} registrations: {len(records)} "
        f"(confirmed={statuses.get('SPOT_RESERVED', 0)}, pending={statuses.get('SPOT_PENDING', 0)})"
    )

    ordered = sorted(
        records,
        key=lambda x: ((x.get("lastName") or "").lower(), (x.get("firstName") or "").lower()),
    )
    for rec in ordered:
        full_name = f"{rec.get('firstName', '').strip()} {rec.get('lastName', '').strip()}".strip()
        print(f"{full_name} | {rec.get('registrationStatus', '')}")


if __name__ == "__main__":
    main()
