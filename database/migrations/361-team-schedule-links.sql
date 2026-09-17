-- 361 — League schedule links per team, shown on the public #schedules page.
--
-- Owner 2026-09-17: "do we have a schedules link on my page … so i can
-- post the leagues web page with schedule on it for each group … so
-- members can see ahead of this week without being able to rsvp".
--
-- #my only shows the released week (schedule release window, mig 334), so
-- the long view has to live somewhere read-only.  The league's own site
-- already publishes the full season; we just point at it.  One row per
-- (team, url) so a team in two competitions can carry two links.  Add or
-- change links by migration.
CREATE TABLE IF NOT EXISTS team_schedule_links (
  id          serial PRIMARY KEY,
  team_id     integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  label       text    NOT NULL,
  url         text    NOT NULL CHECK (url ~ '^https://'),
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (team_id, url)
);

-- Girls play on the Boys section's teams (no girls teams exist), so the
-- Girls heading on #schedules lists the Boys teams.  NULL = own teams.
ALTER TABLE club_sections
  ADD COLUMN IF NOT EXISTS schedule_section_id integer REFERENCES club_sections(id);
UPDATE club_sections g SET schedule_section_id = b.id
  FROM club_sections b
 WHERE g.code = 'G' AND b.code = 'B' AND g.schedule_section_id IS NULL;

INSERT INTO team_schedule_links (team_id, label, url) VALUES
  (912, 'League schedule (GotSport)', 'https://system.gotsport.com/org_event/events/57473/schedules?team=4408462'),
  (913, 'League schedule (GotSport)', 'https://system.gotsport.com/org_event/events/57473/schedules?team=4411988'),
  (914, 'League schedule (GotSport)', 'https://system.gotsport.com/org_event/events/57473/schedules?team=4411989'),
  (35,  'League schedule (APSL)',     'https://apslsoccer.com/APSL/Team/165430'),
  -- CASA's site can't filter to one team by URL, so this is the whole Liga 1 schedule.
  (120, 'League schedule (CASA, all teams)', 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9496152'),
  -- APSL Reserves have no schedule of their own (owner 2026-09-17): they
  -- normally play Liga 1 and can be called up to APSL, so they get both.
  (938, 'Liga 1 schedule (CASA, all teams)', 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9496152'),
  (938, 'APSL schedule (call-ups)',          'https://apslsoccer.com/APSL/Team/165430')
ON CONFLICT (team_id, url) DO NOTHING;

-- Reserves: Liga 1 first, APSL second.
UPDATE team_schedule_links SET sort_order = 1
 WHERE team_id = 938 AND url = 'https://apslsoccer.com/APSL/Team/165430';
