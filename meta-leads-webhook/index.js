'use strict';
// =============================================================================
// meta-leads-webhook
// =============================================================================
//
// As of Phase 14 of the Node → C++ port, this service is reduced to ONE job:
// receive Meta's lead-gen webhook callbacks and write the corresponding row
// into the `leads` table.  Everything else (the /api/leads/* triage surface,
// /api/ads/*, /api/stream SSE, /api/persons/*, reconciliation, magic-link
// auth, RSVPs, etc.) is served by the C++ backend on :3001 — see the
// per-phase commits in backend/ for details.
//
// Why this service still exists: Meta requires a *publicly reachable* HTTPS
// endpoint that responds to its verify GET with the hub.challenge token and
// accepts the POST callback payload.  Keeping the receiver in a separate
// tiny Node service keeps the C++ build free of an Express-compatible HTTP
// surface for the Meta-specific webhook semantics and means the Marketing
// API webhook config (page subscriptions) never has to be re-pointed.
//
// Endpoints:
//   GET  /webhook/meta-leads   Meta subscription verification handshake
//   POST /webhook/meta-leads   leadgen notification → upsert into `leads`
//
// =============================================================================
const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

// ── Config ────────────────────────────────────────────────────────────────
const PORT          = process.env.META_LEADS_PORT || 3003;
const VERIFY_TOKEN  = process.env.META_LEADS_VERIFY_TOKEN;
const LEADS_PAGE_ID = process.env.META_PAGE_ID;
// Page-token preferred; LEADS_TOKEN is the historical fallback name.
const LEADS_TOKEN   = process.env.META_ADS_TOKEN || process.env.META_LEADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';

if (!VERIFY_TOKEN)  { console.error('Missing META_LEADS_VERIFY_TOKEN'); process.exit(1); }
if (!LEADS_TOKEN)   { console.error('Missing META_ADS_TOKEN (or META_LEADS_TOKEN fallback)'); process.exit(1); }
if (!LEADS_PAGE_ID) { console.error('Missing META_PAGE_ID'); process.exit(1); }

const pool = new Pool({
  host:     process.env.POSTGRES_HOST     || 'db',
  port:     parseInt(process.env.POSTGRES_PORT || '5432', 10),
  database: process.env.POSTGRES_DB       || 'footballhome',
  user:     process.env.POSTGRES_USER     || 'footballhome_user',
  password: process.env.POSTGRES_PASSWORD || 'footballhome_pass',
});

// ── Lead-row helpers ──────────────────────────────────────────────────────
// `field_data` is Meta's response shape: [{name, values:[<single string>]}].
// Flatten it to a plain {name: value} object before pulling fields out.
function extractLeadFields(fieldData) {
  const fields = {};
  for (const field of (fieldData || [])) {
    fields[field.name] = field.values?.[0] ?? null;
  }
  return fields;
}

// Blocklist of leadgen_ids that should never be re-ingested.
// Currently: 5 California leads from the APSL ad that ran against San
// Francisco instead of Philadelphia (city-key bug, fixed 2026-06-08).
const EXCLUDED_LEADGEN_IDS = new Set([
  '1216620387131716', // Ann (707 CA)
  '2389328841559768', // Alberto Castillon (209 CA)
  '1018387347196312', // Yovg Tribal (510 CA)
  '2211610912932327', // Brayan Guerra (510 CA)
  '987234783709164',  // فياض زقزوق (510 CA)
]);

// Map any of Meta's preferred-channel response variants to our stable
// canonical value ('text' | 'email' | 'whatsapp').  Meta normalizes the
// option key we set in the form, but be defensive in case a future form
// edit ships a label instead of the key.  Returns null for unknown.
function normalizePreferredChannel(raw) {
  if (!raw) return null;
  const v = String(raw).trim().toLowerCase();
  if (v === 'text'     || v === 'sms'       || v === 'phone text') return 'text';
  if (v === 'email')                                                return 'email';
  if (v === 'whatsapp' || v === 'whats app' || v === 'wa')          return 'whatsapp';
  return null;
}

async function upsertLead(lead) {
  if (EXCLUDED_LEADGEN_IDS.has(String(lead.id))) {
    return {};
  }
  const fieldData = lead.field_data || [];
  const fields = extractLeadFields(fieldData);

  // preferred_channel comes from the radio question we added to the slim
  // forms (key: 'preferred_channel').  Legacy leads from pre-question
  // forms have no such field and remain NULL — frontend handles that.
  const preferredChannel = normalizePreferredChannel(fields.preferred_channel);

  await pool.query(
    `INSERT INTO leads (leadgen_id, form_id, page_id, ad_id, name, email, phone, raw_fields, preferred_channel, created_at)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
     ON CONFLICT (leadgen_id) DO UPDATE
     SET form_id = EXCLUDED.form_id,
         page_id = EXCLUDED.page_id,
         ad_id = EXCLUDED.ad_id,
         name = EXCLUDED.name,
         email = EXCLUDED.email,
         phone = EXCLUDED.phone,
         raw_fields = EXCLUDED.raw_fields,
         preferred_channel = COALESCE(EXCLUDED.preferred_channel, leads.preferred_channel),
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
      preferredChannel,
      lead.created_time || new Date().toISOString(),
    ]
  );

  return fields;
}

// ── Meta webhook verification ─────────────────────────────────────────────
// Meta calls this once when the subscription is created and echoes back
// the challenge string to confirm the receiver is reachable.
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

// ── Meta webhook receiver ─────────────────────────────────────────────────
// Meta retries aggressively on non-2xx, so we ACK first and do the DB work
// in the background.  Every change with field === 'leadgen' triggers a
// second Graph-API fetch for the full field_data (Meta's callback only
// carries the leadgen_id), then a single UPSERT into `leads`.
app.post('/webhook/meta-leads', async (req, res) => {
  // Acknowledge immediately — Meta requires fast 200.
  res.sendStatus(200);

  if (req.body?.object !== 'page') return;

  for (const entry of (req.body.entry || [])) {
    for (const change of (entry.changes || [])) {
      if (change.field !== 'leadgen') continue;

      const { leadgen_id, form_id, page_id, ad_id } = change.value;
      if (!leadgen_id) continue;

      try {
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

// ── Startup: sanity-check the Meta token, then bind the listener ─────────
// A bad token here only matters for the second Graph-API call in POST
// /webhook/meta-leads.  We don't exit on failure — the receiver is still
// useful for verifying the subscription via GET, and a bad token simply
// means real-time leads land in the DB as raw_fields-only rows.
async function validateLeadsToken() {
  try {
    const url = `${API}/${LEADS_PAGE_ID}?fields=id&access_token=${LEADS_TOKEN}`;
    const metaRes = await fetch(url);
    const data = await metaRes.json();
    if (data?.error) {
      console.error('Invalid Meta token (META_ADS_TOKEN/META_LEADS_TOKEN):', data.error.message);
      console.error('Webhook will still verify, but POST callbacks may write rows with no field_data.');
      return;
    }
    console.log(`Meta leads token validated for page ${data.id}`);
  } catch (err) {
    console.error('Token validation failed:', err.message);
  }
}

validateLeadsToken().finally(() => {
  app.listen(PORT, () => console.log(`Meta leads webhook listening on :${PORT}`));
});
