-- Migration 023: Relax NOT NULL constraints for events.title and matches.home_away_status_id
--
-- events.title: title can be derived at query time from match team names; not all
--               callers have team names available at insert time (scraper, seed scripts).
--
-- matches.home_away_status_id: home/away is fully determined by home_team_id / away_team_id
--                               and is redundant; no current code reads this column.

ALTER TABLE events ALTER COLUMN title DROP NOT NULL;
ALTER TABLE events ALTER COLUMN title SET DEFAULT '';

ALTER TABLE matches ALTER COLUMN home_away_status_id DROP NOT NULL;
