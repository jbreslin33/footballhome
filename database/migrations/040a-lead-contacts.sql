-- 040a-lead-contacts.sql
-- The original leads migration (040) created the `leads` table but never
-- created the companion `lead_contacts` log — the table the Leads page
-- reads from to show "✉ Emailed Xm ago" badges and the table the
-- /api/leads/:id/contact webhook writes to when a coach clicks Email
-- (or Text / WhatsApp / Call) on a lead card.
--
-- Without this table:
--   - INSERTs from POST /api/leads/:id/contact silently fail in the
--     webhook (caught + 500'd), so the click never persists.
--   - The LEFT JOIN in GET /api/leads errors and the per-card badge
--     stays blank no matter how many times the coach hits Email.
--
-- Filename uses "040a" so it sorts AFTER 040 (which creates `leads`)
-- and BEFORE 046 (which alters lead_contacts.channel CHECK). The
-- forward-only run-migrations.sh runner is alphabetic.
--
-- Safe to re-run: IF NOT EXISTS guards every object.

CREATE TABLE IF NOT EXISTS lead_contacts (
  id            SERIAL PRIMARY KEY,
  lead_id       INT NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  -- channel CHECK matches the wider set that migration 046 will enforce
  -- (text|email|whatsapp|call). Including the final shape here means 046's
  -- DROP/ADD CONSTRAINT runs as a no-op rename when applied after this.
  channel       TEXT NOT NULL
                  CHECK (channel IN ('text', 'email', 'whatsapp', 'call')),
  -- Coach / user who clicked the button. Nullable so unauthenticated
  -- automated sends (future webhook back-fill, system-triggered emails)
  -- can still be logged. ON DELETE SET NULL so removing a coach account
  -- doesn't blow away the lead's contact history.
  contacted_by  INT REFERENCES users(id) ON DELETE SET NULL,
  -- Free-form record of what was sent (subject/body, SMS text, etc).
  -- Optional; the badge UI doesn't depend on it.
  message_body  TEXT,
  -- 'sent' (default) | 'queued' | 'failed' | etc. Allowed values are
  -- intentionally open-ended for now; tighten with a CHECK later if
  -- we standardize the set.
  status        VARCHAR(20) DEFAULT 'sent',
  sent_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Covers the per-card GROUP BY lead_id + MAX(sent_at) used by GET /api/leads
-- and GET /api/leads/contact-stats. (lead_id, sent_at DESC) lets PG read
-- the MAX directly from the index.
CREATE INDEX IF NOT EXISTS idx_lead_contacts_lead_sent
  ON lead_contacts (lead_id, sent_at DESC);

-- Covers the global rolling-window aggregates in /contact-stats
-- (texts_5min, texts_hour, texts_day, etc).
CREATE INDEX IF NOT EXISTS idx_lead_contacts_channel_sent
  ON lead_contacts (channel, sent_at DESC);

COMMENT ON TABLE lead_contacts IS
  'Log of every outbound contact attempt against a Meta-form lead — '
  'email, text, whatsapp, call. Written by POST /api/leads/:id/contact, '
  'read by GET /api/leads (for the "Emailed Xm ago" badges) and '
  'GET /api/leads/contact-stats.';
