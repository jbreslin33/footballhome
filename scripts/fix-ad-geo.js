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

// Ad-ID → desired radius (mi)
// (5mi for youth-style ads; 10mi for adult/men's ads)
const RADIUS_BY_AD = {
  '120245748851660390': 5,   // Youth (Grades 1–6)
  '120245251868650390': 10,  // APSL Trials
  '120244607213610390': 10,  // PR Men
  '120244607211660390': 10,  // U23 Men
  '120244607212540390': 10,  // Brazil Men
};

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
  console.log(`\n${DRY_RUN ? '🔎 DRY RUN' : '⚙️  APPLYING'} — Fix ad-set targeting\n`);

  // Pull current targeting + adset ids for each ad we care about
  const adIds = Object.keys(RADIUS_BY_AD).join(',');
  const fields = 'id,name,effective_status,adset{id,name,targeting}';
  const ads = (await gj(`${API}/?ids=${adIds}&fields=${encodeURIComponent(fields)}&access_token=${ACCESS_TOKEN}`));

  const adsetUpdates = new Map(); // adset_id -> { name, current, next, radius, adName }

  for (const adId of Object.keys(RADIUS_BY_AD)) {
    const ad = ads[adId];
    if (!ad) { console.log(`⚠️  ad ${adId} not found, skipping`); continue; }
    const adset  = ad.adset;
    const radius = RADIUS_BY_AD[adId];
    const current = adset.targeting || {};

    // Build the NEW targeting: keep everything (ages, genders, placements, etc.),
    // but overwrite geo_locations. targeting_automation goes at the adset
    // level (separate param), NOT inside targeting.
    const next = {
      ...current,
      geo_locations: {
        custom_locations: [{ ...PIN, radius }],
        location_types: ['home'],
      },
    };
    // Strip any read-only / computed fields Meta won't accept on write
    delete next.targeting_automation;
    delete next.targeting_optimization;

    // De-dup by adset id (ads can share an adset)
    adsetUpdates.set(adset.id, {
      adset_id: adset.id,
      adset_name: adset.name,
      ad_name: ad.name,
      radius,
      current_geo: current.geo_locations,
      next_geo: next.geo_locations,
      next_targeting: next,
    });
  }

  for (const u of adsetUpdates.values()) {
    console.log(`▸ Ad set: ${u.adset_name}  (${u.adset_id})`);
    console.log(`  Ad:        ${u.ad_name}`);
    console.log(`  BEFORE:    ${JSON.stringify(u.current_geo)}`);
    console.log(`  AFTER:     pin Erie Ave +${u.radius}mi, location_types=[home]`);
    console.log(`  Advantage+ Audience: OFF (targeting_automation.individual_setting=0)`);

    if (DRY_RUN) { console.log(''); continue; }

    const res = await postForm(u.adset_id, {
      targeting: JSON.stringify(u.next_targeting),
      targeting_automation: JSON.stringify({ individual_setting: 0 }),
    });
    if (res.error) {
      console.log(`  ❌ ERROR: ${res.error.message}`);
      console.log(`     code=${res.error.code} subcode=${res.error.error_subcode} type=${res.error.type}`);
      if (res.error.error_user_msg)   console.log(`     user_msg: ${res.error.error_user_msg}`);
      if (res.error.error_user_title) console.log(`     user_title: ${res.error.error_user_title}`);
      console.log('');
    } else {
      console.log(`  ✅ Updated\n`);
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
