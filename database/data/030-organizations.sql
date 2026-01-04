-- Organizations (universal top-level entities)
-- Organizations are the superclass for:
-- - Governing bodies (FIFA, CONCACAF, US Soccer, USASA, NorCal Soccer)
-- - League operators (APSL, CASA)
-- - Club owners (Lighthouse 1893, Falcons FC)

-- Manual organizations (not scraped)
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (1, 'Lighthouse 1893', 'LH1893', true)
ON CONFLICT (id) DO NOTHING;

-- Placeholder - additional organizations will be populated by scrapers
-- Scrapers should create orgs for: FIFA, CONCACAF, US Soccer, USASA, NorCal, APSL, CASA, each team's club, etc.
