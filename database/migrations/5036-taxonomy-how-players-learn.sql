-- 5036 (2026-11-27): #football-taxonomy 🧭 How players learn tab — the design agreed with the owner today
-- (cards = understanding; one rule for machines; my-job machine; inside Press; states/memory/relation;
-- plan = numbers; scripts + role priors; rule ladder; knowledge + ability scores). Copy only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public) VALUES
 ('Football', 'Taxonomy of Football — how players learn: tab: how players learn', 'taxonomy', 'tab_learning', '🧭 How players learn', 700, true, false),
 ('Football', 'Taxonomy of Football — how players learn: intro', 'taxonomy', 'lm_intro', 'The design agreed with the owner on 2026-11-27 for out-of-possession concepts, starting with pressing the ball. It is a plan: the database tables for machines, scripts and ladders, and the engine (C++), come after sign-off. The concept cards on the Concepts tab are the vocabulary it uses.', 701, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 1 heading', 'taxonomy', 'lm_s1_h', '1 · A card is a piece of understanding', 702, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 1 body', 'taxonomy', 'lm_s1_b', 'Every concept card is something a player either has or lacks. It does three jobs:
• track ability — each player is rated on each card;
• track learning — drills and sessions point at cards, so you can see what was taught and whether it stuck;
• a real sim — a sim player only does what his cards allow; when he lacks one he plays its ''lacking it looks like'' instead, so his mistakes come from missing knowledge, not random noise.', 703, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 2 heading', 'taxonomy', 'lm_s2_h', '2 · One rule for the machines', 704, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 2 body', 'taxonomy', 'lm_s2_b', 'Things a player cannot be doing at the same time are states of ONE machine — he is in exactly one of them.
Things that can happen at the same time are SEPARATE machines running in parallel.
The same rule applies at every level, so machines nest: a state can hold its own smaller machine (a sub-machine).', 705, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 3 heading', 'taxonomy', 'lm_s3_h', '3 · Out of possession: my job right now', 706, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 3 body', 'taxonomy', 'lm_s3_b', 'One machine, exactly one state at a time:
Press the ball · Duel (1v1) · Intercept (the ball is travelling) · Loose ball · Cover · Mark (man / zone / free / track) · Recover · Screen · Sweep

Running in parallel with it:
Eyes (scanning) · Talk (calls) · Angle / cover shadow (what passes I block) · the team''s line and block · the marking scheme (team)

A job gives the player his target; parallel machines BEND it (edge toward the ball, curve onto a lane) without changing the job. Half-pressing is ''Hold zone + a bend'', not a new state.', 707, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 4 heading', 'taxonomy', 'lm_s4_h', '4 · Inside Press the ball', 708, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 4 body', 'taxonomy', 'lm_s4_b', 'PRESS THE BALL
  Approach — straight & fast · sprint then slow · curved with a shadow · blind side
  → Arrival — stop short · side-on · follow through into the tackle · step to the shot · arrive with the ball
  → hands off to DUEL (contain · step in · tackle · shoulder · run with him · block the path to goal)

The arrows are cards too — most coaching corrections are about them:
  in:  who jumps (free man jumps, markers stay · know when you may not jump), triggers (bad touch, back pass, square pass)
  out: beaten → turn and press again · he passed → press the next man · released → get back · press broken → drop and reset
Two players can be in Press at once (first and second presser on a double-up).', 709, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 5 heading', 'taxonomy', 'lm_s5_h', '5 · A machine: states = how, memory = who, relation = why', 710, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 5 body', 'taxonomy', 'lm_s5_b', 'Cover shadow, for example:
  states: asleep · hiding (someone is behind you from where you stand) · shading (moving to keep him behind you) · adjusting (switching who you hide) · lost (he slipped out — call or chain shift)
  memory: the man (or men) in the shadow — their #6, #4 …
  relation: why him — my own man · the man behind me (forward pass) · the man beside him (the switch) · the man back (the reset) · whoever the coach named', 711, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 6 heading', 'taxonomy', 'lm_s6_h', '6 · The coach''s plan is numbers, not cards', 712, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 6 body', 'taxonomy', 'lm_s6_b', 'Who presses whom, whom he shadows, which side he comes from, whether he presses from his mark or as the free man, and who takes the man he leaves — set per situation and per position in the 🎯 tactic plan (tactic_jobs: press = target B, shadow = targets). Named presses coaches use (Hunting 9, Lock the door) are saved presets of these numbers.', 713, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 7 heading', 'taxonomy', 'lm_s7_h', '7 · What people learn: scripts', 714, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 7 body', 'taxonomy', 'lm_s7_b', 'Human learning is specific: a 9 who hides their 6 well has not learned to hide the inside mid as a winger. So scores live on SCRIPTS — concept × my role × target role:
  cover shadow · as the 9 · hide their 6
  cover shadow · as a winger · hide the inside mid (pressing their full-back)
  cover shadow · as an 8 out of a double pivot · hide their 6
Only real coached combinations get a script (about 70–80 for pressing), never one per formation pair.

ROLE PRIORS: in general a winger is good at his own position''s scripts and a 9 at his, because they do them every week. Priors are seeded from the books'' role rows and adjusted by the coach; a player''s own evidence always wins over the prior, and he gets no credit for another role''s script until he shows it.', 715, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 8 heading', 'taxonomy', 'lm_s8_h', '8 · Reading it on the fly: the rule ladder', 716, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 8 body', 'taxonomy', 'lm_s8_b', 'The general rules are abilities too — more advanced ones. They are how a smart player handles a spot he has never drilled. For cover shadow:
  0 · no shadow — runs straight at the ball
  1 · shadow the closest man
  2 · shadow my current mark (the man I left)
  3 · shadow the closest open man
  4 · shadow the most dangerous pass
  5 · shadow what the plan or trap wants — steer him into our trap
Rules lean on scanning, anticipation and decision speed; scripts lean on reps.', 717, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 9 heading', 'taxonomy', 'lm_s9_h', '9 · Scores, and what the sim does', 718, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 9 body', 'taxonomy', 'lm_s9_b', 'Each script and each rung carries two scores: KNOWLEDGE (does he know what to do here?) and ABILITY (can he do it under pressure?).
In a given spot the player uses the better of his script for that spot and his rule rung, applied fresh.
Example: a winger in his normal spot uses his strong script. Moved to 9 he has no script there and falls back on his rung — rung 4 and he is fine (the game-intelligent utility player); rung 1 and he hides someone harmless and their 6 gets the ball.', 719, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 10 heading', 'taxonomy', 'lm_s10_h', '10 · Two ways to learn', 720, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 10 body', 'taxonomy', 'lm_s10_b', 'Drills and repetition build scripts. Varied, game-like practice and film build rungs. The coach can see which one a player is missing. The same pair — scripts for your role plus a ladder for reading it fresh — probably holds for most concepts (marking: whom to pick up; covering: where to stand).', 721, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 11 heading', 'taxonomy', 'lm_s11_h', '11 · Not built yet', 722, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 11 body', 'taxonomy', 'lm_s11_b', 'Database: the machine and state tables (states, sub-machines, transitions), scripts with role priors, rule ladders, and per-player knowledge and ability scores. Then the pages that show them. Then the engine: its flat machines (Press today is just asleep → closing) become these nested ones, one at a time, held to the goldens.', 723, true, false);
COMMIT;
