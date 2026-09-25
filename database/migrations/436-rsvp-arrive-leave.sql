-- ─────────────────────────────────────────────────────────────────────
-- 436-rsvp-arrive-leave.sql (2026-09-25)
--
-- Owner: "for rsvp … an extra field that has arrival and departure time
-- pre set to times but allows them to be edited and if so it should
-- show in yellow background … so that a player or coach can denote if
-- they will be late or leave early".
--
-- The event owns the default times (fh_events.arrival_at from the league
-- offsets, gcal_events.ends_at); the RSVP owns the exception.  NULL =
-- on time.  Player-facing wording is message_templates kind
-- 'rsvp_times' (client_side).
-- ─────────────────────────────────────────────────────────────────────
ALTER TABLE fh_event_rsvps ADD COLUMN IF NOT EXISTS arrive_at TIMESTAMPTZ;
ALTER TABLE fh_event_rsvps ADD COLUMN IF NOT EXISTS leave_at  TIMESTAMPTZ;
COMMENT ON COLUMN fh_event_rsvps.arrive_at IS 'When this person says they will arrive, if not the event''s arrival time (mig 436). NULL = on time.';
COMMENT ON COLUMN fh_event_rsvps.leave_at  IS 'When this person says they will leave, if before the event ends (mig 436). NULL = stays to the end.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', l, 'rsvp_times', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('arrive_label', 'RSVP times — label on the arrival field',        'Arrive',                 720),
    ('leave_label',  'RSVP times — label on the departure field',      'Leave',                  721),
    ('hint',         'RSVP times — under the two fields',              'Late or leaving early? Change the time and the coach will see it.', 722),
    ('chip_arrive',  'RSVP times — chip beside a name (who''s going)', 'arrives {time}',         723),
    ('chip_leave',   'RSVP times — chip beside a name (who''s going)', 'leaves {time}',          724),
    ('reset',        'RSVP times — link to put a time back',           'on time',                725)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'rsvp_times' AND m.tier = v.t);
