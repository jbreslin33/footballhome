-- 794 (2026-10-28) — game: the sheet's tier thresholds and the body's centre
-- (game/DESIGN.md §8.81, G4.83; follows mig 793).
--
-- James 10/28: "diff between starters, bench and deep bench should be
-- significant at this level". A man's tier is read off his club team's
-- lineups as shares of its matches: STARTER = starts 35%+ of them (11 of
-- Lighthouse APSL's 47 over 11 lineups — an XI), BENCH = in the matchday
-- squad 25%+ (21), DEEP BENCH = the rest (15). The body (pace,
-- acceleration, deceleration, agility) centres on 60 at every level — pace
-- is not in a team's record (load_squads.py's PACE_BASE, kept).

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('sheet', 'tier', 'starter_start_share', 0.35, 'share', 'Starter: starts at least this share of his club team''s lineup matches.'),
  ('sheet', 'tier', 'bench_app_share', 0.25, 'share', 'Bench: in the matchday squad for at least this share; below it, deep bench.'),
  ('sheet', 'range', 'physical_base', 60, 'pts', 'The body''s attributes centre here at every level (team quality is a record of football, not of speed).')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
