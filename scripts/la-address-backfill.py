#!/usr/bin/env python3
# Backfill person_addresses from the LeagueApps registrations-2 export.
#
# LA registrations carry address1/city/state (no zip) for every program;
# most youth families have no person_addresses row, which leaves the 🚗
# carpool midpoint suggestions hollow. This emits INSERT ... ON CONFLICT
# DO NOTHING SQL on stdout — strictly additive, never touches an
# existing primary address. PII flows through the pipe into the DB and
# never lands in git, per the contacts-in-DB-only rule. Lat/lon stays
# NULL: CarpoolRouting geocodes lazily on first use.
#
# Each record's address goes to the registrant (userId) AND, on a youth
# registration, the parent (parentUserId) — same household. Matching is
# alias-aware: persons.la_user_id plus person_la_user_ids (mig 602).
#
# Run (program ids from leagueapps_programs; repeat per program):
#   sudo podman exec footballhome_leagueapps_sync \
#     python3 /app/scripts/la-address-backfill.py 5039252 5064618 ... \
#   | sudo podman exec -i footballhome_db \
#     psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1

import os
import re
import sys
import time

import jwt
import requests


def access_token():
    client_id = os.environ["LEAGUEAPPS_API_PRIVATE_KEY"].strip()
    with open(f"config/{client_id}.pem", "r", encoding="utf-8") as f:
        pem = f.read()
    now = int(time.time())
    assertion = jwt.encode({
        "aud": "https://auth.leagueapps.io/v2/auth/token",
        "iss": client_id, "sub": client_id, "iat": now, "exp": now + 300,
    }, pem, algorithm="RS256")
    resp = requests.post(
        "https://auth.leagueapps.io/v2/auth/token",
        data={"grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
              "assertion": assertion},
        timeout=20,
    )
    resp.raise_for_status()
    return resp.json()["access_token"]


def registrations(site_id, program_id, tok):
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
    # Latest state per registration wins; deleted ones drop out.
    latest = {}
    for rec in records:
        rid = rec.get("registrationId") or rec.get("id")
        if rid is None:
            continue
        key = (rec.get("lastUpdated", 0), rec.get("id", 0))
        prev = latest.get(rid)
        if prev is None or key >= (prev.get("lastUpdated", 0), prev.get("id", 0)):
            latest[rid] = rec
    return [r for r in latest.values() if not r.get("deleted")]


def lit(s):
    """SQL text literal: trimmed, control chars rejected, quotes doubled."""
    s = (s or "").strip()
    if re.search(r"[\x00-\x1f\x7f]", s):
        raise ValueError("control character in address field")
    return "'" + s.replace("'", "''") + "'"


def main():
    program_ids = [int(a) for a in sys.argv[1:]]
    if not program_ids:
        print("usage: la-address-backfill.py <program_id> [...]", file=sys.stderr)
        sys.exit(2)
    site_id = int(os.environ["LEAGUEAPPS_SITE_ID"])
    tok = access_token()

    # One address per LA user id; a later program's record never
    # overwrites an earlier one (ON CONFLICT skips repeats anyway).
    addresses = {}
    for pid in program_ids:
        recs = registrations(site_id, pid, tok)
        print(f"-- program {pid}: {len(recs)} live registrations", file=sys.stderr)
        for rec in recs:
            addr = (rec.get("address1") or "").strip()
            city = (rec.get("city") or "").strip()
            if not addr or not city:
                continue
            state = (rec.get("state") or "").strip()
            for uid_key in ("userId", "parentUserId"):
                uid = rec.get(uid_key)
                if uid:
                    addresses.setdefault(int(uid), (addr, city, state))

    print("BEGIN;")
    for uid, (addr, city, state) in sorted(addresses.items()):
        print(
            "INSERT INTO person_addresses (person_id, address1, city, state, zip)\n"
            f"SELECT m.pid, {lit(addr)}, {lit(city)}, {lit(state)}, ''\n"
            "FROM (\n"
            f"  SELECT p.id AS pid FROM persons p WHERE p.la_user_id = '{uid}'\n"
            "  UNION\n"
            f"  SELECT a.person_id FROM person_la_user_ids a WHERE a.la_user_id = '{uid}'\n"
            ") m\n"
            "ON CONFLICT (person_id) WHERE is_primary DO NOTHING;"
        )
    print("COMMIT;")
    print(f"-- {len(addresses)} LA users with an address", file=sys.stderr)


if __name__ == "__main__":
    main()
