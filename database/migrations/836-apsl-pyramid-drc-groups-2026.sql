-- 836 (2026-10-29) — #apsl: Delaware River's groups, this season only.
--
-- Owner 2026-10-29: "now for apsl delaware river we need an exception for
-- this year. so for both their a and b divisions. 1st and 2nd green for
-- playoffs. 3 to 6 white, 7th orange for relegation playoff and 8th red for
-- auto relegation."
--
-- pyramid_zone_rules.expires_on: a rule row stops applying after that date
-- (NULL = always).  Group A and Group B each get their own playoff (stay)
-- and relegation (down) rows, expiring after the 2026/27 season, when the
-- groups fall back to the defaults (1st–4th playoff, 11th / 12th).

ALTER TABLE pyramid_zone_rules ADD COLUMN IF NOT EXISTS expires_on date;

INSERT INTO pyramid_zone_rules (source_id, division, direction, kind, from_pos, to_pos, expires_on, note)
SELECT s.id, g.division, v.dir, v.kind, v.f, v.t, DATE '2027-07-31', 'owner 2026-10-29: Delaware River groups, 2026/27 only'
  FROM pyramid_sources s
  CROSS JOIN (VALUES ('Delaware River Conference (Pennsylvania & New Jersey) - Group A'),
                     ('Delaware River Conference (Pennsylvania & New Jersey) - Group B')) AS g(division)
  CROSS JOIN (VALUES ('stay', 'playoff', 1, 2),
                     ('down', 'relegation_playoff', 7, 7),
                     ('down', 'relegation', 8, 8)) AS v(dir, kind, f, t)
 WHERE s.system = 'teampass_json' AND s.locator = '3841'
   AND NOT EXISTS (SELECT 1 FROM pyramid_zone_rules r WHERE r.source_id = s.id AND r.division = g.division);

-- Rules past their expires_on no longer apply.
CREATE OR REPLACE VIEW pyramid_zones_effective AS
WITH div AS (
    SELECT d.id, d.source_id, d.name,
           (SELECT count(*)::int FROM pyramid_teams t WHERE t.division_id = d.id AND t.removed_at IS NULL) AS n
      FROM pyramid_divisions d
     WHERE d.removed_at IS NULL),
-- Feeders sharing each upper level: distinct (league source, table less
-- its group) linked into it.  (Kept for min/max_feeders on a rule.)
upper_feeders AS (
    SELECT l.id AS link_id,
           (SELECT count(DISTINCT (l2.lower_source_id, regexp_replace(l2.lower_division, '\s*-\s*Group\s+\S+$', '')))
              FROM pyramid_links l2
             WHERE l2.promotes
               AND ((l.upper_competition_id IS NOT NULL AND l2.upper_competition_id = l.upper_competition_id)
                 OR (l.upper_source_id IS NOT NULL AND l2.upper_source_id = l.upper_source_id
                     AND l2.upper_division = l.upper_division))) AS feeders
      FROM pyramid_links l
     WHERE l.promotes),
up AS (
    SELECT div.id AS division_id, max(uf.feeders) AS feeders
      FROM div
      JOIN pyramid_links l ON l.promotes AND l.lower_source_id = div.source_id AND l.lower_division = div.name
      JOIN upper_feeders uf ON uf.link_id = l.id
     GROUP BY div.id),
overridden AS (
    SELECT DISTINCT div.id AS division_id, r.direction
      FROM div JOIN pyramid_zone_rules r ON r.source_id = div.source_id AND r.division = div.name
     WHERE (r.expires_on IS NULL OR r.expires_on >= current_date)),
applied AS (
    -- this table's own rows
    SELECT div.id AS division_id, div.n, r.id AS rule_id, r.direction, r.kind, r.from_pos, r.to_pos, 'override'::text AS origin
      FROM div
      JOIN pyramid_zone_rules r ON r.source_id = div.source_id AND r.division = div.name
      LEFT JOIN up ON up.division_id = div.id
     WHERE (r.min_feeders IS NULL OR coalesce(up.feeders, 0) >= r.min_feeders)
       AND (r.expires_on IS NULL OR r.expires_on >= current_date)
    UNION ALL
    -- defaults, where the table has no override that way
    SELECT div.id, div.n, r.id, r.direction, r.kind, r.from_pos, r.to_pos, 'default'
      FROM div
      JOIN pyramid_zone_rules r ON r.source_id IS NULL
      LEFT JOIN up ON up.division_id = div.id
     WHERE NOT EXISTS (SELECT 1 FROM overridden o WHERE o.division_id = div.id AND o.direction = r.direction)
       AND (r.expires_on IS NULL OR r.expires_on >= current_date)
       AND (r.applies_to = 'all'
            OR (r.applies_to = 'top' AND up.division_id IS NULL)
            OR (r.applies_to = 'feeder' AND up.division_id IS NOT NULL
                AND up.feeders >= coalesce(r.min_feeders, 0)
                AND up.feeders <= coalesce(r.max_feeders, up.feeders)))),
rule_zones AS (
    SELECT a.division_id, a.kind, a.from_pos, least(a.to_pos, a.n) AS to_pos, a.origin
      FROM applied a
     WHERE a.kind IS NOT NULL AND a.n >= a.from_pos),
-- The directions the rules decide for each table (even when its size
-- leaves no rule spot — "no 12th then no relegation").
decided AS (SELECT DISTINCT division_id, direction FROM applied)
SELECT rz.division_id, rz.kind, rz.from_pos, rz.to_pos, k.label, rz.origin
  FROM rule_zones rz JOIN pyramid_zone_kinds k ON k.code = rz.kind
UNION ALL
SELECT z.division_id, z.kind, z.from_pos, z.to_pos, z.label, 'source'
  FROM pyramid_division_zones z
  JOIN pyramid_zone_kinds k ON k.code = z.kind
  JOIN div ON div.id = z.division_id
 WHERE NOT EXISTS (SELECT 1 FROM decided x WHERE x.division_id = z.division_id AND x.direction = coalesce(k.moves, 'stay'))
   AND NOT EXISTS (SELECT 1 FROM rule_zones rz
                    WHERE rz.division_id = z.division_id
                      AND rz.from_pos <= z.to_pos AND rz.to_pos >= z.from_pos);

-- Copy: the ✏️ editor names an expiring exception.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — editor: expiring rows', 'apsl_pyramid', 'until', NULL, 'This exception ends {date} — then the defaults apply', 74, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'until');
