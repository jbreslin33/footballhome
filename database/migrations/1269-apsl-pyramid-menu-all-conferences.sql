-- 1269 (2026-11-11) — #apsl-pyramid ☰ conference list: existing AND proposed,
-- counted, by people.
--
-- Owner 2026-11-11: "in menu show how many proposed + existing conferences
-- show total. also list by pop desc" / "put the existing in the list and
-- mark off existing and proposed".
--
-- pyramid_conference_metro: each live conference's main city and its metro
-- area's people (mig 1265), so /api/pyramid/proposal gives live regions the
-- same core_population the proposals carry and the list sorts as one.

CREATE OR REPLACE VIEW pyramid_conference_metro AS
SELECT m.competition_id AS conference_id, m.name AS city, mp.title AS metro, mp.population
  FROM pyramid_main_cities m
  JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
  JOIN pyramid_metro_counties mc ON mc.fips = m.core_fips[1]
  JOIN pyramid_metro_population mp ON mp.cbsa_code = mc.cbsa_code;
COMMENT ON VIEW pyramid_conference_metro IS
    'mig 1269: live conference → main city, its metro area and people (#apsl-pyramid ☰ list).';

UPDATE message_templates SET body = 'Conferences — existing and proposed', updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_hud';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('proposal_count', 'APSL pyramid — ☰ list: conference count', '{live} existing + {proposed} proposed = {total} conferences', 308),
    ('mark_live', 'APSL pyramid — ☰ list: existing conference tag', 'Existing', 309),
    ('mark_proposed', 'APSL pyramid — ☰ list: proposed conference tag', 'Proposed', 310)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
