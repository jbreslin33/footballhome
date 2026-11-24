-- 1845 (2026-11-24) — 🔺 #apsl-pyramid: three season-calendar pills.
--
-- Owner: "have toggle to show Fifa calendear teams. show summer u23 teams. fifa cal is apsl,
-- casa liga 1 etc, upsl, mls. hten there is u23 summer league is usl2, casa u23, npsl, league
-- for clubs. the usl champ and usl league one are spring to fall. so have diff toggles for
-- each one. 3 temporal buttons" · "pills" · "welocme to us soccer lol".
--
-- season_calendars              when a league plays; one pill each under ☰ Show on screen
-- pro_leagues.calendar          the league's calendar (NULL on a league under another =
--                               its upper league's)
-- pyramid_competitions.calendar the pyramid's own (set on its root: the APSL and every
--                               league that feeds it play fall to spring)
-- As the owner gave them.  Two he did not name are placed with MLS: MLS NEXT Pro (its
-- reserve league) and the Concacaf Champions Cup (the cup its clubs qualify for).
CREATE TABLE IF NOT EXISTS season_calendars (
    code       text PRIMARY KEY,
    label      text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0
);
INSERT INTO season_calendars (code, label, sort_order) VALUES
    ('fifa',        '🗓 FIFA calendar (fall–spring)', 1),
    ('summer',      '☀️ U23 summer leagues',          2),
    ('spring_fall', '🌱 Spring to fall',              3)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE pro_leagues ADD COLUMN IF NOT EXISTS calendar text REFERENCES season_calendars(code);
ALTER TABLE pyramid_competitions ADD COLUMN IF NOT EXISTS calendar text REFERENCES season_calendars(code);

UPDATE pyramid_competitions SET calendar = 'fifa' WHERE slug = 'apsl';
UPDATE pro_leagues SET calendar = 'fifa'        WHERE name IN ('MLS', 'MLS NEXT Pro', 'Concacaf Champions Cup');
UPDATE pro_leagues SET calendar = 'spring_fall' WHERE name IN ('USL Championship', 'USL League One');
UPDATE pro_leagues SET calendar = 'summer'      WHERE name IN ('USL League Two', 'The League for Clubs');
