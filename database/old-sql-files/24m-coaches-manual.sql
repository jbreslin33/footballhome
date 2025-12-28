-- ========================================
-- MANUAL COACHES
-- ========================================
-- Use this file to manually add coaches not found in scraped data
-- ========================================

-- Example:
-- INSERT INTO users (id, email, first_name, last_name, phone, is_active)
-- VALUES ('coach-uuid', 'coach@example.com', 'John', 'Smith', '555-0100', true)
-- ON CONFLICT (email) DO NOTHING;
--
-- INSERT INTO coaches (id, coaching_license, years_experience)
-- VALUES ('coach-uuid', 'UEFA A', 15)
-- ON CONFLICT (id) DO NOTHING;

-- James Breslin as coach
INSERT INTO coaches (id, created_at)
VALUES ('311ee799-a6a1-450f-8bad-5140a021c92b', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;
