-- Lighthouse Old Timers Club Liga 2 - GroupMe Groups

INSERT INTO groupme_groups (id, groupme_group_id, name, team_id, sport_division_id, description, image_url)
VALUES
  ('8a0cbac3-5948-4b0b-89a8-82e9b97e1f7a', '109786278', 'Lighthouse Old Timers Club Liga 2', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '6362c82a-4383-4d2f-8ecc-8b0e87ab1788', NULL, 'https://i.groupme.com/200x200.png.11c354c3f2f347c9b5c649588413cb11')
ON CONFLICT (id) DO UPDATE SET
  groupme_group_id = EXCLUDED.groupme_group_id,
  name = EXCLUDED.name,
  team_id = EXCLUDED.team_id,
  sport_division_id = EXCLUDED.sport_division_id,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url
;

