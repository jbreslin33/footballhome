-- Training Lighthouse - GroupMe Groups

INSERT INTO groupme_groups (id, groupme_group_id, name, team_id, sport_division_id, description, image_url)
VALUES
  ('42d08e9d-1498-41c0-8538-b12f4e3663c7', '108640377', 'Training Lighthouse', '3ee933c4-3ecc-4478-8737-b5a148fcebc7', '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9', NULL, 'https://i.groupme.com/225x225.png.9f0563d0e09247b59933436ade6d6637')
ON CONFLICT (id) DO UPDATE SET
  groupme_group_id = EXCLUDED.groupme_group_id,
  name = EXCLUDED.name,
  team_id = EXCLUDED.team_id,
  sport_division_id = EXCLUDED.sport_division_id,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url
;

