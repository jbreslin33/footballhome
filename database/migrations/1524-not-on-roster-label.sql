-- 1524 (2026-11-19) — ⛔ "Not eligible" reads "Not On Roster".
--
-- Owner: "for me we would assume a guy is eligile if they are [On Roster]
-- via some roster mechanishmt [if] not then we should flag as not on
-- roster?" — the club's own term (On Roster / official roster).  Words
-- only; mig 1523's status (code not_eligible) and its rule are unchanged:
-- On Roster for CASA, or for APSL as a call-down, else flagged.

UPDATE message_templates SET body = v.body, updated_at = now()
  FROM (VALUES
    ('roster_sheet',    'board_not_eligible_h',     '⛔ NOT ON ROSTER'),
    ('roster_sheet',    'team_status_not_eligible', '⛔ Not On Roster (auto)'),
    ('roster_sheet',    'tc_not_eligible',          '⛔ Not On Roster'),
    ('roster_sheet',    'tc_not_eligible_tip',
     'Not On Roster for this team, or for APSL as a call-down — doesn''t see its games, still practises. Clears itself when the sync shows them On Roster.'),
    ('event_center',    'sec_not_eligible',         '⛔ Not On Roster'),
    ('person_standing', 'roster_not_eligible',      '{team} Not On Roster')
  ) AS v(kind, tier, body)
 WHERE message_templates.kind = v.kind AND message_templates.tier = v.tier;

UPDATE squad_statuses SET display_name = 'Not On Roster' WHERE code = 'not_eligible';
