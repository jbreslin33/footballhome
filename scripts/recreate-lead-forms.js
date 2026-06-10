#!/usr/bin/env node
// scripts/recreate-lead-forms.js
// Recreates Meta lead forms to strip non-essential fields and re-points
// the live ads at the new forms.
//
// WHY:
//   Meta lead forms are IMMUTABLE once any submission exists.  You cannot
//   edit the questions on an existing form — you must create a NEW form
//   and point the ads at it.  Same for adcreatives.  So the only way to
//   slim a form is:
//     1. Fetch the existing form (to copy name, privacy policy, thank-you
//        page, locale, etc. — preserve everything except the questions)
//     2. Create a new leadgen_form on the same page with the slim questions
//     3. Find every ad in the ad account whose creative references the old
//        form_id (via link_data.call_to_action.value.lead_gen_form_id)
//     4. For each such ad, CLONE its creative with lead_gen_form_id swapped
//        to the new form (adcreatives are also immutable)
//     5. Update the live ad to point at the new creative_id
//
// HISTORICAL LEADS:
//   Leads already in the DB still have the OLD form_id — they keep their
//   formLabel() mapping.  After running this script, add new mappings to
//   formLabel() in frontend/js/screens/leads.js so future leads on the
//   NEW form get the same human-readable label.  Both old and new IDs
//   should map to the same label.  The script prints the snippet to paste.
//
// SAFETY:
//   - Nothing is deleted.  Old forms + old creatives remain; ads just
//     stop pointing at them.
//   - To revert an ad: re-point its `creative` at the previous
//     creative_id (visible in Ads Manager → Ad → History).
//   - Use --dry-run first to preview what would be created/changed.
//
// USAGE:
//   node scripts/recreate-lead-forms.js                 # all configured funnels
//   node scripts/recreate-lead-forms.js boys            # one funnel
//   node scripts/recreate-lead-forms.js boys girls      # subset
//   node scripts/recreate-lead-forms.js --dry-run       # preview, no writes

require('dotenv').config({ path: __dirname + '/../env' });

const PAGE_ID       = process.env.META_PAGE_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const API           = 'https://graph.facebook.com/v21.0';

const args = process.argv.slice(2);
const DRY  = args.includes('--dry-run');

// label values must match formLabel() in frontend/js/screens/leads.js
const FUNNELS = {
  youth: { label: 'Youth (Grades 1–6)',      oldFormId: '3249608418562710' },
  boys:  { label: 'Boys Club (Grades 1–6)',  oldFormId: '1704106777282059' },
  girls: { label: 'Girls Club (Grades 1–6)', oldFormId: '1571742281184926' },
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
  // Walks paginated edge results until exhausted.
  let next  = null;
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

// ── Form + ad operations ───────────────────────────────────────────────

// Fetch the existing form so we can copy its name, privacy policy, thank-you
// screen, and locale — keeping the post-submit experience identical.
async function fetchForm(formId) {
  return apiGet(formId, {
    fields: [
      'id', 'name', 'locale', 'privacy_policy_url', 'follow_up_action_url',
      'thank_you_page', 'context_card', 'questions', 'status'
    ].join(','),
  });
}

// Create the slimmer form on the page.  Three autofilled standard fields
// only — name, email, phone.  Anything else was friction with no payoff.
async function createSlimForm(srcForm, labelHint) {
  // Strip read-only `id` keys that Meta returns on GET but rejects on POST.
  // Walks the object tree and removes any 'id' property recursively.
  const stripIds = (obj) => {
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
  };

  const body = {
    name:    `${srcForm.name || labelHint} (slim — name/email/phone)`,
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

// Scan every ad in the ad account, find ones whose creative currently
// references oldFormId.  Paginates automatically.
async function findAdsUsingForm(oldFormId) {
  const ads = await apiGetAll(`${AD_ACCOUNT_ID}/ads`, {
    fields: 'id,name,status,effective_status,creative{id,object_story_spec}',
  });
  return ads.filter(ad => {
    const fid = ad?.creative?.object_story_spec?.link_data?.call_to_action?.value?.lead_gen_form_id;
    return fid && String(fid) === String(oldFormId);
  });
}

// Build a new creative copying the old one's full spec but swapping
// lead_gen_form_id.  Caller updates the ad afterwards.
async function cloneCreativeWithNewForm(ad, newFormId) {
  const creative = await apiGet(ad.creative.id, { fields: 'name,object_story_spec' });
  const spec = JSON.parse(JSON.stringify(creative.object_story_spec || {}));
  if (!spec.link_data) throw new Error(`Creative ${creative.id} has no link_data`);
  spec.link_data.call_to_action = spec.link_data.call_to_action || { type: 'SIGN_UP', value: {} };
  spec.link_data.call_to_action.value = {
    ...(spec.link_data.call_to_action.value || {}),
    lead_gen_form_id: newFormId,
  };
  return apiPost(`${AD_ACCOUNT_ID}/adcreatives`, {
    name: `${creative.name || 'creative'} — slim form ${new Date().toISOString().slice(0,10)}`,
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
    console.log(`old form_id: ${f.oldFormId}`);

    const srcForm = await fetchForm(f.oldFormId);
    const qNames  = (srcForm.questions || []).map(q => q.key || q.type).join(', ');
    console.log(`  src form:           ${srcForm.name}`);
    console.log(`  src questions:      ${qNames}`);
    console.log(`  src follow_up_url:  ${srcForm.follow_up_action_url || '(none)'}`);
    console.log(`  src privacy_policy: ${srcForm.privacy_policy_url || '(none)'}`);

    const ads = await findAdsUsingForm(f.oldFormId);
    console.log(`  ads referencing it: ${ads.length}`);
    for (const ad of ads) console.log(`    - ${ad.id}  [${ad.effective_status}]  ${ad.name}`);

    if (DRY) {
      console.log(`  [dry-run] would create slim form + clone ${ads.length} creative(s) + update ${ads.length} ad(s)\n`);
      continue;
    }

    const newForm = await createSlimForm(srcForm, f.label);
    console.log(`  ✨ created new form: ${newForm.id}`);

    for (const ad of ads) {
      const cr = await cloneCreativeWithNewForm(ad, newForm.id);
      console.log(`  🎨 new creative ${cr.id} for ad ${ad.id}`);
      const upd = await apiPost(ad.id, { creative: JSON.stringify({ creative_id: cr.id }) });
      console.log(`  🔁 ad ${ad.id} → ${JSON.stringify(upd)}`);
    }

    results.push({ funnel: key, label: f.label, oldFormId: f.oldFormId, newFormId: newForm.id, ads: ads.length });
    console.log('');
  }

  if (results.length) {
    console.log('\n=== SUMMARY — paste these into formLabel() in frontend/js/screens/leads.js ===\n');
    for (const r of results) {
      console.log(`      '${r.newFormId}': '${r.label}',   // slim form (was ${r.oldFormId})`);
    }
    console.log(`\nKeep the OLD mappings too — historical leads still carry the old form_id.\n`);
  }
})().catch(err => { console.error('\n❌ Failed:', err.message); process.exit(1); });
