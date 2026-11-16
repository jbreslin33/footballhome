-- 1408 (2026-11-16): Denver Brown (person 22782) moves from the ❄️ U10 winter
-- team (942) to the ❄️ U11 winter team (946). Owner: the parent can't make
-- the earlier U10 practice. Same as the ⚽ "Move here" pill: the old row is
-- closed (removed_at + admin_remove) and the new one copies its flags. He
-- keeps his fall U10 (913) and U10 Travel Winter (965) rows.

UPDATE team_persons
   SET removed_at = now(), removed_reason = 'admin_remove'
 WHERE person_id = 22782 AND team_id = 942 AND removed_at IS NULL;

INSERT INTO team_persons (team_id, person_id, on_roster, invite_only, call_in, squad_status_id)
SELECT 946, 22782, false, true, false, 1
 WHERE NOT EXISTS (SELECT 1 FROM team_persons
                    WHERE team_id = 946 AND person_id = 22782 AND removed_at IS NULL);
