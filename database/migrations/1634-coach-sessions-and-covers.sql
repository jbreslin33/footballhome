-- 1634 (2026-11-20) — 🗓️ Coach schedule by SESSION, weekend duty, cover asks.
-- Owner 11/20: "it should mirror the weeks schedule … we always have a
-- consistent schedule even if some are canceled. and then some would weekend
-- duties for games" · "the level of detail is not enough" · "view by coach or
-- by session … or by day or week" · "yes default to team games. we also need
-- a way for coaches to request other coaches to cover. it would open their
-- text needs to work on andriod and appple".
--
-- * A SESSION is one standing practice slot of the week: weekday + local
--   start, read off the calendar (the calendar IS the schedule — repeating
--   gcal practices).  A cancelled week is still the same session.
-- * A coach with a plan (coach_session_plans) is expected at, and RSVPs to,
--   only the practices on their sessions (coach_sessions).  A plan with no
--   sessions = call in if needed.  No plan = every practice of their teams.
--   Replaces the per-section weekday rule of mig 955 for staff; volunteer
--   slot schedules (mig 1224/1461) keep coach_schedules.
-- * Weekend duty = their teams' games, unchanged — a cover moves one.
-- * A COVER: a coach asks for cover on one event; asked coaches get a text
--   (sms: link, works on Android + iPhone); whoever takes it is on that event
--   and the asker is off it.
BEGIN;

-- ── The standing week ─────────────────────────────────────────────────────
-- Every practice slot with a live (not cancelled / deleted) practice from a
-- week back to four weeks ahead: weekday, local start/end, the calendar's
-- usual title ("Soccer " dropped), its teams.
CREATE OR REPLACE FUNCTION fh_practice_sessions(p_on date DEFAULT CURRENT_DATE)
RETURNS TABLE (isodow smallint, starts_at time, ends_at time, label text, team_ids integer[], teams text)
LANGUAGE sql STABLE AS $$
    WITH ev AS (
        SELECT fe.id,
               extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::smallint AS dow,
               (ge.starts_at AT TIME ZONE 'America/New_York')::time AS st,
               (ge.ends_at   AT TIME ZONE 'America/New_York')::time AS en,
               regexp_replace(COALESCE(ge.summary, ''), '^\s*Soccer\s+', '', 'i') AS summ
          FROM gcal_events ge
          JOIN fh_events fe ON fe.gcal_event_id = ge.id AND fe.kind = 'practice'
         WHERE ge.starts_at >= (p_on - 7)::timestamp AT TIME ZONE 'America/New_York'
           AND ge.starts_at <  (p_on + 28)::timestamp AT TIME ZONE 'America/New_York'
           AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
    )
    SELECT ev.dow, ev.st, max(ev.en),
           mode() WITHIN GROUP (ORDER BY ev.summ),
           (SELECT array_agg(DISTINCT fet.team_id ORDER BY fet.team_id)
              FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id AND t.is_active
             WHERE fet.fh_event_id = ANY (array_agg(ev.id))),
           (SELECT string_agg(DISTINCT t.name, ', ')
              FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id AND t.is_active
             WHERE fet.fh_event_id = ANY (array_agg(ev.id)))
      FROM ev
     GROUP BY ev.dow, ev.st
     ORDER BY ev.dow, ev.st
$$;

-- ── Who covers which session ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS coach_session_plans (
    coach_id   integer PRIMARY KEY REFERENCES coaches(id) ON DELETE CASCADE,
    starts_at  timestamptz NOT NULL DEFAULT now(),   -- events before it are untouched
    created_at timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE coach_session_plans IS
  'mig 1634: this coach is on the standing week — expected only at practices on their coach_sessions; no sessions = call in. No row = every practice of their teams.';

CREATE TABLE IF NOT EXISTS coach_sessions (
    coach_id  integer  NOT NULL REFERENCES coach_session_plans(coach_id) ON DELETE CASCADE,
    isodow    smallint NOT NULL CHECK (isodow BETWEEN 1 AND 7),
    starts_at time     NOT NULL,                     -- local (America/New_York) start
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (coach_id, isodow, starts_at)
);
COMMENT ON TABLE coach_sessions IS
  'mig 1634: one standing practice session (weekday + local start, = fh_practice_sessions) a coach covers.';

-- ── Cover asks ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS coach_covers (
    id                 bigserial PRIMARY KEY,
    fh_event_id        bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    coach_id           integer NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,   -- who needs cover
    note               text,
    status             text    NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'covered', 'withdrawn')),
    cover_coach_id     integer REFERENCES coaches(id),                              -- who took it
    created_by_user_id integer,
    created_at         timestamptz NOT NULL DEFAULT now(),
    covered_at         timestamptz,
    covered_by_user_id integer,
    withdrawn_at       timestamptz,
    CHECK ((status = 'covered') = (cover_coach_id IS NOT NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS coach_covers_one_live
    ON coach_covers (fh_event_id, coach_id) WHERE status <> 'withdrawn';
CREATE INDEX IF NOT EXISTS coach_covers_event ON coach_covers (fh_event_id) WHERE status = 'covered';
COMMENT ON TABLE coach_covers IS
  'mig 1634: a coach asks for cover on one event. covered → cover_coach is on that event, coach is off it.';

CREATE TABLE IF NOT EXISTS coach_cover_asks (
    cover_id  bigint  NOT NULL REFERENCES coach_covers(id) ON DELETE CASCADE,
    coach_id  integer NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    asked_at  timestamptz NOT NULL DEFAULT now(),
    texted_at timestamptz,
    PRIMARY KEY (cover_id, coach_id)
);
COMMENT ON TABLE coach_cover_asks IS 'mig 1634: who a cover was asked of (and when the text was opened).';

-- ── The one rule (callers unchanged: person, team, event) ────────────────
CREATE OR REPLACE FUNCTION fh_coach_off_schedule(p_person_id integer, p_team_id integer, p_fh_event_id bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT CASE
    -- mig 1634: covering this one → on it, whatever the plan says
    WHEN EXISTS (SELECT 1 FROM coach_covers cc JOIN coaches c ON c.id = cc.cover_coach_id
                  WHERE cc.fh_event_id = p_fh_event_id AND cc.status = 'covered' AND c.person_id = p_person_id)
      THEN false
    -- mig 1634: someone covers for them → off it
    WHEN EXISTS (SELECT 1 FROM coach_covers cc JOIN coaches c ON c.id = cc.coach_id
                  WHERE cc.fh_event_id = p_fh_event_id AND cc.status = 'covered' AND c.person_id = p_person_id)
      THEN true
    ELSE
      -- mig 1634: on the standing week → practices on their sessions only
      EXISTS (
        SELECT 1
          FROM coach_session_plans pl
          JOIN coaches c ON c.id = pl.coach_id AND c.person_id = p_person_id
          JOIN fh_events fe ON fe.id = p_fh_event_id AND fe.kind = 'practice'
          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
         WHERE ge.starts_at >= pl.starts_at
           AND NOT EXISTS (SELECT 1 FROM coach_sessions x
                            WHERE x.coach_id = pl.coach_id
                              AND x.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int
                              AND x.starts_at = (ge.starts_at AT TIME ZONE 'America/New_York')::time))
      OR EXISTS (   -- volunteer schedules (mig 955 / 1224 / 1461), unchanged
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
                      OR (EXISTS (SELECT 1 FROM coach_schedule_slots x WHERE x.coach_schedule_id = s.id)
                          AND NOT EXISTS (SELECT 1 FROM coach_schedule_slots x
                                           WHERE x.coach_schedule_id = s.id
                                             AND x.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int
                                             AND x.starts_at = (ge.starts_at AT TIME ZONE 'America/New_York')::time))
                    ELSE s.practices_only END)
  END
$function$;

-- ── Carry today's weekday schedules over (staff only, not volunteers) ─────
-- A coach's sessions = the sessions with one of their teams, on their days
-- for a section they had days in, every day for any other section.  Every
-- day in every section = no plan (every practice), as before.
WITH staff AS (
    SELECT s.id, s.coach_id, s.club_section_id, s.starts_at,
           COALESCE((SELECT array_agg(d.isodow) FROM coach_schedule_days d WHERE d.coach_schedule_id = s.id), '{}') AS days
      FROM coach_schedules s
     WHERE NOT s.practices_only
       AND NOT EXISTS (SELECT 1 FROM coach_schedule_slots x WHERE x.coach_schedule_id = s.id)
), partial AS (
    SELECT * FROM staff WHERE cardinality(days) < 7
), plans AS (
    INSERT INTO coach_session_plans (coach_id, starts_at)
    SELECT coach_id, min(starts_at) FROM partial GROUP BY coach_id
    ON CONFLICT (coach_id) DO NOTHING
    RETURNING coach_id
)
INSERT INTO coach_sessions (coach_id, isodow, starts_at)
SELECT DISTINCT p.coach_id, ps.isodow, ps.starts_at
  FROM plans p
  JOIN team_coaches tc ON tc.coach_id = p.coach_id AND tc.ended_at IS NULL
  JOIN teams t ON t.id = tc.team_id AND t.is_active
  JOIN fh_practice_sessions() ps ON t.id = ANY (ps.team_ids)
  LEFT JOIN partial pa ON pa.coach_id = p.coach_id AND pa.club_section_id = t.club_section_id
 WHERE pa.id IS NULL OR ps.isodow = ANY (pa.days)
ON CONFLICT DO NOTHING;

DELETE FROM coach_schedules s
 WHERE NOT s.practices_only
   AND NOT EXISTS (SELECT 1 FROM coach_schedule_slots x WHERE x.coach_schedule_id = s.id);

-- ── Coaches open the page (to see the week and ask for cover) ─────────────
UPDATE menu_pages SET audience = 'coach' WHERE code = 'coach-schedule';

-- ── Words ─────────────────────────────────────────────────────────────────
UPDATE message_templates SET body = 'Every session'
 WHERE kind = 'coach_schedule' AND tier = 'every';
UPDATE message_templates SET body = 'The sessions each coach covers — what they see and RSVP to; weekends = their teams'' games'
 WHERE kind = 'coach_schedule' AND tier = 'tile_sub';
UPDATE message_templates SET body = 'To call a coach in for one practice, invite them on it in Event Center.'
 WHERE kind = 'coach_schedule' AND tier = 'call_in_hint';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Coach Schedule', v.l, 'coach_schedule', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('pill_week',      'Pill: this week',            '📅 Week', 30),
    ('pill_session',   'Pill: by session',           '🕒 By session', 31),
    ('pill_coach',     'Pill: by coach',             '👤 By coach', 32),
    ('week_of',        'Week heading',               'Week of {date}', 33),
    ('session_hint',   'By session line',            'The standing week, off the calendar. A cancelled week is still the same session.', 34),
    ('coach_hint',     'By coach line',              'Tap a session to add or drop it. Weekend duty = the coach''s teams'' games.', 35),
    ('week_hint',      'Week line',                  'Who is on each practice and game this week. Tap 🙋 to ask for cover.', 36),
    ('weekend_duty',   'Weekend duty label',         'Weekend: {teams} games', 37),
    ('no_coach',       'Event without a coach',      'No coach', 38),
    ('cancelled',      'Cancelled event',            'Cancelled', 39),
    ('ask_cover',      'Ask for cover button',       '🙋 Cover', 40),
    ('ask_title',      'Ask sheet title',            'Who could cover {coach} — {event}?', 41),
    ('ask_send',       'Ask button',                 'Ask them', 42),
    ('ask_text',       'Per-coach text button',      '💬 Text {first}', 43),
    ('ask_no_phone',   'No phone for a coach',       '{first}: no phone on file', 44),
    ('needs_cover',    'Open cover badge',           '🆘 {coach} needs cover', 45),
    ('covered_by',     'Covered badge',              '🔁 {cover} for {coach}', 46),
    ('take_cover',     'Take cover button',          '✋ I''ll cover', 47),
    ('withdraw',       'Withdraw cover button',      'Cancel ask', 48),
    ('my_week',        'My sessions heading',        'My sessions', 49),
    ('session_gone',   'Plan slot not on calendar',  'not on the calendar now', 50),
    ('cover_sms',      'Cover ask text',             'Hi {first}, can you cover {event} on {when} for {coach}? Tap to take it: {link}', 51)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'coach_schedule' AND m.tier = v.t);

COMMIT;
