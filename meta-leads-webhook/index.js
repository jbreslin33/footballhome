'use strict';

const express      = require('express');
const { Pool }     = require('pg');

const app  = express();
app.use(express.json());

// ── Config ────────────────────────────────────────────────────────────
const PORT              = process.env.META_LEADS_PORT || 3003;
const VERIFY_TOKEN      = process.env.META_LEADS_VERIFY_TOKEN;
const LEADS_PAGE_ID     = process.env.META_PAGE_ID;
// Prefer a stable Page token for lead fetches. Keep META_LEADS_TOKEN as fallback.
const LEADS_TOKEN       = process.env.META_ADS_TOKEN || process.env.META_LEADS_TOKEN;
const ADS_TOKEN         = process.env.META_ADS_TOKEN || process.env.META_LEADS_TOKEN;
const AD_ACCOUNT_ID     = process.env.META_AD_ACCOUNT_ID || 'act_1792823854148245';
const SYNC_TTL_MS       = parseInt(process.env.META_LEADS_SYNC_TTL_MS || '30000', 10);
const FORM_IDS          = parseFormIds(
  process.env.META_LEAD_FORM_IDS,
  [
    '1696381158350766',
    '1052472267432735',
    '1333581472007910',
    '2062202517690808',
    '875990184755538',
    '1552835789741946',
    '1668570657681917',
    '1773598717166962',
    '3249608418562710', // Youth (Grades 1–6)
    '1704106777282059', // Boys Club (Grades 1–6)
    '1571742281184926', // Girls Club (Grades 1–6)
  ]
);
const API               = 'https://graph.facebook.com/v21.0';
let lastSyncAtMs        = 0;
let leadsTokenValidated = false;

if (!VERIFY_TOKEN)   { console.error('Missing META_LEADS_VERIFY_TOKEN'); process.exit(1); }
if (!LEADS_TOKEN)    { console.error('Missing META_ADS_TOKEN (or META_LEADS_TOKEN fallback)'); process.exit(1); }
if (!LEADS_PAGE_ID)  { console.error('Missing META_PAGE_ID'); process.exit(1); }

const pool = new Pool({
  host:     process.env.POSTGRES_HOST     || 'db',
  port:     parseInt(process.env.POSTGRES_PORT || '5432', 10),
  database: process.env.POSTGRES_DB       || 'footballhome',
  user:     process.env.POSTGRES_USER     || 'footballhome_user',
  password: process.env.POSTGRES_PASSWORD || 'footballhome_pass',
});

function parseFormIds(rawValue, fallback) {
  if (!rawValue) return fallback;
  return rawValue
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean);
}

function extractLeadFields(fieldData) {
  const fields = {};
  for (const field of (fieldData || [])) {
    fields[field.name] = field.values?.[0] ?? null;
  }
  return fields;
}

// Blocklist of leadgen_ids that should never be re-ingested.
// Currently: 5 California leads from the APSL ad that ran against San Francisco
// instead of Philadelphia (city-key bug, fixed 2026-06-08).
const EXCLUDED_LEADGEN_IDS = new Set([
  '1216620387131716', // Ann (707 CA)
  '2389328841559768', // Alberto Castillon (209 CA)
  '1018387347196312', // Yovg Tribal (510 CA)
  '2211610912932327', // Brayan Guerra (510 CA)
  '987234783709164',  // فياض زقزوق (510 CA)
]);

async function upsertLead(lead) {
  if (EXCLUDED_LEADGEN_IDS.has(String(lead.id))) {
    return {};
  }
  const fieldData = lead.field_data || [];
  const fields = extractLeadFields(fieldData);

  await pool.query(
    `INSERT INTO leads (leadgen_id, form_id, page_id, ad_id, name, email, phone, raw_fields, created_at)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
     ON CONFLICT (leadgen_id) DO UPDATE
     SET form_id = EXCLUDED.form_id,
         page_id = EXCLUDED.page_id,
         ad_id = EXCLUDED.ad_id,
         name = EXCLUDED.name,
         email = EXCLUDED.email,
         phone = EXCLUDED.phone,
         raw_fields = EXCLUDED.raw_fields,
         created_at = COALESCE(leads.created_at, EXCLUDED.created_at)`,
    [
      lead.id,
      lead.form_id || null,
      lead.page_id || null,
      lead.ad_id || null,
      fields.full_name || fields.name || null,
      fields.email || fields.email_address || null,
      fields.phone_number || fields.phone || null,
      JSON.stringify(fieldData),
      lead.created_time || new Date().toISOString(),
    ]
  );

  return fields;
}

async function fetchMetaJson(url) {
  const metaRes = await fetch(url);
  return metaRes.json();
}

async function syncFormLeads(formId) {
  if (!leadsTokenValidated) {
    throw new Error('META_LEADS_TOKEN not validated; sync disabled until token is fixed');
  }

  let url = `${API}/${formId}/leads?access_token=${encodeURIComponent(LEADS_TOKEN)}&limit=100&fields=id,created_time,field_data,ad_id,form_id,page_id`;
  let insertedOrUpdated = 0;

  while (url) {
    const data = await fetchMetaJson(url);
    if (data?.error) {
      throw new Error(`Form ${formId}: ${data.error.message}`);
    }

    for (const lead of (data.data || [])) {
      await upsertLead(lead);
      insertedOrUpdated += 1;
    }

    url = data.paging?.next || null;
  }

  return insertedOrUpdated;
}

async function syncAllFormLeads() {
  const nowMs = Date.now();
  if (nowMs - lastSyncAtMs < SYNC_TTL_MS) {
    return { syncedRows: 0, skippedByTtl: true, failedForms: [] };
  }

  let total = 0;
  const failedForms = [];

  for (const formId of FORM_IDS) {
    try {
      total += await syncFormLeads(formId);
    } catch (err) {
      failedForms.push({ formId, error: err.message });
      console.error(`Meta leads sync error for form ${formId}: ${err.message}`);
    }
  }

  lastSyncAtMs = nowMs;
  return { syncedRows: total, skippedByTtl: false, failedForms };
}

// ── Meta webhook verification ─────────────────────────────────────────
app.get('/webhook/meta-leads', (req, res) => {
  const mode      = req.query['hub.mode'];
  const token     = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  if (mode === 'subscribe' && token === VERIFY_TOKEN) {
    console.log('Meta webhook verified');
    return res.status(200).send(challenge);
  }
  res.sendStatus(403);
});

// ── Meta webhook receiver ─────────────────────────────────────────────
app.post('/webhook/meta-leads', async (req, res) => {
  // Acknowledge immediately — Meta requires fast 200
  res.sendStatus(200);

  if (req.body?.object !== 'page') return;

  for (const entry of (req.body.entry || [])) {
    for (const change of (entry.changes || [])) {
      if (change.field !== 'leadgen') continue;

      const { leadgen_id, form_id, page_id, ad_id } = change.value;
      if (!leadgen_id) continue;

      try {
        // Fetch full lead data from Meta
        const url = `${API}/${leadgen_id}?fields=field_data&access_token=${LEADS_TOKEN}`;
        const metaRes  = await fetch(url);
        const metaData = await metaRes.json();

        if (metaData.error) {
          console.error('Meta lead fetch error:', metaData.error.message);
          continue;
        }

        const fields = await upsertLead({
          id: leadgen_id,
          form_id,
          page_id,
          ad_id,
          field_data: metaData.field_data || [],
        });

        console.log(`Lead saved: ${leadgen_id} (${fields['full_name'] || 'unknown'})`);
      } catch (err) {
        console.error('Error processing lead', leadgen_id, err.message);
      }
    }
  }
});

// ── GET /api/ads/preview — return active ads with creative details ────
app.get('/api/ads/preview', requireAuth, async (req, res) => {
  try {
    if (!ADS_TOKEN) {
      return res.status(500).json({ error: 'Missing META_ADS_TOKEN configuration' });
    }

    const fields = [
      'name', 'status',
      'creative{name,body,title,image_url,object_story_spec}'
    ].join(',');
    const url = `${API}/${AD_ACCOUNT_ID}/ads?fields=${encodeURIComponent(fields)}&limit=50&access_token=${ADS_TOKEN}`;
    const metaRes  = await fetch(url);
    const metaData = await metaRes.json();

    if (metaData.error) {
      return res.status(502).json({ error: metaData.error.message });
    }

    // Collect unique image hashes for full-res lookup
    const hashes = new Set();
    for (const ad of metaData.data || []) {
      const h = ad.creative?.object_story_spec?.link_data?.image_hash;
      if (h) hashes.add(h);
    }

    // Fetch full-res image URLs by hash
    const hashToUrl = {};
    if (hashes.size > 0) {
      const hashList = JSON.stringify([...hashes]);
      const imgUrl = `${API}/${AD_ACCOUNT_ID}/adimages?hashes=${encodeURIComponent(hashList)}&fields=hash,url&access_token=${ADS_TOKEN}`;
      const imgRes = await fetch(imgUrl);
      const imgData = await imgRes.json();
      for (const img of imgData.data || []) {
        if (img.hash && img.url) hashToUrl[img.hash] = img.url;
      }
    }

    const ads = (metaData.data || []).map(ad => {
      const c    = ad.creative || {};
      const spec = c.object_story_spec?.link_data || {};
      const fullResUrl = spec.image_hash ? hashToUrl[spec.image_hash] : null;
      return {
        id:        ad.id,
        name:      ad.name,
        status:    ad.status,
        headline:  c.title  || spec.name  || null,
        body:      c.body   || spec.message || null,
        image_url: fullResUrl || c.image_url || null,
        cta:       spec.call_to_action?.type || null,
        link:      spec.link || null,
      };
    });

    res.json(ads);
  } catch (err) {
    console.error('Error fetching ad preview:', err.message);
    res.status(500).json({ error: 'Failed to fetch ads' });
  }
});

// ── GET /api/ads/spend — aggregate spend stats per lead form ──────────
async function fetchAdsTargetingRundown() {
  if (!ADS_TOKEN) throw new Error('Missing META_ADS_TOKEN');

  const fields = [
    'id', 'name', 'effective_status', 'configured_status',
    'adset{id,name,daily_budget,start_time,effective_status,targeting}',
    'creative{object_story_spec{link_data{call_to_action}}}',
    'insights.date_preset(maximum){spend,impressions,clicks,actions}',
  ].join(',');
  const url = `${API}/${AD_ACCOUNT_ID}/ads?fields=${encodeURIComponent(fields)}&limit=200&access_token=${ADS_TOKEN}`;
  const r = await fetch(url);
  const j = await r.json();
  if (j.error) throw new Error(j.error.message);

  // Parse + summarize each ad
  const ads = [];
  for (const ad of (j.data || [])) {
    const cta    = ad.creative?.object_story_spec?.link_data?.call_to_action;
    const formId = cta?.value?.lead_gen_form_id || null;
    const adset  = ad.adset || {};
    const t      = adset.targeting || {};
    const ins    = ad.insights?.data?.[0] || {};
    const leadAction = (ins.actions || []).find(a =>
      a.action_type === 'lead' || a.action_type === 'onsite_conversion.lead_grouped'
    );

    ads.push({
      ad_id:        ad.id,
      ad_name:      ad.name,
      form_id:      formId,
      status:       ad.effective_status,
      adset_id:     adset.id,
      adset_status: adset.effective_status,
      daily_budget_usd: adset.daily_budget ? parseInt(adset.daily_budget, 10) / 100 : 0,
      start_time:   adset.start_time || null,
      geo:          summarizeGeo(t.geo_locations),
      age_min:      t.age_min || null,
      age_max:      t.age_max || null,
      genders:      t.genders || null,
      spend:        parseFloat(ins.spend || '0'),
      impressions:  parseInt(ins.impressions || '0', 10),
      clicks:       parseInt(ins.clicks || '0', 10),
      leads:        leadAction ? parseInt(leadAction.value, 10) : 0,
      regions:      [], // filled in below for active ads
    });
  }

  // Region breakdown for ACTIVE ads (last 30d) — fetch in parallel
  const activeAds = ads.filter(a => a.status === 'ACTIVE');
  await Promise.all(activeAds.map(async (a) => {
    try {
      const ru = `${API}/${a.ad_id}/insights?breakdowns=region&fields=impressions,clicks,actions&date_preset=last_30d&limit=50&access_token=${ADS_TOKEN}`;
      const rr = await fetch(ru);
      const rj = await rr.json();
      if (rj.error || !rj.data) return;
      a.regions = rj.data.map(row => {
        const la = (row.actions || []).find(x =>
          x.action_type === 'lead' || x.action_type === 'onsite_conversion.lead_grouped'
        );
        return {
          region:      row.region || 'Unknown',
          impressions: parseInt(row.impressions || '0', 10),
          clicks:      parseInt(row.clicks || '0', 10),
          leads:       la ? parseInt(la.value, 10) : 0,
        };
      }).sort((x, y) => y.impressions - x.impressions);
    } catch (_) { /* swallow per-ad region errors — keep rest of payload */ }
  }));

  return ads;
}

function summarizeGeo(g) {
  if (!g) return { kind: 'none', label: '(no geo)' };
  if (g.custom_locations && g.custom_locations[0]) {
    const cl = g.custom_locations[0];
    return {
      kind:       'pin',
      label:      `${cl.address_string || (cl.latitude + ',' + cl.longitude)} +${cl.radius}${cl.distance_unit === 'mile' ? 'mi' : 'km'}`,
      address:    cl.address_string,
      latitude:   cl.latitude,
      longitude:  cl.longitude,
      radius:     cl.radius,
      unit:       cl.distance_unit,
      location_types: g.location_types || [],
    };
  }
  if (g.zips && g.zips[0]) {
    // Explicit ZIP allowlist — stricter than radius. Show count + sample.
    const keys   = g.zips.map(z => (z.key || '').replace(/^US:/, '')).filter(Boolean);
    const states = new Set(keys.map(k => (k[0] === '0' ? 'NJ' : k[0] === '1' ? 'PA' : '?')));
    return {
      kind:           'zips',
      label:          `${keys.length} ZIP allowlist (${[...states].sort().join('+')})`,
      zips:           keys,
      location_types: g.location_types || [],
    };
  }
  if (g.cities && g.cities[0]) {
    const c = g.cities[0];
    return {
      kind:           'city',
      label:          `City ${c.name || c.key} +${c.radius}${c.distance_unit === 'mile' ? 'mi' : 'km'}`,
      city:           c.name || c.key,
      radius:         c.radius,
      unit:           c.distance_unit,
      location_types: g.location_types || [],
    };
  }
  return { kind: 'other', label: '(geo set but unparsed)', location_types: g.location_types || [] };
}

app.get('/api/ads/targeting', requireAuth, async (req, res) => {
  try {
    const ads = await fetchAdsTargetingRundown();
    res.json(ads);
  } catch (err) {
    console.error('Error fetching ad targeting:', err.message);
    res.status(502).json({ error: err.message });
  }
});

// ── GET /api/ads/spend — aggregate spend stats per lead form ──────────
app.get('/api/ads/spend', requireAuth, async (req, res) => {
  try {
    if (!ADS_TOKEN) {
      return res.status(500).json({ error: 'Missing META_ADS_TOKEN configuration' });
    }

    const fields = [
      'id', 'name', 'effective_status', 'configured_status',
      'adset{id,daily_budget,start_time,end_time,effective_status,configured_status}',
      'creative{object_story_spec{link_data{call_to_action}}}',
      'insights.date_preset(maximum){spend,date_start,date_stop}',
    ].join(',');
    const url = `${API}/${AD_ACCOUNT_ID}/ads?fields=${encodeURIComponent(fields)}&limit=200&access_token=${ADS_TOKEN}`;
    const metaRes  = await fetch(url);
    const metaData = await metaRes.json();
    if (metaData.error) return res.status(502).json({ error: metaData.error.message });

    const byForm = {};
    const now = Date.now();

    for (const ad of (metaData.data || [])) {
      const cta = ad.creative?.object_story_spec?.link_data?.call_to_action;
      const formId = cta?.value?.lead_gen_form_id;
      if (!formId) continue;

      const adset = ad.adset || {};
      const dailyBudgetUSD = adset.daily_budget ? parseInt(adset.daily_budget, 10) / 100 : 0;
      const startMs = adset.start_time ? new Date(adset.start_time).getTime() : null;
      const insightSpend = parseFloat(ad.insights?.data?.[0]?.spend || '0');

      if (!byForm[formId]) {
        byForm[formId] = {
          form_id: formId,
          daily_budget_usd: 0,
          total_spend_usd: 0,
          days_running: 0,
          ad_active: false,
        };
      }
      const slot = byForm[formId];
      slot.daily_budget_usd += dailyBudgetUSD;
      slot.total_spend_usd  += insightSpend;
      if (startMs) {
        const days = Math.max(0, Math.floor((now - startMs) / 86400000));
        if (days > slot.days_running) slot.days_running = days;
      }
      const adActive = ad.effective_status === 'ACTIVE' && (adset.effective_status === 'ACTIVE');
      if (adActive) slot.ad_active = true;
    }

    res.json(Object.values(byForm));
  } catch (err) {
    console.error('Error fetching ad spend:', err.message);
    res.status(500).json({ error: 'Failed to fetch spend' });
  }
});

// ── GET /api/leads — serve leads to frontend ──────────────────────────
app.get('/api/leads', requireAuth, async (req, res) => {
  let syncResult = { skippedByTtl: false, syncedRows: 0, failedForms: [] };

  try {
    syncResult = await syncAllFormLeads();
  } catch (err) {
    // Defensive fallback — leads endpoint should remain available using DB cache.
    console.error('Unexpected Meta leads sync failure:', err.message);
  }

  try {
    const result = await pool.query(
      `SELECT id, leadgen_id, form_id, page_id, ad_id,
              name, email, phone, raw_fields, created_at
       FROM leads
       ORDER BY created_at DESC`
    );

    if (syncResult.skippedByTtl) {
      console.log(`Meta leads sync skipped by TTL (${SYNC_TTL_MS}ms)`);
    } else if (syncResult.failedForms.length) {
      console.log(
        `Meta leads partial sync before /api/leads: ${syncResult.syncedRows} rows refreshed, ${syncResult.failedForms.length} forms failed`
      );
    } else {
      console.log(`Meta leads sync completed before /api/leads: ${syncResult.syncedRows} rows refreshed from ${FORM_IDS.length} forms`);
    }

    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching leads from DB:', err.message);
    res.status(500).json({ error: 'Failed to fetch leads' });
  }
});

// ── POST /api/leads/:id/contact — log a text/email/call send ──────────
app.post('/api/leads/:id/contact', requireAuth, async (req, res) => {
  const leadId = parseInt(req.params.id, 10);
  const { channel, message_body, status } = req.body || {};
  if (!leadId || !['text', 'email', 'call'].includes(channel)) {
    return res.status(400).json({ error: 'leadId + channel(text|email|call) required' });
  }
  try {
    const userId = parseInt(req.userId, 10);
    const result = await pool.query(
      `INSERT INTO lead_contacts (lead_id, channel, contacted_by, message_body, status)
       VALUES ($1, $2, $3, $4, COALESCE($5, 'sent'))
       RETURNING id, lead_id, channel, sent_at, status`,
      [leadId, channel, Number.isFinite(userId) ? userId : null, message_body || null, status || null]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error logging contact:', err.message);
    res.status(500).json({ error: 'Failed to log contact' });
  }
});

// ── GET /api/leads/contact-stats — aggregates + per-lead touch summary ──
app.get('/api/leads/contact-stats', requireAuth, async (req, res) => {
  try {
    // Per-lead summary
    const perLead = await pool.query(
      `SELECT lead_id,
              COUNT(*) FILTER (WHERE channel='text')   AS text_count,
              COUNT(*) FILTER (WHERE channel='email')  AS email_count,
              MAX(sent_at) FILTER (WHERE channel='text')  AS last_text_at,
              MAX(sent_at) FILTER (WHERE channel='email') AS last_email_at
       FROM lead_contacts
       GROUP BY lead_id`
    );

    // Aggregate windows (text-focused since SMS = bot-risk channel)
    const agg = await pool.query(
      `SELECT
         COUNT(*) FILTER (WHERE channel='text' AND sent_at >= NOW() - INTERVAL '5 minutes')  AS texts_5min,
         COUNT(*) FILTER (WHERE channel='text' AND sent_at >= NOW() - INTERVAL '1 hour')    AS texts_hour,
         COUNT(*) FILTER (WHERE channel='text' AND sent_at >= NOW() - INTERVAL '24 hours')  AS texts_day,
         COUNT(*) FILTER (WHERE channel='text' AND sent_at >= NOW() - INTERVAL '7 days')    AS texts_week,
         COUNT(*) FILTER (WHERE channel='email' AND sent_at >= NOW() - INTERVAL '24 hours') AS emails_day,
         COUNT(*) FILTER (WHERE channel='email' AND sent_at >= NOW() - INTERVAL '7 days')   AS emails_week
       FROM lead_contacts`
    );

    const perLeadMap = {};
    for (const r of perLead.rows) {
      perLeadMap[r.lead_id] = {
        text_count:    Number(r.text_count),
        email_count:   Number(r.email_count),
        last_text_at:  r.last_text_at,
        last_email_at: r.last_email_at,
      };
    }
    res.json({
      per_lead: perLeadMap,
      aggregates: {
        texts_5min:  Number(agg.rows[0].texts_5min),
        texts_hour:  Number(agg.rows[0].texts_hour),
        texts_day:   Number(agg.rows[0].texts_day),
        texts_week:  Number(agg.rows[0].texts_week),
        emails_day:  Number(agg.rows[0].emails_day),
        emails_week: Number(agg.rows[0].emails_week),
      },
    });
  } catch (err) {
    console.error('Error fetching contact stats:', err.message);
    res.status(500).json({ error: 'Failed to fetch contact stats' });
  }
});

// ── GET /api/leads/:id/vcard — download lead as vCard(s) ──────────────
// Query: ?kind=self|parent|player|youth-pair
//   self        — single contact (adult funnels): "FullName Lighthouse "
//   parent      — single parent contact:           "FullName Lighthouse Parent "
//   player      — single player placeholder:        "LastName Player Lighthouse "
//   youth-pair  — BOTH parent + player placeholder in one .vcf (default for youth)
app.get('/api/leads/:id/vcard', requireAuth, async (req, res) => {
  const leadId = parseInt(req.params.id, 10);
  const kind   = (req.query.kind || 'self').toString();
  if (!leadId) return res.status(400).json({ error: 'leadId required' });

  try {
    const q = await pool.query(
      `SELECT id, name, email, phone, raw_fields, created_at, form_id
         FROM leads WHERE id=$1`, [leadId]);
    if (!q.rows.length) return res.status(404).json({ error: 'Lead not found' });
    const lead = q.rows[0];

    const fullName = (lead.name || '').trim();
    const parts = fullName.split(/\s+/);
    const firstName = parts[0] || '';
    const lastName  = parts.slice(1).join(' ') || '';

    // vCard escape: backslash, comma, semicolon, newline
    const esc = (s='') => String(s).replace(/\\/g, '\\\\').replace(/,/g, '\\,')
                                   .replace(/;/g, '\\;').replace(/\r?\n/g, '\\n');
    const dateStr = new Date(lead.created_at).toISOString().slice(0, 10);

    const buildVCard = (displayName, fn, ln, opts = {}) => {
      const lines = [
        'BEGIN:VCARD',
        'VERSION:3.0',
        `FN:${esc(displayName)}`,
        `N:${esc(ln)};${esc(fn)};;;`,
      ];
      if (opts.phone)  lines.push(`TEL;TYPE=CELL:${esc(opts.phone)}`);
      if (opts.email)  lines.push(`EMAIL;TYPE=INTERNET:${esc(opts.email)}`);
      lines.push(`ORG:${esc('Lighthouse 1893 SC')}`);
      if (opts.note)   lines.push(`NOTE:${esc(opts.note)}`);
      lines.push('END:VCARD');
      return lines.join('\r\n');
    };

    const cards = [];
    let downloadName;

    if (kind === 'parent') {
      cards.push(buildVCard(
        `${fullName} Lighthouse Parent `,
        firstName, lastName,
        { phone: lead.phone, email: lead.email,
          note: `Youth lead signup ${dateStr}. Edit name + add birth year after contact.` }
      ));
      downloadName = `${fullName.replace(/\s+/g, '_')}_Parent.vcf`;
    } else if (kind === 'player') {
      cards.push(buildVCard(
        `${lastName || fullName} Player Lighthouse `,
        '', lastName || fullName,
        { note: `Youth player placeholder. Parent: ${fullName} (${lead.phone || ''}). Fill in first name + birth year after first contact.` }
      ));
      downloadName = `${(lastName || fullName).replace(/\s+/g, '_')}_PlayerPlaceholder.vcf`;
    } else if (kind === 'youth-pair') {
      cards.push(buildVCard(
        `${fullName} Lighthouse Parent `,
        firstName, lastName,
        { phone: lead.phone, email: lead.email,
          note: `Youth lead signup ${dateStr}. Edit name + add birth year after contact.` }
      ));
      cards.push(buildVCard(
        `${lastName || fullName} Player Lighthouse `,
        '', lastName || fullName,
        { note: `Youth player placeholder. Parent: ${fullName} (${lead.phone || ''}). Fill in first name + birth year after first contact.` }
      ));
      downloadName = `${fullName.replace(/\s+/g, '_')}_Youth.vcf`;
    } else {
      // self — adult funnels (Brazil/PR/U23/APSL/etc)
      cards.push(buildVCard(
        `${fullName} Lighthouse `,
        firstName, lastName,
        { phone: lead.phone, email: lead.email,
          note: `Lead signup ${dateStr}. Add birth year after confirming.` }
      ));
      downloadName = `${fullName.replace(/\s+/g, '_')}_Lighthouse.vcf`;
    }

    res.setHeader('Content-Type', 'text/vcard; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="${downloadName}"`);
    res.send(cards.join('\r\n') + '\r\n');
  } catch (err) {
    console.error('Error building vCard:', err.message);
    res.status(500).json({ error: 'Failed to build vCard' });
  }
});

// ── Auth middleware (JWT alg:none — matches C++ backend) ──────────────
function requireAuth(req, res, next) {
  const header = req.headers['authorization'] || '';
  const token  = header.replace(/^Bearer\s+/i, '');
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  // Decode payload (alg:none — no signature to verify)
  try {
    const parts   = token.split('.');
    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
    if (!payload.userId) return res.status(401).json({ error: 'Unauthorized' });
    req.userId = payload.userId;
    next();
  } catch {
    res.status(401).json({ error: 'Unauthorized' });
  }
}

async function validateLeadsTokenOrExit() {
  const url = `${API}/${LEADS_PAGE_ID}?fields=id&access_token=${LEADS_TOKEN}`;
  const metaRes = await fetch(url);
  const data = await metaRes.json();

  if (data?.error) {
    console.error('Invalid Meta token for webhook lead fetch (META_ADS_TOKEN or META_LEADS_TOKEN):', data.error.message);
    console.error('Token must include page permissions and be valid for the configured page. Running in degraded mode (DB-only leads).');
    leadsTokenValidated = false;
    return;
  }

  leadsTokenValidated = true;
  console.log(`Meta leads token validated for page ${data.id}`);
}

validateLeadsTokenOrExit()
  .then(() => {
    app.listen(PORT, () => console.log(`Meta leads webhook listening on :${PORT}`));
  })
  .catch((err) => {
    console.error('Failed to validate META_LEADS_TOKEN:', err.message);
    console.error('Running in degraded mode (DB-only leads).');
    app.listen(PORT, () => console.log(`Meta leads webhook listening on :${PORT}`));
  });
