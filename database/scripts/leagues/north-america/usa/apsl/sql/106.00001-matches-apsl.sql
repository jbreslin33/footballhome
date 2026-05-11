-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - APSL
-- Total Records: 586
-- Match type: 1=league, 3=practice, 4=scrimmage
-- Match status: 1=scheduled, 3=completed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Venues
INSERT INTO venues (name, address) 
VALUES ('mercer county community college', '1200 Old Trenton Rd  West Windsor NJ 08550')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('lancaster catholic high school - crusader stadium', '655 Stadium Rd  Lancaster PA ')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('veteran''s park -', '489 Bill Zimmermann Jr Way  Bayville NJ 08721')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('westampton sports complex', '301 Bridge St  Westampton Township NJ 08060')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('holy family university - tiger field', '4601 Stevenson St  Philadelphia PA 19114')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('south philadelphia supersite', '2926-2968 South 10th St.  Philadelphia PA 19148')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('temple university sports complex', '1300 Master St.  Philadelphia PA 19122')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('northeast high school', '1601 Cottman Ave  Philadelphia PA 19111')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('lancaster bible college', '901 Eden Road  Lancaster PA 17601')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('lighthouse field', '101-109 E Erie Ave  Philadelphia PA 19140')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('st joseph academy - moss mill park turf', '1111 Moss Mill Rd  Hammonton NJ 08037')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('penn fusion - kildare''s turf', '601 Westtown Road  West Chester PA 19382')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('owl hollow field', '440 Arthur Kill Rd  Staten Island NY 10312')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('st. john''s university - belson stadium', '8000 Utopia Parkway  Queens NY 11439')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('roosevelt island - jack mcmanus field', '729 Main Street  New York NY 10044')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('randalls island - field 75', '20 Randalls Island Park  New York NY 10035')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('travers island', '31 Shore Road  Pelham Manor NY 10803')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('garfield high school', '500 Palisade Ave  Garfield NJ 07026')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('randalls island - field 83', '20 Randalls Island Park  New York NY 10035')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('laurel hill park', '36 Laurel Hill Rd  Secaucus NJ 07094')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('hofstra university soccer stadium', '230 Hofstra University  Hempstead NY 11549')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('randalls island - icahn stadium', '20 Randalls Island Park  New York NY 10035')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('joseph f. fosina field', '436 5th Ave  New Rochelle NY 10801')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('susa orlin & cohen sports complex - field 2', '271 Carleton Ave  Central Islip NY 11722')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('tibbetts brook park - field 3', 'Tibbetts Road  Yonkers NY 10705')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('patriot park - 1', '12111 Braddock Rd  Fairfax VA 22030')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('poplar tree park - 2', '4718 Stringfellow Road  Chantilly VA 20152')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('liberty sports park -', '220 Prince George''s Boulevard  Upper Marlboro MD 20774')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('tbd', NULL)
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('queens college', '65-30 Kissena Blvd  Queens NY 11367')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('randalls island - field 74', '20 Randalls Island Park  New York NY 10035')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('verrazano sports complex - field 1', '1990 Shore Parkway  New York NY 11214')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('burlington high school', '123 Cambridge St  Burlington MA 01803')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('harry della russo stadium', '75 Park Ave  Revere MA 02151')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('pine banks park', '1087 Main St  Malden MA 02148')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('roberts playground', '56 Dunbar Ave  Boston MA 02124')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('brush field', '114 Winn St  Burlington MA 01803')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('lunenburg middle high school', '1075 Massachusetts Ave  Lunenburg MA 01462')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('james p. falzone field', '901 Trapelo Rd  Waltham MA 02452')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('new bedford regional vocational technical hs', '1121 Ashley Blvd  New Bedford MA 02745')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('game on fitchburg', '100 Game On Way  Fitchburg MA 01420')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('english high school', '10 Williams St  Jamaica Plain MA 02130')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('dilboy stadium', '110 Alewife Brook Pkwy  Somerville MA 02144')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('frey park', '327 Walnut St  Lynn MA 01905')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('irish american home society', '132 Commerce St  Glastonbury CT 06033')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('vale forge', '49 Randolph Rd  Middletown CT 06457')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('municipal stadium', '1200 Watertown Ave  Waterbury CT 06708')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('kristine lilly field', '395 Danbury Rd  Wilton CT 06897')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('woodbridge middle school - 1', '2201 York Drive  Woodbridge VA 22192')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('tucker hs', '2910 N Parham Rd,  Henrico VA 23294')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('edison high school - 1', '5801 Franconia Rd  Alexandria VA 22310')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('norfolk collegiate school', '7336 Granby St  Norfolk VA 23505')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('godwin high school -', '2101 Pump Rd  Richmond VA 22192')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('reynolds cc -', '1651 E.Parham Rd  Richmond VA 23228')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('cfc park', '667 Amity Road  Bethany CT 06524')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('susa orlin & cohen sports complex - field 4', '271 Carleton Ave  Central Islip NY 11722')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('germantown supersite', '1199 E Sedgwick St  Philadelphia PA 19150')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('toms river high school south', '55 Hyers St  Toms River NJ 08753')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('central regional high school', '509 Forest Hills Pkwy  Bayville NJ 08721')
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
VALUES ('veteran''s park', '489 Bill Zimmermann Jr Way  Bayville NJ 08721')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('fleming park', 'Prescott Street  Yonkers NY 10701')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('susa orlin & cohen sports complex - field 1', '271 Carleton Ave  Central Islip NY 11722')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('rowan university', '297-399 North Campus Drive  Glassboro NJ 08028')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('mccarthy stadium', '1900 W Olney Ave  Philadelphia Pa 19141')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('camden athletic complex', '401 Delaware Ave  Camden NJ 08102')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('upper moreland high school', '3000 Terwood Rd  Willow Grove PA 19090')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('seaford high school - seaford hs', '390 North Market St. Seaford,  Seaford, DE 19973-2600.')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('twin pines field -', '250 Lawrenceville - Pennington Rd  Pennington NJ 08534')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('united sports - field 1', '1426 Marshallton Thorndale Rd  Downingtown PA 19335')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('thornbury soccer park - field 2', '1200 Westtown Rd  West Chester PA 19380')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('carter playground', '656 Columbus Ave.  Boston MA 02118')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('ceylon park', '105 Ceylon St  Boston MA 02121')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('madison park high school', '2 Madison Park Ct  Boston MA 02120')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('conway field', '560 Somerville Ave  Somerville MA 02143')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('east boston memorial stadium', '150 Porter St  E Boston MA 02128')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('norfolk christian school - 1', '255 Thole St  Norfolk VA 23505')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('bonner high school', '403 N Lansdowne Ave  Drexel Hill PA 19026')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('norfolk collegiate school - 1', '7336 Granby St  Norfolk VA 23505')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('agnes scott college', '141 E College Ave  Decatur GA 30030')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('jm tull gwinnett family ymca', '2985 Sugarloaf Pkwy  Lawrenceville GA 30045')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('the best academy', '1190 Northwest Dr NW  Atlanta GA 30318')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('bay creek park', '175 Ozora Rd  Loganville GA 30052')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('maynard h jackson high school', '801 Glenwood Ave SE  Atlanta GA 30316')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('ebster field', '125 Electric Ave  Decatur GA 30030')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('brook run park', '4770 N Peachtree Rd  Dunwoody GA 30338')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('mount paran christian school', '1275 Stanley Rd NW  Kennesaw GA 30152')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('empower college & career center', '1952 Winder Hwy  Jefferson GA 30549')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('piedmont park', 'Piedmont Ave NE at 14th St NE  Atlanta GA 30309')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('atlanta international school', '2890 N Fulton Dr NE  Atlanta GA 30305')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('hammond park', '705 Hammond Dr  Sandy Springs GA 30328')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('medford high school', '489 Winthrop St  Medford MA 02155')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('providence christian academy', '4575 Lawrenceville Hwy  Lilburn GA 30047')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('ridge road recreational park - ridge road', '21155 Fredrick Rd  Germantown MD 20876')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('willow springs middle school', '1101 W Lucas Rd  Lucas TX 75002')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('bishop lynch high school', '9750 Ferguson Rd  Dallas TX 75228')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('jerry r. walker stadium', 'French Settlement Rd  Little Elm TX 75068')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('scarbourough-handley field', '6201 Craig St  Fort Worth TX 76112')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('coppell middle school', '2701 Ranch Trail  Coppell TX 75019')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('gateway park synthetic fields - field 3', '3800 E First Street  Fort Worth TX 76111')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('summit high school', '1071 Turner Warnell Rd  Arlington TX 76001')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('rolling hills soccer complex - field 15', '2900 Joe B Rushing Rd  Fort Worth TX 76119')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('lowell h. strike middle school', '8798 Scotty''s Lake Lane  The Colony TX 75056')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('waterford kettering high school', '2800 Kettering Dr  Waterford Township MI 48329')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('canton high velocity', '46245 Michigan Ave  Canton Twp MI 48188')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('schoolcraft soccer field', '18600 Haggerty Rd  Livonia MI 48152')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('wisner stadium', '441 Cesar E Chavez Ave  Pontiac MI 48342')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('yntema park', '2199 S Black Corners Rd  Imlay City MI 48444')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('dibrova ukrainian association', '8400 Maltby Rd  Brighton MI 48116')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('evolution sportsplex', '141 S Opdyke Rd  Auburn Hills MI 48326')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('oakland university - grizz dome', '887 Pioneer Dr  Rochester MI 48309')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('waterford mott high school', '1151 Scott Lake Rd  Waterford Twp MI 48328')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('munson park', '2770 North Custer Road  Monroe MI 48162')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('greenmead historical park', '20501 Newburgh Rd  Livonia MI 48152')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('westfield high school - 1', '4700 Stonecroft Blvd  Chantilly VA 20151')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('woodson hs rf#1 west turf', NULL)
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('varina high school', '7053 Messer rd  Henrico VA 23231')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('utz field - 1', '200 S Linwood Ave  Baltimore MD 21224')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('monacan high school - 1', '11501 Smoketree Dr  ichmond VA 23236')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) 
VALUES ('st. paul albanian field', '525 W Auburn Rd  Rochester Hills MI 48307')
ON CONFLICT (name) DO UPDATE SET
  address = COALESCE(EXCLUDED.address, venues.address);

-- Matches
INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-09-07', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228138', '8AE7C2AD9BD22924CC6BBD890C585D9F'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
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
  4, '2025-09-13', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '228139', '776753A62BFAA346894EA2B79F43153C'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
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
  4, '2025-09-20', '18:00:00', 3,
  ht.id, at.id, v.id,
  7, 0,
  1, '228143', 'FBA7E5E1BA74955831D8B9EFB0FE1616'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
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
  4, '2025-09-28', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228150', '8167410B7F53D3EC57DB4D619E613B66'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
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
  4, '2025-10-11', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 5,
  1, '228157', 'E8B85EBD081362AF9A7052DC14B5C58D'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
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
  4, '2025-10-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '228164', 'E567028C6F537FB11E1A944E983C7CCA'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
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
  4, '2025-11-01', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '228169', 'F0A6733D440D235785D0D8FB42E3A264'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228174', '5B34A74F9096FD5FF16716DAA40C9DE7'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'holy family university - tiger field'
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
  4, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '228176', 'D2807B7636094AE0441A868AD0015178'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
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
  4, '2025-12-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  6, 0,
  1, '236278', '985E7D8B94240D03FC5839616F2A1C67'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2026-02-28', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '262642', 'B09344BE9122D605AE2AD8587A3CED5E'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'temple university sports complex'
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
  4, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '262647', '28CBF914F02653CFACAC897D58E61BFF'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
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
  4, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '262650', 'E609AB22212D8D400B555A7460A46BCB'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster bible college'
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
  4, '2026-03-22', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '262659', '97D62178F30D0B83B39CB3F65E08D3F7'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster bible college'
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
  4, '2026-03-29', '16:30:00', 3,
  ht.id, at.id, v.id,
  9, 1,
  1, '262665', '659D7E793E5FD444BC3EE0BE65A96523'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mercer county community college'
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
  4, '2026-04-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262674', '7E4CF60EC4A8F80DA336F7B7E281471F'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster bible college'
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
  4, '2026-04-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262686', 'D1CCE02D290CB78D25DA643B2C92775C'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
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
  4, '2026-05-03', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262693', '958402803E431359221D666CE0BF6ECE'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster bible college'
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
  4, '2026-05-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262697', 'E0581439B062B5B35D23086670AB14CA'
FROM teams ht
JOIN teams at ON at.external_id = '114808' AND at.source_system_id = 1
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
  4, '2026-05-17', '18:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262704', '755F714602E56FA7BDB63F332E79BF39'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lancaster bible college'
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
  4, '2025-09-07', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226818', '5D460492111E8D4D56E6D5538618630C'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2025-09-21', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '226826', '6F20E923911BAA659BDE581873FA1AF3'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2025-09-28', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 6,
  1, '226833', 'EFB053D9C251F34FD13F4E2A2AEBE895'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2025-10-01', '20:30:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '226823', '118A65C135A681F2D86676AFAF997C6C'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 75'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2025-10-23', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '226845', '6D519FC9B9F3DACF281F21C53539EC9C'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 75'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2025-10-26', '12:15:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '226852', '2417AF765A4C484E99869D71060186AB'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2025-11-02', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226859', '59E22358DA8C77C228F62F5518501E69'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2025-11-09', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226840', 'AAC42EB29371DE3107F0CADC960AB96F'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2025-11-16', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '226865', 'A25152534129D54678988979B2C3A1ED'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2025-12-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '226871', 'FB4F3E04B3C4C8493B3950709F8310E5'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2026-01-11', '14:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226875', '2D824FDDD1C3E9A221BBBF8589FD348B'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 83'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2026-03-08', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '260808', 'F53266A0B542840DAFA1C96B8DB2721B'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2026-03-15', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '260810', '55AE06A7CF33A38A8C3998E1ADE3D607'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2026-03-19', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '260798', '2F8A128EB1B83A73C2480E370560F521'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 75'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2026-03-22', '16:00:00', 3,
  ht.id, at.id, v.id,
  0, 6,
  1, '260816', '065A1EECE31FFE045F8E6D6AD60AB8B0'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - icahn stadium'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2026-03-29', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '260827', '213379211114168FCCF0684E91C66D37'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2026-04-12', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260832', 'BB1EF6ABCAAA03BB48C48CB12884A1FD'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2026-04-19', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260840', 'C29018E1A0A478580C6DC9865C4E61D9'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2026-04-26', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260844', '3A37C012144C4EE53DB3FFAE7EBC65FE'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 2'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-05-03', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260850', 'DDB1522C5FADA9BC266AE3367F06D270'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2026-05-10', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260853', '545CA471D09A599154C1B292A6229655'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114811' AND ht.source_system_id = 1
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
  4, '2026-05-16', '20:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260859', 'B87A07443B3B2E3617ABEFAD55FEB408'
FROM teams ht
JOIN teams at ON at.external_id = '114811' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2025-09-27', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '234450', 'FB72931DEB5F7385F0A792B892491A2A'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
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
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '234439', 'A616D6B80AB63981DA72BC6842611571'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
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
  4, '2025-10-18', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '237182', '5AF1732C3CAF655F5C3B3C3DEE3B78AA'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
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
  4, '2025-10-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '231194', '57306C708B7A5CAE0DD4BCD47B6D525F'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
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
  4, '2025-11-15', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '238680', '0FFBB38CC65ED8000202D22C0BDFC0F8'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
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
  4, '2025-11-16', '19:45:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '234449', '8CF1B627C596E4EF0513371D67829276'
FROM teams ht
JOIN teams at ON at.external_id = '114812' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
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
  4, '2025-11-22', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231193', 'DA1AF662D114040546E90DD7183644FF'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114812' AND ht.source_system_id = 1
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
  4, '2025-09-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226817', 'A2937824ACB3A7827E4DCEF78B6C921C'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  2, 3,
  1, '226831', '6E80CEB6E9BE1D58B4DBDD9F0EE70BDA'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2025-09-25', '20:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226821', '785B73EF1FA821E72C4EA4256D2A1734'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '226837', 'D97F7DC5E2717FA01B37D93BE453A2A9'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226843', '8E3BF8F08DD9F02B6F87776F9504AEA4'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2025-10-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226846', '35A773110F894AC084E91833553AB00B'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'queens college'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226854', '623CE5287BF1D8300F78A668C4D1E696'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226866', '59C30B1912714F08F6ED6886F0E1B2E4'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2025-11-23', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226870', '7596E91977938791E6BFA1427CD36591'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2025-12-13', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226876', 'A326B046B6DF05B3BB926106E8420F5D'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-03-01', '12:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260799', '8E92A69DF37A10734B370AE8DCAA2ADC'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2026-03-08', '20:15:00', 3,
  ht.id, at.id, v.id,
  4, 4,
  1, '260806', 'DA0849A33DEC589A8C2A6A416D013224'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - field 74'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2026-03-15', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '260813', '051D263097DA610AD8C0B7C38954B56A'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2026-03-21', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '260818', '40416E2ACF80CAE1B62682BC34D0BA41'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2026-04-12', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260830', '0B925301C15E9B2772A496BAE212F677'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-04-19', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260838', '93B92A243F3FCE9903DA34ED11BBA801'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2026-04-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260843', '0645259B002107C3A6AFC28AB8A39CAC'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'verrazano sports complex - field 1'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2026-05-03', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260851', 'EC717BFB1A3DB85E6DABE11FC9190560'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2026-05-10', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260854', '8D1226D155A94E7E3E0B8E3FFAF4DA0D'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '114813' AND ht.source_system_id = 1
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
  4, '2026-05-17', '19:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260860', 'A36614277A80FEDFB664417547F30F8B'
FROM teams ht
JOIN teams at ON at.external_id = '114813' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2025-09-13', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '233162', '49592684C0A11DF1B1CAC331241F3DC2'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
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
  4, '2025-09-21', '11:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '231091', 'A1BE5CEFE2523B403F02A72D9B32A888'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2025-09-28', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '231096', '50AEF5D2267843A229E0F842A7244BA7'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
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
  1, 2,
  1, '231097', '4865E6EE39096DE2AE8392AFB195530F'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '231108', '6487C405E549CF9E455965499418BBE2'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roberts playground'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2025-11-01', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '233165', '5EC5E7344A39FAF4FC42CA0D0D7A358E'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
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
  4, '2025-11-06', '19:15:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '231110', 'FCA4874F413733576AEDFF793DB498A4'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brush field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
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
  4, '2025-11-09', '14:00:00', 3,
  ht.id, at.id, v.id,
  8, 1,
  1, '231111', '19414C6D4754BF77D0CAF25D04101A25'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lunenburg middle high school'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
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
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '231086', 'B7DAA3BBFACA0DFAF34458E367C7CA45'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brush field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
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
  4, '2026-03-21', '19:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '258660', 'F1ED942F8BDD1A7A6A2D04705F4A9BBF'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
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
  4, '2026-03-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '258661', '40DC41D99A4BF0620903551D41639AFF'
FROM teams ht
JOIN teams at ON at.external_id = '131978' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
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
  4, '2026-04-04', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258651', 'FEEE3E046D892A2C463D73A9B00F45A6'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'james p. falzone field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
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
  4, '2026-04-12', '16:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258668', 'E8966F5240860E383FE260F02F0A1627'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2026-04-18', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258672', 'F7659504F7D69A42CF76E5EB4184979E'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'james p. falzone field'
WHERE ht.external_id = '114814' AND ht.source_system_id = 1
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
  4, '2026-04-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258674', '1A30372421161AD1464D56272C9C7719'
FROM teams ht
JOIN teams at ON at.external_id = '114814' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '131978' AND ht.source_system_id = 1
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
  4, '2026-08-24', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '275438', '4586D9A1CD3DE4546963D294C290F99D'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lunenburg middle high school'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
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
  4, '2025-09-21', '13:15:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '231090', 'D9F5F672C090D6FDD0E22D1C9D622F49'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
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
  4, '2025-09-28', '15:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '231095', '0E210ADB5E213665873E7742799A831E'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
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
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 8,
  1, '231101', 'E38F137E77CB7D2C43D543F1761B6417'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2025-10-26', '12:30:00', 3,
  ht.id, at.id, v.id,
  0, 10,
  1, '231109', '5C51F51A1F8586ADCE95EC7A4077C264'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2026-03-15', '14:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '258655', 'D91C12FE1B6864A3EB71708055C21203'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dilboy stadium'
WHERE ht.external_id = '131978' AND ht.source_system_id = 1
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
  4, '2026-03-21', '15:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '258657', '4769BBED4F9525523C3B4617A455221E'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
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
  4, '2026-04-12', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258669', 'CE00C9CCD861573BB7C09551F2C40D54'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lunenburg middle high school'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
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
  4, '2026-04-19', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258671', '14DC6C902C7F9087AC6FAA6A0B16FE3E'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  NULL, NULL,
  1, '258675', '9EF338B3FA80EEA1E2717213783CE639'
FROM teams ht
JOIN teams at ON at.external_id = '131978' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
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
  4, '2026-05-02', '16:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258679', 'D5C6A81A522F7BB09E5E507C2D1F36DB'
FROM teams ht
JOIN teams at ON at.external_id = '114815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'frey park'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2026-05-10', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258683', '608705C90FCB8B019F8A5EDE8B9FE552'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'game on fitchburg'
WHERE ht.external_id = '114815' AND ht.source_system_id = 1
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
  4, '2025-09-07', '13:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '227807', '52788BA7E09E935A174D3C1D0318391E'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
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
  4, '2025-09-13', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '236815', '1E2B5AF7F0E591B0F72C53A58B63F7F2'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
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
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  6, 5,
  1, '236816', '3B15E39DD889A51976D5405453AC6947'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
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
  4, '2025-09-28', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '236819', 'E58DA523FAE9E631C439BC0974C057B3'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
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
  4, '2025-10-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  6, 2,
  1, '236820', '715C36B26452454B2BE53C54D1353DB6'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
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
  4, '2025-10-26', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '236822', '7A39A583AF20AA669A007046CFDBE728'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
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
  4, '2026-03-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '278044', '9C14BAFC1109C2351963305A302588E2'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'kristine lilly field'
WHERE ht.external_id = '135760' AND ht.source_system_id = 1
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
  4, '2026-03-22', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 6,
  1, '278046', '14B810C45C8D6C46C8EF2E792E7A3406'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
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
  4, '2026-04-01', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278055', '8ECE72B1DFAD5F27DB8E3A530C20A0E2'
FROM teams ht
JOIN teams at ON at.external_id = '114816' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'kristine lilly field'
WHERE ht.external_id = '135760' AND ht.source_system_id = 1
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
  4, '2026-04-12', '13:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278058', '371438FBC5A37085A4A1E95E8DF07B84'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
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
  4, '2026-04-19', '13:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278109', 'C778A327B3706A29F840FF7E19F1AE7A'
FROM teams ht
JOIN teams at ON at.external_id = '135760' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
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
  4, '2026-04-26', '13:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278110', '1BD25291B166A7C05FABBEA145E13D81'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'irish american home society'
WHERE ht.external_id = '114816' AND ht.source_system_id = 1
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
  4, '2025-09-13', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 7,
  1, '230061', '663E1F6C93237F3FC1EC8529BEF1C3B8'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
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
  4, '2025-09-21', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '230098', '4C0FD9EF32AE18C9819B836D90543BBB'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'woodbridge middle school - 1'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
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
  4, '2025-09-27', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '233406', 'CB07D9EF60DD8243B08414C94284FDAC'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tucker hs'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
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
  4, '2025-11-02', '17:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '237183', '9D0FC1253DE50B8B19EC9B1DC30160C9'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
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
  4, '2025-11-08', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228597', '4BFDA6EEEAB5ADE95E883981003A4B84'
FROM teams ht
JOIN teams at ON at.external_id = '114817' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk collegiate school'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
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
  4, '2025-11-15', '14:45:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '234440', '409393F85FCFEFF06CDAEA7A8D5E1D8A'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'godwin high school -'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
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
  4, '2025-11-16', '14:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '228536', 'C9974584184C519D8220376206786503'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'reynolds cc -'
WHERE ht.external_id = '114817' AND ht.source_system_id = 1
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
  4, '2025-09-14', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '227808', 'AE5CE0BDF78C68DFA6E15B62E55D6925'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
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
  4, '2025-10-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 5,
  1, '236821', '627BE5A985B4537911EF74AB336FB276'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
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
  4, '2025-10-26', '12:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '236823', 'A9C6116918672D9E1E28E8DF44A5B046'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'cfc park'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
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
  4, '2026-03-15', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '278045', '1CBC639837790CD0C0E08A4AE55B547E'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
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
  4, '2026-03-21', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '278047', 'CC00751609D8705A780788F2CEF44BDE'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'kristine lilly field'
WHERE ht.external_id = '135760' AND ht.source_system_id = 1
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
  4, '2026-03-29', '17:00:00', 3,
  ht.id, at.id, v.id,
  2, 8,
  1, '278054', 'CF65D02025DF0911B74586F57E92C9E9'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'cfc park'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
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
  4, '2026-04-16', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278059', '601DAE70BB00B67BC0A1DDBE7716B8E1'
FROM teams ht
JOIN teams at ON at.external_id = '135760' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
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
  4, '2026-05-02', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278113', '46BCF195B26C6CF2C4CCFA32B1964725'
FROM teams ht
JOIN teams at ON at.external_id = '114819' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'kristine lilly field'
WHERE ht.external_id = '135760' AND ht.source_system_id = 1
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
  4, '2026-05-10', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278114', '0C34CF20E77581BFDD881815D2E4A615'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'municipal stadium'
WHERE ht.external_id = '114819' AND ht.source_system_id = 1
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
  4, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226814', 'F063001E31F0F8A8AC17728AFED7F6FA'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  8, 1,
  1, '226825', '9466FF3A6007CF90597FEAB75BA30AC6'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  5, 1,
  1, '226827', 'AFAAE1CF6B06779BF81D1EF771AD2FBB'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2025-09-28', '12:15:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226834', '0C62CF52DDB201731D6EE7AA1BA8CAEA'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, v.id,
  4, 5,
  1, '226838', '1635ABE1B2811DF80B6D578299DBE497'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2025-10-26', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '226851', '32AB0131810040B68564AEA6A7B324C7'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2025-11-06', '20:45:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '226856', 'AB86AD780CA63B8F0BA33BDB26C540DB'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2025-11-19', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226862', 'DA048A32B83E615AA8E34C0D67585661'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '260815', '5BE9F38A99A4CF6EB87BCD0C23422B4D'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 4'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-03-22', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '260819', 'A6D144F46596EDF9422EEF4C47D6F42F'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2026-03-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '260802', '9A4A6FA3DC8DE983CCBDBC6D07FE7F28'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2026-03-28', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260825', '54AFCFC87F92BA970E5F7EB6896ACAD0'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-04-02', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '226874', '3DF4E032FFB0D22005F444353B56ECFC'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'queens college'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2026-04-12', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260833', 'FCEBFC3D9F8401B8FBA4ABE9D888F3DF'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2026-04-19', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260836', '159456D034EB7C79569DE2E02A936344'
FROM teams ht
JOIN teams at ON at.external_id = '114820' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2026-04-26', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260841', '5D8B2975984BAE232BBE83D1603ADCE1'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2026-05-10', '16:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260856', 'F636E4E5CDAABEB9DA09F69D23EE420F'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2026-05-17', '16:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260862', '64F31C31FE4343F1F9260EE8718A18F4'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'laurel hill park'
WHERE ht.external_id = '114820' AND ht.source_system_id = 1
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
  4, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228134', 'ABD621FCC3D3CD820FEECC6240903D28'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '228142', 'F1ADA4EE3C80B2AA7AD9C8B82E072334'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2025-09-21', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228144', 'EA58AD51F929144693E70401D2F8B421'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228160', '73869539098BAC385B8FBC9F969D35A6'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2025-10-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228163', '6A38120CAAA0C65D58E9CC772EA0B0DF'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
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
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '228187', '001A061F094534E68274815C8764DC4E'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
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
  4, '2025-11-23', '18:30:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '228178', '027EEC1168CEDA4C1F02047BB19B0A53'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park -'
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
  4, '2025-11-30', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
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
  4, '2025-12-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228180', '6123A8DAC8C02FFF749CB0395A0D0B54'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2026-01-11', '12:30:00', 3,
  ht.id, at.id, v.id,
  6, 0,
  1, '236282', 'A88CA462AC0E1F83D5DA84247CB868E0'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'central regional high school'
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
  4, '2026-02-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '262641', '19D20CBA66D7B4C9BD5DB98B0EF74620'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2026-03-08', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '262648', '9B63BBB3D9C5F881AC5398F62D9E644E'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2026-03-15', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '262651', 'F90A630C758CAEB4F83E7C97837D543D'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2026-03-22', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '262660', 'D907F1D603BCE1E5D7365DF6DD2C53DB'
FROM teams ht
JOIN teams at ON at.external_id = '114822' AND at.source_system_id = 1
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
  4, '2026-03-29', '18:30:00', 3,
  ht.id, at.id, v.id,
  1, 9,
  1, '262664', '81156C73F69A99993F198C582708DAEF'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park'
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
  4, '2026-04-12', '18:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262675', 'CC4DCFB4C4C636CFB3BD836FB2D96BF2'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park'
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
  4, '2026-04-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262681', '59677C18E9C63313615EE5B4D5B9ED69'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park'
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
  4, '2026-05-10', '18:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262702', '451F8B43E5A3384E5B89CA234D84C02E'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park'
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
  4, '2026-05-17', '18:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262706', 'CB4AC785128F63820369D4BF1D6E4CE4'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'veteran''s park'
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
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '236817', '5A6C59BAF6EC2C5AFF19F1A518F0841B'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
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
  4, '2025-09-28', '18:30:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '236818', 'FAD5AC55C6E0C2BA1F2A4B13660A7DC0'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
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
  4, '2026-04-04', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278056', '43D56A380675919B0067EEF780167C70'
FROM teams ht
JOIN teams at ON at.external_id = '135760' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
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
  4, '2026-04-18', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278108', 'D192702068E553C9328B21481095FC23'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
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
  4, '2026-04-29', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278112', 'F1AFBC505E10C4361A6AC42A54E42003'
FROM teams ht
JOIN teams at ON at.external_id = '114826' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'kristine lilly field'
WHERE ht.external_id = '135760' AND ht.source_system_id = 1
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
  4, '2026-05-10', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278115', 'BCB0D4727E1A23E8E825D1A97B44C639'
FROM teams ht
JOIN teams at ON at.external_id = '135760' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114826' AND ht.source_system_id = 1
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
  4, '2025-09-06', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226816', 'BA9BA551285510BC31174F7BDBCDBE2F'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '226828', '9330988FBCB2549634B0F4D3030C9E5D'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2025-10-05', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226841', 'A3B628E63145802B10C1E9E4E8C14D70'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2025-10-14', '20:30:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '226848', '32EFD5CF15E9E93088060F790345200D'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226850', '9DEC8961FB75564BEDADA4057A3BE57B'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2025-11-15', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226863', '12EAC9FE95DBB964AEC1D765EC7910F9'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2025-12-09', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '226869', 'D4E08B48861F9AF065BE1D579ECBB0AA'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'fleming park'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2026-01-11', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '226878', 'FCAC7EAD3DD0168980BABF08E17D7FDE'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2026-03-08', '12:15:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '260807', '21071CA05D7AB3068118B324A7742CA2'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2026-03-11', '20:15:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '260803', 'FFFE0CCCA6495FE588FCC5D9FECCD9CB'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-03-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '260811', '646DCDF2944384B6E51230DB2FA19D3E'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2026-03-29', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260824', '7EA817A67FB0FBDCC51F23ACCD530992'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 2'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-04-12', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260831', '15467BDAA023CFF94C27FDA8A5E3D88F'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2026-04-18', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260835', 'EC3023CD9384087B5AB4BF503A723835'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2026-04-26', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260845', '7DA5A42A5D7CB524F882357D2EAAC988'
FROM teams ht
JOIN teams at ON at.external_id = '114827' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2026-05-02', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260847', 'E4824C946BE40150122D85E8704008E5'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tibbetts brook park - field 3'
WHERE ht.external_id = '114827' AND ht.source_system_id = 1
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
  4, '2025-09-20', '19:00:00', 3,
  ht.id, at.id, v.id,
  8, 0,
  1, '233401', '8C6F8731F67B1A3FF4E322AF291CB399'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
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
  4, '2025-09-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '234452', 'E3A392ED45EC9AB8EC5A88D023C6BA3A'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114839' AND ht.source_system_id = 1
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
  4, '2025-10-04', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '234447', '9D48C3372C4A3497B292034C06B9E52E'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
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
  4, '2025-10-25', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '234437', 'D7396D14421FC74195B30FA2BED3EB2B'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114829' AND ht.source_system_id = 1
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
  4, '2025-11-08', '19:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '251157', 'DC6F8A17D511688F77A156B583A873B1'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
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
  4, '2025-11-09', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '235879', 'F43D54FC12BB73204BF4E09E05FECA7C'
FROM teams ht
JOIN teams at ON at.external_id = '114829' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
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
  4, '2025-09-14', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '226824', '0B9A43D31555C75D65439ADE2A416EB4'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 2'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2025-09-21', '12:15:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226830', 'EC34480A338FAB51ED9DD2545FC1D6AC'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2025-10-12', '20:00:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '226847', 'B066A3E1A58402E967AC5D80F96B8F15'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2025-11-02', '12:15:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226860', '0A090A7CE79AA8DEEBA4FA38CCBD3871'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2025-11-16', '12:15:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226867', '3328D6E495B9E391431AD6D7C2B528FE'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2025-11-23', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '226868', '224265D8F2AFA6DCC8AB6418A933A258'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2026-01-11', '12:15:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226877', 'C6F395E4F4DDD8FC1FEAE4E8AEC739B3'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2026-03-15', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '260812', 'DB00C653B57A8E3F6DAE361BED16FF9C'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2026-03-22', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '260817', '4D8F03D98E6CECD8BE98D52A3231FC93'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'joseph f. fosina field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  2, 4,
  1, '260826', '938E2EBF998559BCF39A9D6DFC4E194F'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2026-04-19', '12:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260837', '699BB88E3265CA9588C40EAC9E979637'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2026-04-25', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260846', 'CF732B5916F3EFB3A3DEFE013A29475F'
FROM teams ht
JOIN teams at ON at.external_id = '114830' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-05-03', '12:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260852', 'E865C98C91AEFDE8DBFFF9635E58B8DE'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2026-05-10', '12:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260858', '35DCF9C16DFE0C78138F936DA694DDC9'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'travers island'
WHERE ht.external_id = '114830' AND ht.source_system_id = 1
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
  4, '2025-09-21', '19:30:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '226829', '7C2932CF0730EA7344B36DA1CCB5C95C'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2025-09-28', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '226832', '7FB52D175E293638C828EB010310C4CD'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2025-10-23', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '226844', '69156AA75DA6103EC174431A8B6D5FD9'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2025-10-26', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226853', 'A7D131CA158D34FB062D01538E30C4FB'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2025-11-12', '21:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '226861', '5D53804FFAB9205D558740F7D4504D8E'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2025-11-23', '14:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226872', '72924B94E57FD6F0085EA2950DBD4D7A'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2026-03-19', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '260801', '4A343BFB02480957C84B950DAC852103'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2026-03-21', '19:30:00', 3,
  ht.id, at.id, v.id,
  10, 0,
  1, '260821', '0C677373B462D250EF71F5BECFE63046'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-04-12', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260829', '66A681ED2C81514F7FC2C0E79F227EBE'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2026-05-03', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260848', 'FB19AE83635ED58871F38DE0FEB24CFC'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hofstra university soccer stadium'
WHERE ht.external_id = '114831' AND ht.source_system_id = 1
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
  4, '2026-05-10', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260855', '7FD533990932A85ADD833FCA898FB2C6'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 2'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-05-17', '20:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260861', 'E4AA562CA961C89BE5D8585653045337'
FROM teams ht
JOIN teams at ON at.external_id = '114831' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'verrazano sports complex - field 1'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2025-09-07', '19:30:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '226815', 'A8D7125E275548413B97A057D20784DB'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2025-10-01', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226820', 'B35B2D0F2D604300EA0F5769A173A09E'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2025-10-05', '16:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226839', 'A3B9DB8441EFCE79D8DE2883408C3275'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '226858', '9E5E47B90D1DCFB18FF04BCF32D5EFD1'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2025-11-16', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '226864', '84AF29E584D677CA438B71ABEDBAE2E0'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2026-03-08', '14:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '260809', '035C9E25081594F17815E9346EF7DD47'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'queens college'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2026-03-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '260814', '96D8603C1D95A409854C90FD08AB87C1'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2026-03-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '260828', 'AD69D35E1E51B70DF3B8FC219C445B3E'
FROM teams ht
JOIN teams at ON at.external_id = '114832' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2026-04-26', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260842', '6B93DB9FA4E27741F237CC2F7BC142E7'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2026-05-17', '19:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260864', '0AAB384A102D31A5A10A5DB523C9DD55'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. john''s university - belson stadium'
WHERE ht.external_id = '114832' AND ht.source_system_id = 1
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
  4, '2025-09-07', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228137', 'DA7A3259024D57240B7D1D45020CF3CB'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rowan university'
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
  4, '2025-09-17', '20:30:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '236246', 'CC5D30C55A491B494FACFF1F8744F1AA'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
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
  4, '2025-09-27', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '228148', 'F1EF61CA037AE5BE8E5A462F39BA3765'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
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
  4, '2025-10-05', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '228154', '2581662AFF4EB85019BD04FBA9016D77'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
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
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228162', '267180484600D1A7414F583B668D6332'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rowan university'
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
  4, '2025-11-09', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
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
  4, '2025-11-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '228159', '93D8B7FF49071908FC59E82E9C24FFD2'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
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
  4, '2025-12-07', '19:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '228170', 'D48AD84F10808648D909233AE9D6DDC8'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
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
  4, '2026-03-01', '16:30:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '262643', 'AAB3B278495B0184C260663075E4263A'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
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
  4, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, v.id,
  7, 0,
  1, '262646', '838D26F7BB1C6F3BBC2BABFF65F8D713'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rowan university'
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
  4, '2026-03-21', '19:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '262657', 'F5B6C67C855B897B2C93C5FBEA4EC097'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
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
  4, '2026-04-08', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262671', 'A6EF7135869B9FB9BF327416D824E954'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mccarthy stadium'
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
  4, '2026-04-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262653', '5E9BCA729B0E1EBE9A5D1798F9000BB9'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'camden athletic complex'
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
  4, '2026-05-03', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262692', '380F2DD90E3152A25EB1DE4EB57E9462'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
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
  4, '2026-05-10', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262700', '612A30E34691A318BC3DFAF87646A382'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2026-05-17', '19:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262707', '0B82A46012BB63277203A16117BB2A75'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
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
  4, '2026-05-25', NULL, 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228167', 'DF6E6E479B3EACB02B94639370514965'
FROM teams ht
JOIN teams at ON at.external_id = '114833' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'upper moreland high school'
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
  4, '2025-09-27', '13:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '230094', 'BD90AA5C96CD44DD61880BC405E7AEF3'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
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
  4, '2025-10-18', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '233404', '88348644DE4F4E0D88B732C9E65C6DB4'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
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
  4, '2025-11-16', '18:30:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '234448', '25C51A11849135C94EC8203A6A09465A'
FROM teams ht
JOIN teams at ON at.external_id = '114834' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
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
  4, '2025-12-07', '17:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '229167', '9E165A7B8D85501F938BE48A6E5290F3'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '114834' AND ht.source_system_id = 1
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
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '228146', 'DF01FA60CB1E3598F4B6D6390E64EB78'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
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
  4, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228151', '083891AE6AA46D200BE51545711A8711'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2025-10-12', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '236273', '43BE527883D3B67CF5618254B4FD7626'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
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
  4, '2025-10-26', '11:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228165', '80791DD62A3E3674EDE85737564F599C'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
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
  4, '2025-11-15', '19:00:00', 3,
  ht.id, at.id, v.id,
  5, 4,
  1, '228177', '83AFC1412C8A2C48288294A46DD51F62'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
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
  4, '2025-11-23', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228183', 'B4268A7FF6843244ACEBFAF9B4BC0CCB'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'twin pines field -'
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
  4, '2025-12-10', '20:15:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228185', 'BF8F32A44166EC900FB45CBBF9C84EF6'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'united sports - field 1'
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
  4, '2026-03-01', '17:30:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '262644', 'A3454C001BBD8A91F1286EBF144DF6A7'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
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
  4, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '262655', '356014CDD2336D9CA7A1C47244F925DF'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2026-03-22', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
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
  4, '2026-03-29', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '262662', '87FC66FC7EDBF9F2BED3F7B4CABD29BD'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
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
  4, '2026-04-01', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262667', '66607878DC369847551FDB517E3237E6'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mccarthy stadium'
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
  4, '2026-04-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262683', '77DF68FB1A9DDFB8D83EC20BCC6097A5'
FROM teams ht
JOIN teams at ON at.external_id = '114835' AND at.source_system_id = 1
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
  4, '2026-05-03', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262695', 'E514AB474209AB93B00CC5AB1F032EF6'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
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
  4, '2026-05-10', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262701', 'F4CD6EEDDDF2845DF632D78836B600DC'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
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
  4, '2025-09-07', '16:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
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
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '228147', 'F6E4AF1B8C1D9E5F6BBFD86C7E18A72F'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '228152', 'BF266C341BA761EDB5F2DF0D5295D853'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
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
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228156', '7382597A5E425273E9DDF919A5CE7A00'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
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
  4, '2025-11-02', '14:30:00', 3,
  ht.id, at.id, v.id,
  0, 10,
  1, '228172', 'D1E0D6CCB931A4AF7CE477D6D71464C0'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'thornbury soccer park - field 2'
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
  4, '2025-11-20', '20:45:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '236281', 'A413A32A8765AEE19DAAFD461F5F2110'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228182', '9E9C2B9CD3132B200F81F108328F53A0'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
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
  4, '2026-03-15', '17:30:00', 3,
  ht.id, at.id, v.id,
  3, 1,
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
  4, '2026-03-22', '16:30:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '262658', '28BBE1353E83E687E001FBF2D2FB8DCA'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
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
  4, '2026-04-11', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262672', '6E1F5C5A51B0F9FFCE862548A77526A4'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
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
  4, '2026-04-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262687', '13A7C027D28CB34C6F2A022ECD39C470'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
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
  4, '2026-05-07', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262696', '00720581381BE1F97A56467BF9159335'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
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
  4, '2026-05-17', '11:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262703', '28A21D16353083D44C73A11A4908419D'
FROM teams ht
JOIN teams at ON at.external_id = '114836' AND at.source_system_id = 1
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
  4, '2026-05-24', NULL, 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262663', '92C57497442CD90E28811DDFBDFE0D14'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
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
  4, '2026-08-24', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '275439', '7886289C2C9768CF6B8A9C1A7E78A378'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'carter playground'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2025-09-06', '19:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '231088', 'BDC611D214DB0A2A378159050CD36F88'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2025-09-14', '19:00:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '242297', '7C00A6E3A6691021188BF59EFE6B449B'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2025-09-21', '13:30:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '231089', 'EE97F156541D1BAE3B0E56105651FC4E'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '231094', '1B1992CA3C46370178C3091C6A92E8CB'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ceylon park'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2025-10-05', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '245209', 'FE0ED3F9EA7FAAA2052CD1DF5B0A8FC4'
FROM teams ht
JOIN teams at ON at.external_id = '114843' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2025-11-03', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231102', '4AB87398908EC2EA108FC2B6040455EC'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
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
  4, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '258656', '3A44D23926DB17757C8DCC05A233B691'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'madison park high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2026-03-22', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '258659', '3A2247211B930D87823B579C1EA00EC8'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2026-03-29', '16:15:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '258662', 'C7A915BA155172A2D7618D306EB2D794'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'conway field'
WHERE ht.external_id = '131978' AND ht.source_system_id = 1
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
  4, '2026-04-11', NULL, 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '258667', 'D81E551C6BA9F083811A8C4A196EA7CA'
FROM teams ht
JOIN teams at ON at.external_id = '114837' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'frey park'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
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
  4, '2026-04-19', '18:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258673', '3524E565FC9B48AA67B33A2D3635BACD'
FROM teams ht
JOIN teams at ON at.external_id = '131978' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'madison park high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2026-05-03', '18:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258680', '39B9007194777338B40F98E034CEE4B9'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'madison park high school'
WHERE ht.external_id = '114837' AND ht.source_system_id = 1
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
  4, '2025-09-13', '19:30:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '242319', '84DFF02DB72DB94A60F10E12A5CA6A7A'
FROM teams ht
JOIN teams at ON at.external_id = '126357' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'east boston memorial stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2025-09-27', '18:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231093', 'DB3FB092C2A442F0BACD4C32666CA8C3'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
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
  4, '2025-10-05', '12:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '245207', 'C3C03BAB3AC817547860D47C7D2246B7'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2025-10-19', '11:30:00', 3,
  ht.id, at.id, v.id,
  0, 4,
  1, '231103', '099AD3EBCE6D4A5D9A2269594051987C'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2025-10-25', '18:15:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '231106', 'BEA1D489754219DA3546E7ED030D3724'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2025-11-09', '13:30:00', 3,
  ht.id, at.id, v.id,
  2, 7,
  1, '231100', '90FDE59CD99BEFCED90FC76543055003'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2026-03-29', '13:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '258663', '2381A73EA04DFE423269717DB8A814ED'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2026-04-12', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258666', 'B0B6815272C4C17C005F4D372ACE812C'
FROM teams ht
JOIN teams at ON at.external_id = '131978' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'english high school'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2026-04-19', NULL, 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '258670', 'F8C102E89DB0ADC5184774BEFD8C5474'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'frey park'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
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
  4, '2026-04-25', '16:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258677', '668B3518E9EB86254327B324E1D44214'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'frey park'
WHERE ht.external_id = '114838' AND ht.source_system_id = 1
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
  4, '2026-05-06', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258681', 'D7BAC79821943D9EBCF5C917E1A001B2'
FROM teams ht
JOIN teams at ON at.external_id = '114838' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '131978' AND ht.source_system_id = 1
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
  4, '2025-09-14', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 5,
  1, '234438', '1813527465404DD1707BA8FB1482233C'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'poplar tree park - 2'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
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
  4, '2025-11-02', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 10,
  1, '228534', '823A879947C1FBD0BE14C1908D0504E1'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk christian school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
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
  4, '2025-11-08', '15:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '230062', '3694DE8E6AF1EBDC939C00A7481C6E22'
FROM teams ht
JOIN teams at ON at.external_id = '114839' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
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
  2, 1,
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
  4, '2025-10-01', '21:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '236251', '3552DDFED3D7FC7B3B522A8810860154'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
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
  4, '2025-10-04', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228153', '29D34C12FAF872D10A21C0DB89BD9688'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
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
  4, '2025-11-02', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228171', '785AE6C1CA789DD6B8005780EB29EDEA'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
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
  4, '2025-12-03', '20:30:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '228186', '20741AD32BB7F3A311C9715CD9C8FC8E'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
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
  4, '2026-01-11', '11:45:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '228188', 'BEA4051C45935789E6F8D9810E59966B'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bonner high school'
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
  4, '2026-02-28', '18:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '262640', '9826D5BD7A336BFEAB1779FB4F0C5EB7'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2026-03-15', '16:30:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '262652', '9738F4F83693DE5295D9571754EFA4DE'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
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
  4, '2026-04-12', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262676', 'EAA13CF90AAB938A3075D74133DAA1E3'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
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
  4, '2026-04-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262678', 'F84FE5178AFBF87C6384E5644C1028FB'
FROM teams ht
JOIN teams at ON at.external_id = '114840' AND at.source_system_id = 1
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
  4, '2026-04-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262688', 'EB3DA36D057E39F04B710F31DBB07073'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2026-05-03', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
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
  4, '2025-10-26', '20:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '226855', 'A3B3429C6147F1EB179306FAEAD0EE3F'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2025-11-20', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '226857', 'D406FB5A544880E1B44BE16843CF2A1A'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2025-11-23', '18:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '226873', '3484EF15007ECB6A721745792E50BB87'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-01-11', '13:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '226879', 'F209BC6395C19F9EE9C2DDD8D7639C95'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2026-03-08', '20:00:00', 3,
  ht.id, at.id, v.id,
  4, 2,
  1, '260804', '657F5D1DCBD59BC0B2D5EA35CB20835B'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'owl hollow field'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2026-03-17', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '260800', '07FE61423C4CF1DFE7026A0BA649AF6C'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'verrazano sports complex - field 1'
WHERE ht.external_id = '114841' AND ht.source_system_id = 1
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
  4, '2026-04-18', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260839', '8F1B61B414124B5E9F6ABF819EDB6226'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-05-10', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260857', '146537295295E80DA08E2DCCCB4BF22F'
FROM teams ht
JOIN teams at ON at.external_id = '114841' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2025-09-07', '16:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '226819', 'A48FA6BE6ACA181B15E14023285E89A5'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2025-09-27', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '226836', '27F6C07BBA049F793F0E67A0708F1A94'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2025-10-30', '20:15:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '226849', '101419F609E5F1547D4E31B8ACC7337D'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '260805', 'FB977CA38D267930FE09A6BC635D0801'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 4'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-04-12', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260834', '81F869ADD23FFEF91377B136D6B8DCF0'
FROM teams ht
JOIN teams at ON at.external_id = '114842' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2026-05-16', '19:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260863', 'EC9644B0FFB8F995996F808859A1F97B'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'garfield high school'
WHERE ht.external_id = '114842' AND ht.source_system_id = 1
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
  4, '2026-08-24', '14:30:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '275440', '8FD063D82D36C92F7C4F8F46F2701F3A'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2025-09-14', '13:30:00', 3,
  ht.id, at.id, v.id,
  4, 3,
  1, '242310', '6AB0CA6828196883DA2DA39A468F0FFB'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2025-10-19', '13:45:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '231104', '19F40FC33FE542867D5726F20054E04A'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'harry della russo stadium'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
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
  4, '2025-10-25', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '248373', 'E418CE3C2A600DCFDC05743EBA8DAD4A'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dilboy stadium'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
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
  4, '2026-03-08', '13:30:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '258652', '6873A290C7E44A614B7EE7FF3EAD602D'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2026-03-15', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '258654', 'A50BC54B6EE8278020A3A775A84AE03D'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2026-03-22', '18:30:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '258658', '2AD19CBB17C82CD4E73D003F1177B628'
FROM teams ht
JOIN teams at ON at.external_id = '114844' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dilboy stadium'
WHERE ht.external_id = '131978' AND ht.source_system_id = 1
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
  4, '2026-05-09', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258682', 'FE2119CBDFB35DA8B01566BCC4B096EF'
FROM teams ht
JOIN teams at ON at.external_id = '131978' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'new bedford regional vocational technical hs'
WHERE ht.external_id = '114844' AND ht.source_system_id = 1
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
  4, '2025-09-21', '17:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '238667', 'F6D9C085788BC0AF675BE3A0E699B1B1'
FROM teams ht
JOIN teams at ON at.external_id = '114849' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'woodbridge middle school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
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
  4, '2025-10-25', '16:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '233356', 'A07AD205160A1A68DBA7508079EE5FD4'
FROM teams ht
JOIN teams at ON at.external_id = '114846' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '118680' AND ht.source_system_id = 1
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
  4, '2025-11-22', '15:00:00', 3,
  ht.id, at.id, v.id,
  2, 1,
  1, '234433', 'AEF84A2D85D973C1071338A46B2AC2EE'
FROM teams ht
JOIN teams at ON at.external_id = '114846' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk christian school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
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
  4, '2025-12-06', '14:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '238975', '11156EA3054A1831933AB04A9819A817'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'edison high school - 1'
WHERE ht.external_id = '114846' AND ht.source_system_id = 1
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
  4, '2025-09-07', '12:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '228135', '9181C7E343AE48EB86E526FB0ECE22FA'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
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
  4, '2025-10-12', '13:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
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
  4, '2025-10-19', '13:00:00', 3,
  ht.id, at.id, v.id,
  7, 1,
  1, '236276', 'AA2F9D39E76B7BC1E64937D0617404D9'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2025-10-22', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 7,
  1, '228166', 'D8CCE3BB57BFE15D2F725A2D96C1D301'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
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
  4, '2025-11-08', '19:00:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '228175', '472A3403E9CC2C6B7432C27E351C6B9F'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2026-03-23', '20:30:00', 3,
  ht.id, at.id, v.id,
  1, 6,
  1, '262656', '0C40945A104B700084D987036E2FBFD4'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2026-04-09', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262670', '28E7F8403B751E2EF9A27081DADDD928'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
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
  4, '2026-04-12', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262677', '866D6A86ECCA0A9098A025EC759FEF08'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2026-04-19', '18:45:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262682', '4A7D25708DF6A3FAA5AB9BBC12EEB61B'
FROM teams ht
JOIN teams at ON at.external_id = '114847' AND at.source_system_id = 1
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
  4, '2026-05-10', '15:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
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
  4, '2025-10-04', '16:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '233403', '334436516721710312580CC0124D3356'
FROM teams ht
JOIN teams at ON at.external_id = '118680' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk collegiate school - 1'
WHERE ht.external_id = '114849' AND ht.source_system_id = 1
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
  4, '2025-09-14', '11:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '228140', '9E3405AAC94D5F784B841C1DA43CD2A1'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'germantown supersite'
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
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  12, 1,
  1, '236279', '86C60F3FF8FEB726524F01A9864DACF0'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
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
  4, '2025-11-22', '19:00:00', 3,
  ht.id, at.id, v.id,
  7, 2,
  1, '228181', '306AB4224CE83E11CE03D49A1E20177F'
FROM teams ht
JOIN teams at ON at.external_id = '114850' AND at.source_system_id = 1
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
  4, '2025-12-02', '20:30:00', 3,
  ht.id, at.id, v.id,
  7, 0,
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
  4, '2026-03-11', '20:30:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '262649', '481BAB878581B8B66AFEAC4EF03BCD9D'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
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
  4, '2026-04-18', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262680', '2B16B6FEE961BD149654B504368B4ABC'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2026-05-02', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262691', '94EB77D4203352A5E52092E227E4E37B'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
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
  4, '2026-03-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '278053', '5F925157413CF90C981967FA807D655E'
FROM teams ht
JOIN teams at ON at.external_id = '135760' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
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
  4, '2026-04-11', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278057', 'CE605D42E90B7BD4645185B1FBF38302'
FROM teams ht
JOIN teams at ON at.external_id = '114851' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'kristine lilly field'
WHERE ht.external_id = '135760' AND ht.source_system_id = 1
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
  4, '2026-04-26', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '278111', 'B4D977AC8B0262AADA6235665C7219EA'
FROM teams ht
JOIN teams at ON at.external_id = '135760' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'vale forge'
WHERE ht.external_id = '114851' AND ht.source_system_id = 1
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
  4, '2025-09-14', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '226822', '59D1936104860CD61C63F5D9955876B6'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '226842', '0CE5772E534134127579A4E92FEF3420'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-03-22', '19:30:00', 3,
  ht.id, at.id, v.id,
  1, 6,
  1, '260820', '6E9FBD14D33C6D87258CF857285AD00B'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '114852' AND ht.source_system_id = 1
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
  4, '2026-03-29', '11:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '260823', '1506758D3269DC7D3309913470522260'
FROM teams ht
JOIN teams at ON at.external_id = '114852' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'randalls island - icahn stadium'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2025-09-21', '13:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '228202', 'DBB6EFE2D1790B9944CFEC7F353AD54F'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2025-10-05', '17:00:00', 3,
  ht.id, at.id, v.id,
  12, 0,
  1, '228209', '4D5B168379C9FE46F3D879555A3297EA'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2025-10-12', '11:00:00', 3,
  ht.id, at.id, v.id,
  9, 2,
  1, '228212', 'FBA5001B1A8A9850B209EBE194C66779'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228217', '45E38AF0933307B565AA319D41B6CC5F'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
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
  4, '2025-10-26', '11:00:00', 3,
  ht.id, at.id, v.id,
  2, 0,
  1, '228222', '3FFE505FC9A32F096E157C8AE5E15B8C'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2025-11-09', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 7,
  1, '228226', '255110A99F533656CE4C02B4BA7B666B'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2025-11-16', '11:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '228231', '108E1355720401D9B74DBE3257C74A87'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2025-11-23', '10:00:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '228235', '931C8B643588C3D3DA79AE8DC0B03B02'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  4, '2026-01-18', '14:30:00', 3,
  ht.id, at.id, v.id,
  1, 4,
  1, '258147', 'BC116FCD3F1C446DC3EB959DF7B90665'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2026-02-08', '10:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '258168', 'F80C9916FADFB667291A186D2AA84D4C'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2026-03-01', '15:00:00', 3,
  ht.id, at.id, v.id,
  9, 1,
  1, '258165', 'BECF6D68F024032CE8FAA16160DEA219'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mount paran christian school'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2026-03-15', '16:00:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '259286', '2DE5379CAD465F2AEEF12B499A43F23E'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2026-03-22', '15:00:00', 3,
  ht.id, at.id, v.id,
  7, 0,
  1, '259293', '1F5CC41D0E9B75D8EE01F5600471C934'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mount paran christian school'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2026-04-08', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259296', '1268D94BB874F921502A5F02BAA7C5B8'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2026-04-12', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259300', 'A2D90F4801AB8412984DBAB5D122F247'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mount paran christian school'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2026-05-10', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258150', '97AB6BFB201A3933B026633A90CDF2EC'
FROM teams ht
JOIN teams at ON at.external_id = '115101' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2026-05-17', '14:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259306', '583A8F205B5503953B3D7AA1FB92CE94'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'mount paran christian school'
WHERE ht.external_id = '115101' AND ht.source_system_id = 1
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
  4, '2025-09-28', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '226835', 'DC74FFB8A1872B295FB4D17F4E07B2D4'
FROM teams ht
JOIN teams at ON at.external_id = '115102' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'susa orlin & cohen sports complex - field 1'
WHERE ht.external_id = '115315' AND ht.source_system_id = 1
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
  4, '2026-05-03', '14:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '260849', '085EB7016C1F52883F9CCD816335E9F1'
FROM teams ht
JOIN teams at ON at.external_id = '115315' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'roosevelt island - jack mcmanus field'
WHERE ht.external_id = '115102' AND ht.source_system_id = 1
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
  4, '2025-09-28', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228207', 'A36D223E40848941F314504DA0C1A88B'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
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
  4, '2025-10-05', '13:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228211', '57A4D672C9133E03F8C773080FFF7747'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2025-10-12', '09:00:00', 3,
  ht.id, at.id, v.id,
  0, 2,
  1, '228215', '73ADC7F36215766A2F9C99803B733B4B'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2025-10-19', '12:30:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228218', 'E11DA8F2FC5E2EF9086EB49E626F299F'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2025-10-26', '10:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228221', '10ABCE155C073D999B18107D6B2EE067'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  4, '2025-11-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 1,
  1, '228224', 'FDA54793D75B6D3727849BA60BDE7233'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2025-11-23', '13:00:00', 3,
  ht.id, at.id, v.id,
  13, 0,
  1, '228233', '53CC6808E2AEAB13D9D49929F95BF840'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2026-02-08', '15:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '258170', '626D679C8FCE00802869404026272D62'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2026-02-15', '15:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '258172', '907F1273CF021D7DBE085F6089C93754'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2026-02-22', '14:30:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '258174', '5369344BCE43325F8FB79B4CC1AB6807'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2026-03-22', '15:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '259291', 'FE775D05A4BE31B2119037AFAED54342'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2026-03-29', '15:00:00', 3,
  ht.id, at.id, v.id,
  0, 1,
  1, '259295', 'FE6A10D9D2A92C731017A175D17B31BA'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2026-04-12', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259299', '027E2B04C6A293D91308FD91FC905C94'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2026-04-26', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258167', '7CD2B9AC4DEEDC3E2703DB6A2588C3AD'
FROM teams ht
JOIN teams at ON at.external_id = '115104' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2026-05-03', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259285', '55E87D98FB8A858062E60BAD75D45344'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'agnes scott college'
WHERE ht.external_id = '115104' AND ht.source_system_id = 1
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
  4, '2025-09-28', '09:00:00', 3,
  ht.id, at.id, v.id,
  1, 3,
  1, '228205', '72B567C2F93DA724B80DD9DF207E6E02'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'piedmont park'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2025-10-05', '18:00:00', 3,
  ht.id, at.id, v.id,
  6, 2,
  1, '228208', 'D42225AD424CA79CE3FB04C7265F043B'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2025-11-09', '16:00:00', 3,
  ht.id, at.id, v.id,
  14, 0,
  1, '228227', '8D7C31A9C3D1BB5D76BDE70DF86C5E9A'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2025-11-23', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228234', 'A6EA88A5DB9A984AE91CD6D1A3A8F518'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2025-12-07', '14:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '228236', '168EDEC2239AB656C115F466209EEACD'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2025-12-14', '14:00:00', 3,
  ht.id, at.id, v.id,
  5, 3,
  1, '228213', '47BA2114636FE9A734932015577C4CD9'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2026-02-08', '10:00:00', 3,
  ht.id, at.id, v.id,
  2, 2,
  1, '258169', '59320CE86D38A1F8249297589ED86507'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  4, '2026-02-15', '10:00:00', 3,
  ht.id, at.id, v.id,
  2, 3,
  1, '258164', '203E33BD9662CE972544AE02E2487C75'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'atlanta international school'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2026-04-09', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259294', 'FB6670922A38513FFCE798025AA54D2F'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  NULL, NULL,
  1, '258149', 'F25C3F4DC06E48E1AE796C99EA0AFFBC'
FROM teams ht
JOIN teams at ON at.external_id = '115105' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2026-04-30', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259301', '9D34CA01CD2886D79F243589F87EA148'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2026-05-17', '14:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259305', '327382A31DE41EB9F0435A5F798D9669'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2025-12-27', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259287', '4E34DEB0B772D79247C77C3ED861A8B3'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ebster field'
WHERE ht.external_id = '115105' AND ht.source_system_id = 1
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
  4, '2025-09-28', '10:00:00', 3,
  ht.id, at.id, v.id,
  1, 1,
  1, '228206', 'C1AFB0BD1C27BAD4980970A5564E3B35'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  4, '2025-10-19', '14:00:00', 3,
  ht.id, at.id, v.id,
  8, 0,
  1, '228219', 'FBB4691B7675C8D9AB275F8AA343F384'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2025-11-09', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228225', '1809DFC5D9A0FD773EB752AC0EE71707'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2025-11-16', '14:30:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '228228', '3C1267B7502753ACA2A5210303D9341E'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2025-11-23', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 4,
  1, '228232', 'AC66D2DFF2E05D8017A86416EA90241D'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2026-02-08', '15:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '258171', '16AAF2748DDD62FA7E8DEA9541953F95'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2026-02-22', '12:00:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '258175', '56B5F91D7CA6CF5B6F3ABC45D59DE19A'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2026-03-01', '14:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '259283', 'C7522F59860306FA8BC7CA5C3B6B32D8'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2026-04-12', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259298', '37E1167B9E209923B99F97145105AB03'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2026-05-03', '09:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258146', '75231503A0C3B09D1D5713555B7D3374'
FROM teams ht
JOIN teams at ON at.external_id = '115106' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2026-05-10', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258151', '760A023A03590E797E0E06195DE1617B'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115106' AND ht.source_system_id = 1
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
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  3, 6,
  1, '228201', '621C17125F15AF8E19BB54DAFB65383C'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2025-09-28', '15:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '228204', '1F84F8FBAB39E37704B498B882062983'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2025-10-19', '18:00:00', 3,
  ht.id, at.id, v.id,
  2, 4,
  1, '228216', '7E6BA178C97CFA82FFDC90A09624E4E6'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2025-10-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228220', '3EAFA57EEEB0C15655D411826C71F941'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
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
  4, '2026-02-22', '09:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '258176', '0EB3F1D59AA031A90F370BF61965E008'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2026-03-15', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '259290', '35B94529CA7911424580251DA1303A05'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2026-03-22', '10:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '259292', 'DE6ACB913069ADB234AE27D61EE8D874'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  4, '2026-04-12', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259297', 'C6B5467F0B9BEFCBF672CA0ABA419245'
FROM teams ht
JOIN teams at ON at.external_id = '115107' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2026-05-17', '18:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259304', 'A1E51941DE1C551D1EA15E5DDDF7CBE3'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'empower college & career center'
WHERE ht.external_id = '115107' AND ht.source_system_id = 1
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
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228203', '8677CB98B90F4A033F0368705D5781E6'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bay creek park'
WHERE ht.external_id = '115103' AND ht.source_system_id = 1
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
  4, '2025-10-05', '09:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '228210', 'F0F0E6B9F2B0672CC2D0BAC6FCDA3ECB'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2025-11-16', '10:00:00', 3,
  ht.id, at.id, v.id,
  18, 0,
  1, '228230', 'FBF380E6768E06CF13D5A637BF5B068C'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  4, '2026-01-18', '12:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '258980', 'CAC3DCE16A47BD63A44322694D664E27'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'hammond park'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2026-02-15', '10:00:00', 3,
  ht.id, at.id, v.id,
  3, 3,
  1, '258166', '2D67E94C3C600514D32EE07D56475553'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  4, '2026-03-01', '09:00:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '259284', '8E7CD948C4BE6D0A205A9E1E9C097220'
FROM teams ht
JOIN teams at ON at.external_id = '115108' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2026-03-15', '10:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '259289', '7A414822AD8DF89094E14B71A13BFB1A'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'maynard h jackson high school'
WHERE ht.external_id = '115108' AND ht.source_system_id = 1
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
  1, 5,
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
  4, '2025-09-21', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 2,
  1, '236250', 'F8B2C0A6EC70FE30BC40A928E433C4B9'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
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
  4, '2025-10-11', '19:00:00', 3,
  ht.id, at.id, v.id,
  1, 0,
  1, '228161', 'B05D0D03AA786AB07812FC24E46F614A'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
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
  4, '2026-03-07', '19:00:00', 3,
  ht.id, at.id, v.id,
  5, 1,
  1, '262645', 'F6E5C740FE66960E33ADD4BB2935D705'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
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
  4, '2026-05-10', '18:45:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262699', '42C0BBCDE65361B5F1E3F6A63EB52513'
FROM teams ht
JOIN teams at ON at.external_id = '115227' AND at.source_system_id = 1
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
  4, '2025-10-26', '17:00:00', 3,
  ht.id, at.id, v.id,
  7, 0,
  1, '228223', 'BA3971A682CE4B27380DA76A8F9D6C69'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2025-11-16', '09:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228229', '8EE0D2FA2236461B617AF2DDA53BC2BD'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2026-01-04', '10:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '258046', '4F7C4CC0B6BACA1C351034A5DBA74FFD'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'brook run park'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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
  4, '2026-05-17', '09:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259303', '63346D904AAF9B2E3DCDDD4B700BD2EC'
FROM teams ht
JOIN teams at ON at.external_id = '115815' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2025-12-27', '10:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258148', '684D61F508F150248E538B86A94F3D48'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '115815' AND ht.source_system_id = 1
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

INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id, event_url_hash
)
SELECT 
  4, '2025-10-05', '11:00:00', 3,
  ht.id, at.id, v.id,
  3, 2,
  1, '236270', '12068B68423574D5DB51B131E9B7F186'
FROM teams ht
JOIN teams at ON at.external_id = '124946' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'northeast high school'
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
  4, '2026-04-08', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '262669', 'E66C8D886B881510AF359FD60C66E10D'
FROM teams ht
JOIN teams at ON at.external_id = '116136' AND at.source_system_id = 1
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
  4, '2025-09-07', '15:30:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '231087', 'EC16385A0F70DE3D9A6DD74A9B397A92'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
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
  4, '2025-09-24', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231092', 'C7F818EAEE8A81CA4AE7EBFC4EB597A5'
FROM teams ht
JOIN teams at ON at.external_id = '114843' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'east boston memorial stadium'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2026-04-01', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258653', '7BDED28087535561FDFB466CE5EB8837'
FROM teams ht
JOIN teams at ON at.external_id = '118063' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'medford high school'
WHERE ht.external_id = '131978' AND ht.source_system_id = 1
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
  4, '2026-04-04', '17:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '258664', '2E6ED1F583EB0485458BC3A339A31E43'
FROM teams ht
JOIN teams at ON at.external_id = '131978' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2026-04-26', '13:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '258676', 'BB2F19ED3F0C4CA84C931491DBE955A0'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'pine banks park'
WHERE ht.external_id = '118063' AND ht.source_system_id = 1
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
  4, '2025-10-11', '18:15:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '231099', 'DB7EB728F7A79843A3402F94B0B6AB26'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'burlington high school'
WHERE ht.external_id = '114843' AND ht.source_system_id = 1
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
  4, '2026-04-08', '20:00:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '258665', '7F99068F1EB141836FB55E033BC9B231'
FROM teams ht
JOIN teams at ON at.external_id = '118064' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '131978' AND ht.source_system_id = 1
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
  4, '2026-05-03', NULL, 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '258678', '45315B309115C53739E3B23324E78944'
FROM teams ht
JOIN teams at ON at.external_id = '131978' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'frey park'
WHERE ht.external_id = '118064' AND ht.source_system_id = 1
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
  4, '2025-10-12', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '228214', '60B88BC788640BD8DB2AD49A626AA05C'
FROM teams ht
JOIN teams at ON at.external_id = '115103' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jm tull gwinnett family ymca'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2026-03-08', '12:00:00', 3,
  ht.id, at.id, v.id,
  1, 8,
  1, '259288', '642770C3FE143C32505BA4C77CCBB678'
FROM teams ht
JOIN teams at ON at.external_id = '133651' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'providence christian academy'
WHERE ht.external_id = '119159' AND ht.source_system_id = 1
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
  4, '2026-05-10', '09:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '259302', '513911DA1A8F774F11A0D949E5EBCD8E'
FROM teams ht
JOIN teams at ON at.external_id = '119159' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'the best academy'
WHERE ht.external_id = '133651' AND ht.source_system_id = 1
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
  4, '2026-04-11', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277840', '1AD54FFD3EEE59943FDDA1E687DB20B1'
FROM teams ht
JOIN teams at ON at.external_id = '136127' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '143012' AND ht.source_system_id = 1
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
  4, '2026-04-18', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277843', '4EE211FD6378E152442568FFBB13213F'
FROM teams ht
JOIN teams at ON at.external_id = '140359' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '136127' AND ht.source_system_id = 1
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
  4, '2026-04-25', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '280374', '69D18DF1141469B6EB5D03E7CAF5AC09'
FROM teams ht
JOIN teams at ON at.external_id = '136127' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'liberty sports park -'
WHERE ht.external_id = '140760' AND ht.source_system_id = 1
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
  4, '2026-05-02', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277849', 'EDFFC6EACA197BA5AE596CDECB47AFED'
FROM teams ht
JOIN teams at ON at.external_id = '144871' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ridge road recreational park - ridge road'
WHERE ht.external_id = '136127' AND ht.source_system_id = 1
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
  4, '2026-05-09', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277852', '31E59E62454AFA604121F4D543880172'
FROM teams ht
JOIN teams at ON at.external_id = '140784' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ridge road recreational park - ridge road'
WHERE ht.external_id = '136127' AND ht.source_system_id = 1
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
  4, '2026-05-16', '19:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277857', '4E486146169467A7343E2F8166F01EF4'
FROM teams ht
JOIN teams at ON at.external_id = '140730' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ridge road recreational park - ridge road'
WHERE ht.external_id = '136127' AND ht.source_system_id = 1
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
  4, '2026-05-30', '19:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277858', 'D53030B4C68713E35633A24B693BCFBF'
FROM teams ht
JOIN teams at ON at.external_id = '140728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'ridge road recreational park - ridge road'
WHERE ht.external_id = '136127' AND ht.source_system_id = 1
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
  4, '2026-03-15', '20:00:00', 3,
  ht.id, at.id, v.id,
  10, 0,
  1, '271747', 'F4AF3BDB132DBE780994D40C7FCBAA15'
FROM teams ht
JOIN teams at ON at.external_id = '136241' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'willow springs middle school'
WHERE ht.external_id = '136242' AND ht.source_system_id = 1
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
  4, '2026-03-22', '14:00:00', 3,
  ht.id, at.id, v.id,
  5, 0,
  1, '271748', 'A0B32EDF7B15096F8BBEDD566FC03A5D'
FROM teams ht
JOIN teams at ON at.external_id = '136243' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bishop lynch high school'
WHERE ht.external_id = '136241' AND ht.source_system_id = 1
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
  4, '2026-03-29', '14:00:00', 3,
  ht.id, at.id, v.id,
  5, 2,
  1, '271752', '047B48254525891B73A3B8D99D0FA035'
FROM teams ht
JOIN teams at ON at.external_id = '137416' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jerry r. walker stadium'
WHERE ht.external_id = '136241' AND ht.source_system_id = 1
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
  4, '2026-04-12', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271754', '55EADE319BB2C0823C2F08ACD2E2B508'
FROM teams ht
JOIN teams at ON at.external_id = '136241' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '142766' AND ht.source_system_id = 1
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
  4, '2026-04-17', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271755', '7E5C41C2C36B1E8AB72D7FF71F6FE7B4'
FROM teams ht
JOIN teams at ON at.external_id = '136242' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'bishop lynch high school'
WHERE ht.external_id = '136241' AND ht.source_system_id = 1
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
  4, '2026-04-26', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271941', '3B7C5AE198AA48F380F4CF67D2F918D0'
FROM teams ht
JOIN teams at ON at.external_id = '142766' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'jerry r. walker stadium'
WHERE ht.external_id = '136241' AND ht.source_system_id = 1
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
  4, '2026-05-03', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271943', '47D53AD273DDBAFB4F1D8D14320DD1E2'
FROM teams ht
JOIN teams at ON at.external_id = '136241' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'scarbourough-handley field'
WHERE ht.external_id = '136243' AND ht.source_system_id = 1
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
  4, '2026-05-10', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271946', '6797C06AB19382673AAD403DAF9CF631'
FROM teams ht
JOIN teams at ON at.external_id = '136241' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'coppell middle school'
WHERE ht.external_id = '137416' AND ht.source_system_id = 1
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
  4, '2026-03-08', '18:00:00', 3,
  ht.id, at.id, v.id,
  1, 6,
  1, '271737', '3242A6D142CC56FE325D36E43AE0A6F7'
FROM teams ht
JOIN teams at ON at.external_id = '136242' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'coppell middle school'
WHERE ht.external_id = '137416' AND ht.source_system_id = 1
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
  4, '2026-03-21', '17:00:00', 3,
  ht.id, at.id, v.id,
  0, 0,
  1, '271749', '6EC8CB32B0EE7DC4F37FFE0CDB2072DA'
FROM teams ht
JOIN teams at ON at.external_id = '142766' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'willow springs middle school'
WHERE ht.external_id = '136242' AND ht.source_system_id = 1
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
  4, '2026-03-29', '17:00:00', 3,
  ht.id, at.id, v.id,
  0, 5,
  1, '271751', '6445235BD81F1AEFD9608BAA56136758'
FROM teams ht
JOIN teams at ON at.external_id = '136242' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'gateway park synthetic fields - field 3'
WHERE ht.external_id = '136243' AND ht.source_system_id = 1
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
  4, '2026-04-18', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271939', '011AAE0804B3735FCC4B7A609AFD0B9B'
FROM teams ht
JOIN teams at ON at.external_id = '137416' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'willow springs middle school'
WHERE ht.external_id = '136242' AND ht.source_system_id = 1
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
  4, '2026-05-03', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271944', 'CCF869725DE3E1CB21DFF610B6CE3511'
FROM teams ht
JOIN teams at ON at.external_id = '136242' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '142766' AND ht.source_system_id = 1
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
  4, '2026-05-09', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271945', '0F603256631FC27417E02DDC006974D6'
FROM teams ht
JOIN teams at ON at.external_id = '136243' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'willow springs middle school'
WHERE ht.external_id = '136242' AND ht.source_system_id = 1
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
  4, '2026-03-08', '17:15:00', 3,
  ht.id, at.id, v.id,
  12, 2,
  1, '271736', '5355B9AD8361D6159CDBB8582B1EE65B'
FROM teams ht
JOIN teams at ON at.external_id = '136243' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'summit high school'
WHERE ht.external_id = '142766' AND ht.source_system_id = 1
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
  4, '2026-04-12', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271753', 'A430A4DFDA2678F23CE23CEB4887CBA5'
FROM teams ht
JOIN teams at ON at.external_id = '137416' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'scarbourough-handley field'
WHERE ht.external_id = '136243' AND ht.source_system_id = 1
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
  4, '2026-04-19', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271940', '415A3AE2AB03D27D3A0C489AF2ACFE09'
FROM teams ht
JOIN teams at ON at.external_id = '142766' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'scarbourough-handley field'
WHERE ht.external_id = '136243' AND ht.source_system_id = 1
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
  4, '2026-04-26', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '271942', 'DA474511089D77072921E8731F8A87BC'
FROM teams ht
JOIN teams at ON at.external_id = '136243' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'coppell middle school'
WHERE ht.external_id = '137416' AND ht.source_system_id = 1
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
  5, 3,
  1, '271746', '216EDCF1024CA6D0D8A5F98957C534B1'
FROM teams ht
JOIN teams at ON at.external_id = '137416' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'rolling hills soccer complex - field 15'
WHERE ht.external_id = '142766' AND ht.source_system_id = 1
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
  4, '2026-03-25', '20:30:00', 3,
  ht.id, at.id, v.id,
  6, 1,
  1, '271750', '2B1C591E934C8C4541EA3D3F1D485E48'
FROM teams ht
JOIN teams at ON at.external_id = '142766' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'lowell h. strike middle school'
WHERE ht.external_id = '137416' AND ht.source_system_id = 1
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
  4, '2026-04-04', '17:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '282208', 'AD98C9F22B1B20DE37E990BABEFF51EE'
FROM teams ht
JOIN teams at ON at.external_id = '141493' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford kettering high school'
WHERE ht.external_id = '137726' AND ht.source_system_id = 1
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
  4, '2026-04-11', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290901', '78F066EF8D52278B07379A63480BE62F'
FROM teams ht
JOIN teams at ON at.external_id = '137726' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'canton high velocity'
WHERE ht.external_id = '143291' AND ht.source_system_id = 1
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
  4, '2026-04-15', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290906', '86EF487CF864A9EFAC02575CA2EC1209'
FROM teams ht
JOIN teams at ON at.external_id = '143309' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'schoolcraft soccer field'
WHERE ht.external_id = '137726' AND ht.source_system_id = 1
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
  4, '2026-04-18', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290912', 'D98155FC055DEBDC60E7058508A968E3'
FROM teams ht
JOIN teams at ON at.external_id = '137729' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'schoolcraft soccer field'
WHERE ht.external_id = '137726' AND ht.source_system_id = 1
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
  4, '2026-04-24', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290916', '707A20C313B09A1CB539820A584EF4D9'
FROM teams ht
JOIN teams at ON at.external_id = '137726' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'wisner stadium'
WHERE ht.external_id = '141264' AND ht.source_system_id = 1
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
  4, '2026-04-29', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290921', '8525A20A34E78ED119679214872AA7E7'
FROM teams ht
JOIN teams at ON at.external_id = '137727' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'schoolcraft soccer field'
WHERE ht.external_id = '137726' AND ht.source_system_id = 1
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
  4, '2026-05-03', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291184', 'E9AF0D65308A3479A0A1B0237C978FE9'
FROM teams ht
JOIN teams at ON at.external_id = '137726' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'yntema park'
WHERE ht.external_id = '137728' AND ht.source_system_id = 1
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
  4, '2026-05-09', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291189', 'B5A8EFEC5F729DAC235ACD4DE453779D'
FROM teams ht
JOIN teams at ON at.external_id = '143114' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'schoolcraft soccer field'
WHERE ht.external_id = '137726' AND ht.source_system_id = 1
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
  4, '2026-05-17', '18:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291196', 'DBE8ADC838EC186DB42212DB63B0F184'
FROM teams ht
JOIN teams at ON at.external_id = '137726' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dibrova ukrainian association'
WHERE ht.external_id = '140960' AND ht.source_system_id = 1
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
  4, '2026-04-04', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '282207', 'E374FA46322F0A64D1CBCFD8BC7699CE'
FROM teams ht
JOIN teams at ON at.external_id = '137727' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford kettering high school'
WHERE ht.external_id = '143291' AND ht.source_system_id = 1
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
  4, '2026-04-11', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290900', '31A7AA274E626FF6CC0FC475A5814F73'
FROM teams ht
JOIN teams at ON at.external_id = '137728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'evolution sportsplex'
WHERE ht.external_id = '137727' AND ht.source_system_id = 1
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
  4, '2026-04-15', '21:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290904', 'F0C47A94C712A8F7F4AFEE2BD75D8597'
FROM teams ht
JOIN teams at ON at.external_id = '137727' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'oakland university - grizz dome'
WHERE ht.external_id = '137729' AND ht.source_system_id = 1
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
  4, '2026-04-18', '21:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290909', '1121B8DC5A345AC95CC0718E2AEFBCAA'
FROM teams ht
JOIN teams at ON at.external_id = '141493' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'evolution sportsplex'
WHERE ht.external_id = '137727' AND ht.source_system_id = 1
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
  4, '2026-04-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290915', '406D62A74E2F42BAE494B9253632A257'
FROM teams ht
JOIN teams at ON at.external_id = '137727' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford mott high school'
WHERE ht.external_id = '143114' AND ht.source_system_id = 1
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
  4, '2026-05-02', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291183', '5DB0C05EF586351BC1AF4453BD1C0120'
FROM teams ht
JOIN teams at ON at.external_id = '140960' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'evolution sportsplex'
WHERE ht.external_id = '137727' AND ht.source_system_id = 1
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
  4, '2026-05-09', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291191', '92EC27E6D1E4D7B0988AB831BC595D28'
FROM teams ht
JOIN teams at ON at.external_id = '137727' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'wisner stadium'
WHERE ht.external_id = '141264' AND ht.source_system_id = 1
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
  4, '2026-05-17', '21:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291194', 'B2E346C1F914B4727699AD4EB516987C'
FROM teams ht
JOIN teams at ON at.external_id = '143309' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'evolution sportsplex'
WHERE ht.external_id = '137727' AND ht.source_system_id = 1
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
  4, '2026-04-04', '13:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '282206', '84A890A2DB9F69547EC5D46F0F22DC69'
FROM teams ht
JOIN teams at ON at.external_id = '143309' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford kettering high school'
WHERE ht.external_id = '137728' AND ht.source_system_id = 1
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
  4, '2026-04-15', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290908', '142DA7EABAFA8AC2E9B80AADFAF7AEA3'
FROM teams ht
JOIN teams at ON at.external_id = '137728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dibrova ukrainian association'
WHERE ht.external_id = '140960' AND ht.source_system_id = 1
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
  4, '2026-04-19', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290913', '0B660F341820DD5B7368169FDD0D0CBA'
FROM teams ht
JOIN teams at ON at.external_id = '143114' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'yntema park'
WHERE ht.external_id = '137728' AND ht.source_system_id = 1
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
  4, '2026-04-26', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290919', '0DBB7D239685334072F4B17287EFE146'
FROM teams ht
JOIN teams at ON at.external_id = '137728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'oakland university - grizz dome'
WHERE ht.external_id = '137729' AND ht.source_system_id = 1
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
  4, '2026-04-29', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290923', '7795BCFD2250B446B0E01DFABA5E97EE'
FROM teams ht
JOIN teams at ON at.external_id = '143291' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'yntema park'
WHERE ht.external_id = '137728' AND ht.source_system_id = 1
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
  4, '2026-05-10', '14:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291190', 'D06047409FD5E5E281DB5A56E6C07197'
FROM teams ht
JOIN teams at ON at.external_id = '141493' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'yntema park'
WHERE ht.external_id = '137728' AND ht.source_system_id = 1
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
  4, '2026-05-16', '19:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291198', '939EFDF65B0FD97ECF4E79FC9B04AB1B'
FROM teams ht
JOIN teams at ON at.external_id = '137728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'wisner stadium'
WHERE ht.external_id = '141264' AND ht.source_system_id = 1
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
  4, '2026-04-04', '09:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '282204', 'AC5C8B613A538ED249B49400BBAA621A'
FROM teams ht
JOIN teams at ON at.external_id = '137729' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford kettering high school'
WHERE ht.external_id = '140960' AND ht.source_system_id = 1
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
  NULL, NULL,
  1, '290902', '9BB62C9677D4BC41EB1C60D710D98E23'
FROM teams ht
JOIN teams at ON at.external_id = '137729' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'munson park'
WHERE ht.external_id = '141493' AND ht.source_system_id = 1
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
  4, '2026-04-29', '21:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290924', '6FBFA73CB22AF41F1F87C1608EF0A2BD'
FROM teams ht
JOIN teams at ON at.external_id = '141264' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'oakland university - grizz dome'
WHERE ht.external_id = '137729' AND ht.source_system_id = 1
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
  4, '2026-05-03', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291186', '4AA04C1C93CE194BD9D4F6FBCE7FF2CC'
FROM teams ht
JOIN teams at ON at.external_id = '143309' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'greenmead historical park'
WHERE ht.external_id = '137729' AND ht.source_system_id = 1
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
  4, '2026-05-10', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291192', '9CCF7786D27A4FB38FDD5E595AFA3C23'
FROM teams ht
JOIN teams at ON at.external_id = '137729' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'canton high velocity'
WHERE ht.external_id = '143291' AND ht.source_system_id = 1
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
  4, '2026-05-17', '18:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291197', 'A8BE2C9010C99B2EE1F956C308EE93BD'
FROM teams ht
JOIN teams at ON at.external_id = '137729' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford mott high school'
WHERE ht.external_id = '143114' AND ht.source_system_id = 1
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
  4, '2026-03-29', '20:15:00', 3,
  ht.id, at.id, v.id,
  4, 0,
  1, '286499', '503AAF90365090B4BC8F5CA20229E549'
FROM teams ht
JOIN teams at ON at.external_id = '140256' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '140766' AND ht.source_system_id = 1
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
  4, '2026-04-11', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '286506', '3ADB9C5E2DA30E88A20F8EE08452372D'
FROM teams ht
JOIN teams at ON at.external_id = '140256' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westfield high school - 1'
WHERE ht.external_id = '140753' AND ht.source_system_id = 1
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
  4, '2026-04-19', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '293029', 'D96E28E9D3C240D777C9F8B954F47F70'
FROM teams ht
JOIN teams at ON at.external_id = '140256' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '140777' AND ht.source_system_id = 1
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
  4, '2026-04-25', '20:10:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287638', '02AE540A28628D9BAC9C4C3E577171AA'
FROM teams ht
JOIN teams at ON at.external_id = '140256' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'woodson hs rf#1 west turf'
WHERE ht.external_id = '140777' AND ht.source_system_id = 1
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
  4, '2026-05-02', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287642', '2A8B4292C2481FF08B06D1813F18F97D'
FROM teams ht
JOIN teams at ON at.external_id = '140256' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'varina high school'
WHERE ht.external_id = '140739' AND ht.source_system_id = 1
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
  4, '2026-05-10', '15:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287301', '01201F64E2358BC93B15779489490081'
FROM teams ht
JOIN teams at ON at.external_id = '140256' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140779' AND ht.source_system_id = 1
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
  4, '2026-04-11', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277838', '53CF3841131C46D84844A723F55CC7B6'
FROM teams ht
JOIN teams at ON at.external_id = '140784' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140359' AND ht.source_system_id = 1
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
  4, '2026-04-18', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277843', '4EE211FD6378E152442568FFBB13213F'
FROM teams ht
JOIN teams at ON at.external_id = '136127' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140359' AND ht.source_system_id = 1
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
  4, '2026-04-25', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277847', 'CC9F34BDD37BC4B48F44EDAD265A06AE'
FROM teams ht
JOIN teams at ON at.external_id = '140359' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140728' AND ht.source_system_id = 1
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
  4, '2026-05-02', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277850', 'E3EF8496204CBC4CC6827AF45CB50A40'
FROM teams ht
JOIN teams at ON at.external_id = '140359' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140760' AND ht.source_system_id = 1
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
  4, '2026-05-09', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277853', 'EA58B1A097B4ABE47C52E927C6DFD187'
FROM teams ht
JOIN teams at ON at.external_id = '140359' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '140730' AND ht.source_system_id = 1
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
  4, '2026-05-16', '12:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277856', 'C6828D12974FAAAB830F38121CCE3204'
FROM teams ht
JOIN teams at ON at.external_id = '143012' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140359' AND ht.source_system_id = 1
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
  4, '2026-05-30', '12:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277860', 'AD62EAC54291E75F1EC6988D52B4F631'
FROM teams ht
JOIN teams at ON at.external_id = '144871' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140359' AND ht.source_system_id = 1
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
  4, '2026-04-11', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277839', 'D5FC073378B8648993328F35DCFCAD0B'
FROM teams ht
JOIN teams at ON at.external_id = '140728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140760' AND ht.source_system_id = 1
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
  4, '2026-04-18', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277845', '3E136869DEB0C6C8D57967DCDF66C331'
FROM teams ht
JOIN teams at ON at.external_id = '140728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '141305' AND ht.source_system_id = 1
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
  4, '2026-05-02', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277842', 'D34F5B06E42ECED32F08E2A4FEA6C3E6'
FROM teams ht
JOIN teams at ON at.external_id = '140730' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '140728' AND ht.source_system_id = 1
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
  4, '2026-05-09', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '286502', '0077E904B5AFB5DE39521F63D833A211'
FROM teams ht
JOIN teams at ON at.external_id = '143012' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140728' AND ht.source_system_id = 1
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
  4, '2026-06-06', '13:30:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '276878', 'EC0D307C033C1C7342B6155A0C27630C'
FROM teams ht
JOIN teams at ON at.external_id = '140728' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'utz field - 1'
WHERE ht.external_id = '140784' AND ht.source_system_id = 1
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
  4, '2026-03-29', '15:00:00', 3,
  ht.id, at.id, v.id,
  4, 1,
  1, '277706', '7CBFAE5B75991C2BF3061E72FF477FBD'
FROM teams ht
JOIN teams at ON at.external_id = '140760' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '140730' AND ht.source_system_id = 1
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
  4, '2026-04-11', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277841', 'E3C5155DFC602EEFD1EB01BD977FD791'
FROM teams ht
JOIN teams at ON at.external_id = '140730' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '144871' AND ht.source_system_id = 1
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
  4, '2026-04-18', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '286500', '4DB792BC17509234CFE5A075B107A01B'
FROM teams ht
JOIN teams at ON at.external_id = '143012' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '140730' AND ht.source_system_id = 1
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
  4, '2026-04-25', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277846', '1DC07168CFFE02765FD75F36776DDC2E'
FROM teams ht
JOIN teams at ON at.external_id = '140784' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'seaford high school - seaford hs'
WHERE ht.external_id = '140730' AND ht.source_system_id = 1
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
  4, '2026-03-28', '17:30:00', 3,
  ht.id, at.id, v.id,
  0, 3,
  1, '280555', '2E3AA291B06D0F32DF3A1816D8E10EBB'
FROM teams ht
JOIN teams at ON at.external_id = '140739' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'norfolk collegiate school'
WHERE ht.external_id = '140779' AND ht.source_system_id = 1
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
  4, '2026-04-11', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '293024', '0B50DD1F1B3DE526E588B97614740FE1'
FROM teams ht
JOIN teams at ON at.external_id = '140766' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140739' AND ht.source_system_id = 1
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
  4, '2026-04-18', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287300', '4317AAE275BECFDBC52339D915CFF691'
FROM teams ht
JOIN teams at ON at.external_id = '140739' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westfield high school - 1'
WHERE ht.external_id = '140753' AND ht.source_system_id = 1
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
  4, '2026-04-25', '16:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '286505', '8654306D9319986D9F60091E5151AB65'
FROM teams ht
JOIN teams at ON at.external_id = '140779' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'monacan high school - 1'
WHERE ht.external_id = '140739' AND ht.source_system_id = 1
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
  4, '2026-03-28', '20:00:00', 3,
  ht.id, at.id, v.id,
  3, 0,
  1, '280553', '32A53BADC931907BFE0D80E1F4D187B6'
FROM teams ht
JOIN teams at ON at.external_id = '140777' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westfield high school - 1'
WHERE ht.external_id = '140753' AND ht.source_system_id = 1
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
  4, '2026-04-25', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287637', '88EA8C06C8ED9D309577FBA46C602494'
FROM teams ht
JOIN teams at ON at.external_id = '140753' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'westfield high school - 1'
WHERE ht.external_id = '140766' AND ht.source_system_id = 1
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
  4, '2026-05-02', '19:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287639', '647CED3D223ACBF9CB72AB7314A33BB5'
FROM teams ht
JOIN teams at ON at.external_id = '140779' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140753' AND ht.source_system_id = 1
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
  4, '2026-04-18', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277844', 'FD2AA4250E2DC1C26FB93FCDD9284D57'
FROM teams ht
JOIN teams at ON at.external_id = '140784' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140760' AND ht.source_system_id = 1
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
  4, '2026-05-09', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277848', '28B29A7D0589F03F56A2BECEBFE3A306'
FROM teams ht
JOIN teams at ON at.external_id = '144871' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140760' AND ht.source_system_id = 1
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
  4, '2026-05-30', '12:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277859', '4E7C9ED87714BFC72C6187C3FBE7D74E'
FROM teams ht
JOIN teams at ON at.external_id = '143012' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140760' AND ht.source_system_id = 1
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
  4, '2026-04-18', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287299', 'A48509992F073AE02561CC24421D57CA'
FROM teams ht
JOIN teams at ON at.external_id = '140766' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140779' AND ht.source_system_id = 1
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
  4, '2026-05-03', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287641', 'F353A475F8B8432F3F35FC1AFF310049'
FROM teams ht
JOIN teams at ON at.external_id = '140777' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'patriot park - 1'
WHERE ht.external_id = '140766' AND ht.source_system_id = 1
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
  4, '2026-04-12', '19:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '287298', 'DC97A595D4C1B69BB819004A8434FE85'
FROM teams ht
JOIN teams at ON at.external_id = '140779' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140777' AND ht.source_system_id = 1
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
  4, '2026-03-28', '13:30:00', 3,
  ht.id, at.id, v.id,
  5, 4,
  1, '286451', '677ADCFC47505BCBD24DCC1B3F571117'
FROM teams ht
JOIN teams at ON at.external_id = '143012' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'utz field - 1'
WHERE ht.external_id = '140784' AND ht.source_system_id = 1
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
  4, '2026-05-02', NULL, 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277851', 'C776A9B003CE167D4F41894CFE6DFEB0'
FROM teams ht
JOIN teams at ON at.external_id = 'null' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '140784' AND ht.source_system_id = 1
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
  4, '2026-05-16', '12:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277855', '4F15D483FA8E840CC0C6B8F71A171450'
FROM teams ht
JOIN teams at ON at.external_id = '140784' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '144871' AND ht.source_system_id = 1
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
  NULL, NULL,
  1, '290903', 'E6E90F37C923A4009E1B92BE46BD2F8D'
FROM teams ht
JOIN teams at ON at.external_id = '141264' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dibrova ukrainian association'
WHERE ht.external_id = '140960' AND ht.source_system_id = 1
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
  4, '2026-04-19', '15:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290910', 'AC974EFC3BD422D4A446094122FBDA40'
FROM teams ht
JOIN teams at ON at.external_id = '140960' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'canton high velocity'
WHERE ht.external_id = '143291' AND ht.source_system_id = 1
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
  4, '2026-04-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290917', 'CA3E8676599CAF04F91B94C7F6071183'
FROM teams ht
JOIN teams at ON at.external_id = '140960' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'munson park'
WHERE ht.external_id = '141493' AND ht.source_system_id = 1
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
  4, '2026-04-29', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290922', '3E01793444FF83BBB12208A2207121B2'
FROM teams ht
JOIN teams at ON at.external_id = '143114' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'dibrova ukrainian association'
WHERE ht.external_id = '140960' AND ht.source_system_id = 1
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
  4, '2026-05-09', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291188', '276252447C1DDFF828219B5289310E0F'
FROM teams ht
JOIN teams at ON at.external_id = '140960' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. paul albanian field'
WHERE ht.external_id = '143309' AND ht.source_system_id = 1
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
  4, '2026-04-04', '11:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '282205', 'AC3A8F809BCF9483031BA306E8A031FC'
FROM teams ht
JOIN teams at ON at.external_id = '141264' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford kettering high school'
WHERE ht.external_id = '143114' AND ht.source_system_id = 1
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
  4, '2026-04-18', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290911', '8866EE6C632231B9C76422D3E11C5EAE'
FROM teams ht
JOIN teams at ON at.external_id = '141264' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. paul albanian field'
WHERE ht.external_id = '143309' AND ht.source_system_id = 1
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
  4, '2026-05-03', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291185', '947ECFBDB79129D3196667F3395C221E'
FROM teams ht
JOIN teams at ON at.external_id = '141264' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'munson park'
WHERE ht.external_id = '141493' AND ht.source_system_id = 1
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
  4, '2026-05-20', '20:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290907', '0DB7879D45BEAAB95244DED10B3DF9C4'
FROM teams ht
JOIN teams at ON at.external_id = '143291' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '141264' AND ht.source_system_id = 1
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
  4, '2026-04-15', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290905', '940D8AE50CF380C9B1C06EC0B8394EF6'
FROM teams ht
JOIN teams at ON at.external_id = '141493' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford mott high school'
WHERE ht.external_id = '143114' AND ht.source_system_id = 1
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
  4, '2026-04-28', '20:30:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290920', '6F2ED4ADB0EBAB4281961A50A9A73B44'
FROM teams ht
JOIN teams at ON at.external_id = '141493' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. paul albanian field'
WHERE ht.external_id = '143309' AND ht.source_system_id = 1
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
  4, '2026-05-17', '18:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291195', '887BC1A9C16EA58F269C666661AB23C7'
FROM teams ht
JOIN teams at ON at.external_id = '143291' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'munson park'
WHERE ht.external_id = '141493' AND ht.source_system_id = 1
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
  4, '2026-04-25', '12:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '286501', '570891DFE1B92E469860162C707EF354'
FROM teams ht
JOIN teams at ON at.external_id = '143012' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '144871' AND ht.source_system_id = 1
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
  4, '2026-05-16', '12:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277856', 'C6828D12974FAAAB830F38121CCE3204'
FROM teams ht
JOIN teams at ON at.external_id = '140359' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '143012' AND ht.source_system_id = 1
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
  4, '2026-05-06', '20:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291187', 'B01E16A2246EC68DA526EFF5F4827F74'
FROM teams ht
JOIN teams at ON at.external_id = '143291' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'waterford mott high school'
WHERE ht.external_id = '143114' AND ht.source_system_id = 1
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
  4, '2026-05-13', '20:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '291193', '63BB279008981ACC5761FA8B746DCFBD'
FROM teams ht
JOIN teams at ON at.external_id = '143114' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'st. paul albanian field'
WHERE ht.external_id = '143309' AND ht.source_system_id = 1
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
  4, '2026-04-26', '18:00:00', 3,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '290918', '7A869AD3FF2A82770AD45103366DCCE2'
FROM teams ht
JOIN teams at ON at.external_id = '143309' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'canton high velocity'
WHERE ht.external_id = '143291' AND ht.source_system_id = 1
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
  4, '2026-05-30', '12:00:00', 1,
  ht.id, at.id, v.id,
  NULL, NULL,
  1, '277860', 'AD62EAC54291E75F1EC6988D52B4F631'
FROM teams ht
JOIN teams at ON at.external_id = '140359' AND at.source_system_id = 1
LEFT JOIN venues v ON v.name = 'tbd'
WHERE ht.external_id = '144871' AND ht.source_system_id = 1
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  match_status_id = EXCLUDED.match_status_id,
  home_score = COALESCE(EXCLUDED.home_score, matches.home_score),
  away_score = COALESCE(EXCLUDED.away_score, matches.away_score),
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = COALESCE(EXCLUDED.venue_id, matches.venue_id),
  event_url_hash = COALESCE(EXCLUDED.event_url_hash, matches.event_url_hash);

