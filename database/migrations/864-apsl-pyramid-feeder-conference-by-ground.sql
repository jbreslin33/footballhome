-- 864 (2026-10-29) — #apsl-pyramid: a feeder's conference from where its
-- teams play.
--
-- Owner 2026-10-29: "for feeder leagues use home field to infer what
-- conference. i can fix after if wrong."
--
-- pyramid_feeder_conference_votes: each feeder team at a located ground
-- votes for the conference of the NEAREST APSL team's ground (the same
-- nearest-ground rule that draws the territories, mig 852/855).  A feeder
-- votes only when at least half its teams are at a located ground (LISFL:
-- 1 of 43 — the first cut moved it to Constitution on that one).  The rule:
--   - parent = the conference most of its teams are nearest — except the
--     four CASA Select regions, which the owner named as Delaware River
--     feeders (mig 823), and a feeder that doesn't vote (MMSL: no
--     source) — those keep theirs;
--   - its top table also links into any other conference nearest to at
--     least a fifth of its teams, like North Jersey into Metropolitan.
-- First run 10/29: every guessed parent held (CASA MA, Cosmo, LISFL,
-- MIPSL, ADASL — the last three on too few grounds to vote); Central
-- Jersey Liga 1 gains Metropolitan (Elizabeth, Carteret ×2, Perth Amboy:
-- 4 of 19).
--
-- Harlem River Park (225 E 128th St, Cosmo's Central Park Rangers / ERFC
-- Hudson) had geocoded ~390 km north, into upstate NY: set by hand.

UPDATE pyramid_venues
   SET lat = 40.8063000, lon = -73.9327000, geocoded_at = now(), geocode_note = 'hand-set (mig 864)'
 WHERE address = '225 E128th St., New York, NY 10035';

DROP VIEW IF EXISTS pyramid_feeder_conference_votes;
CREATE VIEW pyramid_feeder_conference_votes AS
WITH ft AS (
    SELECT fc.id AS competition_id, v.lat, v.lon
      FROM pyramid_competitions fc
      JOIN pyramid_divisions d ON d.competition_id = fc.id AND d.removed_at IS NULL
      JOIN pyramid_teams t ON t.division_id = d.id AND t.removed_at IS NULL
      LEFT JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
     WHERE fc.kind = 'affiliate'),
totals AS (
    SELECT competition_id, count(*) AS total, count(lat) AS located FROM ft GROUP BY 1)
SELECT ft.competition_id, n.conference_id, count(*) AS teams,
       round(count(*)::numeric / tt.located, 3) AS share,
       tt.located, tt.total, tt.located * 2 >= tt.total AS votes
  FROM ft
  JOIN totals tt ON tt.competition_id = ft.competition_id
  CROSS JOIN LATERAL (
        SELECT tc.conference_id
          FROM pyramid_team_conference tc
         ORDER BY fh_km(ft.lat, ft.lon, tc.lat, tc.lon)
         LIMIT 1) n
 WHERE ft.lat IS NOT NULL
 GROUP BY ft.competition_id, n.conference_id, tt.located, tt.total;

-- Parent = the top vote.
UPDATE pyramid_competitions fc
   SET parent_id = top.conference_id
  FROM (SELECT DISTINCT ON (competition_id) competition_id, conference_id
          FROM pyramid_feeder_conference_votes
         WHERE votes
         ORDER BY competition_id, teams DESC, conference_id) top
 WHERE fc.id = top.competition_id
   AND fc.name NOT LIKE 'CASA Select %'
   AND fc.parent_id IS DISTINCT FROM top.conference_id;

-- A fifth or more nearest another conference: the top table links there
-- too (every table the feeder already links into a conference).
INSERT INTO pyramid_links (lower_source_id, lower_division, upper_competition_id)
SELECT DISTINCT l.lower_source_id, l.lower_division, vt.conference_id
  FROM pyramid_feeder_conference_votes vt
  JOIN pyramid_sources s ON s.competition_id = vt.competition_id
  JOIN pyramid_links l ON l.lower_source_id = s.id AND l.upper_competition_id IS NOT NULL
 WHERE vt.votes AND vt.share >= 0.2
ON CONFLICT DO NOTHING;

-- Undo the first cut on this DB: LISFL back to Metropolitan, no
-- Constitution link (no-ops on a fresh run).
UPDATE pyramid_competitions SET parent_id = m.id
  FROM pyramid_competitions m
 WHERE m.kind = 'conference' AND m.name = 'Metropolitan Conference'
   AND pyramid_competitions.name = 'Long Island Soccer Football League'
   AND pyramid_competitions.parent_id IS DISTINCT FROM m.id;
DELETE FROM pyramid_links l
 USING pyramid_sources s, pyramid_competitions fc, pyramid_competitions uc
 WHERE s.id = l.lower_source_id AND fc.id = s.competition_id AND uc.id = l.upper_competition_id
   AND fc.name = 'Long Island Soccer Football League' AND uc.name = 'Constitution Conference';
