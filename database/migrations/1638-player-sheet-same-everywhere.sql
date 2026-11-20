-- 1638 (2026-11-20) — The ⋯ player sheet is the same wherever it is opened.
--
-- Owner: "we need to make player card the same wherever its clicked from
-- and the functionality to move them teams open la put them as volunteers
-- etc contact them for various reasons need to all be there."
--
-- The sheet now reads the person itself (GET /api/person-sheet): 🔗 Open
-- in LA and 🙋 Volunteer on 👤 Person, each parent's contacts + 📇 CONTACT
-- on 📇 Contact, the team pills + his status on each team on ⚽ Teams — on
-- every screen.  These are its new words.

BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('volunteer_on',           'Player sheet — is a volunteer',                    '🙋 Volunteer since {since} — no dues', 90),
    ('volunteer_off',          'Player sheet — not a volunteer',                   'Not a volunteer — pays dues', 91),
    ('volunteer_make',         'Player sheet — make volunteer button',             '🙋 Make volunteer', 92),
    ('volunteer_end',          'Player sheet — end volunteer button',              '🛑 End volunteer', 93),
    ('volunteer_confirm_make', 'Player sheet — make volunteer, second tap',        'Tap again — volunteer, no dues', 94),
    ('volunteer_confirm_end',  'Player sheet — end volunteer, second tap',         'Tap again — back to paying dues', 95),
    ('volunteer_saved_on',     'Player sheet — made a volunteer',                  'Volunteer — no dues.', 96),
    ('volunteer_saved_off',    'Player sheet — volunteer ended',                   'No longer a volunteer.', 97),
    ('contact_parent',         'Player sheet — a contact who is the parent',       'parent', 98),
    ('contact_title',          'Player sheet — CONTACT button tip',                'Contact {name}', 99),
    ('squad_heading',          'Player sheet — status per team heading',           'Status on each team', 100),
    ('squad_tip',              'Player sheet — status per team picker tip',        'Their status on {team}', 101),
    ('squad_saved',            'Player sheet — status per team saved',             'Team status saved.', 102)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'player_sheet' AND m.tier = v.tier);

COMMIT;
