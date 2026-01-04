-- Continents Data
-- Static reference data for world continents
-- These are standard continent codes used by REST Countries API and ISO standards

INSERT INTO continents (code, name, sort_order) VALUES
    ('AF', 'Africa', 1),
    ('AN', 'Antarctica', 2),
    ('AS', 'Asia', 3),
    ('EU', 'Europe', 4),
    ('NA', 'North America', 5),
    ('OC', 'Oceania', 6),
    ('SA', 'South America', 7)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order;
