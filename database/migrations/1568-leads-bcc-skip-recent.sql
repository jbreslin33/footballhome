-- 1568 (2026-11-19) — ✉️ BCC touch 1 skips anyone emailed or texted in the
-- last 3 days.  Owner: "by default if one was sent out in last 3 days? then
-- dont include them?".  The day count is the recent_days row; the button
-- adds "· {k} sent in the last {days} days" when it left anyone out.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.category, v.label, 'leads_bcc', v.tier, v.body, v.sort_order, true
  FROM (VALUES
    ('Leads', 'BCC touch 1: skip anyone emailed/texted within this many days (0 = off)', 'recent_days', '3', 15),
    ('Leads', 'BCC touch 1: after the button when some were left out ({k}, {days})',     'skipped',     ' · {k} sent in the last {days} days', 25)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'leads_bcc' AND m.tier = v.tier);
UPDATE message_templates
   SET body = 'Everyone on the board not registered yet (not signed up, not a member, not dead), except anyone emailed or texted in the last {days} days. Each one logs an email touch.',
       updated_at = now()
 WHERE kind = 'leads_bcc' AND tier = 'hint';
