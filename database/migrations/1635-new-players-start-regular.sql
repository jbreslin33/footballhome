-- 1635 (2026-11-20) — Every new player starts a Regular: never answering
-- an RSVP no longer parks anyone under 🪑 Reserves, in any section.
--
-- Owner, on Asif Nifaz (Regular Liga 1, Reserve APSL) showing under
-- 🪑 Reserves on Saturday's practice card: "lets start any new player as a
-- reguluar on liga 1 or apsl same with youth until we have reason to
-- demote them".
--
-- club_sections.parks_never_answered (mig 1600, already false for Womens)
-- goes false for Mens, Boys and Girls, so fh_person_needs_onboard answers
-- false for everyone on a team: a never-answered player sits in
-- – No response, gets reminders and is named in roll calls like any other
-- Regular.  🪑 Reserves now = only a Reserves team status (set on #teams)
-- or an invite — the demotion is a person's call, never automatic.

BEGIN;

UPDATE club_sections SET parks_never_answered = false WHERE parks_never_answered;
ALTER TABLE club_sections ALTER COLUMN parks_never_answered SET DEFAULT false;
COMMENT ON COLUMN club_sections.parks_never_answered IS
  'mig 1600/1635: does a player who never answered an RSVP leave No response for 🪑 Reserves (Not chasing)? false everywhere since mig 1635 — every new player starts a Regular until someone demotes them.';

COMMIT;
