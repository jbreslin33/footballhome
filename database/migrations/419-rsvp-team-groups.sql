-- 419 — #rsvps team groups: pick several teams with one pill.
--
-- Owner 2026-09-23: "allow multiple pill selection for teams? so i can
-- select u8 intra, u8 travel and u6 intra or at least group them to
-- select 430 kids, 530 kids, men etc".  Team pills now toggle (several at
-- once); these rows are the one-tap groups shown beside them.  A group
-- is a label over a set of teams — the board shows it when at least two
-- of its teams are on the board, and it selects/deselects them together.
-- Seeded from this season's usual practice starts (U6/U8 at 4:30, U10 and
-- up at 5:30, men's at 7:00); change a group by migration.
CREATE TABLE IF NOT EXISTS rsvp_team_groups (
  id          SERIAL PRIMARY KEY,
  club_id     INTEGER NOT NULL REFERENCES clubs(id),
  label       TEXT    NOT NULL,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (club_id, label)
);
CREATE TABLE IF NOT EXISTS rsvp_team_group_teams (
  group_id  INTEGER NOT NULL REFERENCES rsvp_team_groups(id) ON DELETE CASCADE,
  team_id   INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  PRIMARY KEY (group_id, team_id)
);

INSERT INTO rsvp_team_groups (club_id, label, sort_order) VALUES
  (134, '4:30 kids', 1), (134, '5:30 kids', 2), (134, 'Men', 3)
ON CONFLICT (club_id, label) DO NOTHING;

INSERT INTO rsvp_team_group_teams (group_id, team_id)
SELECT g.id, t.id FROM rsvp_team_groups g JOIN teams t ON
      (g.label = '4:30 kids' AND t.id IN (931, 935, 912))              -- U6 Intramural, U8 Intramural, U8 Travel
   OR (g.label = '5:30 kids' AND t.id IN (936, 913, 937, 914, 934, 932))  -- U10/U12 Intramural + Travel, U16, U19
   OR (g.label = 'Men'       AND t.id IN (35, 120, 938))               -- APSL, Liga 1, APSL Reserves
 WHERE g.club_id = 134
ON CONFLICT DO NOTHING;
