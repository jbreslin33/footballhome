-- Lighthouse Boys Club Liga 1 - GroupMe Groups

INSERT INTO groupme_groups (id, groupme_group_id, name, description, image_url)
VALUES
  ('cdae59d3-8bea-44f8-8737-c6205861600b', '109786182', 'Lighthouse Boys Cub Liga 1', NULL, 'https://i.groupme.com/225x225.jpeg.54b8c9e7280243cca0924c99918504b7')
ON CONFLICT (id) DO UPDATE SET
  groupme_group_id = EXCLUDED.groupme_group_id,
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url
;

