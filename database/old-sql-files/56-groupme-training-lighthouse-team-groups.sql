-- Training Lighthouse - Team GroupMe Groups (Junction)

INSERT INTO team_groupme_groups (id, team_id, groupme_group_id, is_primary)
VALUES
  ('2fa69fa0-c9ed-4ce2-8682-b7cf54fd3000', '3ee933c4-3ecc-4478-8737-b5a148fcebc7', '42d08e9d-1498-41c0-8538-b12f4e3663c7', true)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  is_primary = EXCLUDED.is_primary
;

