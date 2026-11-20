-- 1600 (2026-11-20) — Women are all Regulars: never answering an RSVP
-- doesn't park a woman anywhere.
--
-- Owner: "why are there 4 inactive women lol" → "women have no liga 1.
-- they are tri county. all of them. all active" → "all regulars" →
-- "they still say inactive. there should be no inactive right? isn't it
-- all reserves now for all teams?"
--
-- fh_person_needs_onboard (mig 1520) drives 👋 Not chasing everywhere —
-- the event / game cards (→ 🪑 Reserves), Remind all, roll-call
-- stragglers.  It now answers false for a person whose teams are all in
-- sections that don't park never-answered players
-- (club_sections.parks_never_answered, false for Womens), so the 4 Tri
-- County women who have never answered sit in No response and get
-- reminders like everyone else.

BEGIN;

ALTER TABLE club_sections
  ADD COLUMN IF NOT EXISTS parks_never_answered boolean NOT NULL DEFAULT true;
COMMENT ON COLUMN club_sections.parks_never_answered IS
  'mig 1600: does a player who never answered an RSVP leave No response for 🪑 Reserves (Not chasing)? false = everyone is a Regular (Womens).';
UPDATE club_sections SET parks_never_answered = false WHERE code = 'W';

CREATE OR REPLACE FUNCTION fh_person_needs_onboard(p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT NOT EXISTS (SELECT 1 FROM fh_event_rsvps r
                      WHERE r.person_id = p_person_id AND r.created_via = 'manual')
     AND NOT (EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = p_person_id AND tp.removed_at IS NULL)
              AND NOT EXISTS (SELECT 1 FROM team_persons tp
                                JOIN teams t ON t.id = tp.team_id
                                LEFT JOIN club_sections cs ON cs.id = t.club_section_id
                               WHERE tp.person_id = p_person_id AND tp.removed_at IS NULL
                                 AND COALESCE(cs.parks_never_answered, true)))
$$;
COMMENT ON FUNCTION fh_person_needs_onboard(integer) IS
  'mig 1520/1600: never answered an RSVP himself or through a parent (standing defaults and admin overrides don''t count), and on at least one team whose section parks never-answered players (club_sections.parks_never_answered) — on the cards = 👋 Not chasing / 🪑 Reserves.';

COMMIT;
