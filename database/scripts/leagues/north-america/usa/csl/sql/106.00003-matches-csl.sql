-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CSL
-- Total Records: 887
-- Match type: 1=league, 3=practice, 4=scrimmage
-- Match status: 1=scheduled, 3=completed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Matches
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 6,
  3, '227499_6DDF3347739D8AC3968218D03CA6C76A'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '227500_E16E47909D4C97CAD522106DB62213DA'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '227506_44CA2565E13A2EDC30BF2348447F82B5'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '227510_B307CB0C0BF98011EEB44ED9EF0A9CDC'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '15:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '227516_F7BAD16F0B5AD0994876847F982620C2'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '227521_68256686BEEFAF030205ABAFD82F6050'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '227527_B5515718173748D77EEBE1AF3ECB34A3'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 5,
  3, '227533_54E829C6F18F89D1B1CFD0B6F3A8A181'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '19:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '227544_B16BD20DB2E5F4BECCF6C776C1AAC872'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227546_557CDA1180C5DC7BFB5DE3A0F5A49AF0'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116435' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '261205_BECA633D785B62D7DF6BDFCD2F7627F0'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-14', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '261210_B0F5CE8C668D274EE0445381F1369F27'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261217_409929BA9F228F0C29A8147B9AF1F865'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261224_B2F7D0BB068EA9A8F3FBB511BBE9882A'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261228_29C7459A1D8D045325A92FBC047FE7E9'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-25', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261232_90FF02A59F2D58EDACF3F9E4A68E0E15'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-02', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261237_A9347AF3E25D14A1D7C5D39C929F1EE5'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '14:15:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261240_075168360A98CE0522A5A72E4DE529C8'
FROM teams ht
JOIN teams at ON at.external_id = '114828' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261246_E0B2ED1482DD52EAF92D08DECD201610'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '114828' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '21:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '233852_6911F70649C680A39E91E0C2E1909890'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '118361' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 6,
  3, '238210_1343062E4C0E0EE4C0990205FCE0744B'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238543_DDDD10E65589E02A1625A3377D4A8E12'
FROM teams ht
JOIN teams at ON at.external_id = '124917' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '15:30:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '238548_5074A43453A48055A0A1F9936F8F4F64'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, NULL,
  5, 6,
  3, '238556_6F296F18DAE2A46337652862BB3A9BB5'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, NULL,
  5, 8,
  3, '238566_D20512B1A722ACD9E9C5F07892D111F5'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, NULL,
  8, 2,
  3, '238573_9C6C9CD4A8884417303027B5066D35C0'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '238576_0B3C13C340048603B9A0600D5D99826A'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '238225_935747739042D23C6822A8FA8AFDBA5E'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '13:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238584_914E6C05F73A38F8CA8A8C1522479B50'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '263339_7E5FF5FF755502172932F10EE2F09886'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '08:00:00', 3,
  ht.id, at.id, NULL,
  0, 5,
  3, '263343_7B432EE25343B8AE764E266E37876523'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '19:30:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263350_7A2CB1D5841F42F4530D3B31CBCF44FF'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263355_643348BAC4CE9212ED5D394B1F2C9CC0'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266028_4C18BDA4EE6EFFC1B2F3F98AD8448FAE'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266034_A38E2F514313136749BA7B6326A15A49'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266039_08299DCB17D7F8932BA9E02CDDA4E086'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266047_96D59123ADD518B7B0FC50D7CCC117EE'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266051_3B65E2CEC2D57A808AE45B3CD9CA8499'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '116405' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266057_E7D1BF3330B1753B24E83F16FFCF77BC'
FROM teams ht
JOIN teams at ON at.external_id = '116405' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '233705_945764F24332B7F22A2CC1FBDC7CEAAA'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 6,
  3, '233712_66F0442E5132E53707652B975CEC7675'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '233716_E10551AF0B9F227A107979332C6E803E'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '233737_18D875BE42F0F8423F3EE8B65502A79A'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '16:00:00', 3,
  ht.id, at.id, NULL,
  4, 7,
  3, '233741_1D64B86A817B690CECC24765E05AFD47'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '12:00:00', 3,
  ht.id, at.id, NULL,
  2, 6,
  3, '233747_E306F39FF980354D9399C49EF0907E0C'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '14:00:00', 3,
  ht.id, at.id, NULL,
  5, 1,
  3, '233773_6A7846E38DB709B63A021C06A44CB510'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 6,
  3, '233788_F0639EA10AAF10C14AC008E10F7A5D31'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', '16:00:00', 3,
  ht.id, at.id, NULL,
  5, 2,
  3, '233780_973E83DDDF6A1717365CB12D5F93D95F'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 4,
  3, '261810_3A8AC360C95845DBCACF5C8292A120BE'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '261818_E172D1B8D009034BEC630D683122EA7B'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '10:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261824_8FED4CC76D78AB1E8868300C0E36FD07'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261826_57F91DD9B660B1A5F2349EE6C54565F6'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '21:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261832_7ADF0A6504FECFFD18C8A9C7F0FBE951'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261841_3F8A05164A24F10C06AA675354A462BB'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261846_9CA0EADDE431614A3F96E3888C9FE872'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261852_8B42E4D0CCA58F3DE890042BF5CD58B7'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261858_2D0DE9A1F2903A8F4489FA92BBCA5F5F'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '116406' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', '19:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261860_818798B82DBDFF271AFDE6784D223A36'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-06-07', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '233794_E826CFEF694FA26163F857BEBED68C51'
FROM teams ht
JOIN teams at ON at.external_id = '116406' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '11:00:00', 3,
  ht.id, at.id, NULL,
  5, 0,
  3, '233851_CE1436F79345DD9E4D96E0C031081F1D'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:30:00', 3,
  ht.id, at.id, NULL,
  8, 2,
  3, '238206_38890C622A1E41D9A0384E2B5EEB531B'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238213_34AD52DCFF5C5B373A5558AA815F9EBF'
FROM teams ht
JOIN teams at ON at.external_id = '118361' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '238220_C5BE09D0D2FDEFF0C8775917DD7E07EB'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '238539_F8C5BD32DE7A5CBF6E3A752C25CA5F56'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '19:30:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '238547_245183BFD85E8B84BED939D47B78920F'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, NULL,
  5, 2,
  3, '238555_B23DB26CA19B65ADCD4147B1795F3561'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '13:00:00', 3,
  ht.id, at.id, NULL,
  5, 3,
  3, '238560_DA00006F890CB0CEFB5DE1AC44335EB6'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '14:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '238579_398678D609878EB45F7597935B9F4BCD'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '13:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238581_3217705FDF32D77FC81CF4A6B9007826'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '263337_922DC8DA27E260523C2975940091CB32'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '11:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263349_B3701CF4F97DB3DD469B864C48723CE3'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266026_0BD1242B7ED1D7E2C95258042B6BD6C6'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266032_F41E092215496728DD25FD653BAD5C5D'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266038_BB910C5A7169EEFC5C15ED075323EF4F'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266044_F8A4D1F937B4081CE132828DA76F3E0C'
FROM teams ht
JOIN teams at ON at.external_id = '116407' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266050_6A237735079285FB010DAFB500C3262F'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266056_3963BCAC03585A02BB6C826B35D11397'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116407' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '09:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '230065_47A881BB2169DD2DC856B04420F88BA4'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '230071_2924F1EBEB1787715FB84FDA6563ABD4'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 5,
  3, '230100_162FFC48C1B9DE4A24DEDF75D6124B16'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '11:00:00', 3,
  ht.id, at.id, NULL,
  0, 6,
  3, '230105_A886E99FE96020E044A9941C84DE48D3'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '08:00:00', 3,
  ht.id, at.id, NULL,
  0, 8,
  3, '230111_E9E74EF2C64158C7DE375DA7DC79463D'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 6,
  3, '230118_515BB7C7FD98392CC89E175A143215F3'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 5,
  3, '230122_60A4392CC8671514EC9068A04EFF3DF8'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '11:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '230126_B959A33978C5E4C3D89549F0240E3086'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '13:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '230131_20AE0BA1C4B82FDB2A3ADDBF03F00AF2'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '230136_B2F9F3803A8F7FC2552BAE49927819D3'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '262264_CA37B66FF4C3AFA9AED37B0AFC8454EE'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 6,
  3, '262269_B768F42D9ED32CE092ED925A35169B67'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '09:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262278_3277F3CCF8F0132A23066D519BF3124D'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '11:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262279_B4703CFEA58B216F0D7CE3B3E74FE259'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262287_DD2DA874CAE1028AC2F7C01C5C20F9F3'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262295_431FDA9B58FCD9D02142363D035EB93F'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '08:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262303_D783F3A5FE2E00EE9262E596AEF77770'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '20:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262304_E8783BC5BD546C0C4C85F38A4C4DE91F'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262310_1279F19EE2C08D17D0EB031D0B64AE08'
FROM teams ht
JOIN teams at ON at.external_id = '116408' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262259_1483F3625C280FE196B451F1BFD39C0C'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116408' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-06', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '227496_6ED7A3C7C6F97034D16A42A2F3C90FE2'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '227505_D40D8244FDFA0B85410475EE604E7DA2'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '227513_6EE4949BC0F180C48FB4F9876DF5C895'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '227515_1F8F63E531FCC18D034000822A07A858'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '14:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '227520_A60AF60F75E7ADDA6AAC33539FE1E117'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '227530_4D3FF069C140A733D42D9D26DD6B1E51'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '227535_8E02B7A333B1EFBAB9FC432B884A657B'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '14:30:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227542_E2221B7990CE16166E36D9EAF229AA4C'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116435' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '16:15:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227545_434CBAAAAAC3ABB354D69742CE30E6BF'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '261206_FDA16CF786721EA063CCB1DDBFA318C9'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-21', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261219_9B7EC33BF7EB0754EFD0FC12E430A6DF'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261221_E63999C4F4781C539D8B775241D4C792'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261227_BBFFD01050C3A193A3A534FB034DC6E5'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261230_25230AE766E6A01729B6B8A12E931F55'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261238_2AE9EF86F484AFCE995FD78FD68D2746'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261242_BEDD69531E4B0F15CF8349FF5B50374A'
FROM teams ht
JOIN teams at ON at.external_id = '116409' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261247_59E3A7920820D7C132489AFF8956C2D9'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116409' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '227551_FF3E2F38BCB715F41F50D94D8E9A741C'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '227555_0D534D94F9E6B18ECEABA7C5AACFB25F'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '227560_C4D18C16E16255D7763C94D829CB3201'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '12:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '227568_F9F3935E48DE4658D9F04DD1D0D0045A'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '227570_6E8533C823A70B172C72EB891B0C000F'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '227575_4C6200AEE9ED018D4964FA5E94ED2EB0'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '227585_14A14431B0AA6AF83546165BC45C91FE'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '227590_99C7AFBBFD5158F63E8AA6608742565E'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '12:30:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227597_805187F00250A921BCEC5E1848FE4F5B'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116436' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '261263_4CB909068436388FCC3733B93218932F'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-14', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '261267_90F0799D9CD96F7B53E82F1C4F0A245F'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261276_786BBA223D5DCFE53D609A74A16F8A04'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '13:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227600_1CE74A08B1C2D2307C5421345F2D3776'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261278_769D6BDFEAF07867A60FFEA07F37944D'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261284_53273DE552637A7DE3E909C7A9D0B354'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261287_0B1D14A3D8506AFBEEA820E782FAA081'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261295_8C4467310C8C2F01FF7EDB587901CA69'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '08:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261299_7775ABE32A0FA5E23A9D88F1CE2CFC95'
FROM teams ht
JOIN teams at ON at.external_id = '116410' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261304_A57D2320186C957E08644585A1BF77A2'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116410' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '230149_79FEFD7C6BB9CD13BA90037AACEC9CFD'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '231159_679B95C3B7213B7B8E2EE7981E0AF073'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 4,
  3, '231166_08053A4BC40DFF772302DBDE9E215FC7'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '231291_227490480660A1DCAAE331EB2FB197B4'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '231301_10BAFEBEBA4990D20856B5ECBBB80341'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231310_A4B78D691AF0D925E0581EA7B6185E11'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '12:00:00', 3,
  ht.id, at.id, NULL,
  7, 0,
  3, '231317_C5373E930F1855EE12F97FBD35128337'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231323_8D170106DAA6636BA24EF47CF0D5F5C1'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '231337_7D4546F992B1E6D3D29D62C7DAA479D6'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '231346_F2B4B29D9E39AB791BE76F045550456E'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '13:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231351_0C01E70878AC0CECF9E25A10601BD0AB'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '262415_BF714EFA37201BCAEA169C25CD98FA37'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '262423_4649E906E6C65F5A54A62A70CF0576C6'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262442_B0512648B73F9A05C463D7CC1A560DC9'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '19:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262445_996BBD6985588E6DB73CED9BE79DD8AA'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262463_700FC663A57FE9F3B1492CFE0C9C339A'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116413' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '17:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262477_C0FCBD2E1C9B4E64BEBF2AAA758DACBE'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262483_6CC7B99427F98376668E88E44AEC44EE'
FROM teams ht
JOIN teams at ON at.external_id = '116413' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 8,
  3, '230156_367C9C4FC522B18B97ADF5A3A75CAC29'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '231175_4B74071F1F19F0B7766D16D3126F78B8'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 5,
  3, '231182_4F0AEDD76010BB479E774BC8035D8731'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '232491_4D0DF80BB3C5C43D75152099F4C782F7'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '232501_A266C13BA1FA8EBF02AD2685BCFD1B9A'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '12:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '232510_89BB286A895D80194917D8AB70AFDA28'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '232517_427B1D9181CE24B83B9022812EA9C069'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '232523_8786BE9FA347A5F8017126279E37B198'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '232537_5D24C4FF26E94AB309C0C4C1C1FB2183'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '232546_5C91EFF7CAFA719717E906AFBF1F8684'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '262487_E2A0B2A5EF195255E6878833B06B3C31'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '262495_9A4A2C616CC326138A1008EFCD645BC6'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-26', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232551_786B129D15B5AA388D89498DE054396B'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262514_0649766AEEABAFCBCAF005CC869B9DFA'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '17:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262517_40A72F45258604BB284F491FA8C2621D'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262530_645A4C02CBCA4F859AF011D474685E41'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '116414' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '15:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262544_773C91E9C884C93953D6942588E52B57'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262550_711ABDF6FBB30771A04505B2F0EC2AE1'
FROM teams ht
JOIN teams at ON at.external_id = '116414' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '17:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '233857_822700CBA55CEE6792208A015A89707A'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '238217_741FC8BF421ED0014E800336534BF466'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '15:00:00', 3,
  ht.id, at.id, NULL,
  7, 9,
  3, '238223_CA98F2ECD67A9202B54CAC64D0998BB7'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '238544_B27FA7ADC1D674CABE137732D956862D'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-11', '20:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '238550_416593D52B9C81E31F456CD7A9B64871'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '238562_1E68DC08B6E971FC0B9371B4D455D210'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '238569_62DBEFCA7A474109E0AB72BED4BB1AFD'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '17:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '238575_D1449A680EAB0DF30F1A127EBFBB1245'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238587_A3AD0640154523FBA985819D2176C6A6'
FROM teams ht
JOIN teams at ON at.external_id = '118361' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '263346_56034C370D638900BE9E0A69B971DFD5'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263354_E58972959CE21E1C989E2188CB82260A'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266043_3CD5B985701F08995D05F138BC7B6426'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266062_49D802843836A0D9DBD9EA11BE9CEFAF'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '19:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266046_3B3B06A899E8B72CD29A6D842A13FBF9'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266052_33240005C5BAA2ED9AFFC5A57E1AB8B4'
FROM teams ht
JOIN teams at ON at.external_id = '116415' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266061_0FB29C09E4DE9318EE248BEB41B0DDA5'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116415' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, NULL,
  6, 0,
  3, '227495_1078F9AE19BC2B5538733D2F4B2BF582'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '227517_159BAF31A38C2E2EAE75B4D64860917E'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '16:15:00', 3,
  ht.id, at.id, NULL,
  3, 4,
  3, '227522_7EC9E7E6ED242D0152E703374EC91A00'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '227525_474E8C5854BB97C6D27D0FFB54739B53'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '15:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227531_B1CBC1ECC20ACDB7F7E95127AACB9098'
FROM teams ht
JOIN teams at ON at.external_id = '116435' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '227536_490D4A1DB9456AC01E02DF5924C07BA3'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 4,
  3, '227541_C28B069AF07F71A63401359FFE31BED1'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '261212_F7871F7578E7B5F89B1FDBE78523460B'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261215_6FBB00DDA82B8F9C365A8F97A4AE71EC'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-09', '21:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227547_2BAE0898267DE3D50533F58FA385CCB8'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261222_9310A4FE51820E506F86D57AD4C9002A'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261225_A566CCAEE5D1F508D6C337CBE0CC0B0C'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261236_E8D485C101FF44C23C721256A0D83A42'
FROM teams ht
JOIN teams at ON at.external_id = '116416' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261243_D2C986140AAA98EF8FF0A3F073B1676E'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261245_7E7DCB66FB3D195313D1C822BB4372A5'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116416' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '14:00:00', 3,
  ht.id, at.id, NULL,
  5, 0,
  3, '227550_4190AC1F02FAFB06639A290FF7909FD7'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '14:00:00', 3,
  ht.id, at.id, NULL,
  6, 2,
  3, '227565_FAA26D566ABF87C4B6B2759819A5EE8F'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '227572_D82CAA0E360A6D25AA02C6638F592DB8'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '14:15:00', 3,
  ht.id, at.id, NULL,
  5, 1,
  3, '227577_28225B1548E340E8B6347F17AA1194B2'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '227580_D3148213C23A1AA528604A9666460D1E'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '13:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227586_CC7AFF5293E21BDF97CA4C5313259845'
FROM teams ht
JOIN teams at ON at.external_id = '116436' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '227591_94742D130873F5B1AA156B8815CDBAAF'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '227596_796617993DD0023A7B4880E0FC01DB50'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '261262_8A37A30D4B4CCBAB79017CA1052F1AC5'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '261269_678D51B0079AA16EF0816453B74FE42D'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-18', '20:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '227602_8C2E67AF83688B7E80A781DD8F37860A'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261272_9AF4A57E95882618212CF1D3A97AC302'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '08:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261279_F62BF9ADBBC1DBC7957B235795ED08AD'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261282_A7E05AA2D57CD73F74BE2CC7ECBF179C'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261293_921F2A3B0485FC435A48F1C9649ABC7F'
FROM teams ht
JOIN teams at ON at.external_id = '116417' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261300_D265983F45B0BA11074BFF66FD66E358'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261302_210A160DB3998AC3C06A690352F2230B'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116417' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '230066_602C0A6B234CC34BCBE6D5CD0D7CE96F'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '10:00:00', 3,
  ht.id, at.id, NULL,
  5, 1,
  3, '230074_432B48CFB8FCDDBEDEE2C39131F1E9BD'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 5,
  3, '230101_82232A5B99A37872E426006782C5118C'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '08:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '230112_CF0C15771A7C6892D16E9307C53221AD'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '12:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '230116_6E9ADE8113ED56097C8BBF035D520BF7'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '11:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '230121_F1580EA6AC279266CFF719BCBE98380A'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '11:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '230127_D8C9D4C0B72E6BB0C07E432EF0B1BE69'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '19:30:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '230137_A996F5F1327E467E7CBC9601D0C84498'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '230144_52E0043716B2A25D0B729922EBDCF5BA'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '11:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '262267_622EF0F77A8D1B331C4BC3403D75D95A'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '262270_C612158D3B7CEB47577333CCAE737E60'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '11:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262274_34D3138BC941EA7DE6BBDFD6C9E60DA2'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '09:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262280_79EBDBFEEEB41794A42036656F17BD5F'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '09:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262284_AABFA511F6C4656EF79898AF67AC813C'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '08:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262291_5DBC0DF6D63D2299FD8E6B56746CB777'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262297_10A803A3E2DD7EDAA249200C42DD3F64'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262306_0F6B4FB4D3C28E42568C58DA5C221513'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116420' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262312_074B2FDBD50322B286254264527C4D2B'
FROM teams ht
JOIN teams at ON at.external_id = '116420' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '230067_01C39E6D085EFB03EAA45D27FEFAA259'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '10:00:00', 3,
  ht.id, at.id, NULL,
  7, 1,
  3, '230070_65C24AD33E8B6605E1C8F72CA4F17CED'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '10:00:00', 3,
  ht.id, at.id, NULL,
  8, 1,
  3, '230106_562DFD00EEF3ACDE65804BFC8C4874FC'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '11:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '230119_F8CC0AEDAA7627F8871E6F639CCC36C8'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '08:00:00', 3,
  ht.id, at.id, NULL,
  7, 0,
  3, '230124_599A08BA93E11328611903FC3D439CC6'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '230134_7DA4ABBA83F2922E7A27C39FF734B123'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '10:00:00', 3,
  ht.id, at.id, NULL,
  6, 2,
  3, '230139_9EC2FC15844B0053BA092036F9451843'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', '10:00:00', 3,
  ht.id, at.id, NULL,
  13, 0,
  3, '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '09:00:00', 3,
  ht.id, at.id, NULL,
  14, 0,
  3, '262266_0C47652216B75399CC3C73BDFEE849EB'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '10:00:00', 3,
  ht.id, at.id, NULL,
  9, 0,
  3, '262272_621803CB6491ECBC6C8A8E2CAF0798C6'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '09:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262275_0D51DC1CCF1FC59FBB4A621314B170A0'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262285_99C303FA5F90D9FC074022B226D326FD'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262301_24C1B40B0339758A3A6305B8BFE9D082'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262305_0401EBB004BEEF9ACFE5BDC394EE31F2'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116421' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262311_172DC7DB3169AFB8CBC46BBF297F8AF5'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', '20:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262261_20B559CF02A750E108A1248F3AC43AA3'
FROM teams ht
JOIN teams at ON at.external_id = '116421' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '17:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '230150_135F9055AD2952171A941450834126CD'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 6,
  3, '231156_D4596DCBAFD1C94AC14F045F495E5F33'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-20', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '231164_CF5E14E5EA6D48F472135C7E0C2AB33C'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231299_DED7046D4D421EF8D1627ED0FB86E726'
FROM teams ht
JOIN teams at ON at.external_id = '116427' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '231309_78C37201D695A4650B17E28807D32A9F'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '231315_BB65AE3F6A4AEE17DD5039463D8CDAC7'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-01', '20:00:00', 3,
  ht.id, at.id, NULL,
  1, 5,
  3, '231328_04212FE1B59310243867155AC22279D5'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 7,
  3, '231333_062590CD9D96A6A0F206F39093937FD2'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '17:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '231345_BACC8148CCE26DCEA8A48B05238CB55B'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231348_FA1DCF524C453873F3B8C69DC17206B8'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '15:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '262416_2D4969C11AA0C94593251E1EE867E0F1'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '13:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '262424_9E25755561ABBD5C920CDF629DF85981'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262431_0F240D9E0B3E91EC44B1BE6684887876'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '11:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262446_5E3012A84DB120EC4C5D676E46CF2B39'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '11:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262451_E198C9A7E19045BCE7E2924FBCAAF454'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262464_ADBAD54FDEEB0F47793A80176DCD50BC'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '116422' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262482_A6D2C81CE3420E82124A08A993CEA3B3'
FROM teams ht
JOIN teams at ON at.external_id = '116422' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '15:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '230157_4EEB61594D091A8B0C0DDC302C9CFE80'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '14:00:00', 3,
  ht.id, at.id, NULL,
  5, 3,
  3, '231172_61582F48F46B361041047F2DCE483BC4'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-20', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231180_B0841FB1D482AD79E3CC02C906041176'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232499_6703F1B652EBAE200193CF61E8A5889D'
FROM teams ht
JOIN teams at ON at.external_id = '116428' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '232509_8A319B4F5CC0907560791DA453390024'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '232515_12C63386380164F1186CD8D3A6E2A970'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-01', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '232528_17B5863F11146A753532A42A8A0B4910'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '232533_F4BAD76AB3AC0561CCEAF1754AA84229'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '15:00:00', 3,
  ht.id, at.id, NULL,
  2, 6,
  3, '232545_F3769904133CDDB8133DB266606E93BA'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '10:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232548_7DEA6D615757E55934256837A0F1AC68'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '13:00:00', 3,
  ht.id, at.id, NULL,
  6, 4,
  3, '262488_99179FA8E7ED4B88C74A7A961480CEAA'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '11:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '262496_982A018456D892AAD9D371A940A785AB'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262503_75A5F9D543AA6C44B80864839DFE4915'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '09:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262518_97B407A209E33B49E2F8552624A9EB73'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262523_4D7E8E14F87D3EC488A6BF90E52F7E74'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262531_CA0DB3AA64F17BC8B9D4C9AA4909AA24'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '116423' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262549_2B25F4230CF2D70326C06C9A03397944'
FROM teams ht
JOIN teams at ON at.external_id = '116423' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '19:30:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '230068_122294F87D11928EC0E3820AB3AE4F81'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '230103_2AD02ABA8706D40FB56B43D8665B2AE9'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '12:30:00', 3,
  ht.id, at.id, NULL,
  5, 5,
  3, '230115_3EE69EE3480C302A4419B0A2FB861831'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '230117_8F990E4129985CE4C269EAD8712315FC'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '12:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '230128_92212E608D2D884992A4E9CB422F5704'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '08:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '230138_A82BC8179AB57770A9CAA1DE3599555A'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '230142_00DEFCEFC038AAB301CE2599061E0F49'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '08:00:00', 3,
  ht.id, at.id, NULL,
  7, 3,
  3, '262273_08DAA190C3EB355542A2377E78006CB3'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '10:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262277_F4F556E806D53C75B159DD9CA10EA721'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262281_0928671983DD169AB8AAA828FAEFCE35'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262290_0988B7D283BCDFF4EAADD5BA17C74D72'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262298_3BB6D1671B1C0924236084A695AF5562'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262313_D985BD9E2722400D4BAD8E12A31463CD'
FROM teams ht
JOIN teams at ON at.external_id = '116424' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262262_634E55BF65E60F61CEA4AF2F65501729'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116424' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '230151_C299ADE21EF50ED47C2EF485C24385BB'
FROM teams ht
JOIN teams at ON at.external_id = '116427' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231171_EE417E28C23C5585DC63901A56136D1A'
FROM teams ht
JOIN teams at ON at.external_id = '116427' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231292_19D96CE6BCC11AD6645A636F8BD1B96E'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116427' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-25', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231320_7A9EE3628B39295FD71EE237D9429C40'
FROM teams ht
JOIN teams at ON at.external_id = '116427' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231330_F95BECE4276F385020D08B8EFA7DD932'
FROM teams ht
JOIN teams at ON at.external_id = '116427' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231312_54819CE2EB8C3D0074D9A2737A646940'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116427' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231332_9AF645F380E3A34FB62752836EF7CCC6'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116427' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231340_8E4FD95725A82B3D1F6DA429C71130C1'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116427' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231163_94A4CA6339036E20829BCB5FFCD9E42D'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116427' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231347_5A71D6DA02DA2533ED4EA7CCB110F6DF'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '116427' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '230158_79450DDAECB8BAFF390C2B86D2DC1553'
FROM teams ht
JOIN teams at ON at.external_id = '116428' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231187_03AF986D2BF0E4E4412E9D61B4742F54'
FROM teams ht
JOIN teams at ON at.external_id = '116428' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '17:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232492_1FF959A2B5EB5FB5B4700E92873441E7'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '116428' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-25', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232520_91CB0A2407F31016304CDFFED1019BAC'
FROM teams ht
JOIN teams at ON at.external_id = '116428' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232530_8CF6F6F031648A9CDB6ED998B460D664'
FROM teams ht
JOIN teams at ON at.external_id = '116428' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-09', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232512_336B1D3BA6E34C5B0C898E8E874901FD'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116428' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232532_B0B0E5505F5A0AF8F5E42EEFE63DC412'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '116428' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '15:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232540_03F9D1A333A1E4E6AA3F230AEB34424E'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116428' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231179_5EDDCD85E9365B34E35F2222E916C706'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '116428' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232547_B83A719C6005B25E828BA3FAD12754B5'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '116428' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '233707_0344E4569260D968ABBCA8B7BBD81469'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 6,
  3, '233719_2D7B97831DEF425A44D7B873109E0771'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '233730_018145D20D6BCA6C17EBC2BED5214A56'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '233738_13E2C7001E7E5A52BF1E956CB8D24088'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '233740_04612A5F9CA931675DC235E1B81C731E'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-01', '20:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '233774_9714EFDA472335F060CC50A66FCEE8E1'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '233778_B988578528FA0D0C6782C27245C96E55'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '20:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '233789_8514B7FD8C1B26CEC0765BC0BABE11B3'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '261813_D5A7633D69004CEB1F30C7B462467F7D'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '17:30:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '261817_913DDC4F023DBC2DFB66FD5A002D1154'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261821_6ABB876EA97F5450A20A17C2174899D8'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '19:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261833_7A6A5EF07BF0BEF8347AFCC953B60592'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261837_6387F6F9360E5A23DC761A32692FD096'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261840_ABABD30D82C43C02470AB915947C68AD'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261849_43F1790D0F1F96D14BD826063A17B7CD'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261853_4EE5F09E00F728963CCEFDECEF3C9076'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261857_B3F97848C930DD42169DB40E12371AE9'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116429' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-06-07', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '233796_0F5CA2D988FF1A4C722AA8C986464A35'
FROM teams ht
JOIN teams at ON at.external_id = '116429' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-06', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '230064_C7AEC6345FA9CE65DB80FB61EB173999'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '231162_820AA5F892F770375EDF0BC9E3FA56CF'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-20', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '231169_2D453B620ED26BB3C86722C9D6F705CB'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-04', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '231306_44C42B8167F4F1A3FF34D682CD084625'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-25', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '231319_FD1D5B0EF52600A3062336DA8F8D68F7'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-01', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '231329_D6F28DA731DC326588E401FD79077F88'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-15', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '231338_2A6D036AAEF32048A23798DDBC5421CC'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-14', '21:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '262430_43463EA599B7C3C0F8534B72C0ED0BAB'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-19', '20:30:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '231353_D83474C919C44B6A8592128E5F825187'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '10:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262435_8B34082FAB7C9C28030B6DA5859D9B93'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-28', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262440_AA65F2077E0ADF2B00EE9104CBA9D3ED'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-11', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262450_B70E30ECD58BBBF4DE2D241C0FE69A5E'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262455_ACEF495DAEE5944B0DC19B6CB5C21DEE'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262468_F9DCDC92393AD1F1D65580B482046C8B'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262472_3C7CAC74F0C6FCAC0388997A780EF056'
FROM teams ht
JOIN teams at ON at.external_id = '116430' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-16', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262479_9BFD9F2E19C8CE118EBE1681BAE9D5AC'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '116430' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '230063_22CFC118F0669F2954A4023870D09E10'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '231178_452D8A94A7493B61BFB1B29A59932D1A'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-20', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231185_90953511509488647A66E19E8A629DF5'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-04', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '232506_FC0147DE566E59192762A6B2F6C32AAB'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-25', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '232519_BF04BE9850AAFB9A6F6166A685987826'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-01', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '232529_4D0506BBD06BF190B020292609EC5D1C'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-15', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '232538_DC36F25F3360251AF1FB006E986FF23A'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-12', '20:30:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '232553_EA4960BCA3388673FEDF2339FFC89BCE'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-14', '19:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '262502_CEA3F402B6173A7E25E611EF54FE4AAC'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '08:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262507_F6C538161B9FD744FC1962E177A524FF'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-28', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262512_4AE77186894BD09C2DB83C0F6E32E2E5'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-11', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262522_3E9E144DDF1722605607F510AD0111B1'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262527_87185BA85C2708D85D8F14D32822AA09'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262535_87963DEEB0FB52D7290ECECC67DCD3BD'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262539_9F56A8CFB5CCB684D3A4B67CD928A509'
FROM teams ht
JOIN teams at ON at.external_id = '116431' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-16', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262546_A96E5E36694AB5B81AF6E195B9492774'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '116431' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-13', '20:30:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '227503_5FDBDC8C08D1F89D28B6E8F13B9206F9'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '227509_C542BD58FC257474275FCDF5BF01DF5D'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '227512_1D83272BCF27FFD5F2BA67C22025E24E'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '227524_0A2981B46B9375BDC6BF6D20EDD41ADB'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227528_7CD2B62783087A8728FE004BA80DEB67'
FROM teams ht
JOIN teams at ON at.external_id = '116435' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '227537_06C0FDEDB9D8835197117C970EA70EE0'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '20:30:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '227543_FFF8D7A1B4DACD887D230A90DF6FB212'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '261208_1205F3D0147C0A0D167828A09B007435'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '261213_B36703388C3416B1268DC01EB525DBAD'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261223_D2E9FC6694E690E6FAA1EE99B74F205C'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '16:15:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261226_EC21C3C26253BC8CC5B6AD391206B06E'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261234_8B50CB4A710A09FA26ABEAE20B7B40FE'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116433' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261249_20FCB50658414D40DA56E2C408D1A427'
FROM teams ht
JOIN teams at ON at.external_id = '116433' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-13', '18:30:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '227558_AC96BB2514B5FDD9192470309541EF1C'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '227564_DD106C8C2280A24D521A86653703CC65'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '227567_38920F65F85F7D774EEB3DC528D7F01B'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '227579_ECEC92C4E460EB84E53E157C0023426E'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227583_414046A530DD40051C0167A6681295E0'
FROM teams ht
JOIN teams at ON at.external_id = '116436' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '227588_A6939D1D49C029B4EA639D09E7E6BF6B'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '12:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '227592_64E0C15A959215AC68488898089597DB'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '18:30:00', 3,
  ht.id, at.id, NULL,
  4, 4,
  3, '227598_C9696057B3FBDECB5A1EA038C9CF4B07'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '261265_F711674160DD64D8BBC76E2B05014154'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '261270_3DDBEBA9D284EAD738CB3EDE98DF987B'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261274_03916A29B615F1B88232CB63F0C640D4'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261280_2E1517F556611C1F8E8178AD9CE6EAEB'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '14:15:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261283_183383E5C1B3D53AF10265ED04DDECB7'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261291_BE3858042B9E2A013A332381A14F4C64'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116434' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261306_720EABD6A23D414FC53A7A98FF7E3F0C'
FROM teams ht
JOIN teams at ON at.external_id = '116434' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227498_FA934A134F537446B797A4416D2AA70D'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116435' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227504_4161C8DDC78BCD6B6D69D9681919DAED'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116435' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227508_AAE70BC22BE06AA1135A5066CE4B7FA3'
FROM teams ht
JOIN teams at ON at.external_id = '116435' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227514_AE0C21C6C0D5D923B927AEFD68298250'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116435' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227518_A915BCF28014FBE2C95EF51B688C8605'
FROM teams ht
JOIN teams at ON at.external_id = '116435' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227539_84F7DEFB9BEADF5F6E0A633EBA282A99'
FROM teams ht
JOIN teams at ON at.external_id = '116435' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227553_55ED90846232E1F72E14A25A61765F1C'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116436' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227559_2E6E185F5CEFFB3663E0AD6EF0AEC30A'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116436' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227563_334C685B9A6E26F6057D135E1F60315A'
FROM teams ht
JOIN teams at ON at.external_id = '116436' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227569_0637C221D84B254268F096FB79ABD332'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116436' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227573_5A8294DBCC37D37526F59DB7D4E12452'
FROM teams ht
JOIN teams at ON at.external_id = '116436' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227594_3260C0203C40ADA3A44B70AD53B4B0D9'
FROM teams ht
JOIN teams at ON at.external_id = '116436' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227601_6AED62F5F073A8A489355A83D783B6A5'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116436' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:15:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '227501_AFD7ADAB2CEE655985BA6071C15DDD03'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:15:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '227511_8E6EB8CD7FA352B547EA6506A834BE7C'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '227519_45DC5B0403DA5B89C0AB42C65D81449D'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '16:15:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '227526_5F4B8BA1C95581646AE57CD933AF5ABF'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '227538_B2A6AB7A2607FD2CF8913344E5685E8D'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '261209_8F6FDF05ECB94A00B8CF15C6640A59FE'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '16:15:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '261211_9423A1DCEDAE710DCA401248819C545B'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261220_3708838376FC9833D9E8E1DF34601A60'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261233_A6F6B9EDCBF823A03D0C9761933927AF'
FROM teams ht
JOIN teams at ON at.external_id = '116437' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '16:15:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261235_255B9383E75E9ED9D90895CC298E2623'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116437' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '14:15:00', 3,
  ht.id, at.id, NULL,
  4, 3,
  3, '227556_DF598C8BAC1760554BBDF1BB7C862E5F'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '227561_2C56D2044D12ECD13E2558D65045EF6F'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '14:15:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '227566_CD22E546487020FFE7CC926C71DE0B90'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '227574_A15ACCAE98917302EEFB33810C865CB1'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:15:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '227581_1D17F7E2D6455C78803F9D2CF169677A'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 5,
  3, '227593_461CAF3D0B972B23AE46F4E68929E676'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '261266_848B80E791A1FF7B6609C6185CE15725'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:15:00', 3,
  ht.id, at.id, NULL,
  8, 0,
  3, '261268_A9A6E439F18B3339ABADC60DA89D37B3'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261277_4A1CD6B9FF0754DE8DDB5BCF889F6A8B'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261290_7AE7828978D5CE74201CFFAECF90B344'
FROM teams ht
JOIN teams at ON at.external_id = '116438' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '14:15:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261292_F5454F42747E571CE74C311518B92F5C'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '12:15:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261297_47C9364B701A6D7BB3CF231E437FB835'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116438' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '233714_096A16CFF147F956DB60EED7F2535F6A'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '19:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '233718_EFEFB8AB34474C6D87AB978BE979C692'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-27', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '233733_BD0FB1D90991AE453D0E79CA559C974C'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '19:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '233735_FB61CB22A533E3BBE1FDF5EE1BE1FBE3'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '19:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '233743_1D256CB927224D95AEF7B18AF6EA161E'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 5,
  3, '233746_10A24369A7524626966F23BF01EB779D'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '19:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '233791_5BE84688CEE4B1CE6EAAA4037B969935'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '261811_6C14EA117DBCCE255C1A4886DF51C9EB'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '261815_1ED16E21E3544688A2CCCF47C90FF43C'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '19:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261820_9D0F1B167663AD8588A4113005516914'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261829_B5687F8D79C8C4E31BC745EFAF00AC52'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261838_EF14BD3A34033DE21C0BB75C5902C5FA'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261845_0AA03C98B5AF482D6A484F0EF814D48D'
FROM teams ht
JOIN teams at ON at.external_id = '116439' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '19:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261854_079F033C71C1355C70A3FAD88472AF81'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '19:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261856_468ADA1398BFA01B2E162A36A74A02B7'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-06-07', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '233795_BBA2D455784F332C67FE299A15578CB5'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116439' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-13', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '227502_C95EC37CD4E1EC0CDFDA142C1EC32544'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 3,
  3, '227529_8F4CB7F0110943971E7ED37BB8FF5AF8'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '227532_ECCB4D6DF374E677508E9D7575A3AA6F'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '261214_54FFA163BD0083C4BAF50F017EF7F00B'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227548_C2EA3EE5A9EE5DB891E3A6FB66336CF7'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261229_4CFEAB9CE34D4E7CB25F33CA25B49976'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261239_FB4128E8A4FEE7780961FB193068640E'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116442' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261241_A8B5388C0CAE55E749064A82C0A160B3'
FROM teams ht
JOIN teams at ON at.external_id = '116442' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-13', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '227557_14B7EB8AD0B20774B64E24E5CF1B0643'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '13:00:00', 3,
  ht.id, at.id, NULL,
  5, 2,
  3, '227571_2152D809FADFA0CC929B813C90795620'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '227584_3E685D13963646F09FC4D3E84DCCB5DE'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '227587_06715F4F79BBB6D8F92CDAADA0D241D5'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '261271_5377F8AD62DDE887B568396B511BAFAF'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-17', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 5,
  3, '227603_9ADE2FE73CE4EEC9A1A42B8AB8754DB7'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261281_AFAD4FE0E43EF2FD6B6B64214CFE6297'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261286_EC208408F458D1E6D325749B234D9756'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261296_D3881E36D30A0346FBB191F5ACAC819B'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116443' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261298_FA817F1C65233DDEB41499624FDB6D4E'
FROM teams ht
JOIN teams at ON at.external_id = '116443' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 5,
  3, '233853_BBF48FFEF2F9A7679FD9A95371697006'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '19:30:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '238207_B27D865736E40B19A031F32C4BC401E7'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '19:30:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '238214_2857059FCBA8C0588EB627396DA1BA3C'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '19:30:00', 3,
  ht.id, at.id, NULL,
  3, 4,
  3, '238221_3AF0A8D75605B912DD7AFF8E5A16D792'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '238545_5961B37CE8021403BC16C2F3084E44DB'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '19:30:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238563_33DE38115B57F5F724D495AF63C72F3B'
FROM teams ht
JOIN teams at ON at.external_id = '124917' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, NULL,
  5, 0,
  3, '238572_55E179F3938F2669AAC09C9BA3035078'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '14:00:00', 3,
  ht.id, at.id, NULL,
  9, 1,
  3, '238580_6A904444EE061290E207E9B19A2EBC42'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '238583_E188F2BF585D2EBE209740FCE1B57746'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '19:30:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '263338_064367C2E90B1DB0A269AE64704A0B0B'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '19:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266027_7363A51C1ACB224B752BBDFA54F7F1AB'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '19:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266033_946D000A5BA491C7BD870952068B65BB'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116444' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-16', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266058_DFD51E2793904516DEC357AB2BAF583C'
FROM teams ht
JOIN teams at ON at.external_id = '116444' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 6,
  3, '227554_1E31CA502CED313AF7BAE33F2C0918C7'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '227576_B03160627645A33F9022E323F59E449B'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '227582_1215D7310149AD83D8A0EF2B917D7812'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '17:00:00', 3,
  ht.id, at.id, NULL,
  0, 5,
  3, '227599_05C9DE1A2357A59EF0E657C835720763'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '08:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261285_C0FBF34425D7F1F4D187FCF5570759CD'
FROM teams ht
JOIN teams at ON at.external_id = '116445' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-25', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261289_E1D89AB92D395B89EA72FE5E90BCA544'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-02', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261294_C64F736BECFB69C82272CBC88040B6F5'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261303_855FA9A10E5BFB62A2B214D4371C1FFD'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116445' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '230102_EA8EB3BA006B849679532EC75A4E1F7C'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '19:30:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '230114_88327EB1C82E09B68E68CDB1912D20DD'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '19:30:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '230123_B0E983394036E8B4B59A972D6F2F4981'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '19:30:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '230132_EFECD32D643905855A795CCD1F9126B4'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '230109_844131B9976E0ABCD09C86F5D07D6466'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '09:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '262265_16EFD2723C86863D59DE0161EF7E43B9'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '19:30:00', 3,
  ht.id, at.id, NULL,
  6, 3,
  3, '262271_BF996F711F598B2F15F0EB2235477048'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-19', '20:00:00', 3,
  ht.id, at.id, NULL,
  1, 6,
  3, '230141_E6AA1F9C9D65D6C12D0670B33D478CC1'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '19:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262282_F054547B2238E178121F2B35DD57B5EB'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262288_CA38EF99E48CF28F92CAE66276869F4B'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '20:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262296_7D13A910D6AF3166519410AECD69E79A'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116447' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262302_F72510A76A98D6922A958FD2591F117B'
FROM teams ht
JOIN teams at ON at.external_id = '116447' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '227497_3A3E3DFFD3767C119ACB2BCCEE3A80AC'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '227507_D9F288959C72823A3AEA7640A46D79CC'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '227540_A1EC9A77F50496FADC56B171CF8A4790'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261216_DB4B4B3DEE29FCA05BED0D6E04EBE0C2'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261244_71E0049E169F03C5BCE982E0147F4FB0'
FROM teams ht
JOIN teams at ON at.external_id = '116451' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261248_706C40148B396F1C3E78185D7E826237'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116451' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '227552_FBC1F5EF0F09D6FFEAAFE12881002E97'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '227562_4CA649A5BF5EA84E56BA013BEBA7B347'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-22', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '227595_DC16A598A57578DCB6E3B56EA9A1FF04'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261273_D2282E3D17BADCE57B2D1548FBB7C5D9'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261301_46078D9877914AECFED3EAB87EDCDA0F'
FROM teams ht
JOIN teams at ON at.external_id = '116452' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261305_EF82B3EAE1494C971973B3EE6F389875'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116452' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '230072_B72F7E25D0F39B2288FF2CD283CFF009'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '230108_0D8E452A2AF97C75E28D61980F020FCC'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, NULL,
  5, 2,
  3, '230113_DE4210F1CDEBEECA9080D53F6EE956D6'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '13:00:00', 3,
  ht.id, at.id, NULL,
  8, 1,
  3, '230130_1F59EBB1983DD2C078EF9F8D6F29C0BE'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-14', '10:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '230145_67C0B07BBDAB66004C0B3863C73905A0'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262286_4980BF28BD33B97332A30204E19179A6'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262292_28BD5F8E36D35BE6454C23FAA314BA83'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262294_2A84D3512185F160E7A6934AA4BF4CD2'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262300_CD94B481F42CCD55F37FD820EF58531E'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116453' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262260_E5E202C00EEB0AB82A38852A80C0CEED'
FROM teams ht
JOIN teams at ON at.external_id = '116453' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '08:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '233708_A2E838F6B775663443E6AC18710B2AB9'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '15:00:00', 3,
  ht.id, at.id, NULL,
  4, 4,
  3, '233711_33A911EC3155557E982B0C1122C7757F'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '10:00:00', 3,
  ht.id, at.id, NULL,
  6, 2,
  3, '233717_A3AAB631D7431C5387158E05516155B8'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '10:00:00', 3,
  ht.id, at.id, NULL,
  10, 0,
  3, '233744_1177756EE3FB4D25D71E27B99115771F'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '233771_A1171927899353E6DAEB891BEBD47262'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '233777_8EC78F1271E416FDD50D529A881CF846'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '13:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261828_4CE83830382E8908B46D4255082D4D64'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261830_4F48A5E3FCB33A1FEAEA9EB3EB0BFD1A'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261835_30AF2C9276A7FEF41DC7DDED04EC4A51'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261844_831527DE90BEF689B80FCF6F0C75DF03'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261850_9D6034106213DED4F41BF3448042CD81'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261859_6BD00A839ABC98BEA316CF4E84FDBE07'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261862_A73097AA50DADB3C649B0E6B7C866470'
FROM teams ht
JOIN teams at ON at.external_id = '116454' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-06-07', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '233793_EBFE911FDD04332FD763FADC5FC80BA5'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116454' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '230148_E6E077D5630290931C2F9151D78CCE78'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '19:30:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '231296_F96A379E06A9085C20902D409F7FB3B2'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '231304_8F66F11AB5E75185C90EDEDF42790696'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '13:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '231307_B43E12614FA743935E90ED7A4935780B'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '231343_CCD74B0CF201BDCD3E24A451E3FFBE8C'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '11:00:00', 3,
  ht.id, at.id, NULL,
  9, 3,
  3, '262421_C4D4F3121E9FC0BC16D473BC4A4C392C'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, NULL,
  9, 4,
  3, '262425_63C0839D0F3A426902AE3734F6A4951A'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262433_C5C6AB41C5D1672062F6BD9DB43063EC'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-26', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231349_301B886F37B0C2E28BC52EC20E561E25'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '13:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262441_96B5C232AEC66B564A6A0E2B11725307'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262448_46B23BA342B4888920301190B66F26E5'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262454_979CCC407D908BFFBE89172E15BB6B79'
FROM teams ht
JOIN teams at ON at.external_id = '116456' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262476_81B20D77681D564C075E9CFA8B29D929'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262486_0D256FD7E551F1FB900BBC06FD730830'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '116456' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '230155_3BFB1B766BE86D30F2340CC02B991E93'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '17:30:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '232496_6C830E08972370A47DE498DDD56A66F3'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '232504_43DE6E4E42EE79D5A83B6F0DAC6AD840'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '11:00:00', 3,
  ht.id, at.id, NULL,
  1, 7,
  3, '232507_E8B0472A4C396968124B13A1E3A1A442'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '232543_8B680CD25815B94983C681244544EB2C'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '09:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '262493_E614156D940CD0B8BDF4872A422AC52A'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '12:00:00', 3,
  ht.id, at.id, NULL,
  6, 2,
  3, '262497_67E3DC0558C1EEBD80B5101C9A0C57E5'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262505_08175ACE54AEB7BC3B05040AA9531A3B'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-24', '21:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232549_0C7CDDA484E442B717C7DBF1EB6BFA17'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '11:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262513_76DF99314F782138D3EF6F958313CC8D'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262520_572ED72CB6CA76E057A85503D289B7E5'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262526_D0D0CCF548EB7A7CAD43B7110257EEE5'
FROM teams ht
JOIN teams at ON at.external_id = '116457' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262543_E838EFF2E5FA4886444F9FBC5B65956A'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262553_A690DAD4AFB03A1CDA1A118F95ED57BB'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '116457' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '231157_F76052CA31FF884126101388D02DAB32'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '10:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '231167_A6482E9E77F7A06B52DE5898CBCDDB0B'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '17:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '231293_57276CECB7C58574DFCAE2CF77295B60'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '17:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '231300_7562F7B42475D1189D0FC13C7567DDE9'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-11', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '231313_D7340169BDC266FFE4910DC29C860E76'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '231318_FF0EF602442FEBA6E108B9501BC3D483'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '19:30:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '231341_8B7B6C9820B24BCC3612C9BF385BBA5E'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '262418_46264295BF6E8EA7921A513041E3EA04'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '262426_11179D996BE02F971F40B6FD87E767BB'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262443_17B975610A436866D1867CF3408BCE60'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262449_2EB2A9F96F8126181181EFEB9F3A87B9'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262467_17A4DB40B0967505EF6E63F8AF0A6A6B'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262473_F73EF5045C5DA7C02FC2BE016ED1FFB2'
FROM teams ht
JOIN teams at ON at.external_id = '116459' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262485_73DAB4D23D0D72DE930B605E60BA97EB'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116459' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 6,
  3, '233709_C606D3BB7282973BFE1309C419D6D8E6'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '233729_9705C9F35E790592797933B6EAC29810'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '233734_590DCE4CF2B07C036D21DE409E913E1A'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '13:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '233745_93BD4364D08324FF9AAA7EABF1C83926'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:30:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '233776_C587919C3ADF0AC870545C078A8F4DD3'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 6,
  3, '233797_4975ED98A1339F54E297A8561D8E7748'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '261814_14EAB5223075A197608FF52C5182201F'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-21', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261823_9A79903E727FF1EA79B849653A502931'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261825_B2B739ED4707F7A7F9DDE2F091420549'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261842_F0548411D7E195094219A6E56F3CA698'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261851_9B524C76402368D4C261DDD8C3B8F0A6'
FROM teams ht
JOIN teams at ON at.external_id = '116460' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261863_A0B36FE16311440CAE9D33F3A0AFA0C9'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '116460' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-20', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '231168_A2D76DA49759984CAD053D0A0F491CB3'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '231295_9484C75BDC3B5C575247A980BB9A0C48'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231302_94826E0599F6B06DAFAAFEE2D82A9D67'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '231327_2962C100D8D5408796518EE687A4D123'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '13:00:00', 3,
  ht.id, at.id, NULL,
  4, 5,
  3, '231334_1EB51A3C0BCC7CA38403101A57A10C57'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '21:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '231339_A0D3D3061E0253495FCC9E0FF28910CD'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231352_25CEDD97638877A8DC78DE0DF4026EED'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262420_F29A3DF9D2529FD6461C8F974E975240'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262434_86A84E1B5B32ECDC88654B8A38850307'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262438_081B9ECA41B6927BD14C664334C0ED46'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262471_C8A85BFBEED19B78EBDF6AACC1AB959D'
FROM teams ht
JOIN teams at ON at.external_id = '116462' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262484_D18D6760706E8A6D48788AA4D95E6347'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116462' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-20', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '231184_F6BBBF20017AA3FDA19AC1F1BA706DD7'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '14:00:00', 3,
  ht.id, at.id, NULL,
  5, 2,
  3, '232495_F96A25E11FFA500151DBE1A777797233'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '08:00:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '232502_85845C521CA72B6B21E109450A70CB66'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '232527_59DFD85EDD3A3FB8D0C4BFC871BE10B6'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '232534_1086EA0CEDD423DB1C983E23B6D561CA'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '19:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '232539_F0631677F722A585E35B692412FF1D62'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232552_7A45D8ACC6FC271F9EAE808A7475C64D'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '262492_2595632C725676D8EC2EBCF403604F74'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262506_CA60F578CC38D6D02036E34EF78F0FBB'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262510_C9B773F49649CB49E9F6990CE2A8A705'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262521_879D093EB1343E46F3414ED458E9FE8F'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262538_0F019376C9652D331F8631E98F63E291'
FROM teams ht
JOIN teams at ON at.external_id = '116463' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262551_3C29ACE302FA2353989F4C8BA5D1004B'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116463' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '08:00:00', 3,
  ht.id, at.id, NULL,
  4, 2,
  3, '230073_D36B0606D98B70ABE8FA3E94836CAC5A'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '230107_5AD186BE817D0CBF8D8B8E7B18C15B0D'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '230120_9B8BCDDD0FC6A4238CF3AEDADFE9A059'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '230135_C25ED42C32F24B96C966381D69B5A9B0'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262276_B61AA210C63FB21D4B154B0D763C7CD0'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262293_66CEDC7CFEA07B7F83AA955DA2294308'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262299_0EF3C1C52C0B5715358E3FD0D0940DC7'
FROM teams ht
JOIN teams at ON at.external_id = '116464' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262307_8264FBF48AF4EE07B7ED4AFB57621332'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116464' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '227523_2FD3035B339B7F27A010E26A499FCE77'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '227534_FAA9952BABE59D877067445829C2734C'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116465' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '261207_0427678360869234043E3CD8F44C5B22'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261218_75F335A40C0C4AE770A50606ED31089B'
FROM teams ht
JOIN teams at ON at.external_id = '116465' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '227578_51C24B07137BAD44B73E2B9D2376614C'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '12:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '227589_9185651208C38D90D98D12F4B926E267'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116466' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '261264_A99250CE49BE3F59993A2912B79A7569'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261275_4A699504D71DD72CE492866BF59D4560'
FROM teams ht
JOIN teams at ON at.external_id = '116466' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '14:00:00', 3,
  ht.id, at.id, NULL,
  8, 5,
  3, '233855_D0AF804FFE2D4E1D702CD66965E5F795'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '238212_8EC20A1CA5DC2A4A1FDC441C8C09FEFF'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, NULL,
  5, 1,
  3, '238542_95992206C14F1D74EA465F19AA24EAFA'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-11', '19:00:00', 3,
  ht.id, at.id, NULL,
  2, 5,
  3, '238549_A015C2C87A5D5E48AE9C5A53DEF80969'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238561_030A3B696390A972B2DBF9B0D3AA2720'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '118361' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238570_3C6CB63E18233CCB99BB906613AD9102'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '124917' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '12:00:00', 3,
  ht.id, at.id, NULL,
  5, 1,
  3, '238577_D2212A863AAC3FE52C48BC5A7A35694D'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '16:00:00', 3,
  ht.id, at.id, NULL,
  6, 2,
  3, '263345_FB8D6EBAD6A07F1BA4ECD0CFA6666189'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263351_E1F47A1CFB3F52E04FE301DF8CE5CEFF'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '17:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263356_D5F9F32F9D9389C80BDE41004C88E423'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266030_C03C8D33487D0E4FAF057999DF6D8C4B'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266035_73E832510E0212C83460445080911E3E'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-25', '17:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266042_C9246E5C263C3C334D8D47B550D7EE05'
FROM teams ht
JOIN teams at ON at.external_id = '116467' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266053_1E67D573B1783D768C14C1B1911C70CB'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266063_52D67B680EA968214FCE03DCA0586F42'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '116467' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231294_19AC82D9A13F1D8F6A953C6C52722779'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '19:30:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '231314_7A55A64AE986753927B52E806B5FEFEE'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '10:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '231324_75AD900DFCA53BEDB9A5D21A82292C9F'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 6,
  3, '231342_33D1BBBB8CDEDA4EC910612CCE6E0785'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '16:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '262429_F4F8D02CF61C327792F4097576377308'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262432_306B52A9F4BC02FBEC1703898A6A0B71'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '11:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262439_7E1750C4E6D2F744F385AE782A442326'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-31', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231350_D4AB093705D682D366F7AD619702BA9F'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262453_725604487DC53DAF0BD1C6BD3E861E73'
FROM teams ht
JOIN teams at ON at.external_id = '116468' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '11:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262478_D4614A68717ED76C521E88C64F147C72'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '116468' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '08:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '231183_1BC4923DDA1B7539F3A77E1A10673791'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '232494_FD6F2F9EAD133EBF4E5D56CA19C75EFC'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '17:30:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '232514_CB01B7414EC9A9BE59A52EDE59F16846'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '08:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '232524_B34B5C7735CBE31F8AC18A5ADCA41461'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '08:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '232542_99EB560FD621962E01CD1B3D4E58D774'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '08:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232550_BA0140795B3428F4429B3617C8807DE0'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '262501_C258C5D6B601CB6C03FA113B80001B0D'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262504_2197F5CC637072BAFC5778BFF96ABC24'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '09:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262511_D4A85B72E4E7CC5BD0B86504B0ED0970'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262525_1EE8A349AFD29AF9BA057B956D94D4BD'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '09:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262545_02DDEBFDF9BA8D660DC15EF26CDFA64A'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '116469' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262552_E74025D17D12F218B829FCCC1F3F3203'
FROM teams ht
JOIN teams at ON at.external_id = '116469' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '233854_57AD4440ABB7E4FB3868805F6338ED04'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238540_CAC3A08E0CD90C175D66CEB8087D7C15'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '118361' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238557_90359894B7CA13A839C401963CAAB9C2'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '124917' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '10:00:00', 3,
  ht.id, at.id, NULL,
  11, 0,
  3, '238564_BA0BCDE067F9D3B43592EB15CC80D6DE'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '238568_CCF89A6CC7BDFF15F2C61997E32E5B8B'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-12-07', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '238216_9BC72817B18725C454529EBA7248778D'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238586_3D6DC85C686EE2E831E8B6EE2C1873E8'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '263347_1F918DD3A7C1B27E7ACAB2EC52411096'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '11:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263357_873EAC15E5E99831BFF6BD67FFD5F2CD'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '13:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266036_0C20D090B40894152B2001AA30A3C0AE'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266040_6AB9E41016714E49C5B0490CD0417EF9'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266048_99F12D09FFF2F170F9873C47AFB467F4'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '116470' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-09', '17:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266055_8232B21646CA8612E47C7C55F86F96A4'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266060_22C5E5D53BE879B14AB553FBBFEA1133'
FROM teams ht
JOIN teams at ON at.external_id = '116470' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '233713_478A5E517E1B4B5FE1F517EB2058D36F'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '233731_73404A00E8BB1C9CD94125E6FBA80D3F'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '233736_9B4E7296C68EA955EDD80EA7A0E4E86F'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '233739_0E2D2190F0179B4C8D5DFB6EFD824F19'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '233790_BE0A8F5E44200FE806AF1BB80207F5F0'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '12:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261822_751262E72B9353055F2606FF23E6631D'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '09:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261827_288E9A5D3B4A16CF242D3846360B7510'
FROM teams ht
JOIN teams at ON at.external_id = '116471' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261839_940E07C44B15D0A9FA7E8F6D0B63E57C'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261843_DBA87681EBCD26C7BF707B8A3069B3A6'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261864_C6422DBA65D674631533C812C1E44C47'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '116471' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-12', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '227549_4E5FFC567E356A81F70803A789A646B6'
FROM teams ht
JOIN teams at ON at.external_id = '116498' AND at.source_system_id = 3

WHERE ht.external_id = '116472' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261231_8C2B880B1E23BF573173EBFBE411DE1E'
FROM teams ht
JOIN teams at ON at.external_id = '116472' AND at.source_system_id = 3

WHERE ht.external_id = '116498' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '227604_01275794717F8D7EF36B7790FC6C736C'
FROM teams ht
JOIN teams at ON at.external_id = '116499' AND at.source_system_id = 3

WHERE ht.external_id = '116473' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261288_B0A98D583F2441931AA076C0638BF443'
FROM teams ht
JOIN teams at ON at.external_id = '116473' AND at.source_system_id = 3

WHERE ht.external_id = '116499' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '08:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '233732_1C92C02735810DAF7B06EC5C286E6840'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '233772_07C9C3EC5B702F3E960CFB72D2631C2E'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '233779_BB7D386C6AE304190F39A6F6DB351374'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '13:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '233792_3CD2379A007ECE43EEF6EA864025A1E7'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '12:00:00', 3,
  ht.id, at.id, NULL,
  0, 0,
  3, '261819_D47ED55C20FFF752E84510DDCFEEF321'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261831_E1BDCA4B26EC6C31FB49B5640F380A07'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '20:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261847_02725397F5A12F24DACACEF4EE251ED0'
FROM teams ht
JOIN teams at ON at.external_id = '116475' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '13:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261855_FE7C3BC3BF43B20738FBC4DECD9C6265'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '116475' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '231165_E3BDB8E346A4C8D73FD0657C60A8AB47'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '231316_DEA87BFCC32FE555D58784EA2DCDA854'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '12:00:00', 3,
  ht.id, at.id, NULL,
  7, 1,
  3, '231326_E4B7791D32D1F32803EF12AB09F5A91F'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '231336_8906001851341A451EEFD86AA33A03BF'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 4,
  3, '262419_C27B09DCDEE8F0D85E82A0694A9C763B'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '262428_D161B46580B066F15187EC01D2FB1DA1'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262444_9566E0CC0749D0784EEEDC5B485E7A04'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262452_E4B88FF96FD645C94FB78B30E73415F1'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116476' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262465_D2DBCF19373FAE55EB25AF849923C672'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262481_8EE5E136D2377F3FA987B5FBAC960EA8'
FROM teams ht
JOIN teams at ON at.external_id = '116476' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '231181_4EB6CD670088B1F3373214DF7F76A1D9'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '15:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '232500_8547C2EE94D99238F047FAFFA4DB95FB'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 6,
  3, '232516_1645E9BD4CE1CF27FD2053D41B46AE34'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '10:00:00', 3,
  ht.id, at.id, NULL,
  6, 0,
  3, '232526_794E613037267A1F457C8322C578F1C6'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '232536_8974F09529348AD4BDAD4772D8312D63'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '262491_F349F9B41F1002E90366F85D556A0994'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '262500_7DEADB53A6AF4C9ACDA33EE06DA80CC1'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262516_3AF6404D6338516426F6A63029ECE035'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262524_1BD08078FDE663BBE139CE1E6FC209CF'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262532_5FBB62761286B578596B0536D6B11D7D'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262540_5F4C9FFCDFE7B3C4C0A3C70D929D6ED2'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '116477' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262548_952763C30FB637231167768E3D70F086'
FROM teams ht
JOIN teams at ON at.external_id = '116477' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '08:00:00', 3,
  ht.id, at.id, NULL,
  2, 5,
  3, '230069_8A8DC5C707EF8C8468E0FF7AB582AB56'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '08:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '230129_8A7467E76D73DCF185C0FA617FAFB931'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '230133_DCCFF4896CF5ED3E87FB2BFA3C01930B'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262283_4037F11354C4E51501BA322C06EFDB44'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262309_6308D2E8A790F5D58D64B88F7255B24B'
FROM teams ht
JOIN teams at ON at.external_id = '116478' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262263_5DD9930FF2E6F4E2A09FC393F7D68C71'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116478' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 2,
  3, '233856_2B5D1845BBE522DAC1B154E43C17CAE0'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '238215_B762230C8F3B66B24F8CE185CA43D4EB'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '12:00:00', 3,
  ht.id, at.id, NULL,
  5, 0,
  3, '238226_003C5D4930B48142C9E11A2648F26624'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '124917' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '16:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '238552_5EBB899E39EAC9E96B12270C4CE2124B'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '238558_086220C43DEAC49D998DD12A535D51CA'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '13:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '238571_985E7749AACB511625EE8AB2E38B62E3'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '263348_7106038F14F31FB4960DD856B82115BC'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116479' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266031_F1744BE99C6094CB5E6C584B9D209D0D'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266037_1DC6A1859051418586EE0BB8EA315CEF'
FROM teams ht
JOIN teams at ON at.external_id = '116479' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '10:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '230104_917B1B96758CCBF550F32552E063E45E'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '230125_4F2E7B4061702AF411F47BBA6A0B767D'
FROM teams ht
JOIN teams at ON at.external_id = '116480' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262289_682B82B2284AFF5DC81ECA522D292CC5'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262308_683EF0FC5D32691EEF84C0B3B8DBDFC6'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116480' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '15:00:00', 3,
  ht.id, at.id, NULL,
  3, 4,
  3, '233706_2D593462F36B331D0595A9628C144C4C'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, NULL,
  10, 1,
  3, '233710_A4954417A11EC0F2B10FAF21219ECB01'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '233748_E06FBC05C69DB12B3B1CFA46FF0421FD'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 6,
  3, '261816_95AA3599AE877E8D8A1CE6976C911DFC'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261834_6237854BF1DAC167E35D161FBDBFABD1'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '116486' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261848_4DF29525446ED6E6AC7AC3D85CC8CC61'
FROM teams ht
JOIN teams at ON at.external_id = '116486' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 1,
  3, '230153_0D5C313AAF42CC769312A78CE67ED9A6'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '19:30:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '231160_6C9D6C3781B1EB20DF8BDE3F88E6E485'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '19:30:00', 3,
  ht.id, at.id, NULL,
  7, 1,
  3, '231322_DFB8C30602492825E5C2158B3B70F7F5'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, NULL,
  9, 1,
  3, '231325_A49E7BADC86DA8B1279478208AE8FF01'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '262417_6B37E49E64E02383470096EA90D8EA4B'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-31', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262436_93F38E504E6684B3B551D666C874AB5E'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '19:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262457_8FDD7943316B7234858F1177F410E74A'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '19:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262469_60CD8C3B70501015ECED1B2657959B7C'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '116487' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262475_75B9D807CAAF4B69BE0B28E66BD5CFF4'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262480_19972954732EB1378FFB98359F0A9D5F'
FROM teams ht
JOIN teams at ON at.external_id = '116487' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, NULL,
  6, 1,
  3, '230160_BCE778E0BD00BB48758E5269F3A076F3'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '17:30:00', 3,
  ht.id, at.id, NULL,
  6, 0,
  3, '231176_BD26BB027D92CAF2CF0293B6D9C08263'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '17:30:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '232522_EF18F1929FA21503729C3583BA618FAB'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, NULL,
  4, 1,
  3, '232525_B363F61992538032FD6420F4963572AB'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '17:30:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '232541_256F788168B848EABDA41983C627A6D9'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '262489_B432952F41BBC132E19117FA623039EB'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-24', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262508_6CD077D9923AAAC5A69674C3772CF56E'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '17:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262529_48D60938213BEFAE3B53DCCFA8E83189'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '17:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262536_DD9865B0A411FF03D64852CEC9947796'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '116488' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262542_D2025723B519745DEE8F780EAB02E4E5'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262547_6A5C3D3191F5A13186F57DCB86803529'
FROM teams ht
JOIN teams at ON at.external_id = '116488' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '230140_02090B419575DAF56F03545678B9902D'
FROM teams ht
JOIN teams at ON at.external_id = '119370' AND at.source_system_id = 3

WHERE ht.external_id = '116489' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 6,
  3, '262268_906E879665C4C40874451882660819C8'
FROM teams ht
JOIN teams at ON at.external_id = '116489' AND at.source_system_id = 3

WHERE ht.external_id = '119370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '12:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '230154_902DBF4A5C368FEBDDF3FE6AF84CCBD5'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231297_B953F9EEDA4A9A3E02EA37DF0F8E4E04'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-04', '20:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '231303_BC8E67746B667188604AFF41AF250DE6'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '231308_6DF126D695BF89DDA3CC9C2EBC7E64F1'
FROM teams ht
JOIN teams at ON at.external_id = '116490' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '18:00:00', 3,
  ht.id, at.id, NULL,
  7, 1,
  3, '231335_F8039B0629E19C6A2B4F39B1031E637C'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262456_C49F91F8DAB56A94EC749C7AD3CF46D1'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '116490' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '230161_029A4142DCBB1C42562E61A14A6639B1'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '232497_EA89C79CC3181CE339175AFFD381CF22'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-04', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '232503_28A48B68B8E77F68909B49BBD0AA3C45'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '232508_8BC689AFD6CF9A3C558D8DD0155D805A'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '232535_7CD0F74E76ABDD360C206EC6C52F83EB'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 5,
  3, '262490_FDEEF50B8B6CE9610D645F0E9B896CE6'
FROM teams ht
JOIN teams at ON at.external_id = '116491' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262528_99C1A0E27A61DB5FC314A131038EE124'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '116491' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 0,
  3, '231158_FB1D3C46B089CA71102EE869C0099A6A'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '231170_46FF922EB1BCF08AFB3313157C0C9439'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '231305_37D6FE0467192834E1C665F9EFEEB893'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, NULL,
  5, 2,
  3, '231321_371EDC12E52E5EEA059288BD41BDAC27'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '262427_57113E96B7F0FC5946123E19E40BDB50'
FROM teams ht
JOIN teams at ON at.external_id = '116492' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '12:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262470_D84BC46F2DCEEF7606439C425A6CD900'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '116492' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '231186_7132B7CC6B88EFD306A5145475A6E564'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '232505_DFCC7ACC3DAB109581D59B1A0503F897'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '232521_16A4F1AB8A7352DA6FE53CEFF79C4248'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '08:00:00', 3,
  ht.id, at.id, NULL,
  3, 0,
  3, '262499_FA339BFCA6E24D2006E50024FD57B27C'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262515_339A2A387D9DA9F98DC50925D93324E4'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-31', '20:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231174_139CF5A463049039583D6B1B1CA9D41E'
FROM teams ht
JOIN teams at ON at.external_id = '116493' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '10:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262537_E208A9F76A07678146229D73D6141A51'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '116493' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '238211_D4EC6C1FF07EDDB471D3AAE7A5ED7DBD'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '08:00:00', 3,
  ht.id, at.id, NULL,
  6, 0,
  3, '238219_BBCB6CA0ECD794EE7A29DDD117D69BE5'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-05', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 4,
  3, '238541_0068DB8598FAC4D7569CA87D74D06255'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238567_AB889A93E35F465C82FC93644155DF81'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '118361' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '08:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '238578_4B061877C3676A5E8AD3C56BC2ABF470'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '08:00:00', 3,
  ht.id, at.id, NULL,
  0, 4,
  3, '263341_29D47374101176A45CF3765EA8FBBB1C'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266029_31032B1903123065819B869B922D0075'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '116494' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266054_94A98D6A81466DCB166F3D06E11E9E76'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266059_69DF890BFD91E011ED73A2A596EAB042'
FROM teams ht
JOIN teams at ON at.external_id = '116494' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '17:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '230152_F985950511324120877EE8F8FD862ED3'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '18:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '231331_7EE19ACD7DDEF2C280DA27A319436667'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '14:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '231344_1F9482F6D2452B2512C9B21B5E41157A'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231354_A20513EE22880F5D6AA0F6A67289E01B'
FROM teams ht
JOIN teams at ON at.external_id = '116495' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262474_6BE5B98D2430A14D6E79E774D4E0EED2'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '116495' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-07', '15:00:00', 3,
  ht.id, at.id, NULL,
  4, 3,
  3, '230159_2D35D6793B4C035129DA282378ACAA97'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '231173_CFD8987AA77838841B025E2C0E73F4B5'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-16', '16:00:00', 3,
  ht.id, at.id, NULL,
  1, 1,
  3, '232531_72E8A3945041DF08B7600A356CC9B847'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', '12:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '232544_091EC0E6672A81759BA98E4EB64DCD8F'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '232554_3527A3CDF16D762B32E068049EBE5CD9'
FROM teams ht
JOIN teams at ON at.external_id = '116496' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262541_753E15C3A33393AE0BCA85D2B3C4B420'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '116496' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-13', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238208_DE608AA6CFD6C832A5FD39297CAF0F68'
FROM teams ht
JOIN teams at ON at.external_id = '118361' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-27', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '238222_CE589E778E3311C0F472F4769BDAC85C'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-25', '20:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '238554_29CF8A51BC7A3D758A3FAF1F3E860E11'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '238565_DE528C7F614F0624FB739723EE775B4D'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238582_2EBA8548478B4F747B1D3633E060A7A8'
FROM teams ht
JOIN teams at ON at.external_id = '124917' AND at.source_system_id = 3

WHERE ht.external_id = '116497' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '17:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263353_C97A4D385C7B7742C0B7A18FF0F29E60'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '15:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266049_8AF6D95BEEBFFCCA13DC354CF077CA38'
FROM teams ht
JOIN teams at ON at.external_id = '116497' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '15:00:00', 3,
  ht.id, at.id, NULL,
  2, 0,
  3, '232493_631040920BA320412DF645EEC0552215'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-11', '18:00:00', 3,
  ht.id, at.id, NULL,
  7, 1,
  3, '232513_514A733EC3B798D2D94F9CCDB643BBE2'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:00:00', 3,
  ht.id, at.id, NULL,
  4, 0,
  3, '232518_599D5A4D1683E9879D43F757A68157AB'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '08:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '262498_CE4D4EBF19F6E26A139E0F3EC5EA1CFB'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '117234' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262534_FF109F41049AC36201F3A610ADAAC4E0'
FROM teams ht
JOIN teams at ON at.external_id = '117234' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '14:00:00', 3,
  ht.id, at.id, NULL,
  0, 2,
  3, '231311_D53E8EFB45E0A815D5756254C6399678'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '16:00:00', 3,
  ht.id, at.id, NULL,
  5, 3,
  3, '262422_F541296919E38DAEBFD61F3635ECF9D7'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '117235' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262437_A591B0DF3C4C0BBC15A8CDACA4D3B471'
FROM teams ht
JOIN teams at ON at.external_id = '117235' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '12:00:00', 3,
  ht.id, at.id, NULL,
  5, 1,
  3, '232511_303E1BA49462920205E4DA1264DAAB22'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '262494_E9AB5AD112290C2A7437A156F5AAE3D0'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '117236' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262509_9F5B7F0930FC3167F7B92FFAC60A69CF'
FROM teams ht
JOIN teams at ON at.external_id = '117236' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '16:45:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '231298_BC520835F7241898D9E31128B4FC5B73'
FROM teams ht
JOIN teams at ON at.external_id = '118202' AND at.source_system_id = 3

WHERE ht.external_id = '117364' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262447_0517AE17BE870980EE0BCC5638997C52'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262466_604E680445864667132F1D8680D2A0C5'
FROM teams ht
JOIN teams at ON at.external_id = '117364' AND at.source_system_id = 3

WHERE ht.external_id = '118636' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '15:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '232498_7F4E48A57DC7F4C1E0769C577DD43DDC'
FROM teams ht
JOIN teams at ON at.external_id = '118203' AND at.source_system_id = 3

WHERE ht.external_id = '117370' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262519_20E62336955FBC416B2AFB6C494A9F1F'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '262533_9CF4070FF7C4C381F2AE583E391CB82D'
FROM teams ht
JOIN teams at ON at.external_id = '117370' AND at.source_system_id = 3

WHERE ht.external_id = '118637' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-13', '20:00:00', 3,
  ht.id, at.id, NULL,
  0, 3,
  3, '231161_283B10151F05981A250380F7ACBB8B3F'
FROM teams ht
JOIN teams at ON at.external_id = '118636' AND at.source_system_id = 3

WHERE ht.external_id = '118202' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-13', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 6,
  3, '231177_289E61D2280143806B1100C67FD90F7B'
FROM teams ht
JOIN teams at ON at.external_id = '118637' AND at.source_system_id = 3

WHERE ht.external_id = '118203' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-25', '21:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238553_A88295E57573CEE94C1794F9D8056F8B'
FROM teams ht
JOIN teams at ON at.external_id = '118361' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-01', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238585_2598E5B463AE1C4916F356F93A28F62C'
FROM teams ht
JOIN teams at ON at.external_id = '118353' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '08:00:00', 3,
  ht.id, at.id, NULL,
  3, 2,
  3, '263342_438B2B30168151BFE8F2182352211AFF'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '10:00:00', 3,
  ht.id, at.id, NULL,
  7, 3,
  3, '263344_B297C2242A4B276C257FA3A780B0DF2C'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266041_825B41287C5A0E1EF42B32184AEEDB4C'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '118353' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, NULL,
  3, 3,
  3, '233715_25EA80D97851F4F51123459D53C5774F'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '20:00:00', 3,
  ht.id, at.id, NULL,
  5, 0,
  3, '233742_18914AC01108642A88A74F5362DB92DF'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '16:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261836_22AC2FE51C44917D7C1E77BA7FB0AE60'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '118354' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '261861_B65814B2F0ED2C09534C95FE8581AB3A'
FROM teams ht
JOIN teams at ON at.external_id = '118354' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-14', '14:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238209_6D8100A38E708B552495237370B9F894'
FROM teams ht
JOIN teams at ON at.external_id = '124917' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238224_6CF08C9B3593CC4918B10C6BC5D6B49E'
FROM teams ht
JOIN teams at ON at.external_id = '118361' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  0, 8,
  3, '263340_EB973AEE9579D3844ED4F2372F4525F3'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '118355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '15:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '263352_35DCFC0E4144823C43E3A9AA69B7D8F0'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-31', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266064_56B62D0F7CD439D25F4AB3B3D94DB0B6'
FROM teams ht
JOIN teams at ON at.external_id = '118355' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238218_7E3AC349543DB359B1EFA1D1A02ADB23'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '124917' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '16:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238546_9D358AF9DDB56353548AB1548EE7DF56'
FROM teams ht
JOIN teams at ON at.external_id = '118361' AND at.source_system_id = 3

WHERE ht.external_id = '118356' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-26', '14:00:00', 3,
  ht.id, at.id, NULL,
  11, 0,
  3, '238559_BBDA7778FB4F7C153EABF78866C4518A'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '266045_03BA6189F89F2292890D5BEBF1C10A82'
FROM teams ht
JOIN teams at ON at.external_id = '118356' AND at.source_system_id = 3

WHERE ht.external_id = '119075' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, NULL,
  2, 3,
  3, '233775_D071135885BF46298C20FF8D91C3F90E'
FROM teams ht
JOIN teams at ON at.external_id = '119337' AND at.source_system_id = 3

WHERE ht.external_id = '118357' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '16:00:00', 3,
  ht.id, at.id, NULL,
  0, 8,
  3, '261812_46C80C53DF9626870D76F9F575E455F7'
FROM teams ht
JOIN teams at ON at.external_id = '118357' AND at.source_system_id = 3

WHERE ht.external_id = '119337' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-11-23', NULL, 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238574_25313C07293BA6B163B3C46D522CCA5D'
FROM teams ht
JOIN teams at ON at.external_id = '124917' AND at.source_system_id = 3

WHERE ht.external_id = '118361' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '238551_973B390972A8656877B9D10C09411AF2'
FROM teams ht
JOIN teams at ON at.external_id = '119075' AND at.source_system_id = 3

WHERE ht.external_id = '124917' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '10:00:00', 3,
  ht.id, at.id, NULL,
  2, 2,
  3, '268144_A042336BB3ADCC4A10E73BCA8931F120'
FROM teams ht
JOIN teams at ON at.external_id = '138544' AND at.source_system_id = 3

WHERE ht.external_id = '134573' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '13:05:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268147_51F8D510F524C8D29799E0C09114ABF3'
FROM teams ht
JOIN teams at ON at.external_id = '134573' AND at.source_system_id = 3

WHERE ht.external_id = '135071' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', '19:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268149_4E4D5F4E8D67E9F052796400959F191F'
FROM teams ht
JOIN teams at ON at.external_id = '134573' AND at.source_system_id = 3

WHERE ht.external_id = '134746' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268152_BA510EF2B924B84CFCE41A38426FF81C'
FROM teams ht
JOIN teams at ON at.external_id = '140355' AND at.source_system_id = 3

WHERE ht.external_id = '134573' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268154_19BC5FCCD3F765E12851D5C776F565A0'
FROM teams ht
JOIN teams at ON at.external_id = '134573' AND at.source_system_id = 3

WHERE ht.external_id = '138544' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', '14:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268155_337ABCA02D2B24F5D12A71151D9544DC'
FROM teams ht
JOIN teams at ON at.external_id = '135071' AND at.source_system_id = 3

WHERE ht.external_id = '134573' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-10', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268160_FC44E68D35E2931415F31B619E8D1351'
FROM teams ht
JOIN teams at ON at.external_id = '134573' AND at.source_system_id = 3

WHERE ht.external_id = '140355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '269807_151D8C65C7C97A739A92E135611B9EF9'
FROM teams ht
JOIN teams at ON at.external_id = '134746' AND at.source_system_id = 3

WHERE ht.external_id = '134573' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, NULL,
  3, 1,
  3, '268143_21C687982E78D1EC94A670CAD221CA55'
FROM teams ht
JOIN teams at ON at.external_id = '134746' AND at.source_system_id = 3

WHERE ht.external_id = '135071' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '12:00:00', 3,
  ht.id, at.id, NULL,
  2, 1,
  3, '268146_BB50E5EE4B73F9F6D25B067266ED47D5'
FROM teams ht
JOIN teams at ON at.external_id = '134746' AND at.source_system_id = 3

WHERE ht.external_id = '138544' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-22', '19:00:00', 3,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268148_32E3AC3B057DCCB8DDE65796FDC658B4'
FROM teams ht
JOIN teams at ON at.external_id = '140355' AND at.source_system_id = 3

WHERE ht.external_id = '134746' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-19', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268153_9F879293A2C1D90C9A1CDCEBCEC316C9'
FROM teams ht
JOIN teams at ON at.external_id = '135071' AND at.source_system_id = 3

WHERE ht.external_id = '134746' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-26', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268156_26F711A8D2EF2CACDF20DB206BCC3B20'
FROM teams ht
JOIN teams at ON at.external_id = '134746' AND at.source_system_id = 3

WHERE ht.external_id = '140355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '20:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268158_CEA05ABC3AC5442D22684B879312E491'
FROM teams ht
JOIN teams at ON at.external_id = '138544' AND at.source_system_id = 3

WHERE ht.external_id = '134746' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-15', '10:00:00', 3,
  ht.id, at.id, NULL,
  1, 3,
  3, '268145_7AF63FC0219C182839FF74D09D0E1481'
FROM teams ht
JOIN teams at ON at.external_id = '135071' AND at.source_system_id = 3

WHERE ht.external_id = '140355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-04-12', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268151_C12C4734EDA89C455E74EB5DFC3EE276'
FROM teams ht
JOIN teams at ON at.external_id = '135071' AND at.source_system_id = 3

WHERE ht.external_id = '138544' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-03', '13:30:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268157_A56F6BF740A6FD31CE0F3C02706F0EB0'
FROM teams ht
JOIN teams at ON at.external_id = '140355' AND at.source_system_id = 3

WHERE ht.external_id = '135071' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-09', '18:00:00', 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268159_53B4D93DC9235B01BE565DA6C1B3CAAE'
FROM teams ht
JOIN teams at ON at.external_id = '138544' AND at.source_system_id = 3

WHERE ht.external_id = '135071' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-03-29', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '268150_FAB3621202A31F4DE6975ED8B4902130'
FROM teams ht
JOIN teams at ON at.external_id = '138544' AND at.source_system_id = 3

WHERE ht.external_id = '140355' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  1, '2026-05-17', NULL, 1,
  ht.id, at.id, NULL,
  NULL, NULL,
  3, '269808_CF0F4BBFFF1EC62856AFDED9C6839108'
FROM teams ht
JOIN teams at ON at.external_id = '140355' AND at.source_system_id = 3

WHERE ht.external_id = '138544' AND ht.source_system_id = 3
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id;

