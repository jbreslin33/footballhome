-- Scrape Statuses Lookup Table
-- Defines the CURRENT STATE of a scrape target

CREATE TABLE scrape_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_statuses (id, name, description, sort_order) VALUES
    (1, 'not_started', 'Never been scraped', 1),
    (2, 'in_progress', 'Currently being scraped', 2),
    (3, 'completed', 'Successfully scraped and up-to-date', 3),
    (4, 'needs_refresh', 'Data exists but may be stale', 4),
    (5, 'failed', 'Last scrape failed', 5),
    (6, 'archived', 'Historical data, will not update', 6)
ON CONFLICT (id) DO NOTHING;
