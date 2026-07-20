-- 236-us-soccer-game-model-alignment.sql (2026-07-20)
-- Align the live club game-model phases and principles with the U.S. Soccer U17+ framework.
-- This keeps the schema normalized while updating the actual content to the new four-phase model.

BEGIN;

-- Update the club game-model row metadata for the target club(s).
UPDATE club_game_model
SET title = 'U17+ Game Model',
    summary = 'A U.S. Soccer-aligned U17+ coaching framework built around four moments of play: attack, defend, transition to attack, and transition to defense.',
    base_shape = '11v11',
    updated_at = NOW()
WHERE club_id = 100 AND is_active = true;

-- Re-label and re-describe the existing phases to the four-phase structure.
UPDATE club_game_model_phases
SET slug = 'attack',
    label = 'Attack',
    description = 'Build with structure, create overloads, break lines, and finish with purpose.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'offense';

UPDATE club_game_model_phases
SET slug = 'defend',
    label = 'Defend',
    description = 'Defend compactly, force play wide, and recover as a unit.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'defense';

UPDATE club_game_model_phases
SET slug = 'transition-to-attack',
    label = 'Transition to Attack',
    description = 'Attack immediately after regaining possession and create the next action.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'offensive-transition';

UPDATE club_game_model_phases
SET slug = 'transition-to-defense',
    label = 'Transition to Defense',
    description = 'Recover shape quickly and protect the middle after losing the ball.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'defensive-transition';

-- Update principle titles/descriptions to match the U.S. Soccer language without changing the normalized structure.
UPDATE club_game_model_principles
SET title = 'Build from the back with clear support angles',
    description = 'The team should circulate calmly and create a free player before the attack becomes vertical.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
) AND slug = 'build-from-back';

UPDATE club_game_model_principles
SET title = 'Create overloads in the middle',
    description = 'The midfielders connect the build to the attack and free a player in the attacking third.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
) AND slug = 'create-overloads';

UPDATE club_game_model_principles
SET title = 'Use the third-man run as the trigger',
    description = 'The third-man run should open the line and create the next pass or finish.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
) AND slug = 'third-man-run';

UPDATE club_game_model_principles
SET title = 'Finish with purpose',
    description = 'The attack should create a chance, a cross, or a line-breaking action rather than playing for possession alone.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'attack'
) AND slug = 'finish-with-purpose';

UPDATE club_game_model_principles
SET title = 'Defend compact and aggressive as a unit',
    description = 'The team should stay together and deny central penetrations before the opponent can progress.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'defend'
) AND slug = 'defend-compact';

UPDATE club_game_model_principles
SET title = 'Force play wide and protect the middle',
    description = 'The nearest player presses, the second covers, and the third balances the space.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'defend'
) AND slug = 'force-wide';

UPDATE club_game_model_principles
SET title = 'Counter-press immediately',
    description = 'The team should recover the ball and shift the pressure to the opponent as soon as possible.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'defend'
) AND slug = 'counter-press';

UPDATE club_game_model_principles
SET title = 'Protect the central lane',
    description = 'The midfielders and back line must stay connected to prevent a direct line through the middle.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'defend'
) AND slug = 'protect-central';

UPDATE club_game_model_principles
SET title = 'Counter-attack quickly after the turnover',
    description = 'The first pass should be vertical or line-breaking so the team can attack with numbers.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-attack'
) AND slug = 'counter-attack-quickly';

UPDATE club_game_model_principles
SET title = 'Support the break with a fast second action',
    description = 'The second and third players should join the attack immediately after the first pass.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-attack'
) AND slug = 'support-the-break';

UPDATE club_game_model_principles
SET title = 'Attack the space behind the defensive line',
    description = 'The front line should make the attack unpredictable and force the back line to react.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-attack'
) AND slug = 'attack-the-space';

UPDATE club_game_model_principles
SET title = 'Protect the break and reset shape',
    description = 'The team should keep enough balance to defend if the transition fails.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-attack'
) AND slug = 'protect-the-break';

UPDATE club_game_model_principles
SET title = 'Recover shape immediately after losing the ball',
    description = 'The first recovery action should restore the compact block and protect the middle.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
) AND slug = 'recover-shape';

UPDATE club_game_model_principles
SET title = 'The first two players recover the shape',
    description = 'The first two players should balance the space and make the team compact again.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
) AND slug = 'first-two-recover';

UPDATE club_game_model_principles
SET title = 'Press the ball but stay organized',
    description = 'The pressure should be immediate without breaking the unit structure.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
) AND slug = 'press-on-the-ball';

UPDATE club_game_model_principles
SET title = 'Balance the channel and protect the line',
    description = 'The team should not allow the ball to play straight through the middle after the turnover.',
    updated_at = NOW()
WHERE phase_id IN (
    SELECT id FROM club_game_model_phases WHERE club_id = 100 AND slug = 'transition-to-defense'
) AND slug = 'balance-the-channel';

COMMIT;
