-- 362 — Season fixtures that live only in FH, for the view-only
-- "My schedule ahead" list on #schedules.
--
-- Owner 2026-09-17: "we want the women to see all events in 'schedule'
-- link since they cant always get to teamsnap without logging in" …
-- "dont write to gcal" … "only to fh".
--
-- Tri County Women's league schedule is on TeamSnap behind a login, so a
-- team_schedule_links row (mig 361) would dead-end for members.  Google
-- Calendar stays the source of truth for anything with an RSVP: the
-- owner adds each week's game there as it comes up, and fh_events needs
-- a gcal row.  These rows are just the look-ahead.  The API hides a
-- fixture once that team has a calendar game on the same local day, so
-- nothing shows twice.
--
-- Read off TeamSnap (go.teamsnap.com/10717331/schedule) on 2026-09-17.
-- Re-run by migration if the league moves a game.
CREATE TABLE IF NOT EXISTS team_schedule_fixtures (
  id          serial PRIMARY KEY,
  team_id     integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  starts_at   timestamptz NOT NULL,
  ends_at     timestamptz,
  opponent    text NOT NULL,
  is_home     boolean,            -- NULL = source didn't say
  location    text,
  source      text NOT NULL,      -- where the fixture was read from
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (team_id, starts_at)
);

INSERT INTO team_schedule_fixtures (team_id, starts_at, ends_at, opponent, is_home, location, source) VALUES
  (901, '2026-09-13 11:00 America/New_York', '2026-09-13 12:30 America/New_York', 'Colonials 2',        false, 'Victory 4',              'teamsnap'),
  (901, '2026-09-20 10:00 America/New_York', '2026-09-20 11:30 America/New_York', 'Boyertown Breakers', true,  'Lighthouse Grass Field', 'teamsnap'),
  (901, '2026-09-27 13:30 America/New_York', '2026-09-27 15:00 America/New_York', 'Falcons Orange',     false, 'Germantown Supersite',   'teamsnap'),
  (901, '2026-10-04 10:00 America/New_York', '2026-10-04 11:30 America/New_York', 'Bandits FC',         NULL,  'Lighthouse Grass Field', 'teamsnap'),
  (901, '2026-10-18 10:00 America/New_York', '2026-10-18 11:30 America/New_York', 'Senza Nome SC',      true,  'Lighthouse Grass Field', 'teamsnap'),
  (901, '2026-10-25 10:00 America/New_York', '2026-10-25 11:30 America/New_York', 'Rose Tree',          true,  'Lighthouse Grass Field', 'teamsnap'),
  (901, '2026-11-01 10:00 America/New_York', '2026-11-01 11:30 America/New_York', 'Gaels',              false, 'Rosemont College',       'teamsnap')
ON CONFLICT (team_id, starts_at) DO NOTHING;
