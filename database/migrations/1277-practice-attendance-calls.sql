-- 1277: 📞 Practice attendance calls (owner 2026-11-11: "can we call all
-- coaches that set going to practice 1/2 way through to remind to take
-- attendance? until all players who set going are markd off it will call
-- all coaches lol. like it does for lockup in security screen").
--
-- From the practice's halfway point (start_fraction of start → end), the
-- coaches who said Going get a phone call every repeat_minutes until every
-- player who said Going has an attendance mark (any of P/A/L/E), or the
-- practice has been over stop_after_end_minutes.  Round 1 also texts them
-- the names still unmarked and a link to the practice's Players pill.
-- AttendanceCallScheduler (backend) runs it every minute, like the
-- lock-up ladder (LockupScheduler, mig 421/426).
--
-- live = false (TEST): every call/text goes to test_person_id instead of
-- the coaches, so the owner hears it first.  Flip live by migration.
--
--   attendance_call_policies  one row per section
--   attendance_call_rounds    one row per call round per practice
--   attendance_call_log       every call / text tried, ok or not
--   fh_attendance_call_going(event)   who said Going: is_coach / is_player
--   fh_attendance_calls_due           practices owed a round right now
CREATE TABLE IF NOT EXISTS attendance_call_policies (
  category               text PRIMARY KEY CHECK (category IN ('mens', 'womens', 'boys', 'girls')),
  is_on                  boolean NOT NULL DEFAULT true,
  live                   boolean NOT NULL DEFAULT false,
  test_person_id         integer REFERENCES persons(id) ON DELETE SET NULL,
  start_fraction         numeric NOT NULL DEFAULT 0.5 CHECK (start_fraction >= 0 AND start_fraction <= 1),
  repeat_minutes         integer NOT NULL DEFAULT 10 CHECK (repeat_minutes >= 5),
  stop_after_end_minutes integer NOT NULL DEFAULT 60 CHECK (stop_after_end_minutes >= 0),
  send_text              boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE attendance_call_policies IS
  'Practice attendance calls per section (mig 1277): from start_fraction of the practice, call Going coaches every repeat_minutes until every Going player is marked; live=false rings test_person_id only.';

INSERT INTO attendance_call_policies (category, is_on, live, test_person_id)
VALUES ('mens', true, false, 1), ('womens', true, false, 1), ('boys', true, false, 1), ('girls', true, false, 1)
ON CONFLICT (category) DO NOTHING;

CREATE TABLE IF NOT EXISTS attendance_call_rounds (
  fh_event_id bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
  round       integer NOT NULL,
  unmarked    integer NOT NULL,
  live        boolean NOT NULL,
  called_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (fh_event_id, round)
);
COMMENT ON TABLE attendance_call_rounds IS 'One row per attendance-call round per practice (mig 1277).';

CREATE TABLE IF NOT EXISTS attendance_call_log (
  id          bigserial PRIMARY KEY,
  fh_event_id bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
  round       integer NOT NULL,
  person_id   integer REFERENCES persons(id) ON DELETE SET NULL,
  channel     text    NOT NULL CHECK (channel IN ('call', 'sms')),
  contact     text,
  ok          boolean NOT NULL,
  twilio_sid  text,
  error       text,
  at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS attendance_call_log_event_idx ON attendance_call_log (fh_event_id);
COMMENT ON TABLE attendance_call_log IS 'Every attendance call / text tried (mig 1277).';

-- Who said Going to a practice.  is_coach: an active coach of one of the
-- practice's teams who isn't there only to play (role_choice ''player'').
-- is_player: everyone else who said Going, plus coach-players who picked
-- Both / Playing (mig 688) — they need an attendance mark.
CREATE OR REPLACE FUNCTION fh_attendance_call_going(p_event bigint)
RETURNS TABLE (person_id int, is_coach boolean, is_player boolean, marked boolean)
LANGUAGE sql STABLE AS $$
  WITH coach AS (
    SELECT DISTINCT c.person_id
      FROM fh_event_teams et
      JOIN team_coaches tc ON tc.team_id = et.team_id AND tc.ended_at IS NULL
      JOIN coaches c       ON c.id = tc.coach_id
     WHERE et.fh_event_id = p_event
  )
  SELECT v.person_id,
         (k.person_id IS NOT NULL AND COALESCE(v.role_choice, 'coach') <> 'player') AS is_coach,
         (k.person_id IS NULL OR COALESCE(v.role_choice IN ('player', 'both'), false)) AS is_player,
         EXISTS (SELECT 1 FROM fh_event_attendance a WHERE a.fh_event_id = p_event AND a.person_id = v.person_id) AS marked
    FROM fh_event_rsvps v
    LEFT JOIN coach k ON k.person_id = v.person_id
   WHERE v.fh_event_id = p_event AND v.response = 'yes'
$$;
COMMENT ON FUNCTION fh_attendance_call_going(bigint) IS 'Going RSVPs at a practice split into coaches (called) and players (must be marked) — mig 1277.';

-- Practices owed a call round now.  Cheap filters (kind, today-ish,
-- inside the window) before the per-event checks.
CREATE OR REPLACE VIEW fh_attendance_calls_due AS
  WITH ev AS MATERIALIZED (
    SELECT e.id, e.category, g.starts_at, g.ends_at, p.live, p.test_person_id, p.repeat_minutes, p.send_text,
           g.starts_at + (g.ends_at - g.starts_at) * p.start_fraction AS calls_from,
           g.ends_at + make_interval(mins => p.stop_after_end_minutes) AS calls_until
      FROM fh_events e
      JOIN gcal_events g ON g.id = e.gcal_event_id
      JOIN attendance_call_policies p ON p.category = e.category AND p.is_on
     WHERE e.kind = 'practice'
       AND g.deleted_at IS NULL AND COALESCE(g.status, '') <> 'cancelled'
       AND g.starts_at > now() - interval '1 day' AND g.starts_at < now()
       AND g.ends_at IS NOT NULL
  )
  SELECT ev.*,
         (SELECT count(*) FROM fh_attendance_call_going(ev.id) x WHERE x.is_player AND NOT x.marked)::int AS unmarked,
         COALESCE((SELECT max(r.round) FROM attendance_call_rounds r WHERE r.fh_event_id = ev.id), 0) AS rounds
    FROM ev
   WHERE now() >= ev.calls_from AND now() < ev.calls_until
     AND EXISTS (SELECT 1 FROM fh_attendance_call_going(ev.id) x WHERE x.is_player AND NOT x.marked)
     AND EXISTS (SELECT 1 FROM fh_attendance_call_going(ev.id) x WHERE x.is_coach)
     AND NOT EXISTS (SELECT 1 FROM attendance_call_rounds r
                      WHERE r.fh_event_id = ev.id AND r.called_at > now() - make_interval(mins => ev.repeat_minutes));
COMMENT ON VIEW fh_attendance_calls_due IS 'Practices owed an attendance-call round right now (mig 1277).';

-- Copy (kind = attendance_call).  Tokens: {first} coach first name,
-- {practice} e.g. "Men's 7 PM", {n} players unmarked, {names}, {link},
-- {round}, {time}, {every}, {who}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Attendance calls', l, 'attendance_call', t, NULL, b, o, true, c, false
  FROM (VALUES
    ('call',        'Phone call — spoken ({first} {practice} {n})',
                    'Hi {first}, this is Football Home. {n} players who said they are going to {practice} practice still have no attendance. Please open the practice in Football Home and mark them. Thank you.', 1400, false),
    ('sms',         'Text with round 1 ({first} {practice} {n} {names} {link})',
                    E'Hi {first} — {n} going players at {practice} practice still need attendance: {names}\nMark them: {link}\nFootball Home will keep calling the coaches until they''re marked.', 1401, false),
    ('strip_title', 'Practice page strip — title',            '📞 Attendance calls', 1402, true),
    ('strip_when',  'Strip — rule ({time} {every})',          'From {time} the coaches who said Going get a call every {every} min until every Going player is marked', 1403, true),
    ('strip_wait',  'Strip — not marked yet ({n})',           '{n} going players not marked yet', 1404, true),
    ('strip_done',  'Strip — all marked',                     '✅ Every going player is marked — no calls', 1405, true),
    ('strip_nocoach','Strip — no coach going',                'No coach said Going — nobody to call', 1406, true),
    ('strip_test',  'Strip — test mode ({who})',              '🧪 Test mode: calls ring {who} only, not the coaches', 1407, true),
    ('strip_last',  'Strip — last round ({round} {time})',    'Round {round} at {time}', 1408, true),
    ('strip_off',   'Strip — off for this section',           'Attendance calls are off for this section', 1409, true),
    ('strip_coaches','Strip — who gets called ({names})',     'Calls: {names}', 1410, true)
  ) AS v(t, l, b, o, c)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'attendance_call' AND m.tier = v.t);
