-- APSL Teams
-- Generated at: 2025-12-17T21:42:50.516Z

INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'fe1c0dbb-5ec2-4f07-8842-dc92875c29ec',
  'Falcons FC',
  '89b40d2d-4276-4480-8a01-5a34463b39a3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '8a804c82-814c-4a90-856b-441236c695ed',
  'Scrub Nation',
  '73b2621d-7437-47bd-823a-9c577990f057',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '14bb3090-8e24-4cb6-82e6-73fc6fc04278',
  'Praia Kapital',
  'a08ae97e-6d23-4401-8352-588119b361fb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b23a377a-cf24-46e6-8fb2-09faa87fc064',
  'South Coast Union',
  '0a6a1bdd-06d4-474c-86e5-9e7243257833',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5330ce61-ccc0-4d8e-8a2b-7b092655c952',
  'Project Football',
  '3221428b-3a04-4fe8-8175-4bd831591020',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '272b83b4-1153-402d-8a47-015cb13cd376',
  'Invictus FC',
  'bd24af9b-02a5-488b-8866-3214959485c4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd7ec30af-80bb-4972-894b-4a441b6bc7a9',
  'Fitchburg FC',
  'c2817250-9054-41c9-8bad-4aaba37ecb2d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '032152f4-6b1f-4a87-8ba6-7c3330e1fbdb',
  'Sete Setembro USA',
  '1fa5187b-a7ee-4cb8-82cf-84e252e359fd',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2e3f8a51-d741-46b8-8d9f-76eba5c4c709',
  'Somerville United FC',
  '5a5edf0f-2e18-49ad-8976-c47bc0feb19d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b67749bd-3006-4977-81db-c16e5c10143c',
  'KO Elites',
  'fb24ce73-4a49-482c-823d-dc6aa0faff4b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5d045d5d-e0de-4bf1-803a-3a751a0bd108',
  'Glastonbury Celtic',
  'c8bd5ca8-d63b-4d0e-8c1c-1f0ba36b3f95',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'f98df7c4-dd4b-47e7-86ed-6221c02b28a3',
  'Wildcat FC',
  '06087468-c9f5-4cd6-8cf2-db472b25207c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '78550a78-2da7-4ad0-8dff-8ca3ae1446ea',
  'Hermandad Connecticut',
  '350f2bcd-abdc-4757-8ad4-088b2e4c34e5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '05ec5303-e217-4602-8c03-06fb02c3c083',
  'NY Greek Americans',
  'fd4a7c7c-f3e6-4f17-825d-a29a4639bc46',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.457Z',
  '2025-12-17T21:41:16.457Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1ab54f95-8510-412c-8d6e-c203ee8cd727',
  'Hoboken FC 1912',
  'f8d70701-e70b-487f-80fa-91bb5b664930',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '998d8d80-fabe-4b10-83f5-6ad236885249',
  'NY Pancyprian Freedoms',
  'c351ff32-69ea-44b0-81e2-5ba1b26b1844',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c618dc61-7e80-45fc-8879-0dc3ad29a499',
  'Lansdowne Yonkers FC',
  '4d1f55b0-2c6a-44f3-8b86-4dfadc52ceb5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b59f4742-28b4-46db-8a70-f819f7935278',
  'Doxa FCW',
  'ff1096fb-c947-4081-84f9-a6638fa5bfe3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2bb5ff3c-b055-4d67-8ed4-6ebf0fdcfc47',
  'Leros SC',
  '16adb88a-a401-4f0a-8e4b-e8295dbdc433',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'cfc9b089-1fc3-48b4-89b8-41df1c9013c3',
  'NY International FC',
  '71c3c8e5-5350-4f72-8c66-d03bee38b889',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '139b5b54-bef5-4b6a-8863-57ce6e6d399d',
  'Richmond County FC',
  '16c5bf52-ae81-4cb9-81ab-68650902147a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5b5c9fa8-a519-4711-8638-247856aa639f',
  'Zum Schneider FC 03',
  'a8ccd55b-1790-4ae5-8c26-b6002b90179c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'ae682d5e-54bb-480c-81b9-64294c39fd79',
  'Central Park Rangers FC',
  'ee18c25f-2c74-48f3-8a91-784e72e16a54',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '88e20e8e-ce66-41d6-833d-07e5a25cd61c',
  'SC Vistula Garfield',
  '282ccbd7-19ee-412e-8d80-babfb989621d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '6312950e-7d25-4b0d-8bfb-8e34e8f29515',
  'NY Athletic Club',
  'dd706f35-500c-4a05-87d7-bc08776c9928',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a1288ba5-ae67-43df-8fbe-4a63a7702603',
  'WC Predators',
  'acb1a7b2-3599-4d24-857a-64256cb85aa2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1b01904c-2aca-4467-80c9-705893293f40',
  'Alloy Soccer Club',
  'cc0a73d9-c4c7-4fab-8260-50257ed8701d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd48fb053-a685-499e-8663-9e5a3f8ec6c5',
  'Oaklyn United FC',
  '51c3b20f-1681-45b2-8cf7-cd2e6b0f9264',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'dc27803e-61df-4da0-8d93-3ebad8e0cc15',
  'Real Central NJ Soccer',
  'a089a74e-73b4-43e8-87d1-688a34caae28',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '31c888be-7a06-4c53-8321-a91d8aa7d63a',
  'Philadelphia Heritage SC',
  'd7339ee3-602e-48b7-80e6-039f57f6b70a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'f7621fc8-ea3b-477d-8a61-96e77b3dac29',
  'Philadelphia Soccer Club',
  'b86f88d6-f571-46be-8320-f5787bfe9aa6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '79e4d7bd-bad2-4af9-8fbf-7f48bab11290',
  'Vidas United FC',
  '80153302-026d-4f55-8b83-4e76e2aa618a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5d44198a-5c2e-4ae4-8c4f-7f987b4ac057',
  'GAK',
  'a08a3157-afd8-42e1-8cab-354957d41039',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a16e9445-9bed-4fe6-804d-e77c56258610',
  'Lighthouse 1893 SC',
  '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '63a2603e-8e5c-49eb-826b-ab90969aef98',
  'Jersey Shore Boca',
  '889c65df-5239-4619-8a60-c6779010890c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'cb4a6b7d-d81d-4101-8328-16528f344477',
  'Sewell Old Boys FC',
  '86786fcb-7d0e-4fc4-842e-66e52da45c17',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '7ffd000f-d10c-4270-8342-fd0c583b6855',
  'Medford Strikers',
  'a75542c8-615c-45c8-8d47-c91ebb35e98e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '81100354-bd19-444e-8ef5-9864a598b2b6',
  'Nova FC',
  '118fbc40-e5b7-4175-8f3f-ac4d7049b178',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '8844cece-ce0f-4f9c-8637-403ce90ce0dd',
  'VA Marauders FC',
  'fce9c885-407e-421f-8a33-05321fa142ff',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd7112da9-db42-48d3-8bed-a12bd56a8888',
  'Wave FC',
  '167450a2-5141-42f0-8b81-95b2d9708842',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b289a801-2713-4e48-80cf-bf45994b4b4b',
  'PFA EPSL',
  '1e3bcd56-becf-4af8-8b45-5fc2e8ffbac8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '26ee5a1c-466b-46a2-8b88-b49bc8194989',
  'Grove Soccer United',
  'd8259b20-89e3-457f-8060-5517c169649d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2c9443f6-4c8b-4c89-8e95-2ee0c8bd767f',
  'Christos FC',
  '51b1b28d-3c61-450d-8191-e4dc8588eaef',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '6240b09d-0bbb-4731-8e61-664f69ad8b49',
  'Delmarva Thunder',
  'b44b8381-73c0-4f24-8f20-9990102ee8eb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'ec459901-be4c-4586-8296-a0ca018b0759',
  'PW Nova',
  '223db133-be8b-49a8-8f8d-53af6bdb02b1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '67f4893b-5422-4c7e-868f-f3d27642a12b',
  'Terminus FC',
  'f614e56a-63d3-42d0-89a1-886c19c690b0',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1cb0c041-5949-4337-8a8b-3762f395e59a',
  'Prima FC',
  '97f84a4b-f554-4258-8f9c-0b237dbf23a6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'e8d0e257-ec0b-4fdf-818a-9d4e026b4756',
  'Majestic SC',
  '11af0792-9062-452a-8153-198951479489',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'bfb11081-eb6a-43ec-872b-55e2ef6aca28',
  'Peachtree FC',
  '74afeac9-3f54-421c-826f-4040c925f8e9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '8c230f20-9233-4477-83a3-8d14b4c7e25d',
  'Bel Calcio FC',
  'b34fa7ec-fa63-4197-8381-82205ec5c57e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '53b2b1be-a6d3-4bbf-86db-d622fa72352c',
  'Buckhead SC',
  '702f4429-deca-4b77-835b-c63c056e1762',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5bd11942-7e6b-4b91-85a0-f7842b7e6340',
  'Alliance SC',
  '59b6ecd4-d535-451c-886e-7a7f51e62bb3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '582ace7a-0fbe-4368-8f03-462dae171b0c',
  'SC Gwinnett',
  'fd837c14-9e45-4dab-820c-0026e5954b54',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '55ed4434-a232-448f-8f3b-b52933af199b',
  'Lithonia City FC',
  'e7bd5270-3f8a-4c87-8a57-7cea8c73a638',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:41:16.458Z',
  '2025-12-17T21:41:16.458Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
