-- Division Relationships (Promotion/Relegation between leagues and divisions)
-- This defines how teams can move between divisions, including cross-league movements

-- CASA Liga 1 to APSL Premier promotions
-- Central New Jersey teams can promote to either Delaware River or Metropolitan based on geography

-- Central New Jersey CASA Liga 1 -> APSL Delaware River Premier (southern teams)
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    casa_div.id as from_division_id,
    apsl_div.id as to_division_id,
    'promotion',
    'southern_central_nj_teams',
    1,
    false,
    '2024/25',
    'Central New Jersey CASA Liga 1 teams promote to APSL Delaware River Premier (southern teams)'
FROM league_divisions casa_div
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
JOIN league_divisions apsl_div ON apsl_div.slug = 'premier'
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
WHERE casa_league.name = 'CASA' 
  AND casa_conf.slug = 'central-new-jersey' 
  AND casa_div.slug = 'liga-1'
  AND apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'delaware-river'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = casa_div.id 
      AND dr.to_division_id = apsl_div.id 
      AND dr.relationship_type = 'promotion'
);

-- Central New Jersey CASA Liga 1 -> APSL Metropolitan Premier (northern teams)
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    casa_div.id as from_division_id,
    apsl_div.id as to_division_id,
    'promotion',
    'northern_central_nj_teams',
    1,
    false,
    '2024/25',
    'Central New Jersey CASA Liga 1 teams promote to APSL Metropolitan Premier (northern teams)'
FROM league_divisions casa_div
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
JOIN league_divisions apsl_div ON apsl_div.slug = 'premier'
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
WHERE casa_league.name = 'CASA' 
  AND casa_conf.slug = 'central-new-jersey' 
  AND casa_div.slug = 'liga-1'
  AND apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'metropolitan'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = casa_div.id 
      AND dr.to_division_id = apsl_div.id 
      AND dr.relationship_type = 'promotion'
);

-- Philadelphia CASA Liga 1 -> APSL Delaware River Premier
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    casa_div.id as from_division_id,
    apsl_div.id as to_division_id,
    'promotion',
    'philadelphia_area_teams',
    1,
    false,
    '2024/25',
    'Philadelphia CASA Liga 1 teams promote to APSL Delaware River Premier'
FROM league_divisions casa_div
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
JOIN league_divisions apsl_div ON apsl_div.slug = 'premier'
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
WHERE casa_league.name = 'CASA' 
  AND casa_conf.slug = 'philadelphia' 
  AND casa_div.slug = 'liga-1'
  AND apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'delaware-river'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = casa_div.id 
      AND dr.to_division_id = apsl_div.id 
      AND dr.relationship_type = 'promotion'
);

-- Lancaster CASA Liga 1 -> APSL Delaware River Premier
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    casa_div.id as from_division_id,
    apsl_div.id as to_division_id,
    'promotion',
    'lancaster_area_teams',
    1,
    false,
    '2024/25',
    'Lancaster CASA Liga 1 teams promote to APSL Delaware River Premier'
FROM league_divisions casa_div
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
JOIN league_divisions apsl_div ON apsl_div.slug = 'premier'
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
WHERE casa_league.name = 'CASA' 
  AND casa_conf.slug = 'lancaster' 
  AND casa_div.slug = 'liga-1'
  AND apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'delaware-river'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = casa_div.id 
      AND dr.to_division_id = apsl_div.id 
      AND dr.relationship_type = 'promotion'
);

-- REVERSE RELATIONSHIPS: APSL relegations back to CASA
-- APSL Delaware River Premier -> Philadelphia CASA Liga 1 (relegation)
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    apsl_div.id as from_division_id,
    casa_div.id as to_division_id,
    'relegation',
    'philadelphia_area_teams',
    1,
    false,
    '2024/25',
    'APSL Delaware River Premier teams relegate to Philadelphia CASA Liga 1'
FROM league_divisions apsl_div
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
JOIN league_divisions casa_div ON casa_div.slug = 'liga-1'
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
WHERE apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'delaware-river'
  AND apsl_div.slug = 'premier'
  AND casa_league.name = 'CASA' 
  AND casa_conf.slug = 'philadelphia'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = apsl_div.id 
      AND dr.to_division_id = casa_div.id 
      AND dr.relationship_type = 'relegation'
);

-- APSL Delaware River Premier -> Central New Jersey CASA Liga 1 (relegation - southern teams)
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    apsl_div.id as from_division_id,
    casa_div.id as to_division_id,
    'relegation',
    'southern_central_nj_teams',
    1,
    false,
    '2024/25',
    'APSL Delaware River Premier teams relegate to Central New Jersey CASA Liga 1 (southern teams)'
FROM league_divisions apsl_div
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
JOIN league_divisions casa_div ON casa_div.slug = 'liga-1'
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
WHERE apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'delaware-river'
  AND apsl_div.slug = 'premier'
  AND casa_league.name = 'CASA' 
  AND casa_conf.slug = 'central-new-jersey'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = apsl_div.id 
      AND dr.to_division_id = casa_div.id 
      AND dr.relationship_type = 'relegation'
);

-- APSL Metropolitan Premier -> Central New Jersey CASA Liga 1 (relegation - northern teams)
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    apsl_div.id as from_division_id,
    casa_div.id as to_division_id,
    'relegation',
    'northern_central_nj_teams',
    1,
    false,
    '2024/25',
    'APSL Metropolitan Premier teams relegate to Central New Jersey CASA Liga 1 (northern teams)'
FROM league_divisions apsl_div
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
JOIN league_divisions casa_div ON casa_div.slug = 'liga-1'
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
WHERE apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'metropolitan'
  AND apsl_div.slug = 'premier'
  AND casa_league.name = 'CASA' 
  AND casa_conf.slug = 'central-new-jersey'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = apsl_div.id 
      AND dr.to_division_id = casa_div.id 
      AND dr.relationship_type = 'relegation'
);

-- APSL Delaware River Premier -> Lancaster CASA Liga 1 (relegation)
INSERT INTO division_relationships (from_division_id, to_division_id, relationship_type, geographic_condition, priority_order, is_automatic, season, description)
SELECT 
    apsl_div.id as from_division_id,
    casa_div.id as to_division_id,
    'relegation',
    'lancaster_area_teams',
    1,
    false,
    '2024/25',
    'APSL Delaware River Premier teams relegate to Lancaster CASA Liga 1'
FROM league_divisions apsl_div
JOIN league_conferences apsl_conf ON apsl_div.conference_id = apsl_conf.id
JOIN leagues apsl_league ON apsl_conf.league_id = apsl_league.id
JOIN league_divisions casa_div ON casa_div.slug = 'liga-1'
JOIN league_conferences casa_conf ON casa_div.conference_id = casa_conf.id
JOIN leagues casa_league ON casa_conf.league_id = casa_league.id
WHERE apsl_league.name = 'APSL' 
  AND apsl_conf.slug = 'delaware-river'
  AND apsl_div.slug = 'premier'
  AND casa_league.name = 'CASA' 
  AND casa_conf.slug = 'lancaster'
AND NOT EXISTS (
    SELECT 1 FROM division_relationships dr 
    WHERE dr.from_division_id = apsl_div.id 
      AND dr.to_division_id = casa_div.id 
      AND dr.relationship_type = 'relegation'
);