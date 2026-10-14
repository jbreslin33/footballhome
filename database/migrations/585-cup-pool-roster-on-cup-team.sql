-- 585 (2026-10-14) — the USASA Cup container team (939, mig 567) carries a
-- real roster: the full men's pool (APSL + APSL Reserves + Liga 1), kept in
-- sync by trigger.  A cup game then behaves exactly like a league game —
-- roster-driven visibility, RSVP board pending counts, reminders, roll
-- call, Game Center cards, fines — with no invite special-casing.
-- Owner: "how about we treat it like an apsl game for rsvp eligibility.
-- reason is we can quickly add a guy who rsvps and drop a guy who is not
-- available and add him later … once they finalize the cup roster we can't
-- drop but can add to 30 so important to not have a guy on cup pool that
-- is unavailable this sunday."  (The submitted USASA sheet is the legal
-- squad and lives on #cup-roster; this DB pool is who gets asked.)
--
-- Supersedes the invite approach of migs 568/584: those open invites are
-- revoked below once the same people hold roster rows.  RSVPs already
-- given are untouched (fh_event_rsvps is keyed on person + event).

-- 1. Which teams feed the cup pool — data, not code (change by migration).
CREATE TABLE IF NOT EXISTS cup_pool_teams (
  team_id int PRIMARY KEY REFERENCES teams(id)
);
COMMENT ON TABLE cup_pool_teams IS
  'League teams whose active players are mirrored onto the USASA Cup container team (939) by fh_cup_pool_sync (mig 585).';

INSERT INTO cup_pool_teams (team_id)
SELECT t.id FROM teams t
 WHERE t.club_id = 134
   AND t.name IN ('Lighthouse Mens Club 1893',
                  'Lighthouse Mens Club APSL Reserves',
                  'Lighthouse Mens Club Liga 1')
ON CONFLICT (team_id) DO NOTHING;

-- 2. Seed: every currently active player on a pool team joins the cup team.
INSERT INTO team_persons (team_id, person_id)
SELECT (SELECT id FROM teams WHERE club_id = 134 AND name = 'USASA Cup'),
       tp.person_id
  FROM team_persons tp
  JOIN cup_pool_teams cpt ON cpt.team_id = tp.team_id
 WHERE tp.removed_at IS NULL
GROUP BY tp.person_id
HAVING NOT EXISTS (
    SELECT 1 FROM team_persons x
     WHERE x.team_id = (SELECT id FROM teams WHERE club_id = 134 AND name = 'USASA Cup')
       AND x.person_id = tp.person_id
       AND x.removed_at IS NULL);

-- 3. Keep it in sync: joining any pool team adds you to the cup pool;
--    leaving your LAST pool team removes you from it.  The cup team itself
--    is not a pool team, so the trigger never recurses.
CREATE OR REPLACE FUNCTION fh_cup_pool_sync() RETURNS trigger AS $$
DECLARE
  cup_team int := (SELECT id FROM teams WHERE club_id = 134 AND name = 'USASA Cup');
  pid int := COALESCE(NEW.person_id, OLD.person_id);
  new_in_pool bool := TG_OP <> 'DELETE'
                      AND EXISTS (SELECT 1 FROM cup_pool_teams c WHERE c.team_id = NEW.team_id);
  old_in_pool bool := TG_OP <> 'INSERT'
                      AND EXISTS (SELECT 1 FROM cup_pool_teams c WHERE c.team_id = OLD.team_id);
BEGIN
  IF cup_team IS NULL OR NOT (new_in_pool OR old_in_pool) THEN RETURN NULL; END IF;

  IF new_in_pool AND NEW.removed_at IS NULL THEN
    INSERT INTO team_persons (team_id, person_id)
    SELECT cup_team, pid
     WHERE NOT EXISTS (SELECT 1 FROM team_persons x
                        WHERE x.team_id = cup_team AND x.person_id = pid
                          AND x.removed_at IS NULL);
  ELSIF NOT EXISTS (SELECT 1 FROM team_persons tp
                     JOIN cup_pool_teams c ON c.team_id = tp.team_id
                    WHERE tp.person_id = pid AND tp.removed_at IS NULL) THEN
    UPDATE team_persons
       SET removed_at = now(), removed_reason = 'cup_pool_sync'
     WHERE team_id = cup_team AND person_id = pid AND removed_at IS NULL;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS cup_pool_sync ON team_persons;
CREATE TRIGGER cup_pool_sync
AFTER INSERT OR UPDATE OR DELETE ON team_persons
FOR EACH ROW EXECUTE FUNCTION fh_cup_pool_sync();

-- 4. The invite rows (migs 568/584) are redundant for anyone now rostered
--    on the cup team — revoke them so #my shows one card with role PLAYER,
--    not a duplicate 🎟 invite.
UPDATE fh_event_invites i
   SET revoked_at = now(),
       revoked_by_user_id = (SELECT id FROM users WHERE person_id = 1)
  FROM fh_events e
  JOIN gcal_events g ON g.id = e.gcal_event_id
 WHERE i.fh_event_id = e.id
   AND i.revoked_at IS NULL
   AND e.league ILIKE '%usasa%'
   AND (g.starts_at AT TIME ZONE 'America/New_York')::date = '2026-10-18'
   AND EXISTS (SELECT 1 FROM team_persons tp
                WHERE tp.team_id = (SELECT id FROM teams WHERE club_id = 134 AND name = 'USASA Cup')
                  AND tp.person_id = i.person_id
                  AND tp.removed_at IS NULL);
