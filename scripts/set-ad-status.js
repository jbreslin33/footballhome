#!/usr/bin/env node
// scripts/set-ad-status.js — Flip a Meta ad (and its parents) between ACTIVE / PAUSED
//
// Usage:
//   node scripts/set-ad-status.js <AD_ID> ACTIVE
//   node scripts/set-ad-status.js <AD_ID> PAUSED
//
// Sets status on the ad, its ad set, and its campaign — needed for the whole
// thing to actually run (any level paused will block delivery).

require('dotenv').config({ path: __dirname + '/../env' });

const ACCESS_TOKEN = process.env.META_ADS_TOKEN;
const API          = 'https://graph.facebook.com/v21.0';

const adId  = process.argv[2];
const state = (process.argv[3] || '').toUpperCase();

if (!adId || !['ACTIVE', 'PAUSED'].includes(state)) {
  console.error('Usage: node scripts/set-ad-status.js <AD_ID> ACTIVE|PAUSED');
  process.exit(1);
}
if (!ACCESS_TOKEN) {
  console.error('Missing META_ADS_TOKEN in env');
  process.exit(1);
}

async function apiGet(path, fields) {
  const u = `${API}/${path}?fields=${fields}&access_token=${encodeURIComponent(ACCESS_TOKEN)}`;
  const r = await fetch(u);
  const j = await r.json();
  if (j.error) throw new Error(JSON.stringify(j.error));
  return j;
}

async function apiPost(path, params) {
  const body = new URLSearchParams({ ...params, access_token: ACCESS_TOKEN });
  const r = await fetch(`${API}/${path}`, { method: 'POST', body });
  const j = await r.json();
  if (j.error) throw new Error(JSON.stringify(j.error));
  return j;
}

(async () => {
  console.log(`🔍 Looking up ad ${adId}...`);
  const ad = await apiGet(adId, 'adset_id,campaign_id,name,effective_status');
  console.log(`   Ad:       ${ad.name}`);
  console.log(`   Ad Set:   ${ad.adset_id}`);
  console.log(`   Campaign: ${ad.campaign_id}`);
  console.log(`   Current:  ${ad.effective_status}\n`);

  console.log(`📡 Setting all 3 levels → ${state}...`);
  // Campaign first, then adset, then ad
  for (const [label, id] of [['Campaign', ad.campaign_id], ['Ad Set', ad.adset_id], ['Ad', adId]]) {
    const res = await apiPost(id, { status: state });
    console.log(`   ${label.padEnd(8)} ${id} → ${state}  (${res.success ? 'OK' : JSON.stringify(res)})`);
  }

  console.log(`\n✅ Done. ${state === 'ACTIVE' ? 'Ad is now LIVE and will start spending budget.' : 'Ad is PAUSED — no spend.'}`);
})().catch(err => {
  console.error('❌ Failed:', err.message);
  process.exit(1);
});
