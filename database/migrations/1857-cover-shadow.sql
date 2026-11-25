-- 1857 (2026-11-24): COVER SHADOW built whole — the concept after pressing distance.
--
-- The catalogue's cue: "Pressing their centre back: run at him along the line to his nearest
-- receiver, so that pass is blocked by your body." Nothing in the engine knew it: the presser
-- stands on the carrier's line to our goal, whoever is open beside him.
--
-- game/src/ai/concepts/CoverShadow:
--   recognise   every outfielder of the side without the ball: which opponents stand in his
--               shadow — behind him as seen from the ball, within what his body and a stride
--               either side stop (1.2 m). And for whoever closes the ball down: the pass to
--               block — the carrier's nearest mate who is level with him or nearer our goal.
--   choose      physics.shadow.press (0 … 1). NO ROW = 0: read only, the sim unchanged.
--   execute     the presser's stand-off spot moves off the line to our goal onto the line to
--               that receiver, by the dial's share.
-- The match sends the shadows with the brain feed (frame SHADOW). 178 → 181 behaviours.

INSERT INTO game_engine_acts (code, concept_id, note)
SELECT 'press_shadow', (SELECT id FROM game_concepts WHERE name = 'cover-shadow'),
       'PressBall with his stand-off spot on the line from the carrier to the receiver he hides (ai/concepts/CoverShadow). Only with physics.shadow.press above 0 — no side in the sim has it yet.'
 WHERE NOT EXISTS (SELECT 1 FROM game_engine_acts WHERE code = 'press_shadow');

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, v.file, 1, 'cover shadow 11/24', 'individual', v.what, 'concept',
       (SELECT id FROM game_concepts WHERE name = 'cover-shadow'), v.other, NULL, 'high', v.is_read, v.in_sim
  FROM (VALUES
    ('cs_hidden_behind_him', 'game/src/ai/concepts/CoverShadow.cpp', 'shadow-second-man, deter', true, true,
     'Reads who is in his shadow: an opponent further from the ball than he is, with him standing within 1.2 m of the straight line from the ball to that man. A ground pass to that man goes through him.'),
    ('cs_pick_nearest_receiver', 'game/src/ai/concepts/CoverShadow.cpp', 'winger-press-angle, nine-starts-press', true, true,
     'Reads which pass the man closing the ball down should block: the nearest team-mate of the man on the ball (within 30 m) who is level with him or nearer our goal. A pass back toward their own goal is not worth hiding.'),
    ('cs_press_along_the_lane', 'game/src/ai/DefendingBlock.cpp', 'close-down, jockey-angle', false, false,
     'The presser''s stand-off spot moves off the carrier''s line to our goal onto his line to the receiver being hidden, the same distance from the carrier — so he arrives along the pass he blocks. How far it moves is a dial (physics.shadow.press); with no row it is 0 and he stands goal-side as fitted.')
  ) AS v(code, file, other, is_read, in_sim, what)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT c.id, o.id, 'refines' FROM game_concepts c, game_concepts o
 WHERE c.name = 'cover-shadow' AND o.name = 'close-down'
   AND NOT EXISTS (SELECT 1 FROM game_concept_links l WHERE l.concept_id = c.id AND l.other_id = o.id);

UPDATE game_concepts SET definition =
  'Standing so that one defender blocks a pass to a man who is not his own. He keeps his own man in pressing distance, and positions himself on the straight line from the ball to another opponent — that opponent is now in his shadow and cannot be found along the ground. It is the cover shadow used by a player who is NOT pressing the ball. Not this: leaving your own man to do it; if your man gets free the shadow was not worth it.'
 WHERE name = 'shadow-second-man' AND coalesce(definition, '') = '';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — cover shadow: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('tag: a man in his shadow', 'shadow_hidden', 'IN HIS SHADOW', 300),
    ('tag: the pass left open', 'shadow_open', 'OPEN — the pass to block', 301),
    ('caption: who he hides ({num}, {player}, {list})', 'cap_shadow', '#{num} {player} closes the ball down — hidden behind him: {list}', 302),
    ('caption: the pass he leaves ({num}, {player}, {man})', 'cap_shadow_open', '#{num} {player} closes the ball down — nobody is in his shadow · the pass to #{man} is open', 303),
    ('caption: nothing to hide ({num}, {player})', 'cap_shadow_none', '#{num} {player} closes the ball down — nobody is in his shadow', 304),
    ('legend', 'shadow_legend',
     'Gold ring = the man closing the ball down · red ring = the man on the ball · the dark wedge = his shadow: a pass along the ground into it goes through him · white dashed line = the nearest pass, left open', 305)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
