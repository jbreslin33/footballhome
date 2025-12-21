
-- Logged at: 2025-12-20 21:16:02
INSERT INTO tactical_boards (id, name, description, created_by, board_type_id, stance_id, field_third_id, formation_home, formation_opponent, canvas_width, canvas_height, is_public, is_template) VALUES ('4431fd58-c4df-4764-a444-921c1084e4ce', 'Tactical Board - 12/20/2025', 'test', '311ee799-a6a1-450f-8bad-5140a021c92b', 2, NULL, NULL, '4-4-2', 'custom', 1139, 607, false, false);

-- Logged at: 2025-12-21 00:11:12
INSERT INTO tactical_boards (id, name, description, created_by, board_type_id, stance_id, field_third_id, formation_home, formation_opponent, canvas_width, canvas_height, is_public, is_template) VALUES ('c0c2a59a-598b-429d-9856-2a3bf2ef26e5', 'Tactical Board - 12/20/2025', '', '311ee799-a6a1-450f-8bad-5140a021c92b', 2, NULL, NULL, '4-4-2', 'custom', 1139, 607, false, false);

-- Logged at: 2025-12-21 00:11:12
INSERT INTO tactical_boards (id, name, description, created_by, board_type_id, stance_id, field_third_id, formation_home, formation_opponent, canvas_width, canvas_height, is_public, is_template) VALUES ('7ffc916d-f50f-420a-b749-e6fee999a7e8', 'inverted', 'inverted', '311ee799-a6a1-450f-8bad-5140a021c92b', 2, NULL, NULL, '4-4-2', 'custom', 1139, 607, false, false);

-- Link boards to teams (Manual Fix)
INSERT INTO tactical_board_entities (tactical_board_id, team_id) VALUES
-- Board 1
('4431fd58-c4df-4764-a444-921c1084e4ce', 'a16e9445-9bed-4fe6-804d-e77c56258610'),
('4431fd58-c4df-4764-a444-921c1084e4ce', '57d88568-993d-4411-8aa3-6244ca7ff704'),
('4431fd58-c4df-4764-a444-921c1084e4ce', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11'),
-- Board 2
('c0c2a59a-598b-429d-9856-2a3bf2ef26e5', 'a16e9445-9bed-4fe6-804d-e77c56258610'),
('c0c2a59a-598b-429d-9856-2a3bf2ef26e5', '57d88568-993d-4411-8aa3-6244ca7ff704'),
('c0c2a59a-598b-429d-9856-2a3bf2ef26e5', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11'),
-- Board 3 (inverted)
('7ffc916d-f50f-420a-b749-e6fee999a7e8', 'a16e9445-9bed-4fe6-804d-e77c56258610'),
('7ffc916d-f50f-420a-b749-e6fee999a7e8', '57d88568-993d-4411-8aa3-6244ca7ff704'),
('7ffc916d-f50f-420a-b749-e6fee999a7e8', 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11');
