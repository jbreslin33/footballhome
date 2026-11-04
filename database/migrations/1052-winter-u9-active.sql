-- 1052: winter U9 (945) ACTIVE — six kids (owner 2026-11-04: "add the
-- following to u9 ACTIVE: almonte, bradham, jurnee, woods, tolbert,
-- gabriel").  Same as winter U10/U12 (migs 1048/1050): On Roster by hand.
-- ethan almonte 22630, Jamauri Bradham 22415, Jurnee Smith 22420, Tyreece
-- Woods 22636, Lee Tolbert 22280, Gabriel Rivera-Perez 22693.

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id = 945 AND removed_at IS NULL
   AND person_id IN (22630, 22415, 22420, 22636, 22280, 22693);
