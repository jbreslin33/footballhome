-- 1222: 🙋 Overdue men can volunteer one evening a week instead of paying
-- (owner 2026-11-10: "lets add for men that they can also volunteer if
-- over due. by picking monday wed fri to help if they are out of work.
-- times are 5pm to 7pm" → "pick one day to help" → "they need to
-- understand they have to be on time and show up each week on that day
-- and that if they can't make it they must let us know ahead of time" →
-- "after they show they are reliable we can start process to actually get
-- them paid").
--
--  * volunteer_shifts: the evenings a section's players can pick (Men:
--    Mon / Wed / Fri 5–7 PM).  Change the days or hours by migration.
--  * volunteer_requests: a player's ONE pick, with the moment he ticked
--    the commitment.  The owner approves first ("You approve first"):
--    approving makes him a 🙋 Volunteer (club_volunteers, mig 704 — $0
--    balance, no notices, not an alternate); until then his dues stand.
--  * fh_volunteer_offer(person): owes dues, isn't already dues-free, and
--    is on a team whose section has shifts → #my shows the picker.
--  * fh_volunteer_shift_label / fh_volunteer_days_text: "Wednesday 5–7 PM"
--    and "Monday, Wednesday or Friday, 5–7 PM" built from the rows.
--  * Copy: kind volunteer_shift (#my card + #payments panel) and
--    payment_notice_volunteer (the line the Men's dues notices carry via
--    the {volunteer} token, empty — and dropped — for anyone without shifts).

BEGIN;

CREATE TABLE IF NOT EXISTS volunteer_shifts (
    id              serial PRIMARY KEY,
    club_id         integer  NOT NULL,
    club_section_id integer  NOT NULL REFERENCES club_sections(id),
    weekday         smallint NOT NULL CHECK (weekday BETWEEN 1 AND 7),   -- ISO: 1 = Monday
    starts_at       time     NOT NULL,
    ends_at         time     NOT NULL CHECK (ends_at > starts_at),
    is_active       boolean  NOT NULL DEFAULT true,
    sort_order      integer  NOT NULL DEFAULT 0,
    UNIQUE (club_id, club_section_id, weekday, starts_at)
);

CREATE TABLE IF NOT EXISTS volunteer_requests (
    id                 serial PRIMARY KEY,
    person_id          integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    shift_id           integer NOT NULL REFERENCES volunteer_shifts(id),
    agreed_at          timestamptz NOT NULL,          -- ticked "on time, every week, tell you ahead"
    status             text NOT NULL DEFAULT 'pending'
                       CHECK (status IN ('pending', 'approved', 'denied', 'withdrawn')),
    created_at         timestamptz NOT NULL DEFAULT now(),
    decided_by_user_id integer,
    decided_at         timestamptz
);
-- One live pick per player (pending or approved).
CREATE UNIQUE INDEX IF NOT EXISTS volunteer_requests_one_live
    ON volunteer_requests (person_id) WHERE status IN ('pending', 'approved');

INSERT INTO volunteer_shifts (club_id, club_section_id, weekday, starts_at, ends_at, sort_order)
SELECT 134, cs.id, d.wd, '17:00', '19:00', d.wd
  FROM club_sections cs
 CROSS JOIN (VALUES (1), (3), (5)) AS d(wd)
 WHERE cs.name = 'Mens'
ON CONFLICT DO NOTHING;

-- "Wednesday 5–7 PM" (both ends PM → one PM; else "11 AM–1 PM").
CREATE OR REPLACE FUNCTION fh_volunteer_hours_text(p_start time, p_end time)
RETURNS text LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE WHEN to_char(p_start, 'AM') = to_char(p_end, 'AM')
                THEN to_char(p_start, 'FMHH12') || CASE WHEN extract(minute FROM p_start) > 0 THEN to_char(p_start, ':MI') ELSE '' END
                     || '–' || to_char(p_end, 'FMHH12') || CASE WHEN extract(minute FROM p_end) > 0 THEN to_char(p_end, ':MI') ELSE '' END
                     || ' ' || to_char(p_end, 'AM')
                ELSE to_char(p_start, 'FMHH12:MI AM') || '–' || to_char(p_end, 'FMHH12:MI AM') END
$$;

CREATE OR REPLACE FUNCTION fh_volunteer_shift_label(p_shift_id integer)
RETURNS text LANGUAGE sql STABLE AS $$
    SELECT to_char(DATE '2024-01-01' + (s.weekday - 1), 'FMDay') || ' ' || fh_volunteer_hours_text(s.starts_at, s.ends_at)
      FROM volunteer_shifts s WHERE s.id = p_shift_id
$$;

-- The sections a player's live teams belong to that have shifts.
CREATE OR REPLACE FUNCTION fh_volunteer_sections(p_person integer)
RETURNS SETOF integer LANGUAGE sql STABLE AS $$
    SELECT DISTINCT t.club_section_id
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id AND t.is_active
     WHERE tp.person_id = p_person AND tp.removed_at IS NULL
       AND EXISTS (SELECT 1 FROM volunteer_shifts s
                    WHERE s.is_active AND s.club_id = t.club_id AND s.club_section_id = t.club_section_id)
$$;

-- "Monday, Wednesday or Friday, 5–7 PM" for the dues notice (NULL = no
-- shifts for him).  Mixed hours list each day with its own hours.
CREATE OR REPLACE FUNCTION fh_volunteer_days_text(p_person integer)
RETURNS text LANGUAGE sql STABLE AS $$
    WITH s AS (
        SELECT DISTINCT ON (vs.weekday, vs.starts_at) vs.*,
               to_char(DATE '2024-01-01' + (vs.weekday - 1), 'FMDay') AS day,
               fh_volunteer_hours_text(vs.starts_at, vs.ends_at) AS hours
          FROM volunteer_shifts vs
         WHERE vs.is_active AND vs.club_section_id IN (SELECT fh_volunteer_sections(p_person))
         ORDER BY vs.weekday, vs.starts_at
    ), a AS (SELECT array_agg(day ORDER BY weekday, starts_at) AS days,
                    array_agg(day || ' ' || hours ORDER BY weekday, starts_at) AS each_one,
                    count(DISTINCT hours) AS n_hours, min(hours) AS hours FROM s)
    SELECT CASE WHEN days IS NULL THEN NULL
                WHEN n_hours = 1 THEN
                     CASE WHEN cardinality(days) = 1 THEN days[1]
                          ELSE array_to_string(days[1:cardinality(days) - 1], ', ') || ' or ' || days[cardinality(days)] END
                     || ', ' || hours
                ELSE CASE WHEN cardinality(each_one) = 1 THEN each_one[1]
                          ELSE array_to_string(each_one[1:cardinality(each_one) - 1], ', ') || ' or ' || each_one[cardinality(each_one)] END
           END
      FROM a
$$;

CREATE OR REPLACE FUNCTION fh_volunteer_offer(p_person integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT COALESCE(fh_dues_balance_usd(p_person), 0) > 0
       AND fh_dues_free_reason(p_person) IS NULL
       AND EXISTS (SELECT fh_volunteer_sections(p_person))
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Payments', v.label, 'volunteer_shift', v.tier, NULL, v.body, v.sort, true, true, false
  FROM (VALUES
    ('#my volunteer card: heading', 'heading', '🙋 Out of work? Volunteer instead', 1),
    ('#my volunteer card: what it is', 'intro',
     'Can''t pay dues right now because you''re out of work? Help the club one evening a week instead. Pick ONE day:', 2),
    ('#my volunteer card: the commitment', 'terms',
     'Picking a day means you''re there on time, every week, on that day. If you can''t make it, you must let us know ahead of time. Once you''ve shown you''re reliable, we can start the process of actually getting you paid for it.', 3),
    ('#my volunteer card: the tick before picking', 'agree',
     'I understand — on time, every week, and I''ll let you know ahead of time if I can''t make it.', 4),
    ('#my volunteer card: tick first', 'agree_first', 'Tick the box above first.', 5),
    ('#my volunteer card: picked, waiting on the club', 'pending',
     'You picked {shift}, every week. The club will confirm — until then your dues still stand.', 6),
    ('#my volunteer card: approved', 'approved',
     'You''re a club volunteer: {shift}, every week. Be there on time, and let us know ahead of time if you can''t make it.', 7),
    ('#my volunteer card: cancel the pick', 'withdraw', 'Cancel my pick', 8),
    ('#payments panel: heading', 'requests_heading', '🙋 Volunteer requests', 10),
    ('#payments panel: approve', 'approve', '✓ Make volunteer', 11),
    ('#payments panel: decline', 'deny', '✗ Decline', 12),
    ('#payments panel: one row', 'request_line', '{name} — {shift} · {owed} owed · picked {when}', 13)
  ) AS v(label, tier, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'volunteer_shift' AND m.tier = v.tier);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Payments', v.label, 'payment_notice_volunteer', v.tier, NULL, v.body, v.sort, true, true, false
  FROM (VALUES
    ('Dues notice volunteer line (email)', 'email',
     'Out of work? You can volunteer one evening a week instead — pick one day ({days}) on your Football Home page: https://footballhome.org/#my. You''d need to be there on time every week on that day and let us know ahead of time if you can''t make it. Once you''ve shown you''re reliable, we can start the process of actually getting you paid.', 1),
    ('Dues notice volunteer line (text)', 'sms',
     'Out of work? Volunteer one evening a week instead — pick one day ({days}) at https://footballhome.org/#my. On time every week, and tell us ahead if you can''t make it; once you''ve shown you''re reliable we can start getting you paid.', 2)
  ) AS v(label, tier, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'payment_notice_volunteer' AND m.tier = v.tier);

-- The six *_selection notices (Men + Women's policy) carry the line; the
-- [[ ]] drops it when {volunteer} is empty (no shifts for that member).
UPDATE message_templates
   SET body = regexp_replace(body, E'\n\nThanks,', E'\n\n[[{volunteer}\n\n]]Thanks,')
 WHERE kind = 'payment_notice_email' AND tier LIKE 'behind\_%\_selection' AND is_active
   AND body NOT LIKE '%{volunteer}%';
UPDATE message_templates
   SET body = body || '[[ {volunteer}]]'
 WHERE kind = 'payment_notice_sms' AND tier LIKE 'behind\_%\_selection' AND is_active
   AND body NOT LIKE '%{volunteer}%';

DO $$ BEGIN
    IF (SELECT count(*) FROM message_templates
         WHERE kind IN ('payment_notice_email', 'payment_notice_sms') AND tier LIKE 'behind\_%\_selection'
           AND is_active AND body LIKE '%{volunteer}%') <> 6 THEN
        RAISE EXCEPTION 'volunteer line did not land on all six selection notices';
    END IF;
END $$;

COMMIT;
