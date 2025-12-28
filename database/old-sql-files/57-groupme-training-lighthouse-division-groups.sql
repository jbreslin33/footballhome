-- Training Lighthouse - Sport Division GroupMe Groups (Junction)

INSERT INTO sport_division_groupme_groups (id, sport_division_id, groupme_group_id, is_primary)
VALUES
  ('b4b576d4-5aad-4bc6-8dbd-3a5bb32cc37d', '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9', '42d08e9d-1498-41c0-8538-b12f4e3663c7', true)
ON CONFLICT (id) DO UPDATE SET
  sport_division_id = EXCLUDED.sport_division_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  is_primary = EXCLUDED.is_primary
;

