-- 857 (2026-10-29) — #apsl-pyramid map HUD: the shortest drive — the derby.
--
-- Owner 2026-10-29: "add shortest drive too … put 'Derby' next to
-- 'shortest drive'."  The two APSL teams of a conference whose grounds are
-- the closest Sunday drive apart.  Cached rows without it are re-computed.
ALTER TABLE pyramid_conference_travel ADD COLUMN IF NOT EXISTS min_minutes numeric;
ALTER TABLE pyramid_conference_travel ADD COLUMN IF NOT EXISTS min_from_team_id integer REFERENCES pyramid_teams(id) ON DELETE SET NULL;
ALTER TABLE pyramid_conference_travel ADD COLUMN IF NOT EXISTS min_to_team_id integer REFERENCES pyramid_teams(id) ON DELETE SET NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — map HUD: shortest drive (derby)', 'apsl_pyramid', 'map_short', NULL, 'Shortest drive · Derby: {a} ↔ {b} — {time}', 151, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'map_short');
