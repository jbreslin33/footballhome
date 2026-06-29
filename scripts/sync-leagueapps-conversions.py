#!/usr/bin/env python3
"""
Sync LeagueApps registrations → leads.converted_at.

Phase 3 of the lead-conversion-tracking project.  Pulls active
registrations from every program ID we ship in env, builds a
{email → registration} map, and POSTs `/api/leads/:id/mark-converted`
for every open (not-yet-converted) lead whose email appears in that
map.

Idempotent: skips leads that already have converted_at set (manual or
prior LA flag).  Manual flags always win — we never overwrite them.

Run modes:
  python3 scripts/sync-leagueapps-conversions.py            # mark
  python3 scripts/sync-leagueapps-conversions.py --dry-run  # report only

Env (all required):
  LEAGUEAPPS_API_PRIVATE_KEY          JWT client id (PEM filename in config/)
  LEAGUEAPPS_SITE_ID                  e.g. "13042"

Env (optional — at least one program ID must be set):
  LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID
  LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID
  LEAGUEAPPS_MENS_PROGRAM_ID
  LEAGUEAPPS_MEMBERSHIP_PROGRAM_ID
  EXTRA_LEAGUEAPPS_PROGRAM_IDS        comma-separated extras
                                       (e.g. "5039999,5040000")

Env (optional — backend integration):
  BACKEND_URL                         default http://localhost:3001
  LEADS_SYNC_BEARER                   bearer used to call /api/leads.
                                       Backend currently checks bearer
                                       *presence* only, so the value is
                                       opaque — any string works.
                                       Default: "leagueapps-sync".
"""

import argparse
import os
import subprocess
import sys
import time
from datetime import datetime, timezone

import jwt
import requests


# ─── Program registry ──────────────────────────────────────────────────────
# Maps a friendly name to the env var that carries the LA program id.
# A program with no env value is silently skipped — so the sidecar can be
# deployed before every program is configured.
PROGRAM_ENV_VARS = [
    ("Boys Club",       "LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID"),
    ("Girls Club",      "LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID"),
    ("Men's Club",      "LEAGUEAPPS_MENS_PROGRAM_ID"),
    ("Membership",      "LEAGUEAPPS_MEMBERSHIP_PROGRAM_ID"),
]


def require_env(name):
    value = os.getenv(name, "").strip()
    if not value:
        print(f"Missing required env var: {name}", file=sys.stderr)
        sys.exit(2)
    return value


def load_key_material(client_id):
    """Resolve the RSA key file for the given LeagueApps client id.
    Prefers the unpacked .pem; falls back to converting the .p12 with
    openssl (matches sync-leagueapps-payment-status.py).
    """
    pem_path = f"config/{client_id}.pem"
    p12_path = f"config/{client_id}.p12"
    if not os.path.exists(pem_path):
        if not os.path.exists(p12_path):
            print(f"Missing key files: {pem_path} and {p12_path}", file=sys.stderr)
            sys.exit(2)
        cmd = [
            "openssl", "pkcs12", "-in", p12_path,
            "-nodes", "-passin", "pass:notasecret", "-out", pem_path,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Failed to generate PEM from {p12_path}: {result.stderr.strip()}",
                  file=sys.stderr)
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
        print(f"Token request failed ({resp.status_code}): {resp.text[:300]}",
              file=sys.stderr)
        sys.exit(2)
    return resp.json()["access_token"]


def fetch_program_registrations(site_id, program_id, access_token):
    """Page through the registrations-2 export endpoint and return the
    deduplicated list of non-deleted records (most-recent revision per
    registrationId).  Same algorithm as the other LA sync scripts.
    """
    url = f"https://public.leagueapps.io/v2/sites/{site_id}/export/registrations-2"
    params = {"last-updated": 0, "last-id": 0, "program-id": program_id}
    headers = {"Authorization": f"Bearer {access_token}"}
    records = []
    for _ in range(50):  # cap pagination so a runaway feed doesn't loop forever
        resp = requests.get(url, headers=headers, params=params, timeout=30)
        if resp.status_code != 200:
            print(f"Export {program_id} failed ({resp.status_code}): {resp.text[:300]}",
                  file=sys.stderr)
            return []
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
        cur_key  = (rec.get("lastUpdated", 0), rec.get("id", 0))
        prev_key = (prev.get("lastUpdated", 0), prev.get("id", 0)) if prev else (-1, -1)
        if prev is None or cur_key >= prev_key:
            latest[rid] = rec
    return [r for r in latest.values() if not r.get("deleted")]


def normalize_email(value):
    return (value or "").strip().lower()


def reg_emails(reg):
    """Every email that might tie a registration back to a lead-form
    submission.  Mirrors leads-vs-leagueapps-attribution.py — kids
    register under their own name but the parent email is in a separate
    field, so we have to consider all of them.
    """
    cand = [
        reg.get("email"),
        reg.get("parentEmail"),
        reg.get("guardianEmail"),
        (reg.get("contactInfo") or {}).get("email"),
    ]
    return {normalize_email(c) for c in cand if c}


def reg_label(reg):
    name = (
        f"{(reg.get('firstName') or '').strip()} "
        f"{(reg.get('lastName')  or '').strip()}"
    ).strip()
    return name or f"reg#{reg.get('id') or reg.get('registrationId')}"


def collect_active_emails(site_id, programs, access_token):
    """Returns dict[email -> list of {program, label, status, id}]."""
    by_email = {}
    program_counts = {}
    for program_name, program_id in programs:
        regs = fetch_program_registrations(site_id, program_id, access_token)
        # SPOT_RESERVED = the "actually registered" status.  Pending /
        # waitlist rows are not conversions yet — skip them so the
        # auto-flag doesn't fire prematurely.
        active = [r for r in regs if r.get("registrationStatus") == "SPOT_RESERVED"]
        program_counts[program_name] = len(active)
        for r in active:
            entry = {
                "program": program_name,
                "program_id": program_id,
                "label":   reg_label(r),
                "id":      r.get("id") or r.get("registrationId"),
                "status":  r.get("registrationStatus"),
            }
            for e in reg_emails(r):
                by_email.setdefault(e, []).append(entry)
    return by_email, program_counts


def fetch_leads(backend_url, bearer):
    url = f"{backend_url.rstrip('/')}/api/leads"
    resp = requests.get(
        url,
        headers={"Authorization": f"Bearer {bearer}"},
        timeout=30,
    )
    if resp.status_code != 200:
        print(f"GET /api/leads failed ({resp.status_code}): {resp.text[:300]}",
              file=sys.stderr)
        sys.exit(2)
    return resp.json()


def mark_lead_converted(backend_url, bearer, lead_id, source, note):
    url = f"{backend_url.rstrip('/')}/api/leads/{lead_id}/mark-converted"
    resp = requests.post(
        url,
        headers={
            "Authorization": f"Bearer {bearer}",
            "Content-Type":  "application/json",
        },
        json={"source": source, "note": note},
        timeout=15,
    )
    if resp.status_code != 200:
        print(f"  mark-converted lead {lead_id} failed "
              f"({resp.status_code}): {resp.text[:200]}",
              file=sys.stderr)
        return False
    return True


def parse_extra_program_ids():
    """EXTRA_LEAGUEAPPS_PROGRAM_IDS=5039999,5040000 → [("Extra 5039999", 5039999), ...]"""
    raw = os.getenv("EXTRA_LEAGUEAPPS_PROGRAM_IDS", "").strip()
    if not raw:
        return []
    out = []
    for piece in raw.split(","):
        piece = piece.strip()
        if not piece:
            continue
        try:
            pid = int(piece)
        except ValueError:
            print(f"  ⚠ Skipping non-integer extra program id: {piece!r}",
                  file=sys.stderr)
            continue
        out.append((f"Extra {pid}", pid))
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("--dry-run", action="store_true",
                        help="Report matches without calling mark-converted.")
    args = parser.parse_args()

    backend_url = os.getenv("BACKEND_URL", "http://localhost:3001").strip()
    sync_bearer = os.getenv("LEADS_SYNC_BEARER", "leagueapps-sync").strip() or "leagueapps-sync"

    client_id = require_env("LEAGUEAPPS_API_PRIVATE_KEY")
    site_id   = int(require_env("LEAGUEAPPS_SITE_ID"))

    # Build program list from env.  Any env var that's set + non-empty
    # contributes a program.  EXTRA_LEAGUEAPPS_PROGRAM_IDS appends more.
    programs = []
    for name, env_var in PROGRAM_ENV_VARS:
        val = os.getenv(env_var, "").strip()
        if not val:
            continue
        try:
            programs.append((name, int(val)))
        except ValueError:
            print(f"  ⚠ {env_var}={val!r} is not an integer — skipping",
                  file=sys.stderr)
    programs.extend(parse_extra_program_ids())

    if not programs:
        print("No LeagueApps program ids configured in env — nothing to sync.",
              file=sys.stderr)
        sys.exit(2)

    started = datetime.now(timezone.utc)
    print(f"[{started:%Y-%m-%d %H:%M:%SZ}] sync-leagueapps-conversions starting")
    print(f"  backend:      {backend_url}")
    print(f"  dry-run:      {args.dry_run}")
    print(f"  programs:     {[p[0] for p in programs]}")

    pem_data = load_key_material(client_id)
    token    = request_access_token(client_id, pem_data)

    email_to_regs, program_counts = collect_active_emails(site_id, programs, token)
    print("  active SPOT_RESERVED registrations by program:")
    for name, _ in programs:
        print(f"    {name:<14} {program_counts.get(name, 0)}")
    print(f"  → {len(email_to_regs)} unique active-registrant emails across all programs")

    leads = fetch_leads(backend_url, sync_bearer)
    print(f"  fetched {len(leads)} leads from backend")

    already_converted = [l for l in leads if l.get("converted_at")]
    print(f"  skipping {len(already_converted)} leads already converted (manual or prior LA flag)")

    matched   = []
    nomatch   = 0
    no_email  = 0
    for lead in leads:
        if lead.get("converted_at"):
            continue
        email = normalize_email(lead.get("email"))
        if not email:
            no_email += 1
            continue
        regs = email_to_regs.get(email)
        if not regs:
            nomatch += 1
            continue
        # Compose a note describing the match.  Multiple registrations
        # for the same email get joined so the audit trail is complete.
        bits = []
        for r in regs:
            bits.append(f"{r['program']}#{r['id']}({r['label']})")
        note = "auto: " + " ; ".join(bits)
        matched.append((lead, regs, note))

    print(f"\n=== Matches ({len(matched)}) ===")
    for lead, regs, note in matched:
        progs = ", ".join(sorted({r["program"] for r in regs}))
        print(f"  lead#{lead['id']:<6} {lead.get('email','')!s:<40} → {progs}")
        if args.dry_run:
            continue
        ok = mark_lead_converted(
            backend_url, sync_bearer, lead["id"], "leagueapps", note,
        )
        if ok:
            print(f"     ✓ marked converted (source=leagueapps)")

    print(f"\n=== Summary ===")
    print(f"  leads checked:                 {len(leads)}")
    print(f"  already converted (skipped):   {len(already_converted)}")
    print(f"  open leads with no email:      {no_email}")
    print(f"  open leads with no LA match:   {nomatch}")
    print(f"  open leads matched & {'(would be )' if args.dry_run else ''}marked: {len(matched)}")

    finished = datetime.now(timezone.utc)
    elapsed = (finished - started).total_seconds()
    print(f"[{finished:%Y-%m-%d %H:%M:%SZ}] sync-leagueapps-conversions done "
          f"({elapsed:.1f}s)")


if __name__ == "__main__":
    main()
