#!/usr/bin/env python3
"""
Create two Meta lead-ad forms for the split Boys Club / Girls Club youth ads.

Form structure (identical for both, except titles/cards):
    - FULL_NAME      (standard, auto-prefilled from FB profile)
    - EMAIL          (standard, auto-prefilled)
    - PHONE          (standard, auto-prefilled)
    - CUSTOM         "Grade entering Fall 2026" (multi-choice K, 1, 2, 3, 4, 5, 6)

Thank-you screen has a single button that goes straight to the program's
$1 LeagueApps registration page.

After running, prints the two new form IDs ready to paste into
formLabel() in frontend/js/screens/leads.js:

    'Boys Club (Grades 1-6)':  <BOYS_FORM_ID>
    'Girls Club (Grades 1-6)': <GIRLS_FORM_ID>

Requires META_ADS_TOKEN env var (Page-scoped access token with
leads_retrieval + pages_show_list + pages_manage_ads).
"""

import json
import os
import urllib.parse
import urllib.request

TOKEN   = os.environ['META_ADS_TOKEN']
PAGE_ID = '518090048060695'
API     = 'https://graph.facebook.com/v21.0'

BOYS_URL  = 'https://lighthouse1893.leagueapps.com/leagues/soccer/5039252-lighthouse-1893-boys-club-soccer-membership'
GIRLS_URL = 'https://lighthouse1893.leagueapps.com/leagues/soccer/5039357-lighthouse-1893-girls-club-soccer-membership'

PRIVACY_POLICY_URL = 'https://footballhome.org/privacy'


def api_post(path, data):
    data['access_token'] = TOKEN
    body = urllib.parse.urlencode(data).encode()
    req = urllib.request.Request(
        f'{API}/{path}',
        data=body,
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
        method='POST',
    )
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        err = json.loads(e.read())
        raise Exception(f'API error {e.code} on {path}: {err}') from None


# Multi-choice grade question. Use `key` for stable field ID in webhook
# payload so the value doesn't shift if we ever rename the label.
GRADE_QUESTION = {
    'type':  'CUSTOM',
    'key':   'grade_fall_2026',
    'label': 'Grade entering Fall 2026',
    'options': [
        {'value': 'K'},
        {'value': '1st'},
        {'value': '2nd'},
        {'value': '3rd'},
        {'value': '4th'},
        {'value': '5th'},
        {'value': '6th'},
    ],
}

QUESTIONS = json.dumps([
    {'type': 'FULL_NAME'},
    {'type': 'EMAIL'},
    {'type': 'PHONE'},
    GRADE_QUESTION,
])

PRIVACY_POLICY = json.dumps({
    'url':       PRIVACY_POLICY_URL,
    'link_text': 'Privacy Policy',
})


def build_form(form_name, program_label, register_url):
    """Create one lead form. Returns the new form ID."""
    context_card = json.dumps({
        'style':       'LIST_STYLE',
        'title':       f'Lighthouse 1893 {program_label} — Grades K-6',
        'content': [
            f'Parents: enter your contact info, then tell us your player\'s grade for Fall 2026.',
        ],
        'button_text': 'Continue',
    })
    thank_you = json.dumps({
        'title':       'Thanks! Final step:',
        'body':        'Tap below to lock in your player\'s spot for $1. A Lighthouse 1893 coach will also reach out.',
        'button_type': 'VIEW_WEBSITE',
        'button_text': 'Complete Registration ($1)',
        'website_url': register_url,
    })
    r = api_post(f'{PAGE_ID}/leadgen_forms', {
        'name':                  form_name,
        'questions':             QUESTIONS,
        'privacy_policy':        PRIVACY_POLICY,
        'context_card':          context_card,
        'thank_you_page':        thank_you,
        'locale':                'EN_US',
        'follow_up_action_url':  register_url,
    })
    return r['id']


def main():
    print('=== Creating Lighthouse 1893 youth lead forms ===\n')

    boys_id = build_form(
        form_name     = 'Lighthouse 1893 Boys Club -- Grade Inquiry K-6',
        program_label = 'Boys Club',
        register_url  = BOYS_URL,
    )
    print(f'  Boys Club form:  {boys_id}')

    girls_id = build_form(
        form_name     = 'Lighthouse 1893 Girls Club -- Grade Inquiry K-6',
        program_label = 'Girls Club',
        register_url  = GIRLS_URL,
    )
    print(f'  Girls Club form: {girls_id}')

    print()
    print('=== Done. Paste these into frontend/js/screens/leads.js -> formLabel() ===\n')
    print(f"      '{boys_id}':  'Boys Club (Grades 1-6)',")
    print(f"      '{girls_id}': 'Girls Club (Grades 1-6)',")
    print()


if __name__ == '__main__':
    main()
