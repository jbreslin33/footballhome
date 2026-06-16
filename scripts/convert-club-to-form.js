#!/usr/bin/env node
// scripts/convert-club-to-form.js
//
// Converts the live Men's Club (APSL/Liga 1) + Women's Club (Tri County)
// ads from direct-CTA → native Meta lead form, mirroring the slim form
// pattern used for the K-12 ads but with one extra question (DOB) so we
// know the player's age before reaching out.  The graphic on each ad
// already says MENS CLUB / WOMENS CLUB so we drop the redundant GENDER
// field that the Brazil form template carried.
//
// Form schema (4 questions — all auto-prefilled from Facebook profile):
//     1. FULL_NAME
//     2. EMAIL
//     3. PHONE
//     4. DOB         (kept — coach needs it; not used to gate the form)
//
// Adset targeting:
//     We also widen each adset's age targeting to 18..65 (Meta's full
//     range) so anyone who taps "Sign Up" can submit regardless of age.
//     The form itself never gates by age — only adset targeting does.
//
// Template form: Brazil Mens Interest Form (1333581472007910).  Copy
// privacy / locale / thank-you / context-card from there; replace the
// 5-question schema with the 4-question slim variant above.
//
// LEARNING-PHASE COST:
//     Re-pointing the creative AND changing the adset targeting both
//     reset Meta's Learning Phase (~50 conversions / 7 days, elevated
//     CPL).  Acceptable — these ads currently produce zero attributable
//     leads (direct-CTA → LeagueApps with no Meta-side capture).
//
// SAFETY:
//     Nothing is deleted.  Old creatives + old age targeting can be
//     reverted from Ads Manager → Ad History.  Use --dry-run first.
//
// USAGE:
//     node scripts/convert-club-to-form.js --dry-run
//     node scripts/convert-club-to-form.js                 # both clubs
//     node scripts/convert-club-to-form.js mens
//     node scripts/convert-club-to-form.js womens

require('dotenv').config({ path: __dirname + '/../env' });

const PAGE_ID       = process.env.META_PAGE_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const API           = 'https://graph.facebook.com/v21.0';

const args = process.argv.slice(2);
const DRY  = args.includes('--dry-run');

// Brazil form has the full 5-question schema (FULL_NAME / EMAIL / PHONE
// / DOB / GENDER).  We copy its privacy + thank-you + context-card and
// replace its `questions` with the 4-question variant for these ads.
const TEMPLATE_FORM_ID = '1333581472007910';

const FUNNELS = {
  mens: {
    label:       "Men's Club",
    adId:        '120246234566750390',
    formNameTag: "Lighthouse Men's Club (APSL / Liga 1) — slim — name/email/phone/dob",
  },
  womens: {
    label:       "Women's Club",
    adId:        '120246234573510390',
    formNameTag: "Lighthouse Women's Club (Tri County) — slim — name/email/phone/dob",
  },
};

const positional = args.filter(a => !a.startsWith('--'));
const targets = positional.length
  ? positional.map(s => s.toLowerCase()).filter(k => FUNNELS[k])
  : Object.keys(FUNNELS);

if (!PAGE_ID || !ACCESS_TOKEN || !AD_ACCOUNT_ID) {
  console.error('Missing META_PAGE_ID, META_ADS_TOKEN or META_AD_ACCOUNT_ID in env');
  process.exit(1);
}
if (!targets.length) {
  console.error(`No matching funnels.  Available: ${Object.keys(FUNNELS).join(', ')}`);
  process.exit(1);
}

// ── Tiny Graph API helpers ─────────────────────────────────────────────
async function apiGet(pathStr, params = {}) {
  const u = new URL(`${API}/${pathStr}`);
  for (const [k, v] of Object.entries(params)) u.searchParams.append(k, v);
  u.searchParams.append('access_token', ACCESS_TOKEN);
  const r = await fetch(u);
  const d = await r.json();
  if (d.error) throw new Error(`GET ${pathStr}: ${JSON.stringify(d.error)}`);
  return d;
}

async function apiPost(pathStr, body) {
  const form = new URLSearchParams();
  for (const [k, v] of Object.entries(body)) form.append(k, v);
  form.append('access_token', ACCESS_TOKEN);
  const r = await fetch(`${API}/${pathStr}`, { method: 'POST', body: form });
  const d = await r.json();
  if (d.error) throw new Error(`POST ${pathStr}: ${JSON.stringify(d.error)}`);
  return d;
}

// Walk an object tree removing read-only `id` keys (Meta returns them
// on GET but rejects them on POST for thank_you_page / context_card).
function stripIds(obj) {
  if (Array.isArray(obj)) return obj.map(stripIds);
  if (obj && typeof obj === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(obj)) {
      if (k === 'id') continue;
      out[k] = stripIds(v);
    }
    return out;
  }
  return obj;
}

async function fetchForm(formId) {
  return apiGet(formId, {
    fields: [
      'id', 'name', 'locale', 'privacy_policy_url', 'follow_up_action_url',
      'thank_you_page', 'context_card', 'questions', 'status',
    ].join(','),
  });
}

// Create the club form on the page using the Brazil form as a template,
// but with a 4-question slim schema (no GENDER).
async function createClubForm(srcForm, formNameTag) {
  const body = {
    name:    `${formNameTag} — ${new Date().toISOString().slice(0,10)}`,
    locale:  srcForm.locale || 'en_US',
    questions: JSON.stringify([
      { type: 'FULL_NAME' },
      { type: 'EMAIL' },
      { type: 'PHONE' },
      { type: 'DOB' },
    ]),
  };
  if (srcForm.privacy_policy_url) {
    body.privacy_policy = JSON.stringify({ url: srcForm.privacy_policy_url });
  }
  if (srcForm.follow_up_action_url) body.follow_up_action_url = srcForm.follow_up_action_url;
  if (srcForm.thank_you_page)       body.thank_you_page       = JSON.stringify(stripIds(srcForm.thank_you_page));
  if (srcForm.context_card)         body.context_card         = JSON.stringify(stripIds(srcForm.context_card));
  return apiPost(`${PAGE_ID}/leadgen_forms`, body);
}

// Clone the ad's creative replacing the direct link CTA with a lead form.
// Keep link_data.link as a fallback (Meta accepts both fields on a
// SIGN_UP CTA — the form fires first, link is the post-submit hop).
async function cloneCreativeAsLeadForm(ad, newFormId) {
  const creative = await apiGet(ad.creative.id, { fields: 'name,object_story_spec' });
  const spec = JSON.parse(JSON.stringify(creative.object_story_spec || {}));
  if (!spec.link_data) throw new Error(`Creative ${creative.id} has no link_data`);

  const oldVal = spec.link_data.call_to_action?.value || {};
  spec.link_data.call_to_action = {
    type:  'SIGN_UP',
    value: {
      lead_gen_form_id: newFormId,
      ...(oldVal.link ? { link: oldVal.link } : {}),
    },
  };

  return apiPost(`${AD_ACCOUNT_ID}/adcreatives`, {
    name: `${creative.name || 'creative'} — club lead form ${new Date().toISOString().slice(0,10)}`,
    object_story_spec: JSON.stringify(spec),
  });
}

// Widen adset age targeting to 18..65 (Meta's full range).  Preserves
// every other targeting field — geo, interests, behaviors, etc.  age_min
// / age_max live INSIDE adset.targeting, not at the top level of adset.
async function widenAdsetAge(adsetId) {
  const adset = await apiGet(adsetId, { fields: 'id,name,targeting' });
  const t = adset.targeting || {};
  const before = { age_min: t.age_min, age_max: t.age_max };
  const newTargeting = { ...t, age_min: 18, age_max: 65 };
  // Strip read-only echo fields some accounts add on GET.
  delete newTargeting.targeting_optimization;
  await apiPost(adsetId, { targeting: JSON.stringify(newTargeting) });
  return { before, after: { age_min: 18, age_max: 65 } };
}

// ── Main ───────────────────────────────────────────────────────────────
(async () => {
  console.log(`Mode: ${DRY ? 'DRY-RUN (no writes)' : 'LIVE'}`);
  console.log(`Targets: ${targets.join(', ')}`);
  console.log(`Template form: ${TEMPLATE_FORM_ID}\n`);

  const tpl = await fetchForm(TEMPLATE_FORM_ID);
  console.log(`Template name:      ${tpl.name}`);
  console.log(`Template questions: ${(tpl.questions || []).map(q => q.key || q.type).join(', ')}`);
  console.log(`Privacy / follow-up: ${tpl.privacy_policy_url} / ${tpl.follow_up_action_url}\n`);

  const results = [];
  for (const key of targets) {
    const f = FUNNELS[key];
    console.log(`=== ${key.toUpperCase()} — ${f.label} ===`);

    const ad = await apiGet(f.adId, {
      fields: 'id,name,effective_status,adset_id,creative{id,name,object_story_spec}',
    });
    const oldCre = ad.creative.id;
    const oldCta = ad.creative?.object_story_spec?.link_data?.call_to_action;
    console.log(`  ad: ${ad.id}  [${ad.effective_status}]  ${ad.name}`);
    console.log(`    adset       : ${ad.adset_id}`);
    console.log(`    current cre : ${oldCre}`);
    console.log(`    current CTA : ${JSON.stringify(oldCta)}`);

    if (DRY) {
      console.log(`  [dry-run] would: create slim 4-q form (no GENDER), clone creative w/ lead_gen_form_id, repoint ad, widen adset age → 18..65\n`);
      continue;
    }

    const newForm = await createClubForm(tpl, f.formNameTag);
    console.log(`  ✨ new form     : ${newForm.id}`);
    const newCre = await cloneCreativeAsLeadForm(ad, newForm.id);
    console.log(`  🎨 new creative : ${newCre.id}`);
    const upd = await apiPost(ad.id, { creative: JSON.stringify({ creative_id: newCre.id }) });
    console.log(`  🔁 ad ${ad.id} → creative ${newCre.id}  ${JSON.stringify(upd)}`);

    const ageDelta = await widenAdsetAge(ad.adset_id);
    console.log(`  📅 adset ${ad.adset_id} age: ${ageDelta.before.age_min}..${ageDelta.before.age_max} → ${ageDelta.after.age_min}..${ageDelta.after.age_max}`);

    results.push({
      funnel:      key,
      label:       f.label,
      adId:        ad.id,
      adsetId:     ad.adset_id,
      oldCreative: oldCre,
      newCreative: newCre.id,
      newFormId:   newForm.id,
      oldAge:      ageDelta.before,
    });
    console.log('');
  }

  if (results.length) {
    console.log('\n=== SUMMARY — paste into formLabel() in frontend/js/screens/leads.js ===\n');
    for (const r of results) {
      console.log(`      '${r.newFormId}': "${r.label}",`);
    }
    console.log('\nRevert recipe (per ad):');
    for (const r of results) {
      console.log(`  ad ${r.adId} (${r.label}) → re-point creative to ${r.oldCreative} ; restore adset ${r.adsetId} age to ${r.oldAge.age_min}..${r.oldAge.age_max}`);
    }
  }
})().catch(err => { console.error('\n❌ Failed:', err.message); process.exit(1); });
