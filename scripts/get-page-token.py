#!/usr/bin/env python3
import urllib.request, json, urllib.parse, sys

APP_ID     = '1177405337805460'
APP_SECRET = '62e4c3eb75bd665c7f36d857846292f1'
PAGE_ID    = '518090048060695'
API        = 'https://graph.facebook.com/v21.0'

SHORT_TOK = sys.argv[1]

def get(url):
    try:
        with urllib.request.urlopen(url) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        print('Error', e.code, json.loads(e.read()))
        sys.exit(1)

# Step 1: exchange for long-lived user token (60 days)
params = urllib.parse.urlencode({
    'grant_type': 'fb_exchange_token',
    'client_id': APP_ID,
    'client_secret': APP_SECRET,
    'fb_exchange_token': SHORT_TOK,
})
ll = get(f'{API}/oauth/access_token?{params}')
print('Long-lived expires in (seconds):', ll.get('expires_in'))
ll_token = ll['access_token']

# Step 2: get never-expiring Page Access Token
params2 = urllib.parse.urlencode({'fields': 'access_token', 'access_token': ll_token})
pg = get(f'{API}/{PAGE_ID}?{params2}')
page_token = pg['access_token']

print('\nPage Access Token (never expires):')
print(page_token)
