#!/usr/bin/env node
// scripts/ad-report.js — decision table for Meta ad budgets.
//
// Columns:
//   STATUS      effective_status of the adset
//   SET $/day   configured daily_budget on the adset
//   ACT $/day   actual last-30d spend ÷ 30
//   Meta L      Meta's reported form-submits (last 30d)
//   DB L        our webhook-received leads for the ad's form_id (last 30d)
//   L/day (DB)  DB L ÷ 30
//   $/lead      ACT spend ÷ DB L (real cost per lead that reached us)
//   ADSET       trimmed name

require('dotenv').config({ path: __dirname + '/../env' });
const { execSync } = require('child_process');

const API   = 'https://graph.facebook.com/v21.0';
const acc   = process.env.META_AD_ACCOUNT_ID;
const tok   = process.env.META_ADS_TOKEN;
const DAYS  = 30;

async function fbGet(path) {
  const url = `${API}/${path}${path.includes('?') ? '&' : '?'}access_token=${tok}`;
  const r   = await fetch(url);
  const j   = await r.json();
  if (j.error) throw new Error(JSON.stringify(j.error));
  return j;
}

// Follow pagination for a listing endpoint.
async function fbList(path) {
  const out = [];
  let url = `${API}/${path}${path.includes('?') ? '&' : '?'}access_token=${tok}&limit=200`;
  while (url) {
    const r = await fetch(url);
    const j = await r.json();
    if (j.error) throw new Error(JSON.stringify(j.error));
    out.push(...(j.data || []));
    url = j.paging && j.paging.next;
  }
  return out;
}

(async () => {
  // 1. Adset config (daily budget, status, name)
  const adsets = await fbList(`${acc}/adsets?fields=id,name,effective_status,daily_budget`);
  const meta = {};
  for (const a of adsets) {
    meta[a.id] = {
      name:   a.name,
      status: a.effective_status,
      daily:  a.daily_budget ? parseInt(a.daily_budget, 10) / 100 : 0,
    };
  }

  // 2. Insights (spend + actions.lead) last 30d per adset
  const ins = await fbList(`${acc}/insights?level=adset&date_preset=last_30d&fields=adset_id,adset_name,spend,actions`);
  const insByAdset = {};
  for (const d of ins) {
    const leadAct = (d.actions || []).find(a => a.action_type === 'lead');
    insByAdset[d.adset_id] = {
      spend:     parseFloat(d.spend || 0),
      metaLeads: leadAct ? parseInt(leadAct.value, 10) : 0,
    };
  }

  // 3. Map adset_id → set of form_ids from its ad creatives.
  //    Meta stores the lead-gen form id under call_to_action.value.lead_gen_form_id,
  //    NOT directly on link_data, so query the whole CTA node and dig it out.
  const ads = await fbList(`${acc}/ads?fields=id,adset_id,creative{object_story_spec{link_data{call_to_action}}}`);
  const adsetForms = {};
  for (const ad of ads) {
    const cta = ad.creative
      && ad.creative.object_story_spec
      && ad.creative.object_story_spec.link_data
      && ad.creative.object_story_spec.link_data.call_to_action;
    const fid = cta && cta.value && cta.value.lead_gen_form_id;
    if (fid) {
      adsetForms[ad.adset_id] = adsetForms[ad.adset_id] || new Set();
      adsetForms[ad.adset_id].add(String(fid));
    }
  }

  // 4. DB lead counts per form_id last 30d
  const sql = `SELECT form_id, COUNT(*) FROM leads WHERE created_at > NOW() - INTERVAL '${DAYS} days' AND form_id IS NOT NULL GROUP BY form_id;`;
  const raw = execSync(
    `podman exec footballhome_db psql -U footballhome_user -d footballhome -tAc "${sql}"`
  ).toString().trim();
  const dbByForm = {};
  for (const line of raw.split('\n').filter(Boolean)) {
    const [fid, n] = line.split('|');
    dbByForm[fid.trim()] = parseInt(n, 10);
  }

  // 5. Build rows
  const rows = [];
  for (const adsetId of Object.keys(meta)) {
    const m = meta[adsetId];
    const i = insByAdset[adsetId] || { spend: 0, metaLeads: 0 };
    const forms = [...(adsetForms[adsetId] || [])];
    const dbLeads = forms.reduce((s, f) => s + (dbByForm[f] || 0), 0);
    // Skip zero-everything to keep table readable
    if (i.spend === 0 && m.status !== 'ACTIVE' && dbLeads === 0) continue;
    rows.push({
      name:      m.name.replace(/ — Ad Set.*/, '').replace(/^Lighthouse /, ''),
      status:    m.status,
      setDaily:  m.daily,
      actDaily:  i.spend / DAYS,
      metaLeads: i.metaLeads,
      dbLeads,
      dbPerDay:  dbLeads / DAYS,
      costPerDbLead: dbLeads > 0 ? i.spend / dbLeads : null,
    });
  }

  rows.sort((a, b) => (b.actDaily - a.actDaily));

  // Print
  const header = ['STATUS', 'SET$/d', 'ACT$/d', 'META L', 'DB L', 'DB L/d', '$/DBLEAD', 'ADSET'];
  const widths = [15, 8, 8, 7, 6, 8, 9, 45];
  console.log(header.map((h, i) => h.padEnd(widths[i])).join(' '));
  console.log('-'.repeat(widths.reduce((s, w) => s + w + 1, 0)));
  for (const r of rows) {
    console.log([
      r.status.padEnd(widths[0]),
      ('$' + r.setDaily.toFixed(0)).padEnd(widths[1]),
      ('$' + r.actDaily.toFixed(2)).padEnd(widths[2]),
      String(r.metaLeads).padEnd(widths[3]),
      String(r.dbLeads).padEnd(widths[4]),
      r.dbPerDay.toFixed(2).padEnd(widths[5]),
      (r.costPerDbLead === null ? '-' : '$' + r.costPerDbLead.toFixed(2)).padEnd(widths[6]),
      r.name,
    ].join(' '));
  }

  const totActSpend = rows.reduce((s, r) => s + r.actDaily, 0);
  const totDbLeads  = rows.reduce((s, r) => s + r.dbLeads, 0);
  console.log('-'.repeat(widths.reduce((s, w) => s + w + 1, 0)));
  console.log(
    `TOTAL actual daily spend: $${totActSpend.toFixed(2)}/day  ·  ` +
    `$${(totActSpend * 30).toFixed(0)}/mo  ·  ` +
    `${totDbLeads} DB leads / 30d = ${(totDbLeads / 30).toFixed(1)}/day  ·  ` +
    `blended $/lead: $${totDbLeads > 0 ? (totActSpend * 30 / totDbLeads).toFixed(2) : '-'}`
  );
})().catch(e => { console.error('ERROR:', e); process.exit(1); });
