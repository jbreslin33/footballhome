-- 576 (2026-10-12) — #invoices: James's 2026.20 draft loses its usual-week
-- leftovers.  Owner: "we said to get rid of usual week lol and base
-- everything on real gcal events that were not cancelled."  Mig 572 made
-- every issuer days_source = 'events', but this draft was auto-made before
-- that and kept 11 no-event day rows from the old usual-2-weeks default —
-- they rendered as bare "Hours" lines nobody could identify.  Off they
-- come; the hours rebuild from ✓'d calendar events, and the labor line
-- restarts at 0 (syncLabor recomputes it on every ✓).
WITH tgt AS (
    SELECT v.id FROM invoices v JOIN invoice_issuers i ON i.id = v.issuer_id
     WHERE i.person_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 20 AND NOT v.is_final
)
DELETE FROM invoice_work_shifts s USING tgt
 WHERE s.invoice_id = tgt.id AND s.fh_event_id IS NULL;

UPDATE invoice_lines l SET quantity = 0, amount = 0
  FROM invoices v JOIN invoice_issuers i ON i.id = v.issuer_id
 WHERE l.invoice_id = v.id AND l.category = 'labor'
   AND i.person_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 20 AND NOT v.is_final;

-- Same breath (owner: "check all events and i would uncheck. simple. …
-- all coaches and me should have sim format"): every draft now ✓s the
-- whole calendar on open — the hint says so.
UPDATE message_templates SET body = 'Everything on the calendar starts ✓ and its hours bill — uncheck (✗) what was not worked; an RSVP no starts ✗ by itself. The RSVP and attendance columns say what really happened. ✏️ opens a popup to override the hours — rare, for a late start or staying on.'
 WHERE kind = 'invoices' AND tier = 'games_hint';
