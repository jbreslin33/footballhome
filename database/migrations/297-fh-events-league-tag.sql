-- 297 — Adds fh_events.league: a free-text `League:` tag parsed from the
-- gcal event description by gcal-classify.js's DSL parser (same pattern
-- as the existing Opponent:/Notes: tags — see §6.1.5 in that file).
--
-- Why (2026-08-22, owner directive): "apsl should be apsl delawere
-- river... unless we need a league: var in desc for gcal which i think
-- we do lol. that would inform a lot of things!" — SocialPostCard.js's
-- Instagram post graphic was guessing CASA vs APSL and Liga 1 vs Liga 2
-- from the opponent's scraped team name via regex, which is fragile.
-- This tag is the authoritative source instead: ops types e.g.
-- "League: CASA Select Liga 1" once in the calendar event, and every
-- view that needs the league (post graphics today, potentially more
-- later) reads the same field instead of independently guessing.

ALTER TABLE fh_events ADD COLUMN IF NOT EXISTS league TEXT;
