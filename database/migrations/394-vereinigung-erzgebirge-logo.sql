-- 394 — Vereinigung Erzgebirge crest.
--
-- Owner 2026-09-21: "vereinigung erzgebirge sc logo" + the club badge.
-- The thesportsdb lookup found nothing (empty logo_url cached), so the
-- crest goes in by hand, same as 389/393: a local copy
-- (frontend/images/teams/logos/, corners cut away to the round badge)
-- keyed on fh_events.opponent, source 'manual'.
INSERT INTO opponent_logo_cache (opponent_text, logo_url, source)
VALUES ('Vereinigung Erzgebirge Majors', '/images/teams/logos/vereinigung-erzgebirge.png', 'manual')
ON CONFLICT (lower(btrim(opponent_text)))
DO UPDATE SET logo_url = EXCLUDED.logo_url, source = EXCLUDED.source, fetched_at = now();
