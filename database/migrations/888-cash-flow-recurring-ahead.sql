-- 888 (2026-10-30) — #cash-flow: the months ahead carry what recurs.
--
-- Owner: "november projection should not count like seeds but should look ahead
-- on gcal for refs etc and coach pay", "kits are pretty much purchased at this
-- point too".  Money out ahead is invoices already drafted, plus coach pay off
-- the calendar and referee fees off the schedule.  Nothing else projects.

UPDATE message_templates SET body = 'Next {n} months, projected' WHERE kind = 'cash_flow' AND tier = 'card_ahead';
UPDATE message_templates SET body = 'Money in is what LeagueApps paid out after its fees, less refunds, from the 8 soccer programs only. Money out is James''s and the coaches'' invoices, drafts included, by invoice date. It all starts {date}. Running is not a bank balance.'
 WHERE kind = 'cash_flow' AND tier = 'months_note';
UPDATE message_templates SET body = 'Ahead: money in is members × {rate} a month, less {fee}% LeagueApps fees (last 12 months); pickup memberships are not projected. Money out is invoices already drafted, plus coach pay from the calendar at each coach''s rate and referee fees from the schedule and the games each season still expects. One-off purchases like seed and kits are not projected.'
 WHERE kind = 'cash_flow' AND tier = 'ahead_note';
