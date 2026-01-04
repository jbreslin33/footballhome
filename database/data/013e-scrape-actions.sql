-- Scrape Actions Lookup Table
-- Defines WHAT to do with a scrape target

CREATE TABLE scrape_actions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_actions (id, name, description, sort_order) VALUES
    (1, 'download_and_parse', 'Fetch fresh HTML/API data and parse it', 1),
    (2, 'use_cache_only', 'Parse existing cached HTML without fetching', 2),
    (3, 'skip', 'Do not process this target (completed/archived)', 3),
    (4, 'force_refresh', 'Force fresh download even if recently scraped', 4),
    (5, 'verify_only', 'Check if data exists, report discrepancies', 5)
ON CONFLICT (id) DO NOTHING;
