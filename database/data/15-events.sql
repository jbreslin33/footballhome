-- ========================================
-- EVENTS (APSL MATCHES)
-- ========================================
-- Generated: 2025-12-03T19:19:53.579Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================


-- Note: Events are scraped from APSL fixtures page
-- Deduplication key: home_team + away_team + event_date

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'fb6627a7-177d-0010-0e52-42a6b86ac0bc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Fitchburg FC',
  '2025-09-13 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f71c69b9-5977-0010-388c-000b85994e2b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Falcons FC',
  '2025-09-21 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e500c934-5077-0010-658a-4b89dcc5f190',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Falcons FC',
  '2025-09-28 17:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0a5dd818-b498-0010-968c-a8a68c74319d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Falcons FC',
  '2025-10-05 15:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '80f00296-1771-0010-22b3-4d31768d9cc7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Falcons FC',
  '2025-10-26 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7cdd1cb0-93d2-0010-cb56-87a02eccf351',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sete Setembro USA vs Falcons FC',
  '2025-11-01 15:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '762b6f18-8a9d-0010-b923-1840dc51947a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs Invictus FC',
  '2025-11-06 19:15:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a2a7e585-9480-0010-0ee0-d7c7993b4f23',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Falcons FC',
  '2025-11-09 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ca7129f5-e9d5-0010-b136-46fd010a5f75',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Falcons FC vs South Coast Union',
  '2025-11-20 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '281e7eda-92a6-0010-ea85-1f59c66f8c28',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Invictus FC',
  '2026-08-24 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '413f311d-8b1e-0010-642c-ad48960f75da',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Praia Kapital',
  '2025-09-06 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e124d342-7409-0010-ba8c-347bf88ce401',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Invictus FC',
  '2025-09-14 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a829c863-0a4f-0010-f1b1-5c0edcc7ef87',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Praia Kapital',
  '2025-09-21 13:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '32382ba9-8c3b-0010-66e2-36ed7517b7ba',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Scrub Nation',
  '2025-09-28 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '96d2a978-2c84-0010-f14c-ab6f327774d0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Sete Setembro USA',
  '2025-10-05 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '787dcd51-453b-0010-afb3-f0bdd03d21ac',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Praia Kapital vs Fitchburg FC',
  '2025-10-12 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'bcd51dae-5b2a-0010-5b09-26cdd47e5c8f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sete Setembro USA vs Praia Kapital',
  '2025-11-03 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '82d78b86-9a04-0010-86cd-58c9fed6a9c8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Scrub Nation',
  '2026-08-24 14:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ef646521-f8a6-0010-88f0-c78eef6f2f02',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Scrub Nation',
  '2025-09-07 15:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'b6069f2d-7b2d-0010-5f89-8688b8e12d6b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Scrub Nation',
  '2025-09-14 13:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '3ca28b17-85b3-0010-3d25-1598dbac64e2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Sete Setembro USA',
  '2025-09-24 20:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '48cd03d6-9d40-0010-ce2b-c49ad6a1b57c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Scrub Nation',
  '2025-10-19 11:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '76f66969-5323-0010-a303-af4fe9b156d5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Scrub Nation vs Fitchburg FC',
  '2025-10-26 12:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c42a18f7-abab-0010-c07a-425a84794585',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Sete Setembro USA',
  '2025-09-06 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '08c068e7-8c5d-0010-bd14-1cf2c5bddcf8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sete Setembro USA vs Project Football',
  '2025-09-27 18:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '945bfc1c-2aed-0010-1a96-7e54ac378c55',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sete Setembro USA vs Invictus FC',
  '2025-10-11 18:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a004cc3f-d25b-0010-3113-94dad38c08f0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sete Setembro USA vs South Coast Union',
  '2025-10-25 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'db60c6f7-4303-0010-6751-0778a6f743f6',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs South Coast Union',
  '2025-09-28 15:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c3f0daf0-c4c3-0010-154f-2b42d510c23e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Project Football',
  '2025-10-05 12:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2e38917e-d3ef-0010-8d8f-d1e58f41836b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs South Coast Union',
  '2025-10-19 13:45:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '87a8522e-d795-0010-7a1b-5d37e626cbcb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'South Coast Union vs Project Football',
  '2025-11-09 13:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '017547b5-ed74-0010-8785-c982d7e33896',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Fitchburg FC vs Project Football',
  '2026-08-24 17:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9c72f9a4-ccd5-0010-3b90-2028ec552963',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Project Football vs Invictus FC',
  '2025-10-25 18:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '83f0343b-607c-0010-67de-7893f76ffd36',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Invictus FC vs Fitchburg FC',
  '2025-09-21 13:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '24ca0cb2-67cf-0010-8823-af5d1368caba',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs KO Elites',
  '2025-09-06 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c510b8ef-300f-0010-1984-7e82ad889c00',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Glastonbury Celtic',
  '2025-09-13 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '8dc4b5fd-76c0-0010-4225-c7c5d4fdbaff',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Wildcat FC',
  '2025-09-20 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ae75ea2f-9932-0010-b4a9-e0bde8be3284',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs KO Elites',
  '2025-09-28 18:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '464f8577-6900-0010-2a5c-d6158b0a6b95',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'KO Elites vs Hermandad Connecticut',
  '2025-10-18 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f72e3406-f37c-0010-1301-633372595108',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs KO Elites',
  '2025-10-26 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '6ecf349d-160d-0010-6400-6f5b55d969a9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs Wildcat FC',
  '2025-09-07 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0bb634b1-126f-0010-6005-c703c1e488b0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs Glastonbury Celtic',
  '2025-09-20 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7b7c6c47-efb0-0010-5e2d-a53c946fdd8e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Glastonbury Celtic vs Hermandad Connecticut',
  '2025-09-28 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'd20ef527-4931-0010-2830-a852bc6c5ad3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs Glastonbury Celtic',
  '2025-10-19 18:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '07bf8c0c-95e5-0010-c3ce-16df2cc1e977',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wildcat FC vs Hermandad Connecticut',
  '2025-09-14 18:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '93c821af-9bf1-0010-acf1-a255e718b3ec',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hermandad Connecticut vs Wildcat FC',
  '2025-10-26 12:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2f846e46-5d27-0010-de13-eb98dae26ac1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Doxa FCW',
  '2025-09-07 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '8ec5861b-ac22-0010-e967-36535a5acaa4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Richmond County FC',
  '2025-09-21 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '10e547c7-7fb2-0010-7b61-488c42e2b992',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs NY Pancyprian Freedoms',
  '2025-09-28 21:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '6c04115a-8edd-0010-ed15-f41ba0b8a507',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs NY Greek Americans',
  '2025-10-01 20:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1eb87b78-de4a-0010-7899-f22932ccaa25',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs NY Greek Americans',
  '2025-10-05 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0cb606f8-03d0-0010-e8c1-00100a5867ad',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs NY Greek Americans',
  '2025-10-23 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '8f524925-8a12-0010-80b7-f261a18d49eb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs Leros SC',
  '2025-10-26 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c3b21359-ce04-0010-7116-469dcd5010ad',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Greek Americans vs SC Vistula Garfield',
  '2025-11-12 21:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c5e61138-e74e-0010-029d-88f595d4c430',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs NY Greek Americans',
  '2025-11-15 19:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'edaecda6-de2c-0010-501e-0ddcf30fc2d9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs NY Greek Americans',
  '2025-11-23 14:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c2c23deb-99a3-0010-1dc9-b7f004cac10d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs NY Greek Americans',
  '2025-12-14 12:15:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c61b3fc7-f9eb-0010-7764-a70cfb8dcc71',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Leros SC',
  '2025-09-07 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f05d98d9-99e5-0010-bfb0-e056f2ec48f5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Hoboken FC 1912',
  '2025-09-14 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '91a3b5fa-3741-0010-bd1d-e4192b3955e5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Zum Schneider FC 03',
  '2025-09-21 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'd2a8e904-289c-0010-abfd-643c6f669901',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Hoboken FC 1912',
  '2025-09-28 12:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a33bafa6-365f-0010-84ba-1f533de288d0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Hoboken FC 1912',
  '2025-10-23 21:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'be7abea0-cde4-0010-2bce-c7ecb10e29fe',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Hoboken FC 1912',
  '2025-10-26 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '75d5b815-5a47-0010-5519-58dc6b0673ed',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Hoboken FC 1912',
  '2025-11-06 20:45:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '02b3873f-a21e-0010-c206-60dea90b9ddf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs SC Vistula Garfield',
  '2025-11-19 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '02da5ee6-154d-0010-f2c5-9d15a90e0ce2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Hoboken FC 1912 vs Doxa FCW',
  '2025-11-23 16:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '05b1e09c-0a8d-0010-5487-ff668dea9aed',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Hoboken FC 1912',
  '2025-12-14 16:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '05f4f0b0-4be5-0010-a607-7f6842665da7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs NY Pancyprian Freedoms',
  '2025-09-07 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '25f83c38-a683-0010-0a18-afd9c670dd46',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Central Park Rangers FC',
  '2025-09-21 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '18db8286-2d20-0010-1892-b9164977a74c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs NY Pancyprian Freedoms',
  '2025-10-01 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0215b258-403a-0010-51ec-1b42fd0a0e68',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs NY Pancyprian Freedoms',
  '2025-10-05 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1f18d8d2-e203-0010-c05d-87e73a9b2636',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Doxa FCW',
  '2025-10-22 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '43303689-b25c-0010-0d14-ebc9a141c950',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Lansdowne Yonkers FC',
  '2025-10-26 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a8be6113-ebf7-0010-33e1-8e773bea1b61',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs NY Pancyprian Freedoms',
  '2025-11-02 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '11320df9-ae6f-0010-30e2-7d7f8cea4e56',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs Richmond County FC',
  '2025-11-16 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7ad95bbe-df7c-0010-d01c-674ce91f076d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Pancyprian Freedoms vs NY Athletic Club',
  '2025-11-23 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c5c00b47-b9de-0010-4219-d36f8d1d4300',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs NY Athletic Club',
  '2025-09-06 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7c8f3983-2251-0010-6ad6-c051df1bb25c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs Leros SC',
  '2025-09-20 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '32f5fe19-ae51-0010-480b-11d6a43e5cb9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Lansdowne Yonkers FC',
  '2025-09-25 20:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '26dfbbb8-6080-0010-6d07-2902352ff655',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Lansdowne Yonkers FC',
  '2025-09-28 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '25e40acd-3948-0010-d853-35cc74513ce1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Lansdowne Yonkers FC',
  '2025-10-05 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '95dbe38e-3887-0010-0137-b758f415676a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs NY International FC',
  '2025-10-14 20:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '20923737-4bf7-0010-2595-b629d7b3d5a3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lansdowne Yonkers FC vs SC Vistula Garfield',
  '2025-12-09 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'b9653b0d-d3bb-0010-0485-4ab8cd54560f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Lansdowne Yonkers FC',
  '2025-12-14 19:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'aa490894-6343-0010-c3e2-fa884a5eae2d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs NY Athletic Club',
  '2025-09-14 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '15eb796f-5e78-0010-4390-ae0a12ef2dec',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs NY International FC',
  '2025-09-28 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '732a734a-ed02-0010-bc16-cbb4998f9d2b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Zum Schneider FC 03',
  '2025-10-05 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '57232b5c-8efc-0010-04bc-1b9bf7b7c99f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Leros SC',
  '2025-10-30 20:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c7c622d9-30c9-0010-cafe-c46c0a4b78e1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Leros SC',
  '2025-11-16 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '26cf6d88-3f10-0010-9159-e8a4fcdaae1c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Leros SC vs Richmond County FC',
  '2025-11-23 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7d85e9fa-482e-0010-cd79-4a7b3726c271',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Leros SC',
  '2025-12-14 16:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a5bfceb2-3d7d-0010-788b-5d15faafa965',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs Doxa FCW',
  '2025-09-21 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0946146f-cc88-0010-3eda-3ac77a3e8cea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Richmond County FC',
  '2025-09-28 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '70992bb9-9f4d-0010-9624-5e63719d0bfe',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs NY Athletic Club',
  '2025-10-05 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '90ba37eb-5b56-0010-2356-dd8c14c9e74f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Doxa FCW vs Zum Schneider FC 03',
  '2025-10-26 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ab7814d1-76a4-0010-0791-8159e5255f6d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs Doxa FCW',
  '2025-11-02 16:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'fb38d5de-2c57-0010-4b09-2a83ec419433',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Doxa FCW',
  '2025-12-13 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'aa8d185c-069e-0010-74b7-91c39549cd6e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY International FC vs SC Vistula Garfield',
  '2025-09-07 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '59f81bec-9ef8-0010-c0e0-71559f34794b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs NY International FC',
  '2025-09-14 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f59e2569-09cc-0010-db03-43f81c667fee',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs NY International FC',
  '2025-11-02 12:15:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'd2972566-98b8-0010-50c2-be5c0d5d012d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Central Park Rangers FC vs NY International FC',
  '2025-11-16 16:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '14e104fb-7025-0010-7104-6ee4b747a1d7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs NY International FC',
  '2025-12-14 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c17c4a33-2dbf-0010-d389-adf95e44d841',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs Central Park Rangers FC',
  '2025-09-07 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '34cda3f9-fa45-0010-2530-18a1f270ff99',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs NY Athletic Club',
  '2025-10-12 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '960cc3ea-b5d6-0010-0665-3694acac3d11',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Richmond County FC vs SC Vistula Garfield',
  '2025-10-26 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '549c00ba-5bdc-0010-3158-c4eba5cc7992',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Richmond County FC',
  '2025-11-20 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '924922fa-36c9-0010-31fb-a590c5857a7f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Zum Schneider FC 03',
  '2025-09-27 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e1aabdb0-7152-0010-ff03-ca37690fecd0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Zum Schneider FC 03',
  '2025-11-16 12:15:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '72550f76-a017-0010-f66a-9e15284c9b4a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Zum Schneider FC 03 vs Central Park Rangers FC',
  '2025-12-07 19:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '6511aed0-62dd-0010-37b0-782f93fdda35',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs SC Vistula Garfield',
  '2025-09-21 12:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '34bdc107-efbd-0010-f351-103b99cff3ea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Vistula Garfield vs Central Park Rangers FC',
  '2025-11-09 19:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '32daf988-6b87-0010-125c-4efeb08d3aed',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'NY Athletic Club vs Central Park Rangers FC',
  '2025-10-26 12:15:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f1bef096-9cea-0010-eb0f-77a8e1c79239',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Jersey Shore Boca',
  '2025-09-06 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'aed65cf5-b5ce-0010-f2f1-5ffb5dc1b632',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs WC Predators',
  '2025-09-14 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9995639a-1483-0010-041b-ea051022570b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs WC Predators',
  '2025-09-21 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '27d0ebeb-3a2b-0010-5c84-2ca909c22271',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Oaklyn United FC',
  '2025-09-27 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'cbf94fcc-88ba-0010-3af9-24a37149ec44',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Real Central NJ Soccer',
  '2025-10-04 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '453db044-089f-0010-6d44-a8a4bc01aaf2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs WC Predators',
  '2025-10-11 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '996d41c0-5d92-0010-0306-28c4438d2137',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs WC Predators',
  '2025-10-22 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '4d7066ff-45a7-0010-7977-b54604002112',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Philadelphia Soccer Club',
  '2025-11-02 14:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7f90f7d0-d5dc-0010-e1ea-faf273cac4cc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs WC Predators',
  '2025-11-09 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e2d1c423-ff84-0010-31cb-8ae9f677c79c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs WC Predators',
  '2025-11-22 19:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a1758519-983f-0010-2d6f-def2007edd26',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'WC Predators vs Lighthouse 1893 SC',
  '2025-12-02 20:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f5edc8d1-88ec-0010-b5d9-d4507b599596',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Alloy Soccer Club',
  '2025-09-07 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e0ae2439-2d8f-0010-c5bb-f708ff80431f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Philadelphia Soccer Club',
  '2025-09-13 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c62cd1ea-cbac-0010-c4d0-5eb6faa473dd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Oaklyn United FC',
  '2025-09-20 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2332e5d9-2732-0010-83d6-33ed2a1270cc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Alloy Soccer Club',
  '2025-09-28 18:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'bfe395ea-931b-0010-446d-0f3533bd7d49',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Alloy Soccer Club',
  '2025-10-18 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2f1c2a2e-7e37-0010-ddca-2e96042669ee',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Vidas United FC',
  '2025-11-01 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '048cfe3b-118a-0010-b926-6d3596fc19d5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Alloy Soccer Club',
  '2025-11-09 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0cf6dae6-7f85-0010-7478-8a2331f6f3f9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Alloy Soccer Club',
  '2025-11-16 11:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '01641e5f-5bea-0010-b8c4-c8594b9bb3f8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs Lighthouse 1893 SC',
  '2025-11-22 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a6c0de1a-8d78-0010-31b4-38350124b62c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alloy Soccer Club vs GAK',
  '2025-12-06 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '271bdf02-140f-0010-f77d-b6596b2f7345',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Jersey Shore Boca',
  '2025-09-14 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'b62d88fc-84aa-0010-9a28-0555bfa1e37b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Vidas United FC',
  '2025-09-28 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '015b3194-1a50-0010-bf37-7e970992e835',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Philadelphia Heritage SC',
  '2025-10-05 15:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '476185c1-2d89-0010-9f7c-d285f44201fe',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Philadelphia Heritage SC',
  '2025-10-12 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f0d02370-2598-0010-27c1-06418b3aba76',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Philadelphia Heritage SC',
  '2025-10-19 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1bb786c9-ebdf-0010-9112-26b30f6f6c00',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Philadelphia Heritage SC',
  '2025-10-26 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e4b217dd-b440-0010-1c61-dc4e3d08c715',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Philadelphia Heritage SC',
  '2025-11-15 19:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '46b39520-1d27-0010-263b-587ccbfed708',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Philadelphia Heritage SC',
  '2025-11-23 19:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f1e27c31-fe9e-0010-faa5-017c21de2588',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Heritage SC vs Philadelphia Soccer Club',
  '2025-12-07 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c7569806-c7ed-0010-6a46-da343db1aa8b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Real Central NJ Soccer',
  '2025-09-21 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0da0b566-7ce2-0010-0be6-f071bfbd6d02',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Philadelphia Soccer Club',
  '2025-09-28 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2bb4a2f8-9fea-0010-e295-b50a0d9034ea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Real Central NJ Soccer',
  '2025-10-01 21:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1e7a8ecc-a1c4-0010-326b-a7d238305ae1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Real Central NJ Soccer',
  '2025-10-19 18:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9593c33d-3b41-0010-311a-bfbb4017a168',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Medford Strikers',
  '2025-11-02 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '44628598-1cc3-0010-36ef-c7e21cff4a97',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Real Central NJ Soccer',
  '2025-11-14 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a7bf143c-5dd0-0010-3e94-f91a3eaef7b4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Real Central NJ Soccer vs Sewell Old Boys FC',
  '2025-12-03 20:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '4542e3ba-8e01-0010-bc05-ae0309dc3b33',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Real Central NJ Soccer',
  '2025-12-14 11:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '83897176-e489-0010-12f8-8c21bf33be9a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Sewell Old Boys FC',
  '2025-09-07 12:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e17243f7-0777-0010-38a5-abd34433d83a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Vidas United FC',
  '2025-09-21 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '01a082b5-0bc4-0010-539c-7da180d9dfcd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Oaklyn United FC',
  '2025-10-05 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'd5bfde76-ec60-0010-c1a7-32ce74ab96cd',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs Lighthouse 1893 SC',
  '2025-10-12 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1d0589c6-9dc8-0010-3a67-114900096f7e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Vidas United FC vs GAK',
  '2025-10-19 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '89d626aa-e31e-0010-a20a-de5ce6e5fe2b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Vidas United FC',
  '2025-11-08 19:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '8df31549-a546-0010-34ca-5575b5cd69a4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Vidas United FC',
  '2025-11-23 18:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '3a16a16a-c084-0010-afae-a7cc094141c4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Philadelphia Soccer Club',
  '2025-09-07 16:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '86acfee7-2688-0010-5351-29a32ccc1c60',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Medford Strikers',
  '2025-10-05 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '079bb690-21c2-0010-5a3c-0eb2b19f0de4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Jersey Shore Boca',
  '2025-10-12 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '16ae19d1-7657-0010-dc82-ec877b581123',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs GAK',
  '2025-11-20 20:45:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '385fd330-6a67-0010-9e0e-97b6b9ff4a56',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Sewell Old Boys FC',
  '2025-11-23 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '44f2e6e9-55be-0010-2caf-49ea763bfaa0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Philadelphia Soccer Club vs Oaklyn United FC',
  '2025-12-14 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '00caebff-8747-0010-9c75-6916fe711703',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Medford Strikers',
  '2025-09-07 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2ecc44ff-67cf-0010-f00d-e7320fc98fd1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Oaklyn United FC',
  '2025-09-17 20:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'abf20dc2-816b-0010-7915-51d41fda152e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Oaklyn United FC',
  '2025-11-09 13:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c5e2d5a6-7a7b-0010-f49d-11a1cd720c46',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Jersey Shore Boca',
  '2025-12-05 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9da17937-c7b8-0010-3b52-4ab9e21db327',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Oaklyn United FC vs Sewell Old Boys FC',
  '2025-12-07 19:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '944162c2-77ec-0010-9e59-58f33ad96bfb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Medford Strikers',
  '2025-09-21 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'd7b4bc5a-2527-0010-9643-9523e0dd6a57',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs GAK',
  '2025-10-05 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '33e604ce-de19-0010-3b9b-b51202cbcb84',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'GAK vs Lighthouse 1893 SC',
  '2025-11-13 21:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2b6e517f-f361-0010-2cb0-11299811c0aa',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs GAK',
  '2025-12-14 18:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '3f2448fd-241d-0010-228c-f779fed9f494',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lighthouse 1893 SC vs Medford Strikers',
  '2025-09-14 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'dae1883b-0cb8-0010-d872-479f832e4860',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Lighthouse 1893 SC',
  '2025-09-28 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '01c3fd11-7fc1-0010-6f7b-45bdb4ef68e3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Lighthouse 1893 SC',
  '2025-11-30 18:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '43858e61-0adf-0010-150e-313f26a100b4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Sewell Old Boys FC vs Jersey Shore Boca',
  '2025-09-21 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '31647180-885c-0010-c40b-c26a3ae70f86',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Jersey Shore Boca vs Medford Strikers',
  '2025-11-20 20:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a7f7f3cf-8752-0010-e41d-285be0b5abe7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Medford Strikers vs Sewell Old Boys FC',
  '2025-10-11 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '3f735d12-7d20-0010-dd53-46d249afa6f3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Grove Soccer United',
  '2025-09-13 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9e448fb0-fe0d-0010-cf4a-d83cbaff8a8a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Delmarva Thunder',
  '2025-09-20 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '6db2c26b-04c7-0010-9155-7cd2b844cd03',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Nova FC',
  '2025-09-28 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '4558d6b3-d7b7-0010-6237-069785587f6c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs PFA EPSL',
  '2025-10-04 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '2e75f1bf-c9fd-0010-2519-cb15c463a5a1',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Wave FC',
  '2025-10-25 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f5e9b5ac-3d73-0010-863d-e1b00b2e20e2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Nova FC',
  '2025-11-08 19:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'b19a3ecf-26d2-0010-1263-da16d23b2631',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Nova FC',
  '2025-11-09 19:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '3b9c79d2-5835-0010-2f7d-ea56845cf80a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Nova FC vs Christos FC',
  '2025-11-16 19:45:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'b15a23d2-1ed4-0010-dc27-8095f2346b20',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Wave FC',
  '2025-09-21 17:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '118e9309-abb6-0010-38c1-f9700950aa91',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs Wave FC',
  '2025-09-27 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e9e6c99a-4486-0010-c9fc-030176f22be8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs Delmarva Thunder',
  '2025-10-04 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f5db194e-8e6a-0010-ac6a-69b8533db876',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs PW Nova',
  '2025-11-02 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ca468457-54e6-0010-9198-6a20f8e5ba2f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs Grove Soccer United',
  '2025-11-08 13:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ac2139dc-903b-0010-9791-ab97eddcfd61',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Wave FC vs VA Marauders FC',
  '2025-11-22 15:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '4a7a181b-c4be-0010-3c7a-1fea9dfd83d7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs PW Nova',
  '2025-09-14 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9aca1ca4-86e4-0010-edd7-cc6eadf0cf3b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Christos FC',
  '2025-09-27 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'af112350-c106-0010-5d44-829e150b2d72',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs VA Marauders FC',
  '2025-10-25 16:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '6d85481c-c617-0010-8ae1-9f34457ad2ca',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Grove Soccer United',
  '2025-11-02 17:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '633c92c7-d25f-0010-e792-a020e6162728',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs PFA EPSL',
  '2025-11-16 18:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ca3848e4-5a68-0010-feea-c570bebd6bc5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'VA Marauders FC vs Delmarva Thunder',
  '2025-12-06 12:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9f6ee819-d04d-0010-eda9-98c04802f073',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Grove Soccer United',
  '2025-09-21 19:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a9754bbd-6d5b-0010-7838-f86d8fe11cc5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs Grove Soccer United',
  '2025-10-18 19:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '44ce2434-702d-0010-a159-68e5bdf10460',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs Delmarva Thunder',
  '2025-11-15 14:45:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '520ebcf6-a099-0010-7d42-b726e5423c20',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Grove Soccer United vs PW Nova',
  '2025-11-16 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f27e497e-6733-0010-7fde-ed0d3222277e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PW Nova vs Christos FC',
  '2025-10-05 20:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'fefddfa7-174f-0010-2dcc-af70520496f9',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Christos FC',
  '2025-10-25 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'ea52330d-c0e2-0010-2a5a-cb9fb141eb07',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs Delmarva Thunder',
  '2025-11-15 15:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c83be80a-f690-0010-ecda-808e06bf9f91',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Christos FC vs PFA EPSL',
  '2025-11-22 17:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'faf7d847-7725-0010-5767-156e742251ae',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs PFA EPSL',
  '2025-09-27 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '3d1d184a-8640-0010-135f-0d117b4487de',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs Delmarva Thunder',
  '2025-10-18 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '41c7738f-1359-0010-761b-017f11356860',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'PFA EPSL vs PW Nova',
  '2025-12-07 17:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'e5e03cd2-3bfa-0010-8fca-19cd00d5988a',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Delmarva Thunder vs PW Nova',
  '2025-11-08 15:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1be12713-da80-0010-6c6b-d06f9fcc4eaf',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Terminus FC',
  '2025-09-21 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7826a97a-3435-0010-6ef1-fea551809a19',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Terminus FC',
  '2025-09-28 09:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '5ba7b81d-6e79-0010-12ce-86050ab708a7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Majestic SC',
  '2025-10-05 09:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a6a24aa1-ebd5-0010-e2c0-57fd43af1325',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Buckhead SC',
  '2025-10-12 09:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'd6edf166-fd77-0010-6abb-1ddc1b5192a4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Terminus FC',
  '2025-10-26 17:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a01e0b8b-cd37-0010-6c1d-9656c8b4b1f4',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Terminus FC',
  '2025-11-09 09:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '82e290ca-0466-0010-daef-a5e0762d35e2',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Lithonia City FC',
  '2025-11-16 09:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c69d96ca-3a88-0010-cbed-03a4502fc104',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Terminus FC vs Bel Calcio FC',
  '2025-11-23 09:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '4e73d813-c960-0010-9ed3-d69eedf72853',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lithonia City FC vs Majestic SC',
  '2025-09-21 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'fbc56b1e-0b6b-0010-b10c-70873facb5e3',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Bel Calcio FC',
  '2025-09-28 10:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'd2cd9e2e-8c0b-0010-6566-0b7156f85969',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Majestic SC',
  '2025-10-19 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f5d8200c-c954-0010-27ab-fd55ef6a1959',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Buckhead SC',
  '2025-10-26 10:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '0a2b78fa-fe68-0010-eb2e-c54a15b2b06d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs SC Gwinnett',
  '2025-11-16 10:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'b72a896a-6494-0010-6306-68e9226d926d',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Majestic SC vs Peachtree FC',
  '2025-11-23 10:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '27375ac6-b217-0010-5464-dd3873eb3a8b',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Majestic SC',
  '2025-12-14 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'a6d032cd-6685-0010-0492-dc0c21f5f9f5',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Peachtree FC',
  '2025-09-21 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '785b2ef3-ba3a-0010-23b3-b2cdeba57413',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Peachtree FC',
  '2025-10-05 17:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '964657a9-caa3-0010-5d9f-f9a018ed4bfe',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Alliance SC',
  '2025-10-12 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'cdb1c5ac-70bf-0010-da75-57e57b70235c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lithonia City FC vs Peachtree FC',
  '2025-10-19 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '4973ebc1-64a8-0010-efca-17ec484cbb9f',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Bel Calcio FC',
  '2025-10-26 11:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '9beab712-4a6e-0010-7e2f-3f877c405d02',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Peachtree FC vs Prima FC',
  '2025-11-16 11:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '40f5d3e3-96a4-0010-b33a-dfe04de9f600',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Prima FC',
  '2025-10-05 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '281b035f-c91b-0010-0fdf-48d660133290',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Prima FC',
  '2025-10-19 12:30:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '7c38c113-d9ab-0010-77ed-4500f2033b5e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs SC Gwinnett',
  '2025-11-09 16:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'cf5cc33f-7c26-0010-341a-dc571bb5a903',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Prima FC vs Lithonia City FC',
  '2025-11-23 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'c41a5941-bd85-0010-cb78-f9f73738ddd8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Prima FC',
  '2025-12-07 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '4a72847b-03a6-0010-67c0-cdbdedfc64fc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs Bel Calcio FC',
  '2025-10-05 13:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1e81e224-67f4-0010-6a3f-e4b885c71f3e',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs SC Gwinnett',
  '2025-10-19 14:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '85429edb-eff9-0010-dec1-e8b172836dcb',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Lithonia City FC',
  '2025-11-09 14:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'b5ba618c-72a7-0010-0ec8-01b5a65e00f0',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Bel Calcio FC vs Alliance SC',
  '2025-11-16 14:30:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'cc89ae9a-3e08-0010-a6a6-72ae26f7feed',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lithonia City FC vs Buckhead SC',
  '2025-09-28 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '1041b424-dd78-0010-029c-77c783f3826c',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Alliance SC vs Buckhead SC',
  '2025-11-09 18:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'fc7b82bb-0fdb-0010-12c2-d397a67072e7',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Buckhead SC vs SC Gwinnett',
  '2025-11-23 13:00:00-05',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'baf5193c-a16a-0010-1b16-0fab94d985ea',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Alliance SC',
  '2025-09-28 15:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  'f68bbb7f-16e1-0010-661c-0d0c920ef3bc',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'Lithonia City FC vs Alliance SC',
  '2025-10-26 18:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  '8a1ec78b-9e5b-0010-a7ff-511b5a44dac8',
  '77d77471-1250-47e0-81ab-d4626595d63c',
  '550e8400-e29b-41d4-a716-446655440402',
  'SC Gwinnett vs Lithonia City FC',
  '2025-10-12 15:00:00-04',
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

