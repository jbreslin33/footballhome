-- 1838 (2026-11-24) — 🔺 #apsl-pyramid: the Concacaf Champions Cup over MLS, and a
-- standards box under every pro division.
--
-- Owner: "put pls in between eadch pro level" · "each pro level and have the link to to pls
-- then to leage avoe" · "above mls put concacaf champtions league".
--
-- pro_league_tiers.by_standards — true: the level is entered by meeting U.S. Soccer's
-- Professional League Standards (Divisions I–III), so the page draws the standards box under
-- it and ties the leagues below to the box and the box to the level.  false: the level is
-- reached by results, no box — the leagues below are tied straight to it.
-- Tier 0 = the continental cup MLS clubs qualify for.  Its name is today's: Concacaf
-- Champions Cup (the Champions League until 2023).  A knockout cup — no table, no feed.
ALTER TABLE pro_league_tiers ADD COLUMN IF NOT EXISTS by_standards boolean NOT NULL DEFAULT true;

INSERT INTO pro_league_tiers (tier, label, by_standards)
VALUES (0, 'Continental cup — clubs qualify by results', false)
ON CONFLICT (tier) DO NOTHING;

INSERT INTO pro_leagues (tier, name, sort_order)
VALUES (0, 'Concacaf Champions Cup', 1)
ON CONFLICT (name) DO NOTHING;
