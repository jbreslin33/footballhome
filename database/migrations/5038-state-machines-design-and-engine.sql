-- 5038 (2026-11-27): STATE MACHINES as data — what the engine runs today and what is designed (owner 11/27:
-- "things you cannot be at the same time are states of one machine"; machines nest — a state can hold a
-- sub-machine; arrows are cards too). #football-taxonomy Concepts tab gets a "By machine" view.
--   game_machines             a machine (top level = runs in parallel; parent_state_id = a sub-machine inside a state)
--   game_machine_states       its states (exactly one at a time), each optionally a concept card
--   game_machine_transitions  its arrows: from (NULL = any state) → to (NULL = leaves the machine), optionally a card
-- status 'engine' = the game runs it today (game_engine_terms kind machine / machine_state); 'design' = agreed, not built.
-- DB + page only; the engine is untouched.
BEGIN;
CREATE TABLE game_machines (
  id serial PRIMARY KEY, code text NOT NULL UNIQUE, title text NOT NULL,
  scope text NOT NULL DEFAULT 'player' CHECK (scope IN ('player', 'team')),
  moment text REFERENCES game_moments(code), parent_state_id integer,
  concept_id smallint REFERENCES game_concepts(id),
  status text NOT NULL CHECK (status IN ('engine', 'design')), engine_code text,
  note text NOT NULL DEFAULT '', sort_order smallint NOT NULL DEFAULT 0);
CREATE TABLE game_machine_states (
  id serial PRIMARY KEY, machine_id integer NOT NULL REFERENCES game_machines(id) ON DELETE CASCADE,
  code text NOT NULL, title text NOT NULL, concept_id smallint REFERENCES game_concepts(id),
  status text NOT NULL CHECK (status IN ('engine', 'design')), engine_code text,
  sort_order smallint NOT NULL DEFAULT 0, UNIQUE (machine_id, code));
ALTER TABLE game_machines ADD CONSTRAINT game_machines_parent_state_fk FOREIGN KEY (parent_state_id) REFERENCES game_machine_states(id) ON DELETE CASCADE;
CREATE TABLE game_machine_transitions (
  id serial PRIMARY KEY, machine_id integer NOT NULL REFERENCES game_machines(id) ON DELETE CASCADE,
  from_state_id integer REFERENCES game_machine_states(id) ON DELETE CASCADE,
  to_state_id integer REFERENCES game_machine_states(id) ON DELETE CASCADE,
  concept_id smallint REFERENCES game_concepts(id), label text NOT NULL,
  status text NOT NULL DEFAULT 'design' CHECK (status IN ('engine', 'design')), sort_order smallint NOT NULL DEFAULT 0);

-- ── The engine today: its 8 flat machines (game/src/ai/concepts/Machines.hpp), each with asleep + its states.
INSERT INTO game_machines (code, title, moment, concept_id, status, engine_code, note, sort_order)
SELECT 'engine-' || t.code, t.title, 'out_of_possession', c.id, 'engine', t.code,
       'Runs in the game today as a flat machine (Machines.hpp, wire ' || t.wire_index || ').', 100 + t.wire_index
  FROM game_engine_terms t
  LEFT JOIN game_concepts c ON c.name = CASE t.code WHEN 'marking_scheme' THEN 'marking' WHEN 'cover_shadow' THEN 'cover-shadow'
       WHEN 'pressing_distance' THEN 'pressing-distance' WHEN 'recover' THEN 'recover' WHEN 'press' THEN 'close-down'
       WHEN 'loose_ball' THEN 'nearest-decides' WHEN 'double_team' THEN 'double-team' WHEN 'cover' THEN 'cover' END
 WHERE t.kind = 'machine';
INSERT INTO game_machine_states (machine_id, code, title, status, engine_code, sort_order)
SELECT m.id, 'asleep', 'Asleep (nothing to do)', 'engine', m.engine_code || '.asleep', 0 FROM game_machines m WHERE m.status = 'engine';
INSERT INTO game_machine_states (machine_id, code, title, status, engine_code, sort_order)
SELECT m.id, split_part(t.code, '.', 2), t.title, 'engine', t.code, t.wire_index
  FROM game_engine_terms t JOIN game_machines m ON m.engine_code = t.parent WHERE t.kind = 'machine_state';

-- Engine: the team phase machine (game/src/ai/TeamPhase.hpp) and the player's job machine (ai/Players, frame STATES).
INSERT INTO game_machines (code, title, scope, status, engine_code, note, sort_order) VALUES
 ('team-phase', 'Team phase', 'team', 'engine', 'ai::Phase', 'The team''s moment of the game (TeamPhase.hpp). Transitions last physics.phase.transition_ticks after the ball changes side.', 1),
 ('player-job', 'Player job', 'player', 'engine', 'PlayerState', 'What each player is doing right now — exactly one at a time (ai/Players, frame STATES 0x4F). The design adds the out-of-possession jobs the engine does not have yet.', 2),
 ('eyes', 'Eyes', 'player', 'engine', 'concepts::Eyes', 'Where he is looking (Marking.hpp): the ball, his man, or both. Runs alongside his job.', 3);
INSERT INTO game_machine_states (machine_id, code, title, status, engine_code, sort_order)
SELECT (SELECT id FROM game_machines WHERE code = 'team-phase'), t.code, t.title, 'engine', t.code, row_number() OVER (ORDER BY t.code)
  FROM game_engine_terms t WHERE t.kind = 'phase';
INSERT INTO game_machine_states (machine_id, code, title, concept_id, status, engine_code, sort_order)
SELECT (SELECT id FROM game_machines WHERE code = 'player-job'), t.code,
       t.title || CASE t.parent WHEN 'with' THEN ' (we have it)' WHEN 'without' THEN ' (they have it)' ELSE '' END,
       c.id, 'engine', t.code, CASE t.parent WHEN 'without' THEN 10 WHEN 'keeper' THEN 40 ELSE 50 END
  FROM game_engine_terms t
  LEFT JOIN game_concepts c ON c.name = CASE t.code WHEN 'press_ball' THEN 'close-down' WHEN 'mark_man' THEN 'marking'
       WHEN 'chase_ball' THEN 'nearest-decides' WHEN 'double_team' THEN 'double-team' WHEN 'keeper' THEN 'keeper-set-position'
       WHEN 'receive' THEN 'meet-the-pass' WHEN 'support' THEN 'support' WHEN 'run_line' THEN 'runs' WHEN 'attack_box' THEN 'box-occupancy' END
 WHERE t.kind = 'state';
INSERT INTO game_machine_states (machine_id, code, title, status, engine_code, sort_order) VALUES
 ((SELECT id FROM game_machines WHERE code = 'eyes'), 'ball', 'Watching the ball', 'engine', 'eyes_ball', 1),
 ((SELECT id FROM game_machines WHERE code = 'eyes'), 'man', 'Checking his man', 'engine', 'eyes_man', 2),
 ((SELECT id FROM game_machines WHERE code = 'eyes'), 'both', 'Open, seeing both', 'engine', 'eyes_both', 3);

-- Engine sub-machines: the on-ball / keeper / hold decisions (game_engine_terms kind decision) and the marking steps.
INSERT INTO game_machines (code, title, parent_state_id, status, engine_code, note, sort_order)
SELECT 'decisions-' || s.code, 'Decisions: ' || split_part(s.title, ' (', 1), s.id, 'engine', s.code, 'What he chooses while in this job (game_engine_terms kind decision).', 0
  FROM game_machine_states s JOIN game_machines m ON m.id = s.machine_id
 WHERE m.code = 'player-job' AND s.code IN ('on_ball', 'keeper', 'hold_block');
INSERT INTO game_machine_states (machine_id, code, title, concept_id, status, engine_code, sort_order)
SELECT m.id, t.code, t.title, c.id, 'engine', t.code, t.wire_index
  FROM game_engine_terms t JOIN game_machines m ON m.code = 'decisions-' || t.parent
  LEFT JOIN game_concepts c ON c.name = CASE t.code WHEN 'shoot' THEN 'shot-selection' WHEN 'cross' THEN 'cross-delivery' WHEN 'dribble' THEN 'drive-into-space'
       WHEN 'clear' THEN 'clear-the-danger' WHEN 'in_behind' THEN 'over-top' WHEN 'keeper_pos' THEN 'keeper-set-position' WHEN 'keeper_punt' THEN 'distribute-quickly' END
 WHERE t.kind = 'decision';
INSERT INTO game_machines (code, title, parent_state_id, status, engine_code, note, sort_order)
SELECT 'marking-steps', 'Marking steps', s.id, 'engine', 'concepts::MarkStep', 'The steps of marking his man (Marking.hpp MarkStep).', 0
  FROM game_machine_states s JOIN game_machines m ON m.id = s.machine_id WHERE m.code = 'player-job' AND s.code = 'mark_man';
INSERT INTO game_machine_states (machine_id, code, title, concept_id, status, engine_code, sort_order)
SELECT (SELECT id FROM game_machines WHERE code = 'marking-steps'), v.code, v.title, c.id, 'engine', 'mark_' || v.code, v.o
  FROM (VALUES ('pick_up', 'Pick up his man', 'direct-opponent', 1), ('position', 'Position on his man', 'mark-position', 2),
               ('track_runner', 'Track the runner', 'track-the-runner', 3), ('follow_dropper', 'Follow him in', 'follow-the-dropper', 4),
               ('pass_on', 'Pass him on', 'hand-over-man', 5), ('jump_pass', 'Jump the pass to him', 'jump-the-pass', 6),
               ('no_turn', 'Don''t let him turn', 'defend-your-man', 7), ('contain', 'Contain him', 'engage-or-contain', 8)) v(code, title, cname, o)
  LEFT JOIN game_concepts c ON c.name = v.cname;

UPDATE game_machines SET note = note || ' Design: becomes a state of Player job (one job at a time).'
 WHERE code IN ('engine-press', 'engine-recover', 'engine-loose_ball', 'engine-cover', 'engine-double_team');
UPDATE game_machines SET note = note || ' Design: the Angle machine — runs alongside every defending job, not only the press.'
 WHERE code = 'engine-cover_shadow';

-- ── Design (11/27): the out-of-possession jobs the engine lacks, Press as nested machines, the arrows.
-- 5 new cards the arrival / exit phases need.
UPDATE game_principles SET title = '5 · Arrive: distance and body' WHERE code = 'op-pb-body';
UPDATE game_principles SET title = '6 · Win it, or let him go' WHERE code = 'op-pb-win';
INSERT INTO game_concepts (id, name, title, family, moment, status, kind, principle_id, definition, cue_answer, lacking)
SELECT (SELECT max(id) FROM game_concepts) + v.o, v.name, v.title, 'individual', 'out_of_possession', 'queued', 'behaviour', p.id, v.def, v.cue, v.lacking
  FROM (VALUES
  (1, 'straight-fast', 'Straight and fast', 'op-pb-approach',
   'No shadow to keep and no time to waste (a bad touch, a loose ball, he is facing his own goal): take the straight line and get there now.',
   'Bad touch or he is turned: straight at him, now.', 'Curves a run when he should just get there, and the chance is gone.'),
  (2, 'stop-short', 'Stop short', 'op-pb-body',
   'Arrive a step away from him — close enough to touch the ball if he shows it, far enough that one touch cannot take him past you.',
   'Last step: stop just out of his reach, then wait.', 'Runs right up to him and is beaten with one touch.'),
  (3, 'follow-through', 'Follow through into the tackle', 'op-pb-body',
   'When the ball is exposed as you arrive (a heavy touch, a bouncing ball, he is turned), arrive into the tackle in one movement instead of stopping first.',
   'Ball away from his feet as you get there: go straight through to it.', 'Stops and sets when the ball was there to win, and he recovers it.'),
  (4, 'step-to-shot', 'Step to the shot', 'op-pb-body',
   'He is setting to shoot: your last step puts your body in the line between the ball and the goal, side-on, to block it.',
   'He is about to shoot: step into the line, side-on, block it.', 'Arrives beside him or turns away, and the shot goes through.'),
  (5, 'get-back', 'Released: get back', 'op-pb-win',
   'The press is done or passed on (the ball has gone past you, or someone else has taken him): sprint back to your post or line instead of standing where the press ended.',
   'Press is over: back to your spot, now.', 'Stays where the press ended and the shape has a hole.')
  ) v(o, name, title, pcode, def, cue, lacking) JOIN game_principles p ON p.code = v.pcode;
INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT a.id, b.id, 'refines' FROM (VALUES ('straight-fast','close-down'), ('stop-short','close-down'), ('follow-through','tackle-timing'),
       ('step-to-shot','block-shot-line'), ('get-back','press-broken-reset')) v(a, b)
  JOIN game_concepts a ON a.name = v.a JOIN game_concepts b ON b.name = v.b ON CONFLICT DO NOTHING;
INSERT INTO game_concept_measures (concept, measure) VALUES ('straight-fast','press'), ('stop-short','duel'), ('follow-through','duel'), ('step-to-shot','duel'), ('get-back','team_shape') ON CONFLICT DO NOTHING;

-- Player job: the designed out-of-possession states.
INSERT INTO game_machine_states (machine_id, code, title, concept_id, status, sort_order)
SELECT (SELECT id FROM game_machines WHERE code = 'player-job'), v.code, v.title, c.id, 'design', v.o
  FROM (VALUES ('duel', 'Duel 1v1 (they have it)', 'win-duel', 11), ('intercept', 'Intercept: the ball is travelling (they have it)', 'intercept', 12),
               ('cover', 'Cover the presser (they have it)', 'cover', 13), ('recover', 'Recover goal-side (they have it)', 'recover', 14),
               ('screen', 'Screen in front of the back line (they have it)', 'screen-back-four', 15), ('sweep', 'Sweep behind the line (they have it)', 'deep-sweeper', 16)) v(code, title, cname, o)
  LEFT JOIN game_concepts c ON c.name = v.cname;

-- Press the ball → phases → ways; Duel → its states.
INSERT INTO game_machines (code, title, parent_state_id, status, note, sort_order)
SELECT 'press-phases', 'Press the ball: phases', s.id, 'design', 'Approach, then arrival; then he hands off to Duel.', 0
  FROM game_machine_states s JOIN game_machines m ON m.id = s.machine_id WHERE m.code = 'player-job' AND s.code = 'press_ball';
INSERT INTO game_machine_states (machine_id, code, title, status, sort_order) VALUES
 ((SELECT id FROM game_machines WHERE code = 'press-phases'), 'approach', 'Approach', 'design', 1),
 ((SELECT id FROM game_machines WHERE code = 'press-phases'), 'arrival', 'Arrival', 'design', 2);
INSERT INTO game_machines (code, title, parent_state_id, status, note, sort_order)
SELECT 'press-' || s.code, s.title || ': ways', s.id, 'design', CASE s.code WHEN 'approach' THEN 'How he gets there.' ELSE 'How he finishes the run.' END, 0
  FROM game_machine_states s JOIN game_machines m ON m.id = s.machine_id WHERE m.code = 'press-phases';
INSERT INTO game_machines (code, title, parent_state_id, status, note, sort_order)
SELECT 'duel-ways', 'Duel: ways', s.id, 'design', 'What he does once he is on the man with the ball.', 0
  FROM game_machine_states s JOIN game_machines m ON m.id = s.machine_id WHERE m.code = 'player-job' AND s.code = 'duel';
INSERT INTO game_machine_states (machine_id, code, title, concept_id, status, sort_order)
SELECT m.id, v.code, c.title, c.id, 'design', v.o
  FROM (VALUES ('press-approach', 'straight', 'straight-fast', 1), ('press-approach', 'sprint-slow', 'slow-down-approach', 2),
               ('press-approach', 'curved', 'cover-shadow', 3), ('press-approach', 'blind-side', 'blind-side-press', 4),
               ('press-arrival', 'stop-short', 'stop-short', 1), ('press-arrival', 'side-on', 'side-on-jockey', 2),
               ('press-arrival', 'follow-through', 'follow-through', 3), ('press-arrival', 'step-to-shot', 'step-to-shot', 4),
               ('press-arrival', 'with-the-ball', 'jump-the-pass', 5),
               ('duel-ways', 'contain-or-step', 'engage-or-contain', 1), ('duel-ways', 'on-feet', 'restraint', 2),
               ('duel-ways', 'tackle', 'tackle-timing', 3), ('duel-ways', 'shoulder', 'shoulder-charge', 4),
               ('duel-ways', 'run-with-him', 'drop-step', 5), ('duel-ways', 'block-path', 'block-path-to-goal', 6)) v(mcode, code, cname, o)
  JOIN game_machines m ON m.code = v.mcode JOIN game_concepts c ON c.name = v.cname;

-- The arrows (design). from NULL = from any job; the card is what a player has to know to take it.
INSERT INTO game_machine_transitions (machine_id, from_state_id, to_state_id, concept_id, label, sort_order)
SELECT m.id, f.id, t.id, c.id, v.label, v.o
  FROM (VALUES
   ('player-job', NULL, 'press_ball', 'free-man-jumps', 'their man receives and I am the free man', 1),
   ('player-job', 'screen', 'press_ball', 'know-when-not-to-jump', 'blocked: the spare and the screen hold their posts', 2),
   ('player-job', NULL, 'press_ball', 'press-the-bad-touch', 'trigger: a bad touch', 3),
   ('player-job', NULL, 'press_ball', 'backpass-step-up', 'trigger: a back pass', 4),
   ('player-job', NULL, 'press_ball', 'lateral-pass-trigger', 'trigger: a square pass', 5),
   ('player-job', NULL, 'press_ball', 'hurry-the-keeper', 'trigger: their keeper has it', 6),
   ('player-job', 'intercept', 'press_ball', NULL, 'did not get there first: press the receiver', 7),
   ('player-job', 'press_ball', 'duel', NULL, 'within reach: the arrival is done', 8),
   ('player-job', 'mark_man', 'duel', NULL, 'he dribbles at me', 9),
   ('player-job', 'duel', 'press_ball', 'double-press', 'beaten: turn and press again', 10),
   ('player-job', 'press_ball', 'press_ball', 'press-through', 'he passed: press the next man', 11),
   ('player-job', 'press_ball', 'recover', 'get-back', 'released: get back', 12),
   ('player-job', 'press_ball', 'recover', 'press-broken-reset', 'press broken: drop and reset', 13),
   ('press-phases', 'approach', 'arrival', NULL, 'close enough: the last few metres', 14)
  ) v(mcode, fcode, tcode, cname, label, o)
  JOIN game_machines m ON m.code = v.mcode
  LEFT JOIN game_machine_states f ON f.machine_id = m.id AND f.code = v.fcode
  LEFT JOIN game_machine_states t ON t.machine_id = m.id AND t.code = v.tcode
  LEFT JOIN game_concepts c ON c.name = v.cname;

UPDATE game_machine_states s SET sort_order = v.o FROM (VALUES ('in_possession',1),('attacking_transition',2),('defending_block',3),('defensive_transition',4),('our_set_piece',5),('their_set_piece',6)) v(code,o) WHERE s.code = v.code AND s.machine_id = (SELECT id FROM game_machines WHERE code = 'team-phase');  -- TeamPhase.hpp order

-- Page copy (#football-taxonomy Concepts tab, "By machine" view).
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public) VALUES
 ('Football', 'Taxonomy of Football — view: by section', 'taxonomy', 'view_sections', '📂 By section', 760, true, false),
 ('Football', 'Taxonomy of Football — view: by machine', 'taxonomy', 'view_machines', '🔀 By machine', 761, true, false),
 ('Football', 'Taxonomy of Football — machine view intro', 'taxonomy', 'm_intro', 'Every state machine the game has, and the ones designed. A player is in exactly one state of each machine; the top-level machines run side by side; a state can hold its own smaller machine. Arrows are what he must know to move. ⚙️ = the game runs it today · ✏️ = designed, not built.', 762, true, false),
 ('Football', 'Taxonomy of Football — machine status: engine', 'taxonomy', 'm_engine', '⚙️ in the game', 763, true, false),
 ('Football', 'Taxonomy of Football — machine status: design', 'taxonomy', 'm_design', '✏️ designed', 764, true, false),
 ('Football', 'Taxonomy of Football — machine arrows heading', 'taxonomy', 'm_arrows', 'Arrows', 765, true, false),
 ('Football', 'Taxonomy of Football — arrow from any state', 'taxonomy', 'm_any', 'any', 766, true, false),
 ('Football', 'Taxonomy of Football — arrow leaving the machine', 'taxonomy', 'm_leaves', 'leaves', 767, true, false),
 ('Football', 'Taxonomy of Football — cards not in any machine ({n})', 'taxonomy', 'm_not_placed', 'Cards not in a machine yet ({n})', 768, true, false),
 ('Football', 'Taxonomy of Football — machines per scope: team', 'taxonomy', 'm_scope_team', 'Team', 769, true, false),
 ('Football', 'Taxonomy of Football — machines per scope: player', 'taxonomy', 'm_scope_player', 'Player', 770, true, false);
COMMIT;
