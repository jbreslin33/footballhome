-- ========================================
-- TEST PRACTICES - Winter/Spring 2025-2026
-- ========================================
-- Practice schedule for Lighthouse 1893 SC
-- Loaded only when --test-data flag is passed to dev.sh
-- ========================================

-- Team/User References:
-- Lighthouse 1893 SC:           d37eb44b-8e47-0005-9060-f0cbe96fe089
-- Created by (jbreslin):        77d77471-1250-47e0-81ab-d4626595d63c
-- Training event_type_id:       550e8400-e29b-41d4-a716-446655440401
-- Home status_id:               550e8400-e29b-41d4-a716-446655440801

-- Venue IDs:
-- Lighthouse Field:             5cd5a6f6-3ac7-4093-924f-55fe7f08807d
-- Lighthouse Community Center:  a2000001-0000-0000-0000-000000000001

-- ========================================
-- WINTER SCHEDULE (December 2025 - February 2026)
-- Saturday & Sunday: 9am-11am @ Community Center
-- Monday: 6pm-8pm @ Community Center
-- Wednesday: 6pm-8pm @ Lighthouse Field
-- ========================================

-- DECEMBER 2025
-- Week of Dec 1-7 (starts after today Dec 3)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000001', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2025-12-03 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000002', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2025-12-06 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000003', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2025-12-07 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Dec 8-14
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000004', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2025-12-08 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000005', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2025-12-10 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000006', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2025-12-13 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000007', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2025-12-14 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Dec 15-21
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000008', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2025-12-15 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000009', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2025-12-17 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000010', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2025-12-20 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000011', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2025-12-21 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Dec 22-28 (Christmas week - maybe lighter schedule but including)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000012', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2025-12-22 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000013', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2025-12-27 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000014', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2025-12-28 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Dec 29 - Jan 4
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000015', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2025-12-29 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000016', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2025-12-31 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- JANUARY 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000017', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-01-03 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000018', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-01-04 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Jan 5-11
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000019', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-01-05 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000020', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-01-07 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000021', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-01-10 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000022', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-01-11 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Jan 12-18
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000023', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-01-12 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000024', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-01-14 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000025', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-01-17 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000026', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-01-18 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Jan 19-25
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000027', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-01-19 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000028', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-01-21 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000029', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-01-24 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000030', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-01-25 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Jan 26 - Feb 1
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000031', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-01-26 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000032', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-01-28 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000033', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-01-31 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- FEBRUARY 2026
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000034', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-02-01 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Feb 2-8
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000035', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-02-02 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000036', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-02-04 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000037', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-02-07 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000038', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-02-08 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Feb 9-15
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000039', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-02-09 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000040', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-02-11 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Feb 14 is Cup game day (Saturday) - skip Saturday practice
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000041', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-02-15 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Feb 16-22
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000042', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-02-16 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000043', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-02-18 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000044', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-02-21 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000045', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Sunday Practice', '2026-02-22 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Feb 23 - Mar 1 (transition week)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000046', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Monday Practice', '2026-02-23 18:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000047', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-02-25 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000048', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-02-28 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- ========================================
-- SPRING SCHEDULE (March 2026 onwards)
-- Tuesday, Wednesday, Thursday, Friday: 6pm-8pm @ Lighthouse Field
-- Saturday: 9am-11am @ Community Center
-- ========================================

-- Mar 1 is first league match (Sunday) - no practice
-- Week of Mar 2-7
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000049', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-03-03 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000050', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-03-04 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000051', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-03-05 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000052', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-03-06 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000053', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-03-07 09:00:00-05', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Mar 9-14 (Mar 8 is match day)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000054', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-03-10 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000055', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-03-11 18:00:00-05', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000056', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-03-12 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000057', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-03-13 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Mar 14 is match day (Saturday) - no Saturday practice

-- Week of Mar 16-21 
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000058', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-03-17 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000059', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-03-18 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000060', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-03-19 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000061', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-03-20 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000062', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-03-21 09:00:00-04', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Mar 23-28 (Mar 22 is match day)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000063', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-03-24 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000064', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-03-25 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000065', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-03-26 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000066', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-03-27 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000067', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-03-28 09:00:00-04', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Mar 30 - Apr 4 (Mar 29 is match day)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000068', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-03-31 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000069', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-04-01 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000070', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-04-02 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000071', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-04-03 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000072', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-04-04 09:00:00-04', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Apr 6-11 (Apr 5 is match day)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000073', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-04-07 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000074', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-04-08 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000075', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-04-09 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000076', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-04-10 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Apr 11 is match day (Saturday) - skip Saturday practice

-- Week of Apr 13-18 
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000077', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-04-14 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000078', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-04-15 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000079', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-04-16 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000080', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-04-17 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000081', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-04-18 09:00:00-04', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Apr 20-25 (Apr 19 is match day)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000082', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-04-21 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000083', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-04-22 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000084', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-04-23 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000085', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-04-24 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000086', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-04-25 09:00:00-04', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of Apr 27 - May 2 (Apr 26 is match day)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000087', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-04-28 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000088', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-04-29 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000089', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-04-30 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000090', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-05-01 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000091', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-05-02 09:00:00-04', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- Week of May 4-9 (May 3 is match day)
INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000092', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Tuesday Practice', '2026-05-05 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000093', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Wednesday Practice', '2026-05-06 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000094', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Thursday Practice', '2026-05-07 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000095', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Friday Practice', '2026-05-08 18:00:00-04', 120, (SELECT id FROM venues WHERE name LIKE 'Lighthouse Field%' LIMIT 1))
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes, venue_id)
VALUES ('b1000001-0000-0000-0000-000000000096', '77d77471-1250-47e0-81ab-d4626595d63c', '550e8400-e29b-41d4-a716-446655440401', 'Saturday Practice', '2026-05-09 09:00:00-04', 120, 'a2000001-0000-0000-0000-000000000001')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, event_date = EXCLUDED.event_date;

-- May 10 is final match of season

-- Associate all practices with Lighthouse team

-- Associate all practices with Lighthouse team
INSERT INTO practices (id, team_id)
SELECT id, 'd37eb44b-8e47-0005-9060-f0cbe96fe089'
FROM events
WHERE event_type_id = '550e8400-e29b-41d4-a716-446655440401'
AND id::text LIKE 'b1000001-%'
ON CONFLICT (id) DO NOTHING;
