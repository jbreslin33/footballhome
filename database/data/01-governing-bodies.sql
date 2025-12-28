-- Governing Bodies Hierarchy
-- Organized by scope level: Global -> Continental -> National -> Regional -> State
-- Source: FIFA, USSF, USASA, Wikipedia

-- ============================================================================
-- GLOBAL LEVEL (Scope ID = 1)
-- ============================================================================
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_code, state_code, description, is_active)
VALUES
  (1, 1, 'Fédération Internationale de Football Association', 'FIFA', 'https://www.fifa.com', NULL, NULL, 'International governing body of association football with 211 member associations', true)
ON CONFLICT (name) DO UPDATE SET
  scope_id = EXCLUDED.scope_id,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;

-- ============================================================================
-- CONTINENTAL LEVEL (Scope ID = 2)
-- FIFA's 6 Confederations
-- ============================================================================
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_code, state_code, description, is_active)
VALUES
  (10, 2, 'Confederation of North, Central America and Caribbean Association Football', 'CONCACAF', 'https://www.concacaf.com', NULL, NULL, '41 member associations from North America, Central America, and the Caribbean', true),
  (11, 2, 'Union of European Football Associations', 'UEFA', 'https://www.uefa.com', NULL, NULL, '55 member associations from Europe', true),
  (12, 2, 'Asian Football Confederation', 'AFC', 'https://www.the-afc.com', NULL, NULL, '47 member associations from Asia and Australia', true),
  (13, 2, 'Confederation of African Football', 'CAF', 'https://www.cafonline.com', NULL, NULL, '54 member associations from Africa', true),
  (14, 2, 'South American Football Confederation', 'CONMEBOL', 'https://www.conmebol.com', NULL, NULL, '10 member associations from South America', true),
  (15, 2, 'Oceania Football Confederation', 'OFC', 'https://www.oceaniafootball.com', NULL, NULL, '11 member associations from Oceania', true)
ON CONFLICT (name) DO UPDATE SET
  scope_id = EXCLUDED.scope_id,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;

-- ============================================================================
-- NATIONAL LEVEL (Scope ID = 3)
-- National Federations - Currently adding USA, can expand later
-- ============================================================================
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_code, state_code, description, is_active)
VALUES
  (100, 3, 'United States Soccer Federation', 'USSF', 'https://www.ussoccer.com', 'USA', NULL, 'National governing body for soccer in the United States, recognized by the USOC. Organized into Youth Council, Adult Council, Professional Council, and Athletes Advisory Council', true)
ON CONFLICT (name) DO UPDATE SET
  scope_id = EXCLUDED.scope_id,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  country_code = EXCLUDED.country_code,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;

-- ============================================================================
-- REGIONAL LEVEL (Scope ID = 4)
-- Secondary national bodies under USSF
-- USASA is the ONLY member of the USSF Adult Council
-- ============================================================================
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_code, state_code, description, is_active)
VALUES
  (200, 4, 'United States Adult Soccer Association', 'USASA', 'https://www.usadultsoccer.com', 'USA', NULL, 'The only member of USSF Adult Council. Governs adult amateur soccer with 54 state associations, 220,000+ players, and multi-state leagues including APSL', true),
  (201, 4, 'US Club Soccer', 'USCS', 'https://www.usclubsoccer.org', 'USA', NULL, 'National association for youth soccer clubs, affiliate member of USASA', true),
  (202, 4, 'United States Youth Soccer Association', 'USYSA', 'https://www.usyouthsoccer.org', 'USA', NULL, 'Member of USSF Youth Council, 3 million players nationwide', true),
  (203, 4, 'American Youth Soccer Organization', 'AYSO', 'https://www.ayso.org', 'USA', NULL, 'Member of USSF Youth Council, affiliate member of USASA', true)
ON CONFLICT (name) DO UPDATE SET
  scope_id = EXCLUDED.scope_id,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  country_code = EXCLUDED.country_code,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;

-- ============================================================================
-- STATE LEVEL (Scope ID = 5)
-- USASA is divided into 4 regions comprising 54 state associations
-- Pennsylvania has split associations: EPSA (Eastern) and WPSA (Western)
-- ============================================================================
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_code, state_code, description, is_active)
VALUES
  (300, 5, 'Eastern Pennsylvania Soccer Association', 'EPSA', 'https://www.epsasoccer.com', 'USA', 'PA', 'State governing body for soccer in Eastern Pennsylvania, member of USASA', true),
  (301, 5, 'Western Pennsylvania Soccer Association', 'WPSA', 'https://www.wpasoccer.org', 'USA', 'PA', 'State governing body for soccer in Western Pennsylvania, member of USASA', true)
ON CONFLICT (name) DO UPDATE SET
  scope_id = EXCLUDED.scope_id,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  country_code = EXCLUDED.country_code,
  state_code = EXCLUDED.state_code,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;

-- ============================================================================
-- HIERARCHY RELATIONSHIPS
-- Maps parent-child relationships between governing bodies
-- ============================================================================
INSERT INTO governing_body_relationships (parent_body_id, child_body_id, relationship_type)
VALUES
  -- GLOBAL -> CONTINENTAL
  (1, 10, 'member_confederation'), -- FIFA -> CONCACAF
  (1, 11, 'member_confederation'), -- FIFA -> UEFA
  (1, 12, 'member_confederation'), -- FIFA -> AFC
  (1, 13, 'member_confederation'), -- FIFA -> CAF
  (1, 14, 'member_confederation'), -- FIFA -> CONMEBOL
  (1, 15, 'member_confederation'), -- FIFA -> OFC
  
  -- CONTINENTAL -> NATIONAL
  (10, 100, 'member_association'), -- CONCACAF -> USSF
  
  -- NATIONAL -> REGIONAL
  (100, 200, 'member_council'), -- USSF -> USASA (Adult Council)
  (100, 201, 'affiliate_member'), -- USSF -> US Club Soccer
  (100, 202, 'member_council'), -- USSF -> USYSA (Youth Council)
  (100, 203, 'member_council'), -- USSF -> AYSO (Youth Council)
  
  -- REGIONAL -> STATE
  (200, 300, 'state_association'), -- USASA -> EPSA
  (200, 301, 'state_association') -- USASA -> WPSA
ON CONFLICT (parent_body_id, child_body_id) DO NOTHING;

