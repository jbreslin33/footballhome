-- 1229: 🙋 Weekend youth practice is a volunteer day too (owner
-- 2026-11-10: "we should add the weekend practice for youth. like right
-- now its on saturdays but will be on sunday soon probably. or maybe stay
-- saturday … so mon, wed, fri, sat, sun … if they pick sunday and we
-- approve then when we have a sunday event it will show for them to rsvp
-- to").
--
--  * Saturday and Sunday shifts, 10:30 AM–12 PM (Saturday's youth practice
--    today; Sunday has none yet, so it takes the same hours until it has
--    its own — change by migration).  Approving one adds that day to his
--    coach schedule (mig 1224), so any youth practice on that day shows on
--    his #my under 📋 Coach whenever it exists.
--  * fh_volunteer_hours_text drops ":00" ("10:30 AM–12 PM");
--    fh_volunteer_days_text groups days by hours: "Monday, Wednesday or
--    Friday 5–7 PM, or Saturday or Sunday 10:30 AM–12 PM".
--  * "one evening a week" → "one day a week" in the copy.

BEGIN;

INSERT INTO volunteer_shifts (club_id, club_section_id, helps_section_id, weekday, starts_at, ends_at, sort_order)
SELECT 134, men.id, boys.id, d.wd, '10:30', '12:00', d.wd
  FROM club_sections men, club_sections boys
 CROSS JOIN (VALUES (6), (7)) AS d(wd)
 WHERE men.name = 'Mens' AND boys.name = 'Boys'
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_volunteer_hours_text(p_start time, p_end time)
RETURNS text LANGUAGE sql IMMUTABLE AS $$
    WITH f AS (SELECT to_char(p_start, 'FMHH12') || CASE WHEN extract(minute FROM p_start) > 0 THEN to_char(p_start, ':MI') ELSE '' END AS s,
                      to_char(p_end,   'FMHH12') || CASE WHEN extract(minute FROM p_end)   > 0 THEN to_char(p_end,   ':MI') ELSE '' END AS e)
    SELECT CASE WHEN to_char(p_start, 'AM') = to_char(p_end, 'AM')
                THEN s || '–' || e || ' ' || to_char(p_end, 'AM')
                ELSE s || ' ' || to_char(p_start, 'AM') || '–' || e || ' ' || to_char(p_end, 'AM') END
      FROM f
$$;

-- "Monday, Wednesday or Friday 5–7 PM, or Saturday or Sunday 10:30 AM–12 PM"
CREATE OR REPLACE FUNCTION fh_volunteer_days_text(p_person integer)
RETURNS text LANGUAGE sql STABLE AS $$
    WITH s AS (
        SELECT DISTINCT ON (vs.weekday, vs.starts_at) vs.weekday, vs.starts_at,
               to_char(DATE '2024-01-01' + (vs.weekday - 1), 'FMDay') AS day,
               fh_volunteer_hours_text(vs.starts_at, vs.ends_at) AS hours
          FROM volunteer_shifts vs
         WHERE vs.is_active AND vs.club_section_id IN (SELECT fh_volunteer_sections(p_person))
         ORDER BY vs.weekday, vs.starts_at
    ), g AS (
        SELECT hours, min(weekday) AS first_day, array_agg(day ORDER BY weekday) AS days FROM s GROUP BY hours
    ), groups AS (
        SELECT first_day,
               CASE WHEN cardinality(days) = 1 THEN days[1]
                    ELSE array_to_string(days[1:cardinality(days) - 1], ', ') || ' or ' || days[cardinality(days)] END
               || ' ' || hours AS txt
          FROM g
    ), a AS (SELECT array_agg(txt ORDER BY first_day) AS t FROM groups)
    SELECT CASE WHEN t IS NULL THEN NULL
                WHEN cardinality(t) = 1 THEN t[1]
                ELSE array_to_string(t[1:cardinality(t) - 1], ', ') || ', or ' || t[cardinality(t)] END
      FROM a
$$;

UPDATE message_templates SET body = replace(body, 'one evening a week', 'one day a week')
 WHERE kind IN ('volunteer_shift', 'payment_notice_volunteer') AND body LIKE '%one evening a week%';
-- The grouped list reads better as its own sentence after the link.
UPDATE message_templates SET body = replace(body,
         'You can volunteer one day a week instead — pick one day ({days}) on your Football Home page: https://footballhome.org/#my.',
         'You can volunteer one day a week instead. Pick your day on your Football Home page (https://footballhome.org/#my): {days}.')
 WHERE kind = 'payment_notice_volunteer' AND tier = 'email';
UPDATE message_templates SET body = replace(body,
         'Volunteer one day a week instead — pick one day ({days}) at https://footballhome.org/#my.',
         'Volunteer one day a week instead. Pick your day at https://footballhome.org/#my: {days}.')
 WHERE kind = 'payment_notice_volunteer' AND tier = 'sms';

COMMIT;
