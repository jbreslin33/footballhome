-- 1519 (2026-11-19) — League registration on the player's roster line.
--
-- Follows mig 1518 (league_registrations).  The roster line every money
-- board and the ⋯ player sheet's ⚽ Teams tab carry (PersonStanding,
-- /api/payments/standing) gets one pill per league registration:
--   ✅ CASA reg 10/23   — filled the form; the commissioner can add him
--   ❌ No CASA reg      — on a team in that league's section, never filled
--                         it: a call-up needs a new registration first.
-- ❌ only for leagues marked shows_missing (CASA: any men's player may be
-- called up to Liga 1).  APSL shows ✅ from its list, never ❌ — a Liga 1
-- man doesn't owe the APSL form.

BEGIN;

ALTER TABLE league_registration_forms
  ADD COLUMN IF NOT EXISTS shows_missing boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN league_registration_forms.shows_missing IS
  'mig 1519: true = a player on any team of this league''s section without a league_registrations row shows ❌ No <league> reg on his roster line (PersonStanding).';
UPDATE league_registration_forms SET shows_missing = true WHERE league_label = 'CASA';

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Person standing', v.label, 'person_standing', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('reg_have',        'Roster line: league registration on file ({league}, {date})',
     '✅ {league} reg[[ {date}]]', 56),
    ('reg_have_tip',    'Roster line: league registration on file — hover',
     'Filled the {league} registration form[[ on {date}]]. The commissioner can add them to the list without a new registration.', 57),
    ('reg_list_tip',    'Roster line: registration known from the league list — hover',
     'On the {league} list[[ (seen {date})]], so registered with {league} this season.', 58),
    ('reg_missing',     'Roster line: no league registration ({league})',
     '❌ No {league} reg', 59),
    ('reg_missing_tip', 'Roster line: no league registration — hover',
     'Never filled the {league} registration form. A call-up needs a new {league} registration first.', 60)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'person_standing' AND m.tier = v.tier);

COMMIT;
