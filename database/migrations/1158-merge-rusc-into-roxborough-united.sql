-- 1158: "RUSC" (club 63) is Roxborough United (club 9).  The PPR team
-- contacts import (club_files 52, 2026-10-24) minted club 63 from the
-- sheet's short name, so its 8 coach contacts (incl. the U12 Boys Trash
-- Pandas coach) never showed in the Game Center contact panel for
-- Roxborough games, which point at club 9.  One canonical club; RUSC
-- becomes an alias (owner 2026-11-07).
BEGIN;

UPDATE club_contacts         SET club_id = 9, updated_at = now() WHERE club_id = 63;
UPDATE club_contact_messages SET club_id = 9                     WHERE club_id = 63;
UPDATE club_aliases          SET club_id = 9,
       notes = 'merged from club 63 (PPR contacts import) — mig 1158'
 WHERE club_id = 63;
UPDATE clubs SET is_active = false, updated_at = now() WHERE id = 63;

COMMIT;
