-- 699: club Instagram handles — 📸 buttons on #casa-contacts / #casa-scores.
--
-- Owner 2026-10-26: "each team should have instagram button to open their
-- insta page … so we can check scores" and "lets do it from terminal but have
-- it ready when we say 'check all casa scores from insta'".  One row per club
-- per platform; the button opens https://www.instagram.com/<handle>/.  The
-- terminal check (.claude/skills/casa-insta-scores) reads the unscored games'
-- clubs from here, opens each page in Claude in Chrome and reports back —
-- SportsEngine stays the source of truth for scores.
-- Handles are edited on #casa-contacts (POST /api/opponents/club-social).

CREATE TABLE IF NOT EXISTS club_social_handles (
    id          SERIAL PRIMARY KEY,
    club_id     INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    platform    TEXT NOT NULL CHECK (platform IN ('instagram')),
    handle      TEXT NOT NULL CHECK (handle ~ '^[A-Za-z0-9._]{1,30}$'),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (club_id, platform)
);

CREATE OR REPLACE FUNCTION pg_temp.casa_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'CASA', p_label, 'casa', p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'casa' AND tier = p_tier);
$$;
SELECT pg_temp.casa_tpl('insta_open',      'CASA — Instagram button',             NULL, '📸 Instagram', 60);
SELECT pg_temp.casa_tpl('insta_open_all',  'CASA scores — open every Instagram',  NULL, '📸 Open all {n} Instagrams', 61);
SELECT pg_temp.casa_tpl('insta_handle',    'CASA contacts — handle field label',  NULL, 'Instagram', 62);
SELECT pg_temp.casa_tpl('insta_missing',   'CASA scores — clubs with no handle',  NULL, 'No Instagram on file: {clubs}', 63);
SELECT pg_temp.casa_tpl('insta_popups',    'CASA scores — pop-up hint',           NULL, 'Opening several tabs needs pop-ups allowed for this site (one time). Instagram is blocked on the home network — turn the VPN on first. From the terminal: "check all casa scores from insta".', 64);
