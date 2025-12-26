-- Lighthouse Old Timers Club Liga 2 - Team GroupMe Groups (Junction)

INSERT INTO team_groupme_groups (id, team_id, groupme_group_id, is_primary)
VALUES
  ('71284090-a741-48fc-84a6-44a57e40d49e', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '8a0cbac3-5948-4b0b-89a8-82e9b97e1f7a', true)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  is_primary = EXCLUDED.is_primary
;

