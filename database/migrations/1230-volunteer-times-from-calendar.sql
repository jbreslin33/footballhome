-- 1230: 🙋 Weekend volunteer times come from the youth calendar (owner
-- 2026-11-10: "dont give time for sunday unless we have a time. for
-- saturday that is prob the time. but it may move too. like since handball
-- is 12pm sat we may need to do youth like 9 to 1030 then men 1030 to 12").
--
--  * volunteer_shifts.starts_at / ends_at may be NULL = "follow the
--    calendar": the label takes the hours of the next youth practice on
--    that weekday (the helped section's teams, earliest start → latest
--    end that day, within 60 days); none on the calendar → just the day
--    ("Sunday").  Saturday and Sunday are NULL now; Mon / Wed / Fri keep
--    the owner's 5–7 PM.
--  * fh_volunteer_shift_hours(shift) is the one place a shift's hours are
--    decided; the label and the notice's day list use it.
--  * "Practice right after" copy no longer names nights or 7 PM — a
--    Saturday with men right after youth fits too.

BEGIN;

ALTER TABLE volunteer_shifts ALTER COLUMN starts_at DROP NOT NULL;
ALTER TABLE volunteer_shifts ALTER COLUMN ends_at   DROP NOT NULL;
ALTER TABLE volunteer_shifts DROP CONSTRAINT IF EXISTS volunteer_shifts_check;
ALTER TABLE volunteer_shifts ADD CONSTRAINT volunteer_shifts_hours_check
    CHECK ((starts_at IS NULL) = (ends_at IS NULL) AND (starts_at IS NULL OR ends_at > starts_at));

UPDATE volunteer_shifts SET starts_at = NULL, ends_at = NULL WHERE weekday IN (6, 7);

-- "10:30 AM–12 PM", from the row or the next youth practice that weekday;
-- NULL when neither has a time.
CREATE OR REPLACE FUNCTION fh_volunteer_shift_hours(p_shift_id integer)
RETURNS text LANGUAGE sql STABLE AS $$
    SELECT COALESCE(
        (SELECT fh_volunteer_hours_text(s.starts_at, s.ends_at) WHERE s.starts_at IS NOT NULL),
        (SELECT fh_volunteer_hours_text(min((ge.starts_at AT TIME ZONE 'America/New_York')::time),
                                        max((ge.ends_at   AT TIME ZONE 'America/New_York')::time))
           FROM fh_events fe
           JOIN gcal_events ge ON ge.id = fe.gcal_event_id
           JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
           JOIN teams t ON t.id = fet.team_id AND t.club_section_id = s.helps_section_id
          WHERE fe.kind = 'practice' AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
            AND extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York') = s.weekday
            AND (ge.starts_at AT TIME ZONE 'America/New_York')::date = (
                SELECT min((ge2.starts_at AT TIME ZONE 'America/New_York')::date)
                  FROM fh_events fe2
                  JOIN gcal_events ge2 ON ge2.id = fe2.gcal_event_id
                  JOIN fh_event_teams fet2 ON fet2.fh_event_id = fe2.id
                  JOIN teams t2 ON t2.id = fet2.team_id AND t2.club_section_id = s.helps_section_id
                 WHERE fe2.kind = 'practice' AND ge2.deleted_at IS NULL AND ge2.status IS DISTINCT FROM 'cancelled'
                   AND ge2.starts_at >= now() AND ge2.starts_at < now() + interval '60 days'
                   AND extract(isodow FROM ge2.starts_at AT TIME ZONE 'America/New_York') = s.weekday)
          HAVING count(*) > 0))
      FROM volunteer_shifts s WHERE s.id = p_shift_id
$$;

CREATE OR REPLACE FUNCTION fh_volunteer_shift_label(p_shift_id integer)
RETURNS text LANGUAGE sql STABLE AS $$
    SELECT to_char(DATE '2024-01-01' + (s.weekday - 1), 'FMDay')
           || COALESCE(' ' || fh_volunteer_shift_hours(s.id), '')
      FROM volunteer_shifts s WHERE s.id = p_shift_id
$$;

-- "Monday, Wednesday or Friday 5–7 PM, Saturday 10:30 AM–12 PM, or Sunday"
CREATE OR REPLACE FUNCTION fh_volunteer_days_text(p_person integer)
RETURNS text LANGUAGE sql STABLE AS $$
    WITH s AS (
        SELECT DISTINCT ON (vs.weekday) vs.weekday,
               to_char(DATE '2024-01-01' + (vs.weekday - 1), 'FMDay') AS day,
               COALESCE(fh_volunteer_shift_hours(vs.id), '') AS hours
          FROM volunteer_shifts vs
         WHERE vs.is_active AND vs.club_section_id IN (SELECT fh_volunteer_sections(p_person))
         ORDER BY vs.weekday, vs.starts_at NULLS LAST
    ), g AS (
        SELECT hours, min(weekday) AS first_day, array_agg(day ORDER BY weekday) AS days FROM s GROUP BY hours
    ), groups AS (
        SELECT first_day,
               CASE WHEN cardinality(days) = 1 THEN days[1]
                    ELSE array_to_string(days[1:cardinality(days) - 1], ', ') || ' or ' || days[cardinality(days)] END
               || CASE WHEN hours <> '' THEN ' ' || hours ELSE '' END AS txt
          FROM g
    ), a AS (SELECT array_agg(txt ORDER BY first_day) AS t FROM groups)
    SELECT CASE WHEN t IS NULL THEN NULL
                WHEN cardinality(t) = 1 THEN t[1]
                ELSE array_to_string(t[1:cardinality(t) - 1], ', ') || ', or ' || t[cardinality(t)] END
      FROM a
$$;

UPDATE message_templates SET body =
  'You must be on time, every week, on the day you pick. If you can''t make it, you must let us know ahead of time. Once the club approves your day, it shows on your Football Home page under 📋 Coach — you''ll RSVP to those practices like any coach. Super convenient: when men''s practice is that day, it''s right after, at the same field — help with the kids and you''re already there, totally on time for practice. Once you''ve shown you''re reliable, we can actually get you paid.'
 WHERE kind = 'volunteer_shift' AND tier = 'terms';
UPDATE message_templates SET body =
  'You''re a club volunteer: {shift}, every week — your practices are on this page under 📋 Coach. Be there on time, and let us know ahead of time if you can''t make it. When men''s practice is that day, it''s right after at the same field — you''re already there, on time.'
 WHERE kind = 'volunteer_shift' AND tier = 'approved';
UPDATE message_templates SET body = replace(body,
  'Super convenient: on men''s practice nights our practice is right after, at the same field — help with the kids 5–7 and you''re already there, totally on time for practice at 7.',
  'Super convenient: when men''s practice is that day, it''s right after, at the same field — help with the kids and you''re already there, totally on time for practice.')
 WHERE kind = 'payment_notice_volunteer' AND tier = 'email';
UPDATE message_templates SET body = replace(body,
  'Super convenient: our practice is right after at the same field — coach the kids 5–7 and you''re on time for 7.',
  'Super convenient: when men''s practice is that day, it''s right after at the same field, so you''re already there and on time.')
 WHERE kind = 'payment_notice_volunteer' AND tier = 'sms';

COMMIT;
