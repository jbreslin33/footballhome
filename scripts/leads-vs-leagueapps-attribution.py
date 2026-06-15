#!/usr/bin/env python3
"""
Cross-reference LeagueApps Boys/Girls Club registrants against our leads
table (Meta lead-form submissions) to estimate K-12 ad attribution.

The K-12 Boys/Girls Club ads send users straight to LeagueApps with no
Meta lead form, so we cannot attribute their conversions on the Meta
side at all.  The only proxy is process-of-elimination:

    matched     → registrant email IS in leads where form_id ∈ Grades 1-6
                  (so they came in through the Grades 1-6 ad funnel)
    unmatched   → registrant email NOT in leads at all
                  (so they came in through K-12 ad, organic search,
                   word of mouth, or LeagueApps direct visit)

The "unmatched" count is the upper bound on K-12 ad attribution.

Usage:
    python3 scripts/leads-vs-leagueapps-attribution.py

Reads env (LEAGUEAPPS_API_PRIVATE_KEY, LEAGUEAPPS_SITE_ID, DATABASE_URL).
Reuses the same JWT/PEM setup as scripts/leagueapps-membership-roster.py.
"""

import os
import sys
import time
import subprocess
from collections import Counter

import jwt
import requests


# Boys Club / Girls Club LeagueApps program IDs — derived from the
# membership URLs in frontend/js/screens/leads.js (URL_BOYS, URL_GIRLS).
PROGRAMS = {
    'Boys Club':  5039252,
    'Girls Club': 5039357,
}

# Meta lead form IDs that route to the Grades 1-6 funnel for each
# club (mirrors formLabel() in frontend/js/screens/leads.js).
GRADES_1_6_FORMS = {
    'Boys Club': {
        '1704106777282059',  # original Boys Club Grades 1-6
        '2471488896628970',  # slim form recreated 2026-06-10
    },
    'Girls Club': {
        '1571742281184926',  # original Girls Club Grades 1-6
        '1008195014960429',  # slim form recreated 2026-06-10
    },
}


def require_env(name):
    value = os.getenv(name, '').strip()
    if not value:
        print(f'Missing required env var: {name}', file=sys.stderr)
        sys.exit(2)
    return value


def load_key_material(client_id):
    pem_path = f'config/{client_id}.pem'
    p12_path = f'config/{client_id}.p12'
    if not os.path.exists(pem_path):
        if not os.path.exists(p12_path):
            print(f'Missing key files: {pem_path} and {p12_path}', file=sys.stderr)
            sys.exit(2)
        cmd = f'openssl pkcs12 -in {p12_path} -nodes -passin pass:notasecret -out {pem_path}'
        if os.system(cmd) != 0:
            print(f'Failed to generate PEM from {p12_path}', file=sys.stderr)
            sys.exit(2)
        os.chmod(pem_path, 0o600)
    with open(pem_path, 'r', encoding='utf-8') as f:
        return f.read()


def request_access_token(client_id, pem_data):
    now = int(time.time())
    claims = {
        'aud': 'https://auth.leagueapps.io/v2/auth/token',
        'iss': client_id,
        'sub': client_id,
        'iat': now,
        'exp': now + 300,
    }
    assertion = jwt.encode(claims, pem_data, algorithm='RS256')
    resp = requests.post(
        'https://auth.leagueapps.io/v2/auth/token',
        data={
            'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion': assertion,
        },
        timeout=20,
    )
    if resp.status_code != 200:
        print(f'Token request failed ({resp.status_code}): {resp.text[:300]}', file=sys.stderr)
        sys.exit(2)
    return resp.json()['access_token']


def fetch_program_registrations(site_id, program_id, access_token):
    url = f'https://public.leagueapps.io/v2/sites/{site_id}/export/registrations-2'
    params = {'last-updated': 0, 'last-id': 0, 'program-id': program_id}
    headers = {'Authorization': f'Bearer {access_token}'}
    records = []
    for _ in range(50):
        resp = requests.get(url, headers=headers, params=params, timeout=30)
        if resp.status_code != 200:
            print(f'Export {program_id} failed ({resp.status_code}): {resp.text[:300]}', file=sys.stderr)
            sys.exit(2)
        batch = resp.json()
        if not batch:
            break
        records.extend(batch)
        params['last-updated'] = batch[-1].get('lastUpdated', params['last-updated'])
        params['last-id'] = batch[-1].get('id', params['last-id'])

    latest = {}
    for rec in records:
        rid = rec.get('registrationId') or rec.get('id')
        if rid is None:
            continue
        prev = latest.get(rid)
        cur_key  = (rec.get('lastUpdated', 0), rec.get('id', 0))
        prev_key = (prev.get('lastUpdated', 0), prev.get('id', 0)) if prev else (-1, -1)
        if prev is None or cur_key >= prev_key:
            latest[rid] = rec
    return [r for r in latest.values() if not r.get('deleted')]


def normalize_email(e):
    return (e or '').strip().lower()


def fetch_grades_1_6_emails(forms):
    """Query the leads table via `podman exec footballhome_db psql ...`
    so we don't need psycopg2 installed on the host.  Returns a set of
    lowercased emails."""
    in_clause = ','.join(f"'{f}'" for f in forms)
    sql = (
        "SELECT DISTINCT LOWER(TRIM(email)) FROM leads "
        f"WHERE form_id IN ({in_clause}) AND email IS NOT NULL"
    )
    proc = subprocess.run(
        ['podman', 'exec', 'footballhome_db', 'psql',
         '-U', 'footballhome_user', '-d', 'footballhome',
         '-tAc', sql],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        print(f'psql query failed: {proc.stderr.strip()}', file=sys.stderr)
        sys.exit(2)
    return {line.strip() for line in proc.stdout.splitlines() if line.strip()}


def main():
    client_id  = require_env('LEAGUEAPPS_API_PRIVATE_KEY')
    site_id    = int(require_env('LEAGUEAPPS_SITE_ID'))
    pem_data   = load_key_material(client_id)
    token      = request_access_token(client_id, pem_data)

    print('=' * 78)
    print('LeagueApps registrants ↔ Meta leads (Grades 1-6) attribution check')
    print('=' * 78)

    grand = {'attributed': 0, 'unmatched': 0, 'total': 0}

    for club, program_id in PROGRAMS.items():
        regs = fetch_program_registrations(site_id, program_id, token)
        # Active registrants only — drop SPOT_PENDING / WAITLIST etc.
        active = [r for r in regs if r.get('registrationStatus') == 'SPOT_RESERVED']

        forms = tuple(GRADES_1_6_FORMS[club])
        grades_1_6_emails = fetch_grades_1_6_emails(forms)

        attributed = []
        unmatched  = []
        for r in active:
            # Registrants for kids store the parent email in a "guardian"
            # field set; the registration itself has the kid's name. Try
            # both — fall back to whatever's there.
            cand = [
                normalize_email(r.get('email')),
                normalize_email(r.get('parentEmail')),
                normalize_email(r.get('guardianEmail')),
                normalize_email((r.get('contactInfo') or {}).get('email')),
            ]
            cand = [c for c in cand if c]
            matched_email = next((c for c in cand if c in grades_1_6_emails), None)
            label = f"{r.get('firstName','').strip()} {r.get('lastName','').strip()}".strip() or f"reg#{r.get('id')}"
            if matched_email:
                attributed.append((label, matched_email))
            else:
                unmatched.append((label, ', '.join(cand) or '(no email on registration)'))

        print(f'\n=== {club} (LA program {program_id}) ===')
        print(f'  Active registrants:         {len(active)}')
        print(f'  Grades 1-6 lead emails:     {len(grades_1_6_emails)} unique')
        print(f'  Attributed to Grades 1-6:   {len(attributed)}')
        print(f'  Unmatched (K-12/organic):   {len(unmatched)}')
        if attributed:
            print('  → Attributed registrants:')
            for name, em in attributed:
                print(f'      ✓ {name:<32}  {em}')
        if unmatched:
            print('  → Unmatched registrants (K-12 ad / organic / referral):')
            for name, em in unmatched:
                print(f'      ✗ {name:<32}  {em}')

        grand['attributed'] += len(attributed)
        grand['unmatched']  += len(unmatched)
        grand['total']      += len(active)

    print('\n' + '=' * 78)
    print('TOTALS')
    print('=' * 78)
    print(f'  Active registrants (Boys + Girls): {grand["total"]}')
    print(f'  Attributed to Grades 1-6 lead ads: {grand["attributed"]}')
    print(f'  Unmatched (K-12 ad / organic):     {grand["unmatched"]}')
    if grand['total']:
        pct_attr = 100.0 * grand['attributed'] / grand['total']
        pct_un   = 100.0 * grand['unmatched']  / grand['total']
        print(f'  → {pct_attr:.0f}% from Grades 1-6 funnel · {pct_un:.0f}% leftover (K-12 upper bound)')


if __name__ == '__main__':
    main()
