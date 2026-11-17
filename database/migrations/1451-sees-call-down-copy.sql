-- 👁 SEES controls for the call-down (mig 1450: sees yes on a team = a
-- standing call-down). ＋ L1 ⬇ sets it on an APSL man's card, ✕ ends it.
-- The ⭐ CALL-DOWNS group and its chip on #teams retire.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Roster Sheet', v.label, 'roster_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('card_sees_call_down',         'Card — SEES: ＋ call him down to a team (admins, {team})',  '＋ {team} ⬇', 1531),
    ('card_sees_call_down_tip',     'Card — SEES: ＋ call-down tooltip ({team})',               'Call him down to every {team} game (league rule: at most 2 in a squad). One game only = invite from the game.', 1532),
    ('card_sees_end_call_down',     'Card — SEES: end a standing call-down (admins)',           '✕', 1533),
    ('card_sees_end_call_down_tip', 'Card — SEES: end call-down tooltip ({team})',              'Called down to every {team} game. Tap to stop.', 1534)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'roster_sheet' AND t.tier = v.tier);

UPDATE message_templates SET is_active = false
 WHERE (kind = 'roster_sheet' AND tier IN ('board_calldowns_h', 'board_callups_h'))
    OR (kind = 'invite_chip' AND tier IN ('standing', 'standing_tip'));
