-- 661 (2026-10-23) — Game Center: a player who can't play yet is
-- impossible to miss, and the fix is one tap.
-- Owner: "we need a warning system on game center that a player is not on
-- roster or in the case of call downs that there are too many call downs.
-- and a remedy which we have i think with new contact system. but we
-- should telegraph the remedy and put that player in red like the whole
-- card should be flashing red".
--
-- Who: the registration gaps (fh_event_registration_gaps, migs 638/645) —
-- Going and not on the league's list / roster, or a call-down once both
-- call-down squad spots are taken.  Their card pulses red with a banner
-- saying why and a Fix button that opens the contact sheet on the
-- registration form (mig 654).  Submitted-and-waiting is amber, steady.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, 'reg_warning', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('not_on_list',   'Card banner — not on the league list ({league})',            '⛔ NOT ON THE {league} ROSTER — can''t play until registered', 990),
    ('not_on_roster', 'Card banner — not on the official roster ({status})',        '⛔ NOT ON THE OFFICIAL ROSTER ({status}) — can''t play until registered', 991),
    ('calldown',      'Card banner — call-down spots full ({used}, {max}, {league})', '⛔ CALL-DOWN SPOTS FULL ({used}/{max}) — needs {league} registration to play', 992),
    ('fix',           'Card — fix button',                                          '🛠 Fix: send the registration form →', 993),
    ('calldown_alt',  'Card — the other fix for a call-down',                       'or take another call-down out of the squad', 994),
    ('waiting',       'Card banner — submitted, waiting on the league ({league})',  '⏳ Submitted — waiting on {league}', 995),
    ('strip_title',   'Strip title — how many can''t play yet ({n})',              '⛔ {n} Going can''t play yet — tap a name to jump to their card', 996),
    ('strip_waiting', 'Strip — submitted and waiting ({n})',                        '⏳ {n} submitted, waiting on the league', 997)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'reg_warning' AND m.tier = v.t);
