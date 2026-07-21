-- 238-game-model-principles-visibility.sql (2026-07-20)
-- Expand the live game-model principles so the public view shows multiple main principles per phase and the hierarchy remains DB-driven.

BEGIN;

WITH attack_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
), transition_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
)
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT ap.id, 'create-overloads-in-middle', 'main', 'Create overloads in the middle', 'Create overloads in the middle and free a player in the attacking third.', 2
FROM attack_phase ap
ON CONFLICT (phase_id, slug) DO NOTHING;

WITH attack_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
)
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT ap.id, 'use-third-man-run-as-trigger', 'main', 'Use the third-man run as the trigger', 'Use the third-man run as the trigger to open the line and create the next action.', 3
FROM attack_phase ap
ON CONFLICT (phase_id, slug) DO NOTHING;

WITH attack_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
)
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT ap.id, 'finish-with-purpose-root', 'main', 'Finish with purpose', 'Finish with purpose and create a chance or line-breaking action.', 4
FROM attack_phase ap
ON CONFLICT (phase_id, slug) DO NOTHING;

WITH transition_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
)
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT tp.id, 'protect-the-middle-and-stay-connected', 'main', 'Protect the middle and stay connected', 'Protect the middle and stay connected when the team loses the ball.', 2
FROM transition_phase tp
ON CONFLICT (phase_id, slug) DO NOTHING;

WITH transition_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
)
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT tp.id, 'press-the-ball-and-stay-organized', 'main', 'Press the ball and stay organized', 'Press the ball as a unit while keeping the structure intact.', 3
FROM transition_phase tp
ON CONFLICT (phase_id, slug) DO NOTHING;

WITH transition_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
)
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT tp.id, 'balance-the-channel-root', 'main', 'Balance the channel', 'Balance the channel and protect the line after the turnover.', 4
FROM transition_phase tp
ON CONFLICT (phase_id, slug) DO NOTHING;

WITH attack_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
)
UPDATE club_game_model_principles pr
SET parent_principle_id = root.id
FROM club_game_model_principles root
WHERE pr.phase_id = (SELECT id FROM attack_phase)
  AND root.phase_id = (SELECT id FROM attack_phase)
  AND pr.slug = 'vertical-or-diagonal-passing-options'
  AND root.slug = 'provide-options-to-play-forward';

WITH attack_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
)
UPDATE club_game_model_principles pr
SET parent_principle_id = child.id
FROM club_game_model_principles child
WHERE pr.phase_id = (SELECT id FROM attack_phase)
  AND child.phase_id = (SELECT id FROM attack_phase)
  AND pr.slug = 'supporting-angle-and-structure'
  AND child.slug = 'vertical-or-diagonal-passing-options';

WITH attack_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
)
UPDATE club_game_model_principles pr
SET parent_principle_id = child.id
FROM club_game_model_principles child
WHERE pr.phase_id = (SELECT id FROM attack_phase)
  AND child.phase_id = (SELECT id FROM attack_phase)
  AND pr.slug = 'receive-facing-forward'
  AND child.slug = 'supporting-angle-and-structure';

WITH transition_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
)
UPDATE club_game_model_principles pr
SET parent_principle_id = root.id
FROM club_game_model_principles root
WHERE pr.phase_id = (SELECT id FROM transition_phase)
  AND root.phase_id = (SELECT id FROM transition_phase)
  AND pr.slug = 'first-two-players-recover'
  AND root.slug = 'recover-shape-immediately';

WITH transition_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
)
UPDATE club_game_model_principles pr
SET parent_principle_id = child.id
FROM club_game_model_principles child
WHERE pr.phase_id = (SELECT id FROM transition_phase)
  AND child.phase_id = (SELECT id FROM transition_phase)
  AND pr.slug = 'press-on-the-ball'
  AND child.slug = 'first-two-players-recover';

WITH transition_phase AS (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
)
UPDATE club_game_model_principles pr
SET parent_principle_id = child.id
FROM club_game_model_principles child
WHERE pr.phase_id = (SELECT id FROM transition_phase)
  AND child.phase_id = (SELECT id FROM transition_phase)
  AND pr.slug = 'balance-the-channel'
  AND child.slug = 'press-on-the-ball';

COMMIT;
