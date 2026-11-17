-- No more NEEDS DROP (owner 11/17 "take away needs drops from all").
-- Possible Drop / Pending Drop leave every league's status dropdown, and
-- the one man holding one (Lucca Santos, Possible Drop on L1 + APSL
-- Reserves — he is on both official lists) goes back to On Roster.
-- The roster_statuses rows stay so history/joins keep their names.
UPDATE team_persons
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE roster_status_id IN (SELECT id FROM roster_statuses WHERE code IN ('possible_drop', 'pending_drop'));
UPDATE team_coaches
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE roster_status_id IN (SELECT id FROM roster_statuses WHERE code IN ('possible_drop', 'pending_drop'));
DELETE FROM league_roster_statuses
 WHERE roster_status_id IN (SELECT id FROM roster_statuses WHERE code IN ('possible_drop', 'pending_drop'));
