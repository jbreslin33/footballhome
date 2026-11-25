-- 1853 (2026-11-24): DIRECT OPPONENT — who is my man right now? — in the engine.
--
-- Owner 11/24, on finishing "stay in pressing distance": "for the concept he needs a direct
-- opponent right? even if its a temp direct opponent because of movement" · "yes build direct
-- opponent first".
--
-- game/src/ai/concepts/DirectOpponent: the side without the ball pairs every outfielder with
-- one of theirs — the man nearest his place in the defensive shape, nobody taken twice, a
-- pair kept until another of ours is clearly better placed (4 m), the deepest of ours the
-- spare man, their furthest man left free.  A recognition: it moves nobody, and the sim runs
-- it every tick (goldens unchanged).  Until now only centre-backs, full-backs and the holding
-- midfielder had a man, and only whoever was in their zone.
--
-- Its four behaviours, tagged and listed (171 → 175).  The page can show the pairs: the
-- match sends them with the brain feed (frame PAIRS).
INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, 'game/src/ai/concepts/DirectOpponent.cpp', 1, 'direct opponent 11/24', v.who, v.what, 'concept',
       (SELECT id FROM game_concepts WHERE name = v.concept), v.other, NULL, 'high', true, true
  FROM (VALUES
    ('do_nearest_in_his_area', 'individual', 'direct-opponent', 'match-up',
     'Reads who his man is: of their outfielders, the one nearest his own place in the team''s defensive shape. The closest pairs are made first and nobody is taken twice.'),
    ('do_keep_until_better', 'group', 'direct-opponent', 'take-most-dangerous',
     'A pair is kept as movement changes the picture: his man stays his until another of ours is at least 4 m better placed to take him, so two men do not swap an opponent back and forth.'),
    ('do_spare_man', 'team', 'match-up', 'libero, cover',
     'With the sides level, the one of ours nearest our own goal takes nobody: the spare man, one more at the back.'),
    ('do_free_man', 'team', 'match-up', 'press-minus-one',
     'With the sides level, their outfielder furthest from our goal is left free — one fewer up front. Never the man on the ball.')
  ) AS v(code, who, concept, other, what)
ON CONFLICT (code) DO NOTHING;

UPDATE game_concepts SET definition =
  'The one opponent a defender is responsible for at this moment. It starts from how the two teams line up and changes as players move: if a winger drifts inside and a full-back overlaps, the man in front of you is now a different man, and he is yours until the picture changes again. Two rules keep it orderly — nobody is taken by two defenders, and you keep your man until a teammate is clearly better placed to take him. Usually one defender at the back has nobody (the spare man) and one of their players furthest from our goal is left free. Not this: following one man everywhere (that is man-oriented marking); your direct opponent can change many times in a minute.'
 WHERE name = 'direct-opponent';
UPDATE game_concepts SET definition =
  'Reading how many they have where, and matching up so we are never short where it matters: one more defender than they have strikers, so somebody is always free to cover; and one fewer presser than they have at the back, because we cannot be up everywhere. The spare defender and their free defender both come from this.'
 WHERE name = 'match-up';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — direct opponents: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('pairs toggle', 'pairs_show', 'Show who has whom', 280),
    ('tag: the spare man', 'pairs_spare', 'SPARE MAN', 281),
    ('tag: their free man', 'pairs_free', 'LEFT FREE', 282),
    ('caption: his man ({num}, {player})', 'cap_his_man', 'His man: #{num} {player}', 283),
    ('caption: he has nobody', 'cap_no_man', 'He has nobody — he is the spare man', 284),
    ('caption: a change of man ({from}, {to})', 'cap_switch', 'NEW MAN → #{to} (was #{from})', 285),
    ('example line for a change of man ({i}, {n}, {num}, {player})', 'clip_which_switch', 'Example {i} of {n} — #{num} {player} changes his man', 286)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
