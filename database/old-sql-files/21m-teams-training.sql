-- Lighthouse Training Team (for shared training events)
INSERT INTO teams (id, sport_division_id, name, age_group, skill_level, description)
VALUES (
    '3ee933c4-3ecc-4478-8737-b5a148fcebc7',
    '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9',
    'Lighthouse Training',
    'Adult',
    'Mixed',
    'Shared training team for all Lighthouse clubs'
) ON CONFLICT (id) DO NOTHING;
