-- Needs Docs / Has Docs on every league (owner 2026-09-08: "all teams
-- should have needs docs. its standard for every league").
--
-- Migration 342 scoped the docs steps to the youth leagues on the
-- theory that birth certificate + headshot was a Parks & Rec thing.
-- The owner's call is that chasing documents is a step every league's
-- pipeline has, so the two statuses join every league's list.  The
-- adult pipeline now reads Needs Docs → Has Docs → Needs ITC → … and
-- the APSL man already tagged Needs Docs is simply on the list.
--
-- Also standard from here: a new league gets the docs steps by
-- default, so a later "add league" migration should copy this insert.
BEGIN;

INSERT INTO league_roster_statuses (league_id, roster_status_id)
SELECT l.id, rs.id
  FROM leagues l
 CROSS JOIN roster_statuses rs
 WHERE rs.code IN ('needs_docs', 'has_docs')
ON CONFLICT DO NOTHING;

UPDATE roster_statuses
   SET description = 'Documents not yet received — ask the player / parent (📄 DOCS)'
 WHERE code = 'needs_docs';
UPDATE roster_statuses
   SET description = 'Documents received — ready for the next roster step'
 WHERE code = 'has_docs';

DO $$
DECLARE bad TEXT;
BEGIN
    SELECT string_agg(l.name, ', ') INTO bad
      FROM leagues l
     WHERE NOT EXISTS (SELECT 1 FROM league_roster_statuses lrs
                         JOIN roster_statuses rs ON rs.id = lrs.roster_status_id
                        WHERE lrs.league_id = l.id AND rs.code = 'needs_docs')
        OR NOT EXISTS (SELECT 1 FROM league_roster_statuses lrs
                         JOIN roster_statuses rs ON rs.id = lrs.roster_status_id
                        WHERE lrs.league_id = l.id AND rs.code = 'has_docs');
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'Leagues missing a docs status: %', bad;
    END IF;
END $$;

COMMIT;
