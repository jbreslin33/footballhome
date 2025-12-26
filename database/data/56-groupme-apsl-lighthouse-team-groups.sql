-- APSL Lighthouse - Team GroupMe Groups (Junction)

INSERT INTO team_groupme_groups (id, team_id, groupme_group_id, is_primary)
VALUES
  ('e9493c9e-a767-497d-8c33-eb7acbe2534c', 'a16e9445-9bed-4fe6-804d-e77c56258610', '53dc80a8-5631-484e-81b6-c632d8a04f95', true)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  is_primary = EXCLUDED.is_primary
;

