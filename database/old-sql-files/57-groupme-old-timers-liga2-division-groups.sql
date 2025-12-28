-- Lighthouse Old Timers Club Liga 2 - Sport Division GroupMe Groups (Junction)

INSERT INTO sport_division_groupme_groups (id, sport_division_id, groupme_group_id, is_primary)
VALUES
  ('e095f81c-41d7-46fd-862a-25befbf0a6b3', '6362c82a-4383-4d2f-8ecc-8b0e87ab1788', '8a0cbac3-5948-4b0b-89a8-82e9b97e1f7a', true)
ON CONFLICT (id) DO UPDATE SET
  sport_division_id = EXCLUDED.sport_division_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  is_primary = EXCLUDED.is_primary
;

