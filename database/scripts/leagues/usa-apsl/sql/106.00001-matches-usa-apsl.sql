-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - APSL
-- Total Records: 517
-- Match type: 1=league, 3=practice, 4=scrimmage
-- Match status: 1=scheduled, 3=completed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Venues
INSERT INTO venues (name, address) 
VALUES ('mercer county community college', '1200 Old Trenton Rd  West Windsor NJ 08550')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('lancaster catholic high school - crusader stadium', '655 Stadium Rd  Lancaster PA ')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('veteran''s park -', '489 Bill Zimmermann Jr Way  Bayville NJ 08721')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('westhampton sports complex', '301 Bridge St  Westampton Township NJ 08060')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('holy family university - tiger field', '4601 Stevenson St  Philadelphia PA 19114')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('south philadelphia supersite', '2926-2968 South 10th St.  Philadelphia PA 19148')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('owl hollow field', '440 Arthur Kill Rd  Staten Island NY 10312')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('st. john''s university - belson stadium', '8000 Utopia Parkway  Queens NY 11439')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('roosevelt island - jack mcmanus field', '729 Main Street  New York NY 10044')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('randalls island - field 75', '20 Randalls Island Park  New York NY 10035')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('travers island', '31 Shore Road  Pelham Manor NY 10803')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('garfield high school', '500 Palisade Ave  Garfield NJ 07026')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('randalls island - field 83', '20 Randalls Island Park  New York NY 10035')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('patriot park - 1', '12111 Braddock Rd  Fairfax VA 22030')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('poplar tree park - 2', '4718 Stringfellow Road  Chantilly VA 20152')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('liberty sports park -', '220 Prince George''s Boulevard  Upper Marlboro MD 20774')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('tbd', NULL)
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('hofstra university soccer stadium', '230 Hofstra University  Hempstead NY 11549')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('tibbetts brook park - field 3', 'Tibbetts Road  Yonkers NY 10705')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('joseph f. fosina field', '436 5th Ave  New Rochelle NY 10801')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('queens college', '65-30 Kissena Blvd  Queens NY 11367')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('laurel hill park', 'New County Road  Secaucus NJ 07094')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('burlington high school', '123 Cambridge St  Burlington MA 01803')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('harry della russo stadium', '75 Park Ave  Revere MA 02151')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('pine banks park', '1087 Main St  Malden MA 02148')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('roberts playground', '56 Dunbar Ave  Boston MA 02124')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('brush field', '114 Winn St  Burlington MA 01803')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('lunenburg middle high school', '1075 Massachusetts Ave  Lunenburg MA 01462')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('game on fitchburg', '100 Game On Way  Fitchburg MA 01420')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('english high school', '10 Williams St  Jamaica Plain MA 02130')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('irish american home society', '132 Commerce St  Glastonbury CT 06033')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('vale forge', '49 Randolph Rd  Middletown CT 06457')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('municipal stadium', '1200 Watertown Ave  Waterbury CT 06708')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('woodbridge middle school - 1', '2201 York Drive  Woodbridge VA 22192')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('tucker hs', '2910 N Parham Rd,  Henrico VA 23294')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('edison high school - 1', '5801 Franconia Rd  Alexandria VA 22310')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('norfolk collegiate school', '7336 Granby St  Norfolk VA 23505')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('godwin high school -', '2101 Pump Rd  Richmond VA 22192')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('reynolds cc -', '1651 E.Parham Rd  Richmond VA 23228')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('cfc park', '667 Amity Road  Bethany CT 06524')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('penn fusion - kildare''s turf', '601 Westtown Road  West Chester PA 19382')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('germantown supersite', '1199 E Sedgwick St  Philadelphia PA 19150')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('northeast high school', '1601 Cottman Ave  Philadelphia PA 19111')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('toms river high school south', '55 Hyers St  Toms River NJ 08753')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('st joseph academy - moss mill park turf', '1111 Moss Mill Rd  Hammonton NJ 08037')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('fleming park', 'Prescott Street  Yonkers NY 10701')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('susa orlin & cohen sports complex - field 2', '271 Carleton Ave  Central Islip NY 11722')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('susa orlin & cohen sports complex - field 1', '271 Carleton Ave  Central Islip NY 11722')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('rowan university', '297-399 North Campus Drive  Glassboro NJ 08028')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('german american society - nick wiener sr field', '215 Uncle Pete''s Rd  Trenton NJ ')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('john bartram high school', '5847R Elmwood Ave  Philadelphia PA 19143')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('lighthouse field', '101-109 E Erie Ave  Philadelphia PA 19140')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('bryn athyn college -', '2945 College Dr  Bryn Athyn PA 19009')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('seaford high school - seaford hs', '390 North Market St. Seaford,  Seaford, DE 19973-2600.')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('twin pines field -', '250 Lawrenceville - Pennington Rd  Pennington NJ 08534')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('united sports - field 1', '1426 Marshallton Thorndale Rd  Downingtown PA 19335')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('thornbury soccer park - field 2', '1200 Westtown Rd  West Chester PA 19380')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('carter playground', '656 Columbus Ave.  Boston MA 02118')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('new bedford regional vocational technical hs', '1121 Ashley Blvd  New Bedford MA 02745')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('ceylon park', '105 Ceylon St  Boston MA 02121')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('east boston memorial stadium', '150 Porter St  E Boston MA 02128')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('norfolk christian school - 1', '255 Thole St  Norfolk VA 23505')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('james j. ramp athletic complex - ramp athletic complex', '3300 Solly Ave  Philadelphia PA 19136')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('dilboy stadium', '110 Alewife Brook Pkwy  Somerville MA 02144')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('norfolk collegiate school - 1', '7336 Granby St  Norfolk VA 23505')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('agnes scott college', '141 E College Ave  Decatur GA 30030')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('jm tull gwinnett family ymca', '2985 Sugarloaf Pkwy  Lawrenceville GA 30045')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('the best academy', '1190 Northwest Dr NW  Atlanta GA 30318')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('bay creek park', '175 Ozora Rd  Loganville GA 30052')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('maynard h jackson high school', '801 Glenwood Ave SE  Atlanta GA 30316')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('ebster field', '125 Electric Ave  Decatur GA 30030')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('empower college & career center', '1952 Winder Hwy  Jefferson GA 30549')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('brook run park', '4770 N Peachtree Rd  Dunwoody GA 30338')
ON CONFLICT (name) DO NOTHING;
INSERT INTO venues (name, address) 
VALUES ('piedmont park', 'Piedmont Ave NE at 14th St NE  Atlanta GA 30309')
ON CONFLICT (name) DO NOTHING;

-- Matches
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228138'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '228139'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '18:00:00', 3,
  ht.id, at.id, v.id,
  7, 0,
  1, '228143'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228150'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-11', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 5,
  1, '228157'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '228164'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-01', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '228169'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228174'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'holy family university - tiger field'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '228176'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '228179'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  6, 0,
  1, '236278'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226818'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '226826'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 6,
  1, '226833'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-01', '20:30:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '226823'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 75'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-23', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '226845'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 75'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '12:15:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '226852'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226859'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226840'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '226865'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '226871'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226875'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 83'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '234450'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '234439'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '237182'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '231194'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '238680'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '19:45:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '234449'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231193'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226817'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226831'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-25', '20:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226821'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '226837'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226843'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226846'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'queens college'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226854'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226859'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 4,
  1, '226866'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226870'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-13', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226876'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '233162'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '11:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '231091'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '231096'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '15:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '231097'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '231108'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roberts playground'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-01', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '233165'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-06', '19:15:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '231110'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brush field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '14:00:00', 3,
  ht.id, at.id, v.id,
  8, 1,
  1, '231111'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lunenburg middle high school'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '231086'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brush field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-08-24', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '227286'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231085'
FROM teams ht
JOIN teams at ON at.external_id = '114843' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '16:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '233162'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '13:15:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '231090'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '15:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '231095'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 8,
  1, '231101'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '12:30:00', 3,
  ht.id, at.id, v.id,
  0, 10,
  1, '231109'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '14:00:00', 3,
  ht.id, at.id, v.id,
  1, 8,
  1, '231111'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lunenburg middle high school'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '13:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '227807'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '236815'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  6, 5,
  1, '236816'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '236819'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  6, 2,
  1, '236820'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '236822'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 7,
  1, '230061'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '230098'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'woodbridge middle school - 1'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '233406'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tucker hs'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '237182'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '237183'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228597'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk collegiate school'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '14:45:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '234440'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'godwin high school -'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '228536'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'reynolds cc -'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '227806'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '227808'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  5, 6,
  1, '236816'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '236819'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '236821'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '12:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '236823'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'cfc park'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226814'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  8, 1,
  1, '226825'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '226827'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '12:15:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226834'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, v.id,
  4, 5,
  1, '226838'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-23', '21:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '226845'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 75'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '226851'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-06', '20:45:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226856'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-19', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226862'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226870'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-14', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226874'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228134'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '228142'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228144'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228150'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228160'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228163'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '228187'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '18:30:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '228178'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-30', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228168'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'toms river high school south'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228180'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st joseph academy - moss mill park turf'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-18', '18:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '236282'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '227806'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '19:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '236815'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '236817'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '18:30:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '236818'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '236821'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '13:00:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '236822'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226816'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '226828'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-25', '20:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226821'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, v.id,
  6, 3,
  1, '226833'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226841'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-14', '20:30:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '226848'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226850'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-06', '20:45:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226856'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226863'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-09', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '226869'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'fleming park'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-14', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226878'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '19:30:00', 3,
  ht.id, at.id, v.id,
  7, 4,
  1, '230061'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  8, 0,
  1, '233401'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '234452'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-04', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '234447'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '234437'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '19:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '251157'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '235879'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '19:45:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '234449'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226816'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '226824'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 2'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '12:15:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226830'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '12:15:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226834'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226843'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '20:00:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '226847'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '12:15:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '226852'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '12:15:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226860'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '12:15:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226867'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226868'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '12:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226877'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '226817'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '19:30:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '226829'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '226832'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-01', '20:30:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '226823'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 75'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, v.id,
  5, 4,
  1, '226838'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-23', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '226844'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226853'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-12', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226861'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226863'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '14:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226872'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '12:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226877'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '226815'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226826'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '21:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '226832'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-01', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226820'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226839'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226846'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'queens college'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '226850'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '226858'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226864'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226868'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-14', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226874'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228137'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rowan university'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-17', '20:30:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '236246'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 7,
  1, '228143'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228148'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '228154'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228162'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rowan university'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228173'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228159'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st joseph academy - moss mill park turf'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '228180'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st joseph academy - moss mill park turf'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '19:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '228170'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st joseph academy - moss mill park turf'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-18', '20:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228167'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bryn athyn college -'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '13:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '230094'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-04', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '234447'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '233404'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '231194'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '235879'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '18:30:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '234448'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231193'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '17:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '229167'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '228142'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228146'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228151'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '15:30:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228155'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '236273'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228162'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rowan university'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '11:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228165'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228174'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'holy family university - tiger field'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '19:00:00', 3,
  ht.id, at.id, v.id,
  5, 4,
  1, '228177'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228183'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'twin pines field -'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-10', '20:15:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228185'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'united sports - field 1'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '16:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '228136'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 5,
  1, '228139'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '228147'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '228152'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228156'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '228160'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '14:30:00', 3,
  ht.id, at.id, v.id,
  0, 10,
  1, '228172'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'thornbury soccer park - field 2'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:45:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '236281'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228182'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-10', '20:15:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228185'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'united sports - field 1'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-18', '20:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228167'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bryn athyn college -'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-08-24', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '227287'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'carter playground'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '231088'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '19:00:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '242297'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '13:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '231089'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '231094'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ceylon park'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '245209'
FROM teams ht
JOIN teams at ON at.external_id = '114843' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  8, 0,
  1, '231101'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '231108'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roberts playground'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-03', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231102'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-08-24', '17:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '227286'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '231088'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-13', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '242319'
FROM teams ht
JOIN teams at ON at.external_id = '126357' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'east boston memorial stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '11:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '231091'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '18:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231093'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '12:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '245207'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '11:30:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '231103'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '18:15:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '231106'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '13:30:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '231100'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '234438'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '230098'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'woodbridge middle school - 1'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 6,
  1, '234452'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '234439'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 10,
  1, '228534'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk christian school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '15:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '230062'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '228536'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'reynolds cc -'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '17:00:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '229167'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228138'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228145'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228152'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-01', '21:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '236251'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-04', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228153'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228163'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228171'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228159'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st joseph academy - moss mill park turf'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '19:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228183'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'twin pines field -'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-03', '20:30:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '228186'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '11:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228188'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'james j. ramp athletic complex - ramp athletic complex'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226818'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 8,
  1, '226825'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '226829'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '226837'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226841'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 6,
  1, '226847'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '226855'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226864'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '226857'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '226873'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '13:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226879'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226819'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '12:15:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226830'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226836'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-01', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226820'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '226855'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-30', '20:15:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '226849'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '19:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '226840'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-12', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226861'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-19', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '226862'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-09', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '226869'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'fleming park'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-13', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226876'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-08-24', '14:30:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '227288'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '13:30:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '242310'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '13:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '231089'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '15:30:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '231095'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '12:30:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '245207'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '13:45:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '231104'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '248373'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dilboy stadium'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '13:30:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '231100'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '231086'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brush field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '234438'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '17:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '238667'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'woodbridge middle school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '234450'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '233356'
FROM teams ht
JOIN teams at ON at.external_id = '114846' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '17:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '237183'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '251157'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '18:30:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '234448'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '15:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '234433'
FROM teams ht
JOIN teams at ON at.external_id = '114846' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk christian school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-06', '14:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '238975'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '12:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '228135'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '228147'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228151'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '13:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '228154'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228158'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '13:00:00', 3,
  ht.id, at.id, v.id,
  7, 1,
  1, '236276'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 7,
  1, '228166'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-01', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 5,
  1, '228169'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '19:00:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '228175'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '18:30:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '228178'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '11:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228188'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'james j. ramp athletic complex - ramp athletic complex'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '17:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '238667'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'woodbridge middle school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '233406'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tucker hs'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-04', '16:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '233403'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk collegiate school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '19:30:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '234437'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, v.id,
  10, 0,
  1, '228534'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk christian school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '13:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '228597'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk collegiate school'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '15:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '234433'
FROM teams ht
JOIN teams at ON at.external_id = '114846' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk christian school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228134'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '11:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '228140'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228146'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114835' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '228148'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-04', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228153'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-11', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '228157'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  7, 1,
  1, '228166'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '14:30:00', 3,
  ht.id, at.id, v.id,
  10, 0,
  1, '228172'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'thornbury soccer park - field 2'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  12, 1,
  1, '236279'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '19:00:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '228181'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-02', '20:30:00', 3,
  ht.id, at.id, v.id,
  7, 0,
  1, '228184'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '227807'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '227808'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '236817'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '236818'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 6,
  1, '236820'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '12:30:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '236823'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'cfc park'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '226815'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226822'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '226827'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226836'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '226842'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-23', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '226844'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226854'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '12:15:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '226867'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '226857'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '226871'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-14', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226878'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '13:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228202'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '17:00:00', 3,
  ht.id, at.id, v.id,
  12, 0,
  1, '228209'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '11:00:00', 3,
  ht.id, at.id, v.id,
  9, 2,
  1, '228212'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228217'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '11:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '228222'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 7,
  1, '228226'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228231'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '10:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228235'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-18', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258147'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258150'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '09:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258165'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '10:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258168'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '226819'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226822'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '226831'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226835'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226839'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-14', '20:30:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '226848'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '226851'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '12:15:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226860'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '226865'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '14:30:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226872'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '13:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226879'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228202'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228207'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228211'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '09:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228215'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '12:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228218'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '10:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228221'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '228224'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '13:00:00', 3,
  ht.id, at.id, v.id,
  13, 0,
  1, '228233'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258167'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '15:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258170'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-15', '15:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258172'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-22', '14:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258174'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '09:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228205'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'piedmont park'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  6, 2,
  1, '228208'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '12:30:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '228218'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '16:00:00', 3,
  ht.id, at.id, v.id,
  14, 0,
  1, '228227'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228231'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228234'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '14:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '228236'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-14', '14:00:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '228213'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-18', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258147'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258149'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258164'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '10:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258169'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-22', '14:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258174'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '10:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '228206'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '228211'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '14:00:00', 3,
  ht.id, at.id, v.id,
  8, 0,
  1, '228219'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228222'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228225'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '14:30:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '228228'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '228232'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '14:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228236'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-18', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258146'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258151'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258167'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '18:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258171'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-22', '13:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258175'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 6,
  1, '228201'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '15:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '228204'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 6,
  1, '228208'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '11:00:00', 3,
  ht.id, at.id, v.id,
  2, 9,
  1, '228212'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '228216'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228220'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228224'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '14:30:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '228228'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258150'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '18:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258171'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-15', '15:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258172'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-22', NULL, 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258176'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228203'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '10:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '228206'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228210'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '228216'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '10:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '228221'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, v.id,
  18, 0,
  1, '228230'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '10:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228235'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-14', '14:00:00', 3,
  ht.id, at.id, v.id,
  3, 5,
  1, '228213'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258151'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258166'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '10:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258169'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-15', '13:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258173'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228137'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rowan university'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '228141'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '236250'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228156'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-11', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228161'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '228164'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228171'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 6,
  1, '228175'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '19:00:00', 3,
  ht.id, at.id, v.id,
  4, 5,
  1, '228177'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '228187'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '228181'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226814'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '226824'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 2'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '226828'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226835'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '226842'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226853'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-30', '20:15:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '226849'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '226858'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 4,
  1, '226866'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226873'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-11', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226875'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 83'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  6, 3,
  1, '228201'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '228205'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'piedmont park'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228210'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '09:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '228215'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '17:00:00', 3,
  ht.id, at.id, v.id,
  7, 0,
  1, '228223'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '09:00:00', 3,
  ht.id, at.id, v.id,
  7, 3,
  1, '228226'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '09:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228229'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '09:00:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '228232'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-04', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258046'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258148'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258164'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '10:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258168'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '16:30:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '228136'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '16:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '228141'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228145'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '11:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228149'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '15:30:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228155'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228158'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228173'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lighthouse field'
WHERE ht.external_id = '116079' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-13', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '236280'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-22', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '228179'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-30', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228168'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'toms river high school south'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-02', '20:30:00', 3,
  ht.id, at.id, v.id,
  0, 7,
  1, '228184'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'penn fusion - kildare''s turf'
WHERE ht.external_id = '114850' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '12:00:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '228135'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228140'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228144'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228149'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '11:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '236270'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-11', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228161'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westhampton sports complex'
WHERE ht.external_id = '115227' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '11:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228165'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228176'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'south philadelphia supersite'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228182'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-03', '20:30:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '228186'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
WHERE ht.external_id = '114840' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-07', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '228170'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st joseph academy - moss mill park turf'
WHERE ht.external_id = '114833' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-08-24', '14:30:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '227288'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '15:30:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '231087'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '13:30:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '242310'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-24', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231092'
FROM teams ht
JOIN teams at ON at.external_id = '114843' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'east boston memorial stadium'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '231094'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ceylon park'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '15:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '231097'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '11:30:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '231103'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '12:30:00', 3,
  ht.id, at.id, v.id,
  10, 0,
  1, '231109'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-08-24', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '227287'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'carter playground'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-07', '15:30:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '231087'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-14', '19:00:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '242297'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '13:15:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '231090'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '231096'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-11', '18:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231099'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '13:45:00', 3,
  ht.id, at.id, v.id,
  3, 5,
  1, '231104'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '18:15:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '231106'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-06', '19:15:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '231110'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brush field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 8,
  1, '233401'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-27', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '230094'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-04', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '233403'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk collegiate school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-18', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '233404'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-25', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '233356'
FROM teams ht
JOIN teams at ON at.external_id = '114846' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-08', '15:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '230062'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '14:45:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '234440'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'godwin high school -'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-15', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '238680'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-06', '14:30:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '238975'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-28', '15:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '228204'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '17:00:00', 3,
  ht.id, at.id, v.id,
  0, 12,
  1, '228209'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228214'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '14:00:00', 3,
  ht.id, at.id, v.id,
  0, 8,
  1, '228219'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-26', '17:00:00', 3,
  ht.id, at.id, v.id,
  0, 7,
  1, '228223'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '16:00:00', 3,
  ht.id, at.id, v.id,
  0, 14,
  1, '228227'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, v.id,
  0, 18,
  1, '228230'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-23', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 13,
  1, '228233'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258148'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '09:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258165'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-15', '13:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258173'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-22', '13:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258175'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-17', '20:30:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '236246'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '236250'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-01', '21:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '236251'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-05', '11:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '236270'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '116136' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '236273'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-10-19', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 7,
  1, '236276'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'john bartram high school'
WHERE ht.external_id = '114847' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 12,
  1, '236279'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-13', '21:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '236280'
FROM teams ht
JOIN teams at ON at.external_id = '116079' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'german american society - nick wiener sr field'
WHERE ht.external_id = '124946' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-11-20', '20:45:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '236281'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
WHERE ht.external_id = '114836' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 6,
  1, '236278'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster catholic high school - crusader stadium'
WHERE ht.external_id = '114808' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2025-12-18', '18:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '236282'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
WHERE ht.external_id = '114822' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-04', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258046'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-18', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258146'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-01-25', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258149'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-01', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258166'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-08', '15:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258170'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  4, '2026-02-22', NULL, 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258176'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO NOTHING;

