-- 2216 🏋️ Exercises from the book "terzis-mourinho-real-madrid-defending" into the exercise catalog (mig 2191).
-- Every practice the book sets out, in OUR OWN WORDS, with app page numbers
-- (the diagram is the book page).  Written by scripts/exercises/sync.py load.
-- Re-runnable: clears this book's exercises first.
BEGIN;
DELETE FROM exercises WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending');
INSERT INTO exercises (title, category_id, opposition, moment, source_id, book_id, page_from, page_to, source_ref, coach,
  objective, setup, procedure, rules, progressions, coaching_points, players_text, min_players, max_players,
  area_text, area_length_m, area_width_m, duration_min, has_goals, has_keepers, directional, age_text, sort_order)
SELECT v.t, c.id, v.opp, v.m, b.source_id, b.id, v.pf::int, v.pt::int, v.ref, v.coach, v.obj, v.setup, v.proc, v.rules, v.prog, v.cp,
  v.players, v.mn::int, v.mx::int, v.area, v.len::real, v.wid::real, v.dur::real, v.goals::boolean, v.gk::boolean, v.dir::boolean, v.age, v.so
FROM (VALUES
  ('Back four drop and step for offside', 'defending', 'passive', 'out_of_possession', 14, 17, 'Example Practice: Defending an Open Ball Situation', 'Mourinho (Real Madrid)', 'Teach the back four and holding midfielder when to drop off in an open ball situation and when to push up together once the ball is closed down, catching forwards offside.', 'Full-size pitch, one half used. Four defenders start on cones across the line in front of the box with a second set of cones a few yards behind them; a holding midfielder starts near the centre circle and one attacker with the ball starts just inside his own half.', 'The attacker dribbles forward; the four defenders retreat to the cones behind them as if tracking runners while the holding midfielder sprints over to press the ball. The moment the midfielder closes the carrier down, the four defenders sprint forward together in a flat line.', NULL, 'Add three forwards plus a goalkeeper (9 outfield players in all). When the carrier dribbles, the forwards run in behind; once he crosses the halfway line between the cones he may pass through for them to score. Defenders track the runs, aim to stop a shot and clear; if the midfielder shuts the ball down in time it becomes a closed ball and the line steps up to leave the forwards offside. Can be used to train the attackers too, and a points system can make it a 2-team competition.', 'Timing of the drop and step-up is everything; all four move together and stay in one straight line; start slowly and build speed; in the progression the through pass must be weighted for the runner; use players in their match positions.', '4 defenders + 1 defensive midfielder + 1 attacker (progression: 5 defenders/midfielder v 4 attackers + GK)', 6, 10, 'Full-size pitch (half used)', NULL, NULL, NULL, false, false, false, NULL, 10)
) AS v(t, cat, opp, m, pf, pt, ref, coach, obj, setup, proc, rules, prog, cp, players, mn, mx, area, len, wid, dur, goals, gk, dir, age, so)
JOIN exercise_categories c ON c.code = v.cat
CROSS JOIN (SELECT id, source_id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending') b;
INSERT INTO schema_migrations (filename) VALUES ('2216-exercises-book-terzis-mourinho-real-madrid-defending.sql') ON CONFLICT DO NOTHING;
COMMIT;
