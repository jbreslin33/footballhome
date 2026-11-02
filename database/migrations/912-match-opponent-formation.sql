-- 912 (2026-10-30) — Game Center: match the opponent's formation.
--
-- Owner: "for formation choice we need something that matches the opponent
-- formation in game center right? so i should be able to choose match
-- opponent and the opponent formation and then you put us to match with
-- libero etc. so if we play vs 4231 that actually looks like a 2323 right?"
--
-- The rule: read their shape from the front, so each of our lines meets the
-- line it marks, then add the libero behind and take one off our front line.
-- They have 10 outfield and we have 9 markers plus the free man, so one of
-- their back line is always left over.
--   4-2-3-1 → 1-3-2-4 → 2-3-2-3
--   4-3-3 is really 4-1-2-3 → 3-2-1-4 → 4-2-1-3, our 4-2-3-1
--
-- formation_matchups is the whole table of answers: pick the row, the page
-- sets formation_id and shows the note under the toolbar.  The pick is
-- saved per game, and per draft so a mock lineup can try a different one.
--
-- 2-3-2-3, 2-4-1-3, 3-3-4 and 2-4-4 also need a FIELD_SIZES entry with the
-- same code in frontend/js/screens/game-center.js.  Every shape keeps the
-- owner's numbering: 5 left of 4, 3 left, 2 right, 11 left, 7 right, 10 left
-- of 8, and a back three is 5-6-4.

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
(
  '2-3-2-3', 'Match 2-3-2-3', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 35, "y": 16, "slot": 2,  "label": "LIB", "position_id": 5},
    {"x": 65, "y": 18, "slot": 3,  "label": "CB",  "position_id": 4},
    {"x": 15, "y": 34, "slot": 4,  "label": "LB",  "position_id": 3},
    {"x": 50, "y": 34, "slot": 5,  "label": "CM",  "position_id": 6},
    {"x": 85, "y": 34, "slot": 6,  "label": "RB",  "position_id": 2},
    {"x": 35, "y": 52, "slot": 7,  "label": "CM",  "position_id": 10},
    {"x": 65, "y": 52, "slot": 8,  "label": "CM",  "position_id": 8},
    {"x": 15, "y": 70, "slot": 9,  "label": "LW",  "position_id": 11},
    {"x": 50, "y": 72, "slot": 10, "label": "ST",  "position_id": 9},
    {"x": 85, "y": 70, "slot": 11, "label": "RW",  "position_id": 7}]',
  7
),
(
  '2-4-1-3', 'Match 2-4-1-3', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 35, "y": 16, "slot": 2,  "label": "LIB", "position_id": 5},
    {"x": 65, "y": 18, "slot": 3,  "label": "CB",  "position_id": 4},
    {"x": 12, "y": 36, "slot": 4,  "label": "LB",  "position_id": 3},
    {"x": 38, "y": 36, "slot": 5,  "label": "CM",  "position_id": 6},
    {"x": 62, "y": 36, "slot": 6,  "label": "CM",  "position_id": 8},
    {"x": 88, "y": 36, "slot": 7,  "label": "RB",  "position_id": 2},
    {"x": 50, "y": 54, "slot": 8,  "label": "AM",  "position_id": 10},
    {"x": 15, "y": 70, "slot": 9,  "label": "LW",  "position_id": 11},
    {"x": 50, "y": 72, "slot": 10, "label": "ST",  "position_id": 9},
    {"x": 85, "y": 70, "slot": 11, "label": "RW",  "position_id": 7}]',
  8
),
(
  '3-3-4', 'Match 3-3-4', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB",  "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "LIB", "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 15, "y": 42, "slot": 5,  "label": "LB",  "position_id": 3},
    {"x": 50, "y": 42, "slot": 6,  "label": "CM",  "position_id": 8},
    {"x": 85, "y": 42, "slot": 7,  "label": "RB",  "position_id": 2},
    {"x": 12, "y": 68, "slot": 8,  "label": "LW",  "position_id": 11},
    {"x": 38, "y": 70, "slot": 9,  "label": "ST",  "position_id": 10},
    {"x": 62, "y": 70, "slot": 10, "label": "ST",  "position_id": 9},
    {"x": 88, "y": 68, "slot": 11, "label": "RW",  "position_id": 7}]',
  9
),
(
  '2-4-4', 'Match 2-4-4', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 35, "y": 16, "slot": 2,  "label": "LIB", "position_id": 5},
    {"x": 65, "y": 18, "slot": 3,  "label": "CB",  "position_id": 4},
    {"x": 12, "y": 40, "slot": 4,  "label": "LB",  "position_id": 3},
    {"x": 38, "y": 40, "slot": 5,  "label": "CM",  "position_id": 6},
    {"x": 62, "y": 40, "slot": 6,  "label": "CM",  "position_id": 8},
    {"x": 88, "y": 40, "slot": 7,  "label": "RB",  "position_id": 2},
    {"x": 12, "y": 68, "slot": 8,  "label": "LW",  "position_id": 11},
    {"x": 38, "y": 70, "slot": 9,  "label": "ST",  "position_id": 10},
    {"x": 62, "y": 70, "slot": 10, "label": "ST",  "position_id": 9},
    {"x": 88, "y": 68, "slot": 11, "label": "RW",  "position_id": 7}]',
  10
)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS formation_matchups (
  id            SERIAL PRIMARY KEY,
  opponent_code TEXT NOT NULL UNIQUE,
  formation_id  INTEGER NOT NULL REFERENCES formations(id),
  note          TEXT NOT NULL,
  sort_order    INTEGER NOT NULL DEFAULT 0
);
COMMENT ON TABLE formation_matchups IS 'mig 912: the opponent''s shape → our man-marking shape with a libero; note = who takes whom, shirt numbers as drawn.';

INSERT INTO formation_matchups (opponent_code, formation_id, note, sort_order)
SELECT v.opp, f.id, v.note, v.ord
  FROM (VALUES
    ('4-2-3-1', '2-3-2-3', '5 is the libero. 4 takes their striker. 3, 6, 2 take their three attacking mids. 10, 8 take their two holding mids. 11, 9, 7 press their back four, one is left free.', 1),
    ('4-3-3',   '4-2-3-1', '5 is the libero. 4 takes their striker, 3 and 2 their wingers. 8, 6 take their two central mids, 10 their holding mid. 11, 9, 7 press their back four, one is left free.', 2),
    ('4-4-2',   '3-4-3',   '6 is the libero. 5, 4 take their two strikers. 3, 10, 8, 2 take their four mids. 11, 9, 7 press their back four, one is left free.', 3),
    ('4-1-4-1', '2-4-1-3', '5 is the libero. 4 takes their striker. 3, 6, 8, 2 take their four mids. 10 takes their holding mid. 11, 9, 7 press their back four, one is left free.', 4),
    ('3-5-2',   '3-5-2',   '6 is the libero. 5, 4 take their two strikers. 3, 11, 8, 7, 2 take their five mids, 3 and 2 on the wing backs. 10, 9 press their back three, one is left free.', 5),
    ('3-4-3',   '4-4-2',   '5 is the libero. 4 takes their striker, 3 and 2 their wingers. 11, 8, 6, 7 take their four mids. 10, 9 press their back three, one is left free.', 6),
    ('5-3-2',   '3-3-4',   '6 is the libero. 5, 4 take their two strikers. 3, 8, 2 take their three mids. 11, 10, 9, 7 press their back five, one is left free.', 7),
    ('5-4-1',   '2-4-4',   '5 is the libero. 4 takes their striker. 3, 6, 8, 2 take their four mids. 11, 10, 9, 7 press their back five, one is left free.', 8)
  ) AS v(opp, ours, note, ord)
  JOIN formations f ON f.code = v.ours
ON CONFLICT (opponent_code) DO NOTHING;

ALTER TABLE match_lineup_metadata ADD COLUMN IF NOT EXISTS matchup_id INTEGER REFERENCES formation_matchups(id);
COMMENT ON COLUMN match_lineup_metadata.matchup_id IS 'mig 912: the opponent shape this lineup was matched to; NULL = the coach chose the formation directly.';
ALTER TABLE match_lineup_drafts ADD COLUMN IF NOT EXISTS matchup_id INTEGER REFERENCES formation_matchups(id);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', l, k, t, NULL, b, o, true, true
  FROM (VALUES
    ('Match opponent — dropdown, nothing picked', 'lineup_matchup', 'none',   'Match opponent…', 1),
    ('Match opponent — dropdown row ({opponent}, {ours})', 'lineup_matchup', 'option', 'vs {opponent} → {ours}', 2),
    ('Match opponent — heading on the marking note ({opponent}, {ours})', 'lineup_matchup', 'note_title', 'vs {opponent}, we play {ours}', 3)
  ) AS v(l, k, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
