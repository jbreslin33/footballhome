-- 1527 (2026-11-19) — A call-down is decided by the official rosters.
--
-- Owner: "just make sure there is chedck on liga 1 games taht we are not
-- suing more than 2 apsl guys that are not on liga 1 roster. as that is the
-- leagu rule" → "so you should show me a tally of how many bench and
-- starters i have like that" → "or flag them as call downs and warn if 3 of
-- more".
--
-- The mig 616/617 cap counted "on the FH APSL team and on no FH team tagged
-- on the game" — so Caleb Rojas and Armando Pena, on the FH Liga 1 team but
-- On Roster only for APSL, were never counted.  Now:
--
--   fh_calldown_from(team, person) → the cap's from-team when the person is
--   NOT On Roster on the team's own official roster but IS On Roster on the
--   from-team's (APSL Active or APSL Reserve); NULL otherwise.
--
-- Read by the lineup save, the event caps payload (used), and the team
-- roster payload (calldownFrom) so Game Center flags ⬇ on the box, tallies
-- "⬇ Call-downs n/2" and warns (asks) at the 3rd — a warning, not a block.

BEGIN;

CREATE OR REPLACE FUNCTION fh_calldown_from(p_team_id integer, p_person_id integer)
RETURNS integer LANGUAGE sql STABLE AS $$
  SELECT c.from_team_id
    FROM team_invite_caps c
   WHERE c.to_team_id = p_team_id
     AND NOT EXISTS (SELECT 1 FROM official_roster_names n
                       JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active
                      WHERE s.team_id = p_team_id AND n.person_id = p_person_id)
     AND EXISTS (SELECT 1 FROM official_roster_names n
                   JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active
                  WHERE (s.team_id = c.from_team_id OR s.games_team_id = c.from_team_id)
                    AND n.person_id = p_person_id)
   ORDER BY c.id
   LIMIT 1
$$;
COMMENT ON FUNCTION fh_calldown_from(integer, integer) IS
  'mig 1526: the team_invite_caps from-team when this person is not On Roster on the team''s own official roster but is on the from-team''s (APSL Active/Reserve) — a call-down for the league cap. NULL = not a call-down.';

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.cat, v.label, v.kind, v.tier, v.body, v.ord, true
  FROM (VALUES
    ('Event Center', 'event_center', 'card_calldowns',
     'Game card (coaches): call-downs in the squad ({n}, {max}, {team})', '⬇ {team} call-downs {n}/{max}', 908),
    ('Event Center', 'event_center', 'card_calldowns_over',
     'Game card (coaches): over the call-down cap', '⚠ {team} call-downs {n}/{max} — league max is {max}', 909),
    ('Event Center', 'event_center', 'calldown_confirm',
     'Game Center: placing one call-down too many — confirm', 'League rule: at most {max} {team} call-downs in the squad. This makes {n}. Place anyway?', 910),
    ('Eligibility', 'eligibility', 'lineup_note_calldown',
     'Live card box: this player is a call-down', '⬇ call-down', 40)
  ) AS v(cat, kind, tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);

COMMIT;
