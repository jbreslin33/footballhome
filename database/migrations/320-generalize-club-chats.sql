-- 320 — Seed the women's and youth (boys+girls combined) chats.
--
-- The only chat that has ever existed is 'mens' (id 13, added by an
-- earlier migration). MyController.cpp hardcoded that one slug and
-- gated access off team_persons/teams.gender_category = 'mens'.
--
-- This generalizes chat access to be driven by active LA membership
-- (person_la_memberships) instead of FH's own roster tables — LA is
-- the source of truth for membership, and teams.gender_category has
-- no 'girls' value at all (boys and girls share one combined chat).
-- See MyController.cpp for the slug -> LA program name mapping.
--
-- team_id is left NULL on all three rows, same as the existing mens
-- row — these chats were never actually tied to a specific `teams`
-- row, just a club-wide "everyone active in this membership" group.

BEGIN;

INSERT INTO chats (name, description, is_active, slug)
VALUES
    ('Lighthouse Women''s Club',
     'Practical stuff — cancellations, weather, running late, anything schedule-adjacent.',
     true, 'womens'),
    ('Lighthouse Boys & Girls Club',
     'Practical stuff — cancellations, weather, running late, anything schedule-adjacent.',
     true, 'youth')
ON CONFLICT (slug) WHERE slug IS NOT NULL DO NOTHING;

COMMIT;
