-- 656 (2026-10-23) — game: ability from this season's record and the real
-- rosters (game/DESIGN.md §8.36).
--
-- James: "use this years record and roster … its all on apsl website" /
-- "for lh put our liga 1 guys in too" / "for lh anyone on a roster gets
-- scores for abilities" / "for other teams need to be on real roster" /
-- "so we are not outlier".
--
-- Strength comes from TABLE POSITION, not raw goal difference, so a 2-31
-- start doesn't make a team a statistical outlier: each division maps its
-- table onto a quality span (APSL = the semi-pro band 60-76; Liga 1, the
-- reserve-side division, one step lower). A player's quality is the best of
-- his rostered teams'. Quality replaces the band's default ABILITY on every
-- concept the band knows, and seeds his attributes.
--
-- Records and squads are loaded by game/scripts/load_squads.py (league
-- feed + club rosters), straight into the DB — player names never go in git.

CREATE TABLE IF NOT EXISTS game_team_records (
    team_label  TEXT NOT NULL,      -- the league's name for the team
    division    TEXT NOT NULL,      -- 'APSL Delaware River' / 'CASA Liga 1'
    season      TEXT NOT NULL,
    played      SMALLINT NOT NULL,
    wins        SMALLINT NOT NULL,
    draws       SMALLINT NOT NULL,
    losses      SMALLINT NOT NULL,
    goals_for   SMALLINT NOT NULL,
    goals_against SMALLINT NOT NULL,
    source      TEXT NOT NULL,      -- feed / url
    fetched_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (team_label, division, season)
);
COMMENT ON TABLE game_team_records IS 'This season''s record per team per division (mig 656), from the league feeds; the game rates teams from it.';

-- Each division's quality span (the table's first and last place).
CREATE TABLE IF NOT EXISTS game_division_quality (
    division  TEXT PRIMARY KEY,
    top_q     SMALLINT NOT NULL CHECK (top_q BETWEEN 0 AND 100),
    bottom_q  SMALLINT NOT NULL CHECK (bottom_q BETWEEN 0 AND 100),
    note      TEXT NOT NULL
);
INSERT INTO game_division_quality (division, top_q, bottom_q, note) VALUES
 ('APSL Delaware River', 76, 60, 'APSL = semi-pro: the table spans the semi-pro band around its 68 centre.'),
 ('CASA Liga 1', 68, 52, 'Liga 1 = the reserve-side division (APSL clubs'' second teams), one step below APSL.')
ON CONFLICT (division) DO UPDATE SET top_q = EXCLUDED.top_q, bottom_q = EXCLUDED.bottom_q, note = EXCLUDED.note;

-- Quality by table position: points per game, then goal difference per game.
CREATE OR REPLACE VIEW game_team_strength AS
WITH ranked AS (
    SELECT r.*, (r.wins * 3 + r.draws)::numeric / NULLIF(r.played, 0) AS ppg,
           (r.goals_for - r.goals_against)::numeric / NULLIF(r.played, 0) AS gdpg,
           rank() OVER (PARTITION BY r.division, r.season
                        ORDER BY (r.wins * 3 + r.draws)::numeric / NULLIF(r.played, 0) DESC,
                                 (r.goals_for - r.goals_against)::numeric / NULLIF(r.played, 0) DESC) AS pos,
           count(*) OVER (PARTITION BY r.division, r.season) AS teams
      FROM game_team_records r WHERE r.played > 0)
SELECT k.team_label, k.division, k.season, k.pos, k.teams, round(k.ppg, 2) AS ppg, round(k.gdpg, 2) AS gdpg,
       round(q.top_q - (q.top_q - q.bottom_q) * (k.pos - 1)::numeric / GREATEST(k.teams - 1, 1))::smallint AS quality
  FROM ranked k JOIN game_division_quality q ON q.division = k.division;
COMMENT ON VIEW game_team_strength IS 'Team quality from table position within its division span (mig 656).';

ALTER TABLE game_demo_teams   ADD COLUMN IF NOT EXISTS quality SMALLINT CHECK (quality BETWEEN 0 AND 100);
ALTER TABLE game_demo_players ADD COLUMN IF NOT EXISTS quality SMALLINT CHECK (quality BETWEEN 0 AND 100);
COMMENT ON COLUMN game_demo_teams.quality IS 'Team strength from its record (game_team_strength); NULL = the band.';
COMMENT ON COLUMN game_demo_players.quality IS 'The player''s overall ability 0-100 — his default on every concept his band knows (replaces the band''s quality); NULL = the team''s, else the band''s (mig 656).';
