-- 890 (2026-10-30) — #cash-flow: January to March.
--
-- Owner: "jan no expenses except coach pay. we have ref fees for youth. project
-- for now $75 per week. same in feb as jan."  January 2027 has 5 weekends and
-- February 4.  "march ... no youth but assume same practice schedule for all so
-- coach pay": March has no planned row, so it is coach pay only.

INSERT INTO cash_flow_planned (ym, label, amount)
SELECT v.ym, v.label, v.amount
  FROM (VALUES ('2027-01', 'Youth referee fees, $75 a week × 5', 375.00),
               ('2027-02', 'Youth referee fees, $75 a week × 4', 300.00)) AS v(ym, label, amount)
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.ym = v.ym AND p.label = v.label);

UPDATE message_templates SET body = 'Ahead: money in is members × {rate} a month, less {fee}% LeagueApps fees (last 12 months); pickup memberships are not projected. Money out is coach pay from the calendar at each coach''s rate, referee fees for home games on the calendar through {through}, and planned items. League fees and other purchases are not projected.'
 WHERE kind = 'cash_flow' AND tier = 'ahead_note';
