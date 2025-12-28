-- Training Lighthouse - GroupMe Groups

INSERT INTO groupme_groups (id, groupme_group_id, name, description, image_url)
VALUES
  ('42d08e9d-1498-41c0-8538-b12f4e3663c7', '108640377', 'Training Lighthouse', NULL, 'https://i.groupme.com/225x225.png.9f0563d0e09247b59933436ade6d6637')
ON CONFLICT (id) DO UPDATE SET
  groupme_group_id = EXCLUDED.groupme_group_id,
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url
;

