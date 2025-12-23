-- ========================================
-- MANUAL TEAM COACHES
-- ========================================
-- Use this file to manually assign coaches to teams
-- ========================================

-- Example:
-- INSERT INTO team_coaches (team_id, coach_id, coach_role, is_primary, is_active)
-- VALUES (
--   'team-uuid',
--   'coach-uuid',
--   'head_coach',  -- 'head_coach', 'assistant_coach', 'goalkeeper_coach', 'fitness_coach'
--   true,
--   true
-- )
-- ON CONFLICT (team_id, coach_id) DO NOTHING;

-- James Breslin as Head Coach for all Lighthouse teams
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES 
    (gen_random_uuid(), 'a16e9445-9bed-4fe6-804d-e77c56258610', '311ee799-a6a1-450f-8bad-5140a021c92b', 'Head Coach', true, true),
    (gen_random_uuid(), '57d88568-993d-4411-8aa3-6244ca7ff704', '311ee799-a6a1-450f-8bad-5140a021c92b', 'Head Coach', true, true),
    (gen_random_uuid(), 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', '311ee799-a6a1-450f-8bad-5140a021c92b', 'Head Coach', true, true),
    (gen_random_uuid(), '3ee933c4-3ecc-4478-8737-b5a148fcebc7', '311ee799-a6a1-450f-8bad-5140a021c92b', 'Head Coach', true, true)
ON CONFLICT (team_id, coach_id) DO NOTHING;
