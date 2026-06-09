#!/usr/bin/env node
// scripts/fix-ad-geo.js — Reset every active ad set to a strict Erie-Ave pin
//
// Why: APSL Trials was leaking 99.95% of impressions to California despite
// being "configured" for Philadelphia +30mi. Cause is Advantage+ Audience
// expansion treating your geo as a suggestion. This script:
//
//   1. Replaces geo_locations with a custom pin at 199 East Erie Ave
//      • 5mi for youth ads
//      • 10mi for adult/men's ads
//   2. Forces location_types = ['home'] (people LIVING there, not visitors)
//   3. Disables Advantage+ Audience expansion via targeting_automation
//
// Usage:
//   node scripts/fix-ad-geo.js --dry-run     # show planned changes only
//   node scripts/fix-ad-geo.js               # apply

require('dotenv').config({ path: __dirname + '/../env' });

const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';
const DRY_RUN       = process.argv.includes('--dry-run');

if (!AD_ACCOUNT_ID || !ACCESS_TOKEN) {
  console.error('Missing META_AD_ACCOUNT_ID or META_ADS_TOKEN in env');
  process.exit(1);
}

// Pin: Lighthouse Sports & Entertainment Complex
// Coordinates verified via Nominatim geocode of the full address (June 2026)
const PIN = {
  latitude:  40.0071,
  longitude: -75.1306,
  distance_unit: 'mile',
  address_string: '199 East Erie Avenue, Philadelphia, PA 19140',
};

// Radius rule: 5mi for youth-style adsets (name match), 10mi for everything else.
function radiusFor(adsetName) {
  return /Youth|Boys Club|Girls Club|Grades/i.test(adsetName) ? 5 : 10;
}

async function gj(url) {
  const r = await fetch(url);
  const j = await r.json();
  if (j.error) throw new Error(j.error.message);
  return j;
}

async function postForm(path, params) {
  const body = new URLSearchParams({ ...params, access_token: ACCESS_TOKEN });
  const r = await fetch(`${API}/${path}`, { method: 'POST', body });
  return r.json();
}

(async () => {
  console.log(`\n${DRY_RUN ? '🔎 DRY RUN' : '⚙️  APPLYING'} — Fix ad-set targeting on every ACTIVE adset\n`);

  // Discover ALL active adsets in the account (avoids stale hardcoded IDs).
  const adsetList = await gj(
    `${API}/${AD_ACCOUNT_ID}/adsets` +
    `?fields=id,name,effective_status,targeting` +
    `&limit=200&access_token=${ACCESS_TOKEN}`
  );
  const activeAdsets = (adsetList.data || []).filter(s => s.effective_status === 'ACTIVE');
  console.log(`Found ${activeAdsets.length} ACTIVE ad set(s)\n`);

  for (const adset of activeAdsets) {
    const radius  = radiusFor(adset.name);
    const current = adset.targeting || {};

    // Build the NEW targeting: keep everything (ages, genders, placements, etc.),
    // but overwrite geo_locations AND force Advantage+ Audience expansion OFF.
    const next = {
      ...current,
      geo_locations: {
        custom_locations: [{ ...PIN, radius }],
        location_types: ['home'],
      },
      // The API stores Advantage+ Audience setting *inside* targeting under
      // targeting_automation.advantage_audience (0 = OFF). Sending it as a
      // sibling param to `targeting` is silently ignored.
      targeting_automation: { advantage_audience: 0 },
    };
    // Strip any read-only / computed fields Meta won't accept on write
    delete next.targeting_optimization;

    console.log(`▸ Ad set: ${adset.name}  (${adset.id})`);
    console.log(`  BEFORE:    ${JSON.stringify(current.geo_locations)}`);
    console.log(`  BEFORE aud: ${current.targeting_automation?.advantage_audience ?? 'unset'}`);
    console.log(`  AFTER:     pin Erie Ave +${radius}mi, location_types=[home], advantage_audience=0`);

    if (DRY_RUN) { console.log(''); continue; }

    const res = await postForm(adset.id, {
      targeting: JSON.stringify(next),
    });
    if (res.error) {
      console.log(`  ❌ ERROR: ${res.error.message}`);
      console.log(`     code=${res.error.code} subcode=${res.error.error_subcode} type=${res.error.type}`);
      if (res.error.error_user_msg)   console.log(`     user_msg: ${res.error.error_user_msg}`);
      if (res.error.error_user_title) console.log(`     user_title: ${res.error.error_user_title}`);
      console.log('');
    } else {
      // Read back to confirm the field stuck
      const check = await gj(`${API}/${adset.id}?fields=targeting&access_token=${ACCESS_TOKEN}`);
      const audAfter = check.targeting?.targeting_automation?.advantage_audience;
      const ok = audAfter === 0;
      console.log(`  ${ok ? '✅' : '⚠️ '} Updated  (verified advantage_audience=${audAfter})\n`);
    }
  }

  if (DRY_RUN) {
    console.log('🔎 Dry run complete — no changes made. Re-run without --dry-run to apply.\n');
  } else {
    console.log('✅ Done. Re-run `node scripts/show-ad-geo.js` to verify.\n');
    console.log('⚠️  Also check in Ads Manager UI:');
    console.log('   - Campaign-level Advantage+ settings (some can\'t be set via API)');
    console.log('   - Each ad set → Audience → ensure "Advantage+ Audience" toggle is OFF');
  }
})().catch(e => { console.error('ERROR:', e.message); process.exit(1); });
