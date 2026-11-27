-- 1646 (2026-11-21) — 🎯 New leads in the 🚦 band until someone contacts them.
-- Owner: "we need in the todo at top … we need also for admin if a new lead
-- is sitting it should show there and be actionable".
--
-- Who: GET /api/leads/new (Lead::newWaiting) — leads on a live ad's form
-- (lead_forms) whose status is New: open and never contacted (no
-- lead_contacts row), or status_override = 'new'.  The same rule as the
-- New tab on #leads under Live ads.  Club / super / marketing admins only,
-- never while viewing as.
-- The box: "🎯 New leads — N waiting: Ralf · …  Contact ›".  Its popup lists
-- each one; tapping a name opens #leads with that lead's 📇 Contact popup
-- (touch 1 preselected).  Any email / text / call logs a touch → the name
-- drops off the band.  Mark dead / signed up on #leads clears it too.

INSERT INTO status_items (code, severity, window_hours, sort_order, is_active)
SELECT 'leads_new', 'action', NULL, 10, true
 WHERE NOT EXISTS (SELECT 1 FROM status_items WHERE code = 'leads_new');

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, 1450 + v.n, true
  FROM (VALUES
    (1, 'Band: new leads box ({n} waiting, {list} = names)', 'seg_leads_new',    '🎯 New leads — {n} waiting: {list}'),
    (2, 'Band: new leads box button',                        'act_leads_new',    'Contact ›'),
    (3, 'New leads popup title',                             'sheet_leads_new',  '🎯 New leads — nobody has contacted them yet'),
    (4, 'New leads popup: line under the title',             'leads_new_intro',  'Tap a name — their contact opens with touch 1 ready. They leave this list once you email, text or call.'),
    (5, 'New leads popup: how long waiting ({ago})',         'leads_new_ago',    '{ago} ago'),
    (6, 'New leads popup: lead with no name',                'leads_new_noname', '(no name)'),
    (7, 'New leads popup: button to the Leads board',        'leads_new_board',  '📋 Open the Leads board'),
    (8, 'New leads popup: nobody waiting',                   'leads_new_empty',  'No new leads waiting. ✓')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
