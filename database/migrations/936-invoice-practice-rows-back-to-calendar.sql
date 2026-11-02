-- Youth practice rows on the open invoices had grown past their calendar
-- times: the reality check read a 30-minute lead-in as a "moved" event and
-- each load added the lead-in again (fixed in Invoice::realityCheck, same
-- commit).  Back to the calendar's times; the next load lays the lead-in once
-- and settles overlaps.  A flat-hours row someone typed is left alone.
UPDATE invoice_work_shifts w
   SET start_at = (g.starts_at AT TIME ZONE 'America/New_York')::time,
       end_at   = (g.ends_at   AT TIME ZONE 'America/New_York')::time,
       hours = NULL, auto_adjusted = false,
       auto_from_start = NULL, auto_from_end = NULL, auto_from_hours = NULL
  FROM invoices i, fh_events e, gcal_events g
 WHERE i.id = w.invoice_id AND NOT i.is_final
   AND i.invoice_year = 2026 AND i.invoice_number = 22
   AND e.id = w.fh_event_id AND g.id = e.gcal_event_id
   AND (w.start_at IS NOT NULL OR w.auto_adjusted)
   AND EXISTS (SELECT 1 FROM invoice_lead_in_policies p
                 JOIN fh_event_teams et ON et.fh_event_id = e.id
                 JOIN teams t ON t.id = et.team_id AND t.club_section_id = p.club_section_id
                WHERE p.is_active AND p.event_kind = e.kind);
