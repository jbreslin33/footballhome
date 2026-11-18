-- 1461 (2026-11-18) — 🙋 Volunteer by youth-practice SLOTS, 2 hours a week,
-- monthly dues waiver.  Owner 11/18, talking it through:
--   "3 options. do it by whole block that day, allow for picking from each
--    slot on gcal. allow for the player to select custom hours. we could ask
--    for a min num hours" → "i like your idea of slots" → "monthly waiver,
--    weekday slots only, build it" → back balance "stays owed", missed week
--    = "whole month billed" → "they def have to tell us ahead of time … we
--    need to stress they should not miss but understand life happens" →
--    one told-ahead miss a month, "yes".
--
-- The rules (volunteer_policies, one row per section, history kept):
--   * A player picks youth-practice SLOTS off the calendar (weekdays only),
--     a weekly commitment: the picked slots must add up to at least
--     min_weekly_minutes (Men: 120).  "Whole day" = every slot that day.
--   * The owner approves (as before).  Approval makes him an assistant
--     coach for exactly those slots (coach_schedule_slots below) — NOT a
--     club_volunteers row any more: his back balance stays owed.
--   * While approved he stays eligible to play and is never a dues
--     alternate (fh_dues_blocks_eligibility / fh_dues_alternate below).
--   * Each month's dues are waived when every week of the month is met:
--     attended minutes (the coach's attendance mark on his slot events)
--     reach the minimum, or every slot that week if cancellations leave
--     less.  ONE told-ahead miss a month is OK (✗ on the slot before it
--     starts, or marked excused).  A no-show, or a second miss, bills the
--     month and flags him on #payments.  Using the one miss
--     review_after_months months running flags him for review too.
--     Worked out in C++ (VolunteerLedger), shown on #payments + his card.
--   * Nothing ends a volunteer automatically — the owner does (🛑 End).
BEGIN;

CREATE TABLE IF NOT EXISTS volunteer_policies (
    id                           serial PRIMARY KEY,
    club_id                      integer  NOT NULL,
    club_section_id              integer  NOT NULL REFERENCES club_sections(id),
    min_weekly_minutes           integer  NOT NULL CHECK (min_weekly_minutes > 0),
    told_ahead_misses_per_month  integer  NOT NULL DEFAULT 1 CHECK (told_ahead_misses_per_month >= 0),
    review_after_months          integer  NOT NULL DEFAULT 3 CHECK (review_after_months > 0),
    slot_isodows                 smallint[] NOT NULL DEFAULT '{1,2,3,4,5}',
    effective_from               date     NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (club_id, club_section_id, effective_from)
);
COMMENT ON TABLE volunteer_policies IS
  'mig 1461: volunteer rules per section — weekly minutes, told-ahead misses a month, months of using the miss before review, which weekdays offer slots. Newest effective_from on/before the day wins; insert a row to change.';

INSERT INTO volunteer_policies (club_id, club_section_id, min_weekly_minutes, told_ahead_misses_per_month, review_after_months, slot_isodows, effective_from)
SELECT 134, cs.id, 120, 1, 3, '{1,2,3,4,5}', DATE '2026-11-18'
  FROM club_sections cs WHERE cs.name = 'Mens'
ON CONFLICT DO NOTHING;

-- A request now holds slots; shift_id stays for the old one-evening picks.
ALTER TABLE volunteer_requests ALTER COLUMN shift_id DROP NOT NULL;
ALTER TABLE volunteer_requests ADD COLUMN IF NOT EXISTS helps_section_id integer REFERENCES club_sections(id);
ALTER TABLE volunteer_requests ADD COLUMN IF NOT EXISTS ended_at timestamptz;
ALTER TABLE volunteer_requests DROP CONSTRAINT IF EXISTS volunteer_requests_status_check;
ALTER TABLE volunteer_requests ADD CONSTRAINT volunteer_requests_status_check
    CHECK (status IN ('pending', 'approved', 'denied', 'withdrawn', 'ended'));

CREATE TABLE IF NOT EXISTS volunteer_request_slots (
    request_id integer  NOT NULL REFERENCES volunteer_requests(id) ON DELETE CASCADE,
    isodow     smallint NOT NULL CHECK (isodow BETWEEN 1 AND 7),
    starts_at  time     NOT NULL,          -- local (America/New_York) start of the practice slot
    minutes    integer  NOT NULL CHECK (minutes > 0),
    teams      text,                       -- "U9, U10" when picked (display only)
    PRIMARY KEY (request_id, isodow, starts_at)
);
COMMENT ON TABLE volunteer_request_slots IS
  'mig 1461: the weekly youth-practice slots a volunteer picked (weekday + local start). His events = the helped section''s practices on those slots.';

-- Coach schedule by slot: a schedule with slot rows sees only practices on
-- those (weekday, local start); without slot rows it is days only (mig 955).
CREATE TABLE IF NOT EXISTS coach_schedule_slots (
    coach_schedule_id integer  NOT NULL REFERENCES coach_schedules(id) ON DELETE CASCADE,
    isodow            smallint NOT NULL CHECK (isodow BETWEEN 1 AND 7),
    starts_at         time     NOT NULL,
    PRIMARY KEY (coach_schedule_id, isodow, starts_at)
);

CREATE OR REPLACE FUNCTION fh_coach_off_schedule(p_person_id integer, p_team_id integer, p_fh_event_id bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT EXISTS (
    SELECT 1
      FROM coach_schedules s
      JOIN coaches c ON c.id = s.coach_id AND c.person_id = p_person_id
      JOIN teams t ON t.id = p_team_id AND t.club_section_id = s.club_section_id
      JOIN fh_events fe ON fe.id = p_fh_event_id
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE ge.starts_at >= s.starts_at
       AND CASE WHEN fe.kind = 'practice'
                THEN NOT EXISTS (SELECT 1 FROM coach_schedule_days d
                                  WHERE d.coach_schedule_id = s.id
                                    AND d.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int)
                  -- mig 1461: a volunteer's slots — only practices starting on one of them
                  OR (EXISTS (SELECT 1 FROM coach_schedule_slots x WHERE x.coach_schedule_id = s.id)
                      AND NOT EXISTS (SELECT 1 FROM coach_schedule_slots x
                                       WHERE x.coach_schedule_id = s.id
                                         AND x.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int
                                         AND x.starts_at = (ge.starts_at AT TIME ZONE 'America/New_York')::time))
                ELSE s.practices_only END)   -- mig 1224: a volunteer's schedule is practices only
$function$;

-- The policy in force for the sections a player volunteers from.
CREATE OR REPLACE FUNCTION fh_volunteer_policy(p_person integer, p_on date DEFAULT CURRENT_DATE)
RETURNS volunteer_policies LANGUAGE sql STABLE AS $$
    SELECT vp.* FROM volunteer_policies vp
     WHERE vp.club_section_id IN (SELECT fh_volunteer_sections(p_person))
       AND vp.effective_from <= p_on
     ORDER BY vp.effective_from DESC, vp.id DESC
     LIMIT 1
$$;

-- The slots he can pick: the helped section's practices on the calendar in
-- the next 28 days on the policy's weekdays, one row per (weekday, local
-- start) — length = the longest practice starting then, teams listed.
CREATE OR REPLACE FUNCTION fh_volunteer_slot_options(p_person integer)
RETURNS TABLE (helps_section_id integer, isodow smallint, starts_at time, minutes integer, teams text)
LANGUAGE sql STABLE AS $$
    WITH pol AS (SELECT * FROM fh_volunteer_policy(p_person)),
    sec AS (SELECT DISTINCT vs.helps_section_id
              FROM volunteer_shifts vs
             WHERE vs.is_active AND vs.helps_section_id IS NOT NULL
               AND vs.club_section_id IN (SELECT fh_volunteer_sections(p_person))),
    ev AS (
        SELECT sec.helps_section_id,
               extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::smallint AS dow,
               (ge.starts_at AT TIME ZONE 'America/New_York')::time AS st,
               round(extract(epoch FROM ge.ends_at - ge.starts_at) / 60)::int AS mins,
               t.name AS team
          FROM sec
          JOIN teams t ON t.club_section_id = sec.helps_section_id AND t.is_active
          JOIN fh_event_teams fet ON fet.team_id = t.id
          JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'practice'
          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
         WHERE ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
           AND ge.starts_at >= now() AND ge.starts_at < now() + interval '28 days'
           AND ge.ends_at > ge.starts_at
    )
    SELECT ev.helps_section_id, ev.dow, ev.st, max(ev.mins),
           string_agg(DISTINCT ev.team, ', ')
      FROM ev, pol
     WHERE ev.dow = ANY (pol.slot_isodows)
     GROUP BY ev.helps_section_id, ev.dow, ev.st
     ORDER BY ev.dow, ev.st
$$;

-- His slot practices between two moments, one row per occurrence (date +
-- slot): several practices on one slot count once; attended if any is
-- marked present/late, told ahead if he answered ✗ before it started or a
-- coach marked him excused.
CREATE OR REPLACE FUNCTION fh_volunteer_occurrences(p_request integer, p_from timestamptz, p_to timestamptz)
RETURNS TABLE (day date, isodow smallint, starts_at time, minutes integer, first_start timestamptz,
               attended boolean, absent boolean, told_ahead boolean, marked boolean)
LANGUAGE sql STABLE AS $$
    SELECT (ge.starts_at AT TIME ZONE 'America/New_York')::date,
           s.isodow, s.starts_at, max(s.minutes),
           min(ge.starts_at),
           bool_or(att.status IN ('present', 'late')),
           bool_or(att.status = 'absent'),
           bool_or(att.status = 'excused' OR (rv.response = 'no' AND rv.responded_at < ge.starts_at)),
           bool_or(att.status IS NOT NULL)
      FROM volunteer_requests r
      JOIN volunteer_request_slots s ON s.request_id = r.id
      JOIN teams t ON t.club_section_id = r.helps_section_id AND t.is_active
      JOIN fh_event_teams fet ON fet.team_id = t.id
      JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'practice'
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                         AND ge.starts_at >= p_from AND ge.starts_at < p_to
                         AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
                         AND extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::smallint = s.isodow
                         AND (ge.starts_at AT TIME ZONE 'America/New_York')::time = s.starts_at
      LEFT JOIN fh_event_attendance att ON att.fh_event_id = fe.id AND att.person_id = r.person_id
      LEFT JOIN fh_event_rsvps rv ON rv.fh_event_id = fe.id AND rv.person_id = r.person_id
     WHERE r.id = p_request
     GROUP BY 1, s.isodow, s.starts_at
     ORDER BY 1, s.starts_at
$$;

-- While approved: eligible to play and never a dues alternate (owner: back
-- balance "stays owed" — he pays it off — but volunteering keeps him on).
-- Inline EXISTS, not a function call (mig 1458: nested calls ~0.7 ms each).
CREATE OR REPLACE FUNCTION fh_dues_blocks_eligibility(p_person_id integer, p_club_id integer DEFAULT 134, p_on date DEFAULT CURRENT_DATE)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT EXISTS (
    SELECT 1
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id
     CROSS JOIN LATERAL (
           -- = fh_dues_policy_blocks(p_club_id, t.club_section_id, p_on)
           SELECT dp.blocks_eligibility
             FROM dues_policies dp
            WHERE dp.club_id = p_club_id
              AND (dp.club_section_id IS NULL OR dp.club_section_id = t.club_section_id)
              AND dp.effective_from <= p_on
            ORDER BY (dp.club_section_id IS NOT NULL) DESC, dp.effective_from DESC
            LIMIT 1) pol
     WHERE tp.person_id = p_person_id
       AND tp.removed_at IS NULL
       AND t.club_id = p_club_id
       AND t.club_section_id IS NOT NULL
       AND pol.blocks_eligibility)
  AND NOT EXISTS (SELECT 1 FROM volunteer_requests vr                 -- mig 1461
                   WHERE vr.person_id = p_person_id AND vr.status = 'approved'
                     AND vr.decided_at IS NOT NULL
                     AND (vr.decided_at AT TIME ZONE 'America/New_York')::date <= p_on)
$function$;

CREATE OR REPLACE FUNCTION fh_dues_alternate(p_person_id integer, p_club_id integer DEFAULT 134)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT COALESCE(fh_dues_balance_usd(p_person_id), 0) > 0
     AND fh_dues_selection_policy(p_person_id, p_club_id)
     AND NOT EXISTS (SELECT 1 FROM volunteer_requests vr               -- mig 1461
                      WHERE vr.person_id = p_person_id AND vr.status = 'approved')
$function$;

-- ── Words (kind volunteer_shift) ─────────────────────────────────────────
UPDATE message_templates SET body = '🙋 Behind on dues? Volunteer instead', updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'heading';
UPDATE message_templates SET body =
  'Help coach the kids {min} a week and that month''s dues ({dues}) are waived. Pick youth practice slots below — they must add up to at least {min}. Tap a day to take all of it. What you already owe stays owed — pay it off when you can.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'intro';
UPDATE message_templates SET body =
  'Don''t miss — the kids and coaches are counting on you. We know life happens: if you truly can''t make it, tap ✗ on that slot before it starts. One told-ahead miss a month is OK. A no-show, or a second miss in the month, means that month''s dues are billed. Your slots show on your calendar like any coach''s practice.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'terms';
UPDATE message_templates SET body =
  'I understand — I''ll be there on time every week, and if I truly can''t make it I''ll tap ✗ before it starts.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'agree';
UPDATE message_templates SET body =
  'You picked {shift} — {total} a week. Once the club approves, the slots show on your calendar. Until then your dues stand.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'pending';
UPDATE message_templates SET body =
  'You''re a club volunteer: {shift} — {total} a week. Make your {min} every week and that month''s dues are waived.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'approved';
UPDATE message_templates SET body = '{name} — {shift} ({total}/wk) · {owed} owed · picked {when}', updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'request_line';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Payments', v.label, 'volunteer_shift', v.tier, NULL, v.body, v.sort, true, true, false
  FROM (VALUES
    ('Volunteer card: whole day button',           'whole_day',     'Whole day',                                20),
    ('Volunteer card: running total',              'total',         '{total} of {min} a week',                  21),
    ('Volunteer card: total too low',              'total_short',   'Pick at least {min} a week.',              22),
    ('Volunteer card: send the pick',              'submit',        'Send my slots to the club',                23),
    ('Volunteer card: no slots on the calendar',   'no_slots',      'No youth practice slots on the calendar right now — check back soon.', 24),
    ('Volunteer card: this month heading',         'month_heading', 'This month',                               25),
    ('Volunteer card / #payments: week met',       'week_met',      '✓ {date}: {done} of {need}',               26),
    ('Volunteer card / #payments: week told ahead','week_told',     '🙏 {date}: told us ahead',                 27),
    ('Volunteer card / #payments: week no-show',   'week_noshow',   '✗ {date}: no-show',                        28),
    ('Volunteer card / #payments: week short',     'week_short',    '✗ {date}: {done} of {need}',               29),
    ('Volunteer card / #payments: week to mark',   'week_unmarked', '… {date}: waiting on the coach''s attendance mark', 30),
    ('Volunteer card / #payments: week to come',   'week_coming',   '• {date}: {need} to do',                   31),
    ('Volunteer card / #payments: week no slots',  'week_off',      '— {date}: no practices on your slots',     32),
    ('Volunteer month: waived',                    'month_waived',  '✓ {month} dues waived',                    33),
    ('Volunteer month: billed',                    'month_billed',  '✗ {month} dues billed ({dues}) — {why}',   34),
    ('Volunteer month: still open',                'month_open',    '{month}: on track — keep it up',           35),
    ('Volunteer month: waiting on marks',          'month_pending', '{month}: waiting on attendance marks',     36),
    ('Volunteer month why: no-show',               'why_noshow',    'a no-show',                                37),
    ('Volunteer month why: second miss',           'why_misses',    '{n} missed weeks',                         38),
    ('#payments: volunteers heading',              'ledger_heading','🙋 Volunteers — this month',               40),
    ('#payments: flag no-show',                    'flag_noshow',   '⚠️ No-show this month',                    41),
    ('#payments: flag pattern',                    'flag_pattern',  '⚠️ Used the one miss {n} months running — review', 42),
    ('#payments: end a volunteer',                 'end',           '🛑 End volunteer',                         43),
    ('#payments: bill line',                       'bill_line',     'Bill {month}: {dues}',                     44),
    ('#payments: waive line',                      'waive_line',    'Waive {month}',                            45),
    ('#payments: last month heading',              'last_month',    'Last month',                               46)
  ) AS v(label, tier, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'volunteer_shift' AND m.tier = v.tier);

-- The dues notice for an approved volunteer who still owes from before.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', 'Calendar notice — volunteer, back balance', 'my_dues', 'volunteer_owed', NULL,
       '🙋 Thanks for volunteering — make your hours every week and the month''s dues are waived. You still owe {amount} from before: pay it off when you can.', 42, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_dues' AND m.tier = 'volunteer_owed');

-- The dues emails / texts: "2 hours a week", not "one evening".
UPDATE message_templates SET body =
  'Behind on dues? You can volunteer instead — help coach the kids 2 hours a week at youth practice and that month''s dues are waived. Pick your slots on your Football Home page: https://footballhome.org/#calendar. You must be there on time every week, and tell us ahead (tap ✗) if you truly can''t make it.',
       updated_at = now()
 WHERE kind = 'payment_notice_volunteer' AND tier = 'email';
UPDATE message_templates SET body =
  'Behind on dues? Volunteer instead — help coach the kids 2 hrs a week and that month''s dues are waived. Pick slots at https://footballhome.org/#calendar. On time every week; tap ✗ ahead if you truly can''t make it.',
       updated_at = now()
 WHERE kind = 'payment_notice_volunteer' AND tier = 'sms';

-- The short calendar line (mig 1460) said "one evening a week".
UPDATE message_templates SET body =
  'You''re behind on dues ({amount} owed) — fix it now: pay it, or volunteer 2 hours a week coaching the kids. Tap 🙋 Volunteer for the details.',
       updated_at = now()
 WHERE kind = 'my_dues' AND tier = 'behind_short';

COMMIT;
