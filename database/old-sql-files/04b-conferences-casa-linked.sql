-- CASA Divisions

INSERT INTO casa_divisions (id, casa_id, name, season, league_division_id)
VALUES
  ('e19d8804-80d8-4583-8433-dceac30b1b5b', 'philadelphia-liga-1', 'Philadelphia Liga 1', '2024', 'd5d544d1-1f35-4b7d-80e0-67c5fd63258f'),
  ('9d8d258c-7556-4935-81ce-779772234251', 'philadelphia-liga-2', 'Philadelphia Liga 2', '2024', '311fe53c-88df-4efe-8fa9-6f397992b826'),
  ('81207b70-69af-4446-8051-b53f66e294e9', 'boston-liga-1', 'Boston Liga 1', '2024', '9f1b6ea8-e94f-482c-8231-b8dcb2ddf278'),
  ('94907d95-378f-43a5-8927-7e54643d3e1e', 'lancaster-liga-1', 'Lancaster Liga 1', '2024', '78c7666c-a894-4cd7-8256-3a04b98228cb'),
  ('a3848367-3e36-4afe-8eb5-0d45bd477b2f', 'central-nj-liga-1', 'Central NJ Liga 1', '2024', 'b2cf2684-c283-4c5f-8518-4cc259041f44')
ON CONFLICT (id) DO UPDATE SET
  casa_id = EXCLUDED.casa_id,
  name = EXCLUDED.name,
  season = EXCLUDED.season,
  league_division_id = EXCLUDED.league_division_id
;

