-- ========================================
-- MATCHES (APSL)
-- ========================================
-- Generated: 2025-12-07T21:45:47.777Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================


-- Note: Matches extend events with home/away team details
-- Includes scores for completed matches

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'fb6627a7-177d-0010-0e52-42a6b86ac0bc',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f71c69b9-5977-0010-388c-000b85994e2b',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e500c934-5077-0010-658a-4b89dcc5f190',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0a5dd818-b498-0010-968c-a8a68c74319d',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '80f00296-1771-0010-22b3-4d31768d9cc7',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7cdd1cb0-93d2-0010-cb56-87a02eccf351',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '762b6f18-8a9d-0010-b923-1840dc51947a',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a2a7e585-9480-0010-0ee0-d7c7993b4f23',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  8,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ca7129f5-e9d5-0010-b136-46fd010a5f75',
  '093a47d2-4a1d-0005-6ab0-93e9e96847d7',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '281e7eda-92a6-0010-ea85-1f59c66f8c28',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '413f311d-8b1e-0010-642c-ad48960f75da',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e124d342-7409-0010-ba8c-347bf88ce401',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a829c863-0a4f-0010-f1b1-5c0edcc7ef87',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '32382ba9-8c3b-0010-66e2-36ed7517b7ba',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '96d2a978-2c84-0010-f14c-ab6f327774d0',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '787dcd51-453b-0010-afb3-f0bdd03d21ac',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  8,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'bcd51dae-5b2a-0010-5b09-26cdd47e5c8f',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  '2a1d62b2-aa71-0005-a6eb-1657e21800bf',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '82d78b86-9a04-0010-86cd-58c9fed6a9c8',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ef646521-f8a6-0010-88f0-c78eef6f2f02',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'b6069f2d-7b2d-0010-5f89-8688b8e12d6b',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  4
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '3ca28b17-85b3-0010-3d25-1598dbac64e2',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '48cd03d6-9d40-0010-ce2b-c49ad6a1b57c',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '76f66969-5323-0010-a303-af4fe9b156d5',
  'cd2f494d-83b2-0005-7009-2d86f0e05d52',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  10,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c42a18f7-abab-0010-c07a-425a84794585',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '08c068e7-8c5d-0010-bd14-1cf2c5bddcf8',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  10,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '945bfc1c-2aed-0010-1a96-7e54ac378c55',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a004cc3f-d25b-0010-3113-94dad38c08f0',
  'a9f395bc-b644-0005-057d-97f0afc4ca9c',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'db60c6f7-4303-0010-6751-0778a6f743f6',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c3f0daf0-c4c3-0010-154f-2b42d510c23e',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2e38917e-d3ef-0010-8d8f-d1e58f41836b',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '87a8522e-d795-0010-7a1b-5d37e626cbcb',
  '3b1d4171-c61d-0005-82fe-0b134f83622d',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '017547b5-ed74-0010-8785-c982d7e33896',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9c72f9a4-ccd5-0010-3b90-2028ec552963',
  'd6dd2763-bfe0-0005-76b6-634bdffc6f2a',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '83f0343b-607c-0010-67de-7893f76ffd36',
  'aa0aab49-a007-0005-2697-8c6ceac5beb7',
  'b8ec25f4-b6b4-0005-ce33-0da183347d70',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '24ca0cb2-67cf-0010-8823-af5d1368caba',
  '5c979af3-1b0d-0005-afb1-07227c8fb58c',
  'a57bd844-e059-0005-1ea8-768f2a07223e',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c510b8ef-300f-0010-1984-7e82ad889c00',
  'a57bd844-e059-0005-1ea8-768f2a07223e',
  '265404b6-e493-0005-2586-5ba8bae74fcc',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '8dc4b5fd-76c0-0010-4225-c7c5d4fdbaff',
  'a57bd844-e059-0005-1ea8-768f2a07223e',
  '7f09e1bb-ee7f-0005-739b-caf0f540a273',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ae75ea2f-9932-0010-b4a9-e0bde8be3284',
  '7f09e1bb-ee7f-0005-739b-caf0f540a273',
  'a57bd844-e059-0005-1ea8-768f2a07223e',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '464f8577-6900-0010-2a5c-d6158b0a6b95',
  'a57bd844-e059-0005-1ea8-768f2a07223e',
  '5c979af3-1b0d-0005-afb1-07227c8fb58c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f72e3406-f37c-0010-1301-633372595108',
  '265404b6-e493-0005-2586-5ba8bae74fcc',
  'a57bd844-e059-0005-1ea8-768f2a07223e',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '6ecf349d-160d-0010-6400-6f5b55d969a9',
  '265404b6-e493-0005-2586-5ba8bae74fcc',
  '7f09e1bb-ee7f-0005-739b-caf0f540a273',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0bb634b1-126f-0010-6005-c703c1e488b0',
  '5c979af3-1b0d-0005-afb1-07227c8fb58c',
  '265404b6-e493-0005-2586-5ba8bae74fcc',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  5
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7b7c6c47-efb0-0010-5e2d-a53c946fdd8e',
  '265404b6-e493-0005-2586-5ba8bae74fcc',
  '5c979af3-1b0d-0005-afb1-07227c8fb58c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'd20ef527-4931-0010-2830-a852bc6c5ad3',
  '7f09e1bb-ee7f-0005-739b-caf0f540a273',
  '265404b6-e493-0005-2586-5ba8bae74fcc',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '07bf8c0c-95e5-0010-c3ce-16df2cc1e977',
  '7f09e1bb-ee7f-0005-739b-caf0f540a273',
  '5c979af3-1b0d-0005-afb1-07227c8fb58c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '93c821af-9bf1-0010-acf1-a255e718b3ec',
  '5c979af3-1b0d-0005-afb1-07227c8fb58c',
  '7f09e1bb-ee7f-0005-739b-caf0f540a273',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2f846e46-5d27-0010-de13-eb98dae26ac1',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '8ec5861b-ac22-0010-e967-36535a5acaa4',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '10e547c7-7fb2-0010-7b61-488c42e2b992',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '6c04115a-8edd-0010-ed15-f41ba0b8a507',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1eb87b78-de4a-0010-7899-f22932ccaa25',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  4
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0cb606f8-03d0-0010-e8c1-00100a5867ad',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '8f524925-8a12-0010-80b7-f261a18d49eb',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c3b21359-ce04-0010-7116-469dcd5010ad',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c5e61138-e74e-0010-029d-88f595d4c430',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'edaecda6-de2c-0010-501e-0ddcf30fc2d9',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c2c23deb-99a3-0010-1dc9-b7f004cac10d',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  'a9e2b1a8-5969-0005-f674-2f918d293250',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c61b3fc7-f9eb-0010-7764-a70cfb8dcc71',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f05d98d9-99e5-0010-bfb0-e056f2ec48f5',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  8,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '91a3b5fa-3741-0010-bd1d-e4192b3955e5',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'd2a8e904-289c-0010-abfd-643c6f669901',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a33bafa6-365f-0010-84ba-1f533de288d0',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'be7abea0-cde4-0010-2bce-c7ecb10e29fe',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '75d5b815-5a47-0010-5519-58dc6b0673ed',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '02b3873f-a21e-0010-c206-60dea90b9ddf',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '02da5ee6-154d-0010-f2c5-9d15a90e0ce2',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '05b1e09c-0a8d-0010-5487-ff668dea9aed',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '49df0225-be54-0005-699c-ee6cd5da686b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '05f4f0b0-4be5-0010-a607-7f6842665da7',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '25f83c38-a683-0010-0a18-afd9c670dd46',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '18db8286-2d20-0010-1892-b9164977a74c',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0215b258-403a-0010-51ec-1b42fd0a0e68',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1f18d8d2-e203-0010-c05d-87e73a9b2636',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '43303689-b25c-0010-0d14-ebc9a141c950',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a8be6113-ebf7-0010-33e1-8e773bea1b61',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '11320df9-ae6f-0010-30e2-7d7f8cea4e56',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7ad95bbe-df7c-0010-d01c-674ce91f076d',
  'cd0f7cdf-7018-0005-51d9-cafefed696e5',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c5c00b47-b9de-0010-4219-d36f8d1d4300',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7c8f3983-2251-0010-6ad6-c051df1bb25c',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '32f5fe19-ae51-0010-480b-11d6a43e5cb9',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '26dfbbb8-6080-0010-6d07-2902352ff655',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '25e40acd-3948-0010-d853-35cc74513ce1',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '95dbe38e-3887-0010-0137-b758f415676a',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '20923737-4bf7-0010-2595-b629d7b3d5a3',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'b9653b0d-d3bb-0010-0485-4ab8cd54560f',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  'fd2f4fc8-6cbd-0005-8199-96a395b40d55',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'aa490894-6343-0010-c3e2-fa884a5eae2d',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '15eb796f-5e78-0010-4390-ae0a12ef2dec',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '732a734a-ed02-0010-bc16-cbb4998f9d2b',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '57232b5c-8efc-0010-04bc-1b9bf7b7c99f',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c7c622d9-30c9-0010-cafe-c46c0a4b78e1',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  4
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '26cf6d88-3f10-0010-9159-e8a4fcdaae1c',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7d85e9fa-482e-0010-cd79-4a7b3726c271',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '77717fe0-fb4f-0005-cef3-260a0c447980',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a5bfceb2-3d7d-0010-788b-5d15faafa965',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0946146f-cc88-0010-3eda-3ac77a3e8cea',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '70992bb9-9f4d-0010-9624-5e63719d0bfe',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '90ba37eb-5b56-0010-2356-dd8c14c9e74f',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ab7814d1-76a4-0010-0791-8159e5255f6d',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'fb38d5de-2c57-0010-4b09-2a83ec419433',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '68b50f22-dddc-0005-06ca-622f3a3a0ea4',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'aa8d185c-069e-0010-74b7-91c39549cd6e',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '59f81bec-9ef8-0010-c0e0-71559f34794b',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f59e2569-09cc-0010-db03-43f81c667fee',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'd2972566-98b8-0010-50c2-be5c0d5d012d',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '14e104fb-7025-0010-7104-6ee4b747a1d7',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  'c99ade72-80a1-0005-bb2a-e36057334cac',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c17c4a33-2dbf-0010-d389-adf95e44d841',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '34cda3f9-fa45-0010-2530-18a1f270ff99',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  6
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '960cc3ea-b5d6-0010-0665-3694acac3d11',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '549c00ba-5bdc-0010-3158-c4eba5cc7992',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  'bad8aee7-4cea-0005-8995-4a25b932936d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '924922fa-36c9-0010-31fb-a590c5857a7f',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e1aabdb0-7152-0010-ff03-ca37690fecd0',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '72550f76-a017-0010-f66a-9e15284c9b4a',
  '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '6511aed0-62dd-0010-37b0-782f93fdda35',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '34bdc107-efbd-0010-f351-103b99cff3ea',
  '741624af-fbb6-0005-5186-2697c8c058e6',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '32daf988-6b87-0010-125c-4efeb08d3aed',
  '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6',
  '48a40f97-9111-0005-2e29-709bd3953df2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f1bef096-9cea-0010-eb0f-77a8e1c79239',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'aed65cf5-b5ce-0010-f2f1-5ffb5dc1b632',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9995639a-1483-0010-041b-ea051022570b',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '27d0ebeb-3a2b-0010-5c84-2ca909c22271',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'cbf94fcc-88ba-0010-3af9-24a37149ec44',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '453db044-089f-0010-6d44-a8a4bc01aaf2',
  '0223b314-0973-0005-f017-a5527b76a814',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '996d41c0-5d92-0010-0306-28c4438d2137',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '4d7066ff-45a7-0010-7977-b54604002112',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  10,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7f90f7d0-d5dc-0010-e1ea-faf273cac4cc',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  12,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e2d1c423-ff84-0010-31cb-8ae9f677c79c',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a1758519-983f-0010-2d6f-def2007edd26',
  '84a1029b-04c8-0005-5548-e180ad338d6b',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f5edc8d1-88ec-0010-b5d9-d4507b599596',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '0223b314-0973-0005-f017-a5527b76a814',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e0ae2439-2d8f-0010-c5bb-f708ff80431f',
  '0223b314-0973-0005-f017-a5527b76a814',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c62cd1ea-cbac-0010-c4d0-5eb6faa473dd',
  '0223b314-0973-0005-f017-a5527b76a814',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2332e5d9-2732-0010-83d6-33ed2a1270cc',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '0223b314-0973-0005-f017-a5527b76a814',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'bfe395ea-931b-0010-446d-0f3533bd7d49',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '0223b314-0973-0005-f017-a5527b76a814',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2f1c2a2e-7e37-0010-ddca-2e96042669ee',
  '0223b314-0973-0005-f017-a5527b76a814',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '048cfe3b-118a-0010-b926-6d3596fc19d5',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '0223b314-0973-0005-f017-a5527b76a814',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0cf6dae6-7f85-0010-7478-8a2331f6f3f9',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '0223b314-0973-0005-f017-a5527b76a814',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '01641e5f-5bea-0010-b8c4-c8594b9bb3f8',
  '0223b314-0973-0005-f017-a5527b76a814',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a6c0de1a-8d78-0010-31b4-38350124b62c',
  '0223b314-0973-0005-f017-a5527b76a814',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c7569806-c7ed-0010-6a46-da343db1aa8b',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0da0b566-7ce2-0010-0be6-f071bfbd6d02',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2bb4a2f8-9fea-0010-e295-b50a0d9034ea',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1e7a8ecc-a1c4-0010-326b-a7d238305ae1',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9593c33d-3b41-0010-311a-bfbb4017a168',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '44628598-1cc3-0010-36ef-c7e21cff4a97',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '46b39520-1d27-0010-263b-587ccbfed708',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a7bf143c-5dd0-0010-3e94-f91a3eaef7b4',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '4542e3ba-8e01-0010-bc05-ae0309dc3b33',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '5d95682c-0ec8-0005-0728-deae7986a2e0',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '271bdf02-140f-0010-f77d-b6596b2f7345',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'b62d88fc-84aa-0010-9a28-0555bfa1e37b',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '015b3194-1a50-0010-bf37-7e970992e835',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '476185c1-2d89-0010-9f7c-d285f44201fe',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f0d02370-2598-0010-27c1-06418b3aba76',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1bb786c9-ebdf-0010-9112-26b30f6f6c00',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e4b217dd-b440-0010-1c61-dc4e3d08c715',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  4
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f1e27c31-fe9e-0010-faa5-017c21de2588',
  '294a08ff-4f18-0005-c42b-a5fb0d5f0896',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '00caebff-8747-0010-9c75-6916fe711703',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2ecc44ff-67cf-0010-f00d-e7320fc98fd1',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '01a082b5-0bc4-0010-539c-7da180d9dfcd',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'abf20dc2-816b-0010-7915-51d41fda152e',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c5e2d5a6-7a7b-0010-f49d-11a1cd720c46',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9da17937-c7b8-0010-3b52-4ab9e21db327',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '44f2e6e9-55be-0010-2caf-49ea763bfaa0',
  '907ece9f-5926-0005-cff6-7672dec05648',
  'c2402f6c-0036-0005-d453-d68637ee8277',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '83897176-e489-0010-12f8-8c21bf33be9a',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e17243f7-0777-0010-38a5-abd34433d83a',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'd5bfde76-ec60-0010-c1a7-32ce74ab96cd',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1d0589c6-9dc8-0010-3a67-114900096f7e',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '89d626aa-e31e-0010-a20a-de5ce6e5fe2b',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '8df31549-a546-0010-34ca-5575b5cd69a4',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '3dd92f09-4a7d-0005-c554-60df95cfb846',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  4
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '3a16a16a-c084-0010-afae-a7cc094141c4',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '86acfee7-2688-0010-5351-29a32ccc1c60',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '079bb690-21c2-0010-5a3c-0eb2b19f0de4',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '16ae19d1-7657-0010-dc82-ec877b581123',
  '907ece9f-5926-0005-cff6-7672dec05648',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '385fd330-6a67-0010-9e0e-97b6b9ff4a56',
  '907ece9f-5926-0005-cff6-7672dec05648',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '944162c2-77ec-0010-9e59-58f33ad96bfb',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'd7b4bc5a-2527-0010-9643-9523e0dd6a57',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '33e604ce-de19-0010-3b9b-b51202cbcb84',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2b6e517f-f361-0010-2cb0-11299811c0aa',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  'f11cc01a-e8d3-0005-74f0-b00c38923236',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '3f2448fd-241d-0010-228c-f779fed9f494',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'dae1883b-0cb8-0010-d872-479f832e4860',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '01c3fd11-7fc1-0010-6f7b-45bdb4ef68e3',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '43858e61-0adf-0010-150e-313f26a100b4',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '31647180-885c-0010-c40b-c26a3ae70f86',
  '7288846b-402d-0005-9d60-70d5ffcc5588',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a7f7f3cf-8752-0010-e41d-285be0b5abe7',
  '77b6674f-d598-0005-fd48-227b9e088c41',
  '50720c09-2e57-0005-da39-afc85228aaa9',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '3f735d12-7d20-0010-dd53-46d249afa6f3',
  '4975b02e-8e62-0005-2030-8e154013c759',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  4
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9e448fb0-fe0d-0010-cf4a-d83cbaff8a8a',
  '4975b02e-8e62-0005-2030-8e154013c759',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  8,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '6db2c26b-04c7-0010-9155-7cd2b844cd03',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  '4975b02e-8e62-0005-2030-8e154013c759',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '4558d6b3-d7b7-0010-6237-069785587f6c',
  '4975b02e-8e62-0005-2030-8e154013c759',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '2e75f1bf-c9fd-0010-2519-cb15c463a5a1',
  '4975b02e-8e62-0005-2030-8e154013c759',
  '5cb8a2b2-4ca8-0005-2d81-819249f89f0d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f5e9b5ac-3d73-0010-863d-e1b00b2e20e2',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  '4975b02e-8e62-0005-2030-8e154013c759',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'b19a3ecf-26d2-0010-1263-da16d23b2631',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '4975b02e-8e62-0005-2030-8e154013c759',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '3b9c79d2-5835-0010-2f7d-ea56845cf80a',
  '4975b02e-8e62-0005-2030-8e154013c759',
  '226c892a-a28d-0005-ad0a-f9435e13f4e2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '4a7a181b-c4be-0010-3c7a-1fea9dfd83d7',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'b15a23d2-1ed4-0010-dc27-8095f2346b20',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  '5cb8a2b2-4ca8-0005-2d81-819249f89f0d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9aca1ca4-86e4-0010-edd7-cc6eadf0cf3b',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  '226c892a-a28d-0005-ad0a-f9435e13f4e2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'af112350-c106-0010-5d44-829e150b2d72',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '6d85481c-c617-0010-8ae1-9f34457ad2ca',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '633c92c7-d25f-0010-e792-a020e6162728',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ac2139dc-903b-0010-9791-ab97eddcfd61',
  '5cb8a2b2-4ca8-0005-2d81-819249f89f0d',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ca3848e4-5a68-0010-feea-c570bebd6bc5',
  '8d88ffe1-06ae-0005-6f19-0e9432e55afa',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '118e9309-abb6-0010-38c1-f9700950aa91',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '5cb8a2b2-4ca8-0005-2d81-819249f89f0d',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e9e6c99a-4486-0010-c9fc-030176f22be8',
  '5cb8a2b2-4ca8-0005-2d81-819249f89f0d',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f5db194e-8e6a-0010-ac6a-69b8533db876',
  '5cb8a2b2-4ca8-0005-2d81-819249f89f0d',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  10,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ca468457-54e6-0010-9198-6a20f8e5ba2f',
  '5cb8a2b2-4ca8-0005-2d81-819249f89f0d',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9f6ee819-d04d-0010-eda9-98c04802f073',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a9754bbd-6d5b-0010-7838-f86d8fe11cc5',
  '226c892a-a28d-0005-ad0a-f9435e13f4e2',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '44ce2434-702d-0010-a159-68e5bdf10460',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '520ebcf6-a099-0010-7d42-b726e5423c20',
  'cf7f17f3-b83d-0005-856e-8a0b8da24008',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f27e497e-6733-0010-7fde-ed0d3222277e',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  '226c892a-a28d-0005-ad0a-f9435e13f4e2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'fefddfa7-174f-0010-2dcc-af70520496f9',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '226c892a-a28d-0005-ad0a-f9435e13f4e2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'ea52330d-c0e2-0010-2a5a-cb9fb141eb07',
  '226c892a-a28d-0005-ad0a-f9435e13f4e2',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c83be80a-f690-0010-ecda-808e06bf9f91',
  '226c892a-a28d-0005-ad0a-f9435e13f4e2',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'faf7d847-7725-0010-5767-156e742251ae',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '3d1d184a-8640-0010-135f-0d117b4487de',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '41c7738f-1359-0010-761b-017f11356860',
  'd8e57bbb-92dd-0005-95c3-76a8d99bb683',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'e5e03cd2-3bfa-0010-8fca-19cd00d5988a',
  '171f448b-97a3-0005-b875-35f9861c31b6',
  '7425cb8d-f81d-0005-8a67-7aa5c9dd6023',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1be12713-da80-0010-6c6b-d06f9fcc4eaf',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7826a97a-3435-0010-6ef1-fea551809a19',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '5ba7b81d-6e79-0010-12ce-86050ab708a7',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a6a24aa1-ebd5-0010-e2c0-57fd43af1325',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'd6edf166-fd77-0010-6abb-1ddc1b5192a4',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a01e0b8b-cd37-0010-6c1d-9656c8b4b1f4',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  7,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '82e290ca-0466-0010-daef-a5e0762d35e2',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c69d96ca-3a88-0010-cbed-03a4502fc104',
  'f05b54ff-8886-0005-29cd-ff42c703f657',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  3
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '4e73d813-c960-0010-9ed3-d69eedf72853',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'fbc56b1e-0b6b-0010-b10c-70873facb5e3',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  1,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'd2cd9e2e-8c0b-0010-6566-0b7156f85969',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f5d8200c-c954-0010-27ab-fd55ef6a1959',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '0a2b78fa-fe68-0010-eb2e-c54a15b2b06d',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  18,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'b72a896a-6494-0010-6306-68e9226d926d',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '27375ac6-b217-0010-5464-dd3873eb3a8b',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  '55bd7a24-ba77-0005-81a4-2f5bfb50c614',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '40f5d3e3-96a4-0010-b33a-dfe04de9f600',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  6,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '281b035f-c91b-0010-0fdf-48d660133290',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '7c38c113-d9ab-0010-77ed-4500f2033b5e',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  14,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '9beab712-4a6e-0010-7e2f-3f877c405d02',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  0,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'cf5cc33f-7c26-0010-341a-dc571bb5a903',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'c41a5941-bd85-0010-cb78-f9f73738ddd8',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  '07e8c5da-df90-0005-7ef3-b55105901be2',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'a6d032cd-6685-0010-0492-dc0c21f5f9f5',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  4,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '785b2ef3-ba3a-0010-23b3-b2cdeba57413',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  12,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '964657a9-caa3-0010-5d9f-f9a018ed4bfe',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  9,
  2
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'cdb1c5ac-70bf-0010-da75-57e57b70235c',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '4973ebc1-64a8-0010-efca-17ec484cbb9f',
  'ec1718e1-142d-0005-ef5c-b49f0f144a3c',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '4a72847b-03a6-0010-67c0-cdbdedfc64fc',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1e81e224-67f4-0010-6a3f-e4b885c71f3e',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  8,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '85429edb-eff9-0010-dec1-e8b172836dcb',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'b5ba618c-72a7-0010-0ec8-01b5a65e00f0',
  '268164a2-111d-0005-9ea6-900cd6c9f197',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  2,
  4
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'cc89ae9a-3e08-0010-a6a6-72ae26f7feed',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '1041b424-dd78-0010-029c-77c783f3826c',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  3,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'fc7b82bb-0fdb-0010-12c2-d397a67072e7',
  '3ae0fc91-9acf-0005-06a7-2af9ccf19b51',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  13,
  0
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'baf5193c-a16a-0010-1b16-0fab94d985ea',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'completed',
  5,
  1
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  'f68bbb7f-16e1-0010-661c-0d0c920ef3bc',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  '6778fbca-ca21-0005-a2e2-d5b9dfc49df6',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  '8a1ec78b-9e5b-0010-a7ff-511b5a44dac8',
  'd2c80f1f-3aa2-0005-9951-cacab62cb9fc',
  'fcccc73d-ebb9-0005-64c9-ee520c7672f8',
  '550e8400-e29b-41d4-a716-446655440801',
  'APSL Regular Season',
  'scheduled',
  NULL,
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

