-- 712 (2026-10-26) — invoice hours come from calendar events only, and
-- youth practices carry a lead-in.  Owner: "only use gcal events and auto
-- give coaches for youth 30 minutes before start of 1st practice they
-- attend that day"; "get rid of usual week completely".
--
-- • days_source goes: every issuer has been 'events' since mig 572, and
--   new drafts no longer copy a usual week.  invoice_default_shifts STAYS
--   only as the #finances coaching projection input (Expenses.cpp
--   coaching_usual, mig 494) — nothing on #invoices reads or writes it.
-- • invoice_lead_in_policies: per club section + event kind, the minutes a
--   coach is credited before the day's FIRST billed such event
--   (Invoice::applyLeadIns).  Boys/Girls practices = 30.
ALTER TABLE invoice_issuers DROP COLUMN IF EXISTS days_source;

CREATE TABLE IF NOT EXISTS invoice_lead_in_policies (
    id               serial PRIMARY KEY,
    club_section_id  integer NOT NULL REFERENCES club_sections(id),
    event_kind       text    NOT NULL,
    minutes_before   integer NOT NULL CHECK (minutes_before BETWEEN 1 AND 240),
    is_active        boolean NOT NULL DEFAULT true,
    note             text,
    UNIQUE (club_section_id, event_kind)
);

INSERT INTO invoice_lead_in_policies (club_section_id, event_kind, minutes_before, note)
SELECT cs.id, 'practice', 30, 'Youth set-up: 30 min before the first practice of the day'
  FROM club_sections cs WHERE cs.name IN ('Boys', 'Girls')
ON CONFLICT (club_section_id, event_kind) DO NOTHING;
