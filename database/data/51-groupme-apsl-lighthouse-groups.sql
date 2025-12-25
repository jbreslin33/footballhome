-- APSL Lighthouse - GroupMe Groups

INSERT INTO groupme_groups (id, groupme_group_id, name, team_id, sport_division_id, description, image_url)
VALUES
  ('53dc80a8-5631-484e-81b6-c632d8a04f95', '109785985', 'APSL Lighthouse', 'a16e9445-9bed-4fe6-804d-e77c56258610', NULL, NULL, 'https://i.groupme.com/225x224.png.3aac206764f845238bc5e6e9e2683e70')
ON CONFLICT (id) DO UPDATE SET
  groupme_group_id = EXCLUDED.groupme_group_id,
  name = EXCLUDED.name,
  team_id = EXCLUDED.team_id,
  sport_division_id = EXCLUDED.sport_division_id,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url
;

