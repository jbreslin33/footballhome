-- 5034 (2026-11-27): concepts revisit, out of possession — the owner's review round. Our own audit plus two
-- outside research passes (coaching frameworks: FA England DNA, KNVB, US Soccer, FIFA Talent Coach, RFEF, Vitor
-- Pereira; the pro game: Spielverlagerung, Breaking the Lines, UEFA, FIFA CWC 2025, StatsBomb, Wyscout). DB only:
-- every new concept is queued; nothing reaches the engine (C++) until the owner signs the list off.
--   * id rule: ids above 254 may exist but may not be wired (the engine sends a concept id as one byte)
--   * 5 principles: Cover and balance; Press as a team split into Triggers / Traps / Press shape; The back line
--     split from Compact block
--   * moves, 6 renames, 3 links; 24 new concepts with their cited sources and measure
--   * 5 new style dimensions (press direction, rest defence, back line, set-piece marking, defensive rhythm);
--     richer measures on pressing / after loss / block height
--   * 8 book patterns whose reader proposed one of the new concepts are re-pointed to it
BEGIN;
ALTER TABLE game_concepts DROP CONSTRAINT game_concepts_id_check;
ALTER TABLE game_concepts ADD CONSTRAINT game_concepts_id_check CHECK (id >= 0 AND (id <= 254 OR status <> 'wired'));

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('web-fa-dna-oop', 'federation', 'The FA — England DNA: how we play out of possession', 'https://www.thefa.com/bootroom/resources/england-dna/how-we-play/out-of-possession', false),
  ('web-fa-defend-transition', 'federation', 'The FA — How to defend like England: transition', 'https://www.thefa.com/bootroom/resources/coaching/how-to-defend-like-england-transition', false),
  ('web-fa-defend-roles', 'federation', 'The FA — How to defend like England: roles and responsibilities', 'https://www.thefa.com/bootroom/resources/coaching/how-to-defend-like-england-roles-and-responsibilities', false),
  ('web-fa-defend-space-behind', 'federation', 'The FA — How to defend like England: space in behind', 'https://www.thefa.com/bootroom/resources/coaching/how-to-defend-like-england-space-in-behind', false),
  ('web-fa-defend-overloads', 'federation', 'The FA — How to defend like England: overloads', 'https://www.thefa.com/bootroom/resources/coaching/how-to-defend-like-england-overloads', false),
  ('web-fifa-zonal-progressive', 'federation', 'FIFA Talent Coach — zonal defending: from principles to practice', 'https://www.fifatrainingcentre.com/en/practice/talent-coach-programme/zonal-defending/from-principles-to-practice-using-a-progressive-methodology.php', false),
  ('web-fifa-cwc25-corners', 'federation', 'FIFA Training Centre — Club World Cup 2025: defending corner strategies', 'https://www.fifatrainingcentre.com/en/game/tournaments/fcwc/2025/team-analyses/set-plays-defending-corner-strategies.php', false),
  ('web-fifa-efi-line-height', 'federation', 'FIFA EFI metrics — defensive line height and team length', 'https://www.fifatrainingcentre.com/en/fwc2022/efi-metrics/efi-metric--defensive-line-height-and-team-length.php', false),
  ('web-rfef-principles-dialnet', 'analysis', 'RFEF defensive principles table (as reproduced in Dialnet article 3929974)', 'https://dialnet.unirioja.es/descarga/articulo/3929974.pdf', false),
  ('web-pereira-defensive-org', 'coach', 'Vítor Pereira — defensive organisation (slides)', 'https://www.slideshare.net/slideshow/vitor-pereira-defensive-organization/30774512', false),
  ('web-sv-counterpressing', 'analysis', 'Spielverlagerung — counter-pressing (ball, access, passing-lane, space)', 'https://spielverlagerung.com/?p=202', false),
  ('web-sv-rest-defence', 'analysis', 'Spielverlagerung — tactical theory: the various forms of rest defence', 'https://spielverlagerung.com/2021/07/05/tactical-theory-the-various-forms-of-rest-defence/', false),
  ('web-sv-liverpool-pressing', 'analysis', 'Spielverlagerung — Liverpool''s pressing system (2019)', 'https://spielverlagerung.com/2019/05/09/liverpools-pressing-system/', false),
  ('web-sv-4141-traps', 'analysis', 'Spielverlagerung — examples of pressing traps in the 4-1-4-1', 'https://spielverlagerung.com/2014/07/06/examples-of-pressing-traps-in-the-4-1-4-1/', false),
  ('web-btl-inter-532', 'analysis', 'Breaking the Lines — Inter Milan and defending in a 5-3-2', 'https://breakingthelines.com/@btl/tactical-analysis-inter-milan-and-defending-in-a-5-3-2', false),
  ('web-uefa-setting-the-press', 'federation', 'UEFA — Champions League performance insights: setting the press', 'https://www.uefa.com/uefachampionsleague/news/028a-1a1bf5c2d303-4a5106d81f09-1000--champions-league-performance-insights-setting-the-press', false),
  ('web-cv-rest-defence', 'analysis', 'Coaches'' Voice Learning — rest defence', 'https://learning.coachesvoice.com/?p=71763', false),
  ('web-statsbomb-counterpress', 'analysis', 'StatsBomb — how StatsBomb data helps measure counter-pressing', 'https://blogarchive.statsbomb.com/articles/soccer/how-statsbomb-data-helps-measure-counter-pressing/', false),
  ('web-wyscout-ppda', 'analysis', 'Wyscout data glossary — PPDA', 'https://dataglossary.wyscout.com/ppda/', false)
ON CONFLICT (code) DO NOTHING;

UPDATE game_principles SET title = 'Compact block', description = 'Keep the block short and narrow, slide with the ball, protect the middle.' WHERE code = 'op-compact';
UPDATE game_principles SET title = 'Pressure on the ball', description = 'The first defender: close, delay, show, control and restraint, win it.' WHERE code = 'op-pressure';
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-cover', 'out_of_possession', NULL, 'Cover and balance', 'The second and third defenders: cover the presser, balance the far side, swap when the cover steps (pressure–cover–balance: FA, US Soccer, FIFA).', 7);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-press-triggers', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-press-team'), 'Triggers', 'When we go: the moments that start the press.', 8);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-press-traps', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-press-team'), 'Traps', 'Where we win it: shut the carrier in against a line or a crowd.', 8);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-press-shape', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-press-team'), 'Press shape', 'Who presses whom, and the angles that cut the passes.', 8);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-back-line', 'out_of_possession', NULL, 'The back line', 'Hold, step or drop together, and protect the space behind and between the defenders.', 9);

UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-press-triggers') WHERE name IN ('nine-starts-press', 'backpass-step-up', 'lateral-pass-trigger', 'press-the-rebalance', 'loose-pass-trap', 'hurry-the-keeper', 'press-the-bad-touch');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-press-traps') WHERE name IN ('double-team', 'touchline-trap', 'back-to-goal-trap', 'central-trap', 'open-lane-bait', 'lock-the-side', 'press-the-full-back');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-press-shape') WHERE name IN ('press-minus-one', 'press-as-unit', 'pivot-step', 'far-winger-jump', 'screen-the-pivot', 'winger-press-angle', 'cover-shadow', 'lock-the-door', 'shadow-the-line', 'call-adjust-shadow', 'deter', 'press-backward', 'cut-the-key-link');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-back-line') WHERE name IN ('line-hold', 'push-up', 'line-step', 'offside-trap', 'call-squeeze', 'call-line', 'deep-sweeper', 'step-out', 'wingback-drop-five');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-cover') WHERE name IN ('cover', 'balance', 'fill-fullback-space', 'pivot-fills-cb-gap', 'pivot-shift-halfspace', 'deny-the-switch');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-mark') WHERE name IN ('jump-the-pass', 'libero');
UPDATE game_concepts SET title = 'Press on the blind side' WHERE name = 'blind-side-press';
UPDATE game_concepts SET title = 'Double up on the wide carrier' WHERE name = 'double-team';
UPDATE game_concepts SET title = 'Balance: tuck in on the far side' WHERE name = 'balance';
UPDATE game_concepts SET title = 'Man-to-man marking' WHERE name = 'man-mark';
UPDATE game_concepts SET title = 'Wide pair: one presses, one covers' WHERE name = 'deny-the-switch';
UPDATE game_concepts SET title = 'Control and restraint: stay on your feet' WHERE name = 'restraint';
UPDATE game_concepts SET kind = 'style' WHERE name IN ('central-trap', 'close-the-centre');  -- the two ends of press direction

INSERT INTO game_concepts (id, name, title, family, moment, status, kind, principle_id, definition, cue_answer, lacking)
SELECT v.id, v.name, v.title, v.family, v.moment, 'queued', v.kind, p.id, v.def, v.cue, v.lacking FROM (VALUES
  (242, 'close-the-channel', 'Close the channel', 'individual', 'out_of_possession', 'op-back-line', 'behaviour', 'The gap between our centre-back and full-back is the runner''s lane: the nearer of the two narrows it and keeps the runner on his outside shoulder, the other holds his man.', 'A runner aims for the gap between you and your neighbour: close it before he arrives.', 'Runs between centre-back and full-back go through untouched.'),
  (243, 'press-broken-reset', 'Press broken: drop and reset', 'team', 'out_of_possession', 'op-compact', 'behaviour', 'Our press has been played through: stop pressing, sprint back behind the ball and re-form the block before engaging again (the FA''s delay, deny and dictate when pressing is not on).', 'The ball is past our press: everyone back behind it, then set.', 'Players keep chasing from behind while the ball runs at an open back line.'),
  (244, 'win-first-contact', 'Win the first contact', 'group', 'out_of_possession', 'op-back-line', 'behaviour', 'Their long ball: one defender attacks the first header, the nearest teammate drops a few metres behind him for the flick-on, and midfielders collapse on the second ball.', 'Long ball coming: one attacks it, one covers behind.', 'Two defenders go for the same header, or nobody covers the flick-on.'),
  (245, 'guard-cutback-zone', 'Guard the cut-back zone', 'individual', 'out_of_possession', 'op-protect-goal', 'behaviour', 'A runner reaches our byline: a midfielder drops to the penalty spot and the edge of the six-yard box, where cut-backs land, instead of following the ball.', 'Their man is at the byline: get to the penalty spot.', 'Everyone runs to the near post and the cut-back finds a free man.'),
  (246, 'keeper-1v1', 'Keeper 1v1: stay big', 'keeper', 'out_of_possession', 'op-keeper', 'behaviour', 'A forward through on goal: close the distance while his touch is long, set and stay on your feet as he gets ready to shoot, make yourself big and make him decide.', 'Through on you: come while the ball is away from him, set as he looks up.', 'Goes down early, and the forward rounds or chips him.'),
  (247, 'wingback-jump', 'Wing-back jumps, outside centre-back covers', 'group', 'out_of_possession', 'op-press-shape', 'behaviour', 'In a back five, on a trigger (a slow, square or back pass, or a receiver facing his own goal) the wing-back leaves the line to press their full-back and the outside centre-back slides into the channel behind him (Inter''s 5-3-2).', 'Trigger on their full-back: wing-back goes, outside centre-back slides across.', 'The back five stays five and their full-back has all day.'),
  (248, 'wide-cb-steps', 'Wide centre-back steps out', 'individual', 'out_of_possession', 'op-mark', 'behaviour', 'In a back three, the ball-side centre-back follows his man into midfield to stop him turning, while the other two hold the centre.', 'Back three, your man drops into the half-space: follow him; the other two hold.', 'Their 10 or winger receives in the half-space in front of a back three that never steps.'),
  (249, 'double-press', 'Turn and press again', 'individual', 'out_of_possession', 'op-pressure', 'behaviour', 'Beaten by the carrier, the presser turns at once and presses him again from behind while the cover engages him from the front.', 'He''s gone past you: turn and hunt him from behind.', 'The beaten presser stops and watches.'),
  (250, 'access-counter-press', 'Counter-press: ball and nearest man', 'team', 'to_defend', 'td-regain', 'behaviour', 'On the loss, one or two press the ball while everyone else takes the nearest opponent man-to-man for a few seconds, so the carrier has nobody to pass to (Heynckes'' Bayern).', 'Lost it: the nearest presses, everyone else on the nearest man.', 'Everyone swarms the ball and an easy pass escapes.'),
  (251, 'lane-counter-press', 'Counter-press: block the lanes', 'team', 'to_defend', 'td-regain', 'behaviour', 'On the loss, the players near the ball block the obvious passing lanes and leave one bait lane open, then jump the pass into it (Guardiola''s Barcelona).', 'Lost it: shut the lanes, leave the one we want.', 'The carrier is pressed but nobody is on his options.'),
  (252, 'counter-press-window', 'Counter-press window, then drop', 'team', 'to_defend', 'td-regain', 'behaviour', 'Counter-press for a fixed window after the loss (StatsBomb counts 5 s, Opta 2 s); if the ball is not won or forced back by then, drop into the block.', 'Five seconds to win it; then get back.', 'Still chasing the counter-press long after it has failed.'),
  (253, 'nine-curve-press', '9: curve to cut the switch', 'individual', 'out_of_possession', 'op-press-triggers', 'behaviour', 'On the pass to their centre-back, the 9 curves his run so his shadow cuts the pass to the other centre-back, then presses the receiver on a diagonal (Klopp''s Liverpool).', 'Ball to their centre-back: curve in, close the switch, then press.', 'The 9 runs straight and the ball simply goes across.'),
  (254, 'hunting-nine', 'Hunting 9: start wide, trap the centre-back', 'individual', 'out_of_possession', 'op-press-traps', 'behaviour', 'The 9 starts wide on their full-back but one sprint from the near centre-back: the centre-back has no wide pass, and a long ball behind lands where we have the numbers.', 'Stand on their full-back''s line, one sprint from the centre-back.', 'The 9 sits between their centre-backs and the full-back is their easy way out.'),
  (255, 'watch-counter-man', 'Watch their counter man while we attack', 'individual', 'in_possession', 'ip-secure', 'behaviour', 'While we have the ball, a rest-defence player stays tight on their most dangerous counter-attacker, so the moment we lose it he cannot receive (RFEF ''vigilancia'').', 'We are attacking: stay on their counter man.', 'Their best runner is free the moment we lose it.'),
  (256, 'corner-zonal', 'Corner: zonal, own your zone', 'team', 'set_piece', 'sp-defend', 'style', 'Defenders stand in a line across the six-yard box and a second line out to about 12 yards; each attacks the ball into his zone and wins the first contact (FIFA CWC 2025: 60% of corners defended zonally).', 'Corner: in your zone, attack the ball, not the man.', 'Zonal players stand still and let runners attack the ball first.'),
  (257, 'corner-man', 'Corner: man-for-man', 'team', 'set_piece', 'sp-defend', 'style', 'Each defender takes one attacker from the delivery and stays goal-side and touch-tight through the first and second ball (FIFA CWC 2025: 14% of corners).', 'Corner: your man, goal-side, all the way.', 'Runners lose their markers on the blocks and screens.'),
  (258, 'corner-edge-guard', 'Corner: guard the edge of the box', 'individual', 'set_piece', 'sp-defend', 'behaviour', 'One player stays on the edge of the box to win the clearance and block the second-phase shot or cross (FIFA CWC 2025: second-phase corners fell from 57% to 40% with a player there).', 'Corner against us: you own the edge of the box.', 'The cleared ball comes straight back in.'),
  (259, 'set-the-wall', 'Set the wall', 'team', 'set_piece', 'sp-defend', 'behaviour', 'Free kick in range: the keeper calls the number, the wall covers the near post, one man guards the end of the wall for the square ball, the rest mark the runners.', 'Free kick in range: wall up fast, keeper calls it.', 'A slow wall, a free square pass, unmarked runners.'),
  (260, 'permuta', 'Swap after the cover steps', 'group', 'out_of_possession', 'op-cover', 'behaviour', 'The presser is beaten and the cover steps to the carrier: the beaten defender recovers into the cover''s old place or onto his man, so the chain is whole again (RFEF ''permuta'').', 'Your cover took your man: take his place.', 'Two defenders end up on the ball and one space is empty.'),
  (261, 'cbs-hold-goal-width', 'Centre-backs hold the width of the goal', 'group', 'to_defend', 'td-recover', 'behaviour', 'In transition the centre-backs stay inside the posts and are not dragged wide; a recovering midfielder or full-back deals with the wide ball.', 'Lost it: centre-backs stay between the posts.', 'A centre-back chases wide and the middle opens.'),
  (262, 'shoulder-charge', 'Win it shoulder to shoulder', 'individual', 'out_of_possession', 'op-pressure', 'behaviour', 'Running alongside the carrier, use a fair shoulder-to-shoulder charge to knock him off the ball instead of only reaching for a tackle (RFEF ''carga'').', 'Side by side with him: shoulder in, take the ball.', 'Only ever stretches a leg, and the carrier rides it.'),
  (263, 'call-show-him', 'Call: show him outside / inside', 'individual', 'out_of_possession', 'op-cover', 'call', 'The cover tells the presser which way to show the carrier and when to tackle or hold: "show him out!", "now!".', 'You are the cover: tell the presser which way, and when.', 'The presser guesses which way to show him, away from the cover.'),
  (264, 'line-drop-open-ball', 'Drop on an open ball', 'team', 'out_of_possession', 'op-back-line', 'behaviour', 'Their carrier is free, facing forward, with a runner going: the whole line drops together a few steps to protect the space behind, then holds.', 'Open ball and a run: drop together.', 'The line holds high on an open ball and is beaten by one pass.'),
  (265, 'outnumbered-show-cover', 'Outnumbered wide: show him onto the cover', 'individual', 'out_of_possession', 'op-pressure', 'behaviour', 'A wide defender facing two attackers shows the carrier inside onto the covering centre-back instead of out wide, keeping both attackers in view.', 'Two on you out wide: show him in, onto our cover.', 'Shows him outside into the 2v1 and is beaten either way.')
) v(id, name, title, family, moment, pcode, kind, def, cue, lacking) JOIN game_principles p ON p.code = v.pcode;

INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT a.id, b.id, v.k FROM (VALUES
  ('close-the-channel', 'channel-run', 'counters'),
  ('press-broken-reset', 'compact-block', 'refines'),
  ('guard-cutback-zone', 'defend-the-cross', 'refines'),
  ('keeper-1v1', 'narrow-angle', 'refines'),
  ('wingback-jump', 'press-the-full-back', 'refines'),
  ('wide-cb-steps', 'follow-the-dropper', 'refines'),
  ('double-press', 'press-through', 'refines'),
  ('access-counter-press', 'counter-press', 'refines'),
  ('lane-counter-press', 'counter-press', 'refines'),
  ('counter-press-window', 'counter-press', 'refines'),
  ('nine-curve-press', 'nine-starts-press', 'refines'),
  ('hunting-nine', 'cover-shadow', 'refines'),
  ('watch-counter-man', 'rest-defense', 'refines'),
  ('permuta', 'cover', 'refines'),
  ('cbs-hold-goal-width', 'recover', 'refines'),
  ('shoulder-charge', 'win-duel', 'refines'),
  ('call-show-him', 'cover', 'refines'),
  ('line-drop-open-ball', 'line-hold', 'refines'),
  ('outnumbered-show-cover', 'jockey-angle', 'refines'),
  ('loose-pass-trap', 'press-the-bad-touch', 'refines'),
  ('press-minus-one', 'match-up', 'refines'),
  ('lock-the-door', 'lock-the-side', 'refines')
) v(a, b, k) JOIN game_concepts a ON a.name = v.a JOIN game_concepts b ON b.name = v.b ON CONFLICT DO NOTHING;

INSERT INTO game_concept_measures (concept, measure) VALUES
  ('close-the-channel', 'off_ball'),
  ('press-broken-reset', 'transition'),
  ('win-first-contact', 'duel'),
  ('guard-cutback-zone', 'cross'),
  ('keeper-1v1', 'keeper'),
  ('wingback-jump', 'press'),
  ('wide-cb-steps', 'off_ball'),
  ('double-press', 'press'),
  ('access-counter-press', 'transition'),
  ('lane-counter-press', 'transition'),
  ('counter-press-window', 'transition'),
  ('nine-curve-press', 'press'),
  ('hunting-nine', 'press'),
  ('watch-counter-man', 'off_ball'),
  ('corner-zonal', 'restart'),
  ('corner-man', 'restart'),
  ('corner-edge-guard', 'restart'),
  ('set-the-wall', 'restart'),
  ('permuta', 'off_ball'),
  ('cbs-hold-goal-width', 'team_shape'),
  ('shoulder-charge', 'duel'),
  ('call-show-him', 'unseen'),
  ('line-drop-open-ball', 'team_shape'),
  ('outnumbered-show-cover', 'duel')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation, verified)
SELECT c.id, s.id, s.title, false FROM (VALUES
  ('close-the-channel', 'web-fa-defend-space-behind'),
  ('press-broken-reset', 'web-fa-dna-oop'),
  ('wingback-jump', 'web-btl-inter-532'),
  ('wide-cb-steps', 'web-btl-inter-532'),
  ('double-press', 'web-uefa-setting-the-press'),
  ('access-counter-press', 'web-sv-counterpressing'),
  ('lane-counter-press', 'web-sv-counterpressing'),
  ('counter-press-window', 'web-statsbomb-counterpress'),
  ('nine-curve-press', 'web-sv-liverpool-pressing'),
  ('hunting-nine', 'web-sv-4141-traps'),
  ('watch-counter-man', 'web-sv-rest-defence'),
  ('watch-counter-man', 'web-rfef-principles-dialnet'),
  ('watch-counter-man', 'web-fa-defend-transition'),
  ('corner-zonal', 'web-fifa-cwc25-corners'),
  ('corner-man', 'web-fifa-cwc25-corners'),
  ('corner-edge-guard', 'web-fifa-cwc25-corners'),
  ('permuta', 'web-rfef-principles-dialnet'),
  ('cbs-hold-goal-width', 'web-fa-defend-transition'),
  ('shoulder-charge', 'web-rfef-principles-dialnet'),
  ('call-show-him', 'web-fa-defend-roles'),
  ('line-drop-open-ball', 'web-fifa-zonal-progressive'),
  ('line-drop-open-ball', 'web-fa-defend-space-behind'),
  ('outnumbered-show-cover', 'web-fa-defend-overloads')
) v(c, s) JOIN game_concepts c ON c.name = v.c JOIN game_sources s ON s.code = v.s ON CONFLICT DO NOTHING;

INSERT INTO game_style_dimensions (code, moment, title, low_label, high_label, definition, measure, sort_order) VALUES
  ('press-direction', 'out_of_possession', 'Press direction', 'show inside', 'show outside', 'Which way the press forces their build-up: into the middle where we collapse on it, or out to the touchline.', 'share of their progressive passes through the middle vs the wings', 12),
  ('rest-defence', 'in_possession', 'Rest defence', 'few left back', 'many left back', 'How many men stay behind the ball while we attack (typically 4–6, in a 2-3, 3-2 or 2-2 shape).', 'players behind the ball at our final-third entries', 13),
  ('back-line', 'out_of_possession', 'Back line', 'back four', 'back five', 'Whether the team defends with four or five across the back.', 'players in the last line out of possession', 14),
  ('set-piece-marking', 'set_piece', 'Set-piece marking', 'zonal', 'man-for-man', 'How corners and wide free kicks are defended: zones, hybrid, or man-for-man (FIFA CWC 2025: 60% zonal, 24% hybrid, 14% man).', 'share of defended corners by scheme', 15),
  ('defensive-rhythm', 'out_of_possession', 'Defensive rhythm', 'steady', 'varied', 'Defend at one intensity all game, or pick moments to press hard and moments to sit and rest (Vítor Pereira).', 'spread of PPDA across 15-minute spells', 16);
UPDATE game_style_dimensions SET measure = 'PPDA (Wyscout: their passes in our final 60% of the pitch ÷ our defensive actions there; lower = harder); StatsBomb pressure = a defender within 5 yards of the carrier' WHERE code = 'pressing';
UPDATE game_style_dimensions SET measure = 'regains within 5 s of a loss; counter-press fraction (StatsBomb: share of losses pressed within 5 s, PL average 0.47)' WHERE code = 'after-loss';
UPDATE game_style_dimensions SET measure = 'average height of the defensive line without the ball (FIFA EFI: goal line to deepest outfield player) and team length' WHERE code = 'block-height';
UPDATE game_concepts c SET style_dimension_id = d.id, style_value = v.val FROM (VALUES
  ('central-trap', 'press-direction', -2),
  ('close-the-centre', 'press-direction', 2),
  ('corner-zonal', 'set-piece-marking', -2),
  ('corner-man', 'set-piece-marking', 2)
) v(name, dcode, val) JOIN game_style_dimensions d ON d.code = v.dcode WHERE c.name = v.name;

CREATE TEMP TABLE retag (pattern_id int, concept text) ON COMMIT DROP;
INSERT INTO retag VALUES (180,'corner-zonal'), (182,'set-the-wall'), (183,'set-the-wall'), (444,'line-drop-open-ball'), (1994,'wingback-jump'), (3005,'corner-zonal'), (3517,'win-first-contact'), (4361,'corner-zonal');
UPDATE coaching_book_pattern_concepts x SET is_main = false FROM retag r WHERE x.pattern_id = r.pattern_id AND x.is_main;
INSERT INTO coaching_book_pattern_concepts (pattern_id, concept_id, is_main, fit)
SELECT r.pattern_id, c.id, true, 'good' FROM retag r JOIN game_concepts c ON c.name = r.concept
ON CONFLICT (pattern_id, concept_id) DO UPDATE SET is_main = true, fit = 'good';
UPDATE coaching_book_patterns p SET concept_fit = 'tagged' FROM retag r WHERE p.id = r.pattern_id;
COMMIT;
