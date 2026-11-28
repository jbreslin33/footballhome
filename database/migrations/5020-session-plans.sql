-- 5020 (2026-11-27): 🗓 Session plans — exercises from the catalog tied to
-- practices and to games (the warm-up); the old Days & Exercises / Practice
-- Plans planner retires.
--
-- Owner: "if we get the exercises IN. then making it so we can tie it to a
-- practice event and even a game as the warmup" · "for youth right now its
-- simple mon,wed,fri we sync exercises to those. for men the game days vary
-- but usually sunday. so do we need special thing for men like -1 game day
-- etc?" · plan agreed: youth by weekday, men/women by match day (MD+1, MD-3,
-- MD-2, MD-1, MD warm-up, no-game week) · "yes build it" · "get rid of old
-- stuff".
--
--   session_templates           one per team × slot.  Slot = weekday (1 Mon
--                               … 7 Sun, youth) or match-day offset (men /
--                               women: +1, -3, -2, -1, 0 = game warm-up) or
--                               the no-game-week plan.
--   session_template_exercises  the template's exercises in order, minutes,
--                               note.
--   fh_event_sessions           a coach edited THIS practice/game: its own
--                               copy wins over the template (also the record
--                               of what was actually run).
--   fh_event_session_exercises  that copy's exercises.
--
-- A practice finds its slot from the calendar: youth by its weekday; men and
-- women by days to the team's next game (or days since the last one for
-- MD+1).  A game is MD 0 = the warm-up.  Logic: models/SessionPlans.
BEGIN;

CREATE TABLE IF NOT EXISTS session_templates (
    id          serial PRIMARY KEY,
    team_id     integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    anchor      text NOT NULL CHECK (anchor IN ('weekday', 'match_day', 'no_game')),
    weekday     smallint CHECK (weekday BETWEEN 1 AND 7),       -- ISO: 1 Mon … 7 Sun
    md_offset   smallint CHECK (md_offset BETWEEN -6 AND 2),    -- 0 = game day (warm-up)
    theme       text,                                           -- coach's focus for the slot
    updated_at  timestamptz NOT NULL DEFAULT now(),
    CHECK ((anchor = 'weekday'   AND weekday IS NOT NULL AND md_offset IS NULL)
        OR (anchor = 'match_day' AND md_offset IS NOT NULL AND weekday IS NULL)
        OR (anchor = 'no_game'   AND weekday IS NULL AND md_offset IS NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS session_templates_slot_uq
    ON session_templates (team_id, anchor, COALESCE(weekday, 0), COALESCE(md_offset, 99));

CREATE TABLE IF NOT EXISTS session_template_exercises (
    id           serial PRIMARY KEY,
    template_id  integer NOT NULL REFERENCES session_templates(id) ON DELETE CASCADE,
    exercise_id  integer NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    sort_order   integer NOT NULL DEFAULT 0,
    minutes      smallint CHECK (minutes BETWEEN 1 AND 180),
    note         text
);
CREATE INDEX IF NOT EXISTS session_template_exercises_tpl_idx ON session_template_exercises (template_id, sort_order);

CREATE TABLE IF NOT EXISTS fh_event_sessions (
    fh_event_id  bigint PRIMARY KEY REFERENCES fh_events(id) ON DELETE CASCADE,
    edited_by    integer REFERENCES persons(id) ON DELETE SET NULL,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fh_event_session_exercises (
    id           serial PRIMARY KEY,
    fh_event_id  bigint NOT NULL REFERENCES fh_event_sessions(fh_event_id) ON DELETE CASCADE,
    exercise_id  integer NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    sort_order   integer NOT NULL DEFAULT 0,
    minutes      smallint CHECK (minutes BETWEEN 1 AND 180),
    note         text
);
CREATE INDEX IF NOT EXISTS fh_event_session_exercises_ev_idx ON fh_event_session_exercises (fh_event_id, sort_order);

-- ── The 8 exercises from the old planner move into the catalog (source:
--    our own club) so nothing is lost; the 2 old practices keep their lists.
INSERT INTO game_sources (code, kind, title, verified)
VALUES ('fh-lighthouse', 'club', 'Lighthouse 1893 — our own sessions', true)
ON CONFLICT (code) DO NOTHING;

CREATE TEMP TABLE _old_ex_map (old_id bigint, new_id integer) ON COMMIT DROP;
WITH src AS (
    SELECT o.id AS old_id, o.title,
           COALESCE(NULLIF(o.description, ''), o.title) AS objective,
           NULLIF(o.setup, '') AS setup, NULLIF(o.coaching_points, '') AS cp,
           NULLIF(o.min_players, 0) AS mn, NULLIF(o.max_players, 0) AS mx,
           NULLIF(o.default_duration_minutes, 0) AS dur,
           CASE o.id WHEN 2 THEN 'rondo' WHEN 3 THEN 'possession' WHEN 4 THEN 'technical'
                     WHEN 5 THEN 'passing_unopposed' WHEN 6 THEN 'one_v_one' WHEN 7 THEN 'technical'
                     WHEN 8 THEN 'small_sided_game' WHEN 12 THEN 'positional_game' ELSE 'possession' END AS cat,
           row_number() OVER (ORDER BY o.id) AS rn
      FROM club_game_model_exercises o
     WHERE NOT EXISTS (SELECT 1 FROM exercises e JOIN game_sources s ON s.id = e.source_id
                        WHERE s.code = 'fh-lighthouse' AND e.title = o.title)
), ins AS (
    INSERT INTO exercises (title, category_id, source_id, objective, setup, coaching_points,
                           min_players, max_players, duration_min, coach, sort_order)
    SELECT src.title, c.id, (SELECT id FROM game_sources WHERE code = 'fh-lighthouse'),
           src.objective, src.setup, src.cp, src.mn, src.mx, src.dur, 'Lighthouse 1893', src.rn * 10
      FROM src JOIN exercise_categories c ON c.code = src.cat
    RETURNING id, title
)
INSERT INTO _old_ex_map SELECT src.old_id, ins.id FROM src JOIN ins ON ins.title = src.title;

INSERT INTO fh_event_sessions (fh_event_id)
SELECT DISTINCT pr.fh_event_id FROM club_game_model_practices pr
  JOIN club_game_model_sessions s ON s.practice_id = pr.id
  JOIN club_game_model_session_exercises se ON se.session_id = s.id
 WHERE pr.fh_event_id IS NOT NULL
ON CONFLICT DO NOTHING;
INSERT INTO fh_event_session_exercises (fh_event_id, exercise_id, sort_order, note)
SELECT pr.fh_event_id, m.new_id, row_number() OVER (PARTITION BY pr.fh_event_id ORDER BY s.sort_order, se.sequence_order, se.id) * 10,
       NULLIF(se.notes, '')
  FROM club_game_model_practices pr
  JOIN club_game_model_sessions s ON s.practice_id = pr.id
  JOIN club_game_model_session_exercises se ON se.session_id = s.id
  JOIN _old_ex_map m ON m.old_id = se.exercise_id
 WHERE pr.fh_event_id IS NOT NULL;

-- ── Old planner out.
DROP TABLE IF EXISTS club_game_model_session_exercises, club_game_model_sessions,
                     club_game_model_practices, club_game_model_days,
                     club_game_model_exercise_principles, club_game_model_exercise_sub_principles,
                     club_game_model_exercise_action_items, club_game_model_exercise_images,
                     club_game_model_exercises CASCADE;
UPDATE menu_pages SET is_active = false WHERE code IN ('game-model-admin', 'practice-plan');

-- ── Wording (kind 'exercises', same family as the page).
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Exercises', v.label, 'exercises', v.tier, v.body, v.so, true, false
  FROM (VALUES
  ('Exercises — plans view pill', 'view_plans', '🗓 Plans', 40),
  ('Exercises — plans intro', 'plans_intro', 'Each team''s week. Youth plan by weekday; men and women by match day — a practice picks its plan from the days to the next game, and the game itself is the warm-up.', 41),
  ('Exercises — plans pick team', 'plans_team', 'Team', 42),
  ('Exercises — plans empty slot', 'plans_empty', 'Nothing planned — add from the exercise list (➕).', 43),
  ('Exercises — plans total minutes', 'plans_total', '{n} min', 44),
  ('Exercises — slot weekday', 'slot_weekday', '{day}', 45),
  ('Exercises — slot MD+1', 'slot_md_1', 'MD+1 · recovery', 46),
  ('Exercises — slot MD+2', 'slot_md_2', 'MD+2', 47),
  ('Exercises — slot MD-1', 'slot_md_m1', 'MD-1 · day before', 48),
  ('Exercises — slot MD-2', 'slot_md_m2', 'MD-2', 49),
  ('Exercises — slot MD-3', 'slot_md_m3', 'MD-3', 50),
  ('Exercises — slot MD-4', 'slot_md_m4', 'MD-4', 51),
  ('Exercises — slot MD', 'slot_md_0', 'MD · game warm-up', 52),
  ('Exercises — slot no game', 'slot_no_game', 'No game this week', 53),
  ('Exercises — weekday names', 'weekdays', 'Mon|Tue|Wed|Thu|Fri|Sat|Sun', 54),
  ('Exercises — add to plan button', 'add_to_plan', '➕ Add to plan', 55),
  ('Exercises — add to plan heading', 'add_heading', 'Add to which plan?', 56),
  ('Exercises — added', 'added', 'Added to {team} · {slot}', 57),
  ('Exercises — minutes field', 'minutes_short', 'min', 58),
  ('Exercises — remove', 'remove', 'Remove', 59),
  ('Exercises — no teams to plan', 'no_teams', 'You don''t coach a team you can plan for.', 60),
  ('Exercises — plans theme placeholder', 'theme_ph', 'Focus for this day (optional)', 61),
  ('Exercises — event session heading', 'ev_session', '🏋️ Session', 62),
  ('Exercises — event warm-up heading', 'ev_warmup', '🔥 Warm-up', 63),
  ('Exercises — event from plan', 'ev_from_plan', 'From the {team} plan · {slot}', 64),
  ('Exercises — event edited', 'ev_edited', 'Edited for this {kind}', 65),
  ('Exercises — event none', 'ev_none', 'No exercises planned for this slot yet.', 66),
  ('Exercises — event edit', 'ev_edit', '✏️ Edit this one', 67),
  ('Exercises — event reset', 'ev_reset', '↩ Back to the plan', 68),
  ('Exercises — event add', 'ev_add', '➕ Add exercise', 69),
  ('Exercises — event open plans', 'ev_open_plans', '🗓 Team plans', 70),
  ('Exercises — event search', 'ev_search', 'Search the catalog…', 71),
  ('Exercises — event kind practice', 'kind_practice', 'practice', 72),
  ('Exercises — event kind game', 'kind_game', 'game', 73),
  ('Exercises — up', 'up', '▲', 74),
  ('Exercises — down', 'down', '▼', 75),
  ('Exercises — game model card title', 'gm_plans_title', 'Practice plans', 76),
  ('Exercises — game model card text', 'gm_plans_moved', 'Exercises and each team''s weekly plan (weekday for youth, match day for men and women) now live on 🏋️ Exercises → 🗓 Plans.', 77),
  ('Exercises — game model card button', 'gm_plans_btn', '🗓 Open plans', 78)
  ) AS v(label, tier, body, so)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'exercises' AND m.tier = v.tier);

INSERT INTO schema_migrations (filename) VALUES ('5020-session-plans.sql') ON CONFLICT DO NOTHING;
COMMIT;
