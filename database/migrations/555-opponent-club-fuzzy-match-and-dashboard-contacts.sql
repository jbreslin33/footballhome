-- 555 (2026-10-09) — the opponent's contact on every game of the
-- #dashboard Game Center cell, and a forgiving opponent-name match.
-- Owner: "on game center we should show opponent contact info … for each
-- game".
--
-- The calendar says "Real Central NJ" and "Philadelphia Select SC"; the
-- clubs rows say "Real Central NJ Soccer" and "Philadelphia SC Select", and
-- no alias bridged them, so the 📇 panel found nothing for either game.
-- fh_opponent_club(text) resolves opponent text to a club: exact alias,
-- exact name, then the same with the filler words (SC, FC, Soccer, Club,
-- APSL, CASA, …) and punctuation stripped.  Game Center's panel
-- (OpponentsController::loadMatch) and the dashboard both use it; an alias
-- row still wins, so #logos keeps the last word.
CREATE OR REPLACE FUNCTION fh_club_name_key(p_text TEXT) RETURNS TEXT
LANGUAGE sql IMMUTABLE AS $$
    SELECT NULLIF(regexp_replace(
             regexp_replace(LOWER(COALESCE(p_text, '')),
                            '\m(sc|fc|afc|cf|soccer|football|club|united|utd|apsl|casa|ppr|the)\M', ' ', 'g'),
             '[^a-z0-9]', '', 'g'), '')
$$;
CREATE OR REPLACE FUNCTION fh_opponent_club(p_text TEXT) RETURNS INTEGER
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(
        (SELECT club_id FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM(p_text)) LIMIT 1),
        (SELECT id FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM(p_text)) ORDER BY id LIMIT 1),
        (SELECT club_id FROM club_aliases WHERE fh_club_name_key(alias) = fh_club_name_key(p_text) AND fh_club_name_key(p_text) IS NOT NULL LIMIT 1),
        (SELECT id FROM clubs WHERE fh_club_name_key(name) = fh_club_name_key(p_text) AND fh_club_name_key(p_text) IS NOT NULL ORDER BY id LIMIT 1))
$$;
COMMENT ON FUNCTION fh_opponent_club(TEXT) IS 'mig 555: opponent text → clubs.id — alias, exact name, then both with filler words (SC/FC/Soccer/Club/APSL/CASA…) and punctuation stripped.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dashboard', l, 'dashboard', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('gc_contact_none', 'Game Center cell — opponent has no contact on file', 'no opponent contact on file', 872)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'dashboard' AND m.tier = v.t);
