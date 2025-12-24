-- Training Lighthouse - Schedule

INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'db1adebc-2e80-4f6b-8e4f-2dd5d1524063',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Monday Training Indoor Flats',
  NULL,
  '2025-12-01T23:00:00.000Z',
  NULL,
  110,
  false,
  NULL,
  '05185f7920c14cb8825547ad4779afbd'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  'db1adebc-2e80-4f6b-8e4f-2dd5d1524063',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '38838d7f-02e7-4436-8e4e-9fc3565412a3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Saturday Training Indoor Flats',
  NULL,
  '2025-12-06T14:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  'ed035c7123da47758822572e7bbbf33e'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  '38838d7f-02e7-4436-8e4e-9fc3565412a3',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '2f4c6ff2-e8d8-4000-8264-64190daf3835',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Sunday Training Indoor Flats',
  NULL,
  '2025-12-07T14:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  'd14fb27ba4eb42138d2b7d12d841e61f'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  '2f4c6ff2-e8d8-4000-8264-64190daf3835',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'afb47723-1fb6-4b43-852f-fb4632f7ca8c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Monday Training Indoor Flats',
  NULL,
  '2025-12-08T23:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  'a376627892ad431888bf7a2dd556d262'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  'afb47723-1fb6-4b43-852f-fb4632f7ca8c',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3b7861e0-d5ff-4e05-874e-1cc6045751d5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Saturday Training Indoor Flats',
  NULL,
  '2025-12-13T14:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  'a3b8e835d5ba40248f10d147cba36466'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  '3b7861e0-d5ff-4e05-874e-1cc6045751d5',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b44059c4-c217-44af-85d7-1e6d6ff70b8c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Monday Training Indoor Flats',
  NULL,
  '2025-12-13T23:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  '3515ec3d49a84940b41bc8dafca2e82f'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  'b44059c4-c217-44af-85d7-1e6d6ff70b8c',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '8aa0fa55-f5a2-4adb-82d8-2656e0e5fe9d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Monday Training Indoor Flats',
  NULL,
  '2025-12-15T23:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  'a6186a5028144d24bed24049409c39a7'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  '8aa0fa55-f5a2-4adb-82d8-2656e0e5fe9d',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '20ae424f-ddaf-44af-8bfe-5a5f1a129a3a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Saturday Training Indoor Flats',
  NULL,
  '2025-12-20T14:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  'bc6c2a00a50c49a5a10e834b586b5594'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  '20ae424f-ddaf-44af-8bfe-5a5f1a129a3a',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b94ba29c-69ec-44a1-88aa-4fc097736543',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Monday Training Indoor Flats',
  NULL,
  '2025-12-22T23:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  'e02876d802ad49d09577e7efe2d31965'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  'b94ba29c-69ec-44a1-88aa-4fc097736543',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'b30327e1-1152-4560-8a34-e8eb58a2d832',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Saturday Training Indoor Flats',
  NULL,
  '2025-12-27T14:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  '676c0ca7f2154baeb2df5776aa1451ae'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  'b30327e1-1152-4560-8a34-e8eb58a2d832',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  'c98a9857-c89f-4949-8408-aa2cb6d44d3e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Sunday Training Indoor Flats',
  NULL,
  '2025-12-28T14:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  '7582172ef5e742648c2b8ba30bca45f6'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  'c98a9857-c89f-4949-8408-aa2cb6d44d3e',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  '3ca1a1ab-fdf9-4853-85be-2c5e3c455db0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440401',
  'Monday Training Indoor Flats',
  NULL,
  '2025-12-29T23:00:00.000Z',
  NULL,
  120,
  false,
  NULL,
  '95343f9952964663836e65d2cb8d162e'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;

INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  '3ca1a1ab-fdf9-4853-85be-2c5e3c455db0',
  '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;
