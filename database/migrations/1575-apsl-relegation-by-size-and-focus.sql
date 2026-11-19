-- 1575 (2026-11-19) — 📉 #apsl Forecast: up/down for every conference, the
-- Delaware River groups, and a page with no home team.
--
-- Owner 2026-11-19: "i need to be able share this whole page so lighthouse
-- has to not be center of attention lol. so we should be able to "focus" on
-- any given team in national pyramid" + "assume 1 relegation spot for all
-- other apsl confs. drc is unique with 1.5" + "and of course our weird one
-- next 2 years of 2 divisions" + "the others are 12 and 1.5 if they have
-- 12. if 11 then no relegation".
--
-- pyramid_relegation_size_rules: a conference with no seasons of its own
-- (pyramid_relegation_outlook) goes by its size this season — 12 teams:
-- 1.5 down / 1.5 up; 11: none down, 1 up (back to 12 — a guess, owner to
-- confirm); any other size (teams NULL): 1 down / 1 up.
-- pyramid_relegation_outlook.divisions: groups that season (Delaware River
-- 2 groups in 2026-27 and 2027-28, one table from 2028-29).
-- pyramid_forecast_policies.our_name_pattern goes: the page has no home
-- team; tap any team (or open a shared ?fc=<conference>&focus=<team> link)
-- for its road.
BEGIN;

CREATE TABLE IF NOT EXISTS pyramid_relegation_size_rules (
    id           serial PRIMARY KEY,
    teams        integer UNIQUE CHECK (teams > 0),   -- NULL = any other size
    relegated    numeric NOT NULL CHECK (relegated >= 0),
    promoted     numeric NOT NULL CHECK (promoted >= 0),
    rules_label  text,
    note         text
);
CREATE UNIQUE INDEX IF NOT EXISTS pyramid_relegation_size_rules_default ON pyramid_relegation_size_rules ((teams IS NULL)) WHERE teams IS NULL;

INSERT INTO pyramid_relegation_size_rules (teams, relegated, promoted, rules_label, note)
SELECT v.teams, v.down, v.up, v.label, v.note
  FROM (VALUES
    (12,   1.5, 1.5, 'Normal APSL rules (12 teams)', 'Owner 11/19: 12 teams → 1.5 down'),
    (11,   0,   1,   'Normal APSL rules (11 teams)', 'Owner 11/19: 11 teams → no relegation; 1 up (back to 12) is a guess'),
    (NULL, 1,   1,   'Assumed: 1 down, 1 up',        'Owner 11/19: "assume 1 relegation spot for all other apsl confs"')
  ) AS v(teams, down, up, label, note)
 WHERE NOT EXISTS (SELECT 1 FROM pyramid_relegation_size_rules r WHERE r.teams IS NOT DISTINCT FROM v.teams);

ALTER TABLE pyramid_relegation_outlook ADD COLUMN IF NOT EXISTS divisions integer NOT NULL DEFAULT 1 CHECK (divisions >= 1);
UPDATE pyramid_relegation_outlook o SET divisions = 2
  FROM pyramid_competitions c
 WHERE o.competition_id = c.id AND c.name = 'Delaware River Conference' AND o.season IN ('2026-27', '2027-28');

ALTER TABLE pyramid_forecast_policies DROP COLUMN IF EXISTS our_name_pattern;

UPDATE message_templates SET body = '🛣 The road ahead', label = 'Forecast — the focused team''s road heading'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_road';
UPDATE message_templates SET body = '{season}: {down} chance of going down (the forecast above).', label = 'Forecast — road: this season ({down} {season})'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_road_now';
UPDATE message_templates SET body = 'Drop now: {s2} in a feeder league — {up} spots come up across the feeders, and the {others} other sides relegated that year chase them too. Back up for {s3}: then only {s3_down} of {s3_teams} go down.',
       label = 'Forecast — road: drop now, back next year ({s2} {s3} {up} {others} {s3_down} {s3_teams})'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_bounce';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_ol_groups',     'Forecast — outlook column: groups',                       'Groups', 420),
    ('fc_ol_every',      'Forecast — outlook: a size-rule season label',            'Every season', 421),
    ('fc_ol_road_base',  'Forecast — road: the base rate ({pct} {season})',         '{season}: an average side has a {pct} chance of going down.', 422),
    ('fc_ol_tap_road',   'Forecast — outlook: tap a team for its road',             'Tap any team for its own road through these seasons.', 423),
    ('fc_share',         'Forecast — share link button',                            '🔗 Copy link', 424),
    ('fc_shared',        'Forecast — share link copied',                            '✓ Link copied', 425)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;
