-- 692 (2026-10-24) — game: hold the line, man-marking matchups, shot
-- selection on what the chance is worth (game/DESIGN.md §8.52, G4.55-56).
--
-- James: "what concepts are not being used that causes the players to
-- drop so far back on defense … pushing up the lines. then for lighthouse
-- it's the same to get to mark and -1 and +1."
--
-- Measured: back lines 16-22 m from their own goal (real ~35-45 m), the
-- ball 33-35 m beyond them. Cause: the back line followed the deepest
-- attacker — a G4.4 rule written before the offside law existed — and the
-- hold distance only ever capped a defender, never brought him up.

-- The line's numbers (were literals in the Brain).
INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'line-hold', 'hold_m', 25::numeric, 'm', 'The back line sits this far behind a covered ball (push-up squeezes it).'),
 ('concept', 'line-hold', 'squeeze_m', 13, 'm', 'push-up at 100 takes this much off hold_m.'),
 ('concept', 'line-hold', 'uncovered_drop_m', 6, 'm', 'A free carrier facing forward (uncovered ball): the line drops this much more.'),
 ('concept', 'engage-or-contain', 'danger_m', 25, 'm', 'Deny the shot: inside this distance of our goal he closes the carrier down (FA "delay, deny, dictate").'),
 ('concept', 'shot-selection', 'xg_scale', 0.64, '', 'xg = scale · visible-goal angle (rad, halved per body in it) · e^(−d/decay). [FH] fitted to rough public xG anchors (~0.45 at 6 m, ~0.2 at the spot, ~0.09 at the box edge, ~0.03 at 25 m, central) — source to pin.'),
 ('concept', 'shot-selection', 'xg_decay_m', 13.5, 'm', 'Distance decay of the xG read.'),
 ('concept', 'shot-selection', 'pressed_factor', 0.7, '', 'A pressed shot is worth this share.'),
 ('concept', 'shot-selection', 'min_xg_pressed', 0.05, 'xG', 'Pressed: shoot at this chance or better (shoot or lose it).'),
 ('concept', 'shot-selection', 'min_xg_free', 0.12, 'xG', 'Free: needs this much, else he works it closer.'),
 ('concept', 'shot-selection', 'pass_better', 1.5, '×', 'A mate with a safe pass and this many times his chance → pass instead.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_concepts
   SET cue_answer = 'Hold a height off the BALL: tight behind a covered ball, a few metres deeper when a free carrier faces forward. An attacker beyond the line is offside, not a man to follow.',
       lacking = 'Drops with the deepest attacker every time — the whole team sinks into its own box.'
 WHERE name = 'line-hold';
UPDATE game_concepts
   SET cue_answer = 'Shoot on what the chance is worth against what else you have: pressed, take a fair chance; free, work a better one; a mate with a clearly better chance gets the pass.',
       lacking = 'Shoots whenever he sees a bit of goal — from 25 m, with a teammate free at the far post.'
 WHERE name = 'shot-selection';
UPDATE game_concepts
   SET cue_answer = cue_answer || ' Man-marking: take your direct opponent from the matchup and follow him anywhere; the free man takes nobody.'
 WHERE name = 'man-mark' AND cue_answer NOT LIKE '%direct opponent%';
