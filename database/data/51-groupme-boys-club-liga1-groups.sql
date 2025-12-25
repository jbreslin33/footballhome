-- Lighthouse Boys Club Liga 1 - GroupMe Groups

INSERT INTO groupme_groups (id, groupme_group_id, name, team_id, sport_division_id, description, image_url)
VALUES
  ('cdae59d3-8bea-44f8-8737-c6205861600b', '109786182', 'Lighthouse Boys Cub Liga 1', '57d88568-993d-4411-8aa3-6244ca7ff704', '105ab0d0-6d89-4e8b-8c4b-ce637c610e1c', NULL, 'https://i.groupme.com/225x225.jpeg.54b8c9e7280243cca0924c99918504b7')
ON CONFLICT (id) DO UPDATE SET
  groupme_group_id = EXCLUDED.groupme_group_id,
  name = EXCLUDED.name,
  team_id = EXCLUDED.team_id,
  sport_division_id = EXCLUDED.sport_division_id,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url
;

