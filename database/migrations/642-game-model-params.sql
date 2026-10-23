-- 642 (2026-10-22) — game: the game model's NUMBERS live in the DB; the
-- Bielsa roles (libero, cover-shadow 9) and Sacchi's line step switched on
-- (game/DESIGN.md §8.29).
--
-- James: "remember no hard code. all comes from db and oop" / "each concept
-- is a class? extended from concept? each skill a skill extended from
-- skills?" / "lh should be when out of possession find a mark and have free
-- libero follow ball but set themselves ready for long ball. the lh 9 should
-- look to cover shadow press the ball carrying cb on ukies" / "both teams
-- should try to push up line at a semi pro level … when ball is moving push
-- up and stop as opp is receiving and can play long. push up if opp is
-- turned toward their own goal with ball" / "use principles and game models
-- from around the world".
--
-- game_model_params: one row per number a Skill or Concept class uses
-- (game/src/core/Skill.hpp, game/src/ai/Concept.hpp), keyed
-- owner.code.param. The daemon reads them at boot; the classes' built-in
-- values equal these seeds and only apply when the DB is unreachable.

CREATE TABLE IF NOT EXISTS game_model_params (
    owner   TEXT NOT NULL CHECK (owner IN ('skill', 'concept')),
    code    TEXT NOT NULL,        -- game_attributes.code / concept name
    param   TEXT NOT NULL,
    value   NUMERIC NOT NULL,
    unit    TEXT NOT NULL,
    note    TEXT NOT NULL,        -- what it means + where it comes from
    PRIMARY KEY (owner, code, param)
);
COMMENT ON TABLE game_model_params IS 'Numbers of the game model''s Skill/Concept classes (mig 642), read by fh-game at boot.';

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 -- skills (mig 636 semantics; 50 = the band)
 ('skill', 'pace',         'base_cms',      540, 'cm/s', 'Top speed at pace 0 (APSL legs: 5.4 m/s).'),
 ('skill', 'pace',         'per_point_cms', 2,   'cm/s', 'Added per pace point: 6.4 m/s at 50, 7.4 at 100.'),
 ('skill', 'passing',      'at0_pct',       150, '%',    'Pass angle/power error at passing 0, as % of the band.'),
 ('skill', 'passing',      'at100_pct',     50,  '%',    'Pass error at passing 100, as % of the band.'),
 ('skill', 'shooting',     'at0_pct',       150, '%',    'Shot error at shooting 0, as % of the band.'),
 ('skill', 'shooting',     'at100_pct',     50,  '%',    'Shot error at shooting 100, as % of the band.'),
 ('skill', 'first_touch',  'at0_pct',       75,  '%',    'Fastest controllable ball at first touch 0, as % of the band.'),
 ('skill', 'first_touch',  'at100_pct',     125, '%',    'Fastest controllable ball at first touch 100.'),
 ('skill', 'tackling',     'spread_points', 30,  'pct points', 'Tackle success +/- around the band from tackling 0 to 100.'),
 ('skill', 'tackling',     'min_pct',       5,   '%',    'Floor on tackle success.'),
 ('skill', 'tackling',     'max_pct',       95,  '%',    'Ceiling on tackle success.'),
 ('skill', 'anticipation', 'at0_pct',       150, '%',    'Perception delay at anticipation 0, as % of the band.'),
 ('skill', 'anticipation', 'at100_pct',     50,  '%',    'Perception delay at anticipation 100.'),
 ('skill', 'decisions',    'at0_pct',       150, '%',    'Decision jitter at decisions 0, as % of the band.'),
 ('skill', 'decisions',    'at100_pct',     50,  '%',    'Decision jitter at decisions 100.'),
 ('skill', 'goalkeeping',  'at0_pct',       150, '%',    'Keeper reaction + fumbles at goalkeeping 0, as % of the band.'),
 ('skill', 'goalkeeping',  'at100_pct',     50,  '%',    'Keeper reaction + fumbles at goalkeeping 100.'),
 -- libero [Bielsa: the free +1 behind man-oriented marking]
 ('concept', 'libero', 'depth_min_m',        2,   'm',   'Libero sits at least this far behind the deepest teammate [Bielsa].'),
 ('concept', 'libero', 'depth_span_m',       3,   'm',   '… plus this much more at rating 100 (2-5 m).'),
 ('concept', 'libero', 'lateral_follow',     0.6, 'ratio', 'Share of the ball''s lateral position he follows — ball side, still central.'),
 ('concept', 'libero', 'lateral_max_m',      20,  'm',   'He never drifts wider than this.'),
 ('concept', 'libero', 'long_ball_lead_s',   0.8, 's',   'A long ball toward our goal: he runs to where it will be this far ahead.'),
 ('concept', 'libero', 'long_ball_height_m', 1,   'm',   'Ball higher than this and heading our way = a long ball.'),
 -- cover-shadow press [Bielsa / Klopp: press the carrier on the pass you cut]
 ('concept', 'cover-shadow', 'deep_x_m',         15,  'm', 'Carrier at least this far into THEIR half = building out from the back.'),
 ('concept', 'cover-shadow', 'handover_m',       3.5, 'm', 'Closer than this the normal press takes over.'),
 ('concept', 'cover-shadow', 'gap_m',            2.5, 'm', 'Point on the carrier→receiver lane the 9 runs to.'),
 ('concept', 'cover-shadow', 'lane_width_m',     25,  'm', 'Only receivers within this distance of the centre line count (the 6, the 8).'),
 ('concept', 'cover-shadow', 'receiver_ahead_m', 3,   'm', 'A receiver must be at least this far ahead of the carrier.'),
 -- line step [Sacchi: palla coperta / palla scoperta; same rule in the FA,
 -- KNVB and DFB back-four models]
 ('concept', 'line-step', 'step_behind_m',     12, 'm',   'Covered ball: the line steps up to this far behind the ball.'),
 ('concept', 'line-step', 'receive_radius_m',  6,  'm',   'An opponent this close to a moving ball is about to receive it.'),
 ('concept', 'line-step', 'pressure_radius_m', 3,  'm',   'A teammate this close to the ball player = he is under pressure (covered).'),
 ('concept', 'line-step', 'moving_speed_mps',  4,  'm/s', 'A free ball faster than this is travelling (covered) unless a free receiver faces forward.')
ON CONFLICT (owner, code, param) DO NOTHING;

-- ── Roles. Lighthouse APSL [Bielsa]: the free CB is also the libero; the
-- 9 (the starting ST) presses on a cover shadow.
INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
SELECT c.team_id, c.shirt, 'libero', 95
  FROM game_demo_player_concepts c JOIN game_demo_teams t ON t.id = c.team_id
 WHERE t.name = 'Lighthouse APSL' AND c.concept = 'cover' AND c.rating = 95
ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating;

INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
SELECT p.team_id, p.shirt, 'cover-shadow', 90
  FROM game_demo_players p JOIN game_demo_teams t ON t.id = p.team_id
 WHERE t.name = 'Lighthouse APSL' AND p.lineup_slot IS NOT NULL AND p.position = 'ST'
ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating;

-- Both teams step their line at a semi-pro understanding (68 = the semipro
-- band's quality, core::defaultRatings) — every outfield player.
INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
SELECT p.team_id, p.shirt, 'line-step', 68
  FROM game_demo_players p JOIN game_demo_teams t ON t.id = p.team_id
 WHERE t.name IN ('Lighthouse APSL', 'Ukrainian Nationals') AND p.position <> 'GK'
ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating;
