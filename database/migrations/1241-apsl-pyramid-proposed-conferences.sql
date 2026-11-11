-- 1241 (2026-11-11) — #apsl-pyramid map: proposed borders for every
-- conference, and proposed NEW conferences filling the rest of the country.
--
-- Owner 2026-11-11: "for map draw a line where you propose borders for all
-- conferences and judge proposed new ones with names in the rest of country
-- based on what we have now" / "in other words fill the map" / "these new
-- proposed confs should be maps only" / "and we should be able to toggle
-- that feature".
--
-- What we have now (mig 852): a conference's ground = the counties whose
-- nearest APSL club is within 100 km.  The eight live conferences hold
-- 4.8 M (Constitution) … 17.2 M (Metropolitan) people that way, median
-- 8.6 M.  So a NEW conference is judged the same way: the people within
-- 100 km of its anchor cities, against the smallest live conference:
--   ready       ≥ the smallest live conference's ground (Constitution)
--   borderline  ≥ 75 % of it
--   developing  less — a metro to watch; no region of its own, it falls
--               inside its neighbours' borders until it grows
-- The tier is computed (fh_pyramid_proposal_refresh), never typed in.
-- Anchors were picked by a greedy scan of the open ground (2026-11-11): the
-- open county with the most people within 100 km, then the next at least
-- 220 km away, … — named here by their metros.
--
-- Borders: every lower-48 county belongs to the region of its nearest point
-- — an APSL club's ground (live conference) or an anchor county's centre
-- (proposed, not developing).  Lines are drawn where two counties of
-- different regions meet (shared county edges), precomputed into
-- pyramid_proposal_borders so the page gets lines, not 2 MB of counties.
-- Rerun fh_pyramid_proposal_refresh() after grounds or anchors change.

CREATE TABLE IF NOT EXISTS pyramid_proposed_conferences (
    id          serial PRIMARY KEY,
    code        text NOT NULL UNIQUE,
    name        text NOT NULL,
    note        text,                       -- the judgement in words (map HUD)
    developing  boolean NOT NULL DEFAULT false,   -- set by the refresh: below the borderline bar
    tier        text,                       -- ready / borderline / developing (refresh)
    core_population bigint,                 -- people within 100 km of its anchors (refresh)
    sort_order  integer NOT NULL DEFAULT 0
);
COMMENT ON TABLE pyramid_proposed_conferences IS
    'mig 1241: proposed APSL conferences for the open ground — #apsl-pyramid map only, behind a ☰ switch. Tier/core_population computed by fh_pyramid_proposal_refresh().';

CREATE TABLE IF NOT EXISTS pyramid_proposed_anchors (
    proposed_id integer NOT NULL REFERENCES pyramid_proposed_conferences(id) ON DELETE CASCADE,
    fips        char(5) NOT NULL REFERENCES pyramid_counties(fips),
    label       text NOT NULL,              -- the metro, as the map writes it
    PRIMARY KEY (proposed_id, fips)
);

CREATE TABLE IF NOT EXISTS pyramid_proposal_counties (
    fips          char(5) PRIMARY KEY REFERENCES pyramid_counties(fips) ON DELETE CASCADE,
    conference_id integer REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    proposed_id   integer REFERENCES pyramid_proposed_conferences(id) ON DELETE CASCADE,
    km            double precision,
    CHECK ((conference_id IS NULL) <> (proposed_id IS NULL))
);

CREATE TABLE IF NOT EXISTS pyramid_proposal_borders (
    id       serial PRIMARY KEY,
    region_a text NOT NULL,     -- 'c<conference id>' / 'p<proposed id>'
    region_b text NOT NULL,
    line     jsonb NOT NULL     -- [[lat, lon], …]
);

INSERT INTO pyramid_proposed_conferences (code, name, note, sort_order) VALUES
  ('pacific',     'Pacific Conference',     'Los Angeles and Orange County — the biggest open metro, the size of Delaware River.', 10),
  ('lakeshore',   'Lakeshore Conference',   'Chicagoland — a ready-made conference on its own.', 20),
  ('golden_gate', 'Golden Gate Conference', 'San Francisco, the East Bay and San Jose.', 30),
  ('gulf_coast',  'Gulf Coast Conference',  'Greater Houston — about the median live conference.', 40),
  ('sunshine',    'Sunshine Conference',    'Tampa Bay and Orlando along I-4.', 50),
  ('biscayne',    'Biscayne Conference',    'Miami, Fort Lauderdale and the Palm Beaches — over four hours from Tampa, so its own.', 60),
  ('steel',       'Steel Conference',       'Pittsburgh and Cleveland–Akron–Youngstown, about two hours apart.', 70),
  ('alamo',       'Alamo Conference',       'Austin and San Antonio up I-35, south of Trinity.', 80),
  ('buckeye',     'Buckeye Conference',     'Columbus, Dayton and Cincinnati.', 90),
  ('cascadia',    'Cascadia Conference',    'Seattle–Tacoma, with Portland three hours down I-5.', 100),
  ('piedmont',    'Piedmont Conference',    'Charlotte, the Triad and the Triangle.', 110),
  ('sonoran',     'Sonoran Conference',     'Greater Phoenix — just under the smallest live conference.', 120),
  ('front_range', 'Front Range Conference', 'Denver to Colorado Springs.', 130),
  ('north_star',  'North Star Conference',  'Minneapolis–Saint Paul.', 140),
  ('gateway',     'Gateway Conference',     'St. Louis and Kansas City, ~4 h apart (Mid-Atlantic''s longest trip is 4 h).', 150),
  ('tidewater',   'Tidewater Conference',      'Richmond and Hampton Roads.', 200),
  ('music_city',  'Music City Conference',     'Nashville.', 210),
  ('wasatch',     'Wasatch Conference',        'Salt Lake City.', 220),
  ('erie_canal',  'Erie Canal Conference',     'Buffalo and Rochester.', 230),
  ('bayou',       'Bayou Conference',          'New Orleans and Baton Rouge.', 240),
  ('red_dirt',    'Red Dirt Conference',       'Oklahoma City and Tulsa.', 250),
  ('mojave',      'Mojave Conference',         'Las Vegas.', 260)
ON CONFLICT (code) DO NOTHING;

INSERT INTO pyramid_proposed_anchors (proposed_id, fips, label)
SELECT p.id, v.fips, v.label
  FROM (VALUES
    ('pacific','06037','Los Angeles'), ('pacific','06059','Orange County'),
    ('lakeshore','17031','Chicago'),
    ('golden_gate','06075','San Francisco'), ('golden_gate','06001','Oakland'), ('golden_gate','06085','San Jose'),
    ('gulf_coast','48201','Houston'),
    ('sunshine','12057','Tampa'), ('sunshine','12095','Orlando'),
    ('biscayne','12086','Miami'), ('biscayne','12011','Fort Lauderdale'),
    ('steel','42003','Pittsburgh'), ('steel','39035','Cleveland'),
    ('alamo','48453','Austin'), ('alamo','48029','San Antonio'),
    ('buckeye','39049','Columbus'), ('buckeye','39113','Dayton'), ('buckeye','39061','Cincinnati'),
    ('cascadia','53033','Seattle'), ('cascadia','41051','Portland'),
    ('piedmont','37119','Charlotte'), ('piedmont','37081','Greensboro'), ('piedmont','37183','Raleigh'),
    ('sonoran','04013','Phoenix'),
    ('front_range','08031','Denver'),
    ('north_star','27053','Minneapolis'),
    ('gateway','29510','St. Louis'), ('gateway','29189','St. Louis County'), ('gateway','29095','Kansas City'),
    ('tidewater','51760','Richmond'), ('tidewater','51810','Virginia Beach'),
    ('music_city','47037','Nashville'),
    ('wasatch','49035','Salt Lake City'),
    ('erie_canal','36029','Buffalo'), ('erie_canal','36055','Rochester'),
    ('bayou','22071','New Orleans'), ('bayou','22033','Baton Rouge'),
    ('red_dirt','40109','Oklahoma City'), ('red_dirt','40143','Tulsa'),
    ('mojave','32003','Las Vegas')
  ) AS v(code, fips, label)
  JOIN pyramid_proposed_conferences p ON p.code = v.code
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_pyramid_proposal_refresh() RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    bar bigint;
BEGIN
    -- The bar: the smallest live conference's ground (mig 852 rule).
    SELECT min(pop) INTO bar FROM (
        SELECT sum(k.population) AS pop
          FROM pyramid_county_conference cc JOIN pyramid_counties k ON k.fips = cc.fips
         WHERE cc.conference_id IS NOT NULL
         GROUP BY cc.conference_id) s;

    -- Each proposal's core: people within 100 km (policy reach) of an anchor.
    UPDATE pyramid_proposed_conferences p
       SET core_population = s.pop,
           tier = CASE WHEN s.pop >= bar THEN 'ready' WHEN s.pop >= bar * 0.75 THEN 'borderline' ELSE 'developing' END,
           developing = s.pop < bar * 0.75
      FROM (SELECT p2.id, sum(k.population) AS pop
              FROM pyramid_proposed_conferences p2
              JOIN pyramid_counties k ON EXISTS (
                     SELECT 1 FROM pyramid_proposed_anchors a JOIN pyramid_counties ak ON ak.fips = a.fips
                      WHERE a.proposed_id = p2.id
                        AND fh_km(k.lat, k.lon, ak.lat, ak.lon) <= (SELECT reach_km FROM pyramid_territory_policy LIMIT 1))
             GROUP BY p2.id) s
     WHERE s.id = p.id;

    -- Every lower-48 county → its nearest point: a live conference's APSL
    -- ground, or a non-developing proposal's anchor.
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (fips, conference_id, proposed_id, km)
    SELECT k.fips, n.conference_id, n.proposed_id, n.km
      FROM pyramid_counties k
      CROSS JOIN LATERAL (
            SELECT pt.conference_id, pt.proposed_id, fh_km(k.lat, k.lon, pt.lat, pt.lon) AS km
              FROM (SELECT tc.conference_id, NULL::int AS proposed_id, tc.lat, tc.lon FROM pyramid_team_conference tc
                    UNION ALL
                    SELECT NULL, a.proposed_id, ak.lat, ak.lon
                      FROM pyramid_proposed_anchors a
                      JOIN pyramid_proposed_conferences p ON p.id = a.proposed_id AND NOT p.developing
                      JOIN pyramid_counties ak ON ak.fips = a.fips) pt
             ORDER BY fh_km(k.lat, k.lon, pt.lat, pt.lon)
             LIMIT 1) n
     WHERE k.state NOT IN ('AK', 'HI', 'PR');

    -- Border lines: county ring edges shared by two counties of different
    -- regions, drawn once (from the side whose region key sorts first),
    -- consecutive edges of a ring joined into one line.
    DELETE FROM pyramid_proposal_borders;
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line)
    WITH reg AS (
        SELECT fips, COALESCE('c' || conference_id, 'p' || proposed_id) AS r FROM pyramid_proposal_counties
    ), polys AS (
        SELECT k.fips, p.ord AS pord, p.poly
          FROM pyramid_counties k
          JOIN reg USING (fips)
          CROSS JOIN LATERAL jsonb_array_elements(
                CASE k.geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(k.geometry->'coordinates')
                                         WHEN 'MultiPolygon' THEN k.geometry->'coordinates' ELSE '[]'::jsonb END)
                WITH ORDINALITY p(poly, ord)
    ), rings AS (
        SELECT fips, pord * 10000 + r.ord AS ring, r.ring AS pts
          FROM polys CROSS JOIN LATERAL jsonb_array_elements(poly) WITH ORDINALITY r(ring, ord)
    ), pts AS (
        SELECT fips, ring, q.i,
               round((q.pt->>1)::numeric, 4) AS lat, round((q.pt->>0)::numeric, 4) AS lon
          FROM rings CROSS JOIN LATERAL jsonb_array_elements(pts) WITH ORDINALITY q(pt, i)
    ), seg AS (
        SELECT fips, ring, i, lat, lon,
               lead(lat) OVER w AS lat2, lead(lon) OVER w AS lon2
          FROM pts WINDOW w AS (PARTITION BY fips, ring ORDER BY i)
    ), keyed AS (
        SELECT s.*, CASE WHEN (lat, lon) < (lat2, lon2) THEN lat || ',' || lon || '|' || lat2 || ',' || lon2
                         ELSE lat2 || ',' || lon2 || '|' || lat || ',' || lon END AS k
          FROM seg s WHERE lat2 IS NOT NULL AND (lat, lon) <> (lat2, lon2)
    ), owners AS (
        SELECT k, min(fips) AS f1, max(fips) AS f2 FROM keyed GROUP BY k HAVING count(DISTINCT fips) = 2
    ), border AS (
        SELECT ky.fips, ky.ring, ky.i, ky.lat, ky.lon, ky.lat2, ky.lon2, ra.r AS ra, rb.r AS rb
          FROM keyed ky
          JOIN owners o ON o.k = ky.k
          JOIN reg ra ON ra.fips = ky.fips
          JOIN reg rb ON rb.fips = CASE WHEN o.f1 = ky.fips THEN o.f2 ELSE o.f1 END
         WHERE ra.r < rb.r
    ), runs AS (
        SELECT b.*, i - row_number() OVER (PARTITION BY fips, ring, rb ORDER BY i) AS grp FROM border b
    )
    SELECT ra, rb,
           jsonb_build_array(jsonb_build_array(min(lat) FILTER (WHERE i = first_i), min(lon) FILTER (WHERE i = first_i)))
             || jsonb_agg(jsonb_build_array(lat2, lon2) ORDER BY i)
      FROM (SELECT r.*, min(i) OVER (PARTITION BY fips, ring, rb, grp) AS first_i FROM runs r) x
     GROUP BY fips, ring, rb, ra, grp;
END $$;

COMMENT ON FUNCTION fh_pyramid_proposal_refresh() IS
    'mig 1241: recompute proposed conference tiers, the county → region fill, and the border lines (#apsl-pyramid map).';

SELECT fh_pyramid_proposal_refresh();

-- Words on the page (public, mig 870).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('feature_proposal', 'APSL pyramid — menu: proposed borders + conferences', 'Proposed borders + new conferences', 199),
    ('proposal_hud',     'APSL pyramid — map panel title: the proposal',       'Proposed conferences', 300),
    ('proposal_intro',   'APSL pyramid — map panel intro',
       'A Football Home proposal, not APSL''s. Every county goes to its nearest APSL ground or proposed city. A new conference is judged by the people within 100 km of its cities, against the smallest live conference ({bar}).', 301),
    ('proposal_live',    'APSL pyramid — map panel: live conferences heading', 'Live conferences (proposed borders)', 302),
    ('proposal_new',     'APSL pyramid — map panel: new conferences heading',  'Proposed new conferences', 303),
    ('proposal_watch',   'APSL pyramid — map panel: watch-list heading',       'Watch list — not big enough yet', 304),
    ('tier_ready',       'APSL pyramid — proposal tier: ready',                'Ready', 305),
    ('tier_borderline',  'APSL pyramid — proposal tier: borderline',           'Borderline', 306),
    ('tier_developing',  'APSL pyramid — proposal tier: developing',           'Watch', 307),
    ('proposal_pop',     'APSL pyramid — proposal: population line',           '{core} within 100 km · {region} inside the border', 308)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

-- (names carry no tier — the tier is computed and shown beside the name)
UPDATE pyramid_proposed_conferences SET name = replace(name, ' (watch)', ' Conference') WHERE name LIKE '% (watch)';
