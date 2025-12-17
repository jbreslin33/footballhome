-- CASA League Divisions
-- Generated at: 2025-12-17T15:41:55.796Z

INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, hierarchy_group, skill_level, age_group, description, is_active)
VALUES
  ('9f708557-d2bf-4192-82f5-9ea58a3978cc', 'c435f97d-f0eb-4616-84f3-0075e6375c0d', 'Liga 1', 'Liga 1', 'liga-1', 1, NULL, NULL, NULL, NULL, NULL, false, false, true),
  ('bfa1da60-e9cf-4677-80ad-3c98a240f75f', 'c435f97d-f0eb-4616-84f3-0075e6375c0d', 'Liga 2', 'Liga 2', 'liga-2', 2, NULL, NULL, NULL, NULL, NULL, false, false, true)
ON CONFLICT (id) DO UPDATE SET
  conference_id = EXCLUDED.conference_id,
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  tier = EXCLUDED.tier,
  hierarchy_group = EXCLUDED.hierarchy_group,
  skill_level = EXCLUDED.skill_level,
  age_group = EXCLUDED.age_group,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;

