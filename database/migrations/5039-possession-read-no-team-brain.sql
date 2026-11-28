-- 5039 (2026-11-27): no team brain (owner 11/27: "a whole team does not have a brain … let the players in
-- their mind have a concept of our ball, their ball, unknown loose … percent chance"). Each player gets a designed
-- POSSESSION READ machine; the engine's Team phase stays listed (it runs today) but as a summary only, replaced by the
-- per-player reads in the design. How players learn: team coordinator → plan + rules + calls held per player.
BEGIN;
UPDATE game_machines SET title = 'Team phase (summary only)', note = 'The engine runs this today as one team-level machine (TeamPhase.hpp). Design: a team has no brain — this becomes only a summary of the players'' own Possession reads (e.g. 8 of 11 think it is ours), for analysis and the viewer. Nobody obeys it.' WHERE code = 'team-phase';
INSERT INTO game_machines (code, title, scope, moment, status, note, sort_order) VALUES
 ('possession-read', 'Possession read (whose ball he thinks it is)', 'player', NULL, 'design',
  'Every player''''s own read, from what he has seen or heard — not the truth. Memory: how sure he is (the chance it is ours). Fed by Eyes, his reaction and reading (anticipation, concentration), the cards he knows, and calls. Different players switch at different times; that is the point.', 1);
INSERT INTO game_machine_states (machine_id, code, title, concept_id, status, sort_order)
SELECT (SELECT id FROM game_machines WHERE code = 'possession-read'), v.code, v.title, c.id, 'design', v.o
  FROM (VALUES ('ours', 'Ours: settled', NULL, 1), ('ours-won', 'Ours: we just won it', 'counter-or-keep', 2),
               ('theirs', 'Theirs: settled', NULL, 3), ('theirs-won', 'Theirs: they just won it', 'zero-pause-switch', 4),
               ('loose-ours', 'Loose: likely ours', NULL, 5), ('loose-5050', 'Loose: 50/50', 'nearest-decides', 6),
               ('loose-theirs', 'Loose: likely theirs', NULL, 7), ('dead-ours', 'Dead ball: our restart', 'quick-restart', 8),
               ('dead-theirs', 'Dead ball: their restart', NULL, 9)) v(code, title, cname, o)
  LEFT JOIN game_concepts c ON c.name = v.cname;
INSERT INTO game_machine_transitions (machine_id, from_state_id, to_state_id, concept_id, label, sort_order)
SELECT m.id, f.id, t.id, c.id, v.label, v.o
  FROM (VALUES ('ours', 'theirs-won', 'zero-pause-switch', 'I see us lose it, or hear ''away!''', 1),
               ('theirs', 'ours-won', 'anticipate-regain', 'I see us win it (or I saw it coming)', 2),
               (NULL, 'loose-5050', NULL, 'nobody has it: the ball is loose', 3),
               ('loose-5050', 'loose-ours', NULL, 'a teammate is getting there first', 4),
               ('loose-5050', 'loose-theirs', NULL, 'one of theirs is getting there first', 5),
               ('ours-won', 'ours', NULL, 'a few seconds pass with it', 6),
               ('theirs-won', 'theirs', NULL, 'a few seconds pass with it: they are set', 7),
               (NULL, 'dead-ours', NULL, 'the referee gives it to us', 8),
               (NULL, 'dead-theirs', NULL, 'the referee gives it to them', 9)) v(fcode, tcode, cname, label, o)
  JOIN game_machines m ON m.code = 'possession-read'
  LEFT JOIN game_machine_states f ON f.machine_id = m.id AND f.code = v.fcode
  LEFT JOIN game_machine_states t ON t.machine_id = m.id AND t.code = v.tcode
  LEFT JOIN game_concepts c ON c.name = v.cname;
UPDATE message_templates SET body = 'Team — summaries only (a team has no brain)' WHERE kind = 'taxonomy' AND tier = 'm_scope_team';
UPDATE message_templates SET body = 'One machine, exactly one state at a time:
Press the ball · Duel (1v1) · Intercept (the ball is travelling) · Loose ball · Cover · Mark (man / zone / free / track) · Recover · Screen · Sweep

Running in parallel with it:
Possession read (whose ball he THINKS it is) · Eyes (scanning) · Talk (calls) · Angle / cover shadow (what passes I block)

A job gives the player his target; parallel machines BEND it (edge toward the ball, curve onto a lane) without changing the job. Half-pressing is ''Hold zone + a bend'', not a new state.

POSSESSION READ — there is no team brain. Each player has his own read: ours (settled / just won) · theirs (settled / just won) · loose (likely ours / 50-50 / likely theirs) · dead ball (our / their restart), with how sure he is. It changes only when he sees it, works it out, or hears a call. Players reach the conclusion at different times — that is a feature: the one still thinking ''ours'' a second after we lost it is the gap the counter goes through.' WHERE kind = 'taxonomy' AND tier = 'lm_s3_b';
UPDATE message_templates SET body = 'State machines are the backbone, not the whole AI. Each technique does the part it is best at:
• Hierarchical state machines — structure: what am I doing right now, commitment (no flickering between jobs), phases. The states and arrows ARE the cards, so it is explainable and teachable.
• Utility scoring — choosing: which arrow to take, which option, which man to shadow, scored from the situation × the player''s knowledge and ability for that script or rung. A card he lacks is an option he never sees or misjudges.
• Spatial maps (pitch control, danger, open space) — seeing the field: who is free, which pass is dangerous. ''Most dangerous pass'' and ''closest open man'' need them.
• Perception (the Eyes machine and the Possession read) — he can only score what he has seen; a missed shoulder check means the runner is not in his picture; a missed turnover means he is still playing ''ours''.
• No team brain. Teamwork comes from three things every player holds himself: the PLAN he has learned (the coach''s numbers), the RULES he knows (free man jumps, markers stay; step only when covered), and the CALLS he hears (''away!'', ''squeeze!'', ''I''ve got him!''). When they fail you get real errors: two go or nobody goes; one defender steps while the others drop.
• Models fitted to real data (DFL tracking, StatsBomb) — the numbers: pass success, reaction times after a turnover, distances. Pro is the bound; semi-pro is worse.
Not used for behaviour: reinforcement learning (opaque, finds odd tricks, breaks the card-to-mistake link); behaviour trees and planners (they would work, but fit commitment and the cards less well).' WHERE kind = 'taxonomy' AND tier = 'lm_s11_b';
UPDATE message_templates SET body = '1 SEE — Eyes updates what he knows; his Possession read changes only from what he saw or heard.
2 READ — maps and reads from what he saw, not the true picture.
3 SHARE — the plan he learned, the rules he knows, the calls he hears. No team brain decides for him.
4 CHOOSE — scoring picks the arrow out of his state, using his scripts and rungs and the plan''s numbers.
5 ACT — the machine moves (with commitment); its state gives the target; parallel machines bend it.
6 EXECUTE — technique and physical ability decide how well it comes off.

Three kinds of realistic mistake, the way coaches diagnose real players: DIDN''T SEE (eyes, a late possession read) · DIDN''T KNOW (a missing card or low knowledge → the wrong choice) · COULDN''T DO IT (ability and technique → poor execution).
Lineage: Buckland''s Programming Game AI by Example (state machines for soccer agents); RoboCup sim teams such as HELIOS (role assignment plus scored action choice). The cards-as-learnable-knowledge layer, and reading possession per player, are ours.' WHERE kind = 'taxonomy' AND tier = 'lm_s12_b';
COMMIT;
