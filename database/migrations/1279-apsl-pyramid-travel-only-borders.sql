-- 1279 (2026-11-11) — #apsl-pyramid: borders by travel only, fair to every
-- club; the rules that make conferences, in order, in ☰.
--
-- Owner 2026-11-11: "it needs to be fair to teams as this is highly
-- competitive league" / "adding a team into 'conf' geo area makes it more
-- difficult for the other teams. so its political lol" / "each team in
-- border areas needs a real distance reason to be there. travel reason" /
-- "philly and ny are a reality that they are 2 sep confs. so that reality
-- means their border trumps all other reasons. same with any similar
-- situations country wide" / "then in menu show hierarchy of rules to make
-- conferences".
--
-- * The tail balancer (mig 1272) moved border counties to a farther city to
--   shorten a conference's longest trip — a non-travel reason.  Retired:
--   pins dropped, scripts/pyramid-balance.py deleted.  A conference that is
--   too long gets split (a new city), never a bent border.
-- * Clubs: pyramid_team_nearest_conference (the flow chart's split-table /
--   outlier lines) now goes by drive minutes from the club's ground × the
--   city's traffic factor (pyramid_venue_drive_times, filled by
--   scripts/pyramid-county-drive.py), not straight km.
-- * pyramid_conference_rules: the rules, ranked — ☰ shows them in order.
-- Pipeline: scripts/pyramid-county-drive.py → SELECT fh_pyramid_proposal_refresh()
-- → pyramid-sea-borders.py → pyramid-drive-times.py.

CREATE OR REPLACE FUNCTION public.fh_pyramid_proposal_refresh()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    bar bigint;
    vkind text;
    vplan text;
    minpop int;
    reach numeric;
BEGIN
    SELECT b.bar INTO bar FROM pyramid_proposal_bar b;
    SELECT span_min_population, proposal_reach_min INTO minpop, reach FROM pyramid_territory_policy LIMIT 1;

    UPDATE pyramid_proposed_conferences p
       SET core_population = s.pop,
           tier = CASE WHEN s.pop >= bar THEN 'ready' WHEN s.pop >= bar * 0.75 THEN 'borderline' ELSE 'developing' END,
           developing = s.pop < bar * 0.75
      FROM (SELECT a.proposed_id AS id, max(mp.population) AS pop
              FROM pyramid_proposed_anchors a
              JOIN pyramid_metro_counties mc ON mc.fips = a.fips
              JOIN pyramid_metro_population mp ON mp.cbsa_code = mc.cbsa_code
             WHERE a.is_base
             GROUP BY a.proposed_id) s
     WHERE s.id = p.id;

    -- County → region by drive time (mig 1278).
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    WITH cand AS (
        SELECT c.plan, cp.fips, c.conference_id, c.proposed_id, c.factor,
               fh_km(cp.lat, cp.lon, c.lat, c.lon) AS km,
               COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, c.lat, c.lon) * 1.1) AS mins
          FROM pyramid_county_points cp
          JOIN pyramid_region_centers c ON true
          LEFT JOIN pyramid_county_drive_times dt
                 ON dt.fips = cp.fips AND dt.from_lat = cp.lat AND dt.from_lon = cp.lon
                AND dt.to_lat = round(c.lat::numeric, 4) AND dt.to_lon = round(c.lon::numeric, 4)
    ), ok AS (               -- current plan: only cities within reach
        SELECT * FROM cand WHERE plan = 'proposed' OR mins <= reach
    ), t AS (                -- travel + traffic: the coloured border
        SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id, km
          FROM ok ORDER BY plan, fips, mins * factor
    ), s AS (                -- plain travel time: the second line
        SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id
          FROM ok ORDER BY plan, fips, mins
    ), filled AS (
        SELECT t.plan, t.fips, t.conference_id, t.proposed_id, t.km, s.conference_id AS pc, s.proposed_id AS pp
          FROM t JOIN s USING (plan, fips)
        UNION ALL            -- a metro county out of everyone's reach: its home conference
        SELECT h.plan, h.fips, h.conference_id, h.proposed_id, NULL, h.conference_id, h.proposed_id
          FROM pyramid_region_homes h
          JOIN pyramid_counties k ON k.fips = h.fips AND k.state NOT IN ('AK', 'HI', 'PR')
         WHERE NOT EXISTS (SELECT 1 FROM t WHERE t.plan = h.plan AND t.fips = h.fips)
    )
    SELECT plan, fips, conference_id, proposed_id, km, pc, pp FROM filled;

    -- The pill's numbers, every region of both plans (keys are distinct).
    DELETE FROM pyramid_proposal_region_stats;
    INSERT INTO pyramid_proposal_region_stats (region, conference_id, proposed_id, population, counties, area_km2, a_fips, b_fips, span_km)
    WITH rc AS (
        SELECT COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id) AS region, pc.conference_id, pc.proposed_id,
               k.fips, k.lat, k.lon, k.population, k.area_km2,
               row_number() OVER (PARTITION BY pc.plan, pc.conference_id, pc.proposed_id ORDER BY k.population DESC) AS rk
          FROM pyramid_proposal_counties pc JOIN pyramid_counties k ON k.fips = pc.fips
    ), cand AS (
        SELECT * FROM rc WHERE population >= minpop OR rk <= 2
    ), far AS (
        SELECT DISTINCT ON (a.region) a.region, a.fips AS a_fips, b.fips AS b_fips, fh_km(a.lat, a.lon, b.lat, b.lon) AS km
          FROM cand a JOIN cand b ON b.region = a.region AND b.fips > a.fips
         ORDER BY a.region, fh_km(a.lat, a.lon, b.lat, b.lon) DESC
    )
    SELECT rc.region, min(rc.conference_id), min(rc.proposed_id), sum(rc.population), count(*), round(sum(rc.area_km2)),
           min(far.a_fips), min(far.b_fips), round(min(far.km)::numeric, 1)
      FROM rc LEFT JOIN far USING (region)
     GROUP BY rc.region;

    DELETE FROM pyramid_proposal_borders;
    FOREACH vplan IN ARRAY ARRAY['current', 'proposed'] LOOP
    FOREACH vkind IN ARRAY ARRAY['travel', 'plain'] LOOP
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left, kind)
    WITH reg AS (
        SELECT k0.fips,
               CASE WHEN vkind = 'travel' THEN COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id, 'x')
                    ELSE COALESCE('c' || pc.plain_conference_id, 'p' || pc.plain_proposed_id, 'x') END AS r,
               COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id, 'x') AS rt
          FROM pyramid_counties k0
          LEFT JOIN pyramid_proposal_counties pc ON pc.fips = k0.fips AND pc.plan = vplan
         WHERE k0.state NOT IN ('AK', 'HI', 'PR')
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
    ), orient AS (
        SELECT fips, ring, sum(lon * lat2 - lon2 * lat) > 0 AS ccw FROM seg WHERE lat2 IS NOT NULL GROUP BY fips, ring
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
           AND ra.r <> 'x'                  -- open ground on both sides: no border
           AND (vkind = 'travel' OR ra.rt = rb.rt)
    ), runs AS (
        SELECT b.*, i - row_number() OVER (PARTITION BY fips, ring, rb ORDER BY i) AS grp FROM border b
    )
    SELECT ra, rb,
           jsonb_build_array(jsonb_build_array(min(lat) FILTER (WHERE i = first_i), min(lon) FILTER (WHERE i = first_i)))
             || jsonb_agg(jsonb_build_array(lat2, lon2) ORDER BY i),
           bool_or(o.ccw), vkind
      FROM (SELECT r.*, min(i) OVER (PARTITION BY fips, ring, rb, grp) AS first_i FROM runs r) x
      JOIN orient o USING (fips, ring)
     GROUP BY x.fips, x.ring, rb, ra, grp;
    END LOOP;
    END LOOP;
END $function$;

COMMENT ON FUNCTION fh_pyramid_proposal_refresh() IS
    'mig 1279: both plans by drive time × traffic factor only (no balancer), region stats, border lines. Pipeline: scripts/pyramid-county-drive.py → refresh → pyramid-sea-borders.py → pyramid-drive-times.py.';

DROP TABLE IF EXISTS pyramid_proposal_county_pins;

-- ── Clubs by drive time ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_venue_drive_times (
    venue_id   int NOT NULL REFERENCES pyramid_venues(id) ON DELETE CASCADE,
    from_lat   numeric(9,4) NOT NULL,
    from_lon   numeric(9,4) NOT NULL,
    to_lat     numeric(9,4) NOT NULL,
    to_lon     numeric(9,4) NOT NULL,
    minutes    numeric NOT NULL,
    km         numeric NOT NULL,
    fetched_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (venue_id, to_lat, to_lon)
);
COMMENT ON TABLE pyramid_venue_drive_times IS
    'mig 1279: road drive (OSRM, no traffic) from a club ground to each live conference city — scripts/pyramid-county-drive.py.';

CREATE OR REPLACE VIEW pyramid_team_nearest_conference AS
SELECT t.id AS team_id, t.division_id, n.conference_id, n.km, n.minutes
  FROM pyramid_teams t
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions fc ON fc.id = d.competition_id AND fc.kind = 'affiliate'
  JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
  CROSS JOIN LATERAL (
        SELECT c.conference_id, fh_km(v.lat, v.lon, c.lat, c.lon) AS km,
               COALESCE(dt.minutes, fh_km(v.lat, v.lon, c.lat, c.lon) * 1.1) AS minutes
          FROM pyramid_region_centers c
          LEFT JOIN pyramid_venue_drive_times dt
                 ON dt.venue_id = v.id AND dt.from_lat = round(v.lat::numeric, 4) AND dt.from_lon = round(v.lon::numeric, 4)
                AND dt.to_lat = round(c.lat::numeric, 4) AND dt.to_lon = round(c.lon::numeric, 4)
         WHERE c.conference_id IS NOT NULL
         ORDER BY COALESCE(dt.minutes, fh_km(v.lat, v.lon, c.lat, c.lon) * 1.1) * c.factor
         LIMIT 1) n
 WHERE t.removed_at IS NULL;
COMMENT ON VIEW pyramid_team_nearest_conference IS
    'mig 1279: each located feeder team → the live conference whose city is the shortest drive from its ground × traffic factor (minutes); km straight.';

-- ── The rules, in order ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_conference_rules (
    rank  int PRIMARY KEY,
    title text NOT NULL,
    body  text NOT NULL
);
COMMENT ON TABLE pyramid_conference_rules IS
    'mig 1279: how #apsl-pyramid conferences are made, highest rule first — shown in ☰. Change by migration.';
INSERT INTO pyramid_conference_rules (rank, title, body) VALUES
  (1, 'Travel decides every border', 'A club or county belongs to the conference whose city is the shortest drive away with traffic (New York ×1.25). Where two conferences meet — Philly and New York, or anywhere — the border is where those drives are equal. It overrides every rule below.'),
  (2, 'Fair to every club', 'No club is placed for any reason but travel: not to balance numbers, shorten another club''s trips, follow a metro label or make a conference look tidy. Every club in a border area has a travel reason to be there.'),
  (3, 'Existing conferences are real', 'Today''s conferences keep their cities. The proposed map can re-imagine their reach, but only by the travel rule.'),
  (4, 'One city per conference', 'Each conference is built around one city — its biggest — and every distance is measured from that city''s centre.'),
  (5, 'Too far means a new conference', 'If a conference''s longest drive is too long (target 4½ h where people are dense), split it with a new city. Never bend a border to fix it.'),
  (6, 'The whole country is covered', 'Every county belongs to a conference in the proposed map, even sparse ones with long trips, as Norway and Brazil accept at this level.'),
  (7, 'People decide readiness', 'A proposal is ready when its city''s metro area has at least as many people as the smallest metro that anchors a live conference (Hartford), borderline at 75 %, otherwise one to watch.'),
  (8, 'Sized like a 4th division abroad', 'Conference count and size follow 4th tiers elsewhere: groups of 6–20 M people in dense regions (Serie D, 2ª Federación, Regionalliga), 1–2 M in sparse ones (Sweden, Norway).')
ON CONFLICT (rank) DO UPDATE SET title = EXCLUDED.title, body = EXCLUDED.body;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — ☰ section: the rules for making conferences', 'apsl_pyramid', 'rules_hud', NULL,
       'How conferences are made — rules in order', 324, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'rules_hud');

UPDATE message_templates
   SET body = 'Our proposal, not APSL''s, modelled on 4th divisions abroad (Serie D, 2ª Federación, Regionalliga): the whole lower 48, today''s 8 conferences re-imagined with the rest. Every county goes to the city it is the shortest drive from with traffic — borders by travel only (the rules above). Green ready · yellow borderline · grey watch — people in its metro vs the smallest live conference''s metro, Hartford ({bar}).',
       updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_intro';
