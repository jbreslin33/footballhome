-- 967 (2026-11-03) — referee fees for September's games tied to the invoice
-- line that paid them, so #finances stops projecting them as still owed.
--
-- Invoice 2026.19 line 34 "APSL, Liga 1 x2, u8,u10,u12" = $655 predates the
-- per-game ticks (mig 490): APSL 9/13 $310 + Liga 1 9/13, 9/20 2 × $130 +
-- U8/U10/U12 9/19 $25 + $25 + $35 = $655 exactly.  Liga 1's 9/20 away game
-- only started projecting when mig 965 made Liga 1 refs every game.
-- Owner 2026-11-03: "we can pull out the duplicate payments … same with refs".
INSERT INTO ref_fee_payments (policy_id, invoice_line_id, fh_event_id, league_fixture_id, game_on, opponent, amount_usd)
SELECT v.pol, 34, v.ev, v.fx, v.d::date, v.opp, v.amt
  FROM (VALUES
    (1, NULL::bigint, 29008, '2026-09-13', 'Feelsgood FC',              310.00),
    (2, NULL::bigint, 9,     '2026-09-13', 'Philadelphia Sierra Stars', 130.00),
    (2, NULL::bigint, 14,    '2026-09-20', 'Oaklyn United FC II',       130.00),
    (3, 56457688,     NULL::int, '2026-09-19', 'Torresdale',            25.00),
    (4, 56457689,     NULL::int, '2026-09-19', 'Torresdale',            25.00),
    (5, 56457690,     NULL::int, '2026-09-19', 'East Falls',            35.00)
  ) AS v(pol, ev, fx, d, opp, amt)
 WHERE EXISTS (SELECT 1 FROM invoice_lines WHERE id = 34 AND amount = 655.00)
   AND NOT EXISTS (SELECT 1 FROM ref_fee_payments r WHERE r.fh_event_id = v.ev OR r.league_fixture_id = v.fx);
