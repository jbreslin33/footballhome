-- APSL Sport Divisions
-- Generated at: 2025-12-18T15:07:54.365Z

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '89b40d2d-4276-4480-8a01-5a34463b39a3',
  'a5fb8ddf-c1d6-487c-8c3d-ba4cb001a65e',
  '550e8400-e29b-41d4-a716-446655440101',
  'Falcons FC Soccer',
  'Falcons FC Soccer',
  'falcons-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '73b2621d-7437-47bd-823a-9c577990f057',
  'ad4b2776-c55f-493c-85dd-dcd27757f836',
  '550e8400-e29b-41d4-a716-446655440101',
  'Scrub Nation Soccer',
  'Scrub Nation Soccer',
  'scrub-nation',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a08ae97e-6d23-4401-8352-588119b361fb',
  'f1c1b897-660b-4460-842a-134c0570886a',
  '550e8400-e29b-41d4-a716-446655440101',
  'Praia Kapital Soccer',
  'Praia Kapital Soccer',
  'praia-kapital',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '0a6a1bdd-06d4-474c-86e5-9e7243257833',
  '4fb68606-b590-4313-8a5a-f7b64828db46',
  '550e8400-e29b-41d4-a716-446655440101',
  'South Coast Union Soccer',
  'South Coast Union Soccer',
  'south-coast-union',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '3221428b-3a04-4fe8-8175-4bd831591020',
  '11993e55-fcf5-4baa-8f92-1a1f91a0ee4c',
  '550e8400-e29b-41d4-a716-446655440101',
  'Project Football Soccer',
  'Project Football Soccer',
  'project-football',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'bd24af9b-02a5-488b-8866-3214959485c4',
  '7f94d8be-0c04-4977-8702-3729da641f9f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Invictus FC Soccer',
  'Invictus FC Soccer',
  'invictus-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c2817250-9054-41c9-8bad-4aaba37ecb2d',
  'b5a56a7c-fdb2-4ffb-8879-6de4aeeb4ec2',
  '550e8400-e29b-41d4-a716-446655440101',
  'Fitchburg FC Soccer',
  'Fitchburg FC Soccer',
  'fitchburg-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1fa5187b-a7ee-4cb8-82cf-84e252e359fd',
  '0f88bdf4-6a86-4800-8767-dd17e3009ada',
  '550e8400-e29b-41d4-a716-446655440101',
  'Sete Setembro USA Soccer',
  'Sete Setembro USA Soccer',
  'sete-setembro-usa',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5a5edf0f-2e18-49ad-8976-c47bc0feb19d',
  'e1293c35-a49e-4bec-8194-21b6b992d739',
  '550e8400-e29b-41d4-a716-446655440101',
  'Somerville United FC Soccer',
  'Somerville United FC Soccer',
  'somerville-united-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'fb24ce73-4a49-482c-823d-dc6aa0faff4b',
  '6cbe0d00-871e-43e1-8ae3-d849bd604e43',
  '550e8400-e29b-41d4-a716-446655440101',
  'KO Elites Soccer',
  'KO Elites Soccer',
  'ko-elites',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c8bd5ca8-d63b-4d0e-8c1c-1f0ba36b3f95',
  '7477789b-6c26-4cfa-8d3d-47b315967687',
  '550e8400-e29b-41d4-a716-446655440101',
  'Glastonbury Celtic Soccer',
  'Glastonbury Celtic Soccer',
  'glastonbury-celtic',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '06087468-c9f5-4cd6-8cf2-db472b25207c',
  'b895e0ad-dbac-4962-8571-13352024a8a6',
  '550e8400-e29b-41d4-a716-446655440101',
  'Wildcat FC Soccer',
  'Wildcat FC Soccer',
  'wildcat-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '350f2bcd-abdc-4757-8ad4-088b2e4c34e5',
  '0dabd8ac-c3fe-455d-85f9-f57f767e4305',
  '550e8400-e29b-41d4-a716-446655440101',
  'Hermandad Connecticut Soccer',
  'Hermandad Connecticut Soccer',
  'hermandad-connecticut',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'fd4a7c7c-f3e6-4f17-825d-a29a4639bc46',
  '15fe0415-c520-4485-8b16-7be159b0af9d',
  '550e8400-e29b-41d4-a716-446655440101',
  'NY Greek Americans Soccer',
  'NY Greek Americans Soccer',
  'ny-greek-americans',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'f8d70701-e70b-487f-80fa-91bb5b664930',
  'a17d4d1d-2e80-4a11-8332-f0f748a08e6d',
  '550e8400-e29b-41d4-a716-446655440101',
  'Hoboken FC 1912 Soccer',
  'Hoboken FC 1912 Soccer',
  'hoboken-fc-1912',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c351ff32-69ea-44b0-81e2-5ba1b26b1844',
  '58a68082-aed1-4cdb-83de-f164e6af69f4',
  '550e8400-e29b-41d4-a716-446655440101',
  'NY Pancyprian Freedoms Soccer',
  'NY Pancyprian Freedoms Soccer',
  'ny-pancyprian-freedoms',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '4d1f55b0-2c6a-44f3-8b86-4dfadc52ceb5',
  'd5a7da3d-e222-4d07-81f1-954299765e0f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lansdowne Yonkers FC Soccer',
  'Lansdowne Yonkers FC Soccer',
  'lansdowne-yonkers-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'ff1096fb-c947-4081-84f9-a6638fa5bfe3',
  'f1054efc-0bad-4b32-83f9-421f36826591',
  '550e8400-e29b-41d4-a716-446655440101',
  'Doxa FCW Soccer',
  'Doxa FCW Soccer',
  'doxa-fcw',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '16adb88a-a401-4f0a-8e4b-e8295dbdc433',
  '78abcc31-7865-437b-8626-726353e0a7db',
  '550e8400-e29b-41d4-a716-446655440101',
  'Leros SC Soccer',
  'Leros SC Soccer',
  'leros-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '71c3c8e5-5350-4f72-8c66-d03bee38b889',
  '3e50c3f7-18ba-4fc5-8515-9fce7cf3ef37',
  '550e8400-e29b-41d4-a716-446655440101',
  'NY International FC Soccer',
  'NY International FC Soccer',
  'ny-international-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '16c5bf52-ae81-4cb9-81ab-68650902147a',
  'bb491f4c-73d6-41bc-8f00-d2de5859f39d',
  '550e8400-e29b-41d4-a716-446655440101',
  'Richmond County FC Soccer',
  'Richmond County FC Soccer',
  'richmond-county-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a8ccd55b-1790-4ae5-8c26-b6002b90179c',
  '9b1d533a-800a-4528-8b5f-767263a3361c',
  '550e8400-e29b-41d4-a716-446655440101',
  'Zum Schneider FC 03 Soccer',
  'Zum Schneider FC 03 Soccer',
  'zum-schneider-fc-03',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'ee18c25f-2c74-48f3-8a91-784e72e16a54',
  'd2b87014-7353-413c-86fb-1952b5ea9f76',
  '550e8400-e29b-41d4-a716-446655440101',
  'Central Park Rangers FC Soccer',
  'Central Park Rangers FC Soccer',
  'central-park-rangers-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '282ccbd7-19ee-412e-8d80-babfb989621d',
  '6aff430c-deb9-433b-8346-80da7dba2b2c',
  '550e8400-e29b-41d4-a716-446655440101',
  'SC Vistula Garfield Soccer',
  'SC Vistula Garfield Soccer',
  'sc-vistula-garfield',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'dd706f35-500c-4a05-87d7-bc08776c9928',
  '43913bb3-ab79-4785-8b5c-02d89dac3264',
  '550e8400-e29b-41d4-a716-446655440101',
  'NY Athletic Club Soccer',
  'NY Athletic Club Soccer',
  'ny-athletic-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'acb1a7b2-3599-4d24-857a-64256cb85aa2',
  '5a9245ef-a0e1-4db6-8088-11ac8131e0e6',
  '550e8400-e29b-41d4-a716-446655440101',
  'WC Predators Soccer',
  'WC Predators Soccer',
  'wc-predators',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'cc0a73d9-c4c7-4fab-8260-50257ed8701d',
  '811c2df6-d140-46cb-8266-de145c17dc7f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Alloy Soccer Club Soccer',
  'Alloy Soccer Club Soccer',
  'alloy-soccer-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '51c3b20f-1681-45b2-8cf7-cd2e6b0f9264',
  '832495ff-9eaa-49fc-8c11-3865e2d0f372',
  '550e8400-e29b-41d4-a716-446655440101',
  'Oaklyn United FC Soccer',
  'Oaklyn United FC Soccer',
  'oaklyn-united-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a089a74e-73b4-43e8-87d1-688a34caae28',
  '529aa852-3ca1-49d4-8713-d891f85edc5c',
  '550e8400-e29b-41d4-a716-446655440101',
  'Real Central NJ Soccer Soccer',
  'Real Central NJ Soccer Soccer',
  'real-central-nj-soccer',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd7339ee3-602e-48b7-80e6-039f57f6b70a',
  'cbcbb423-6599-4e69-8469-06b964fd5086',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philadelphia Heritage SC Soccer',
  'Philadelphia Heritage SC Soccer',
  'philadelphia-heritage-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b86f88d6-f571-46be-8320-f5787bfe9aa6',
  '1caf8458-8fae-406f-84dd-73d20799afcc',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philadelphia Soccer Club Soccer',
  'Philadelphia Soccer Club Soccer',
  'philadelphia-soccer-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '80153302-026d-4f55-8b83-4e76e2aa618a',
  '0fdf9eb0-4340-4961-8aff-4f32d845084c',
  '550e8400-e29b-41d4-a716-446655440101',
  'Vidas United FC Soccer',
  'Vidas United FC Soccer',
  'vidas-united-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a08a3157-afd8-42e1-8cab-354957d41039',
  '28d6f64d-604d-4c97-84a6-b474cb20dd58',
  '550e8400-e29b-41d4-a716-446655440101',
  'GAK Soccer',
  'GAK Soccer',
  'gak',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9',
  '235a623c-7368-4c4e-8984-d42da5a47abf',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lighthouse 1893 SC Soccer',
  'Lighthouse 1893 SC Soccer',
  'lighthouse-1893-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '889c65df-5239-4619-8a60-c6779010890c',
  'b84f3d23-8cb8-4349-87a2-5539798bba90',
  '550e8400-e29b-41d4-a716-446655440101',
  'Jersey Shore Boca Soccer',
  'Jersey Shore Boca Soccer',
  'jersey-shore-boca',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '86786fcb-7d0e-4fc4-842e-66e52da45c17',
  '9da3119e-0c1e-4f02-84c2-44fdb73e04bb',
  '550e8400-e29b-41d4-a716-446655440101',
  'Sewell Old Boys FC Soccer',
  'Sewell Old Boys FC Soccer',
  'sewell-old-boys-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a75542c8-615c-45c8-8d47-c91ebb35e98e',
  'c386fcfe-92ac-472b-8f00-db1391129c34',
  '550e8400-e29b-41d4-a716-446655440101',
  'Medford Strikers Soccer',
  'Medford Strikers Soccer',
  'medford-strikers',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '118fbc40-e5b7-4175-8f3f-ac4d7049b178',
  'a9c31157-c88a-4386-84f2-e00ec868d693',
  '550e8400-e29b-41d4-a716-446655440101',
  'Nova FC Soccer',
  'Nova FC Soccer',
  'nova-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'fce9c885-407e-421f-8a33-05321fa142ff',
  '24aad489-ec8c-4b8d-8161-cec655384412',
  '550e8400-e29b-41d4-a716-446655440101',
  'VA Marauders FC Soccer',
  'VA Marauders FC Soccer',
  'va-marauders-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '167450a2-5141-42f0-8b81-95b2d9708842',
  '2cf46ee9-e543-45ad-814b-d701d23e31ef',
  '550e8400-e29b-41d4-a716-446655440101',
  'Wave FC Soccer',
  'Wave FC Soccer',
  'wave-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1e3bcd56-becf-4af8-8b45-5fc2e8ffbac8',
  '18da6af3-fcd0-463b-86ef-af7b7ad9d2fe',
  '550e8400-e29b-41d4-a716-446655440101',
  'PFA EPSL Soccer',
  'PFA EPSL Soccer',
  'pfa-epsl',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd8259b20-89e3-457f-8060-5517c169649d',
  '3c358fec-6574-4a92-8461-12c10bf33db1',
  '550e8400-e29b-41d4-a716-446655440101',
  'Grove Soccer United Soccer',
  'Grove Soccer United Soccer',
  'grove-soccer-united',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '51b1b28d-3c61-450d-8191-e4dc8588eaef',
  '61f1b43e-12c0-4a67-8ee4-643b084acaf7',
  '550e8400-e29b-41d4-a716-446655440101',
  'Christos FC Soccer',
  'Christos FC Soccer',
  'christos-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b44b8381-73c0-4f24-8f20-9990102ee8eb',
  '7e5d39f0-30dc-4373-8559-143a6e258117',
  '550e8400-e29b-41d4-a716-446655440101',
  'Delmarva Thunder Soccer',
  'Delmarva Thunder Soccer',
  'delmarva-thunder',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '223db133-be8b-49a8-8f8d-53af6bdb02b1',
  '4e02053c-fefe-444b-8ea9-59237b240715',
  '550e8400-e29b-41d4-a716-446655440101',
  'PW Nova Soccer',
  'PW Nova Soccer',
  'pw-nova',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'f614e56a-63d3-42d0-89a1-886c19c690b0',
  'a50fa2ac-80c8-43b8-8db8-6bbc5bb080f4',
  '550e8400-e29b-41d4-a716-446655440101',
  'Terminus FC Soccer',
  'Terminus FC Soccer',
  'terminus-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '97f84a4b-f554-4258-8f9c-0b237dbf23a6',
  '3eaffe22-c329-448a-8c6b-47907004a14f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Prima FC Soccer',
  'Prima FC Soccer',
  'prima-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '11af0792-9062-452a-8153-198951479489',
  '5a9bf59b-1f1b-4b7d-8b4b-cf94c76df8b5',
  '550e8400-e29b-41d4-a716-446655440101',
  'Majestic SC Soccer',
  'Majestic SC Soccer',
  'majestic-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '74afeac9-3f54-421c-826f-4040c925f8e9',
  '79cf94c1-0331-4d55-8632-c6d5da0306b9',
  '550e8400-e29b-41d4-a716-446655440101',
  'Peachtree FC Soccer',
  'Peachtree FC Soccer',
  'peachtree-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b34fa7ec-fa63-4197-8381-82205ec5c57e',
  'ea147695-940c-431d-8628-dedf9a441c24',
  '550e8400-e29b-41d4-a716-446655440101',
  'Bel Calcio FC Soccer',
  'Bel Calcio FC Soccer',
  'bel-calcio-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '702f4429-deca-4b77-835b-c63c056e1762',
  'cb9d08f1-bc2c-4a9f-8a10-c5f5480bb69d',
  '550e8400-e29b-41d4-a716-446655440101',
  'Buckhead SC Soccer',
  'Buckhead SC Soccer',
  'buckhead-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '59b6ecd4-d535-451c-886e-7a7f51e62bb3',
  'db5e4d7e-d10e-4b77-8486-010998f20bba',
  '550e8400-e29b-41d4-a716-446655440101',
  'Alliance SC Soccer',
  'Alliance SC Soccer',
  'alliance-sc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'fd837c14-9e45-4dab-820c-0026e5954b54',
  'f2331b6a-9534-4790-8f67-a458db904a51',
  '550e8400-e29b-41d4-a716-446655440101',
  'SC Gwinnett Soccer',
  'SC Gwinnett Soccer',
  'sc-gwinnett',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'e7bd5270-3f8a-4c87-8a57-7cea8c73a638',
  'daebd418-b752-4a87-8292-4e1dcf06ec88',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lithonia City FC Soccer',
  'Lithonia City FC Soccer',
  'lithonia-city-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  NULL,
  NULL
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
