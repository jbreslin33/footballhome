-- 261-marketing-admin-level.sql (2026-08-04)
--
-- Adds a 'marketing' admin_levels row so social-media/recruitment
-- staff can be granted a real, narrower role instead of full 'club'
-- admin. Nested, not disjoint: 'club' and 'super' already cover
-- everything 'marketing' can do (see Controller::requireAdminLevel
-- call sites — Communications/Recruitment endpoints allow all three
-- levels; People/Billing/RSVP-eligibility/Person-merge allow only
-- club/super). admins.user_id stays UNIQUE — one admin_level per
-- user, so a marketing person who's promoted to full club admin gets
-- their row's admin_level_id updated, not a second row added.

BEGIN;

-- admin_levels was seeded via COPY, which doesn't advance the id
-- sequence — resync it first or nextval() collides with an existing
-- row (seen live: sequence stuck at 1 while MAX(id)=3).
SELECT setval('admin_levels_id_seq', (SELECT MAX(id) FROM admin_levels));

INSERT INTO admin_levels (name, description, sort_order)
VALUES ('marketing', 'Marketing/social administrator — recruitment leads and outbound communications only', 4)
ON CONFLICT (name) DO NOTHING;

COMMIT;
