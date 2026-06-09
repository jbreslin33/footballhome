#!/usr/bin/env node
// scripts/apply-zip-allowlist.js — Replace each active adset's geo_locations
// with an explicit ZIP allowlist (much stricter than radius targeting).
//
// Why: Even with a 5/10mi pin + location_types=['home'] + Advantage+ OFF,
// Meta's radius can still bleed to neighboring states/counties at the edges.
// An explicit ZIP allowlist ("zips": [...]) is a hard fence — only people
// whose home ZIP is in the list will be served the ad.
//
// Adset → list assignment is by name match:
//   /Youth|Boys Club|Girls Club|Grades/i  →  youth_5mi_pa_only   (PA-only)
//   everything else                       →  adult_10mi_pa_nj    (PA + NJ)
//
// Lists are read from config/ad-targeting-zips.json. Edit that file to
// add/remove ZIPs and re-run.
//
// Usage:
//   node scripts/apply-zip-allowlist.js --dry-run   # preview only
//   node scripts/apply-zip-allowlist.js             # apply

require('dotenv').config({ path: __dirname + '/../env' });
const fs = require('fs');
const path = require('path');

const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';
const DRY_RUN       = process.argv.includes('--dry-run');

if (!AD_ACCOUNT_ID || !ACCESS_TOKEN) {
  console.error('Missing META_AD_ACCOUNT_ID or META_ADS_TOKEN in env');
  process.exit(1);
}

const CFG = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'config', 'ad-targeting-zips.json'), 'utf8'));
const YOUTH_ZIPS = CFG.youth_5mi_pa_only;
const ADULT_ZIPS = CFG.adult_10mi_pa_nj;

function zipsFor(adsetName) {
  return /Youth|Boys Club|Girls Club|Grades/i.test(adsetName)
    ? { list: YOUTH_ZIPS, label: 'youth_5mi_pa_only' }
    : { list: ADULT_ZIPS, label: 'adult_10mi_pa_nj' };
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
  console.log(`\n${DRY_RUN ? '🔎 DRY RUN' : '⚙️  APPLYING'} — Replace adset geo with ZIP allowlist\n`);
  console.log(`Youth list: ${YOUTH_ZIPS.length} ZIPs (PA only)`);
  console.log(`Adult list: ${ADULT_ZIPS.length} ZIPs (PA + NJ)\n`);

  const adsetList = await gj(
    `${API}/${AD_ACCOUNT_ID}/adsets` +
    `?fields=id,name,effective_status,targeting` +
    `&limit=200&access_token=${ACCESS_TOKEN}`
  );
  const activeAdsets = (adsetList.data || []).filter(s => s.effective_status === 'ACTIVE');
  console.log(`Found ${activeAdsets.length} ACTIVE ad set(s)\n`);

  for (const adset of activeAdsets) {
    const pick    = zipsFor(adset.name);
    const current = adset.targeting || {};
    const prevGeo = current.geo_locations || {};

    const next = {
      ...current,
      geo_locations: {
        // Hard allowlist: explicit ZIPs only. No custom_locations / cities /
        // regions — Meta will OR these together, which would widen the geo.
        zips: pick.list.map(z => ({ key: `US:${z}` })),
        location_types: ['home'],
      },
      targeting_automation: { advantage_audience: 0 },
    };
    delete next.targeting_optimization;

    console.log(`▸ Ad set: ${adset.name}  (${adset.id})`);
    console.log(`  Using:   ${pick.label}  (${pick.list.length} ZIPs)`);
    console.log(`  BEFORE:  ${prevGeo.custom_locations ? `pin +${prevGeo.custom_locations[0]?.radius}mi` : prevGeo.zips ? `${prevGeo.zips.length} zips` : '(unknown)'}, types=[${(prevGeo.location_types || []).join(',')}]`);
    console.log(`  AFTER:   ${pick.list.length} ZIP allowlist, types=[home], advantage_audience=0`);

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
      const check = await gj(`${API}/${adset.id}?fields=targeting&access_token=${ACCESS_TOKEN}`);
      const zipsAfter = check.targeting?.geo_locations?.zips?.length ?? 0;
      const audAfter  = check.targeting?.targeting_automation?.advantage_audience;
      const ok = zipsAfter === pick.list.length && audAfter === 0;
      console.log(`  ${ok ? '✅' : '⚠️ '} Updated  (verified ${zipsAfter} zips, advantage_audience=${audAfter})\n`);
    }
  }

  if (DRY_RUN) {
    console.log('🔎 Dry run complete — no changes made. Re-run without --dry-run to apply.\n');
  } else {
    console.log('✅ Done. Re-run `node scripts/show-ad-geo.js` to verify.\n');
  }
})().catch(e => { console.error('ERROR:', e.message); process.exit(1); });
