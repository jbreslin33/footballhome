-- APSL Teams
-- Generated at: 2025-12-16T15:59:40.891Z

INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  'Falcons FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.045Z',
  '2025-12-16T15:58:14.045Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '8a804c82-814c-4a90-856b-441236c695ed',
  'Scrub Nation',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.045Z',
  '2025-12-16T15:58:14.045Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  'Praia Kapital',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.045Z',
  '2025-12-16T15:58:14.045Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  'South Coast Union',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.045Z',
  '2025-12-16T15:58:14.045Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  'Project Football',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.045Z',
  '2025-12-16T15:58:14.045Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '272b83b4-1153-402d-8a47-015cb13cd376',
  'Invictus FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.045Z',
  '2025-12-16T15:58:14.045Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  'Fitchburg FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.045Z',
  '2025-12-16T15:58:14.045Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  'Sete Setembro USA',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2e3f8a51-d741-46b8-8d9f-76eba5c4c709',
  'Somerville United FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b67749bd-3006-4977-81db-c16e5c10143c',
  'KO Elites',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  'Glastonbury Celtic',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  'Wildcat FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  'Hermandad Connecticut',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  'NY Greek Americans',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  'Hoboken FC 1912',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  'NY Pancyprian Freedoms',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  'Lansdowne Yonkers FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b59f4742-28b4-46db-8a70-f819f7935278',
  'Doxa FCW',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  'Leros SC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  'NY International FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  'Richmond County FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  'Zum Schneider FC 03',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  'Central Park Rangers FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  'SC Vistula Garfield',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  'NY Athletic Club',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  'WC Predators',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1b01904c-2aca-4467-80c9-705893293f40',
  'Alloy Soccer Club',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  'Oaklyn United FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  'Real Central NJ Soccer',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  'Philadelphia Heritage SC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  'Philadelphia Soccer Club',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  'Vidas United FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  'GAK',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  'Lighthouse 1893 SC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  'Jersey Shore Boca',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  'Sewell Old Boys FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  'Medford Strikers',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  'Nova FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  'VA Marauders FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  'Wave FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  'PFA EPSL',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  'Grove Soccer United',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  'Christos FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  'Delmarva Thunder',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'ec459901-be4c-4586-8296-a0ca018b0759',
  'PW Nova',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  'Terminus FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  'Prima FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  'Majestic SC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  'Peachtree FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  'Bel Calcio FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  'Buckhead SC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  'Alliance SC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  'SC Gwinnett',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '55ed4434-a232-448f-8f3b-b52933af199b',
  'Lithonia City FC',
  'TBD',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:58:14.046Z',
  '2025-12-16T15:58:14.046Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
