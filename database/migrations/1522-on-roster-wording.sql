-- 1522 (2026-11-19) — Say "On Roster" / "official roster", not "league list".
--
-- Owner: "you keep saying on the league list its on official league roster.
-- or on roster."  The words migs 1519/1521 added follow the club's term.

UPDATE message_templates SET body = v.body, updated_at = now()
  FROM (VALUES
    ('person_standing', 'reg_have_tip',
     'Filled the {league} registration form[[ on {date}]]. The commissioner can put them On Roster without a new registration.'),
    ('person_standing', 'reg_list_tip',
     'On the {league} official roster[[ (seen {date})]], so registered with {league} this season.'),
    ('roster_sheet', 'tc_listed_tip',
     'On Roster (official league roster)')
  ) AS v(kind, tier, body)
 WHERE message_templates.kind = v.kind AND message_templates.tier = v.tier;
