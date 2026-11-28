-- 5037 (2026-11-27): 🧭 How players learn — the AI architecture sections (state machines + utility scoring +
-- spatial maps + perception + team coordinator, fitted to data), the per-tick loop, and 'Not built yet' moved to 13.
BEGIN;
UPDATE message_templates SET body = '11 · The AI: state machines plus scoring' WHERE kind = 'taxonomy' AND tier = 'lm_s11_h';
UPDATE message_templates SET body = 'State machines are the backbone, not the whole AI. Each technique does the part it is best at:
• Hierarchical state machines — structure: what am I doing right now, commitment (no flickering between jobs), phases. The states and arrows ARE the cards, so it is explainable and teachable.
• Utility scoring — choosing: which arrow to take, which option, which man to shadow, scored from the situation × the player''s knowledge and ability for that script or rung. A card he lacks is an option he never sees or misjudges.
• Spatial maps (pitch control, danger, open space) — seeing the field: who is free, which pass is dangerous. ''Most dangerous pass'' and ''closest open man'' need them.
• Perception (the Eyes machine) — he can only score what he has seen; a missed shoulder check means the runner is not in his picture.
• A team coordinator — who jumps, traps, chain shifts: decisions one player cannot make alone.
• Models fitted to real data (DFL tracking, StatsBomb) — the numbers: pass success, reaction times, distances. Pro is the bound; semi-pro is worse.
Not used for behaviour: reinforcement learning (opaque, finds odd tricks, breaks the card-to-mistake link); behaviour trees and planners (they would work, but fit commitment and the cards less well).' WHERE kind = 'taxonomy' AND tier = 'lm_s11_b';
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public) VALUES
 ('Football', 'Taxonomy of Football — how players learn: 12 heading', 'taxonomy', 'lm_s12_h', '12 · Every tick, for each player', 730, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 12 body', 'taxonomy', 'lm_s12_b', '1 SEE — Eyes updates what he knows.
2 READ — maps and reads from what he saw, not the true picture.
3 TEAM — the coordinator assigns who jumps, who covers, the trap.
4 CHOOSE — scoring picks the arrow out of his state, using his scripts and rungs and the plan''s numbers.
5 ACT — the machine moves (with commitment); its state gives the target; parallel machines bend it.
6 EXECUTE — technique and physical ability decide how well it comes off.

Three kinds of realistic mistake, the way coaches diagnose real players: DIDN''T SEE (eyes) · DIDN''T KNOW (a missing card or low knowledge → the wrong choice) · COULDN''T DO IT (ability and technique → poor execution).
Lineage: Buckland''s Programming Game AI by Example (state machines for soccer agents); RoboCup sim teams such as HELIOS (role assignment plus scored action choice). The cards-as-learnable-knowledge layer on top is ours.', 731, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 13 heading', 'taxonomy', 'lm_s13_h', '13 · Not built yet', 732, true, false),
 ('Football', 'Taxonomy of Football — how players learn: 13 body', 'taxonomy', 'lm_s13_b', 'Database: the machine and state tables (states, sub-machines, transitions), scripts with role priors, rule ladders, and per-player knowledge and ability scores. Then the pages that show them (a ''By machine'' view of the cards). Then the engine: its flat machines (Press today is just asleep → closing) become these nested ones, with scoring on the arrows, one at a time, held to the goldens.', 733, true, false);
COMMIT;
