-- 1810 (2026-11-24): 🧬 Taxonomy of Football — a page under ⚽ Football.
--
-- Owner 11/24: "show me first the entire taxonomy of football we currently have in db and
-- c++" · "actually this should be on a page in footballhome right? under football menu?" ·
-- "taxonomy of football".  And the point behind it: "we need the engine to be aware of all
-- of 'football' and its concepts right? it doesn't mean u use it all?" — so the page shows,
-- for every concept, how far it reaches:
--
--   📚 named        a row in game_concepts, nothing more
--   🏷 a board job   a tactic_job_kinds row whose rule is 'home' (he keeps his spot; the
--                   concept is his instruction)
--   📐 placed       a job with real geometry (shared/tactics/TacticGeometry.hpp) — the
--                   🎯 Tactics board and the 🎓 teaching room can put a man there
--   ⚙️ played       the game engine runs it by itself (game_engine_acts)
--
-- #football-taxonomy reads GET /api/tactic-plans/taxonomy.  New here: the engine's own
-- vocabulary — its team phases, player states, decisions and roles live as C++ enums
-- (game/src/ai/TeamPhase.hpp, Players.hpp, Orders.hpp), so the page could not show them.
-- game_engine_terms mirrors them, the way game_engine_acts mirrors ai::Act.  A change to
-- one of those enums comes with a migration to this table.

CREATE TABLE IF NOT EXISTS game_engine_terms (
    kind       text     NOT NULL CHECK (kind IN ('phase', 'state', 'decision', 'role')),
    code       text     NOT NULL,
    title      text     NOT NULL,
    note       text,
    sort_order smallint NOT NULL DEFAULT 0,
    PRIMARY KEY (kind, code)
);
COMMENT ON TABLE game_engine_terms IS
    'The game engine''s own vocabulary, mirrored from its C++ enums (ai::Phase, the player states, ai::Why, ai::Role) for #football-taxonomy. Read-only reference; the engine never reads it.';

INSERT INTO game_engine_terms (kind, code, title, note, sort_order) VALUES
  ('phase', 'in_possession',        'In possession',        'We have the ball, settled.', 1),
  ('phase', 'attacking_transition', 'Attacking transition', 'We have just won it.', 2),
  ('phase', 'defending_block',      'Defending block',      'They have the ball, settled.', 3),
  ('phase', 'defensive_transition', 'Defensive transition', 'We have just lost it.', 4),
  ('phase', 'our_set_piece',        'Our set piece',        NULL, 5),
  ('phase', 'their_set_piece',      'Their set piece',      NULL, 6),
  ('state', 'on_ball',        'On the ball',         'He has it: shoot, pass, cross, dribble or clear.', 1),
  ('state', 'support',        'Support',             'Our ball, not his: his role''s real spot for where the ball is.', 2),
  ('state', 'receive',        'Receive',             'The pass is his: he meets it.', 3),
  ('state', 'attack_box',     'Attack the box',      'A cross or a ball into the area is coming.', 4),
  ('state', 'run_line',       'Run onto the line',   'A run in behind their back line.', 5),
  ('state', 'hold_block',     'Hold the block spot', 'Their ball: his role''s measured spot in the block.', 6),
  ('state', 'press_ball',     'Press the ball',      'The one man who steps to their carrier.', 7),
  ('state', 'chase_ball',     'Chase the ball',      'Our first man to a loose ball.', 8),
  ('state', 'mark_man',       'Mark his man',        'A centre-back, full-back or holding midfielder goal-side of the man in his zone.', 9),
  ('state', 'keeper',         'Keeper',              'Set position, the ball not his.', 10),
  ('decision', 'hold',        'Hold shape', NULL, 1),
  ('decision', 'shoot',       'Shoot', NULL, 2),
  ('decision', 'pass',        'Pass', NULL, 3),
  ('decision', 'cross',       'Cross', NULL, 4),
  ('decision', 'dribble',     'Dribble', NULL, 5),
  ('decision', 'clear',       'Clear', NULL, 6),
  ('decision', 'keeper_punt', 'Keeper punt', NULL, 7),
  ('decision', 'keeper_pos',  'Keeper position', NULL, 8),
  ('decision', 'keeper_dive', 'Keeper dive', NULL, 9),
  ('decision', 'press',       'Press', NULL, 10),
  ('decision', 'chase',       'Chase the ball', NULL, 11),
  ('decision', 'meet_pass',   'Meet the pass', NULL, 12),
  ('decision', 'restart',     'Take the restart', NULL, 13),
  ('decision', 'throw_in',    'Throw-in', NULL, 14),
  ('decision', 'corner',      'Corner', NULL, 15),
  ('decision', 'law_distance','The Law''s distance', NULL, 16),
  ('decision', 'attack_box',  'Attack the box', NULL, 17),
  ('decision', 'in_behind',   'Ball in behind', NULL, 18),
  ('decision', 'run_line',    'Run onto the line', NULL, 19),
  ('decision', 'into_space',  'Ball into space', NULL, 20),
  ('decision', 'mark',        'Mark his man', NULL, 21),
  ('role', 'cb',   'Centre-back', NULL, 1),
  ('role', 'fb',   'Full-back (a wing-back without the ball)', NULL, 2),
  ('role', 'dm',   'Holding / central midfielder', NULL, 3),
  ('role', 'am',   'Attacking midfielder', NULL, 4),
  ('role', 'wide', 'Wide forward', NULL, 5),
  ('role', 'st',   'Striker', NULL, 6)
ON CONFLICT (kind, code) DO NOTHING;

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, href, new_tab, download)
VALUES ('football-taxonomy', 'football', 'Taxonomy', '🧬', 'coach', 6, '{football-taxonomy}', NULL, false, false)
ON CONFLICT (code) DO NOTHING;
UPDATE menu_pages SET sort_order = 7 WHERE code = 'teach';
UPDATE menu_pages SET sort_order = 8 WHERE code = 'reports' AND group_code = 'football';
UPDATE menu_pages SET sort_order = 9 WHERE code = 'game';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('page title', 'title', '🧬 Taxonomy of Football', 1),
    ('under the title', 'intro', 'Everything the club has named in the game, and how far each idea reaches: named, a job on the 🎯 Tactics board, placed on the pitch, or played by the game engine by itself.', 2),
    ('tab: concepts', 'tab_concepts', '🧠 Concepts', 3),
    ('tab: techniques', 'tab_techniques', '🦶 Techniques', 4),
    ('tab: roles, measures and Laws', 'tab_more', '📏 Roles · Measures · Laws', 5),
    ('tab: the engine''s own vocabulary', 'tab_engine', '⚙️ Engine', 6),
    ('reach: every concept', 'reach_all', 'All', 10),
    ('reach: the engine plays it', 'reach_played', '⚙️ Engine plays it', 11),
    ('reach: a job with geometry', 'reach_placed', '📐 Board places it', 12),
    ('reach: a job, no geometry', 'reach_job', '🏷 Board job, no geometry', 13),
    ('reach: named only', 'reach_named', '📚 Named only', 14),
    ('search box placeholder', 'search', 'Find a concept…', 15),
    ('every moment', 'moment_all', 'Every moment', 16),
    ('concepts with no principle', 'no_principle', 'Not under a principle yet', 17),
    ('count line ({n} = shown, {total} = all)', 'count', '{n} of {total} concepts', 18),
    ('family: one player', 'family_individual', 'one player', 20),
    ('family: a few players', 'family_group', 'a few together', 21),
    ('family: the team', 'family_team', 'the team', 22),
    ('family: the keeper', 'family_keeper', 'the keeper', 23),
    ('sources ({n})', 'sources', 'sources: {n}', 24),
    ('placement rule line ({rule})', 'placed_by', 'Placed: {rule}', 25),
    ('engine line ({note})', 'played_by', 'Engine: {note}', 26),
    ('roles heading', 'h_roles', 'Roles', 30),
    ('measures heading', 'h_measures', 'What we measure', 31),
    ('Laws heading', 'h_laws', 'Laws of the Game the engine referees', 32),
    ('placement rules heading', 'h_rules', 'Placement rules (shared by the board and the teaching room)', 33),
    ('engine: phases heading', 'h_phase', 'Team phases', 40),
    ('engine: states heading', 'h_state', 'Player states', 41),
    ('engine: decisions heading', 'h_decision', 'Decisions a player can show', 42),
    ('engine: roles heading', 'h_role', 'Roles the engine plays', 43),
    ('engine: what this tab is', 'engine_intro', 'The game engine''s own vocabulary — what it can actually do today. Everything else on this page is knowledge it does not act on yet.', 44),
    ('loading', 'loading', 'Loading the taxonomy…', 50),
    ('load failed', 'failed', 'The taxonomy did not load.', 51)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
