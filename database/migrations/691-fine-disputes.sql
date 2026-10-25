-- 691 (2026-10-24) — A player can dispute a no-show fine: "I was there,
-- I was marked absent."  Owner: "for fines we need to list them on the my
-- page for players and have a dispute button … they attended but were
-- not marked present … (said going but it fined them anyway — not buying
-- that one so leave out) … the guys that did not rsvp we are fining."
--
-- Only the said-yes-then-marked-absent fines (no_show_*) can be disputed;
-- no-RSVP fines cannot.  One dispute per fine.  An admin decides on
-- #fines: Approve marks the player PRESENT for that event — the fine
-- disappears on its own (fines are derived, nothing stored) and their
-- attendance record is right for starter eligibility too; Deny keeps it.

CREATE TABLE IF NOT EXISTS fine_disputes (
    id                 BIGSERIAL PRIMARY KEY,
    person_id          INT    NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    fh_event_id        BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    note               TEXT,
    status             TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'denied')),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    decided_by_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    decided_at         TIMESTAMPTZ,
    UNIQUE (person_id, fh_event_id)
);
COMMENT ON TABLE fine_disputes IS
    'mig 691: a player says they attended an event they were marked absent for (no-show fine). Approve = mark present (fine goes away); deny = fine stands.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Fines', v.l, v.k, v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('my_fines', 'dispute_button',   '#my — dispute a no-show fine',                 'I was there — dispute', 20),
    ('my_fines', 'dispute_note',     '#my — dispute box hint',                       'Anything the coach should know? (optional)', 21),
    ('my_fines', 'dispute_send',     '#my — send the dispute',                       'Send dispute', 22),
    ('my_fines', 'dispute_pending',  '#my — dispute waiting',                        'Disputed — waiting for review', 23),
    ('my_fines', 'dispute_approved', '#my — dispute approved (rarely seen: the fine goes away)', 'Dispute approved', 24),
    ('my_fines', 'dispute_denied',   '#my — dispute denied',                         'Dispute denied — fine stands', 25),
    ('fines',    'disputes_heading', '#fines — pending disputes heading ({n})',      'Disputes to review ({n})', 40),
    ('fines',    'dispute_line',     '#fines — one dispute ({name}, {event}, {amount})', '{name} says they were at {event} ({amount} no-show fine)', 41),
    ('fines',    'dispute_approve',  '#fines — approve (marks present)',             'Approve — mark present', 42),
    ('fines',    'dispute_deny',     '#fines — deny',                                'Deny', 43)
  ) AS v(k, t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
