#!/usr/bin/env python3
# PII-safe probe: does the LeagueApps registrations-2 export carry
# addresses we could backfill into person_addresses? Prints only field
# NAMES and non-empty coverage counts — never a value. Run inside the
# sync container (credentials + mounted config):
#   sudo podman exec footballhome_leagueapps_sync \
#     python3 /app/scripts/la-address-probe.py <program_id>

import os
import sys
import time

import jwt
import requests


def main():
    program_id = int(sys.argv[1]) if len(sys.argv) > 1 else int(
        os.environ["LEAGUEAPPS_MEMBERSHIP_PROGRAM_ID"])
    client_id = os.environ["LEAGUEAPPS_API_PRIVATE_KEY"].strip()
    site_id = int(os.environ["LEAGUEAPPS_SITE_ID"])

    with open(f"config/{client_id}.pem", "r", encoding="utf-8") as f:
        pem = f.read()
    now = int(time.time())
    assertion = jwt.encode({
        "aud": "https://auth.leagueapps.io/v2/auth/token",
        "iss": client_id, "sub": client_id, "iat": now, "exp": now + 300,
    }, pem, algorithm="RS256")
    tok = requests.post(
        "https://auth.leagueapps.io/v2/auth/token",
        data={"grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
              "assertion": assertion},
        timeout=20,
    ).json()["access_token"]

    url = f"https://public.leagueapps.io/v2/sites/{site_id}/export/registrations-2"
    params = {"last-updated": 0, "last-id": 0, "program-id": program_id}
    records = []
    for _ in range(50):
        batch = requests.get(url, params=params, timeout=30,
                             headers={"Authorization": f"Bearer {tok}"}).json()
        if not batch:
            break
        records.extend(batch)
        params["last-updated"] = batch[-1].get("lastUpdated", 0)
        params["last-id"] = batch[-1].get("id", 0)

    live = [r for r in records if not r.get("deleted")]
    print(f"program {program_id}: {len(live)} live records")
    if not live:
        return

    # Every key seen anywhere, with how many records carry a non-empty value.
    keys = {}
    for rec in live:
        for k, v in rec.items():
            filled = v not in (None, "", [], {})
            keys[k] = keys.get(k, 0) + (1 if filled else 0)
    for k in sorted(keys):
        print(f"  {k}: {keys[k]}/{len(live)} non-empty")


if __name__ == "__main__":
    main()
