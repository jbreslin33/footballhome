-- CASA League Divisions

INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, hierarchy_group, skill_level, age_group, description, max_teams, promotion_eligible, relegation_eligible, is_active)
VALUES
  ('d5d544d1-1f35-4b7d-80e0-67c5fd63258f', '608a4eb6-432e-43f3-853f-1438f93528f9', 'Liga 1', 'Philadelphia Liga 1', 'philadelphia-liga-1', 1, NULL, NULL, NULL, NULL, NULL, false, false, true),
  ('311fe53c-88df-4efe-8fa9-6f397992b826', '608a4eb6-432e-43f3-853f-1438f93528f9', 'Liga 2', 'Philadelphia Liga 2', 'philadelphia-liga-2', 2, NULL, NULL, NULL, NULL, NULL, false, false, true),
  ('9f1b6ea8-e94f-482c-8231-b8dcb2ddf278', 'b7c0b518-29f2-4bf3-8651-9b6d699f01b7', 'Liga 1', 'Boston Liga 1', 'boston-liga-1', 1, NULL, NULL, NULL, NULL, NULL, false, false, true),
  ('78c7666c-a894-4cd7-8256-3a04b98228cb', '00ad821c-1bee-4c78-8756-d4172c82f976', 'Liga 1', 'Lancaster Liga 1', 'lancaster-liga-1', 1, NULL, NULL, NULL, NULL, NULL, false, false, true),
  ('b2cf2684-c283-4c5f-8518-4cc259041f44', '49df086e-f87b-4fb4-8640-dccaf6fdc1e9', 'Liga 1', 'Central NJ Liga 1', 'central-nj-liga-1', 1, NULL, NULL, NULL, NULL, NULL, false, false, true)
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
  max_teams = EXCLUDED.max_teams,
  promotion_eligible = EXCLUDED.promotion_eligible,
  relegation_eligible = EXCLUDED.relegation_eligible,
  is_active = EXCLUDED.is_active
;

