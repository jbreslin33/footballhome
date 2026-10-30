-- 885 (2026-10-30) — #cash-flow: money out is invoices and nothing else.
--
-- Owner, on October showing $20k out: "not possible", "the only out should be
-- from my invoice and coaches invoices".  Budget estimates leave the page, so
-- the months ahead show money in plus any invoice already drafted.

UPDATE message_templates SET body = 'Next {n} months, money in projected' WHERE kind = 'cash_flow' AND tier = 'card_ahead';
UPDATE message_templates SET body = 'Money in is what LeagueApps paid out after its fees, less refunds. Money out is James''s and the coaches'' invoices, drafts included, by invoice date, and nothing else. It all starts {date}, the first invoice carrying the club''s expenses: before that there is no money out on file to compare. Running starts from zero at the top row: it is not a bank balance.'
 WHERE kind = 'cash_flow' AND tier = 'months_note';
UPDATE message_templates SET body = 'Ahead: members × {rate} a month, less {fee}% LeagueApps fees (last 12 months). Pickup memberships are not projected. Money out ahead shows only invoices already drafted.'
 WHERE kind = 'cash_flow' AND tier = 'ahead_note';

DELETE FROM message_templates WHERE kind = 'cash_flow' AND tier = 'untied';
