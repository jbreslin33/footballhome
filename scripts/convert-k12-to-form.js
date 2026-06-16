#!/usr/bin/env node
// scripts/convert-k12-to-form.js
//
// Converts the live K-12 Boys Club + Girls Club ads from direct-CTA
// (link straight to LeagueApps, no Meta lead form) to lead-form ads
// using the same slim form layout as the Grades 1-6 ads.
//
// WHY:
//   The K-12 ads have been live for weeks but produce zero on-platform
//   visibility — registrations only show up in LeagueApps and we can
//   only attribute by process-of-elimination against Grades 1-6 lead
//   emails.  Switching them to lead-form ads gives us:
//     - parent's name + email + phone captured before the LeagueApps
//       handoff (so we can follow up if they don't complete checkout)
//     - first-class column on the Leads page with real CPL numbers
//     - direct comparability with the Grades 1-6 funnel
//
// HOW:
//   For each club:
//     1. Fetch the existing Grades 1-6 slim form to use as a TEMPLATE
//        (same privacy policy URL, locale, follow-up URL, thank-you
//        page).  The K-12 form will reuse all of that — only the form
//        name changes so the coach can tell them apart in Ads Manager.
//     2. POST a new leadgen_form on the page with name/email/phone +
//        preferred_channel radio.  Same questions as Grades 1-6.
//     3. Look up the live K-12 ad (by ad name regex `(K-12)`).
//     4. Clone its creative, replacing
//          link_data.call_to_action.value.link
//        with
//          link_data.call_to_action.value.lead_gen_form_id
//        Keep the rest of the creative (image, copy, message) intact.
//        link_data.link stays — Meta requires a fallback link on lead
//        ads anyway and falling through to LeagueApps is the right
//        post-submit destination.
//     5. POST adcreatives → get new creative id.
//     6. Update the ad to point at the new creative_id.
//
// LEARNING-PHASE COST:
//   Re-pointing a live ad's creative resets the Learning Phase
//   (~50 conversions / 7 days, elevated CPL during).  Acceptable
//   tradeoff given the K-12 ads currently produce ~0 attributable
//   conversions.
//
// SAFETY:
//   - Nothing is deleted.  Old creatives remain.  Revert by re-pointing
//     the ad at the original creative id (printed at the start of each
//     conversion + visible in Ads Manager → Ad → History).
//   - Use --dry-run first to preview every action.
//
// USAGE:
//   node scripts/convert-k12-to-form.js --dry-run
//   node scripts/convert-k12-to-form.js                 # both clubs
//   node scripts/convert-k12-to-form.js boys
//   node scripts/convert-k12-to-form.js girls

require('dotenv').config({ path: __dirname + '/../env' });

const PAGE_ID       = process.env.META_PAGE_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const API           = 'https://graph.facebook.com/v21.0';

const args = process.argv.slice(2);
const DRY  = args.includes('--dry-run');

// One entry per K-12 funnel.
//   templateFormId : an existing slim Grades 1-6 form on the same page
//                    we copy locale + privacy + thank-you settings from.
//   adNameMatch    : regex against the ad's `name` field to find the
//                    live ad to convert.  Must match exactly one
//                    ACTIVE ad.
//   newFormName    : human label used both in the new form's name on
//                    Meta AND printed in the formLabel() snippet at the
//                    end so the coach knows what to paste into
//                    frontend/js/screens/leads.js.
const FUNNELS = {
  boys: {
    label:          'Boys Club (K-12)',
    templateFormId: '2471488896628970', // current slim Boys (Grades 1–6)
    adNameMatch:    /^Lighthouse Boys Club .* \(K-?12\)/i,
  },
  girls: {
    label:          'Girls Club (K-12)',
    templateFormId: '1008195014960429', // current slim Girls (Grades 1–6)
    adNameMatch:    /^Lighthouse Girls Club .* \(K-?12\)/i,
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

async function apiGetAll(pathStr, params = {}) {
  let next = null;
  const out = [];
  let first = true;
  while (first || next) {
    const data = first
      ? await apiGet(pathStr, { ...params, limit: 100 })
      : await (async () => {
          const r = await fetch(next);
          const d = await r.json();
          if (d.error) throw new Error(`GET (page): ${JSON.stringify(d.error)}`);
          return d;
        })();
    first = false;
    if (Array.isArray(data.data)) out.push(...data.data);
    next = data.paging && data.paging.next;
  }
  return out;
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

// Fetch the template form so we can copy privacy / thank-you / locale.
async function fetchForm(formId) {
  return apiGet(formId, {
    fields: [
      'id', 'name', 'locale', 'privacy_policy_url', 'follow_up_action_url',
      'thank_you_page', 'context_card', 'questions', 'status',
    ].join(','),
  });
}

// Create the K-12 form on the page.  Same questions as the live
// Grades 1-6 slim forms — name / email / phone, nothing else.  We
// originally tried adding a `preferred_channel` CUSTOM radio but
// Meta drops CUSTOM questions silently on create for some pages, so
// the live Grades 1-6 forms ended up with three questions and we
// match that exactly to keep K-12 lead schema identical.
async function createK12Form(srcForm, label) {
  const body = {
    name:    `Lighthouse — ${label} (slim — name/email/phone)`,
    locale:  srcForm.locale || 'en_US',
    questions: JSON.stringify([
      { type: 'FULL_NAME' },
      { type: 'EMAIL' },
      { type: 'PHONE' },
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

// Find the single live K-12 ad whose name matches the funnel regex.
async function findActiveK12Ad(adNameRegex) {
  const ads = await apiGetAll(`${AD_ACCOUNT_ID}/ads`, {
    fields: 'id,name,status,effective_status,creative{id,name,object_story_spec}',
  });
  const live = ads.filter(a =>
    a.effective_status === 'ACTIVE' && adNameRegex.test(a.name || '')
  );
  return live;
}

// Clone the ad's creative replacing the direct link CTA with a lead form.
// Keep link_data.link as a fallback (Meta accepts both fields on a
// SIGN_UP CTA — the form fires first, link is the post-submit hop).
async function cloneCreativeAsLeadForm(ad, newFormId) {
  const creative = await apiGet(ad.creative.id, { fields: 'name,object_story_spec' });
  const spec = JSON.parse(JSON.stringify(creative.object_story_spec || {}));
  if (!spec.link_data) throw new Error(`Creative ${creative.id} has no link_data`);

  // Force CTA to a lead-form CTA.  Drop the previous .value.link so the
  // form is the unambiguous primary action; .link_data.link remains
  // as the post-submit fallback.
  const oldVal = spec.link_data.call_to_action?.value || {};
  spec.link_data.call_to_action = {
    type:  'SIGN_UP',
    value: {
      lead_gen_form_id: newFormId,
      // preserve UTM-tagged link as the post-submit / fallback target
      ...(oldVal.link ? { link: oldVal.link } : {}),
    },
  };

  return apiPost(`${AD_ACCOUNT_ID}/adcreatives`, {
    name: `${creative.name || 'creative'} — K-12 lead form ${new Date().toISOString().slice(0,10)}`,
    object_story_spec: JSON.stringify(spec),
  });
}

// ── Main ───────────────────────────────────────────────────────────────
(async () => {
  console.log(`Mode: ${DRY ? 'DRY-RUN (no writes)' : 'LIVE'}`);
  console.log(`Targets: ${targets.join(', ')}\n`);

  const results = [];
  for (const key of targets) {
    const f = FUNNELS[key];
    console.log(`=== ${key.toUpperCase()} — ${f.label} ===`);
    console.log(`template form: ${f.templateFormId}`);

    const tpl  = await fetchForm(f.templateFormId);
    const qNames = (tpl.questions || []).map(q => q.key || q.type).join(', ');
    console.log(`  template name:      ${tpl.name}`);
    console.log(`  template questions: ${qNames}`);
    console.log(`  follow_up_url:      ${tpl.follow_up_action_url || '(none)'}`);
    console.log(`  privacy_policy:     ${tpl.privacy_policy_url || '(none)'}`);

    const ads = await findActiveK12Ad(f.adNameMatch);
    if (ads.length === 0) {
      console.log(`  ⚠  no ACTIVE K-12 ad matched ${f.adNameMatch} — skipping\n`);
      continue;
    }
    if (ads.length > 1) {
      console.log(`  ⚠  ${ads.length} ACTIVE K-12 ads matched — refusing to convert all in one run.`);
      console.log(`     Tighten adNameMatch in this script first.  Matched ad ids:`);
      for (const a of ads) console.log(`       ${a.id}  ${a.name}`);
      console.log('');
      continue;
    }
    const ad = ads[0];
    const oldCre = ad.creative.id;
    const oldCta = ad.creative?.object_story_spec?.link_data?.call_to_action;
    console.log(`  ad: ${ad.id}  [${ad.effective_status}]  ${ad.name}`);
    console.log(`    current creative: ${oldCre}`);
    console.log(`    current CTA:      ${JSON.stringify(oldCta)}`);

    if (DRY) {
      console.log(`  [dry-run] would create new K-12 form, clone creative, swap link → lead_gen_form_id, update ad\n`);
      continue;
    }

    const newForm = await createK12Form(tpl, f.label);
    console.log(`  ✨ new form:     ${newForm.id}`);
    const newCre  = await cloneCreativeAsLeadForm(ad, newForm.id);
    console.log(`  🎨 new creative: ${newCre.id}`);
    const upd = await apiPost(ad.id, { creative: JSON.stringify({ creative_id: newCre.id }) });
    console.log(`  🔁 ad ${ad.id} → creative ${newCre.id}  ${JSON.stringify(upd)}`);

    results.push({
      funnel:      key,
      label:       f.label,
      adId:        ad.id,
      adName:      ad.name,
      oldCreative: oldCre,
      newCreative: newCre.id,
      newFormId:   newForm.id,
    });
    console.log('');
  }

  if (results.length) {
    console.log('\n=== SUMMARY — paste these into formLabel() in frontend/js/screens/leads.js ===\n');
    for (const r of results) {
      console.log(`      '${r.newFormId}': '${r.label}',`);
    }
    console.log('\nKeep the existing slim Grades 1-6 mappings unchanged — those still apply.');
    console.log('After the form-label change, redeploy the frontend so new K-12 leads bucket correctly.');
    console.log('\nRevert recipe (per ad):');
    for (const r of results) {
      console.log(`  ad ${r.adId} (${r.label}) → re-point creative to ${r.oldCreative}`);
    }
  }
})().catch(err => { console.error('\n❌ Failed:', err.message); process.exit(1); });
