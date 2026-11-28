-- 5008 🏋️ Exercises from the book "kindle-bielsa-thirteen-steps-premier-league" into the exercise catalog (mig 2191).
-- Every practice the book sets out, in OUR OWN WORDS, with app page numbers
-- (the diagram is the book page).  Written by scripts/exercises/sync.py load.
-- Re-runnable: clears this book's exercises first.
BEGIN;
DELETE FROM exercises WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league');
INSERT INTO exercises (title, category_id, opposition, moment, source_id, book_id, page_from, page_to, source_ref, coach,
  objective, setup, procedure, rules, progressions, coaching_points, players_text, min_players, max_players,
  area_text, area_length_m, area_width_m, duration_min, has_goals, has_keepers, directional, age_text, sort_order)
SELECT v.t, c.id, v.opp, v.m, b.source_id, b.id, v.pf::int, v.pt::int, v.ref, v.coach, v.obj, v.setup, v.proc, v.rules, v.prog, v.cp,
  v.players, v.mn::int, v.mx::int, v.area, v.len::real, v.wid::real, v.dur::real, v.goals::boolean, v.gk::boolean, v.dir::boolean, v.age, v.so
FROM (VALUES
  ('Murderball non-stop 11v11', 'conditioned_game', 'opposed', NULL, 24, 24, 'Murderball', 'Bielsa (Leeds United)', 'Builds match fitness and the concentration to keep tracking defensive reference points under constant, high-intensity play.', 'Full 11 v 11 match on a normal pitch with coaching staff holding spare balls around the edges.', 'Play a normal full-sided game; whenever the ball leaves the field a coach instantly plays a new ball in so there is no stoppage and players never get a breather.', 'No dead-ball rest: every out-of-play ball is replaced immediately by a staff feed.', NULL, 'Stay switched on to your marking assignment and the position of the ball at all times; intensity is physical and mental.', '11v11', 22, 22, 'full pitch', NULL, NULL, NULL, true, true, true, NULL, 10)
) AS v(t, cat, opp, m, pf, pt, ref, coach, obj, setup, proc, rules, prog, cp, players, mn, mx, area, len, wid, dur, goals, gk, dir, age, so)
JOIN exercise_categories c ON c.code = v.cat
CROSS JOIN (SELECT id, source_id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league') b;
INSERT INTO schema_migrations (filename) VALUES ('5008-exercises-book-kindle-bielsa-thirteen-steps-premier-league.sql') ON CONFLICT DO NOTHING;
COMMIT;
