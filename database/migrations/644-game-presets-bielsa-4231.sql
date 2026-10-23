-- 644 (2026-10-22) — game: the Ukies play a researched 4-2-3-1; Lighthouse
-- plays Bielsa (game/DESIGN.md §8.30).
--
-- James: "look up how a 4231 defense and offense works for ukies. use
-- bielsa system of tactics for lh".
--
-- Presets are concept ratings (game_style_preset_ratings, mig 630) that a
-- team WEARS (game_demo_teams.style_preset, mig 631); per-player rows (mig
-- 639/642: the libero, the cover-shadow 9, line-step 68) still apply on
-- top, so roles survive. Every row cites its source.

-- ── Bielsa, completed. Mig 630 seeded his five headline dials; these are
-- the rest of the model as published (man-oriented duels all over the
-- pitch with a spare at the back, aggressive counter-pressing, vertical
-- attacks after the regain, width + overlaps, combinations, runs beyond).
INSERT INTO game_style_preset_ratings (preset_id, concept, rating, source)
SELECT p.id, v.concept, v.rating, v.source
  FROM game_style_presets p,
       (VALUES
        ('marking',        90, 'Bielsa: organised marking everywhere, each player responsible for a man (ekkonocoaching.com "Marcelo Bielsa: El Loco tactical evolution").'),
        ('counter-attack', 85, 'Bielsa: vertical attack immediately after the regain, forwards running into free space (ekkonocoaching.com).'),
        ('runs',           90, 'Bielsa: constant runs beyond the last line — the 9 and the far winger attack depth.'),
        ('give-and-go',    85, 'Bielsa: rehearsed combinations / wall passes to break man-marking (pattern play "automatisms").'),
        ('support',        85, 'Bielsa: short support around the ball so the vertical pass always has a next option.'),
        ('intercept',      80, 'Bielsa: man-oriented defenders anticipate and step in front of their man on the pass.'),
        ('double-team',    75, 'Bielsa: wide traps — the touchline as an extra marker once the ball goes wide.'),
        ('safe-pass',      45, 'Bielsa: verticality over security — accepts losing the ball forward (risk-taking model).')
       ) AS v(concept, rating, source)
 WHERE p.name = 'Bielsa'
ON CONFLICT (preset_id, concept) DO UPDATE SET rating = EXCLUDED.rating, source = EXCLUDED.source;

-- ── The classic 4-2-3-1, as the Premier League's tactics explainer and
-- coaching sources describe it: a double pivot screening the back four
-- (one destroyer, one distributor), full-backs tucking in, CBs on the
-- strikers, the 10 supporting the lone 9, wide players cutting inside;
-- out of possession a compact mid-block with one pivot stepping to press.
INSERT INTO game_style_presets (name, sort_order, note)
SELECT 'Classic 4-2-3-1', COALESCE(max(sort_order), 0) + 1,
       'Double pivot screening a zonal back four; 10 behind a lone 9; compact mid-block (Premier League "The 4-2-3-1: football tactics explained").'
  FROM game_style_presets
 WHERE NOT EXISTS (SELECT 1 FROM game_style_presets WHERE name = 'Classic 4-2-3-1');

INSERT INTO game_style_preset_ratings (preset_id, concept, rating, source)
SELECT p.id, v.concept, v.rating, v.source
  FROM game_style_presets p,
       (VALUES
        ('man-mark',       0,  'Zonal back four: CBs pick up the strikers in their zone, no man-following (premierleague.com/news/4243785).'),
        ('marking',        70, 'CBs pick up the opposing strikers; full-backs take wide threats one-on-one (premierleague.com/news/4243785).'),
        ('cover',          80, 'The double pivot guards the zone in front of the back four (premierleague.com/news/4243785).'),
        ('balance',        80, 'Full-backs tuck in; the far pivot shifts across to cover (premierleague.com/news/4243785).'),
        ('intercept',      75, 'Pivots intercept, win duels and pick up second balls (Coaches'' Voice, 4-2-3-1 positional functions).'),
        ('double-team',    65, 'One pivot steps up to press alongside the 10 or a wide player (premierleague.com/news/4243785).'),
        ('push-up',        60, 'Compact mid-block rather than a high line — five midfielders deny central overloads (sportsessionplanner.com 4-2-3-1).'),
        ('counter-press',  60, 'Pressing is why the shape spread (Lillo), but the pivots also protect the back line (premierleague.com/news/4243785).'),
        ('jockey-angle',   70, 'Full-backs one-on-one wide: show the winger the line (premierleague.com/news/4243785).'),
        ('restraint',      70, 'Zonal block holds position rather than diving in (sportsessionplanner.com 4-2-3-1).'),
        ('outlet',         75, 'CBs pass into midfield — the pivots occupy that space (premierleague.com/news/4243785).'),
        ('safe-pass',      70, 'Build through the distributor pivot, one drops to make a numerical edge (sportmonks.com 4-2-3-1).'),
        ('support',        80, 'The 10 supports the lone striker as the main central threat (premierleague.com/news/4243785).'),
        ('runs',           70, 'The lone 9 attacks the last line with the 10 arriving behind him.'),
        ('width',          55, 'Wide midfielders often cut inside on their unnatural side — width comes from the full-backs (premierleague.com/news/4243785).'),
        ('counter-attack', 70, 'In positive transition the three attacking midfielders + full-backs make it strongly attacking (sportsessionplanner.com IPI9i).'),
        ('verticality',    50, 'Direct balls forward are an option, but the default is through the pivots (premierleague.com/news/4243785).')
       ) AS v(concept, rating, source)
 WHERE p.name = 'Classic 4-2-3-1'
ON CONFLICT (preset_id, concept) DO UPDATE SET rating = EXCLUDED.rating, source = EXCLUDED.source;

UPDATE game_demo_teams SET style_preset = 'Bielsa'          WHERE name = 'Lighthouse APSL';
UPDATE game_demo_teams SET style_preset = 'Classic 4-2-3-1' WHERE name = 'Ukrainian Nationals';
