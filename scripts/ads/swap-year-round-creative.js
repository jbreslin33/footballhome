#!/usr/bin/env node
// scripts/ads/swap-year-round-creative.js — put a fresh graphic + caption on
// the LIVE year-round ads without touching their ad sets (budget, targeting,
// learning history) or lead forms.  A Meta creative can't be edited, so each
// ad gets a new creative copied from its current one with:
//   image  ← frontend/images/posts/<card>.png  (scripts/generate-year-round-cards.js)
//   text   ← message_templates meta_ad_caption/<tier>
// and the ad is pointed at it (Meta re-reviews the ad).
//
// Usage: node scripts/ads/swap-year-round-creative.js [--dry-run] [youth|mens|womens ...]
// First used 2026-11-13 (youth Grades K–10 (Ages 6–15), mig 1351; adult
// leagues, mig 1352).

const path = require('path');
const fs = require('fs');
const { execFileSync } = require('child_process');
const REPO_ROOT = path.resolve(__dirname, '..', '..');
require('dotenv').config({ path: path.join(REPO_ROOT, 'env') });

const TOKEN = process.env.META_ADS_TOKEN;
const ACCT = (process.env.META_AD_ACCOUNT_ID || '').startsWith('act_')
  ? process.env.META_AD_ACCOUNT_ID : 'act_' + process.env.META_AD_ACCOUNT_ID;
const API = 'https://graph.facebook.com/v21.0';

// Which live ad is which: ad name pattern → card file + caption tier.
const ADS = {
  youth:  { match: /Lighthouse Youth — Soccer All Year Round/, card: 'youth-year-round-ad.png',  tier: 'youth-year-round' },
  mens:   { match: /Lighthouse Mens Club — Soccer All Year Round/, card: 'mens-year-round-ad.png', tier: 'mens-year-round' },
  womens: { match: /Lighthouse Women's Club 1895 — Soccer All Year Round/, card: 'womens-year-round-ad.png', tier: 'womens-year-round' },
};

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const only = args.filter(a => !a.startsWith('--'));
const keys = only.length ? only : Object.keys(ADS);

async function graph(method, p, params = {}) {
  const body = new URLSearchParams({ ...params, access_token: TOKEN });
  const url = method === 'GET' ? `${API}/${p}?${body}` : `${API}/${p}`;
  const res = await fetch(url, method === 'GET' ? {} : { method, body });
  const j = await res.json();
  if (j.error) throw new Error(`${method} ${p}: ${j.error.error_user_msg || j.error.message}`);
  return j;
}

function caption(tier) {
  const sql = `SELECT body FROM message_templates WHERE kind='meta_ad_caption' AND tier='${tier}'`;
  return execFileSync('sudo', ['podman', 'exec', 'footballhome_db', 'psql', '-U', 'footballhome_user',
    '-d', 'footballhome', '-tA', '-c', sql], { stdio: ['ignore', 'pipe', 'inherit'] }).toString().replace(/\n$/, '');
}

(async () => {
  const live = await graph('GET', `${ACCT}/ads`, {
    // A switched-on ad back in review after an edit is still the live ad.
    effective_status: '["ACTIVE","IN_PROCESS","PENDING_REVIEW","PREAPPROVED","WITH_ISSUES"]',
    fields: 'id,name,creative{id,object_story_spec,instagram_user_id,degrees_of_freedom_spec}',
    limit: 50,
  });
  for (const key of keys) {
    const cfg = ADS[key];
    if (!cfg) { console.log(`? unknown ad key ${key}`); continue; }
    const ad = live.data.find(a => cfg.match.test(a.name));
    if (!ad) { console.log(`- ${key}: no live ad matches`); continue; }
    const message = caption(cfg.tier);
    if (!message) throw new Error(`no caption row for ${cfg.tier}`);
    const file = path.join(REPO_ROOT, 'frontend', 'images', 'posts', cfg.card);
    console.log(`\n== ${key}: ad ${ad.id} (${ad.name})\n   image ${cfg.card}\n   caption ${message.split('\n').length} lines`);
    if (dryRun) continue;

    const up = await graph('POST', `${ACCT}/adimages`, { bytes: fs.readFileSync(file).toString('base64') });
    const hash = Object.values(up.images)[0].hash;

    const old = ad.creative;
    const spec = JSON.parse(JSON.stringify(old.object_story_spec));
    spec.link_data.message = message;
    spec.link_data.image_hash = hash;
    delete spec.link_data.picture;
    const params = {
      name: `${message.split('\n')[0].slice(0, 60)} ${new Date().toISOString().slice(0, 10)}-${hash.slice(0, 8)}`,
      object_story_spec: JSON.stringify(spec),
    };
    if (old.instagram_user_id) params.instagram_user_id = old.instagram_user_id;
    if (old.degrees_of_freedom_spec) params.degrees_of_freedom_spec = JSON.stringify(old.degrees_of_freedom_spec);
    let created;
    try {
      created = await graph('POST', `${ACCT}/adcreatives`, params);
    } catch (e) {
      // Some enhancement keys Meta reports back can't be sent in; the ad
      // still opts out of everything we don't send.
      console.log(`   creative with old enhancement spec refused (${e.message}); retrying without`);
      delete params.degrees_of_freedom_spec;
      created = await graph('POST', `${ACCT}/adcreatives`, params);
    }
    await graph('POST', ad.id, { creative: JSON.stringify({ creative_id: created.id }) });
    const back = await graph('GET', ad.id, { fields: 'effective_status,creative{id,object_story_spec{link_data{image_hash}}}' });
    console.log(`   creative ${old.id} → ${back.creative.id} (image ${back.creative.object_story_spec.link_data.image_hash}), ad now ${back.effective_status}`);
  }
})().catch(e => { console.error('✗', e.message); process.exit(1); });
