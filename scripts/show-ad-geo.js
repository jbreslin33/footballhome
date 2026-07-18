#!/usr/bin/env node
// scripts/show-ad-geo.js — Print live targeting + region-of-click breakdown for all active ads
//
// Reads META_ADS_TOKEN + META_AD_ACCOUNT_ID from env. Pulls each ad's adset
// targeting (so we see the actual live geo, not what scripts/ads/create-ad.js *originally*
// posted — it may have been edited in Ads Manager), plus a region-broken-down
// insights row to show where impressions / clicks / leads actually came from.

require('dotenv').config({ path: __dirname + '/../env' });

const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';

if (!AD_ACCOUNT_ID || !ACCESS_TOKEN) {
  console.error('Missing META_AD_ACCOUNT_ID or META_ADS_TOKEN in env');
  process.exit(1);
}

const FORM_LABELS = {
  '1668570657681917': 'PR Men',
  '2062202517690808': 'PR Men',
  '875990184755538':  'U23 Women',
  '1696381158350766': 'U23 Women',
  '1552835789741946': 'Brazil Men',
  '1333581472007910': 'Brazil Men',
  '1052472267432735': 'U23 Men',
  '1773598717166962': 'APSL Trials',
  '3249608418562710': 'Youth (Grades 1–6)',
  '1704106777282059': 'Boys Club (Grades 1–6)',
  '1571742281184926': 'Girls Club (Grades 1–6)',
};

async function gj(url) {
  const r = await fetch(url);
  const j = await r.json();
  if (j.error) throw new Error(j.error.message);
  return j;
}

function geoLabel(t) {
  if (!t || !t.geo_locations) return '(no geo)';
  const g = t.geo_locations;
  const out = [];
  if (g.custom_locations) {
    for (const cl of g.custom_locations) {
      out.push(`pin: ${cl.address_string || (cl.latitude + ',' + cl.longitude)} +${cl.radius}${cl.distance_unit === 'mile' ? 'mi' : 'km'}`);
    }
  }
  if (g.cities) {
    for (const c of g.cities) {
      out.push(`city ${c.name || c.key} +${c.radius}${c.distance_unit === 'mile' ? 'mi' : 'km'}`);
    }
  }
  if (g.regions) {
    for (const r of g.regions) out.push(`region ${r.name || r.key}`);
  }
  if (g.countries) out.push(`countries ${g.countries.join(',')}`);
  if (g.zips) {
    for (const z of g.zips) out.push(`zip ${z.name || z.key}`);
  }
  if (g.location_types) out[out.length - 1] += ` (${g.location_types.join('+')})`;
  return out.join(' | ') || '(geo set but unparsed)';
}

(async () => {
  const fields = [
    'id', 'name', 'effective_status',
    'adset{id,name,targeting{geo_locations,age_min,age_max,genders}}',
    'creative{object_story_spec{link_data{call_to_action}}}',
    'insights.date_preset(maximum){spend,impressions,clicks,actions}',
  ].join(',');

  const ads = (await gj(`${API}/${AD_ACCOUNT_ID}/ads?fields=${encodeURIComponent(fields)}&limit=200&access_token=${ACCESS_TOKEN}`)).data || [];

  // Group ads by lead form id
  const byForm = {};
  for (const ad of ads) {
    const cta = ad.creative?.object_story_spec?.link_data?.call_to_action;
    const formId = cta?.value?.lead_gen_form_id;
    const key = formId || `(non-lead-form: ${ad.name})`;
    if (!byForm[key]) byForm[key] = [];
    byForm[key].push(ad);
  }

  const rows = [];
  for (const [formId, list] of Object.entries(byForm)) {
    const label = FORM_LABELS[formId] || formId;
    for (const ad of list) {
      const t = ad.adset?.targeting || {};
      const ins = ad.insights?.data?.[0] || {};
      const leadAction = (ins.actions || []).find(a => a.action_type === 'lead' || a.action_type === 'onsite_conversion.lead_grouped');
      rows.push({
        funnel: label,
        ad_name: ad.name,
        status: ad.effective_status,
        geo: geoLabel(t),
        ages: `${t.age_min ?? '?'}–${t.age_max ?? '?'}`,
        gender: t.genders ? (t.genders.includes(1) ? 'M' : 'F') : 'All',
        spend: `$${ins.spend ?? '0'}`,
        impressions: ins.impressions ?? '0',
        clicks: ins.clicks ?? '0',
        leads: leadAction?.value ?? '0',
        ad_id: ad.id,
      });
    }
  }

  console.log('\n=== LIVE AD TARGETING + LIFETIME PERFORMANCE ===\n');
  for (const r of rows) {
    console.log(`▸ ${r.funnel}  [${r.status}]  ${r.ad_name}`);
    console.log(`  geo:     ${r.geo}`);
    console.log(`  audience: ages ${r.ages}, gender ${r.gender}`);
    console.log(`  perf:    spend ${r.spend} · imp ${r.impressions} · clicks ${r.clicks} · leads ${r.leads}`);
    console.log(`  ad_id:   ${r.ad_id}\n`);
  }

  // === Region breakdown for each ACTIVE ad ===
  const active = rows.filter(r => r.status === 'ACTIVE');
  console.log('\n=== REGION-OF-CLICK HOT SPOTS (active ads only, last 30d) ===\n');
  for (const r of active) {
    const url = `${API}/${r.ad_id}/insights?breakdowns=region&fields=impressions,clicks,actions&date_preset=last_30d&limit=50&access_token=${ACCESS_TOKEN}`;
    try {
      const j = await gj(url);
      const data = (j.data || []).sort((a, b) => parseInt(b.clicks || 0) - parseInt(a.clicks || 0));
      console.log(`▸ ${r.funnel} — ${r.ad_name}`);
      if (data.length === 0) {
        console.log('  (no region data — ad has no impressions in last 30d)\n');
        continue;
      }
      for (const row of data.slice(0, 8)) {
        const lead = (row.actions || []).find(a => a.action_type === 'lead' || a.action_type === 'onsite_conversion.lead_grouped');
        console.log(`  ${(row.region || 'Unknown').padEnd(20)} imp ${String(row.impressions || 0).padStart(6)}  clicks ${String(row.clicks || 0).padStart(4)}  leads ${lead?.value ?? 0}`);
      }
      if (data.length > 8) console.log(`  … and ${data.length - 8} more regions`);
      console.log('');
    } catch (e) {
      console.log(`  (failed: ${e.message})\n`);
    }
  }
})().catch(e => { console.error('ERROR:', e.message); process.exit(1); });
