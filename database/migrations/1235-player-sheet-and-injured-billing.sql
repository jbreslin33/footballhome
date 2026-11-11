-- 1235 (2026-11-11) — One player sheet; injured players billed at the owner's call.
--
-- Owner 2026-11-11: "we need a more consistent interface to player cards on
-- all screens … one button to launch actions on that player" / "it needs to
-- be consistent across screens with consistent sections by pill or tab" /
-- "this could also replace going into the player screen".  Every player
-- card gets ONE ⋯ button → the same sheet, same tabs in the same order on
-- every screen (frontend/js/components/player-sheet.js).  First screen:
-- #payments.  The words below are the sheet's (kind player_sheet).
--
-- And: "injured players on payments screen can just be put in 2 sections
-- short and long for injury and then during billing time i can decide to
-- bill them or not" → "yes drop the auto $0".  Mig 715 made a Long-term
-- injury zero the balance; now no health status waives dues — #payments
-- shows 🩹 Short-term / 🩹 Long-term sections with the real balance.
-- fh_dues_free_reason stays (volunteers, mig 704); flipping waives_dues back
-- on for a status restores the old behaviour.

UPDATE health_statuses SET waives_dues = false WHERE waives_dues;
COMMENT ON COLUMN health_statuses.waives_dues IS
    'mig 715: an injury of this kind covering now means no dues. All false since mig 1235 — #payments shows injured players in their own sections and the owner decides at billing time.';

UPDATE message_templates
   SET body = 'Injured — what they owe is shown as usual; decide at billing time whether to bill this month.', updated_at = now()
 WHERE kind = 'payments_overview' AND tier = 'injured_note';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('button_title',   'Player sheet — ⋯ button tooltip',            'Everything for this player', 1),
    ('close',          'Player sheet — close button tooltip',        'Close (Esc)', 2),
    ('tab_person',     'Player sheet — tab: person',                 '👤 Person', 10),
    ('tab_contact',    'Player sheet — tab: contact',                '📇 Contact', 11),
    ('tab_teams',      'Player sheet — tab: teams',                  '⚽ Teams', 12),
    ('tab_health',     'Player sheet — tab: health',                 '🩹 Health', 13),
    ('tab_money',      'Player sheet — tab: money',                  '💳 Money', 14),
    ('tab_fines',      'Player sheet — tab: fines',                  '⚖️ Fines', 15),
    ('tab_activity',   'Player sheet — tab: activity',               '📅 Activity', 16),
    ('profile_button', 'Player sheet — open the full profile',       '👤 Full profile', 20),
    ('empty_contact',  'Player sheet — no email or phone',           'No email or phone on file.', 30),
    ('empty_teams',    'Player sheet — on no team',                  'Not on a team.', 31),
    ('empty_money',    'Player sheet — no dues data',                'No dues on record.', 32),
    ('empty_fines',    'Player sheet — no fines',                    'No fines.', 33),
    ('empty_activity', 'Player sheet — no RSVP / attendance',        'No RSVP or attendance on record.', 34),
    ('health_saved',   'Player sheet — health saved toast',          'Health saved.', 40),
    ('dispute_banner', 'Player sheet — card banner, pending disputes ({count})', '⚖️ {count} fine dispute(s) waiting — tap to settle', 50),
    ('injured_section_note', 'Tuition — note under each injury section', 'Billed as usual unless you skip them — you decide at billing time.', 60)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'player_sheet' AND t.tier = v.tier);
