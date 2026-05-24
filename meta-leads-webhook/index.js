'use strict';

const express      = require('express');
const { Pool }     = require('pg');

const app  = express();
app.use(express.json());

// ── Config ────────────────────────────────────────────────────────────
const PORT               = process.env.META_LEADS_PORT   || 3003;
const VERIFY_TOKEN       = process.env.META_LEADS_VERIFY_TOKEN;
const ACCESS_TOKEN       = process.env.META_ADS_TOKEN;
const API                = 'https://graph.facebook.com/v21.0';

if (!VERIFY_TOKEN)   { console.error('Missing META_LEADS_VERIFY_TOKEN'); process.exit(1); }
if (!ACCESS_TOKEN)   { console.error('Missing META_ADS_TOKEN');          process.exit(1); }

const pool = new Pool({
  host:     process.env.POSTGRES_HOST     || 'db',
  port:     parseInt(process.env.POSTGRES_PORT || '5432', 10),
  database: process.env.POSTGRES_DB       || 'footballhome',
  user:     process.env.POSTGRES_USER     || 'footballhome_user',
  password: process.env.POSTGRES_PASSWORD || 'footballhome_pass',
});

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
        const url = `${API}/${leadgen_id}?fields=field_data&access_token=${ACCESS_TOKEN}`;
        const metaRes  = await fetch(url);
        const metaData = await metaRes.json();

        if (metaData.error) {
          console.error('Meta lead fetch error:', metaData.error.message);
          continue;
        }

        // Extract common fields from field_data array
        const fields = {};
        for (const f of (metaData.field_data || [])) {
          fields[f.name] = f.values?.[0] ?? null;
        }

        await pool.query(
          `INSERT INTO leads (leadgen_id, form_id, page_id, ad_id, name, email, phone, raw_fields)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
           ON CONFLICT (leadgen_id) DO NOTHING`,
          [
            leadgen_id,
            form_id  || null,
            page_id  || null,
            ad_id    || null,
            fields['full_name']    || fields['name']         || null,
            fields['email']        || fields['email_address'] || null,
            fields['phone_number'] || fields['phone']         || null,
            JSON.stringify(metaData.field_data || []),
          ]
        );

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
    const fields = [
      'name', 'status',
      'creative{name,body,title,image_url,object_story_spec}'
    ].join(',');
    const url = `${API}/act_1792823854148245/ads?fields=${encodeURIComponent(fields)}&limit=50&access_token=${ACCESS_TOKEN}`;
    const metaRes  = await fetch(url);
    const metaData = await metaRes.json();

    if (metaData.error) {
      return res.status(502).json({ error: metaData.error.message });
    }

    const ads = (metaData.data || []).map(ad => {
      const c    = ad.creative || {};
      const spec = c.object_story_spec?.link_data || {};
      return {
        id:        ad.id,
        name:      ad.name,
        status:    ad.status,
        headline:  c.title  || spec.name  || null,
        body:      c.body   || spec.message || null,
        image_url: c.image_url || null,
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

// ── GET /api/leads — serve leads to frontend ──────────────────────────
app.get('/api/leads', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, leadgen_id, form_id, page_id, ad_id,
              name, email, phone, raw_fields, created_at
       FROM leads
       ORDER BY created_at DESC`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching leads:', err.message);
    res.status(500).json({ error: 'Failed to fetch leads' });
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

app.listen(PORT, () => console.log(`Meta leads webhook listening on :${PORT}`));
