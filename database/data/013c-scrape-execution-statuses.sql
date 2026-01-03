-- Scrape Execution Statuses Lookup Data
-- Defines possible states for scrape execution runs

INSERT INTO scrape_execution_statuses (id, name, description, sort_order) VALUES
    (1, 'pending', 'Scrape queued but not yet started', 1),
    (2, 'running', 'Scrape currently in progress', 2),
    (3, 'success', 'Scrape completed successfully', 3),
    (4, 'partial', 'Scrape completed with some errors', 4),
    (5, 'failed', 'Scrape failed completely', 5),
    (6, 'timeout', 'Scrape exceeded time limit', 6),
    (7, 'cancelled', 'Scrape manually cancelled', 7)
ON CONFLICT (id) DO NOTHING;
