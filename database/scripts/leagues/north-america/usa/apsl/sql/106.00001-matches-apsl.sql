-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - APSL
-- Total Records: 22
-- Match type: 1=league, 3=practice, 4=scrimmage
-- Match status: 1=scheduled, 3=completed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Venues
INSERT INTO venues (name, address) 
VALUES ('lighthouse field', '101-109 E Erie Ave  Philadelphia PA 19140')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('south philadelphia supersite', '2926-2968 South 10th St.  Philadelphia PA 19148')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('john bartram high school', '5847R Elmwood Ave  Philadelphia PA 19143')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('german american society - nick wiener sr field', '215 Uncle Pete''s Rd  Trenton NJ 08691')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('lancaster catholic high school - crusader stadium', '655 Stadium Rd  Lancaster PA ')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('toms river high school south', '55 Hyers St  Toms River NJ 08753')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('penn fusion - kildare''s turf', '601 Westtown Road  West Chester PA 19382')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('northeast high school', '1601 Cottman Ave  Philadelphia PA 19111')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('germantown supersite', '1199 E Sedgwick St  Philadelphia PA 19150')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('st joseph academy - moss mill park turf', '1111 Moss Mill Rd  Hammonton NJ 08037')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('westampton sports complex', '301 Bridge St  Westampton Township NJ 08060')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('mercer county community college', '1200 Old Trenton Rd  West Windsor NJ 08550')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);

-- Matches
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-09-07', '16:30:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '228136', '4FB0FBA9E361FD943037208FD92FE052'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '228141', '24DFFB0E5C0290BB7F9E265B12B2B60B'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228145', '996C67767EA6F8582FDD4E45D85C24FF'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-09-28', '11:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228149', '3E4EA61F11A660CABDD3FEE3BB22895C'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-10-05', '15:30:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228155', '02D9E16BC249B3A2DF1B375012187432'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-10-12', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228158', 'DB17A32100FED3D026E0290F62E12C38'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-11-09', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228173', '96347CC85A8CAF1C58C8F297F72FCF1C'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-11-13', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '236280', '151534281E7FFE5BFD67A32406959486'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-11-22', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '228179', 'ECCFC7079889537875B89808B640630B'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-11-30', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228168', '9720322853D607ACB35015EFE43C2242'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'toms river high school south'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-12-02', '20:30:00', 3,
  ht.id, at.id, v.id,
  0, 7,
  1, '228184', 'FD8F0C369F900DAF352D1562E87FBBAE'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-03-15', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '262654', '5218BB8D8FDB6BD1198FD23170B2C132'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-03-22', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '262661', 'BBA01C48D95382510E7D202D63F991E5'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-03-29', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '262666', '41174F4F3DA137C7C8F6EB515A51EDC6'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-04-08', '20:30:00', 3,
  ht.id, at.id, v.id,
  1, 6,
  1, '262668', 'C6933A7FA49158E6147EADC716016FA5'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-04-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '262673', '7EB3068265CAC47C1ED38702B2A43794'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st joseph academy - moss mill park turf'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-04-19', '12:45:00', 3,
  ht.id, at.id, v.id,
  2, 8,
  1, '262679', '981C7A05E53497C076187F477E3DE4D0'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-04-26', '15:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '262685', '7AA833B45063F0A2F3880571555A53B4'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-04-29', '21:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '231085', 'B6C005930E7E59BFB01A53B7917341EC'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-05-03', '19:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262694', '84FC5B1F3FB2716C17408EB641A51C60'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-05-10', '15:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262698', '62B996CFDE22AEACF5C8A8F4E89D0CD7'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2026-05-17', '15:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262705', '4B1DD04980EDBC54754C15FD24CE5078'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

