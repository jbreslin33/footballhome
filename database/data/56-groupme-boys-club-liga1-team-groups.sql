-- Lighthouse Boys Club Liga 1 - Team GroupMe Groups (Junction)

INSERT INTO team_groupme_groups (id, team_id, groupme_group_id, is_primary)
VALUES
  ('ffed85f5-50c2-4a32-81f7-c7dcc7b187b8', '57d88568-993d-4411-8aa3-6244ca7ff704', 'cdae59d3-8bea-44f8-8737-c6205861600b', true)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  is_primary = EXCLUDED.is_primary
;

