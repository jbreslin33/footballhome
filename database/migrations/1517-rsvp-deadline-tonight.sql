-- 1517 (2026-11-19) — Deadline day says TONIGHT.
--
-- Owner, deadline day with 18 Liga 1 no-responses: "today is deadline so
-- do we make it more pressing to set availabilty for games".
--
-- fh_rsvp_deadline_note() (mig 507) picks the reminder's deadline line by
-- tier: deadline / deadline_plain, with _passed once it has gone.  On
-- the deadline's own day (local date = the day before the midnight
-- instant) it now picks a _today tier instead, so the reminder text, the
-- roll-call card and anything else reading the note say TONIGHT rather
-- than a weekday the reader has to work out.  No _today row → the plain
-- tier as before (the function falls back).
-- Plain ASCII on purpose (mig 684): one emoji drops a text to 70 chars
-- per SMS segment.

INSERT INTO message_templates (category, label, kind, tier, body, sort_order)
SELECT 'RSVP', v.label, 'rsvp_reminder', v.tier, v.body, v.ord
  FROM (VALUES
    ('deadline_today',       'RSVP reminder — game deadline is tonight',
     'DUE TONIGHT at midnight or you can''t start. Answer now.', 19),
    ('deadline_plain_today', 'RSVP reminder — game deadline is tonight (no start rule)',
     'DUE TONIGHT at midnight. Answer now.', 19)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m
                    WHERE m.kind = 'rsvp_reminder' AND m.tier = v.tier);

CREATE OR REPLACE FUNCTION public.fh_rsvp_deadline_note(p_fh_event_id bigint)
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  SELECT replace(m.body, '{day}',
                 to_char((i.deadline AT TIME ZONE 'America/New_York')::date - 1, 'Dy Mon FMDD'))
    FROM fh_rsvp_deadline_info(p_fh_event_id) i
    CROSS JOIN LATERAL (SELECT 'deadline' || CASE WHEN i.blocks_start THEN '' ELSE '_plain' END AS base,
                               CASE WHEN now() >= i.deadline THEN '_passed'
                                    WHEN (now() AT TIME ZONE 'America/New_York')::date
                                         = (i.deadline AT TIME ZONE 'America/New_York')::date - 1 THEN '_today'
                                    ELSE '' END AS phase) t
    JOIN message_templates m
      ON m.kind = 'rsvp_reminder' AND m.is_active
     AND m.tier IN (t.base || t.phase, t.base)
   ORDER BY (m.tier = t.base || t.phase) DESC, m.sort_order, m.id
   LIMIT 1
$function$;
