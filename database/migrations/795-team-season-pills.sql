-- 795: Season pills on #teams — Fall · Winter · Spring · Summer (owner
-- 2026-10-28: "lets have pills for Fall, Winter, Spring, Summer in teams";
-- "a season row of pills"; "for all"; "so we can click pill for boys,
-- fall or men, winter").
--
-- year_terms  — the four seasons of the year, their pill label and the
--               day each one starts (the lit pill on open = the term
--               whose start most recently passed, fh_current_term()).
-- team_terms  — which terms a team plays in.  A team with NO rows shows
--               under every pill, so nothing vanishes before it's mapped.
--
-- Not seasons.* — those are league seasons (2025/2026, Fall 2026, Indoor
-- 2026–27) and run stale; a team's terms are a fact about the team.
-- Change a team's terms by migration.
CREATE TABLE IF NOT EXISTS year_terms (
  code         text PRIMARY KEY,
  label        text NOT NULL,
  sort_order   int  NOT NULL,
  starts_month int  NOT NULL CHECK (starts_month BETWEEN 1 AND 12),
  starts_day   int  NOT NULL DEFAULT 1 CHECK (starts_day BETWEEN 1 AND 31)
);
COMMENT ON TABLE year_terms IS 'Seasons of the year for the #teams season pills (mig 795): label + start day.';

INSERT INTO year_terms (code, label, sort_order, starts_month) VALUES
  ('fall',   '🍂 Fall',   1, 9),
  ('winter', '❄️ Winter', 2, 12),
  ('spring', '🌱 Spring', 3, 3),
  ('summer', '☀️ Summer', 4, 6)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS team_terms (
  team_id integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  term    text    NOT NULL REFERENCES year_terms(code),
  PRIMARY KEY (team_id, term)
);
COMMENT ON TABLE team_terms IS 'Which year_terms a team plays in (mig 795). No rows = shows under every season pill.';

-- The term a date falls in: the one whose start (this year or last) most
-- recently passed.
CREATE OR REPLACE FUNCTION fh_current_term(p_day date DEFAULT (now() AT TIME ZONE 'America/New_York')::date)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT t.code
    FROM year_terms t
    CROSS JOIN LATERAL (
      SELECT CASE WHEN make_date(extract(year FROM p_day)::int, t.starts_month, t.starts_day) <= p_day
                  THEN make_date(extract(year FROM p_day)::int, t.starts_month, t.starts_day)
                  ELSE make_date(extract(year FROM p_day)::int - 1, t.starts_month, t.starts_day) END AS began) b
   ORDER BY b.began DESC LIMIT 1
$$;

INSERT INTO team_terms (team_id, term)
SELECT v.team_id, v.term FROM (VALUES
  -- Men: APSL, APSL Reserves, Liga 1 — fall + spring (winter break)
  (35, 'fall'), (35, 'spring'), (938, 'fall'), (938, 'spring'), (120, 'fall'), (120, 'spring'),
  -- Women: Tri County
  (901, 'fall'), (901, 'spring'),
  -- Youth travel: U8 / U10 / U12 Travel
  (912, 'fall'), (912, 'spring'), (913, 'fall'), (913, 'spring'), (914, 'fall'), (914, 'spring'),
  -- Intramural U6–U19: fall, spring, summer
  (931, 'fall'), (931, 'spring'), (931, 'summer'), (935, 'fall'), (935, 'spring'), (935, 'summer'),
  (936, 'fall'), (936, 'spring'), (936, 'summer'), (937, 'fall'), (937, 'spring'), (937, 'summer'),
  (934, 'fall'), (934, 'spring'), (934, 'summer'), (932, 'fall'), (932, 'spring'), (932, 'summer'),
  -- PPR Indoor (mig 788)
  (940, 'winter'), (941, 'winter'), (942, 'winter')
) AS v(team_id, term)
JOIN teams t ON t.id = v.team_id
ON CONFLICT DO NOTHING;
