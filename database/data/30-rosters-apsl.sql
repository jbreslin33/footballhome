-- APSL Rosters (Internal)

INSERT INTO team_players (team_id, player_id, jersey_number, is_active, joined_date, left_date, notes)
VALUES
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '40ec02c5-fb91-4291-8ceb-9bc9c05ff016', '8', true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '4f521fde-a21a-47a0-8119-fa9620588c85', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '62b437b5-8f56-4656-8302-91d73dfcdf2d', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '326afaa9-78f2-4afd-8bfe-54fcd609011f', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '9cbae92e-dc47-4652-8625-5290c0ccbc57', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '873cbd3f-e5aa-43d2-81d5-b3e8728a54b0', '1', true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'aa1fa5e4-b5bb-4564-8d36-06dbd4d49fac', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'cbf1a0b4-2a27-4006-8db1-9ad86b1521a4', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'a12f890e-be4b-49f0-8d67-95d7fdd805f6', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'fcb79856-84dc-4262-8ab8-99b0d7e608bc', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '29de4344-124c-47bc-8ca6-cf5415bca661', '2', true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'f0c2c317-a6ad-4439-8009-0f1398874a34', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '2ecf11c2-efd4-4e92-8f25-2332454ce35d', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '8c8a0777-0fd6-4cfe-84b9-b9663da89ac7', '2', true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '7fcb45b4-5984-4091-8023-62aaab73faed', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '0fdb3031-94ab-438e-826e-b2e2ce92eb4d', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'b1a92aed-cc81-4765-8b98-c8010da51080', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '978312f0-43c5-4d3c-808b-6520582ff7b8', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '69b58dbe-3d56-4d95-8fa3-30ac086aa5e0', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'b7c238e5-1f2a-4f3e-8db7-b0f828cda76c', '1', true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '5a3a94d3-8f8f-46f5-8a4d-18f144d68c38', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'a942a402-d84b-4c5e-804a-22c5e2467b67', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'f9111610-235d-4965-8ba9-2a21e666d7a7', '2', true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'f97f58e8-6a44-4b15-83be-c668409c4259', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'e7d338ff-ca88-4165-8f06-3ad8f5d6f97e', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '1920c979-2534-4cca-87d0-6b24ddd2b482', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', '289ca5c6-502b-4aaa-89c1-0c1e45f036dd', NULL, true, NULL, NULL, NULL),
  ('a16e9445-9bed-4fe6-804d-e77c56258610', 'dbb43302-2369-4fe9-8d59-7c5601efe207', NULL, true, NULL, NULL, NULL)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  player_id = EXCLUDED.player_id,
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active,
  joined_date = EXCLUDED.joined_date,
  left_date = EXCLUDED.left_date,
  notes = EXCLUDED.notes
;

