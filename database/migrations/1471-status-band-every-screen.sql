-- 1471 (2026-11-18) — 🚦 The status band moves to the top of every screen.
-- Owner 11/18: "its supposed to be just like the viewing as bar. everything
-- in there".
--
-- components/status-banner.js: a full-width band right under the admin's
-- 🎭 view-as bar, sticky, on every screen once signed in.  Tap → the details
-- drop down from it: the unanswered events of the next 7 days (tap one to
-- open it), dues / volunteer notice, 💬 chat bar, ⚖️ fines bar.  The
-- Calendar page is just the calendar again.  New words below.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Status band — heading over the unanswered events', 'need_title',    '⚠️ Set your availability — tap one to answer', 1374),
    ('Status band — the fine on one unanswered event',   'need_row_fine', '{amount} fine',                               1375)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
