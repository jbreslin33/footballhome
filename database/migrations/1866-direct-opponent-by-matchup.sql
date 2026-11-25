-- 1866 (2026-11-24): DIRECT OPPONENT by the matchup, not by whoever is nearest — and a room
-- where a concept can be watched switched on.
--
-- Owner 11/24, on the first build: "direct opponent would never be that far away lol. a
-- direct opponent is normally 9 vs 4,5  10 v 6 2 v 7 11v3 8v8 but of course in the heat of
-- battle you have to adjust to the ball area and find a direct opponent for that part of
-- pitch or battle sceen" · "i am not seeing the concept ran?"
--
-- The same pairs he gave on 10/24 (mig 694); game_direct_opponents was emptied by the
-- clean slate (mig 1092) and nothing read it since. Back in, and game/src/ai/concepts/
-- DirectOpponent now pairs in three steps: the BATTLE (men within 18 m of the ball pair with
-- who is there), then the MATCHUP by these numbers (wide men along their own touchline),
-- then — only for a man whose numbers find nobody in their shape — the nearest man left
-- within 20 m. Never a man across the pitch.
--
-- And game_concept_dials: the model params that switch a concept on. The clip viewer opens a
-- private room of the full engine (/game?trainer=1&concept=<id>) with them on for both sides,
-- so a concept the real sim keeps at zero is seen being done.

INSERT INTO game_direct_opponents (number, opponent_number, note) VALUES
  (9, 4, 'the 9 between their centre-backs — the -1'), (9, 5, 'the 9 between their centre-backs — the -1'),
  (4, 9, 'two centre-backs on their 9 — one marks, the other is the +1'), (5, 9, 'two centre-backs on their 9 — one marks, the other is the +1'),
  (10, 6, ''), (6, 10, ''), (8, 8, ''),
  (2, 7, 'along the touchline: the engine pairs wide men on the same side whichever of 7 / 11 that is'),
  (7, 2, ''), (3, 11, ''), (11, 3, '')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS game_concept_dials (
  concept_id smallint NOT NULL REFERENCES game_concepts(id),
  param text NOT NULL,
  on_milli bigint NOT NULL,
  note text NOT NULL DEFAULT '',
  PRIMARY KEY (concept_id, param)
);
COMMENT ON TABLE game_concept_dials IS
  'The game_model_params key(s) that switch a concept on, and the value that means on (×1000). The real sim uses whatever game_model_params holds (no row = off); the concept clip viewer''s private room sets these for both sides.';
INSERT INTO game_concept_dials (concept_id, param, on_milli, note)
SELECT c.id, v.param, v.on_milli, v.note FROM game_concepts c JOIN (VALUES
  ('pressing-distance', 'physics.pressdist.hold', 1000, 'the whole step back into reach'),
  ('cover-shadow', 'physics.shadow.press', 1000, 'the presser fully onto the lane to the receiver')
) AS v(name, param, on_milli, note) ON v.name = c.name
ON CONFLICT DO NOTHING;

-- The behaviours: the first build's "nearest to his place" is gone.
DELETE FROM game_engine_behaviours WHERE code = 'do_nearest_in_his_area';
INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, 'game/src/ai/concepts/DirectOpponent.cpp', 1, 'direct opponent by matchup 11/24', v.who, v.what, 'concept',
       (SELECT id FROM game_concepts WHERE name = v.concept), v.other, NULL, 'high', true, true
  FROM (VALUES
    ('do_matchup_by_number', 'individual', 'direct-opponent', 'match-up',
     'Reads who his man is from the matchup by position number (game_direct_opponents): the 9 on their 4 or 5, the 4 and 5 on their 9, 10 on 6, 6 on 10, 8 on 8, full-backs and wingers on each other. Of his matchup men not already taken, the nearer.'),
    ('do_wide_by_touchline', 'individual', 'direct-opponent', '',
     'Wide men pair along their own touchline: a full-back takes the winger on his side whichever number that winger wears.'),
    ('do_battle_near_ball', 'group', 'direct-opponent', 'take-most-dangerous, nearest-decides',
     'In the heat of battle: everyone within 18 m of the ball pairs with the opponents who are actually in that scene, nearest first, nobody twice — the matchup gives way around the ball.'),
    ('do_nearest_when_no_matchup', 'individual', 'direct-opponent', 'match-up',
     'One whose number finds nobody in their shape (a back three, no 10) takes the nearest man left — but only within 20 m of his place; otherwise he is a spare man.')
  ) AS v(code, who, concept, other, what)
ON CONFLICT (code) DO NOTHING;
UPDATE game_engine_behaviours SET what = 'His man stays his until another of ours is at least 4 m better placed to take him, so two men do not swap an opponent back and forth.'
 WHERE code = 'do_keep_until_better';
UPDATE game_engine_behaviours SET what = 'Where two of ours share one of theirs (the 4 and 5 on their 9), the nearer takes him and the other has nobody: the spare man, one more at the back.'
 WHERE code = 'do_spare_man';
UPDATE game_engine_behaviours SET what = 'Where one of ours has two of theirs (our 9 on their 4 and 5), he takes the nearer and the other is left free: one fewer up front.'
 WHERE code = 'do_free_man';

UPDATE game_concepts SET definition =
  'The one opponent a defender is responsible for. It starts from the matchup — who lines up against whom: the 9 against their two centre-backs, the two centre-backs against their 9 (so one of them is the spare man), the 10 against their 6, the 6 against their 10, the 8 against their 8, each full-back against the winger on his side. In the heat of battle it changes: around the ball, you take the man who is actually in your part of that scene, and he is yours until the picture changes. Not this: following one man everywhere (man-oriented marking), and not simply whoever is nearest.'
 WHERE name = 'direct-opponent';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('room banner ({concept})', 'room_on', '▶ A private match with "{concept}" switched ON for both teams — the real sim keeps it off until the data says it helps', 310),
    ('room banner, no dial', 'room_live', 'The live match — this is read from the real sim, nobody is told to do it', 311),
    ('pair from the matchup ({num}, {man})', 'pair_matchup', 'his matchup: #{num} v #{man}', 312),
    ('pair from the battle near the ball', 'pair_battle', 'battle near the ball', 313),
    ('pair: nearest man (no matchup in their shape)', 'pair_nearest', 'no matchup in their shape — the nearest man', 314),
    ('example line for pressing distance done ({i}, {n}, {num}, {player})', 'clip_which_reach_on', 'Example {i} of {n} — #{num} {player} steps off his place to keep his man in reach', 315),
    ('caption while he steps ({num}, {player}, {man}, {gap}, {reach}, {verdict})', 'cap_reach_live',
     '#{num} {player}: his man #{man} is {gap} m away · he can reach {reach} m while a pass to him travels → {verdict}', 316)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
