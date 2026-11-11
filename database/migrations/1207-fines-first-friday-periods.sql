-- 1207: fines run on the tuition schedule — first Friday to first Friday.
--
-- Owner 2026-11-09: "this should be from tuition date to tuition date
-- 'first fridays'" … "switch the fines pages to first friday periods. yes
-- it should also be same schedule as tuition".
--
-- A fines period is named for the month it starts in and runs from that
-- month's first Friday (00:00 club time) to the next month's first Friday:
-- "Oct" = Fri 2026-10-02 … Thu 2026-11-05.  Its fines still post with the
-- next month's dues on that next first Friday, so the bill boxes, posting
-- match and copy-for-LA button keep their meaning; only which period an
-- event lands in moves (Nov 1–5 now belong to Oct, billed 11/6).
--
-- PersonFines (#payments boxes, #my, /api/fines for #fines) and the
-- waiver start (fh_fine_unbilled_since) read these helpers.

BEGIN;

-- The first Friday of the month holding club-time day p_day.
CREATE OR REPLACE FUNCTION fh_first_friday(p_day date) RETURNS date
LANGUAGE sql IMMUTABLE AS $$
    SELECT date_trunc('month', p_day)::date
           + ((5 - EXTRACT(DOW FROM date_trunc('month', p_day))::int + 7) % 7)
$$;
COMMENT ON FUNCTION fh_first_friday(date) IS
    'mig 1207: first Friday of the month holding p_day (a club-time calendar date).';

-- The month (its 1st) naming the fines period that holds p_at.
CREATE OR REPLACE FUNCTION fh_fine_period_month(p_at timestamptz) RETURNS date
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN d < fh_first_friday(d)
                THEN (date_trunc('month', d) - interval '1 month')::date
                ELSE date_trunc('month', d)::date END
      FROM (SELECT (p_at AT TIME ZONE 'America/New_York')::date AS d) x
$$;
COMMENT ON FUNCTION fh_fine_period_month(timestamptz) IS
    'mig 1207: the month naming the fines period holding p_at — periods run first Friday → next first Friday (the tuition dates).';

-- When the fines period named by month p_month starts (first Friday 00:00 club time).
CREATE OR REPLACE FUNCTION fh_fine_period_start_of(p_month date) RETURNS timestamptz
LANGUAGE sql STABLE AS $$
    SELECT fh_first_friday(p_month)::timestamp AT TIME ZONE 'America/New_York'
$$;
COMMENT ON FUNCTION fh_fine_period_start_of(date) IS
    'mig 1207: start of the fines period named by month p_month — its first Friday, 00:00 club time.';

-- Waivers open from the first period not yet billed: the one running now
-- (the previous period was billed on this period's first Friday).
CREATE OR REPLACE FUNCTION fh_fine_unbilled_since(p_at timestamptz DEFAULT now()) RETURNS timestamptz
LANGUAGE sql STABLE AS $$
    SELECT fh_fine_period_start_of(fh_fine_period_month(p_at))
$$;
COMMENT ON FUNCTION fh_fine_unbilled_since(timestamptz) IS
    'mig 997→1207: start of the fines period holding p_at (first Friday) — the first fines not yet on a bill.';

-- Wording that said "month" now says the tuition dates.
UPDATE message_templates
   SET body = 'Worked out from each player''s RSVPs and attendance against the rules below — nothing is typed in; a corrected RSVP or attendance mark corrects the fine. Fines run first Friday to first Friday, like tuition: each period''s fines go on LeagueApps with the next tuition on the first Friday it ends.'
 WHERE kind = 'fines' AND tier = 'subtitle';
UPDATE message_templates
   SET body = 'Men''s fines — missed RSVPs and no-shows by tuition period (first Friday to first Friday), who owes what, what is on LeagueApps'
 WHERE kind = 'fines' AND tier = 'tile_sub';
UPDATE message_templates
   SET body = 'Inactive players are billed the usual dues only. Fines from the first unbilled period (first Friday) until they are back are $0; they start fresh when they return. Undo a waiver by migration (fine_waivers.reversed_at).'
 WHERE kind = 'fines' AND tier = 'waived_note';
UPDATE message_templates
   SET body = 'Fines run first Friday to first Friday, like tuition, and are added to your next tuition on the first Friday. Days you were blocked from RSVPing by overdue tuition are not fined.'
 WHERE kind = 'my_fines' AND tier = 'note';
UPDATE message_templates
   SET body = '{month} ({from}–{to}) total {amount}', label = 'Period total ({month} {from} {to} {amount})'
 WHERE kind = 'my_fines' AND tier = 'month_total';

-- Period dates next to a period's name ({month} {from}–{to}).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Fines', 'Period name with its dates ({month} {from} {to})', 'fines', 'period_range', NULL,
       '{month} {from}–{to}', 798, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'fines' AND tier = 'period_range');

COMMIT;
