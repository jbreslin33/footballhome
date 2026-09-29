-- 495 (2026-09-29) — lineup drafts.  Owner: "we need to give lineup draft
-- permission to some members. So the official one remains official. Then
-- we need a draft tab for me, Christopher Fletcher and Gian Maldonado.
-- Then we need a pill that shows diff between them … so we can all come up
-- with a proposed 20 man and starters bench" — "everyone sees every draft,
-- and yes add make official from a draft but there should be a separate
-- official one too that i can edit directly".
--
--   lineup_drafters          who may draft for a team (also opens the Game
--                            Center picker to a player who is not a coach)
--   match_lineup_drafts      one draft per match per author, with its shape
--   match_lineup_draft_rows  the same zone / position / slot shape as
--                            match_lineups, so the editor renders a draft
--                            unchanged; "Make official" copies it across
CREATE TABLE IF NOT EXISTS lineup_drafters (
    id                 SERIAL PRIMARY KEY,
    team_id            INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    person_id          INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    granted_by_user_id INTEGER,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (team_id, person_id)
);
COMMENT ON TABLE lineup_drafters IS 'People who may keep a lineup draft for a team''s games (mig 495). Coaches and club admins draft without a row.';

CREATE TABLE IF NOT EXISTS match_lineup_drafts (
    id               SERIAL PRIMARY KEY,
    match_id         INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id          INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    author_person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    formation_id     INTEGER REFERENCES formations(id) ON DELETE SET NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (match_id, author_person_id)
);
CREATE TABLE IF NOT EXISTS match_lineup_draft_rows (
    id           SERIAL PRIMARY KEY,
    draft_id     INTEGER NOT NULL REFERENCES match_lineup_drafts(id) ON DELETE CASCADE,
    player_id    INTEGER NOT NULL,
    zone         TEXT NOT NULL CHECK (zone IN ('starter', 'bench', 'alternate')),
    position_id  INTEGER,
    slot_number  INTEGER,
    UNIQUE (draft_id, player_id)
);

-- The APSL squad: James (person 1), Christopher Fletcher (1361), Gian
-- Maldonado (14454).  Liga 1 games share the APSL roster pool (team 35).
INSERT INTO lineup_drafters (team_id, person_id, granted_by_user_id)
SELECT 35, p.id, 1 FROM persons p WHERE p.id IN (1, 1361, 14454)
   AND NOT EXISTS (SELECT 1 FROM lineup_drafters d WHERE d.team_id = 35 AND d.person_id = p.id);

-- Wording, kind 'lineup_drafts'.
CREATE OR REPLACE FUNCTION pg_temp.ld(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Game Center', p_label, 'lineup_drafts', p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_drafts' AND tier = p_tier);
$$;
SELECT pg_temp.ld('pill_official',   'Lineup drafts — official pill',      'Official', 1);
SELECT pg_temp.ld('pill_compare',    'Lineup drafts — compare pill',       'Compare', 2);
SELECT pg_temp.ld('pill_mine',       'Lineup drafts — my draft suffix',    '(mine)', 3);
SELECT pg_temp.ld('official_hint',   'Lineup drafts — official hint',      'The official lineup — what players see. Coaches edit it directly.', 4);
SELECT pg_temp.ld('draft_hint',      'Lineup drafts — own draft hint',     'Your draft. Only you can change it; everyone with draft access can see it.', 5);
SELECT pg_temp.ld('draft_readonly',  'Lineup drafts — someone else''s',    '{name}''s draft — read only.', 6);
SELECT pg_temp.ld('draft_empty',     'Lineup drafts — nothing yet',        '{name} has not started a draft for this game.', 7);
SELECT pg_temp.ld('make_official',   'Lineup drafts — make official',      '✅ Make this the official lineup', 8);
SELECT pg_temp.ld('made_official',   'Lineup drafts — after make official','{name}''s draft is now the official lineup.', 9);
SELECT pg_temp.ld('compare_note',    'Lineup drafts — compare note',       'S = starter (with position number), B = bench, A = alternate, – = not in the squad. Rows that differ are highlighted.', 10);
SELECT pg_temp.ld('compare_only_diff','Lineup drafts — differences toggle', 'Differences only', 11);
SELECT pg_temp.ld('compare_same',    'Lineup drafts — no differences',     'Every version agrees.', 12);
