-- 1830 (2026-11-24): MARKING, built as a concept — recognise → choose → execute, visible.
--
-- Owner 11/24, looking at "Man-oriented marking" as the proof of concept: "the examples are
-- poor? i feel like man oriented marking should be more clear? and the sub states it would
-- go into?" · "if the player is in man-oriented marking that is a state of marking? then we
-- should have sub states where he does certain things to accomplish it and both state
-- machines should show" · "a player should have multiple state machines for behaviour" ·
-- "focus on 1 player and all his state machines" · "build it for marking first".
--
-- What the look found: the engine's MarkMan is ZONAL (the man in his zone, handed on when he
-- leaves) but was labelled with the man-oriented concept; and marking was one state with no
-- steps.  This migration is the catalogue half of game/src/ai/concepts/Marking:
--
--   1. zonal-marking gets its own concept row; the engine's block_mark act and its two
--      behaviours move to it.  man-mark stays "follow him anywhere".
--   2. game_concept_links learns two relations the taxonomy needed:
--        kind-of   inheritance — man-mark and zonal-marking are kinds of marking
--        step-of   a sub-state — find your man, where to stand, track the runner … are steps
--                  of marking (the states a marker moves between)
--   3. The marking mind's behaviours (src/ai/behaviours.list): two kinds, eight steps, three
--      eyes states — each named by the catalogue concept it plays.  The eyes are READS.
--   4. The teaching room's words for the one-player view (message_templates kind 'teach').

INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking, principle_id)
SELECT 189, 'zonal-marking', 'Zonal marking', 'individual', 'out_of_possession', 'u10', 'wired',
       'Out of possession: the man in YOUR zone is yours — goal-side of him while he is there; he leaves it, pass him on to the next man and hold your place.',
       'He follows his man out of his zone and leaves a hole where he should be.',
       (SELECT principle_id FROM game_concepts WHERE name = 'man-mark')
 WHERE NOT EXISTS (SELECT 1 FROM game_concepts WHERE name = 'zonal-marking');

UPDATE game_engine_acts SET concept_id = (SELECT id FROM game_concepts WHERE name = 'zonal-marking'),
       note = 'MarkMan: a CB / FB / DM goal-side of the man in his zone (radius and stand-off by that man''s metres off our goal, DFL-fitted, G5.72); hands him on when he leaves the zone — zonal, not man-oriented'
 WHERE code = 'block_mark';
UPDATE game_engine_behaviours SET concept_id = (SELECT id FROM game_concepts WHERE name = 'zonal-marking'), other_concepts = 'marking, direct-opponent', confidence = 'high'
 WHERE code IN ('block_mark', 'mark_pickup_in_zone');

ALTER TABLE game_concept_links DROP CONSTRAINT IF EXISTS game_concept_links_kind_check;
ALTER TABLE game_concept_links ADD CONSTRAINT game_concept_links_kind_check
      CHECK (kind = ANY (ARRAY['requires', 'refines', 'counters', 'lapses-to', 'kind-of', 'step-of']));

INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT a.id, b.id, v.kind
  FROM (VALUES
    ('man-mark', 'marking', 'kind-of'), ('zonal-marking', 'marking', 'kind-of'),
    ('find-your-man', 'marking', 'step-of'), ('mark-position', 'marking', 'step-of'),
    ('near-tight-far-zone', 'marking', 'step-of'), ('tighten-near-goal', 'marking', 'step-of'),
    ('track-the-runner', 'marking', 'step-of'), ('follow-the-dropper', 'marking', 'step-of'),
    ('direct-opponent', 'marking', 'step-of'), ('jump-the-pass', 'marking', 'step-of'),
    ('defend-your-man', 'marking', 'step-of'), ('scan-defending', 'marking', 'step-of')
  ) AS v(a, b, kind)
  JOIN game_concepts a ON a.name = v.a JOIN game_concepts b ON b.name = v.b
ON CONFLICT DO NOTHING;

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read)
SELECT v.code, 'game/src/ai/concepts/Marking.cpp', 1, 'marking mind 11/24', 'individual', v.what, 'concept',
       (SELECT id FROM game_concepts WHERE name = v.concept), v.other, NULL, 'high', v.is_read
  FROM (VALUES
    ('mark_kind_man',       'man-mark',           NULL, false, 'Marking, man-oriented: his man is his anywhere on the pitch — he drops off, the marker follows him in.'),
    ('mark_kind_zonal',     'zonal-marking',      NULL, false, 'Marking, zonal: his man is his while he is within the zone round the marker''s own spot; he leaves it and is passed on.'),
    ('mark_pick_up',        'find-your-man',      NULL, false, 'Step: more than 6 m off where he should stand on his man — he gets to him at full pace.'),
    ('mark_position',       'mark-position',      'near-tight-far-zone, tighten-near-goal', false, 'Step: goal-side of his man, further round to the ball''s side and tighter the nearer the ball is (1 m near, 4 m far), tighter again inside 20 m of our goal.'),
    ('mark_track_runner',   'track-the-runner',   NULL, false, 'Step: his man moves at our goal at 3.5 m/s or more and is level with him or beyond — he goes with him, goal-side of where the man will be in 0.6 s.'),
    ('mark_follow_dropper', 'follow-the-dropper', NULL, false, 'Step (man-oriented only): his man moves away from our goal at 2.5 m/s or more — he follows him in, tight behind.'),
    ('mark_pass_on',        'direct-opponent',    'zonal-marking', false, 'Step (zonal only): his man is more than 14 m from the marker''s own spot — he lets him go and returns to it.'),
    ('mark_jump_pass',      'jump-the-pass',      'intercept', false, 'Step: he has seen a pass on its way to his man — he goes as the ball goes, to arrive tight and goal-side as it does.'),
    ('mark_no_turn',        'defend-your-man',    NULL, false, 'Step: his man has the ball with his back to our goal — tight behind him (0.8 m), not diving in, so he cannot turn.'),
    ('mark_contain',        'defend-your-man',    'engage-or-contain', false, 'Step: his man has the ball and has turned — he stands off 2.5 m goal-side and contains.'),
    ('eyes_both',           'scan-defending',     'mark-position', true, 'Eyes: ball and man are under about 110° apart from where he stands — he opens up and sees both.'),
    ('eyes_man',            'scan-defending',     NULL, true, 'Eyes: he cannot see both — every 1.2 s he looks over his shoulder at his man for 0.3 s. What he sees then is all he knows of him.'),
    ('eyes_ball',           'scan-defending',     NULL, true, 'Eyes: he cannot see both and is watching the ball — his man is where he last saw him, which may be wrong.')
  ) AS v(code, concept, other, is_read, what)
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Game Center', 'Teaching room — one player''s mind: ' || v.l, 'teach', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('how to open it', 'mind_hint', 'Tap one of ours to see inside his head.', 1300),
    ('panel heading ({n} = his number)', 'mind_title', 'Our #{n} — what he is doing and why', 1301),
    ('close', 'mind_close', '✕ Back to everyone', 1302),
    ('a player with no mind yet ({n})', 'mind_none', 'Our #{n} is on a simple job: he stands where the plan puts him. Marking is the first job built with a mind — tap a marker.', 1303),
    ('section: the stack', 'mind_stack', 'His states, top down', 1304),
    ('stack level: team', 'mind_l_team', 'Team', 1305),
    ('stack level: job', 'mind_l_job', 'Job', 1306),
    ('stack level: kind', 'mind_l_kind', 'Kind', 1307),
    ('stack level: step', 'mind_l_step', 'Step', 1308),
    ('the job name', 'mind_job_marking', 'Marking their #{n}', 1309),
    ('section: side machines', 'mind_side', 'Running alongside', 1310),
    ('machine: eyes', 'mind_m_eyes', 'Eyes', 1311),
    ('machine: movement', 'mind_m_move', 'Movement', 1312),
    ('movement: standing', 'mind_move_stand', 'standing', 1313),
    ('movement: walking', 'mind_move_walk', 'walking', 1314),
    ('movement: jogging', 'mind_move_jog', 'jogging', 1315),
    ('movement: running', 'mind_move_run', 'running', 1316),
    ('movement: sprinting', 'mind_move_sprint', 'sprinting', 1317),
    ('section: memory', 'mind_memory', 'What he knows (and how old it is)', 1318),
    ('memory: his man, seen now', 'mind_man_fresh', 'His man: in view now', 1319),
    ('memory: his man, stale ({s} seconds, {m} metres off)', 'mind_man_stale', 'His man: last seen {s} s ago — he is really {m} m from where our man thinks', 1320),
    ('memory: the ball, seen now', 'mind_ball_fresh', 'The ball: in view now', 1321),
    ('memory: the ball, stale ({s})', 'mind_ball_stale', 'The ball: last seen {s} s ago', 1322),
    ('memory fact: his man has the ball, back to goal', 'mind_f_back', 'His man has it, back to our goal', 1323),
    ('memory fact: his man has the ball, turned', 'mind_f_turned', 'His man has it and has turned', 1324),
    ('memory fact: pass on its way', 'mind_f_pass', 'A pass is on its way to his man', 1325),
    ('section: options', 'mind_options', 'What he weighed', 1326),
    ('option: chosen', 'mind_o_win', 'doing it', 1327),
    ('option: wanted, still reacting', 'mind_o_wants', 'about to — reacting', 1328),
    ('option: cue true, lost on score', 'mind_o_true', 'true, but outranked', 1329),
    ('option: cue not true', 'mind_o_false', 'not the situation', 1330),
    ('section: timeline', 'mind_timeline', 'What he has done', 1331),
    ('pitch legend: the ghost', 'mind_ghost', 'Hollow ring = where he thinks his man is', 1332),
    ('the engine has him for a moment', 'mind_off', 'Right now the engine has him — first to a loose ball, or the ball is dead. Below is his mind as it was a moment ago.', 1336),
    ('marking kind switch: label', 'mark_kind', 'Marking', 1333),
    ('marking kind switch: man-oriented', 'mark_kind_man', 'Man-oriented', 1334),
    ('marking kind switch: zonal', 'mark_kind_zonal', 'Zonal', 1335)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'teach' AND m.tier = v.t);

-- The 🧬 Taxonomy page's words for the two new relations (a concept's sheet, "How it relates").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('relation: a kind of', 'link_kind_of', 'A kind of', 138),
    ('relation: its kinds', 'link_kind_of_by', 'One kind of it:', 139),
    ('relation: a step of', 'link_step_of', 'A step of', 140),
    ('relation: its steps', 'link_step_of_by', 'One of its steps:', 141)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
