-- 240-us-soccer-game-model-doc-seed.sql (2026-07-21)
-- Seed the normalized definitions and player actions for the current U.S. Soccer-aligned phases.

BEGIN;

UPDATE club_game_model_phases
SET label = 'Attacking',
    description = 'When in possession, advance the ball quickly in the attacking half with high energy and high tempo.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'attack';

UPDATE club_game_model_phases
SET label = 'Defending',
    description = 'When out of possession, protect the goal and delay the opponent''s progress by creating a compact and organized defensive shape.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'defend';

UPDATE club_game_model_phases
SET label = 'Attacking to Defending Transition',
    description = 'As soon as possession is lost, recover balance and apply pressure quickly.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'transition-to-defense';

UPDATE club_game_model_phases
SET label = 'Defending to Attacking Transition',
    description = 'As soon as possession is won, attack quickly and create the next action.',
    updated_at = NOW()
WHERE club_id = 100 AND slug = 'transition-to-attack';

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'attacking-game-idea', 'Game Idea', 'When in possession, we want to dominate by advancing the ball quickly in the attacking half with high energy and high tempo.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'defending-game-idea', 'Game Idea', 'When out of possession, the team protects the goal and delays the opponent''s progress by creating a compact and organized defensive shape.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defend'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'attacking-to-defending-transition-game-idea', 'Game Idea', 'After losing possession, the team must immediately recover shape, protect the central space, and delay the opponent''s counterattack.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'defending-to-attacking-transition-game-idea', 'Game Idea', 'When the team regains possession, it should attack quickly with numbers and create the next action before the opponent can recover.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'drive-with-the-ball-to-exploit-space', 'Drive with the ball to exploit space', 'Recognize and exploit space by advancing the ball with quality and tempo.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'engage-opponent-create-1v1-or-2v1', 'Engage the opponent to create a 1v1 or 2v1', 'Create isolation by engaging the opponent and using the space in front of you.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'find-a-free-player-between-or-behind-the-lines', 'Find a free player between or behind the lines', 'Pass quickly to a free teammate to keep the attack moving.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'cross-into-space-or-player', 'Cross into space or to a player', 'Create a finish by timing the cross into the right zone or to the right runner.', 4
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'press-the-ball-carrier', 'Press the ball carrier', 'Press the ball carrier immediately and make the play predictable.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defend'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'cover-the-nearest-supporting-player', 'Cover the nearest supporting player', 'Cover the nearest supporting player to maintain balance.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defend'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'balance-and-protect-the-middle', 'Balance and protect the middle', 'Protect the central lane and deny through balls.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defend'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'press-closest-opponent-immediately', 'Press the closest opponent immediately', 'Press the closest opponent immediately to delay the transition.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'recover-into-defensive-shape', 'Recover into defensive shape', 'Recover into defensive shape and protect the middle.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'protect-the-width-of-the-goal', 'Protect the width of the goal', 'Protect the width of the goal and deny central penetration.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'play-the-first-pass-forward', 'Play the first pass forward', 'Play the first pass forward and attack the space behind the defensive line.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'support-the-break-with-speed', 'Support the break with speed', 'Support the break with speed and create a numerical advantage.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'finish-the-counterattack-with-purpose', 'Finish the counterattack with purpose', 'Finish the counterattack with purpose and create a chance.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'transition-to-attack'
ON CONFLICT (phase_id, slug) DO NOTHING;

COMMIT;
