-- Roster pill left column (owner 2026-11-02): "col on left could be stacked.
-- as its team independent".  Members on no league list sit in one team-free
-- column, stacked NEEDS ONBOARD (welcome owed), NOT ON ROSTER, NO ROOM, so a
-- team column no longer implies a guy belongs to that team.
--
-- Awaiting Roster Spot becomes No Room and leaves the add lane: owner, "guys
-- that we just don't have room for".  He is not an add, so nobody asks the
-- league for him; when a spot opens you mark him Needs Add.
ALTER TABLE roster_statuses DROP CONSTRAINT IF EXISTS roster_statuses_board_section_check;
ALTER TABLE roster_statuses ADD CONSTRAINT roster_statuses_board_section_check
    CHECK (board_section IN ('proposed', 'pending_add', 'drop', 'pending_drop', 'no_room'));

UPDATE roster_statuses
   SET display_name = 'No Room',
       description  = 'Good enough, but the roster is full — not asked of the league until a spot opens',
       board_section = 'no_room',
       league_request = NULL
 WHERE code = 'awaiting_roster_spot';

UPDATE message_templates SET body = 'NOT ON ROSTER'
 WHERE kind = 'roster_sheet' AND tier = 'board_not_on_roster_h';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_members_title',   'Team boards — left column title on the Roster pill', '👤 Members, not on a roster', 969),
    ('board_members_subtitle', 'Team boards — page subtitle on the Roster pill', 'Members on no roster on the left, league rosters on the right — filter each side independently', 973),
    ('board_needs_onboard_h', 'Team boards — left column: signed up, welcome owed', 'NEEDS ONBOARD', 970),
    ('board_no_room_h',       'Team boards — left column: good enough, roster full', 'NO ROOM', 971),
    ('board_also_on_team',    'Team boards — ON ROSTER card: on another team here but not on its list', '⚠ also on {team} team, not its list', 972)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
