-- 2260 🏋️ Exercises from the book "jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book" into the exercise catalog (mig 2191).
-- Every practice the book sets out, in OUR OWN WORDS, with app page numbers
-- (the diagram is the book page).  Written by scripts/exercises/sync.py load.
-- Re-runnable: clears this book's exercises first.
BEGIN;
DELETE FROM exercises WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book');
INSERT INTO exercises (title, category_id, opposition, moment, source_id, book_id, page_from, page_to, source_ref, coach,
  objective, setup, procedure, rules, progressions, coaching_points, players_text, min_players, max_players,
  area_text, area_length_m, area_width_m, duration_min, has_goals, has_keepers, directional, age_text, sort_order)
SELECT v.t, c.id, v.opp, v.m, b.source_id, b.id, v.pf::int, v.pt::int, v.ref, v.coach, v.obj, v.setup, v.proc, v.rules, v.prog, v.cp,
  v.players, v.mn::int, v.mx::int, v.area, v.len::real, v.wid::real, v.dur::real, v.goals::boolean, v.gk::boolean, v.dir::boolean, v.age, v.so
FROM (VALUES
  ('Switch of play to overlapping full back', 'combination', 'unopposed', 'in_possession', 14, 17, 'Example Practice: Switching Play and Quick Combinations', 'Mourinho (Real Madrid)', 'Rehearse a fast switch of play to the far flank followed by a quick combination that releases the overlapping full back.', 'Two thirds of a pitch with a goal; three mannequins stand in a line across the edge of the box as defenders. Six players start on cones (full back, winger and deep midfielder positions on each flank) with balls at the deep cones, and a seventh player starts beside the middle mannequin.', 'A deep player on one side starts the move and the ball is switched long across to the opposite flank; there the winger, central player and full back combine with short passes while the full back runs round from deep on the overlap to receive the final ball in behind. Next rep starts from the other side.', 'Use one touch where possible; alternate the side the move is played on and rotate roles often.', 'Practice Progression (p16-17): replace mannequins with 3 live defenders and add a goalkeeper; the far-side winger also joins in as an extra option and the seventh man plays as a forward. Start the same way with the switch and the full back''s overlap, but the forward now chooses the final pass/finish himself (book shows 2 sample combinations). Add a fourth defender once players cope.', 'Accurate, well-timed passes on good angles; check away from cone/mannequin before receiving; high tempo to make the switch work; full back times his run from deep to arrive on the final pass at speed. In the progression, vary the combination each time and watch body shape, run timing and pass direction.', '7 (progression: 7 attackers v 3 defenders + GK)', 7, 12, '2/3 of a pitch', NULL, NULL, NULL, true, false, true, NULL, 10)
) AS v(t, cat, opp, m, pf, pt, ref, coach, obj, setup, proc, rules, prog, cp, players, mn, mx, area, len, wid, dur, goals, gk, dir, age, so)
JOIN exercise_categories c ON c.code = v.cat
CROSS JOIN (SELECT id, source_id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book') b;
INSERT INTO schema_migrations (filename) VALUES ('2260-exercises-book-jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in.sql') ON CONFLICT DO NOTHING;
COMMIT;
