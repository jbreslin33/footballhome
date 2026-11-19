-- 1521 (2026-11-19) — #teams Team view: a game-style card per team.
--
-- Owner: "maybe 2 'game' cards for apsl and liga 1 on same screen with
-- boxes and important info in the boxes" + "no diff between a reserve and
-- a main its just whhat we want them to see. we can just have the reserves
-- pitch hidden by defualt".  RosterScreenBase.renderTeamCards: ACTIVE as
-- boxes on a pitch (name, last RSVP / 👻, dues, CASA form, 📋 on the
-- league list), the folded team (APSL Reserves) a second pitch closed by
-- default, then 👋 Not chasing / 🏋 Practice squad / 🩹 Injured / 💤
-- Inactive name rows.  Words only.

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.cat, v.label, v.kind, v.tier, v.body, v.ord, true
  FROM (VALUES
    ('Roster sheet', 'roster_sheet', 'tc_box_tip',    '#teams team card: box hover',                 'Tap — player sheet (⚽ Teams to move)', 900),
    ('Roster sheet', 'roster_sheet', 'tc_listed_tip', '#teams team card: 📋 on the league list hover', 'On the league list', 901),
    ('Roster sheet', 'roster_sheet', 'tc_empty',      '#teams team card: empty pitch',               'Nobody here', 902),
    ('Roster sheet', 'roster_sheet', 'tc_folded',     '#teams team card: folded team pitch ({team}, {n})', '▸ {team} pitch · {n}', 903),
    ('Person standing', 'person_standing', 'box_ghost',       'Team card box: ghost',            '👻 ghost', 70),
    ('Person standing', 'person_standing', 'box_last',        'Team card box: last RSVP ({date})', 'R {date}', 71),
    ('Person standing', 'person_standing', 'box_never',       'Team card box: never answered',   'no RSVP', 72),
    ('Person standing', 'person_standing', 'box_dues_free',   'Team card box: no dues (volunteer / injured)', '$0', 73),
    ('Person standing', 'person_standing', 'box_dues_none',   'Team card box: no LA membership', 'no LA', 74),
    ('Person standing', 'person_standing', 'box_dues_owes',   'Team card box: owes ({amount})',  '🔴 {amount}', 75),
    ('Person standing', 'person_standing', 'box_dues_paid',   'Team card box: paid up',          '🟢 paid', 76),
    ('Person standing', 'person_standing', 'box_reg_have',    'Team card box: league form on file ({league})', '✅{league}', 77),
    ('Person standing', 'person_standing', 'box_reg_missing', 'Team card box: no league form ({league})',      '❌{league}', 78)
  ) AS v(cat, kind, tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
