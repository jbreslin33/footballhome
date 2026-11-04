-- 1035: U19 (team 932) retired; Sheldon Rhoden out of youth as a player
-- (owner 2026-11-04: "get rid of u19 and put the players on u12 if any",
-- "actually sheldon is adults lol", "take him out of youth").
--   • U19's last player was Sheldon (22433, 18, APSL) — nobody moves to
--     U12 (the six 13-year-olds went there in mig 1034).
--   • Sheldon's youth player rows end: U19 (932) and winter U18 (944).
--     His Men's / Cup rows and his youth COACH rows (U8/U10/U12) stay.
--   • U19's 7 coach rows end; every one also coaches U8, U10 and U12.
--   • Its 152 upcoming live events (3014 future links counting deleted
--     calendar copies) are the shared Grades 3-10 practices, which
--     already carry U10 (913) and U12 (914); U19's link to them is dropped.
--   • The "u19 / u16 in-house / intramural" calendar tags point at U12.
--   • teams.is_active = false (as the mig 899 merges); fh_youth_place
--     already skipped it (mig 1034, game teams only).

BEGIN;

UPDATE team_persons SET removed_at = now(), removed_reason = 'admin_remove',
       removed_details = jsonb_build_object('mig', 1035, 'why', 'adult, not youth')
 WHERE person_id = 22433 AND team_id IN (932, 944) AND removed_at IS NULL;

UPDATE team_persons SET removed_at = now(), removed_reason = 'team_merge',
       removed_details = jsonb_build_object('mig', 1035, 'to_team_id', 914)
 WHERE team_id = 932 AND removed_at IS NULL;

UPDATE team_coaches SET ended_at = now() WHERE team_id = 932 AND ended_at IS NULL;

DELETE FROM fh_event_teams fet USING fh_events fe, gcal_events ge
 WHERE fet.team_id = 932 AND fe.id = fet.fh_event_id AND ge.id = fe.gcal_event_id
   AND ge.starts_at > now();

UPDATE gcal_team_aliases SET team_id = 914, notes = COALESCE(notes, '') || ' · U19 retired (mig 1035)'
 WHERE team_id = 932;

UPDATE teams SET is_active = false WHERE id = 932;

COMMIT;
