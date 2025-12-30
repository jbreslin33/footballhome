-- CASA Leagues

INSERT INTO leagues (id, organization_id, name, season, website_url, affiliation, age_calculation_method_id, age_min, age_max, age_cutoff_month_day, age_display_label, sex_restriction, source_system_id, external_id, is_active)
VALUES
  (1, 2, 'CASA Soccer League', '2024-2025', 'https://www.casasoccerleagues.com', NULL, NULL, NULL, NULL, NULL, 'Open', 'men', 2, 'casa-2024-2025', true)
ON CONFLICT (id) DO UPDATE SET
  organization_id = EXCLUDED.organization_id,
  name = EXCLUDED.name,
  season = EXCLUDED.season,
  website_url = EXCLUDED.website_url,
  affiliation = EXCLUDED.affiliation,
  age_calculation_method_id = EXCLUDED.age_calculation_method_id,
  age_min = EXCLUDED.age_min,
  age_max = EXCLUDED.age_max,
  age_cutoff_month_day = EXCLUDED.age_cutoff_month_day,
  age_display_label = EXCLUDED.age_display_label,
  sex_restriction = EXCLUDED.sex_restriction,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id,
  is_active = EXCLUDED.is_active
;

