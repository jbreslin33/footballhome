-- 594 (2026-10-19) — Ref fee picker checks the calendar.  Owner: "the
-- invoice load should check gcal. if an event is in gcal it can be used
-- for hours or refs but if not it would need to be added manually."
--
-- Hours already come only from gcal-backed events; this closes the refs
-- side: a league-feed game with no live gcal match of the same league on
-- the same local day is shown dimmed and untickable in the REFEREE FEES
-- picker — if it is real, it goes on the sheet by hand (ADD A LINE).
-- The flag itself is computed in Expenses::games (in_gcal); this
-- migration only adds the row's label copy.

CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.tpl('invoices', 'refs_not_on_gcal', 'Invoices — feed game not on the calendar',
                   'not on the calendar — add manually', 104);
