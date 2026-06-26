#!/usr/bin/env node
// scripts/analyze-ad-spend.js — Last-7d performance + daily budgets for ACTIVE ads.
// Helps decide whether to increase / decrease / pause budgets.

require('dotenv').config({ path: __dirname + '/../env' });

const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';

if (!AD_ACCOUNT_ID || !ACCESS_TOKEN) {
  console.error('Missing META_AD_ACCOUNT_ID or META_ADS_TOKEN in env');
  process.exit(1);
}

async function gj(url) {
  const r = await fetch(url);
  const j = await r.json();
  if (j.error) throw new Error(j.error.message);
  return j;
}

function leadCount(actions) {
  if (!actions) return 0;
  const a = actions.find(x => x.action_type === 'lead' || x.action_type === 'onsite_conversion.lead_grouped');
  return a ? parseInt(a.value, 10) : 0;
}

function fmtMoney(v) {
  const n = parseFloat(v || 0);
  return '$' + n.toFixed(2);
}

(async () => {
  const fields = [
    'id','name','effective_status','adset_id',
    'adset{id,name,daily_budget,lifetime_budget,bid_strategy,optimization_goal,budget_remaining,start_time,end_time}',
    'insights.date_preset(last_7d){spend,impressions,clicks,reach,frequency,actions,ctr,cpc,cpm}',
  ].join(',');

  const ads = (await gj(`${API}/${AD_ACCOUNT_ID}/ads?fields=${encodeURIComponent(fields)}&limit=200&access_token=${ACCESS_TOKEN}`)).data || [];

  const active = ads.filter(a => a.effective_status === 'ACTIVE');

  // dedup adsets so we can also fetch adset-level (rolled-up across all ads) insights
  const adsetMap = new Map();
  for (const ad of active) {
    if (ad.adset?.id) adsetMap.set(ad.adset.id, ad.adset);
  }

  // adset-level 7d insights
  const adsetInsights = {};
  for (const asId of adsetMap.keys()) {
    try {
      const j = await gj(`${API}/${asId}/insights?date_preset=last_7d&fields=spend,impressions,clicks,reach,frequency,actions,ctr,cpc,cpm&access_token=${ACCESS_TOKEN}`);
      adsetInsights[asId] = j.data?.[0] || {};
    } catch (e) {
      adsetInsights[asId] = { _err: e.message };
    }
  }

  console.log('\n=== ACTIVE ADS — LAST 7 DAYS ===\n');

  const rows = [];
  for (const ad of active) {
    const ins = ad.insights?.data?.[0] || {};
    const leads = leadCount(ins.actions);
    const spend = parseFloat(ins.spend || 0);
    const clicks = parseInt(ins.clicks || 0, 10);
    const impressions = parseInt(ins.impressions || 0, 10);
    const cpl = leads > 0 ? spend / leads : null;
    const adset = ad.adset || {};
    // daily_budget / lifetime_budget come back in cents
    const dailyBudget = adset.daily_budget ? parseInt(adset.daily_budget, 10) / 100 : null;
    const lifeBudget  = adset.lifetime_budget ? parseInt(adset.lifetime_budget, 10) / 100 : null;
    rows.push({
      name: ad.name,
      adset_name: adset.name,
      adset_id: adset.id,
      daily_budget: dailyBudget,
      lifetime_budget: lifeBudget,
      end_time: adset.end_time || null,
      spend, impressions, clicks, leads,
      cpl,
      ctr: parseFloat(ins.ctr || 0),
      cpc: parseFloat(ins.cpc || 0),
      cpm: parseFloat(ins.cpm || 0),
      frequency: parseFloat(ins.frequency || 0),
      reach: parseInt(ins.reach || 0, 10),
    });
  }

  // sort by 7d leads desc, then spend
  rows.sort((a,b) => (b.leads - a.leads) || (b.spend - a.spend));

  for (const r of rows) {
    const cplStr = r.cpl !== null ? fmtMoney(r.cpl) : 'n/a';
    const budStr = r.daily_budget !== null
      ? `daily ${fmtMoney(r.daily_budget)}`
      : (r.lifetime_budget !== null ? `lifetime ${fmtMoney(r.lifetime_budget)} (ends ${r.end_time || '?'})` : 'no budget cap');
    console.log(`▸ ${r.name}`);
    console.log(`  adset:    ${r.adset_name}  [${budStr}]`);
    console.log(`  7d perf:  spend ${fmtMoney(r.spend)} · imp ${r.impressions} · reach ${r.reach} · freq ${r.frequency.toFixed(2)}`);
    console.log(`            clicks ${r.clicks} · CTR ${r.ctr.toFixed(2)}% · CPC ${fmtMoney(r.cpc)} · CPM ${fmtMoney(r.cpm)}`);
    console.log(`            leads ${r.leads} · CPL ${cplStr}`);
    console.log('');
  }

  // === Recommendation engine ===
  console.log('\n=== RECOMMENDATIONS ===\n');
  for (const r of rows) {
    const lines = [];
    if (r.leads === 0 && r.spend > 10) {
      lines.push(`⚠️  $${r.spend.toFixed(2)} spent in 7d with 0 leads — consider PAUSING or rewriting creative.`);
    } else if (r.leads === 0) {
      lines.push(`… too little data (spend $${r.spend.toFixed(2)}, ${r.impressions} imp). Let it run a few more days.`);
    } else {
      if (r.cpl !== null && r.cpl < 5)       lines.push(`🟢 Excellent CPL (${fmtMoney(r.cpl)}). Strong candidate to INCREASE daily budget.`);
      else if (r.cpl !== null && r.cpl < 10) lines.push(`🟢 Healthy CPL (${fmtMoney(r.cpl)}). OK to scale modestly.`);
      else if (r.cpl !== null && r.cpl < 20) lines.push(`🟡 Borderline CPL (${fmtMoney(r.cpl)}). Hold steady; tune creative or audience.`);
      else                                   lines.push(`🔴 High CPL (${fmtMoney(r.cpl)}). Reduce budget or pause.`);
    }
    if (r.frequency > 3)  lines.push(`⚠️  Frequency ${r.frequency.toFixed(2)} — audience fatiguing, refresh creative or widen targeting.`);
    if (r.ctr && r.ctr < 0.8) lines.push(`⚠️  CTR ${r.ctr.toFixed(2)}% is below the 1% rule-of-thumb — creative or hook is weak.`);
    if (r.daily_budget !== null && r.spend / 7 > r.daily_budget * 0.9) {
      lines.push(`💡 Adset is fully spending its daily cap (${fmtMoney(r.daily_budget)}/day). It IS budget-constrained — raising will deliver more.`);
    } else if (r.daily_budget !== null && r.spend / 7 < r.daily_budget * 0.5) {
      lines.push(`💡 Spending only ${fmtMoney(r.spend/7)}/day vs ${fmtMoney(r.daily_budget)} cap — NOT budget-constrained; raising won't help.`);
    }
    console.log(`▸ ${r.name}`);
    for (const l of lines) console.log(`    ${l}`);
    console.log('');
  }
})().catch(e => { console.error('ERROR:', e.message); process.exit(1); });
