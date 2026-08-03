-- ─────────────────────────────────────────────────────────────────────
-- Attendance check-in for practices/matches. Mirrors fh_event_rsvps
-- (migration 119) — same FK shape, same UNIQUE(fh_event_id, person_id)
-- upsert target — but tracks post-event "did they actually show up"
-- rather than pre-event availability. Reserved for this purpose since
-- migration 119: see docs/calendar-design.md §10.2's table
-- ("Attendance (post-event check-in) | fh_event_attendance (future
-- table)").
--
-- No row = not yet marked (NOT the same as absent — the UI defaults
-- unmarked players to a neutral state, not a checked "absent" box).
-- `status` values cover what a coach needs at check-in; 'present' and
-- 'late' both count as "showed up" for any future eligibility use,
-- 'excused' is an absence the coach has acknowledged (vs a silent no-show).
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

CREATE TABLE fh_event_attendance (
    id                 BIGSERIAL PRIMARY KEY,
    fh_event_id        BIGINT      NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    person_id          INT         NOT NULL REFERENCES persons(id)   ON DELETE CASCADE,
    status             TEXT        NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
    marked_by_user_id  INT         REFERENCES users(id),
    marked_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (fh_event_id, person_id)
);
CREATE INDEX fh_event_attendance_person_idx ON fh_event_attendance (person_id);

COMMIT;
