-- 812 (2026-10-29) — game: the taxonomy covers PLAYER MOVEMENT — a
-- `movement` technique family (how the body moves, not where he runs) —
-- and the `reaction` attribute is wired (game/DESIGN.md §8.83, G4.85).
--
-- James 10/29: "our taxonomy should cover player movement." / "lets do it.
-- we can always adjust later". The engine already moves bodies (G4.51-54
-- core::Body: sprint τ, braking, turning, gaits, body yaw, head turn; G4.80
-- brake to arrive; G4.84 run on time) but nothing in game_techniques named
-- it: movement-off-the-ball is tactical runs (WHERE he goes). This family is
-- the athletic side — HOW he gets there.
--
-- Sources: Bloomfield, Polman & O'Donoghue 2007 (the Bloomfield Movement
-- Classification of Premier League time-motion: sprint, run, shuffle, skip,
-- jog, walk; forward / backward / lateral / diagonal / arc); Sheppard &
-- Young 2006 (agility = a rapid whole-body change of velocity or direction
-- IN RESPONSE TO A STIMULUS — change-of-direction speed plus perception and
-- decision). Rows that only name what the engine does cite [FH].
--
-- `reaction` (game_attributes, 'teaching' since mig 653) is now his own: the
-- time he takes to respond to the kick, a body number (core::Body). The
-- flight read and the passer's pass-safety read use HIS reaction, counted
-- once from the moment the flight began — so concept.meet-the-pass.
-- reaction_s (one flat number for everyone) is retired.

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('bloomfield-2007', 'analysis',
   'Bloomfield, Polman & O''Donoghue (2007), Physical demands of different positions in FA Premier League soccer, J Sports Sci Med 6:63-70',
   'https://www.jssm.org/jssm-06-63.xml-Fulltext', true),
  ('sheppard-young-2006', 'analysis',
   'Sheppard & Young (2006), Agility literature review: classifications, training and testing, J Sports Sci 24(9):919-932',
   'https://doi.org/10.1080/02640410500457109', true)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_techniques (id, code, parent_id, node, title, how, taught_from, status, sort_order) VALUES
  (11, 'movement', NULL, 'family', 'Movement',
   'How the body moves — starting, stopping, turning, the gaits, reacting and adjusting to the ball. Where he runs is movement-off-the-ball.',
   NULL, 'teaching', 11),
  (48, 'movement-ready-and-react', 11, 'group', 'Ready and react', 'Set before the ball moves; go the moment it does.', NULL, 'teaching', 28),
  (49, 'movement-start-and-stop',  11, 'group', 'Start and stop',  'Get up to speed, and come off it under control.', NULL, 'teaching', 29),
  (50, 'movement-change-direction', 11, 'group', 'Change direction', 'Plant, cut, turn the body, open the hips.', NULL, 'teaching', 30),
  (51, 'movement-gaits',           11, 'group', 'Gaits',            'Forward, side-on, sideways and backwards running.', NULL, 'teaching', 31),
  (52, 'movement-adjust-to-ball',  11, 'group', 'Adjust to the ball', 'Read the ball''s flight and fit his feet and speed to it.', NULL, 'teaching', 32),
  (53, 'movement-jump-and-land',   11, 'group', 'Jump and land',    'Take off for a high ball and land balanced.', NULL, 'teaching', 33),

  (280, 'move-athletic-stance', 48, 'technique', 'Athletic stance',
   'Ball about to be played → knees bent, weight on the balls of the feet, ready to go either way', 'u10', 'teaching', 180),
  (281, 'move-react-to-kick', 48, 'technique', 'React to the kick',
   'Ball struck → move on it now, not when it arrives (his reaction attribute: the time to respond, counted once from the kick)', 'u10', 'wired', 181),
  (282, 'move-first-step', 48, 'technique', 'First step',
   'Going → a short, low, explosive first step in the new direction', 'u10', 'teaching', 182),

  (283, 'move-accelerate', 49, 'technique', 'Accelerate',
   'Space to attack or a race → drive up to top speed (acceleration: his sprint τ)', 'u10', 'wired', 183),
  (284, 'move-decelerate', 49, 'technique', 'Decelerate',
   'Arriving at the ball, a man or a spot → brake in short steps, low, under control (deceleration: his braking limit and how fast it bites)', 'u14', 'wired', 184),
  (285, 'move-arrive-on-time', 49, 'technique', 'Arrive on time',
   'Running onto a moving ball → go at the speed that gets him there when it does — not early and waiting, not late and braking (G4.80/G4.84)', 'u14', 'wired', 185),

  (286, 'move-plant-and-cut', 50, 'technique', 'Plant and cut',
   'Change of direction at speed → plant the outside foot and push off it (agility: his turning limit)', 'u10', 'wired', 186),
  (287, 'move-turn-body', 50, 'technique', 'Turn the body',
   'Ball or man behind him → turn hips and shoulders to it (agility: his body yaw)', 'u10', 'wired', 187),
  (288, 'move-drop-step', 50, 'technique', 'Drop step',
   'Ball played over or beyond him → open the hips and step back with the near foot to run, not backpedal', 'u14', 'wired', 188),

  (289, 'move-sprint', 51, 'technique', 'Sprint forward',
   'Open ground → run flat out facing his line (pace: his top speed)', 'u10', 'wired', 189),
  (290, 'move-side-on-run', 51, 'technique', 'Side-on run',
   'Moving across while watching the ball → hips open, crossover steps (his side-on share of top speed)', 'u14', 'wired', 190),
  (291, 'move-shuffle', 51, 'technique', 'Shuffle',
   'Short lateral adjustment facing the play → side steps, feet never crossing', 'u10', 'teaching', 191),
  (292, 'move-backpedal', 51, 'technique', 'Backpedal',
   'A few metres back while facing the ball → short backward steps (his backpedal share of top speed)', 'u10', 'wired', 192),
  (293, 'move-skip', 51, 'technique', 'Skip',
   'Adjusting position at low intensity → skipping steps', NULL, 'teaching', 193),

  (294, 'move-read-flight', 52, 'technique', 'Read the flight',
   'Ball in the air or rolling → judge where and when he can first reach it, the time his reaction costs him counted once (the flight read)', 'u10', 'wired', 194),
  (295, 'move-controllable-pace', 52, 'technique', 'Take it at a pace you can hold',
   'Our pass coming → meet it where it has slowed to what his first touch can control, not early and hot', 'u14', 'wired', 195),
  (296, 'move-adjusting-steps', 52, 'technique', 'Adjusting steps',
   'Last metres to the ball → small steps to set the receiving foot', 'u10', 'teaching', 196),

  (297, 'move-jump-take-off', 53, 'technique', 'Take off',
   'High ball → one-footed take-off at the top of the approach, arms up', 'u14', 'teaching', 197),
  (298, 'move-land', 53, 'technique', 'Land',
   'Coming down → two feet where he can, knees bent, ready for the next action', 'u14', 'teaching', 198)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_technique_sources (technique_id, source_id, citation, verified)
SELECT t.id, s.id, x.citation, x.verified
FROM (VALUES
  ('movement',              'bloomfield-2007',     'Bloomfield Movement Classification: purposeful movement by type and direction (sprint, run, shuffle, skip, jog, walk; forward, backward, lateral, diagonal, arc)', true),
  ('movement',              'sheppard-young-2006', 'Agility: a rapid whole-body movement with a change of velocity or direction in response to a stimulus', true),
  ('movement-change-direction', 'sheppard-young-2006', 'Change-of-direction speed: the physical component of agility', true),
  ('move-react-to-kick',    'sheppard-young-2006', 'The perceptual / decision component: responding to a stimulus', true),
  ('move-react-to-kick',    'fh',                  'Flight read and pass-safety read charge his reaction once from the kick (G4.85)', true),
  ('move-accelerate',       'fh',                  'core::Body sprint τ (G4.51-52)', true),
  ('move-decelerate',       'fh',                  'core::Body braking limit and brake τ (G4.51, G4.80)', true),
  ('move-arrive-on-time',   'fh',                  'Brain::brakeToArrive (G4.80, G4.84)', true),
  ('move-plant-and-cut',    'fh',                  'core::Body turning limit (G4.51)', true),
  ('move-turn-body',        'fh',                  'core::Body yaw (G4.53)', true),
  ('move-drop-step',        'fh',                  'Why::DropStep (drop-step concept)', true),
  ('move-sprint',           'bloomfield-2007',     'Sprint, directly forward', true),
  ('move-side-on-run',      'bloomfield-2007',     'Lateral and diagonal movement', true),
  ('move-side-on-run',      'fh',                  'core::Body gait: side-on share (G4.54)', true),
  ('move-shuffle',          'bloomfield-2007',     'Shuffle', true),
  ('move-backpedal',        'bloomfield-2007',     'Backward movement', true),
  ('move-backpedal',        'fh',                  'core::Body gait: backpedal share (G4.54)', true),
  ('move-skip',             'bloomfield-2007',     'Skip', true),
  ('move-read-flight',      'fh',                  'Brain::flightRead (G4.49, G4.85)', true),
  ('move-controllable-pace','fh',                  'Flight read: our own ball is taken where it is at or under his control speed (G4.85)', true)
) AS x(code, source, citation, verified)
JOIN game_techniques t ON t.code = x.code
JOIN game_sources s ON s.code = x.source
ON CONFLICT DO NOTHING;

-- What the concepts need executed.
INSERT INTO game_concept_techniques (concept_id, technique_id)
SELECT c.id, t.id
FROM (VALUES
  ('meet-the-pass', 'move-react-to-kick'), ('meet-the-pass', 'move-read-flight'),
  ('meet-the-pass', 'move-arrive-on-time'), ('meet-the-pass', 'move-controllable-pace'),
  ('meet-the-pass', 'move-adjusting-steps'),
  ('intercept', 'move-react-to-kick'), ('intercept', 'move-read-flight'), ('intercept', 'move-arrive-on-time'),
  ('jump-the-pass', 'move-react-to-kick'), ('jump-the-pass', 'move-read-flight'), ('jump-the-pass', 'move-first-step'),
  ('drop-step', 'move-drop-step'), ('drop-step', 'move-turn-body'),
  ('side-on-jockey', 'move-side-on-run'), ('side-on-jockey', 'move-shuffle'), ('side-on-jockey', 'move-backpedal'),
  ('jockey-angle', 'move-decelerate'), ('jockey-angle', 'move-athletic-stance'),
  ('recover', 'move-turn-body'), ('recover', 'move-sprint')
) AS x(concept, technique)
JOIN game_concepts c ON c.name = x.concept
JOIN game_techniques t ON t.code = x.technique
ON CONFLICT DO NOTHING;

-- Reaction is wired: a body number, his own.
UPDATE game_attributes
   SET status = 'wired',
       scales = 'reaction time to the kick: 0.30 s at 0 … 0.20 at 50 … 0.15 at 100 (flight read + pass-safety read, once from the kick)',
       description = 'Time to respond to a stimulus — the kick (USYS U-12; Sheppard & Young 2006)'
 WHERE code = 'reaction';

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('skill', 'reaction', 'reaction_s_at0',   0.30, 's', 'Time to move on the kick at 0. [FH] estimate — 50 = the old flat meet-the-pass reaction_s (0.2 s), so a 50 plays as before; sport reaction-time source to pin.'),
  ('skill', 'reaction', 'reaction_s_at50',  0.20, 's', 'At 50.'),
  ('skill', 'reaction', 'reaction_s_at100', 0.15, 's', 'At 100.')
ON CONFLICT DO NOTHING;

DELETE FROM game_model_params WHERE owner = 'concept' AND code = 'meet-the-pass' AND param = 'reaction_s';
