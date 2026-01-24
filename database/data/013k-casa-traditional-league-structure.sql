-- CASA Traditional 2025 League Structure
-- League ID: 3 (CASA Traditional)
-- 2 conferences (Philadelphia, Boston), 12 divisions
-- Philadelphia: 7 divisions (Primera through Septima)
-- Boston: 5 divisions (Primera through Tercera, Quarto Rojo, Quarto Azul)
-- Uses 200-series IDs to distinguish from CASA Select (100-series)

-- Season 200: CASA Traditional 2025
INSERT INTO seasons (id, league_id, name, start_date, end_date, is_active, source_system_id) VALUES
    (200, 3, '2025', '2025-01-01', '2025-12-31', true, 2)
ON CONFLICT (league_id, name) DO NOTHING;

-- Conference 200: Philadelphia
-- Conference 201: Boston
INSERT INTO conferences (id, season_id, name, abbreviation, region, source_system_id, sort_order) VALUES
    (200, 200, 'Philadelphia', 'PHI', 'Philadelphia, PA', 2, 1),
    (201, 200, 'Boston', 'BOS', 'Boston, MA', 2, 2)
ON CONFLICT (season_id, name) DO NOTHING;

-- Philadelphia Divisions (200-206)
-- Division 200: Primera
-- Division 201: Segunda
-- Division 202: Tercera
-- Division 203: Quarto
-- Division 204: Quinto
-- Division 205: Sexta
-- Division 206: Septima
INSERT INTO divisions (id, season_id, conference_id, name, division_type_id, source_system_id, external_id, sort_order) VALUES
    (200, 200, 200, 'Primera', 1, 2, NULL, 1),
    (201, 200, 200, 'Segunda', 1, 2, NULL, 2),
    (202, 200, 200, 'Tercera', 1, 2, NULL, 3),
    (203, 200, 200, 'Quarto', 1, 2, NULL, 4),
    (204, 200, 200, 'Quinto', 1, 2, NULL, 5),
    (205, 200, 200, 'Sexta', 1, 2, NULL, 6),
    (206, 200, 200, 'Septima', 1, 2, NULL, 7)
ON CONFLICT DO NOTHING;

-- Boston Divisions (207-211)
-- Division 207: Primera
-- Division 208: Segunda
-- Division 209: Tercera
-- Division 210: Quarto Rojo
-- Division 211: Quarto Azul
INSERT INTO divisions (id, season_id, conference_id, name, division_type_id, source_system_id, external_id, sort_order) VALUES
    (207, 200, 201, 'Primera', 1, 2, NULL, 1),
    (208, 200, 201, 'Segunda', 1, 2, NULL, 2),
    (209, 200, 201, 'Tercera', 1, 2, NULL, 3),
    (210, 200, 201, 'Quarto Rojo', 1, 2, NULL, 4),
    (211, 200, 201, 'Quarto Azul', 1, 2, NULL, 5)
ON CONFLICT DO NOTHING;

-- Update sequence to continue from highest ID
SELECT setval('seasons_id_seq', (SELECT MAX(id) FROM seasons));
SELECT setval('conferences_id_seq', (SELECT MAX(id) FROM conferences));
SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions));
