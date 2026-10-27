-- 777 (2026-10-27) — the #teams Roster pill is the board for organizing
-- league roster moves.  Owner: "we can even have a pending section to show
-- they were submitted. so that should be the drop down for movement on
-- roster. they also need from roster to be able to be moved out of those
-- sections but not out of 'official' except to put them in 'dropping' col
-- and then pending drop … roster pill is basically a way for me to
-- organize moves".
--
-- The two lanes, all driven by the card's roster-status dropdown:
--   ADD:  PROPOSED (a step we still owe) → PENDING ADD (submitted to the
--         league) → the 🌐 pull finds him on the list → OFFICIAL (granted).
--   DROP: OFFICIAL → DROPPING (we plan to) → PENDING DROP (submitted) →
--         the 🌐 pull no longer finds him → status cleared to Not on Roster.
-- A player on the league list can only be On Roster / Dropping / Pending
-- Drop (TeamController::handleSetRosterStatusForPerson); one not on it
-- can't be put in a drop lane.

ALTER TABLE roster_statuses DROP CONSTRAINT IF EXISTS roster_statuses_board_section_check;
ALTER TABLE roster_statuses ADD CONSTRAINT roster_statuses_board_section_check
    CHECK (board_section IN ('proposed', 'pending_add', 'drop', 'pending_drop'));
COMMENT ON COLUMN roster_statuses.board_section IS 'migs 775/777: #teams Roster pill lane — proposed (a step we owe) / pending_add (submitted, waiting on the league) / drop (on the list, planned to come off) / pending_drop (drop submitted) / NULL (On Roster lives on the list; the rest are not roster moves)';

UPDATE roster_statuses SET board_section = 'pending_add'
 WHERE code IN ('submitted_itc', 'awaiting_transfer', 'awaiting_approval');

UPDATE roster_statuses SET sort_order = 13 WHERE code = 'suspended';
INSERT INTO roster_statuses (id, code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order,
                             is_active, color_bg, color_fg, color_border, counts_as_on_roster, player_done, board_section)
SELECT (SELECT max(id) + 1 FROM roster_statuses), 'pending_drop', 'Pending Drop',
       'Drop submitted to the league — still on the official roster until the league takes him off',
       true, true, 12, true, '#dc2626', '#ffffff', '#f87171', true, false, 'pending_drop'
 WHERE NOT EXISTS (SELECT 1 FROM roster_statuses WHERE code = 'pending_drop');

-- every league whose pipeline has Possible Drop gets Pending Drop
INSERT INTO league_roster_statuses (league_id, roster_status_id)
SELECT l.league_id, (SELECT id FROM roster_statuses WHERE code = 'pending_drop')
  FROM league_roster_statuses l
 WHERE l.roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'possible_drop')
ON CONFLICT DO NOTHING;

-- Section headings (mig 776's REMOVE becomes DROPPING + PENDING DROP)
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_pending_add_h',  'Team boards — Roster pill: adds submitted to the league',  'PENDING ADD',  945),
    ('board_dropping_h',     'Team boards — Roster pill: planned drops',                 'DROPPING',     946),
    ('board_pending_drop_h', 'Team boards — Roster pill: drops submitted to the league', 'PENDING DROP', 947),
    ('board_pending_drop_chip', 'Team boards — flag on a pending-drop card',              '⏳ PENDING DROP', 948),
    ('board_pending_drops',  'Team boards — official banner suffix ({n})',               '{n} pending drop', 949)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
UPDATE message_templates SET is_active = false WHERE kind = 'roster_sheet' AND tier = 'board_remove_h';
UPDATE message_templates SET body = '⬇ DROPPING' WHERE kind = 'roster_sheet' AND tier = 'board_planned_drop_chip';
UPDATE message_templates SET body = '{n} dropping' WHERE kind = 'roster_sheet' AND tier = 'board_planned_drops';
