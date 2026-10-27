-- 747 (2026-10-27) — game: defend-your-man's 3 rules weighted by coach and
-- by third of the pitch (game/DESIGN.md §8.66, G4.68).
--
-- James 10/27: "yes that is a general rule for bielsa but i would say all
-- coaches. but its calibrated for the 3 differently depending on coach and
-- part of field. and even level of player to be able to lets say intercept"
-- / "do both".
--
-- One row per (model, third, rule): how often (0-100) the marker plays that
-- rule when it's on. Missing = the parent model's row, else 100. A miss
-- drops a rung: no interception → arrive so he can't turn; no "no turn" →
-- contain. The player's level still gates all of it (min(ability, demand)
-- on defend-your-man, and the race decides whether he CAN intercept).

CREATE TABLE IF NOT EXISTS game_model_ladder (
    model_id integer NOT NULL REFERENCES game_models(id) ON DELETE CASCADE,
    zone     text    NOT NULL CHECK (zone IN ('own', 'middle', 'their')),
    rung     text    NOT NULL CHECK (rung IN ('intercept', 'no_turn', 'contain')),
    weight   integer NOT NULL CHECK (weight BETWEEN 0 AND 100),
    note     text    NOT NULL DEFAULT '',
    PRIMARY KEY (model_id, zone, rung)
);

-- Lighthouse (both tactics inherit): in our own third a failed interception
-- is a man through on goal, so he goes for it half the time and otherwise
-- stays goal-side so his man can't turn. Middle and their third: everything.
-- Starting numbers for James to set.
INSERT INTO game_model_ladder (model_id, zone, rung, weight, note)
SELECT m.id, v.zone, v.rung, v.weight, v.note FROM (VALUES
 ('own', 'intercept', 50, 'Our third: a missed interception is a man through — go for it only half the time; else no turn.')
) AS v(zone, rung, weight, note)
JOIN game_models m ON m.name = 'Lighthouse APSL'
ON CONFLICT (model_id, zone, rung) DO NOTHING;

-- Shadow the line (mig 745): our full-back CAN step up with a winger who
-- drops short — he just won't get tight, so he still leans on our winger's
-- shadow, stays in reach to help, and isn't in a better spot for our
-- transition by chasing (James 10/27: "our fb can step its just that he is
-- gonna have trouble getting tight so he stil relys on cover shadow from
-- our winger"). Was 0 (level with our highest centre-back).
UPDATE game_model_params SET value = 5,
       note = 'Playing off, he steps up at most this far past our highest centre-back — he can step, he won''t get tight, our winger keeps the shadow.'
 WHERE owner = 'concept' AND code = 'play-off-long-ball' AND param = 'ahead_of_line_m';
