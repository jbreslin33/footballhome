#!/usr/bin/env python3
import json
import os
import random
import string
import sys
import urllib.request
import urllib.error

BASE_URL = os.environ.get('FH_BASE_URL', 'http://127.0.0.1:3001')
CLUB_ID = os.environ.get('FH_CLUB_ID', '134')


def fetch_json(url, data=None, method=None):
    req = urllib.request.Request(
        url,
        data=json.dumps(data).encode('utf-8') if data is not None else None,
        headers={'Content-Type': 'application/json'},
        method=method,
    )
    with urllib.request.urlopen(req) as response:
        body = response.read().decode('utf-8')
        if response.status != 200:
            raise SystemExit(f'Request to {url} failed with status {response.status}: {body}')
        return json.loads(body), body


phases_payload, _ = fetch_json(f'{BASE_URL}/api/clubs/{CLUB_ID}/game-model/admin/phases')
phases = phases_payload.get('data', phases_payload)
if not isinstance(phases, list) or not phases:
    raise SystemExit(f'Expected at least one phase from admin/phases, got: {phases_payload}')
phase_id = phases[0]['id']

principle_slug = 'regression-test-principle-' + ''.join(random.choice(string.ascii_lowercase) for _ in range(4))
principle_payload = {
    'phase_id': phase_id,
    'slug': principle_slug,
    'title': 'Regression Test Principle',
    'description': 'Principle created by the regression test.',
    'sort_order': 999,
}
create_principle_result, _ = fetch_json(
    f'{BASE_URL}/api/clubs/{CLUB_ID}/game-model/admin/principles',
    data=principle_payload,
    method='POST',
)
principle_id = create_principle_result.get('data', {}).get('id')
if not principle_id:
    raise SystemExit(f'Expected new principle id in response, got: {create_principle_result}')

sub_principle_slug = 'regression-test-sub-principle-' + ''.join(random.choice(string.ascii_lowercase) for _ in range(4))
sub_principle_payload = {
    'principle_id': principle_id,
    'slug': sub_principle_slug,
    'title': 'Regression Test Sub-Principle',
    'definition': 'Sub-principle definition created by the regression test.',
    'sort_order': 999,
}
fetch_json(
    f'{BASE_URL}/api/clubs/{CLUB_ID}/game-model/admin/sub_principles',
    data=sub_principle_payload,
    method='POST',
)

with urllib.request.urlopen(f'{BASE_URL}/api/clubs/{CLUB_ID}/game-model/structure') as response:
    body = response.read().decode('utf-8')

payload = json.loads(body)
structure = payload.get('data', payload)
phases = structure.get('phases', [])
if not phases:
    raise SystemExit(f'Expected phases in structure payload, but none were returned.\n{body}')

first_phase = phases[0]
if 'action_catalogs' not in first_phase or not isinstance(first_phase['action_catalogs'], list):
    raise SystemExit(f'Expected action_catalogs array for phase {first_phase.get("slug")}, but it was missing.\n{body}')
for catalog in first_phase.get('action_catalogs', []):
    if 'categories' not in catalog or not isinstance(catalog['categories'], list):
        raise SystemExit(f'Expected categories array on action catalog {catalog.get("slug")}, but it was missing.\n{body}')
    for category in catalog['categories']:
        if 'items' not in category or not isinstance(category['items'], list):
            raise SystemExit(f'Expected items array on action category {category.get("slug")}, but it was missing.\n{body}')
for principle in first_phase.get('principles', []):
    if 'sub_principles' not in principle or not isinstance(principle['sub_principles'], list):
        raise SystemExit(f'Expected sub_principles array on principle {principle.get("slug")}, but it was missing.\n{body}')
    for sub_principle in principle['sub_principles']:
        if 'definition' not in sub_principle:
            raise SystemExit(f'Expected definition field on sub_principle {sub_principle.get("slug")}, but it was missing.\n{body}')

for expected_slug in ['attacking', 'defending', 'attacking-to-defending-transition', 'defending-to-attacking-transition']:
    phase = next((phase for phase in phases if phase.get('slug') == expected_slug), None)
    if not phase:
        raise SystemExit(f'Expected phase {expected_slug} in structure payload, but it was missing.\n{body}')
    if not isinstance(phase.get('principles'), list) or not phase.get('principles'):
        raise SystemExit(f'Expected at least one principle for phase {expected_slug}, but none were returned.\n{body}')

if principle_slug not in body:
    raise SystemExit(f'Expected principle slug {principle_slug} to appear in structure payload, but it did not.\n{body}')
if sub_principle_slug not in body:
    raise SystemExit(f'Expected sub-principle slug {sub_principle_slug} to appear in structure payload, but it did not.\n{body}')

print(f'PASS: {principle_slug} / {sub_principle_slug} appeared in the structure payload with sub_principles, definitions, and action catalogs')

