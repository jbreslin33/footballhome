-- Lighthouse Boys Club Liga 1 - Sport Division GroupMe Groups (Junction)

INSERT INTO sport_division_groupme_groups (id, sport_division_id, groupme_group_id, is_primary)
VALUES
  ('b87f356f-8b0a-4232-8ecf-b949aeffb8d9', '105ab0d0-6d89-4e8b-8c4b-ce637c610e1c', 'cdae59d3-8bea-44f8-8737-c6205861600b', true)
ON CONFLICT (id) DO UPDATE SET
  sport_division_id = EXCLUDED.sport_division_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  is_primary = EXCLUDED.is_primary
;

