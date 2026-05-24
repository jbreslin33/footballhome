#!/usr/bin/env python3
"""
Create lead forms with DOB+gender for all 4 campaigns,
create new creatives, update ads, set budgets, activate campaigns.
"""
import urllib.request, json, os, sys

TOKEN   = os.environ['META_ADS_TOKEN']
PAGE_ID = '518090048060695'
AD_ACCT = 'act_1792823854148245'
API     = 'https://graph.facebook.com/v21.0'

def api_post(path, data):
    data['access_token'] = TOKEN
    body = urllib.parse.urlencode(data).encode()
    req = urllib.request.Request(f'{API}/{path}', data=body,
          headers={'Content-Type': 'application/x-www-form-urlencoded'}, method='POST')
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        err = json.loads(e.read())
        raise Exception(f'API error {e.code} on {path}: {err}') from None

def api_get(path, params={}):
    params['access_token'] = TOKEN
    qs = urllib.parse.urlencode(params)
    with urllib.request.urlopen(f'{API}/{path}?{qs}') as r:
        return json.loads(r.read())

import urllib.parse

# ── 1. Create lead forms ──────────────────────────────────────────────
print('\n=== 1. Creating lead forms ===')
questions = json.dumps([
    {"type": "FULL_NAME"},
    {"type": "EMAIL"},
    {"type": "PHONE"},
    {"type": "DOB"},
    {"type": "GENDER"},
])

form_defs = [
    ('U23 Womens Interest Form v2 -- 18-23', 'womens'),
    ('U23 Mens Interest Form v2 -- 18-23',   'mens'),
    ('Brazil Mens Interest Form -- 18-32',   'brazil'),
    ('PR Mens Interest Form -- 18-32',       'pr'),
]
form_ids = {}
PRIVACY_POLICY = json.dumps({'url': 'https://footballhome.org/privacy', 'link_text': 'Privacy Policy'})
CONTEXT_CARD   = json.dumps({'style': 'LIST_STYLE', 'title': 'Join Lighthouse 1893 Soccer Club', 'content': ['Express your interest. We will be in touch with next steps.'], 'button_text': 'Continue'})
THANK_YOU      = json.dumps({'title': 'Thanks for your interest!', 'body': 'A Lighthouse 1893 coach will reach out to you soon.', 'button_type': 'VIEW_WEBSITE', 'button_text': 'Visit Website', 'website_url': 'https://footballhome.org'})

for name, key in form_defs:
    r = api_post(f'{PAGE_ID}/leadgen_forms', {
        'name': name, 'questions': questions,
        'privacy_policy': PRIVACY_POLICY,
        'context_card': CONTEXT_CARD,
        'thank_you_page': THANK_YOU,
        'locale': 'EN_US',
        'follow_up_action_url': 'https://footballhome.org',
    })
    form_ids[key] = r['id']
    print(f'  {key}: {r["id"]}')

# ── 2. Create new creatives ───────────────────────────────────────────
print('\n=== 2. Creating creatives ===')

creatives = {
    'womens': {
        'name':       'U23 Womens Creative v6 DOB+Gender 2026-05-24',
        'image_hash': '98c96b25401ff36bc6509841226cadc9',
        'message':    '\u26bd NOW FORMING: LIGHTHOUSE WOMEN\u2019S CLUB U23!\n\nLighthouse Women\u2019s Club U23 is forming a team in partnership with CASA Soccer!\n\n\U0001f4c5 First Match: May 31, 2026 \u2014 7 DAYS AWAY!\n\U0001f3c6 League: CASA Soccer \u00b7 Philadelphia\n\U0001f4cd Philadelphia, PA\n\U0001f3af Open to ALL players \u00b7 Ages 16\u201323 eligible\n\nSpots are filling fast \u2014 sign up now before it\u2019s too late!\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #WomensSoccer',
        'headline':   'Join Lighthouse U23 Women\u2019s Team \u2014 Game May 31',
    },
    'mens': {
        'name':       'U23 Mens Creative v3 DOB+Gender 2026-05-24',
        'image_hash': 'c65a072cc0fd15cc54ae4c9e1e5c4ff5',
        'message':    '\u26bd NOW FORMING: LIGHTHOUSE BOYS CLUB U23!\n\nLighthouse Boys Club U23 is forming a team in partnership with CASA Soccer!\n\n\U0001f4c5 First Match: May 31, 2026\n\U0001f3c6 League: CASA Soccer \u00b7 Philadelphia\n\U0001f4cd Philadelphia, PA\n\U0001f3af Open to ALL players \u00b7 Ages 16\u201323 eligible\n\nSpots are filling fast \u2014 sign up now!\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer',
        'headline':   'Join Lighthouse U23 Men\u2019s Team',
    },
    'brazil': {
        'name':       'Brazil Mens Creative v2 Native Form 2026-05-24',
        'image_hash': '762adb67f3a7c2fd8787079eb42327cc',
        'message':    '\U0001f1e7\U0001f1f7 WE\u2019RE GOING TO THE PHILLY GRASSROOTS CUP \u2014 BRAZIL TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Brazil team in the 2026 Philly Grassroots Cup!\n\n\U0001f3c6 3-game group stage + knockouts \u00b7 12 Nations\n\U0001f4c5 First match: June 7, 2026\n\U0001f4cd Philadelphia, PA\n\n\U0001f30e Open to ALL players \u2014 You do not have to be Brazilian!\n\u26a0\ufe0f Spots are limited and filling fast!\n\n#PhillyGrassrootsCup #Brazil #Lighthouse1893 #PhillySoccer #CASASoccer',
        'headline':   'Join the Brazil Team \u2014 Philly Grassroots Cup',
    },
    'pr': {
        'name':       'PR Mens Creative v2 Native Form 2026-05-24',
        'image_hash': '476b8763f5f917588ad0d9bca009e674',
        'message':    '\U0001f1f5\U0001f1f7 WE\u2019RE GOING TO THE PHILLY GRASSROOTS CUP \u2014 PUERTO RICO TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Puerto Rico team in the 2026 Philly Grassroots Cup!\n\n\U0001f3c6 3-game group stage + knockouts \u00b7 12 Nations\n\U0001f4c5 First match: June 7, 2026\n\U0001f4cd Philadelphia, PA\n\n\U0001f30e Open to ALL players \u2014 You do not have to be Puerto Rican!\n\u26a0\ufe0f Spots are limited and filling fast!\n\n#PhillyGrassrootsCup #PuertoRico #Lighthouse1893 #PhillySoccer #CASASoccer',
        'headline':   'Join the Puerto Rico Team \u2014 Philly Grassroots Cup',
    },
}

creative_ids = {}
for key, c in creatives.items():
    r = api_post(f'{AD_ACCT}/adcreatives', {
        'name': c['name'],
        'object_story_spec': json.dumps({
            'page_id': PAGE_ID,
            'link_data': {
                'link':       'https://footballhome.org/',
                'message':    c['message'],
                'name':       c['headline'],
                'image_hash': c['image_hash'],
                'call_to_action': {
                    'type':  'SIGN_UP',
                    'value': {'lead_gen_form_id': form_ids[key]},
                },
            },
        }),
    })
    creative_ids[key] = r['id']
    print(f'  {key}: {r["id"]}')

# ── 3. Update ads with new creatives ─────────────────────────────────
print('\n=== 3. Updating ads ===')
ad_map = {
    'womens': '120244607214000390',
    'mens':   '120244607211660390',
    'brazil': '120244607212540390',
    'pr':     '120244607213610390',
}
for key, ad_id in ad_map.items():
    r = api_post(ad_id, {'creative': json.dumps({'creative_id': creative_ids[key]})})
    print(f'  {key} ad {ad_id}: {"ok" if r.get("success") else r}')

# ── 4. Update mens adset budgets to $20/day ───────────────────────────
print('\n=== 4. Updating budgets ===')
budget_map = {
    'mens':   '120244607109200390',  # $10 → $20
    'brazil': '120244607109510390',  # $10 → $20
    'pr':     '120244607109770390',  # $10 → $20
}
for key, adset_id in budget_map.items():
    r = api_post(adset_id, {'daily_budget': '2000'})
    print(f'  {key} adset {adset_id}: {"ok" if r.get("success") else r}')

# ── 5. Activate paused campaigns ─────────────────────────────────────
print('\n=== 5. Activating campaigns ===')
camp_map = {
    'mens':   '120244563341030390',
    'brazil': '120244562626350390',
    'pr':     '120244562558790390',
}
for key, camp_id in camp_map.items():
    r = api_post(camp_id, {'status': 'ACTIVE'})
    print(f'  {key} campaign {camp_id}: {"ok" if r.get("success") else r}')

print('\nDone.')
