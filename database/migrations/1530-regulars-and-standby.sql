-- 1530 (2026-11-19) — Men: Regulars and Standby.
--
-- Owner: "what we are really after is to not spam certain guys. so i need
-- like a list of guys that we hit up for practice and games and then a 2nd
-- teir that we hit up if desparate and thus maybe need to add them or just
-- need numbbers at pracitce" → "yes build it like 'regulars' its very
-- milityary and then we can't use reserves lol but maybe something else?"
-- → "or maybe its all internal lists so dont' matter".
--
--   ✅ Regulars (no Team-pill status) — expected, chased, reminded, fined.
--   📞 Standby (squad status standby, men) — sees every game and practice
--      and can answer any time; never in No response, reminders or Remind
--      all, never fined, still billed.  Hit up only when short: the
--      📣 Ask Standby button on the game / event page (your own texting app
--      or Gmail, BCC — nothing is sent by the server).
--   Men's 🏋 Practice Squad and 💤 Inactive fold into Standby (27 rows).
--   ⛔ Not On Roster stays a flag in either tier (mig 1528).
--   Youth keeps Practice Squad / Inactive as they are.
-- Internal words only — players never see their tier.

BEGIN;

INSERT INTO squad_statuses (code, display_name, owes_practice_rsvps, sort_order, is_active, per_team)
SELECT 'standby', 'Standby', false, 4, true, true
 WHERE NOT EXISTS (SELECT 1 FROM squad_statuses WHERE code = 'standby');

INSERT INTO squad_status_section_rules (club_section_id, squad_status_id, owes_practice_rsvps, sees_games)
SELECT cs.id, ss.id, false, true FROM club_sections cs, squad_statuses ss
 WHERE cs.code = 'M' AND ss.code = 'standby'
ON CONFLICT (club_section_id, squad_status_id) DO UPDATE SET owes_practice_rsvps = false, sees_games = true;

-- Men's Practice Squad + Inactive → Standby (trigger opens their games).
UPDATE team_persons tp
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'standby')
  FROM teams t JOIN club_sections cs ON cs.id = t.club_section_id AND cs.code = 'M',
       squad_statuses ss
 WHERE t.id = tp.team_id AND ss.id = tp.squad_status_id
   AND ss.code IN ('practice_squad', 'inactive') AND tp.removed_at IS NULL;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.cat, v.label, v.kind, v.tier, v.body, v.ord, true
  FROM (VALUES
    ('Roster sheet', 'roster_sheet', 'team_status_regular', 'Men''s Team pill: Regular (expected, chased)', '✅ Regular', 910),
    ('Roster sheet', 'roster_sheet', 'team_status_standby', 'Men''s Team pill: Standby (hit up only when short)', '📞 Standby', 911),
    ('Roster sheet', 'roster_sheet', 'board_regulars_h',    'Men''s Team view / team card: Regulars heading', 'REGULARS', 912),
    ('Roster sheet', 'roster_sheet', 'board_standby_h',     'Men''s Team view / team card: Standby heading', '📞 STANDBY', 913),
    ('Event Center', 'event_center', 'sec_standby',         'Game / event card: Standby fold + graphic row', '📞 Standby', 911),
    ('Event Center', 'event_center', 'ask_standby',         'Game / event card: ask Standby when short ({n})', '📣 Ask Standby ({n})', 912),
    ('Event Center', 'event_center', 'ask_standby_body',    'Ask Standby message ({event}, {where})',
     'We''re short for {event}[[ at {where}]]. Can you make it? Answer on footballhome.org or reply here.', 913),
    ('Event Center', 'event_center', 'ask_standby_subject', 'Ask Standby email subject ({event})', 'Can you make it? {event}', 914),
    ('Person standing', 'person_standing', 'roster_standby', 'Roster line: Standby on a team ({team})', '{team} Standby', 55)
  ) AS v(cat, kind, tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);

COMMIT;
