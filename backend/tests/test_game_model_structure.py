#!/usr/bin/env python3
import json
import os
import random
import string
import sys
import urllib.request
import urllib.error

BASE_URL = os.environ.get('FH_BASE_URL', 'http://127.0.0.1:3001')
CLUB_ID = os.environ.get('FH_CLUB_ID', '100')

slug = 'regression-test-principle-' + ''.join(random.choice(string.ascii_lowercase) for _ in range(4))
payload = {
    'club_id': int(CLUB_ID),
    'phase_id': 1,
    'slug': slug,
    'level': 'main',
    'title': 'Regression Test Principle',
    'description': 'Principle created by the regression test.',
    'sort_order': 999,
}

req = urllib.request.Request(
    f'{BASE_URL}/api/clubs/{CLUB_ID}/game-model/admin/principles',
    data=json.dumps(payload).encode('utf-8'),
    headers={'Content-Type': 'application/json'},
    method='POST',
)

with urllib.request.urlopen(req) as response:
    body = response.read().decode('utf-8')
    if response.status != 200:
        raise SystemExit(f'Create failed with status {response.status}: {body}')

with urllib.request.urlopen(f'{BASE_URL}/api/clubs/{CLUB_ID}/game-model/structure') as response:
    body = response.read().decode('utf-8')

if slug not in body:
    raise SystemExit(f'Expected slug {slug} to appear in structure payload, but it did not.\n{body}')

print(f'PASS: {slug} appeared in the structure payload')
