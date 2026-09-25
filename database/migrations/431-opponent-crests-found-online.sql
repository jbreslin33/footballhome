-- ─────────────────────────────────────────────────────────────────────
-- Opponent crests found online (2026-09-25, owner: "can you find missing
-- ones on internet?").  Four opponents on the calendar had no crest.
-- Files placed under frontend/images/teams/logos; the backend imports
-- them into club_logos (source = 'legacy') on its next start (mig 428).
--
--   East Falls           → East Falls Sports Association (EFSA bell crest,
--                          from @efsa_soccer)             PPR U12 boys
--   Parkwood             → Parkwood Youth Organization (Vikings, pyo.org)
--                                                         PPR U8 boys
--   West Philly          → West Philadelphia Soccer Academy (their crest)
--                                                         PPR
--   Philadelphia Falcons → Philadelphia Falcons Soccer Club (emblem from
--                          the club wordmark); they play in the Tri-County
--                          Women's league as Falcons Orange / Falcons Green
--
-- Torresdale (Torresdale Boys Club) has no real crest published anywhere
-- reachable — only platform placeholders — so it stays unresolved.
-- ─────────────────────────────────────────────────────────────────────
CREATE TEMP TABLE seed_clubs (name TEXT, logo_url TEXT, aliases TEXT[]) ON COMMIT DROP;
INSERT INTO seed_clubs VALUES
  ('East Falls Sports Association',    '/images/teams/logos/east-falls.png',                       ARRAY['East Falls','EFSA','East Falls Sports Association']),
  ('Parkwood Youth Organization',      '/images/teams/logos/parkwood-youth-organization.png',      ARRAY['Parkwood','PYO','Parkwood Youth Organization']),
  ('West Philadelphia Soccer Academy', '/images/teams/logos/west-philadelphia-soccer-academy.png', ARRAY['West Philly','West Philadelphia','WPSA','West Philadelphia Soccer Academy']),
  ('Philadelphia Falcons',             '/images/teams/logos/philadelphia-falcons.png',             ARRAY['Philadelphia Falcons','Philly Falcons','Falcons Orange','Falcons Green']);

INSERT INTO clubs (organization_id, name, logo_url)
SELECT NULL, s.name, s.logo_url FROM seed_clubs s
 WHERE NOT EXISTS (SELECT 1 FROM clubs c WHERE LOWER(BTRIM(c.name)) = LOWER(BTRIM(s.name)));

-- A club that already existed but had no crest gets this one (imported on start).
UPDATE clubs c SET logo_url = s.logo_url
  FROM seed_clubs s
 WHERE LOWER(BTRIM(c.name)) = LOWER(BTRIM(s.name)) AND c.logo_id IS NULL AND COALESCE(c.logo_url, '') = '';

INSERT INTO club_aliases (club_id, alias, notes)
SELECT c.id, a.alias, 'found online (mig ' || '431' || ')'
  FROM seed_clubs s
  JOIN clubs c ON LOWER(BTRIM(c.name)) = LOWER(BTRIM(s.name))
  CROSS JOIN LATERAL unnest(s.aliases) AS a(alias)
ON CONFLICT DO NOTHING;
